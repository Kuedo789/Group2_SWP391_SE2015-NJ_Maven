package com.bakeryzone.dao;

import com.bakeryzone.model.Order;
import com.bakeryzone.utils.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DashboardDAO {

    public double getTotalRevenue() {
        String sql = "SELECT SUM(Total_Cost) FROM `orders` WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao')";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public int getTotalOrders() {
        String sql = "SELECT COUNT(*) FROM `orders`";
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

    public int getTotalCustomers() {
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

    public Map<String, Integer> getOrderStatusCounts() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        
        // Initialize default statuses to ensure they show up even with 0 orders
        counts.put("Chờ xác nhận", 0);
        counts.put("Đã xác nhận", 0);
        counts.put("Đang xử lý", 0);
        counts.put("Đang giao", 0);
        counts.put("Hoàn thành", 0);
        counts.put("Đã hủy", 0);

        String sql = "SELECT OrderStatus, COUNT(*) AS count FROM `orders` GROUP BY OrderStatus";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("OrderStatus");
                int count = rs.getInt("count");
                
                // Map DB status strings to display status strings if they are in English or variations
                if (status != null) {
                    if (status.equalsIgnoreCase("Pending") || status.equals("Chờ xác nhận")) {
                        counts.put("Chờ xác nhận", counts.getOrDefault("Chờ xác nhận", 0) + count);
                    } else if (status.equalsIgnoreCase("Confirmed") || status.equals("Đã xác nhận")) {
                        counts.put("Đã xác nhận", counts.getOrDefault("Đã xác nhận", 0) + count);
                    } else if (status.equalsIgnoreCase("Processing") || status.equals("Đang xử lý")) {
                        counts.put("Đang xử lý", counts.getOrDefault("Đang xử lý", 0) + count);
                    } else if (status.equalsIgnoreCase("Delivering") || status.equals("Đang giao hàng") || status.equals("Đang giao")) {
                        counts.put("Đang giao", counts.getOrDefault("Đang giao", 0) + count);
                    } else if (status.equalsIgnoreCase("Completed") || status.equals("Hoàn thành") || status.equals("Đã giao")) {
                        counts.put("Hoàn thành", counts.getOrDefault("Hoàn thành", 0) + count);
                    } else if (status.equalsIgnoreCase("Cancelled") || status.equalsIgnoreCase("Canceled") || status.equals("Đã hủy")) {
                        counts.put("Đã hủy", counts.getOrDefault("Đã hủy", 0) + count);
                    } else {
                        counts.put(status, count);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return counts;
    }

    public List<Order> getRecentOrders(int limit) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT o.Order_No, o.Customer_ID, o.Order_Time, o.Total_Cost, o.OrderStatus, c.Full_Name " +
                     "FROM `orders` o " +
                     "LEFT JOIN `customer` c ON o.Customer_ID = c.Customer_ID " +
                     "ORDER BY o.Order_Time DESC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderNo(rs.getString("Order_No"));
                    order.setCustomerId(rs.getString("Customer_ID"));
                    order.setOrderTime(rs.getTimestamp("Order_Time"));
                    order.setTotalCost(rs.getBigDecimal("Total_Cost"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setCustomerName(rs.getString("Full_Name"));
                    orders.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }

    public Map<String, Double> getMonthlyRevenueTrend(int monthsLimit) {
        Map<String, Double> trend = new LinkedHashMap<>();
        // Query to group by month and year. In MySQL, DATE_FORMAT is perfect.
        // We order by MIN(Order_Time) ASC so that the months show chronologically left-to-right.
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
                     "  SELECT DATE_FORMAT(Order_Time, '" + dateFormat + "') AS time_label, SUM(Total_Cost) AS revenue, MIN(Order_Time) as min_ot " +
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
                     "  SELECT DATE_FORMAT(Order_Time, '" + dateFormat + "') AS time_label, COUNT(*) AS order_count, MIN(Order_Time) as min_ot " +
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
                     "                 WHERE d.Template_ID = cc.Template_ID" +
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
                     "  SELECT DATE_FORMAT(Order_Time, '%d/%m') AS time_label, SUM(Total_Cost) AS revenue, MIN(Order_Time) as min_ot " +
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
                     "  SELECT DATE_FORMAT(Order_Time, '%d/%m') AS time_label, COUNT(*) AS order_count, MIN(Order_Time) as min_ot " +
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
                     "                 WHERE d.Template_ID = cc.Template_ID" +
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

    public double getTotalRevenueCustom(String startDate, String endDate) {
        String sql = "SELECT SUM(Total_Cost) FROM `orders` WHERE OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') AND Order_Time >= ? AND Order_Time <= ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
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

    public int getTotalOrdersCustom(String startDate, String endDate) {
        String sql = "SELECT COUNT(*) FROM `orders` WHERE Order_Time >= ? AND Order_Time <= ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
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

    public int getTotalCustomersCustom(String startDate, String endDate) {
        String sql = "SELECT COUNT(DISTINCT Customer_ID) FROM `orders` WHERE Order_Time >= ? AND Order_Time <= ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
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

    public Map<String, Integer> getOrderStatusCountsCustom(String startDate, String endDate) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("Chờ xác nhận", 0);
        counts.put("Đã xác nhận", 0);
        counts.put("Đang xử lý", 0);
        counts.put("Đang giao", 0);
        counts.put("Hoàn thành", 0);
        counts.put("Đã hủy", 0);

        String sql = "SELECT OrderStatus, COUNT(*) AS count FROM `orders` WHERE Order_Time >= ? AND Order_Time <= ? GROUP BY OrderStatus";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
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
                        } else if (status.equalsIgnoreCase("Delivering") || status.equals("Đang giao hàng") || status.equals("Đang giao")) {
                            counts.put("Đang giao", counts.getOrDefault("Đang giao", 0) + count);
                        } else if (status.equalsIgnoreCase("Completed") || status.equals("Hoàn thành") || status.equals("Đã giao")) {
                            counts.put("Hoàn thành", counts.getOrDefault("Hoàn thành", 0) + count);
                        } else if (status.equalsIgnoreCase("Cancelled") || status.equalsIgnoreCase("Canceled") || status.equals("Đã hủy")) {
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

    public List<java.util.Map<String, Object>> getBestSellingProductsCustom(String startDate, String endDate, int limit) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name, " +
                     "       SUM(oi.Quantity) AS quantity_sold, SUM(oi.Quantity * oi.Price_At_Purchase) AS total_revenue " +
                     "FROM order_item oi " +
                     "JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID " +
                     "JOIN cake_template t ON cc.Template_ID = t.Template_ID " +
                     "LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID " +
                     "JOIN orders o ON oi.Order_No = o.Order_No " +
                     "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                     "  AND o.Order_Time >= ? AND o.Order_Time <= ? " +
                     "GROUP BY t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name " +
                     "ORDER BY quantity_sold DESC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
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

    public List<java.util.Map<String, Object>> getTopCustomersCustom(String startDate, String endDate, int limit) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT c.Customer_ID, c.Full_Name, COUNT(o.Order_No) AS order_count, SUM(o.Total_Cost) AS total_spent " +
                     "FROM customer c " +
                     "JOIN orders o ON c.Customer_ID = o.Customer_ID " +
                     "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                     "  AND o.Order_Time >= ? AND o.Order_Time <= ? " +
                     "GROUP BY c.Customer_ID, c.Full_Name " +
                     "ORDER BY total_spent DESC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, startDate + " 00:00:00");
            ps.setString(2, endDate + " 23:59:59");
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
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

    public List<java.util.Map<String, Object>> getBestSellingProducts(int limit) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name, " +
                     "       SUM(oi.Quantity) AS quantity_sold, SUM(oi.Quantity * oi.Price_At_Purchase) AS total_revenue " +
                     "FROM order_item oi " +
                     "JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID " +
                     "JOIN cake_template t ON cc.Template_ID = t.Template_ID " +
                     "LEFT JOIN product_category cat ON t.Category_ID = cat.Category_ID " +
                     "JOIN orders o ON oi.Order_No = o.Order_No " +
                     "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                     "GROUP BY t.Template_ID, t.Template_Name, t.Image_URL, cat.Category_Name " +
                     "ORDER BY quantity_sold DESC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
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

    public List<java.util.Map<String, Object>> getTopCustomers(int limit) {
        List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT c.Customer_ID, c.Full_Name, COUNT(o.Order_No) AS order_count, SUM(o.Total_Cost) AS total_spent " +
                     "FROM customer c " +
                     "JOIN orders o ON c.Customer_ID = o.Customer_ID " +
                     "WHERE o.OrderStatus IN ('Completed', 'Hoàn thành', 'Đã giao') " +
                     "GROUP BY c.Customer_ID, c.Full_Name " +
                     "ORDER BY total_spent DESC LIMIT ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
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
