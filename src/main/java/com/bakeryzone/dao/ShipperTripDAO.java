package com.bakeryzone.dao;

import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.utils.DBContext;
import com.bakeryzone.utils.OrderMapper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ShipperTripDAO {
    private OrderDAO orderDAO = new OrderDAO();


    // Lấy tên của nhân viên giao hàng (Shipper) phụ trách chuyến đi cụ thể
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

    // Lấy khu vực quản lý của một nhân viên
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

    // Đếm tổng số đơn hàng được giao bởi một shipper cụ thể
    public int getTotalOrdersCountByShipper(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr) {
        return getTotalOrdersCountByShipper(shipperId, keyword, status, startDateStr, endDateStr, null);
    }

    // Đếm tổng số đơn hàng được giao bởi một shipper cụ thể
    public int getTotalOrdersCountByShipper(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr, String cakeType) {
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

    // Lấy danh sách đơn hàng của một shipper có phân trang và bộ lọc
    public List<Order> getOrdersByShipperPaged(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr,
            String sort, int pageIndex, int pageSize) {
        return getOrdersByShipperPaged(shipperId, keyword, status, startDateStr, endDateStr, sort, pageIndex, pageSize, null);
    }

    // Lấy danh sách đơn hàng của một shipper có phân trang và bộ lọc
    public List<Order> getOrdersByShipperPaged(String shipperId, String keyword, String status, String startDateStr,
            String endDateStr,
            String sort, int pageIndex, int pageSize, String cakeType) {
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
                    orders.add(order);
                }
            }
            OrderMapper.populateOrderItems(orders, conn);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    // Lấy link ảnh bằng chứng nhận hàng và giao hàng của một chuyến đi
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

    // Lưu hình ảnh bằng chứng giao hàng (lấy hàng/giao hàng) vào DB
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

    public String generateEvidenceId(Connection conn) {
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

    //chức năng
    // Tự động tìm kiếm và phân công shipper phù hợp nhất (theo tuyến đường/tình trạng) cho đơn hàng
    public boolean autoAssignShipperAndTrip(String orderNo) {
        Order order = new OrderDAO().getOrderByNo(orderNo);
        if (order == null) {
            return false;
        }
        return com.bakeryzone.service.AutoAssignService.assignShipperToOrder(order);
    }

    public String generateTripId(Connection conn) {
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

    // Tạo một chuyến giao hàng (Delivery Trip) mới cho shipper
    public String createNewDeliveryTrip(String shipperId) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            if (conn == null) return null;
            String tripId = generateTripId(conn);
            String insertTripSql = "INSERT INTO `delivery_trip` (Trip_ID, Shipper_ID, OSRM_Distance_Km, OSRM_Duration_Min) VALUES (?, ?, 0.0, 0)";
            try (PreparedStatement ps = conn.prepareStatement(insertTripSql)) {
                ps.setString(1, tripId);
                ps.setString(2, shipperId);
                if (ps.executeUpdate() > 0) {
                    return tripId;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Cập nhật (gắn) một đơn hàng vào một chuyến giao hàng cụ thể
    public boolean updateOrderTrip(String orderNo, String tripId) {
        String sql = "UPDATE `orders` SET Trip_ID = ? WHERE Order_No = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tripId);
            ps.setString(2, orderNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Lấy danh sách các đơn hàng thuộc một chuyến giao hàng
    public List<Order> getOrdersByTripId(String tripId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM `orders` WHERE Trip_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tripId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(OrderMapper.mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Lấy ID chuyến giao hàng đang hoạt động (chưa hoàn thành) của shipper
    public String getActiveTripIdByShipper(String shipperId) {
        String sql = "SELECT DISTINCT dt.Trip_ID FROM `delivery_trip` dt " +
                     "JOIN `orders` o ON dt.Trip_ID = o.Trip_ID " +
                     "WHERE dt.Shipper_ID = ? AND o.OrderStatus IN ('Processing', 'Delivering') " +
                     "LIMIT 1";
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Trip_ID");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy tọa độ (hoặc địa chỉ) giao hàng của một đơn hàng để tính toán lộ trình
    public double[] getOrderCoordinates(String orderNo) {
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT Delivery_Address, Customer_ID FROM `orders` WHERE Order_No = ?")) {
            ps.setString(1, orderNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String deliveryAddressStr = rs.getString("Delivery_Address");
                    String customerId = rs.getString("Customer_ID");
                    String addressDetail = deliveryAddressStr;
                    if (deliveryAddressStr != null && deliveryAddressStr.contains("|")) {
                        String[] parts = deliveryAddressStr.split("\\|");
                        if (parts.length >= 3) {
                            addressDetail = parts[2].trim();
                        }
                    }
                    
                    String coordSql = "SELECT da.Latitude, da.Longitude FROM `delivery_address` da " +
                                      "JOIN `customer` c ON da.User_ID = c.User_ID " +
                                      "WHERE c.Customer_ID = ? AND (da.Address_Detail = ? OR LOCATE(da.Address_Detail, ?) > 0 OR LOCATE(?, da.Address_Detail) > 0)";
                    try (PreparedStatement ps2 = conn.prepareStatement(coordSql)) {
                        ps2.setString(1, customerId);
                        ps2.setString(2, addressDetail);
                        ps2.setString(3, addressDetail);
                        ps2.setString(4, addressDetail);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            if (rs2.next()) {
                                return new double[]{rs2.getDouble("Latitude"), rs2.getDouble("Longitude")};
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Lấy thông số thống kê trong ngày của shipper (số đơn, doanh thu, v.v.)
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

    // Lấy danh sách các đơn hàng đã sẵn sàng giao cho shipper
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
                    orders.add(OrderMapper.mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    // Lấy danh sách các đơn hàng đã được giao thành công bởi shipper
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
                    orders.add(OrderMapper.mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    // Shipper xác nhận nhận đơn hàng để đi giao
    public boolean acceptOrderForShipper(String shipperId, String orderNo) {
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
                String insertTripSql = "INSERT INTO `delivery_trip` (Trip_ID, Shipper_ID, OSRM_Distance_Km, OSRM_Duration_Min) VALUES (?, ?, 0.0, 0)";
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

    public String ensureTripIdForOrder(String orderNo, String shipperUserId) {
        if (orderNo == null || orderNo.trim().isEmpty()) {
            return null;
        }
        try (Connection conn = DBContext.getJDBCConnection()) {
            if (conn == null) return null;

            String checkSql = "SELECT Trip_ID FROM `orders` WHERE Order_No = ?";
            String currentTripId = null;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setString(1, orderNo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentTripId = rs.getString("Trip_ID");
                    }
                }
            }

            if (currentTripId != null && !currentTripId.trim().isEmpty()) {
                return currentTripId;
            }

            conn.setAutoCommit(false);
            String staffId = shipperUserId;
            if (shipperUserId != null && !shipperUserId.trim().isEmpty()) {
                String getStaffSql = "SELECT Staff_ID FROM `staff` WHERE User_ID = ? OR Staff_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(getStaffSql)) {
                    ps.setString(1, shipperUserId);
                    ps.setString(2, shipperUserId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            staffId = rs.getString("Staff_ID");
                        }
                    }
                }
            }

            String newTripId = generateTripId(conn);
            String insertTripSql = "INSERT INTO `delivery_trip` (Trip_ID, Shipper_ID, OSRM_Distance_Km, OSRM_Duration_Min) VALUES (?, ?, 0.0, 0)";
            try (PreparedStatement ps = conn.prepareStatement(insertTripSql)) {
                ps.setString(1, newTripId);
                ps.setString(2, staffId);
                ps.executeUpdate();
            }

            String updateOrderSql = "UPDATE `orders` SET Trip_ID = ? WHERE Order_No = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                ps.setString(1, newTripId);
                ps.setString(2, orderNo);
                ps.executeUpdate();
            }

            conn.commit();
            return newTripId;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
