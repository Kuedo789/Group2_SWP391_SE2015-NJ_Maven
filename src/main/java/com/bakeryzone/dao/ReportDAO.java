package com.bakeryzone.dao;

import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {


    //chức năng
    // Tính tổng lợi nhuận thực tế (Đã trừ đi chi phí nguyên vật liệu cấu thành bánh) trong khoảng thời gian
    public double getTotalProfit(String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT SUM(o.Total_Cost) - SUM(COALESCE(" +
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
                "         )) AS total_profit " +
                "FROM `orders` o " +
                "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')");
        List<String> params = new ArrayList<>();
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDate.trim() + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDate.trim() + " 23:59:59");
        }
        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("total_profit");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    //chức năng
    // Tính tổng doanh thu gộp (Bao gồm tiền sản phẩm + phí ship) của các đơn hàng đã hoàn thành
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

    // Lấy tổng số lượng khách hàng đã đặt hàng trong khoảng thời gian
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

    // Đếm tổng số lượng mẫu bánh (sản phẩm) đang có trên hệ thống
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

    // Thống kê số lượng đơn hàng theo từng trạng thái trên toàn hệ thống
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

    //chức năng
    // Lấy dữ liệu xu hướng doanh thu theo từng tháng để vẽ biểu đồ tổng quan
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

    // Lấy xu hướng doanh thu theo ngày/tháng để vẽ biểu đồ
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

    // Lấy xu hướng số lượng đơn hàng theo ngày/tháng để vẽ biểu đồ
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

    // Lấy xu hướng lợi nhuận theo ngày/tháng để vẽ biểu đồ
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

    // Lấy xu hướng doanh thu theo khoảng thời gian tùy chỉnh
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

    // Lấy xu hướng số lượng đơn hàng theo khoảng thời gian tùy chỉnh
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

    // Lấy xu hướng lợi nhuận theo khoảng thời gian tùy chỉnh
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

    //chức năng
    // Lấy danh sách các sản phẩm bán chạy nhất kèm theo số lượng bán và tổng doanh thu mang lại
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

    // Lấy danh sách các khách hàng mua nhiều nhất (Top khách hàng)
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
}
