package com.bakeryzone.dao;

import com.bakeryzone.model.Review;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public List<Review> getReviewsByProductId(String productId) {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT 
                r.Review_ID,
                r.Custom_Cake_ID,
                r.Customer_ID,
                r.Rating_Stars,
                r.Comment,
                r.Moderation_Status,
                c.Full_Name AS Customer_Name,
                cc.Calculated_Price,
                cc.Greeting_Text,
                t.Template_Name,
                (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0) 
                 FROM template_ingredient_detail d 
                 JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID 
                 WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                t.Default_Margin_Percent,
                t.Default_Service_Percent
            FROM product_review r
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID
            LEFT JOIN cake_template t ON cc.Template_ID = t.Template_ID
            LEFT JOIN customer c ON r.Customer_ID = c.Customer_ID
            WHERE cc.Template_ID = ?
            ORDER BY r.Review_ID DESC
            """;

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getString("Review_ID"));
                    r.setCustomCakeId(rs.getString("Custom_Cake_ID"));
                    r.setCustomerId(rs.getString("Customer_ID"));
                    r.setRatingStars(rs.getInt("Rating_Stars"));
                    r.setComment(rs.getString("Comment"));
                    r.setModerationStatus(rs.getString("Moderation_Status"));
                    r.setCustomerName(rs.getString("Customer_Name"));
                    
                    double calculatedPrice = rs.getDouble("Calculated_Price");
                    r.setCalculatedPrice(calculatedPrice);
                    r.setGreetingText(rs.getString("Greeting_Text"));
                    r.setTemplateName(rs.getString("Template_Name"));

                    // Calculate Base Price dynamically
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
                    r.setBasePrice(basePrice);

                    // Set Variation Name
                    r.setVariationName(getVariationName(basePrice, calculatedPrice));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean hasBoughtProduct(String customerId, String productId) {
        String sql = """
            SELECT COUNT(*) 
            FROM order_item oi
            JOIN orders o ON oi.Order_No = o.Order_No
            JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
            WHERE o.Customer_ID = ? AND cc.Template_ID = ? AND o.OrderStatus = 'Completed'
            """;
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getRecentCustomCakeId(String customerId, String productId) {
        String sql = """
            SELECT cc.Custom_Cake_ID 
            FROM order_item oi
            JOIN orders o ON oi.Order_No = o.Order_No
            JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID
            WHERE o.Customer_ID = ? AND cc.Template_ID = ? AND o.OrderStatus = 'Completed'
            ORDER BY o.Order_Time DESC LIMIT 1
            """;
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("Custom_Cake_ID");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean hasReviewed(String customerId, String productId) {
        String sql = """
            SELECT COUNT(*) 
            FROM product_review r
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID
            WHERE r.Customer_ID = ? AND cc.Template_ID = ?
            """;
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addReview(String reviewId, String customCakeId, String customerId, int ratingStars, String comment) {
        String sql = "INSERT INTO product_review (Review_ID, Custom_Cake_ID, Customer_ID, Rating_Stars, Comment, Moderation_Status) VALUES (?, ?, ?, ?, ?, 'Approved')";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewId);
            ps.setString(2, customCakeId);
            ps.setString(3, customerId);
            ps.setInt(4, ratingStars);
            ps.setString(5, comment);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateReview(String reviewId, String customerId, int ratingStars, String comment) {
        String sql = "UPDATE product_review SET Rating_Stars = ?, Comment = ? WHERE Review_ID = ? AND Customer_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ratingStars);
            ps.setString(2, comment);
            ps.setString(3, reviewId);
            ps.setString(4, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteReview(String reviewId, String customerId) {
        String sql = "DELETE FROM product_review WHERE Review_ID = ? AND Customer_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reviewId);
            ps.setString(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private String getVariationName(double basePrice, double calculatedPrice) {
        double diff = calculatedPrice - basePrice;
        if (diff <= 40000) {
            return "Size 16cm";
        } else if (diff <= 120000) {
            return "Size 20cm";
        } else {
            return "Size 24cm";
        }
    }
}
