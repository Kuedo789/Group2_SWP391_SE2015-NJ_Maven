package com.bakeryzone.dao;

import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO class for managing Product CRUD operations matching the simplified MySQL schema.
 * Operates strictly on cake_template, product_category, and cake_recipe tables.
 */
public class ProductDAO {
    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());

    /**
     * Retrieves all products without filters.
     */
    public List<Product> getAllProductsAdmin() {
        return getAllProductsAdmin("", "", "", "newest", 1, 100).list();
    }

    /**
     * Retrieves a single product by its ID from cake_template.
     */
    public Product getProductById(String id) {
        if (id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            return null;
        }
        String sql = "SELECT * FROM (" + getBaseUnionQuery() + ") AS p WHERE p.Product_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = mapRowToProduct(rs);
                    // Query additional images
                    List<String> images = new ArrayList<>();
                    String imgSql = "SELECT Image_URL FROM product_image WHERE Product_ID = ? ORDER BY Sort_Order ASC";
                    try (PreparedStatement imgPs = conn.prepareStatement(imgSql)) {
                        imgPs.setString(1, id);
                        try (ResultSet imgRs = imgPs.executeQuery()) {
                            while (imgRs.next()) {
                                images.add(imgRs.getString("Image_URL"));
                            }
                        }
                    }
                    product.setAdditionalImages(images);
                    return product;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get product by ID: " + id, e);
        }
        return null;
    }

    /**
     * Retrieves filtered, sorted, and paginated products directly from DB.
     */
    public ProductSearchResult getAllProductsAdmin(String category, String status, String search, String sortBy, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        int totalCount = 0;

        try (Connection conn = DBContext.getJDBCConnection()) {
            // 1. Get the total count matching filters
            String baseCountSql = "SELECT COUNT(*) FROM (" + getBaseUnionQuery() + ") AS p WHERE 1=1";
            List<Object> countParams = new ArrayList<>();
            String filteredCountSql = appendFilterConditions(baseCountSql, category, status, search, countParams);

            try (PreparedStatement ps = conn.prepareStatement(filteredCountSql)) {
                for (int i = 0; i < countParams.size(); i++) {
                    ps.setObject(i + 1, countParams.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCount = rs.getInt(1);
                    }
                }
            }

            // 2. Query paginated and sorted items
            String baseItemsSql = "SELECT * FROM (" + getBaseUnionQuery() + ") AS p WHERE 1=1";
            List<Object> itemParams = new ArrayList<>();
            String filteredItemsSql = appendFilterConditions(baseItemsSql, category, status, search, itemParams);
            
            // Add sorting
            filteredItemsSql += getOrderByClause(sortBy);
            
            // Add pagination (MySQL dialect)
            filteredItemsSql += " LIMIT ? OFFSET ?";
            itemParams.add(pageSize);
            itemParams.add((page - 1) * pageSize);

            try (PreparedStatement ps = conn.prepareStatement(filteredItemsSql)) {
                for (int i = 0; i < itemParams.size(); i++) {
                    ps.setObject(i + 1, itemParams.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        list.add(mapRowToProduct(rs));
                    }
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "getAllProductsAdmin query failed.", e);
        }
        
        return new ProductSearchResult(list, totalCount);
    }

    /**
     * Performs a delete operation.
     */
    public void deleteProduct(String id) throws SQLException {
        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            try {
                // Delete additional images first to prevent FK/dependency constraints
                String deleteImages = "DELETE FROM product_image WHERE Product_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteImages)) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }
                // Then delete template
                String deleteTemplate = "DELETE FROM cake_template WHERE Template_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteTemplate)) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    /**
     * Creates or updates a product in the database.
     */
    public boolean saveProduct(Product product) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            boolean success = false;
            try {
                boolean exists = false;
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM cake_template WHERE Template_ID = ?")) {
                    ps.setString(1, product.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) exists = true;
                    }
                }

                if (exists) {
                    // Update Template
                    String updateT = "UPDATE cake_template SET Template_Name = ?, Base_Price = ?, "
                                   + "Estimated_Labor_Hours = ?, Allows_Greeting = ?, Image_URL = ?, Status = ?, "
                                   + "Is_Featured = ?, Full_Description = ?, Category_ID = ? "
                                   + "WHERE Template_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateT)) {
                        ps.setString(1, product.getName());
                        ps.setDouble(2, product.getBasePrice());
                        ps.setDouble(3, product.getEstimatedLaborHours());
                        ps.setBoolean(4, product.isAllowsGreeting());
                        ps.setString(5, product.getImageUrl());
                        ps.setString(6, product.getStatus());
                        ps.setBoolean(7, product.isFeatured());
                        ps.setString(8, product.getFullDescription());
                        
                        String cId = product.getCategoryId();
                        ps.setString(9, (cId == null || cId.trim().isEmpty()) ? null : cId.trim());
                        
                        ps.setString(10, product.getId());
                        success = ps.executeUpdate() > 0;
                    }
                } else {
                    // Insert Template
                    String insertT = "INSERT INTO cake_template (Template_ID, Template_Name, Base_Price, Estimated_Labor_Hours, "
                                   + "Allows_Greeting, Image_URL, Status, Is_Featured, Full_Description, Category_ID) "
                                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertT)) {
                        ps.setString(1, product.getId());
                        ps.setString(2, product.getName());
                        ps.setDouble(3, product.getBasePrice());
                        ps.setDouble(4, product.getEstimatedLaborHours());
                        ps.setBoolean(5, product.isAllowsGreeting());
                        ps.setString(6, product.getImageUrl());
                        ps.setString(7, product.getStatus());
                        ps.setBoolean(8, product.isFeatured());
                        ps.setString(9, product.getFullDescription());
                        
                        String cId = product.getCategoryId();
                        ps.setString(10, (cId == null || cId.trim().isEmpty()) ? null : cId.trim());
                        
                        success = ps.executeUpdate() > 0;
                    }
                }

                if (success) {
                    // Delete existing product images
                    String deleteImages = "DELETE FROM product_image WHERE Product_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(deleteImages)) {
                        ps.setString(1, product.getId());
                        ps.executeUpdate();
                    }

                    // Insert fresh product images list
                    List<String> list = product.getAdditionalImages();
                    if (list != null && !list.isEmpty()) {
                        String insertImg = "INSERT INTO product_image (Product_ID, Image_URL, Is_Cover, Sort_Order) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertImg)) {
                            for (int i = 0; i < list.size(); i++) {
                                String url = list.get(i);
                                ps.setString(1, product.getId());
                                ps.setString(2, url);
                                // If this image is the main preview image, mark as cover
                                boolean isCover = url.equalsIgnoreCase(product.getImageUrl());
                                ps.setInt(3, isCover ? 1 : 0);
                                ps.setInt(4, i + 1);
                                ps.addBatch();
                            }
                            ps.executeBatch();
                        }
                    }
                }

                conn.commit();
                return success;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save product in database: " + product.getId(), e);
        }
        return false;
    }
    public List<Map<String, String>> getAllProductCategories() {
        List<Map<String, String>> categories = new ArrayList<>();
        String sql = "SELECT Category_ID, Category_Name FROM product_category";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> cat = new HashMap<>();
                cat.put("id", rs.getString("Category_ID"));
                cat.put("name", rs.getString("Category_Name"));
                categories.add(cat);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get product categories.", e);
        }
        return categories;
    }

    /**
     * Queries the cake_recipe table to retrieve all Recipe IDs and Names.
     */
    public List<Map<String, String>> getAllRecipeMasters() {
        List<Map<String, String>> recipes = new ArrayList<>();
        String sql = "SELECT Recipe_ID, Recipe_Name FROM cake_recipe";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> rec = new HashMap<>();
                rec.put("id", rs.getString("Recipe_ID"));
                rec.put("name", rs.getString("Recipe_Name"));
                recipes.add(rec);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get recipe masters.", e);
        }
        return recipes;
    }

    /* Helper Methods */

    public String getBaseUnionQuery() {
        return "SELECT "
             + "    t.Template_ID AS Product_ID, "
             + "    t.Template_Name AS Product_Name, "
             + "    t.Base_Price AS Base_Price, "
             + "    t.Allows_Greeting AS Allows_Greeting, "
             + "    t.Image_URL AS Image_URL, "
             + "    t.Status AS Status, "
             + "    t.Is_Featured AS Is_Featured, "
             + "    t.Full_Description AS Full_Description, "
             + "    'Cake' AS Product_Type, "
             + "    t.Category_ID AS Category_ID, "
             + "    c.Category_Name AS Category_Name, "
             + "    t.Estimated_Labor_Hours AS Estimated_Labor_Hours "
             + "FROM cake_template t "
             + "LEFT JOIN product_category c ON t.Category_ID = c.Category_ID";
    }

    public Product mapRowToProduct(ResultSet rs) throws SQLException {
        Product p = new Product(
            rs.getString("Product_ID"),
            rs.getString("Product_Name"),
            rs.getString("Category_ID"),
            rs.getString("Category_Name"),
            rs.getDouble("Base_Price"),
            rs.getDouble("Estimated_Labor_Hours"),
            rs.getBoolean("Allows_Greeting"),
            rs.getString("Image_URL"),
            rs.getString("Status"),
            rs.getBoolean("Is_Featured"),
            rs.getString("Full_Description"),
            rs.getString("Product_Type")
        );
        return p;
    }

    private String appendFilterConditions(String sql, String category, String status, String search, List<Object> params) {
        StringBuilder sb = new StringBuilder(sql);
        if (category != null && !category.trim().isEmpty()) {
            sb.append(" AND (p.Category_Name = ? OR p.Category_ID = ?)");
            params.add(category);
            params.add(category);
        }
        if (status != null && !status.trim().isEmpty()) {
            sb.append(" AND p.Status = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sb.append(" AND (p.Product_Name LIKE ? OR p.Product_ID LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }
        return sb.toString();
    }

    private String getOrderByClause(String sortBy) {
        if ("price-asc".equalsIgnoreCase(sortBy)) {
            return " ORDER BY p.Base_Price ASC";
        } else if ("price-desc".equalsIgnoreCase(sortBy)) {
            return " ORDER BY p.Base_Price DESC";
        }
        return " ORDER BY p.Product_ID DESC"; // newest first
    }
}
