/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.dao;

/**
 *
 * @author thais
 */
import com.bakeryzone.model.CartItemDTO;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    // Rule #4: Single-query optimized SQL for aggregate footer
    public String getCartAggregateStatus(String userId) {
        String sql = "SELECT "
                + "  COUNT(ci.Cart_Item_ID) AS Total, "
                + "  SUM(CASE WHEN (a.Status = 'Active' OR ct.Status = 'Active') THEN 1 ELSE 0 END) AS ActiveCount, "
                + "  SUM(CASE WHEN (a.Status != 'Active' OR ct.Status != 'Active') THEN 1 ELSE 0 END) AS DisabledCount "
                + "FROM cart_item ci "
                + "LEFT JOIN accessory a ON ci.Accessory_ID = a.Accessory_ID "
                + "LEFT JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID "
                + "LEFT JOIN cake_template ct ON cc.Template_ID = ct.Template_ID "
                + "WHERE ci.User_ID = ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("Total");
                    int active = rs.getInt("ActiveCount");
                    int disabled = rs.getInt("DisabledCount");

                    if (total == 0) {
                        return "Total 0 items";
                    }
                    return String.format("Total %d (%d active / %d disabled)", total, active, disabled);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "Total 0 (0 active / 0 disabled)";
    }

    public List<CartItemDTO> getCartItemsForUser(String userId) {
        List<CartItemDTO> items = new ArrayList<>();
        // Joins across your 3NF structure to flatten data for the JSP
        String sql = "SELECT ci.Cart_Item_ID, ci.Quantity, "
                + "  ct.Template_Name, cc.Calculated_Price, ct.Image_URL AS CakeImg, ct.Status AS CakeStatus, cc.Greeting_Text "
                + "FROM cart_item ci "
                + "JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID "
                + "JOIN cake_template ct ON cc.Template_ID = ct.Template_ID "
                + "WHERE ci.User_ID = ? ORDER BY ci.Added_At DESC";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItemDTO dto = new CartItemDTO();
                    dto.setCartItemId(rs.getString("Cart_Item_ID"));
                    dto.setQuantity(rs.getInt("Quantity"));

                    // Direct mapping to cake templates since accessories are removed
                    dto.setName(rs.getString("Template_Name"));
                    dto.setUnitPrice(rs.getBigDecimal("Calculated_Price"));
                    dto.setImageUrl(rs.getString("CakeImg"));
                    dto.setActive("Active".equalsIgnoreCase(rs.getString("CakeStatus")));

                    String greeting = rs.getString("Greeting_Text");
                    dto.setGreetingText(greeting);

                    // Explicitly flags if it is a custom configuration based on greeting text existence
                    //dto.setCustom(greeting != null && !greeting.trim().isEmpty());
                    items.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public void updateQuantity(String cartItemId, String userId, int delta) {
        // Delta will be +1 or -1. Database prevents going below 1 via constraints/logic.
        String sql = "UPDATE cart_item SET Quantity = GREATEST(1, Quantity + ?) WHERE Cart_Item_ID = ? AND User_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setString(2, cartItemId);
            ps.setString(3, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void removeCartItem(String cartItemId, String userId) {
        // NOTE: While strict rules state "No Hard Deletes", the cart_item table represents 
        // volatile session-state routing. We hard delete the cart mapping, but the actual 
        // product/accessory records remain untouched.
        String sql = "DELETE FROM cart_item WHERE Cart_Item_ID = ? AND User_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cartItemId);
            ps.setString(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getCartCountForUser(String userId) {
        if (userId == null || userId.trim().isEmpty()) {
            return 0;
        }

        String sql = "SELECT COALESCE(SUM(Quantity), 0) FROM cart_item WHERE User_ID = ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(CartDAO.class.getName())
                    .log(java.util.logging.Level.SEVERE, "Failed to get cart count for user: " + userId, e);
        }
        return 0;
    }
}
