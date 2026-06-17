package com.bakeryzone.dao;

import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public List<Order> getOrdersByCustomerId(String customerId) {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM `orders` WHERE Customer_ID = ? ORDER BY Order_Time DESC";

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order order = mapRowToOrder(rs);
                    order.getItems().addAll(getOrderItems(order.getOrderNo(), conn));
                    orders.add(order);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
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
                    return order;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
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
                COALESCE(t.Template_Name, a.Accessory_Name) AS Item_Name,
                COALESCE(cc.Canvas_Image_URL, t.Image_URL, a.Image_URL) AS Item_Image,
                cc.Greeting_Text,
                COALESCE(cat.Category_Name, 'Phụ kiện') AS Category_Name,
                t.Template_ID,
                t.Image_URL AS Template_Image
            FROM order_item oi
            LEFT JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
            LEFT JOIN cake_template t ON cc.Template_ID = t.Template_ID
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
        order.setTotalCost(rs.getBigDecimal("Total_Cost"));
        order.setOrderStatus(rs.getString("OrderStatus"));
        return order;
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
}
