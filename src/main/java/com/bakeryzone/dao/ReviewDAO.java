package com.bakeryzone.dao;

import com.bakeryzone.model.Review;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    private String getHashForTemplate(String templateId) {
        if (templateId == null) return "";
        switch (templateId) {
            case "TPL_0001": return "HASH_CC_0001";
            case "TPL_0005": return "HASH_CC_0002";
            case "TPL_0009": return "HASH_CC_0003";
            case "TPL_0011": return "HASH_CC_0004";
            case "TPL_0013": return "HASH_CC_0005";
            case "TPL_0017": return "HASH_CC_0006";
            default: return templateId;
        }
    }

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
            LEFT JOIN cake_template t ON (
                cc.Cake_Hash_Structure = t.Template_ID OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')
            )
            LEFT JOIN customer c ON r.Customer_ID = c.Customer_ID
            WHERE (cc.Cake_Hash_Structure = ? OR cc.Cake_Hash_Structure = ?) AND r.Moderation_Status IN ('Approved', 'Featured')
            ORDER BY 
                CASE WHEN r.Moderation_Status = 'Featured' THEN 1 ELSE 2 END ASC, 
                r.Review_ID DESC
            """;

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productId);
            ps.setString(2, getHashForTemplate(productId));
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
                    
                    String tName = rs.getString("Template_Name");
                    r.setTemplateName(tName != null ? tName : "Bánh tự thiết kế");

                    double ingredientCost = rs.getDouble("Ingredient_Cost");
                    double margin = rs.getDouble("Default_Margin_Percent");
                    double service = rs.getDouble("Default_Service_Percent");
                    double divisor = 1.0 - ((margin + service) / 100.0);
                    double basePrice = (divisor > 0.0) ? (ingredientCost / divisor) : ingredientCost;
                    basePrice = Math.ceil(basePrice / 1000.0) * 1000.0;
                    r.setBasePrice(basePrice);
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
            WHERE o.Customer_ID = ? AND (cc.Cake_Hash_Structure = ? OR cc.Cake_Hash_Structure = ?) AND o.OrderStatus = 'Completed'
            """;
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            ps.setString(3, getHashForTemplate(productId));
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
            WHERE o.Customer_ID = ? AND (cc.Cake_Hash_Structure = ? OR cc.Cake_Hash_Structure = ?) AND o.OrderStatus = 'Completed'
            ORDER BY o.Order_Time DESC LIMIT 1
            """;
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            ps.setString(3, getHashForTemplate(productId));
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
            WHERE r.Customer_ID = ? AND (cc.Cake_Hash_Structure = ? OR cc.Cake_Hash_Structure = ?)
            """;
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            ps.setString(2, productId);
            ps.setString(3, getHashForTemplate(productId));
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
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
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

    public int getTotalReviewsForAdmin(String keyword, Integer stars, String status) {
        String query = """
            SELECT COUNT(*) FROM product_review r 
            JOIN customer c ON r.Customer_ID = c.Customer_ID 
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID 
            LEFT JOIN cake_template t ON (
                cc.Cake_Hash_Structure = t.Template_ID OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')
            )
            WHERE 1=1 
            """;

        if (keyword != null) {
            query += "AND (c.Full_Name LIKE ? OR r.Comment LIKE ? OR cc.Cake_Hash_Structure LIKE ? OR t.Template_Name LIKE ?) ";
        }
        if (stars != null) {
            query += "AND r.Rating_Stars = ? ";
        }
        if (status != null) {
            query += "AND r.Moderation_Status = ? ";
        }

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (keyword != null) {
                String k = "%" + keyword + "%";
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
            }
            if (stars != null) {
                ps.setInt(paramIndex++, stars);
            }
            if (status != null) {
                ps.setString(paramIndex++, status);
            }

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

    public List<Review> searchAndFilterReviewsForAdmin(String keyword, Integer stars, String status, int pageIndex, int pageSize) {
        List<Review> list = new ArrayList<>();
        String query = """
            SELECT r.*, c.Full_Name AS Customer_Name, COALESCE(t.Template_Name, cc.Cake_Hash_Structure) AS Template_Name 
            FROM product_review r 
            JOIN customer c ON r.Customer_ID = c.Customer_ID 
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID 
            LEFT JOIN cake_template t ON (
                cc.Cake_Hash_Structure = t.Template_ID OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')
            )
            WHERE 1=1 
            """;

        if (keyword != null) {
            query += "AND (c.Full_Name LIKE ? OR r.Comment LIKE ? OR cc.Cake_Hash_Structure LIKE ? OR t.Template_Name LIKE ?) ";
        }
        if (stars != null) {
            query += "AND r.Rating_Stars = ? ";
        }
        if (status != null) {
            query += "AND r.Moderation_Status = ? ";
        }

        query += "ORDER BY r.Review_ID DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            int paramIndex = 1;
            if (keyword != null) {
                String k = "%" + keyword + "%";
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
                ps.setString(paramIndex++, k);
            }
            if (stars != null) {
                ps.setInt(paramIndex++, stars);
            }
            if (status != null) {
                ps.setString(paramIndex++, status);
            }

            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, (pageIndex - 1) * pageSize);

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

                    String rawTemplateName = rs.getString("Template_Name");
                    if (rawTemplateName != null && rawTemplateName.contains("SIZE")) {
                        r.setTemplateName("Bánh Custom (" + rawTemplateName.split("_")[1] + "cm)");
                    } else {
                        r.setTemplateName(rawTemplateName);
                    }
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Review getReviewByIdForAdmin(String id) {
        String query = """
            SELECT 
                r.*, c.Full_Name AS Customer_Name, cc.Calculated_Price, cc.Greeting_Text, COALESCE(t.Template_Name, cc.Cake_Hash_Structure) AS Template_Name,
                (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0) 
                 FROM template_ingredient_detail d 
                 JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID 
                 WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost,
                t.Default_Margin_Percent, t.Default_Service_Percent
            FROM product_review r
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID
            LEFT JOIN cake_template t ON (
                cc.Cake_Hash_Structure = t.Template_ID OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')
            )
            LEFT JOIN customer c ON r.Customer_ID = c.Customer_ID
            WHERE r.Review_ID = ?
            """;
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getString("Review_ID"));
                    r.setCustomCakeId(rs.getString("Custom_Cake_ID"));
                    r.setCustomerId(rs.getString("Customer_ID"));
                    r.setRatingStars(rs.getInt("Rating_Stars"));
                    r.setComment(rs.getString("Comment"));
                    r.setModerationStatus(rs.getString("Moderation_Status"));
                    r.setCustomerName(rs.getString("Customer_Name"));
                    r.setTemplateName(rs.getString("Template_Name"));
                    r.setGreetingText(rs.getString("Greeting_Text"));

                    double calculatedPrice = rs.getDouble("Calculated_Price");
                    r.setCalculatedPrice(calculatedPrice);

                    double ingredientCost = rs.getDouble("Ingredient_Cost");
                    double margin = rs.getDouble("Default_Margin_Percent");
                    double service = rs.getDouble("Default_Service_Percent");
                    double divisor = 1.0 - ((margin + service) / 100.0);
                    double basePrice = (divisor > 0.0) ? (ingredientCost / divisor) : ingredientCost;
                    basePrice = Math.ceil(basePrice / 1000.0) * 1000.0;
                    r.setBasePrice(basePrice);

                    r.setVariationName(getVariationName(basePrice, calculatedPrice));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateModerationStatus(String reviewId, String status) {
        String sql = "UPDATE product_review SET Moderation_Status = ? WHERE Review_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, reviewId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Review> getFeaturedReviewsForHomePage() {
        List<Review> list = new ArrayList<>();
        String sql = """
            SELECT
                r.Review_ID,
                r.Rating_Stars,
                r.Comment,
                c.Full_Name AS Customer_Name,
                COALESCE(t.Template_Name, cc.Cake_Hash_Structure) AS Template_Name
            FROM product_review r
            JOIN custom_cake cc ON r.Custom_Cake_ID = cc.Custom_Cake_ID
            LEFT JOIN cake_template t ON (
                cc.Cake_Hash_Structure = t.Template_ID OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0001' AND t.Template_ID = 'TPL_0001') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0002' AND t.Template_ID = 'TPL_0005') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0003' AND t.Template_ID = 'TPL_0009') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0004' AND t.Template_ID = 'TPL_0011') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0005' AND t.Template_ID = 'TPL_0013') OR
                (cc.Cake_Hash_Structure = 'HASH_CC_0006' AND t.Template_ID = 'TPL_0017')
            )
            LEFT JOIN customer c ON r.Customer_ID = c.Customer_ID
            WHERE r.Moderation_Status = 'Featured'
            ORDER BY r.Review_ID DESC
            LIMIT 3
            """;

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Review r = new Review();
                r.setReviewId(rs.getString("Review_ID"));
                r.setRatingStars(rs.getInt("Rating_Stars"));
                r.setComment(rs.getString("Comment"));
                r.setCustomerName(rs.getString("Customer_Name"));

                String rawName = rs.getString("Template_Name");
                if (rawName != null && rawName.contains("SIZE")) {
                    r.setTemplateName("Bánh Thiết Kế (" + rawName.split("_")[1] + "cm)");
                } else {
                    r.setTemplateName(rawName);
                }
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
