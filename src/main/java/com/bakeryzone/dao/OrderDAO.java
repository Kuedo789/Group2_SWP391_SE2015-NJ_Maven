
package com.bakeryzone.dao;

import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.HashMap;

public class OrderDAO {

    private String escapeWildcards(String keyword) {
        if (keyword == null) {
            return null;
        }
        return keyword.replace("\\", "\\\\")
                      .replace("%", "\\%")
                      .replace("_", "\\_");
    }

    public String getCustomerIdByUserId(String userId) {
        String sql = "SELECT Customer_ID FROM customer WHERE User_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Customer_ID");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userId;
    }

    public List<Order> getOrdersByCustomerId(String customerId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM `orders` WHERE Customer_ID = ? ORDER BY Order_Time DESC";

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapRowToOrder(rs));
                }
            }
            populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    /**
     * Đếm số đơn hàng của một khách hàng theo bộ lọc (date, status, search).
     * Dùng cho customer-side pagination – thực hiện filter hoàn toàn ở DB.
     *
     * @param uiStatus "processing" | "shipping" | "completed" | "cancelled" | "all"
     *                 | null
     */
    public int getOrdersCountByCustomer(String customerId, String keyword, String uiStatus,
            String startDateStr, String endDateStr) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT o.Order_No) FROM `orders` o"
                        + " LEFT JOIN order_item oi ON o.Order_No = oi.Order_No"
                        + " LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID"
                        + " LEFT JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017'))"
                        + " LEFT JOIN accessory a ON oi.Accessory_ID = a.Accessory_ID"
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR COALESCE(NULLIF(TRIM(t.Template_Name),''), NULLIF(TRIM(a.Accessory_Name),'')) LIKE ?)");
            String kw = "%" + escapeWildcards(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
        }
        appendCustomerStatusFilter(sql, params, uiStatus);
        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr.trim() + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr.trim() + " 23:59:59");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lấy danh sách đơn hàng đã phân trang của một khách hàng.
     * Filter, sort, LIMIT/OFFSET thực hiện hoàn toàn ở DB.
     * Items chỉ được load cho đúng pageSize bản ghi (giải quyết N+1).
     */
    public List<Order> getOrdersByCustomerPaged(String customerId, String keyword, String uiStatus,
            String startDateStr, String endDateStr, String sort, int page, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT o.* FROM `orders` o"
                        + " LEFT JOIN order_item oi ON o.Order_No = oi.Order_No"
                        + " LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID"
                        + " LEFT JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017'))"
                        + " LEFT JOIN accessory a ON oi.Accessory_ID = a.Accessory_ID"
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR COALESCE(NULLIF(TRIM(t.Template_Name),''), NULLIF(TRIM(a.Accessory_Name),'')) LIKE ?)");
            String kw = "%" + escapeWildcards(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
        }
        appendCustomerStatusFilter(sql, params, uiStatus);
        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr.trim() + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr.trim() + " 23:59:59");
        }

        // Sort
        String orderByClause = " ORDER BY o.Order_Time DESC";
        if (sort != null) {
            switch (sort.trim().toLowerCase()) {
                case "date_asc":
                    orderByClause = " ORDER BY o.Order_Time ASC";
                    break;
                case "price_desc":
                    orderByClause = " ORDER BY o.Total_Cost DESC";
                    break;
                case "price_asc":
                    orderByClause = " ORDER BY o.Total_Cost ASC";
                    break;
                default:
                    orderByClause = " ORDER BY o.Order_Time DESC";
                    break;
            }
        }
        sql.append(orderByClause).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapRowToOrder(rs));
                }
            }
            populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    /**
     * Đếm số đơn hàng theo từng trạng thái UI cho customer tab counts.
     * Trả về Map: "all", "processing", "shipping", "completed", "cancelled".
     */
    public java.util.Map<String, Integer> getOrderStatusCountsByCustomer(String customerId,
            String keyword, String startDateStr, String endDateStr) {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("all", 0);
        counts.put("processing", 0);
        counts.put("shipping", 0);
        counts.put("completed", 0);
        counts.put("cancelled", 0);

        StringBuilder sql = new StringBuilder(
                "SELECT o.OrderStatus, COUNT(DISTINCT o.Order_No) AS cnt FROM `orders` o"
                        + " LEFT JOIN order_item oi ON o.Order_No = oi.Order_No"
                        + " LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID"
                        + " LEFT JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR"
                        + " (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017'))"
                        + " LEFT JOIN accessory a ON oi.Accessory_ID = a.Accessory_ID"
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR COALESCE(NULLIF(TRIM(t.Template_Name),''), NULLIF(TRIM(a.Accessory_Name),'')) LIKE ?)");
            String kw = "%" + escapeWildcards(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
        }
        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr.trim() + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr.trim() + " 23:59:59");
        }
        sql.append(" GROUP BY o.OrderStatus");

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String dbStatus = rs.getString("OrderStatus");
                    int cnt = rs.getInt("cnt");
                    counts.put("all", counts.get("all") + cnt);
                    if (dbStatus != null) {
                        if (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed")
                                || dbStatus.equalsIgnoreCase("Processing") || dbStatus.equalsIgnoreCase("PAID")) {
                            counts.put("processing", counts.get("processing") + cnt);
                        } else if (dbStatus.equalsIgnoreCase("Delivering")) {
                            counts.put("shipping", counts.get("shipping") + cnt);
                        } else if (dbStatus.equalsIgnoreCase("Completed")) {
                            counts.put("completed", counts.get("completed") + cnt);
                        } else if (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled")) {
                            counts.put("cancelled", counts.get("cancelled") + cnt);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    /** Helper: Thêm điều kiện WHERE cho uiStatus vào câu SQL đang build. */
    private void appendCustomerStatusFilter(StringBuilder sql, List<Object> params, String uiStatus) {
        if (uiStatus == null || uiStatus.equalsIgnoreCase("all"))
            return;
        switch (uiStatus.toLowerCase()) {
            case "processing":
                sql.append(" AND o.OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'PAID')");
                break;
            case "shipping":
                sql.append(" AND o.OrderStatus = 'Delivering'");
                break;
            case "completed":
                sql.append(" AND o.OrderStatus = 'Completed'");
                break;
            case "cancelled":
                sql.append(" AND o.OrderStatus IN ('Cancelled', 'Canceled')");
                break;
        }
    }

    public Order getOrderByNo(String orderNo) {
        String sql = "SELECT * FROM `orders` WHERE Order_No = ?";

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    order.getItems().addAll(getOrderItems(order.getOrderNo(), conn));
                    if (order.getTripId() != null && !order.getTripId().trim().isEmpty()) {
                        order.setShipperName(getShipperNameByTripId(order.getTripId()));
                    }
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public String getShipperNameByTripId(String tripId) {
        String sql = "SELECT s.Full_Name FROM `staff` s JOIN `delivery_trip` dt ON s.Staff_ID = dt.Shipper_ID WHERE dt.Trip_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Full_Name");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    public String getManagedZoneByStaffId(String staffId) {
        String sql = "SELECT Managed_Zone FROM `staff` WHERE Staff_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Managed_Zone");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private void populateOrderItems(List<Order> orders, Connection conn) throws Exception {
        if (orders == null || orders.isEmpty()) {
            return;
        }

        Map<String, Order> orderMap = new HashMap<>();
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < orders.size(); i++) {
            Order o = orders.get(i);
            orderMap.put(o.getOrderNo(), o);
            inClause.append(i == 0 ? "?" : ", ?");
        }

        String sql = """
                SELECT
                    oi.Order_Item_ID,
                    oi.Order_No,
                    oi.Custom_Cake_ID,
                    oi.Accessory_ID,
                    oi.Quantity,
                    oi.Price_At_Purchase,
                    COALESCE(NULLIF(TRIM(t.Template_Name), ''), NULLIF(TRIM(a.Accessory_Name), '')) AS Item_Name,
                    COALESCE(NULLIF(TRIM(cc.Canvas_Image_URL), ''), NULLIF(TRIM(t.Image_URL), ''), NULLIF(TRIM(a.Image_URL), '')) AS Item_Image,
                    cc.Greeting_Text,
                    COALESCE(NULLIF(TRIM(cat.Category_Name), ''), 'Phụ kiện') AS Category_Name,
                    t.Template_ID,
                    COALESCE(NULLIF(TRIM(t.Image_URL), ''), NULLIF(TRIM(a.Image_URL), '')) AS Template_Image,
                    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0)
                     FROM template_ingredient_detail d
                     JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID
                     WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                    t.Default_Margin_Percent,
                    t.Default_Service_Percent
                FROM order_item oi
                LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
                LEFT JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017'))
                LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID
                LEFT JOIN accessory a ON oi.Accessory_ID = a.Accessory_ID
                WHERE oi.Order_No IN (
                """
                + inClause + ")";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < orders.size(); i++) {
                ps.setString(i + 1, orders.get(i).getOrderNo());
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getString("Order_Item_ID"));
                    item.setOrderNo(rs.getString("Order_No"));
                    item.setCustomCakeId(rs.getString("Custom_Cake_ID"));
                    item.setAccessoryId(rs.getString("Accessory_ID"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setPriceAtPurchase(rs.getBigDecimal("Price_At_Purchase"));
                    item.setItemName(rs.getString("Item_Name"));
                    item.setItemImage(rs.getString("Item_Image"));
                    item.setGreetingText(rs.getString("Greeting_Text"));
                    item.setCategoryName(rs.getString("Category_Name"));
                    item.setTemplateId(rs.getString("Template_ID"));
                    item.setTemplateImage(rs.getString("Template_Image"));

                    if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                        double ingredientCost = rs.getDouble("Ingredient_Cost");
                        double margin = rs.getDouble("Default_Margin_Percent");
                        double service = rs.getDouble("Default_Service_Percent");
                        double divisor = 1.0 - ((margin + service) / 100.0);
                        double basePrice = 0.0;
                        if (divisor > 0.0) {
                            basePrice = ingredientCost / divisor;
                        } else {
                            basePrice = ingredientCost;
                        }
                        basePrice = Math.ceil(basePrice / 1000.0) * 1000.0;

                        double purchasePrice = item.getPriceAtPurchase() != null
                                ? item.getPriceAtPurchase().doubleValue()
                                : 0.0;
                        double diff = purchasePrice - basePrice;
                        if (diff <= 40000) {
                            item.setVariationName("Size 16cm");
                        } else if (diff <= 120000) {
                            item.setVariationName("Size 20cm");
                        } else {
                            item.setVariationName("Size 24cm");
                        }
                    } else if (item.getAccessoryId() != null && !item.getAccessoryId().trim().isEmpty()) {
                        item.setVariationName("Phụ kiện");
                    } else {
                        item.setVariationName("Tiêu chuẩn");
                    }

                    Order o = orderMap.get(item.getOrderNo());
                    if (o != null) {
                        o.getItems().add(item);
                    }
                }
            }
        }
    }

    private List<OrderItem> getOrderItems(String orderNo, Connection conn) throws Exception {
        List<OrderItem> items = new ArrayList<>();
        String sql = """
                SELECT
                    oi.Order_Item_ID,
                    oi.Order_No,
                    oi.Custom_Cake_ID,
                    oi.Accessory_ID,
                    oi.Quantity,
                    oi.Price_At_Purchase,
                    COALESCE(NULLIF(TRIM(t.Template_Name), ''), NULLIF(TRIM(a.Accessory_Name), '')) AS Item_Name,
                    COALESCE(NULLIF(TRIM(cc.Canvas_Image_URL), ''), NULLIF(TRIM(t.Image_URL), ''), NULLIF(TRIM(a.Image_URL), '')) AS Item_Image,
                    cc.Greeting_Text,
                    COALESCE(NULLIF(TRIM(cat.Category_Name), ''), 'Phụ kiện') AS Category_Name,
                    t.Template_ID,
                    COALESCE(NULLIF(TRIM(t.Image_URL), ''), NULLIF(TRIM(a.Image_URL), '')) AS Template_Image,
                    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0)
                     FROM template_ingredient_detail d
                     JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID
                     WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                    t.Default_Margin_Percent,
                    t.Default_Service_Percent
                FROM order_item oi
                LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
                LEFT JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                    (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017'))
                LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID
                LEFT JOIN accessory a ON oi.Accessory_ID = a.Accessory_ID
                WHERE oi.Order_No = ?
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getString("Order_Item_ID"));
                    item.setOrderNo(rs.getString("Order_No"));
                    item.setCustomCakeId(rs.getString("Custom_Cake_ID"));
                    item.setAccessoryId(rs.getString("Accessory_ID"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setPriceAtPurchase(rs.getBigDecimal("Price_At_Purchase"));
                    item.setItemName(rs.getString("Item_Name"));
                    item.setItemImage(rs.getString("Item_Image"));
                    item.setGreetingText(rs.getString("Greeting_Text"));
                    item.setCategoryName(rs.getString("Category_Name"));
                    item.setTemplateId(rs.getString("Template_ID"));
                    item.setTemplateImage(rs.getString("Template_Image"));

                    if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                        double ingredientCost = rs.getDouble("Ingredient_Cost");
                        double margin = rs.getDouble("Default_Margin_Percent");
                        double service = rs.getDouble("Default_Service_Percent");
                        double divisor = 1.0 - ((margin + service) / 100.0);
                        double basePrice = 0.0;
                        if (divisor > 0.0) {
                            basePrice = ingredientCost / divisor;
                        } else {
                            basePrice = ingredientCost;
                        }
                        basePrice = Math.ceil(basePrice / 1000.0) * 1000.0;

                        double purchasePrice = item.getPriceAtPurchase() != null
                                ? item.getPriceAtPurchase().doubleValue()
                                : 0.0;
                        double diff = purchasePrice - basePrice;
                        if (diff <= 40000) {
                            item.setVariationName("Size 16cm");
                        } else if (diff <= 120000) {
                            item.setVariationName("Size 20cm");
                        } else {
                            item.setVariationName("Size 24cm");
                        }
                    } else if (item.getAccessoryId() != null && !item.getAccessoryId().trim().isEmpty()) {
                        item.setVariationName("Phụ kiện");
                    } else {
                        item.setVariationName("Tiêu chuẩn");
                    }

                    items.add(item);
                }
            }
        }
        return items;
    }

    private Order mapRowToOrder(ResultSet rs) throws Exception {
        Order order = new Order();
        order.setOrderNo(rs.getString("Order_No"));
        order.setCustomerId(rs.getString("Customer_ID"));
        order.setTripId(rs.getString("Trip_ID"));
        order.setOrderTime(rs.getTimestamp("Order_Time"));
        order.setDeliveryWindowStart(rs.getTimestamp("Delivery_Window_Start"));
        order.setDeliveryWindowEnd(rs.getTimestamp("Delivery_Window_End"));
        order.setDeliveryAddress(rs.getString("Delivery_Address"));
        order.setDepositAmount(rs.getBigDecimal("Deposit_Amount"));
        BigDecimal total = rs.getBigDecimal("Total_Cost");
        order.setTotalCost(total);
        BigDecimal deposit = rs.getBigDecimal("Deposit_Amount");
        try {
            BigDecimal remaining = rs.getBigDecimal("Remaining_COD_Balance");
            if (remaining != null) {
                order.setRemainingCodBalance(remaining);
            } else if (total != null && deposit != null) {
                order.setRemainingCodBalance(total.subtract(deposit));
            } else {
                order.setRemainingCodBalance(BigDecimal.ZERO);
            }
        } catch (SQLException e) {
            if (total != null && deposit != null) {
                order.setRemainingCodBalance(total.subtract(deposit));
            } else {
                order.setRemainingCodBalance(BigDecimal.ZERO);
            }
        }
        order.setOrderStatus(rs.getString("OrderStatus"));
        try {
            order.setCustomerName(rs.getString("Customer_Name"));
        } catch (SQLException e) {
            // Ignore if Customer_Name column is not present
        }
        try {
            order.setShippingFee(rs.getBigDecimal("Shipping_Fee"));
        } catch (SQLException ignored) {
        }

        try {
            order.setPaymentMethod(rs.getString("Payment_Method"));
        } catch (SQLException ignored) {
        }
        try {
            order.setReceiverName(rs.getString("Receiver_Name"));
        } catch (SQLException ignored) {
        }
        try {
            order.setReceiverPhone(rs.getString("Receiver_Phone"));
        } catch (SQLException ignored) {
        }
        try {
            order.setCustomerNote(rs.getString("Customer_Note"));
        } catch (SQLException ignored) {
        }
        try {
            order.setShipperNote(rs.getString("Shipper_Note"));
        } catch (SQLException ignored) {
        }
        try {
            order.setDiscountAmount(rs.getBigDecimal("Discount_Amount"));
        } catch (SQLException ignored) {
        }
        try {
            order.setAppliedVoucherCode(rs.getString("Applied_Voucher_Code"));
        } catch (SQLException ignored) {
        }
        return order;
    }

    public static boolean canCustomerCancel(String status) {
        if (status == null) return false;
        String s = status.trim().toLowerCase();
        if (s.equals("ready") || s.contains("chờ vận chuyển") || s.contains("sẵn sàng")) return false;
        if (s.equals("delivering") || s.contains("đang giao")) return false;
        if (s.equals("completed") || s.contains("hoàn thành") || s.contains("đã giao")) return false;
        if (s.equals("cancelled") || s.equals("canceled") || s.contains("hủy")) return false;
        return true; // Allowed for Pending, Confirmed, PAID, Processing, Chờ xác nhận, Đang làm bánh
    }

    public static boolean isTerminalState(String status) {
        if (status == null) return false;
        String s = status.trim().toLowerCase();
        return s.equals("completed") || s.contains("hoàn thành") || s.equals("cancelled") || s.equals("canceled") || s.contains("hủy");
    }

    public boolean updateOrderStatus(String orderNo, String status) {
        String sql = "UPDATE `orders` SET OrderStatus = ? WHERE Order_No = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, orderNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateOrderStatusWithNote(String orderNo, String status, String shipperNote) {
        String sql = "UPDATE `orders` SET OrderStatus = ?, Shipper_Note = ? WHERE Order_No = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, shipperNote);
            ps.setString(3, orderNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean insertOrder(Order order) {
        String sqlOrder = "INSERT INTO `orders` (Order_No, Customer_ID, Trip_ID, Order_Time, Delivery_Window_Start, Delivery_Window_End, Delivery_Address, Deposit_Amount, Remaining_COD_Balance, Total_Cost, OrderStatus, Shipping_Fee, Discount_Amount, Payment_Method, Receiver_Name, Receiver_Phone, Customer_Note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlCake = "INSERT INTO `custom_cake` (Custom_Cake_ID, Canvas_Image_URL, Greeting_Text, Cake_Hash_Structure, Calculated_Price) VALUES (?, ?, ?, ?, ?)";
        String sqlItem = "INSERT INTO `order_item` (Order_Item_ID, Order_No, Custom_Cake_ID, Accessory_ID, Quantity, Price_At_Purchase) VALUES (?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psCake = null;
        PreparedStatement psItem = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null)
                return false;
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert Order
            psOrder = conn.prepareStatement(sqlOrder);
            psOrder.setString(1, order.getOrderNo());
            psOrder.setString(2, order.getCustomerId());
            psOrder.setString(3, order.getTripId());
            psOrder.setTimestamp(4, order.getOrderTime());
            psOrder.setTimestamp(5, order.getDeliveryWindowStart());
            psOrder.setTimestamp(6, order.getDeliveryWindowEnd());
            psOrder.setString(7, order.getDeliveryAddress());
            psOrder.setBigDecimal(8, order.getDepositAmount());
            psOrder.setBigDecimal(9, order.getRemainingCodBalance());
            psOrder.setBigDecimal(10, order.getTotalCost());
            psOrder.setString(11, order.getOrderStatus());
            psOrder.setBigDecimal(12, order.getShippingFee() != null ? order.getShippingFee() : BigDecimal.ZERO);
            psOrder.setBigDecimal(13, order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO);
            psOrder.setString(14, order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD");

            String receiverName = order.getReceiverName();
            String receiverPhone = order.getReceiverPhone();
            if ((receiverName == null || receiverName.trim().isEmpty()) && order.getDeliveryAddress() != null) {
                String[] parts = order.getDeliveryAddress().split("\\|");
                if (parts.length >= 3) {
                    receiverName = parts[0].trim();
                    receiverPhone = parts[1].trim();
                }
            }
            psOrder.setString(15, receiverName);
            psOrder.setString(16, receiverPhone);
            psOrder.setString(17, order.getCustomerNote());
            psOrder.executeUpdate();

            psCake = conn.prepareStatement(sqlCake);
            psItem = conn.prepareStatement(sqlItem);

            int itemCounter = 1;
            for (OrderItem item : order.getItems()) {
                String orderItemId = order.getOrderNo() + "_ITM_" + itemCounter++;
                psItem.setString(1, orderItemId);
                psItem.setString(2, order.getOrderNo());

                if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                    // Insert into custom_cake if not present
                    try {
                        psCake.setString(1, item.getCustomCakeId());
                        psCake.setString(2,
                                item.getItemImage() != null ? item.getItemImage() : "assets/images/default-cake.png");
                        psCake.setString(3,
                                item.getGreetingText() != null ? item.getGreetingText() : "Chúc mừng sinh nhật!");
                        String hash = (item.getTemplateId() != null && !item.getTemplateId().trim().isEmpty())
                                ? item.getTemplateId().trim()
                                : "STANDARD_CAKE_HASH";
                        psCake.setString(4, hash);
                        psCake.setBigDecimal(5, item.getPriceAtPurchase() != null ? item.getPriceAtPurchase() : BigDecimal.ZERO);
                        psCake.executeUpdate();
                    } catch (Exception cakeEx) {
                        // Ignore duplicate key if custom_cake ID already exists
                    }

                    psItem.setString(3, item.getCustomCakeId());
                    psItem.setNull(4, java.sql.Types.VARCHAR);
                } else {
                    // It's an accessory
                    psItem.setNull(3, java.sql.Types.VARCHAR);
                    psItem.setString(4, item.getAccessoryId());
                }

                psItem.setInt(5, item.getQuantity());
                psItem.setBigDecimal(6, item.getPriceAtPurchase());
                psItem.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            try {
                if (psOrder != null)
                    psOrder.close();
            } catch (Exception e) {
            }
            try {
                if (psCake != null)
                    psCake.close();
            } catch (Exception e) {
            }
            try {
                if (psItem != null)
                    psItem.close();
            } catch (Exception e) {
            }
            try {
                if (conn != null)
                    conn.close();
            } catch (Exception e) {
            }
        }
    }

    private void appendKeywordCondition(StringBuilder sql, List<Object> params, String keyword) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (o.Order_No LIKE ? OR c.Full_Name LIKE ? OR c.Phone LIKE ? OR o.Receiver_Name LIKE ? OR o.Receiver_Phone LIKE ?)");
            String kw = "%" + escapeWildcards(keyword.trim()) + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }
    }

    private void appendStatusCondition(StringBuilder sql, List<Object> params, String status) {
        if (status == null || status.trim().isEmpty() || status.equalsIgnoreCase("all")) {
            return;
        }
        String st = status.trim();
        switch (st) {
            case "Pending":
                sql.append(" AND o.OrderStatus IN ('Pending', 'Chờ xác nhận')");
                break;
            case "Confirmed":
                sql.append(" AND o.OrderStatus IN ('Confirmed', 'Đã xác nhận', 'Chờ làm')");
                break;
            case "PAID":
                sql.append(" AND o.OrderStatus IN ('PAID', 'Đã thanh toán', 'Đã chuyển khoản')");
                break;
            case "Processing":
                sql.append(" AND o.OrderStatus IN ('Processing', 'Confirmed', 'Chờ xử lý', 'Đang làm bánh', 'Đã xác nhận')");
                break;
            case "Delivering":
                sql.append(" AND o.OrderStatus IN ('Delivering', 'Đang giao hàng', 'Đang giao', 'Chờ giao')");
                break;
            case "Completed":
                sql.append(" AND o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')");
                break;
            case "Cancelled":
                sql.append(" AND o.OrderStatus IN ('Cancelled', 'Canceled', 'Đã hủy')");
                break;
            default:
                sql.append(" AND (o.OrderStatus = ? OR o.OrderStatus LIKE ?)");
                params.add(st);
                params.add("%" + st + "%");
                break;
        }
    }

    public int getTotalOrdersCount(String keyword, String status, String startDateStr, String endDateStr) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        appendKeywordCondition(sql, params, keyword);
        appendStatusCondition(sql, params, status);

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr + " 23:59:59");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public List<Order> getOrdersPaged(String keyword, String status, String startDateStr, String endDateStr,
            String sort, int pageIndex, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, c.Full_Name AS Customer_Name FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        appendKeywordCondition(sql, params, keyword);
        appendStatusCondition(sql, params, status);

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr + " 23:59:59");
        }

        String orderByClause = " ORDER BY o.Order_Time DESC ";
        if (sort != null && !sort.trim().isEmpty()) {
            switch (sort.trim().toLowerCase()) {
                case "date_asc":
                    orderByClause = " ORDER BY o.Order_Time ASC ";
                    break;
                case "price_desc":
                    orderByClause = " ORDER BY o.Total_Cost DESC ";
                    break;
                case "price_asc":
                    orderByClause = " ORDER BY o.Total_Cost ASC ";
                    break;
                default:
                    orderByClause = " ORDER BY o.Order_Time DESC ";
                    break;
            }
        }
        sql.append(orderByClause).append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((pageIndex - 1) * pageSize);

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    // NOTE: Don't load items in list view - only needed in detail view
                    orders.add(order);
                }
            }
            populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public int getTotalOrdersCountByShipper(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT o.Order_No) FROM `orders` o " +
                        "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                        "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                        "LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID " +
                        "WHERE (t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID " +
                        "OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' " +
                        "OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0)");
        List<Object> params = new ArrayList<>();
        params.add(shipperId);
        params.add(shipperId);
        params.add(shipperId);

        appendKeywordCondition(sql, params, keyword);
        appendStatusCondition(sql, params, status);

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr + " 23:59:59");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return count;
    }

    public List<Order> getOrdersByShipperPaged(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr,
            String sort, int pageIndex, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT o.*, c.Full_Name AS Customer_Name, s.Managed_Zone FROM `orders` o " +
                        "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                        "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                        "LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID " +
                        "WHERE (t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID " +
                        "OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' " +
                        "OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0)");
        List<Object> params = new ArrayList<>();
        params.add(shipperId);
        params.add(shipperId);
        params.add(shipperId);

        appendKeywordCondition(sql, params, keyword);
        appendStatusCondition(sql, params, status);

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr + " 23:59:59");
        }

        String orderByClause = " ORDER BY o.Order_Time DESC ";
        if (sort != null && !sort.trim().isEmpty()) {
            switch (sort.trim().toLowerCase()) {
                case "date_asc":
                    orderByClause = " ORDER BY o.Order_Time ASC ";
                    break;
                case "price_desc":
                    orderByClause = " ORDER BY o.Total_Cost DESC ";
                    break;
                case "price_asc":
                    orderByClause = " ORDER BY o.Total_Cost ASC ";
                    break;
                default:
                    orderByClause = " ORDER BY o.Order_Time DESC ";
                    break;
            }
        }
        sql.append(orderByClause).append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((pageIndex - 1) * pageSize);

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    orders.add(order);
                }
            }
            populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public double getTotalRevenue(String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT SUM(Total_Cost) FROM `orders` WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')");
        List<String> params = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND Order_Time >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND Order_Time <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public int getTotalCustomers(String startDate, String endDate) {
        if (startDate == null || startDate.trim().isEmpty() || endDate == null || endDate.trim().isEmpty()) {
            String sql = "SELECT COUNT(*) FROM `customer`";
            try (Connection conn = DBContext.getJDBCConnection();
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return 0;
        } else {
            String sql = "SELECT COUNT(DISTINCT Customer_ID) FROM `orders` WHERE Order_Time >= ? AND Order_Time <= ?";
            try (Connection conn = DBContext.getJDBCConnection();
                    PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, startDate.trim() + " 00:00:00");
                ps.setString(2, endDate.trim() + " 23:59:59");
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return 0;
        }
    }

    public int getTotalProducts() {
        String sql = "SELECT COUNT(*) FROM `cake_template`";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Map<String, Integer> getOrderStatusCounts(String startDate, String endDate) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("Chờ xác nhận", 0);
        counts.put("Đã xác nhận", 0);
        counts.put("Đang xử lý", 0);
        counts.put("Đang giao", 0);
        counts.put("Hoàn thành", 0);
        counts.put("Đã hủy", 0);

        StringBuilder sql = new StringBuilder("SELECT OrderStatus, COUNT(*) AS count FROM `orders` WHERE 1=1");
        List<String> params = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND Order_Time >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND Order_Time <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
        sql.append(" GROUP BY OrderStatus");

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("OrderStatus");
                    int count = rs.getInt("count");
                    if (status != null) {
                        if (status.equalsIgnoreCase("Pending") || status.equals("Chờ xác nhận")) {
                            counts.put("Chờ xác nhận", counts.getOrDefault("Chờ xác nhận", 0) + count);
                        } else if (status.equalsIgnoreCase("Confirmed") || status.equals("Đã xác nhận")) {
                            counts.put("Đã xác nhận", counts.getOrDefault("Đã xác nhận", 0) + count);
                        } else if (status.equalsIgnoreCase("Processing") || status.equals("Đang xử lý")) {
                            counts.put("Đang xử lý", counts.getOrDefault("Đang xử lý", 0) + count);
                        } else if (status.equalsIgnoreCase("Delivering") || status.equals("Đang giao hàng")
                                || status.equals("Đang giao")) {
                            counts.put("Đang giao", counts.getOrDefault("Đang giao", 0) + count);
                        } else if (status.equalsIgnoreCase("Completed") || status.equals("Hoàn thành")
                                || status.equals("Đã giao")) {
                            counts.put("Hoàn thành", counts.getOrDefault("Hoàn thành", 0) + count);
                        } else if (status.equalsIgnoreCase("Cancelled") || status.equalsIgnoreCase("Canceled")
                                || status.equals("Đã hủy")) {
                            counts.put("Đã hủy", counts.getOrDefault("Đã hủy", 0) + count);
                        } else {
                            counts.put(status, count);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    public Map<String, Double> getMonthlyRevenueTrend(int monthsLimit) {
        Map<String, Double> trend = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(Order_Time, '%m/%Y') AS month_year, SUM(Total_Cost) AS monthly_revenue " +
                "FROM `orders` " +
                "WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "GROUP BY DATE_FORMAT(Order_Time, '%m/%Y') " +
                "ORDER BY MIN(Order_Time) ASC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, monthsLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("month_year"), rs.getDouble("monthly_revenue"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Double> getRevenueTrend(String period, int limit) {
        Map<String, Double> trend = new LinkedHashMap<>();
        String dateFormat = "month".equalsIgnoreCase(period) ? "%m/%Y" : "%d/%m";
        String sql = "SELECT time_label, revenue FROM (" +
                "  SELECT DATE_FORMAT(Order_Time, '" + dateFormat
                + "') AS time_label, SUM(Total_Cost) AS revenue, MIN(Order_Time) as min_ot " +
                "  FROM `orders` " +
                "  WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "  GROUP BY DATE_FORMAT(Order_Time, '" + dateFormat + "') " +
                "  ORDER BY min_ot DESC LIMIT ?" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getDouble("revenue"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Integer> getOrdersTrend(String period, int limit) {
        Map<String, Integer> trend = new LinkedHashMap<>();
        String dateFormat = "month".equalsIgnoreCase(period) ? "%m/%Y" : "%d/%m";
        String sql = "SELECT time_label, order_count FROM (" +
                "  SELECT DATE_FORMAT(Order_Time, '" + dateFormat
                + "') AS time_label, COUNT(*) AS order_count, MIN(Order_Time) as min_ot " +
                "  FROM `orders` " +
                "  GROUP BY DATE_FORMAT(Order_Time, '" + dateFormat + "') " +
                "  ORDER BY min_ot DESC LIMIT ?" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getInt("order_count"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Double> getProfitTrend(String period, int limit) {
        Map<String, Double> trend = new LinkedHashMap<>();
        String dateFormat = "month".equalsIgnoreCase(period) ? "%m/%Y" : "%d/%m";
        String sql = "SELECT time_label, profit FROM (" +
                "  SELECT DATE_FORMAT(o.Order_Time, '" + dateFormat + "') AS time_label, " +
                "         SUM(o.Total_Cost) - SUM(COALESCE(" +
                "             (SELECT SUM(oi.Quantity * (" +
                "                 SELECT COALESCE(SUM(d.Quantity * ing.Price_Per_Unit), 0)" +
                "                 FROM template_ingredient_detail d" +
                "                 JOIN ingredients ing ON d.Ingredient_ID = ing.Ingredient_ID" +
                "                 WHERE d.Template_ID = (CASE" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0001' THEN 'TPL_0001'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0002' THEN 'TPL_0005'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0003' THEN 'TPL_0009'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0004' THEN 'TPL_0011'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0005' THEN 'TPL_0013'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0006' THEN 'TPL_0017'" +
                "                     ELSE cc.Cake_Hash_Structure END)" +
                "             ))" +
                "              FROM order_item oi" +
                "              LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID" +
                "              WHERE oi.Order_No = o.Order_No)," +
                "             0" +
                "         )) AS profit, " +
                "         MIN(o.Order_Time) as min_ot " +
                "  FROM `orders` o " +
                "  WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "  GROUP BY DATE_FORMAT(o.Order_Time, '" + dateFormat + "') " +
                "  ORDER BY min_ot DESC LIMIT ?" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getDouble("profit"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Double> getRevenueTrendCustom(String startDate, String endDate) {
        Map<String, Double> trend = new LinkedHashMap<>();
        String sql = "SELECT time_label, revenue FROM (" +
                "  SELECT DATE_FORMAT(Order_Time, '%d/%m') AS time_label, SUM(Total_Cost) AS revenue, MIN(Order_Time) as min_ot "
                +
                "  FROM `orders` " +
                "  WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "    AND Order_Time >= ? AND Order_Time <= ? " +
                "  GROUP BY DATE_FORMAT(Order_Time, '%d/%m') " +
                "  ORDER BY min_ot DESC LIMIT 31" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getDouble("revenue"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Integer> getOrdersTrendCustom(String startDate, String endDate) {
        Map<String, Integer> trend = new LinkedHashMap<>();
        String sql = "SELECT time_label, order_count FROM (" +
                "  SELECT DATE_FORMAT(Order_Time, '%d/%m') AS time_label, COUNT(*) AS order_count, MIN(Order_Time) as min_ot "
                +
                "  FROM `orders` " +
                "  WHERE Order_Time >= ? AND Order_Time <= ? " +
                "  GROUP BY DATE_FORMAT(Order_Time, '%d/%m') " +
                "  ORDER BY min_ot DESC LIMIT 31" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getInt("order_count"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public Map<String, Double> getProfitTrendCustom(String startDate, String endDate) {
        Map<String, Double> trend = new LinkedHashMap<>();
        String sql = "SELECT time_label, profit FROM (" +
                "  SELECT DATE_FORMAT(o.Order_Time, '%d/%m') AS time_label, " +
                "         SUM(o.Total_Cost) - SUM(COALESCE(" +
                "             (SELECT SUM(oi.Quantity * (" +
                "                 SELECT COALESCE(SUM(d.Quantity * ing.Price_Per_Unit), 0)" +
                "                 FROM template_ingredient_detail d" +
                "                 JOIN ingredients ing ON d.Ingredient_ID = ing.Ingredient_ID" +
                "                 WHERE d.Template_ID = (CASE" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0001' THEN 'TPL_0001'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0002' THEN 'TPL_0005'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0003' THEN 'TPL_0009'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0004' THEN 'TPL_0011'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0005' THEN 'TPL_0013'" +
                "                     WHEN cc.Cake_Hash_Structure = 'HASH_CC_0006' THEN 'TPL_0017'" +
                "                     ELSE cc.Cake_Hash_Structure END)" +
                "             ))" +
                "              FROM order_item oi" +
                "              LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID" +
                "              WHERE oi.Order_No = o.Order_No)," +
                "             0" +
                "         )) AS profit, " +
                "         MIN(o.Order_Time) as min_ot " +
                "  FROM `orders` o " +
                "  WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "    AND o.Order_Time >= ? AND o.Order_Time <= ? " +
                "  GROUP BY DATE_FORMAT(o.Order_Time, '%d/%m') " +
                "  ORDER BY min_ot DESC LIMIT 31" +
                ") AS temp ORDER BY min_ot ASC";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    trend.put(rs.getString("time_label"), rs.getDouble("profit"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return trend;
    }

    public List<Map<String, Object>> getBestSellingProducts(String startDate, String endDate, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name, "
                +
                "       SUM(oi.Quantity) AS quantity_sold, SUM(oi.Quantity * oi.Price_At_Purchase) AS total_revenue " +
                "FROM order_item oi " +
                "JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID " +
                "JOIN cake_template t ON (cc.Cake_Hash_Structure = t.Template_ID OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR " +
                "  (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')) " +
                "LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID " +
                "JOIN orders o ON oi.Order_No = o.Order_No " +
                "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')");
        List<Object> params = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
        sql.append(" GROUP BY t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name " +
                "ORDER BY quantity_sold DESC LIMIT ?");
        params.add(limit);

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("templateId", rs.getString("Template_ID"));
                    map.put("name", rs.getString("Template_Name"));
                    map.put("imageUrl", rs.getString("Image_URL"));
                    map.put("category", rs.getString("Category_Name"));
                    map.put("quantitySold", rs.getInt("quantity_sold"));
                    map.put("totalRevenue", rs.getDouble("total_revenue"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getTopCustomers(String startDate, String endDate, int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.Customer_ID, c.Full_Name, COUNT(o.Order_No) AS order_count, SUM(o.Total_Cost) AS total_spent "
                        +
                        "FROM customer c " +
                        "JOIN orders o ON c.Customer_ID = o.Customer_ID " +
                        "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')");
        List<Object> params = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
        sql.append(" GROUP BY c.Customer_ID, c.Full_Name " +
                "ORDER BY total_spent DESC LIMIT ?");
        params.add(limit);

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("customerId", rs.getString("Customer_ID"));
                    map.put("fullName", rs.getString("Full_Name"));
                    map.put("orderCount", rs.getInt("order_count"));
                    map.put("totalSpent", rs.getDouble("total_spent"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public String[] getEvidencePhotosByTripId(String tripId) {
        String sql = "SELECT Pickup_Photo_URL, Delivery_Photo_URL FROM `delivery_evidence` WHERE Trip_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new String[] { rs.getString("Pickup_Photo_URL"), rs.getString("Delivery_Photo_URL") };
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new String[] { "", "" };
    }

    public boolean saveDeliveryEvidence(String tripId, String photoUrl, String type) {
        String checkSql = "SELECT Evidence_ID FROM `delivery_evidence` WHERE Trip_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection()) {
            if (conn == null)
                return false;
            conn.setAutoCommit(false);

            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, tripId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        exists = true;
                    }
                }
            }

            boolean success = false;
            if (exists) {
                String updateSql;
                if ("pickup".equalsIgnoreCase(type)) {
                    updateSql = "UPDATE `delivery_evidence` SET Pickup_Photo_URL = ? WHERE Trip_ID = ?";
                } else {
                    updateSql = "UPDATE `delivery_evidence` SET Delivery_Photo_URL = ? WHERE Trip_ID = ?";
                }
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setString(1, photoUrl);
                    ps.setString(2, tripId);
                    success = ps.executeUpdate() > 0;
                }
            } else {
                String evidenceId = generateEvidenceId(conn);
                String insertSql;
                if ("pickup".equalsIgnoreCase(type)) {
                    insertSql = "INSERT INTO `delivery_evidence` (Evidence_ID, Trip_ID, Pickup_Photo_URL, Delivery_Photo_URL) VALUES (?, ?, ?, '')";
                } else {
                    insertSql = "INSERT INTO `delivery_evidence` (Evidence_ID, Trip_ID, Pickup_Photo_URL, Delivery_Photo_URL) VALUES (?, ?, '', ?)";
                }
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setString(1, evidenceId);
                    ps.setString(2, tripId);
                    ps.setString(3, photoUrl);
                    success = ps.executeUpdate() > 0;
                }
            }

            if (success) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private String generateEvidenceId(Connection conn) {
        String sql = "SELECT MAX(CAST(SUBSTRING(Evidence_ID, 5) AS UNSIGNED)) FROM `delivery_evidence` WHERE Evidence_ID LIKE 'EVI_%'";
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int maxId = rs.getInt(1);
                if (maxId > 0) {
                    return String.format("EVI_%04d", maxId + 1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "EVI_" + System.currentTimeMillis();
    }

    public boolean autoAssignShipperAndTrip(String orderNo) {
        String selectOrderSql = "SELECT Delivery_Address, Delivery_Window_Start, Delivery_Window_End FROM `orders` WHERE Order_No = ?";

        try (Connection conn = DBContext.getJDBCConnection()) {
            if (conn == null)
                return false;
            conn.setAutoCommit(false);

            String deliveryAddress = null;
            java.sql.Timestamp windowStart = null;
            java.sql.Timestamp windowEnd = null;

            // 1. Lấy thông tin đơn hàng
            try (PreparedStatement ps = conn.prepareStatement(selectOrderSql)) {
                ps.setString(1, orderNo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        deliveryAddress = rs.getString("Delivery_Address");
                        windowStart = rs.getTimestamp("Delivery_Window_Start");
                        windowEnd = rs.getTimestamp("Delivery_Window_End");
                    }
                }
            }

            if (deliveryAddress == null) {
                conn.rollback();
                return false;
            }

            // 2. Lấy toàn bộ shipper đang hoạt động và danh sách Managed_Zone của họ
            List<Map<String, Object>> shippers = new java.util.ArrayList<>();
            String shipperQuery = "SELECT s.Staff_ID, s.Full_Name, s.Managed_Zone FROM `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "WHERE u.Role_ID = 'SHIPPER' AND s.Is_Active_Staff = 1";
            try (PreparedStatement ps = conn.prepareStatement(shipperQuery);
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> sh = new java.util.HashMap<>();
                    sh.put("id", rs.getString("Staff_ID"));
                    sh.put("name", rs.getString("Full_Name"));
                    sh.put("zone", rs.getString("Managed_Zone"));
                    shippers.add(sh);
                }
            }

            // 3. Lọc ra các Shipper ứng viên có Managed_Zone khớp với địa chỉ đơn hàng (hỗ
            // trợ phân tách dấu phẩy)
            List<String> candidates = new java.util.ArrayList<>();
            for (Map<String, Object> sh : shippers) {
                String zoneStr = (String) sh.get("zone");
                if (zoneStr != null && !zoneStr.trim().isEmpty()) {
                    // Cắt các khu vực quản lý bằng dấu phẩy
                    String[] zones = zoneStr.split(",");
                    for (String z : zones) {
                        z = z.trim();
                        if (!z.isEmpty() && deliveryAddress.toLowerCase().contains(z.toLowerCase())) {
                            candidates.add((String) sh.get("id"));
                            break; // Đã khớp 1 khu vực, dừng kiểm tra shipper này
                        }
                    }
                }
            }

            String optimalShipperId = null;
            String pooledTripId = null;

            if (!candidates.isEmpty()) {
                // 4. KIỂM TRA ROUTE POOLING (Gom đơn): Tìm chuyến đi đang hoạt động cùng khung
                // giờ của các shipper ứng viên này
                StringBuilder poolingQuery = new StringBuilder(
                        "SELECT o.Trip_ID, dt.Shipper_ID FROM `orders` o " +
                                "JOIN `delivery_trip` dt ON o.Trip_ID = dt.Trip_ID " +
                                "WHERE o.Delivery_Window_Start = ? AND o.Delivery_Window_End = ? " +
                                "AND dt.Shipper_ID IN (");
                for (int i = 0; i < candidates.size(); i++) {
                    poolingQuery.append(i == 0 ? "?" : ", ?");
                }
                poolingQuery.append(") LIMIT 1");

                try (PreparedStatement ps = conn.prepareStatement(poolingQuery.toString())) {
                    ps.setTimestamp(1, windowStart);
                    ps.setTimestamp(2, windowEnd);
                    for (int i = 0; i < candidates.size(); i++) {
                        ps.setString(3 + i, candidates.get(i));
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            pooledTripId = rs.getString("Trip_ID");
                        }
                    }
                }

                if (pooledTripId != null) {
                    // Gom đơn vào chuyến đi có sẵn
                    String updateOrderSql = "UPDATE `orders` SET Trip_ID = ? WHERE Order_No = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                        ps.setString(1, pooledTripId);
                        ps.setString(2, orderNo);
                        ps.executeUpdate();
                    }
                    conn.commit();
                    return true;
                }

                // 5. PHÂN TẢI CÂN BẰNG (Load Balancing): Tìm shipper ứng viên có lượng đơn đang
                // giao ít nhất
                StringBuilder loadQuery = new StringBuilder(
                        "SELECT s.Staff_ID, COUNT(o.Order_No) AS active_orders FROM `staff` s " +
                                "LEFT JOIN `delivery_trip` dt ON s.Staff_ID = dt.Shipper_ID " +
                                "LEFT JOIN `orders` o ON dt.Trip_ID = o.Trip_ID AND o.OrderStatus IN ('Processing', 'Delivering') "
                                +
                                "WHERE s.Staff_ID IN (");
                for (int i = 0; i < candidates.size(); i++) {
                    loadQuery.append(i == 0 ? "?" : ", ?");
                }
                loadQuery.append(") GROUP BY s.Staff_ID ORDER BY active_orders ASC LIMIT 1");

                try (PreparedStatement ps = conn.prepareStatement(loadQuery.toString())) {
                    for (int i = 0; i < candidates.size(); i++) {
                        ps.setString(1 + i, candidates.get(i));
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            optimalShipperId = rs.getString("Staff_ID");
                        }
                    }
                }
            }

            // 6. CƠ CHẾ DỰ PHÒNG (Fallback): Chọn shipper rảnh nhất toàn hệ thống nếu địa
            // chỉ không khớp bất kì ai
            if (optimalShipperId == null) {
                String fallbackQuery = "SELECT s.Staff_ID, COUNT(o.Order_No) AS active_orders FROM `staff` s " +
                        "JOIN `user` u ON s.User_ID = u.User_ID " +
                        "LEFT JOIN `delivery_trip` dt ON s.Staff_ID = dt.Shipper_ID " +
                        "LEFT JOIN `orders` o ON dt.Trip_ID = o.Trip_ID AND o.OrderStatus IN ('Processing', 'Delivering') "
                        +
                        "WHERE u.Role_ID = 'SHIPPER' AND s.Is_Active_Staff = 1 " +
                        "GROUP BY s.Staff_ID ORDER BY active_orders ASC LIMIT 1";
                try (PreparedStatement ps = conn.prepareStatement(fallbackQuery);
                        ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        optimalShipperId = rs.getString("Staff_ID");
                    }
                }
            }

            if (optimalShipperId == null) {
                conn.rollback();
                return false;
            }

            // 7. Tạo chuyến đi mới
            String newTripId = generateTripId(conn);
            String insertTripSql = "INSERT INTO `delivery_trip` (Trip_ID, Shipper_ID, OSRM_Distance_Km, OSRM_Duration_Min, Calculated_Shipping_Fee) VALUES (?, ?, 0.0, 0, 0.0)";
            try (PreparedStatement ps = conn.prepareStatement(insertTripSql)) {
                ps.setString(1, newTripId);
                ps.setString(2, optimalShipperId);
                ps.executeUpdate();
            }

            // 8. Cập nhật mã chuyến đi cho đơn hàng
            String updateOrderSql = "UPDATE `orders` SET Trip_ID = ? WHERE Order_No = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setString(1, newTripId);
                ps.setString(2, orderNo);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private String generateTripId(Connection conn) {
        String sql = "SELECT MAX(CAST(SUBSTRING(Trip_ID, 6) AS UNSIGNED)) FROM `delivery_trip` WHERE Trip_ID LIKE 'TRIP_%'";
        try (PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int maxId = rs.getInt(1);
                if (maxId > 0) {
                    return String.format("TRIP_%04d", maxId + 1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "TRIP_" + System.currentTimeMillis();
    }

    public java.util.Map<String, Object> getShipperDailyStats(String shipperId) {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        double todayRevenue = 0.0;
        double yesterdayRevenue = 0.0;
        int todayDeliveriesCount = 0;
        int yesterdayDeliveriesCount = 0;

        String todaySql = "SELECT COALESCE(SUM(o.Total_Cost), 0) AS total_rev, COUNT(o.Order_No) AS total_count " +
                "FROM `orders` o " +
                "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                "WHERE (t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0) " +
                "AND o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "AND DATE(o.Order_Time) = CURDATE()";

        String yesterdaySql = "SELECT COALESCE(SUM(o.Total_Cost), 0) AS total_rev, COUNT(o.Order_No) AS total_count " +
                "FROM `orders` o " +
                "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                "WHERE (t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0) " +
                "AND o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "AND DATE(o.Order_Time) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)";

        try (Connection conn = DBContext.getJDBCConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(todaySql)) {
                ps.setString(1, shipperId);
                ps.setString(2, shipperId);
                ps.setString(3, shipperId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        todayRevenue = rs.getDouble("total_rev");
                        todayDeliveriesCount = rs.getInt("total_count");
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(yesterdaySql)) {
                ps.setString(1, shipperId);
                ps.setString(2, shipperId);
                ps.setString(3, shipperId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        yesterdayRevenue = rs.getDouble("total_rev");
                        yesterdayDeliveriesCount = rs.getInt("total_count");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        double revDiffPercent = 0.0;
        if (yesterdayRevenue > 0) {
            revDiffPercent = ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100.0;
        } else if (todayRevenue > 0) {
            revDiffPercent = 100.0;
        }

        int deliveriesDiffCount = todayDeliveriesCount - yesterdayDeliveriesCount;

        stats.put("todayRevenue", todayRevenue);
        stats.put("yesterdayRevenue", yesterdayRevenue);
        stats.put("todayDeliveriesCount", todayDeliveriesCount);
        stats.put("yesterdayDeliveriesCount", yesterdayDeliveriesCount);
        stats.put("revDiffPercent", revDiffPercent);
        stats.put("deliveriesDiffCount", deliveriesDiffCount);

        return stats;
    }

    public List<Order> getReadyOrdersForShipper(String shipperId, int limit) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT o.*, c.Full_Name AS Customer_Name FROM `orders` o " +
                "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                "LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID " +
                "WHERE o.OrderStatus IN ('Processing', 'Confirmed', 'PAID', 'Chờ xử lý', 'Đang làm bánh', 'Đã xác nhận', 'Chờ giao') " +
                "AND (t.Shipper_ID IS NULL OR t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID " +
                "OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' " +
                "OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0) " +
                "ORDER BY o.Order_Time DESC ");
        if (limit > 0) {
            sql.append("LIMIT ?");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, shipperId);
            ps.setString(2, shipperId);
            ps.setString(3, shipperId);
            if (limit > 0) {
                ps.setInt(4, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<Order> getDeliveredOrdersForShipper(String shipperId, int limit) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT o.*, c.Full_Name AS Customer_Name FROM `orders` o " +
                "LEFT JOIN `delivery_trip` t ON o.Trip_ID = t.Trip_ID " +
                "LEFT JOIN `staff` s ON (s.Staff_ID = ? OR s.User_ID = ?) " +
                "LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID " +
                "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                "AND (t.Shipper_ID = ? OR t.Shipper_ID = s.Staff_ID " +
                "OR s.Managed_Zone IS NULL OR s.Managed_Zone = '' OR s.Managed_Zone LIKE '%Toàn thành phố%' " +
                "OR LOCATE(LOWER(s.Managed_Zone), LOWER(o.Delivery_Address)) > 0) " +
                "ORDER BY o.Order_Time DESC ");
        if (limit > 0) {
            sql.append("LIMIT ?");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setString(1, shipperId);
            ps.setString(2, shipperId);
            ps.setString(3, shipperId);
            if (limit > 0) {
                ps.setInt(4, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public boolean acceptOrderForShipper(String shipperId, String orderNo) {
        if (shipperId == null || orderNo == null) return false;
        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            
            // Tìm Staff_ID từ User_ID nếu truyền User_ID
            String staffId = shipperId;
            String getStaffSql = "SELECT Staff_ID FROM `staff` WHERE User_ID = ? OR Staff_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(getStaffSql)) {
                ps.setString(1, shipperId);
                ps.setString(2, shipperId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        staffId = rs.getString("Staff_ID");
                    }
                }
            }

            // Kiểm tra xem đơn hàng đã có Trip_ID chưa
            String checkOrderSql = "SELECT Trip_ID FROM `orders` WHERE Order_No = ?";
            String currentTripId = null;
            try (PreparedStatement ps = conn.prepareStatement(checkOrderSql)) {
                ps.setString(1, orderNo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentTripId = rs.getString("Trip_ID");
                    }
                }
            }

            if (currentTripId == null || currentTripId.trim().isEmpty()) {
                currentTripId = generateTripId(conn);
                String insertTripSql = "INSERT INTO `delivery_trip` (Trip_ID, Shipper_ID, OSRM_Distance_Km, OSRM_Duration_Min, Calculated_Shipping_Fee) VALUES (?, ?, 0.0, 0, 0.0)";
                try (PreparedStatement ps = conn.prepareStatement(insertTripSql)) {
                    ps.setString(1, currentTripId);
                    ps.setString(2, staffId);
                    ps.executeUpdate();
                }

                String updateOrderTripSql = "UPDATE `orders` SET Trip_ID = ?, OrderStatus = 'Delivering' WHERE Order_No = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOrderTripSql)) {
                    ps.setString(1, currentTripId);
                    ps.setString(2, orderNo);
                    ps.executeUpdate();
                }
            } else {
                String updateTripSql = "UPDATE `delivery_trip` SET Shipper_ID = ? WHERE Trip_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateTripSql)) {
                    ps.setString(1, staffId);
                    ps.setString(2, currentTripId);
                    ps.executeUpdate();
                }

                String updateOrderSql = "UPDATE `orders` SET OrderStatus = 'Delivering' WHERE Order_No = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                    ps.setString(1, orderNo);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
