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

public class OrderDAO {

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
                    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0)
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
        if (total != null && deposit != null) {
            order.setRemainingCodBalance(total.subtract(deposit));
        } else {
            order.setRemainingCodBalance(BigDecimal.ZERO);
        }
        order.setOrderStatus(rs.getString("OrderStatus"));
        try {
            order.setCustomerName(rs.getString("Customer_Name"));
        } catch (SQLException e) {
            // Ignore if Customer_Name column is not present
        }
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

    public boolean insertOrder(Order order) {
        String sqlOrder = "INSERT INTO `orders` (Order_No, Customer_ID, Trip_ID, Order_Time, Delivery_Window_Start, Delivery_Window_End, Delivery_Address, Deposit_Amount, Total_Cost, OrderStatus) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlCake = "INSERT INTO `custom_cake` (Custom_Cake_ID, Template_ID, Canvas_Image_URL, Greeting_Text, Frosting_Ingredient_ID, Topping_Ingredient_ID, Cake_Hash_Structure, Calculated_Price) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
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
            psOrder.setBigDecimal(9, order.getTotalCost());
            psOrder.setString(10, order.getOrderStatus());
            psOrder.executeUpdate();

            psCake = conn.prepareStatement(sqlCake);
            psItem = conn.prepareStatement(sqlItem);

            int itemCounter = 1;
            for (OrderItem item : order.getItems()) {
                String orderItemId = order.getOrderNo() + "_ITM_" + itemCounter++;
                psItem.setString(1, orderItemId);
                psItem.setString(2, order.getOrderNo());

                if (item.getCustomCakeId() != null && !item.getCustomCakeId().trim().isEmpty()) {
                    // It's a custom cake template, insert custom_cake first
                    psCake.setString(1, item.getCustomCakeId());
                    if (item.getTemplateId() != null && !item.getTemplateId().trim().isEmpty()) {
                        psCake.setString(2, item.getTemplateId());
                    } else {
                        psCake.setNull(2, java.sql.Types.VARCHAR);
                    }
                    psCake.setString(3,
                            item.getItemImage() != null ? item.getItemImage() : "assets/images/default-cake.png");
                    psCake.setString(4,
                            item.getGreetingText() != null ? item.getGreetingText() : "Chúc mừng sinh nhật!");
                    psCake.setString(5, "ING_CREAM"); // Frosting_Ingredient_ID
                    psCake.setNull(6, java.sql.Types.VARCHAR); // Topping_Ingredient_ID
                    psCake.setString(7, "DEFAULT_HASH"); // Cake_Hash_Structure
                    psCake.setBigDecimal(8, item.getPriceAtPurchase()); // Calculated_Price
                    psCake.executeUpdate();

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

    public int getTotalOrdersCount(String keyword, String status, String startDateStr, String endDateStr) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (o.Order_No LIKE ? OR c.Full_Name LIKE ? OR c.Phone LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status);
        }

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
            int pageIndex, int pageSize) {
        List<Order> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, c.Full_Name AS Customer_Name FROM `orders` o LEFT JOIN customer c ON o.Customer_ID = c.Customer_ID WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (o.Order_No LIKE ? OR c.Full_Name LIKE ? OR c.Phone LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("all")) {
            sql.append(" AND o.OrderStatus = ?");
            params.add(status);
        }

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time >= ?");
            params.add(startDateStr + " 00:00:00");
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            sql.append(" AND o.Order_Time <= ?");
            params.add(endDateStr + " 23:59:59");
        }

        sql.append(" ORDER BY o.Order_Time DESC LIMIT ? OFFSET ?");
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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orders;
    }
}
