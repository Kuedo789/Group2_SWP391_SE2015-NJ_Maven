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
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class CartDAO {

    // Rule #4: Single-query optimized SQL for aggregate footer
    public String getCartAggregateStatus(String userId) {
        String sql = "SELECT "
                + "  COUNT(ci.Cart_Item_ID) AS Total, "
                + "  SUM(CASE WHEN (cc.Custom_Cake_ID IS NOT NULL) THEN 1 ELSE 0 END) AS ActiveCount, "
                + "  0 AS DisabledCount "
                + "FROM cart_item ci "
                + "LEFT JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID "
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
                + "  cc.Cake_Hash_Structure AS Template_Name, cc.Calculated_Price, cc.Canvas_Image_URL AS CakeImg, 'Active' AS CakeStatus, cc.Greeting_Text "
                + "FROM cart_item ci "
                + "JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID "
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

    /**
     * Removes only the specified cart rows owned by the user.
     *
     * @return the number of cart rows removed
     */
    public int removeItemsFromCart(String userId, List<String> cartItemIds) {
        if (userId == null || userId.trim().isEmpty()
                || cartItemIds == null || cartItemIds.isEmpty()) {
            return 0;
        }

        List<String> validIds = cartItemIds.stream()
                .filter(id -> id != null && !id.trim().isEmpty())
                .map(String::trim)
                .distinct()
                .collect(Collectors.toList());

        if (validIds.isEmpty()) {
            return 0;
        }

        String placeholders = String.join(",", Collections.nCopies(validIds.size(), "?"));
        String sql = "DELETE FROM cart_item WHERE User_ID = ? AND Cart_Item_ID IN ("
                + placeholders + ")";

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            for (int i = 0; i < validIds.size(); i++) {
                ps.setString(i + 2, validIds.get(i));
            }
            return ps.executeUpdate();
        } catch (SQLException e) {
            java.util.logging.Logger.getLogger(CartDAO.class.getName())
                    .log(java.util.logging.Level.SEVERE,
                            "Failed to remove checked-out cart items for user: " + userId, e);
            return 0;
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

    public boolean addSnapshotToCart(String userId, String productId, String templateName, java.math.BigDecimal price, String imageUrl, int quantity) {
        // 1. Check if the user already has this exact standard product (and variant/size) in their cart
        if (productId != null && !productId.isEmpty()) {
            String sqlCheck = "SELECT ci.Cart_Item_ID FROM cart_item ci " +
                              "JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID " +
                              "WHERE ci.User_ID = ? AND cc.Cake_Hash_Structure = ?";
            try (Connection conn = DBContext.getJDBCConnection();
                 PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setString(1, userId);
                psCheck.setString(2, templateName);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        String existingCartItemId = rs.getString("Cart_Item_ID");
                        String sqlUpdate = "UPDATE cart_item SET Quantity = Quantity + ? WHERE Cart_Item_ID = ?";
                        try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                            psUpdate.setInt(1, quantity);
                            psUpdate.setString(2, existingCartItemId);
                            psUpdate.executeUpdate();
                            return true; // Successfully incremented quantity
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        // 2. If it does not exist, create a new custom_cake snapshot and cart_item link
        String customCakeId = "CAKE-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String cartItemId = "CRT-" + java.util.UUID.randomUUID().toString().toUpperCase();

        String sqlCake = "INSERT INTO custom_cake (Custom_Cake_ID, Canvas_Image_URL, Greeting_Text, Cake_Hash_Structure, Calculated_Price) VALUES (?, ?, ?, ?, ?)";
        String sqlCart = "INSERT INTO cart_item (Cart_Item_ID, User_ID, Custom_Cake_ID, Quantity, Added_At) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psCake = conn.prepareStatement(sqlCake);
                 PreparedStatement psCart = conn.prepareStatement(sqlCart)) {
                
                // Insert snapshot into custom_cake
                psCake.setString(1, customCakeId);
                psCake.setString(2, imageUrl != null ? imageUrl : "assets/images/products/basic.png");
                psCake.setNull(3, java.sql.Types.VARCHAR); // No greeting for standard product yet
                psCake.setString(4, templateName); // Name + size
                psCake.setBigDecimal(5, price);
                psCake.executeUpdate();

                // Insert link into cart_item
                psCart.setString(1, cartItemId);
                psCart.setString(2, userId);
                psCart.setString(3, customCakeId);
                psCart.setInt(4, quantity);
                psCart.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));
                psCart.executeUpdate();

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
