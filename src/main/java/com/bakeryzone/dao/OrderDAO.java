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
                t.Image_URL AS Template_Image,
                (SELECT COALESCE(SUM(d.Standard_Gram * i.Price_Per_Unit), 0) 
                 FROM template_ingredient_detail d 
                 JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID 
                 WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                t.Default_Margin_Percent,
                t.Default_Service_Percent
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
                        
                        double purchasePrice = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().doubleValue() : 0.0;
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
