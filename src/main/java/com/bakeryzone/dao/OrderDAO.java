
package com.bakeryzone.dao;

import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.utils.DBContext;
import com.bakeryzone.utils.OrderMapper;

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
    //chức năng
    // Lấy Customer ID dựa trên User ID của tài khoản đang đăng nhập
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

    // Lấy danh sách toàn bộ đơn hàng của một khách hàng cụ thể
    public List<Order> getOrdersByCustomerId(String customerId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM `orders` WHERE Customer_ID = ? ORDER BY Order_Time DESC";

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(OrderMapper.mapRowToOrder(rs));
                }
            }
            OrderMapper.populateOrderItems(orders, conn);
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
    // Đếm số lượng đơn hàng của khách hàng theo các bộ lọc (từ khóa, trạng thái, thời gian)
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
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR t.Template_Name LIKE ?)");
            String kw = "%" + OrderMapper.escapeWildcards(keyword.trim()) + "%";
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
    // Lấy danh sách đơn hàng của khách hàng có phân trang và bộ lọc
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
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR t.Template_Name LIKE ?)");
            String kw = "%" + OrderMapper.escapeWildcards(keyword.trim()) + "%";
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
                    orders.add(OrderMapper.mapRowToOrder(rs));
                }
            }
            OrderMapper.populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    /**
     * Đếm số đơn hàng theo từng trạng thái UI cho customer tab counts.
     * Trả về Map: "all", "processing", "shipping", "completed", "cancelled".
     */
    // Thống kê số lượng đơn hàng theo từng trạng thái của một khách hàng
    public java.util.Map<String, Integer> getOrderStatusCountsByCustomer(String customerId,
            String keyword, String startDateStr, String endDateStr) {
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("all", 0);
        counts.put("confirmed", 0);
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
                        + " WHERE o.Customer_ID = ?");
        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(
                    " AND (o.Order_No LIKE ? OR t.Template_Name LIKE ?)");
            String kw = "%" + OrderMapper.escapeWildcards(keyword.trim()) + "%";
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
                        if (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed")) {
                            counts.put("confirmed", counts.get("confirmed") + cnt);
                        } else if (dbStatus.equalsIgnoreCase("Processing") || dbStatus.equalsIgnoreCase("PAID")) {
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
            case "confirmed":
                sql.append(" AND o.OrderStatus IN ('Pending', 'Confirmed')");
                break;
            case "processing":
                sql.append(" AND o.OrderStatus IN ('Processing', 'PAID')");
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

    //chức năng
    // Truy xuất toàn bộ thông tin của một đơn hàng cụ thể dựa vào mã đơn hàng (Order_No)
    public Order getOrderByNo(String orderNo) {
        String sql = "SELECT * FROM `orders` WHERE Order_No = ?";

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order order = OrderMapper.mapRowToOrder(rs);
                    order.getItems().addAll(OrderMapper.getOrderItems(order.getOrderNo(), conn));
                    if (order.getTripId() != null && !order.getTripId().trim().isEmpty()) {
                        order.setShipperName(new ShipperTripDAO().getShipperNameByTripId(order.getTripId()));
                    }
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    // Kiểm tra xem khách hàng có quyền hủy đơn hàng với trạng thái hiện tại hay không
    public static boolean canCustomerCancel(String status) {
        if (status == null) return false;
        String s = status.trim().toLowerCase();
        if (s.equals("ready") || s.contains("chờ vận chuyển") || s.contains("sẵn sàng")) return false;
        if (s.equals("delivering") || s.contains("đang giao")) return false;
        if (s.equals("completed") || s.contains("hoàn thành") || s.contains("đã giao")) return false;
        if (s.equals("cancelled") || s.equals("canceled") || s.contains("hủy")) return false;
        return true; // Allowed for Pending, Confirmed, PAID, Processing, Chờ xác nhận, Đang làm bánh
    }

    // Kiểm tra xem trạng thái đơn hàng đã là trạng thái cuối cùng (không thể thay đổi) chưa
    public static boolean isTerminalState(String status) {
        String s = status.trim().toLowerCase();
        return s.equals("completed") || s.contains("hoàn thành") || s.equals("cancelled") || s.equals("canceled") || s.contains("hủy");
    }

    //chức năng
    // Cập nhật trạng thái của đơn hàng trong cơ sở dữ liệu
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

    // Cập nhật trạng thái đơn hàng kèm theo ghi chú của shipper
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

    //chức năng
    // Lưu đơn hàng mới, bao gồm thông tin giao hàng, thông tin bánh và chi tiết nguyên liệu vào Database
    public boolean insertOrder(Order order) {
        String sqlOrder = "INSERT INTO `orders` (Order_No, Customer_ID, Trip_ID, Order_Time, Delivery_Window_Start, Delivery_Window_End, Delivery_Address, Deposit_Amount, Remaining_COD_Balance, Total_Cost, OrderStatus, Shipping_Fee, Discount_Amount, Payment_Method, Receiver_Name, Receiver_Phone, Customer_Note) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlCake = "INSERT INTO `custom_cake` (Custom_Cake_ID, Canvas_Image_URL, Greeting_Text, Cake_Hash_Structure, Calculated_Price) VALUES (?, ?, ?, ?, ?)";
        String sqlItem = "INSERT INTO `order_item` (Order_Item_ID, Order_No, Custom_Cake_ID, Quantity, Price_At_Purchase) VALUES (?, ?, ?, ?, ?)";

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
                } else {
                    psItem.setNull(3, java.sql.Types.VARCHAR);
                }

                psItem.setInt(4, item.getQuantity());
                psItem.setBigDecimal(5, item.getPriceAtPurchase());
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
    // Đếm tổng số lượng đơn hàng trên toàn hệ thống dựa theo các bộ lọc
    public int getTotalOrdersCount(String keyword, String status, String startDateStr, String endDateStr) {
        return getTotalOrdersCount(keyword, status, startDateStr, endDateStr, null);
    }

    // Đếm tổng số lượng đơn hàng trên toàn hệ thống dựa theo các bộ lọc
    public int getTotalOrdersCount(String keyword, String status, String startDateStr, String endDateStr, String cakeType) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        OrderMapper.appendKeywordCondition(sql, params, keyword);
        OrderMapper.appendStatusCondition(sql, params, status);
        OrderMapper.appendCakeTypeCondition(sql, cakeType);

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

    // Lấy danh sách đơn hàng trên hệ thống có phân trang và bộ lọc
    public List<Order> getOrdersPaged(String keyword, String status, String startDateStr, String endDateStr,
            String sort, int pageIndex, int pageSize) {
        return getOrdersPaged(keyword, status, startDateStr, endDateStr, sort, pageIndex, pageSize, null);
    }

    // Lấy danh sách đơn hàng trên hệ thống có phân trang và bộ lọc
    public List<Order> getOrdersPaged(String keyword, String status, String startDateStr, String endDateStr,
            String sort, int pageIndex, int pageSize, String cakeType) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, c.Full_Name AS Customer_Name FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        OrderMapper.appendKeywordCondition(sql, params, keyword);
        OrderMapper.appendStatusCondition(sql, params, status);
        OrderMapper.appendCakeTypeCondition(sql, cakeType);

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
                    Order order = OrderMapper.mapRowToOrder(rs);
                    // NOTE: Don't load items in list view - only needed in detail view
                    orders.add(order);
                }
            }
            OrderMapper.populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
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
    // Tự động dọn các đơn "Chờ thanh toán" quá 15 phút
    public void cancelExpiredWaitingPaymentOrders() {
        long thresholdMillis = System.currentTimeMillis() - (15 * 60 * 1000);
        java.sql.Timestamp thresholdTime = new java.sql.Timestamp(thresholdMillis);
        String sql = "UPDATE `orders` SET OrderStatus = 'Cancelled', Shipper_Note = 'Hệ thống tự động hủy do quá hạn thanh toán' WHERE OrderStatus = 'Waiting_Payment' AND Order_Time <= ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, thresholdTime);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int countWaitingPaymentByCustomer(String customerId) {
        String sql = "SELECT COUNT(*) FROM `orders` WHERE Customer_ID = ? AND OrderStatus = 'Waiting_Payment'";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
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
