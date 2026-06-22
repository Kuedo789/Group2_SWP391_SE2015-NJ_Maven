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
}
