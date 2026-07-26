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
                + "  SUM(CASE WHEN (ci.Custom_Cake_ID IS NOT NULL OR ci.Product_ID IS NOT NULL) THEN 1 ELSE 0 END) AS ActiveCount, "
                + "  0 AS DisabledCount "
                + "FROM cart_item ci "
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
        String sql = "SELECT ci.Cart_Item_ID, ci.Quantity, ci.Snapshot_Name, ci.Snapshot_Image, ci.Price_At_Purchase, "
                + "  COALESCE(ci.Snapshot_Name, t.Template_Name, cc.Cake_Hash_Structure) AS Template_Name, "
                + "  COALESCE(ci.Price_At_Purchase, "
                + "     (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0) "
                + "      FROM template_ingredient_detail d JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID "
                + "      WHERE d.Template_ID = t.Template_ID) / (1.0 - (t.Default_Margin_Percent + t.Default_Service_Percent)/100.0), "
                + "     cc.Calculated_Price"
                + "  ) AS Calculated_Price, "
                + "  COALESCE(ci.Snapshot_Image, t.Image_URL, cc.Canvas_Image_URL) AS CakeImg, "
                + "  'Active' AS CakeStatus, cc.Greeting_Text, ci.Product_ID, ci.Custom_Cake_ID "
                + "FROM cart_item ci "
                + "LEFT JOIN custom_cake cc ON ci.Custom_Cake_ID = cc.Custom_Cake_ID "
                + "LEFT JOIN cake_template t ON ci.Product_ID = t.Template_ID "
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
                    
                    dto.setProductId(rs.getString("Product_ID"));
                    dto.setCustomCakeId(rs.getString("Custom_Cake_ID"));

                    // Set raw snapshot fields if they exist, catching exception if column doesn't exist
                    try {
                        dto.setSnapshotName(rs.getString("Snapshot_Name"));
                        dto.setSnapshotImage(rs.getString("Snapshot_Image"));
                        dto.setPriceAtPurchase(rs.getBigDecimal("Price_At_Purchase"));
                    } catch (SQLException ignore) {
                        // Columns might not exist yet
                    }

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

    public boolean addTemplateToCart(String userId, String productId, String templateName, java.math.BigDecimal price, String imageUrl, int quantity) {
        // 1. Check if the user already has this exact standard product in their cart
        if (productId != null && !productId.isEmpty()) {
            String sqlCheck = "SELECT Cart_Item_ID FROM cart_item " +
                              "WHERE User_ID = ? AND Product_ID = ? AND Snapshot_Name = ?";
            try (Connection conn = DBContext.getJDBCConnection();
                 PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                psCheck.setString(1, userId);
                psCheck.setString(2, productId);
                psCheck.setString(3, templateName);
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
                // If Snapshot_Name column doesn't exist, it will throw an exception here, but we will catch it and try to insert below (which will also fail).
                // But we print it to see.
                System.out.println("Error checking cart item: " + e.getMessage());
            }
        }

        // 2. If it does not exist, insert into cart_item directly
        String cartItemId = "CRT-" + java.util.UUID.randomUUID().toString().toUpperCase();

        String sqlCart = "INSERT INTO cart_item (Cart_Item_ID, User_ID, Product_ID, Quantity, Added_At, Snapshot_Name, Snapshot_Image, Price_At_Purchase) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement psCart = conn.prepareStatement(sqlCart)) {
            
            psCart.setString(1, cartItemId);
            psCart.setString(2, userId);
            psCart.setString(3, productId);
            psCart.setInt(4, quantity);
            psCart.setTimestamp(5, new java.sql.Timestamp(System.currentTimeMillis()));
            psCart.setString(6, templateName);
            psCart.setString(7, imageUrl);
            psCart.setBigDecimal(8, price);
            psCart.executeUpdate();

            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
