package com.bakeryzone.utils;

import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.math.BigDecimal;

public class OrderMapper {

    public static String escapeWildcards(String keyword) {
        if (keyword == null) {
            return null;
        }
        return keyword.replace("\\", "\\\\")
                      .replace("%", "\\%")
                      .replace("_", "\\_");
    }

    public static void populateOrderItems(List<Order> orders, Connection conn) throws Exception {
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
                    oi.Product_ID,
                    oi.Snapshot_Name,
                    oi.Snapshot_Image,
                    oi.Quantity,
                    oi.Price_At_Purchase,
                    COALESCE(oi.Snapshot_Name, cc.Cake_Hash_Structure, t.Template_Name, 'Bánh ngọt') AS Item_Name,
                    COALESCE(oi.Snapshot_Image, cc.Canvas_Image_URL, t.Image_URL) AS Item_Image,
                    cc.Greeting_Text,
                    COALESCE(NULLIF(TRIM(cat.Category_Name), ''), 'Bánh ngọt') AS Category_Name,
                    t.Template_ID,
                    NULLIF(TRIM(t.Image_URL), '') AS Template_Image,
                    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0)
                     FROM template_ingredient_detail d
                     JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID
                     WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                    t.Default_Margin_Percent,
                    t.Default_Service_Percent,
                    cc.Cake_Hash_Structure
                FROM order_item oi
                LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
                LEFT JOIN cake_template t ON t.Template_ID = COALESCE(oi.Product_ID, cc.Cake_Hash_Structure)
                LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID
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
                    item.setProductId(rs.getString("Product_ID"));
                    item.setSnapshotName(rs.getString("Snapshot_Name"));
                    item.setSnapshotImage(rs.getString("Snapshot_Image"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setPriceAtPurchase(rs.getBigDecimal("Price_At_Purchase"));
                    item.setItemName(rs.getString("Item_Name"));
                    item.setItemImage(rs.getString("Item_Image"));
                    item.setGreetingText(rs.getString("Greeting_Text"));
                    item.setCategoryName(rs.getString("Category_Name"));
                    item.setTemplateId(rs.getString("Template_ID"));
                    item.setTemplateImage(rs.getString("Template_Image"));

                    if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                        String cakeHash = rs.getString("Cake_Hash_Structure");
                        if (item.getTemplateId() == null && cakeHash != null && (cakeHash.startsWith("SIZE_") || cakeHash.equals("STANDARD_CAKE_HASH"))) {
                            item.setItemName("Bánh thiết kế");
                            item.setCategoryName("Bánh thiết kế");
                            String sizeStr = "Tùy chỉnh";
                            if (cakeHash.startsWith("SIZE_")) {
                                String[] parts = cakeHash.split("_");
                                if (parts.length >= 2 && "SIZE".equals(parts[0])) {
                                    sizeStr = "Size " + parts[1] + "cm";
                                }
                            }
                            item.setVariationName(sizeStr);
                        } else {
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
                        }
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

    public static List<OrderItem> getOrderItems(String orderNo, Connection conn) throws Exception {
        List<OrderItem> items = new ArrayList<>();
        String sql = """
                SELECT
                    oi.Order_Item_ID,
                    oi.Order_No,
                    oi.Custom_Cake_ID,
                    oi.Product_ID,
                    oi.Snapshot_Name,
                    oi.Snapshot_Image,
                    oi.Quantity,
                    oi.Price_At_Purchase,
                    COALESCE(oi.Snapshot_Name, cc.Cake_Hash_Structure, t.Template_Name, 'Bánh ngọt') AS Item_Name,
                    COALESCE(oi.Snapshot_Image, cc.Canvas_Image_URL, t.Image_URL) AS Item_Image,
                    cc.Greeting_Text,
                    COALESCE(NULLIF(TRIM(cat.Category_Name), ''), 'Bánh ngọt') AS Category_Name,
                    t.Template_ID,
                    NULLIF(TRIM(t.Image_URL), '') AS Template_Image,
                    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0)
                     FROM template_ingredient_detail d
                     JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID
                     WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                    t.Default_Margin_Percent,
                    t.Default_Service_Percent,
                    cc.Cake_Hash_Structure
                FROM order_item oi
                LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
                LEFT JOIN cake_template t ON t.Template_ID = COALESCE(oi.Product_ID, cc.Cake_Hash_Structure)
                LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID
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
                    item.setProductId(rs.getString("Product_ID"));
                    item.setSnapshotName(rs.getString("Snapshot_Name"));
                    item.setSnapshotImage(rs.getString("Snapshot_Image"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setPriceAtPurchase(rs.getBigDecimal("Price_At_Purchase"));
                    item.setItemName(rs.getString("Item_Name"));
                    item.setItemImage(rs.getString("Item_Image"));
                    item.setGreetingText(rs.getString("Greeting_Text"));
                    item.setCategoryName(rs.getString("Category_Name"));
                    item.setTemplateId(rs.getString("Template_ID"));
                    item.setTemplateImage(rs.getString("Template_Image"));

                    if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                        String cakeHash = rs.getString("Cake_Hash_Structure");
                        if (item.getTemplateId() == null && cakeHash != null && (cakeHash.startsWith("SIZE_") || cakeHash.equals("STANDARD_CAKE_HASH"))) {
                            item.setItemName("Bánh thiết kế");
                            item.setCategoryName("Bánh thiết kế");
                            String sizeStr = "Tùy chỉnh";
                            if (cakeHash.startsWith("SIZE_")) {
                                String[] parts = cakeHash.split("_");
                                if (parts.length >= 2 && "SIZE".equals(parts[0])) {
                                    sizeStr = "Size " + parts[1] + "cm";
                                }
                            }
                            item.setVariationName(sizeStr);
                        } else {
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
                        }
                    } else {
                        item.setVariationName("Tiêu chuẩn");
                    }

                    items.add(item);
                }
            }
        }
        return items;
    }

    public static Order mapRowToOrder(ResultSet rs) throws Exception {
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

    public static void appendKeywordCondition(StringBuilder sql, List<Object> params, String keyword) {
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

    public static void appendStatusCondition(StringBuilder sql, List<Object> params, String status) {
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

    public static void appendCakeTypeCondition(StringBuilder sql, String cakeType) {
        if (cakeType == null || cakeType.trim().isEmpty() || "all".equalsIgnoreCase(cakeType)) {
            return;
        }
        if ("template".equalsIgnoreCase(cakeType.trim())) {
            sql.append(" AND EXISTS (")
               .append("  SELECT 1 FROM order_item oi ")
               .append("  WHERE oi.Order_No = o.Order_No ")
               .append("  AND oi.Product_ID IS NOT NULL ")
               .append("  AND oi.Custom_Cake_ID IS NULL ")
               .append(" )");
        } else if ("custom".equalsIgnoreCase(cakeType.trim())) {
            sql.append(" AND EXISTS (")
               .append("  SELECT 1 FROM order_item oi ")
               .append("  WHERE oi.Order_No = o.Order_No ")
               .append("  AND oi.Custom_Cake_ID IS NOT NULL ")
               .append(" )");
        }
    }
}
