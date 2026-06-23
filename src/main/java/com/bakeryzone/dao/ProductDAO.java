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
 * DAO class for managing Product CRUD operations matching the updated schema.
 * Operates on cake_template, product_category, and calculates dynamic
 * margins/service percentages.
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
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product product = mapRowToProduct(rs);
                    if (product != null) {
                        product.setAdditionalImages(getAdditionalImagesByProductId(product.getId()));
                    }
                    return product;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get product by ID: " + id, e);
        }
        return null;
    }

    public List<String> getAdditionalImagesByProductId(String productId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT Image_URL FROM product_image WHERE Product_ID = ? ORDER BY Sort_Order ASC, Image_ID ASC";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("Image_URL"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get additional images for product: " + productId, e);
        }
        return list;
    }

    public void saveProductAdditionalImages(String productId, List<String> imageUrls) {
        String deleteSql = "DELETE FROM product_image WHERE Product_ID = ?";
        String insertSql = "INSERT INTO product_image (Product_ID, Image_URL, Is_Cover, Sort_Order) VALUES (?, ?, 0, ?)";
        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            try {
                // First delete old ones
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setString(1, productId);
                    ps.executeUpdate();
                }

                // Then insert new ones
                if (imageUrls != null && !imageUrls.isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        int order = 1;
                        for (String url : imageUrls) {
                            if (url != null && !url.trim().isEmpty()) {
                                ps.setString(1, productId);
                                ps.setString(2, url);
                                ps.setInt(3, order++);
                                ps.addBatch();
                            }
                        }
                        ps.executeBatch();
                    }
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save additional images for product: " + productId, e);
        }
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
            // Fix this line:
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

    private int countCountParams(String category, String status, String search, List<Object> params) {
        // Wrapper extraction tool matching native pattern
        return params.size();
    }

    /**
     * Performs a delete operation.
     */
    public void deleteProduct(String id) throws SQLException {
        try (Connection conn = DBContext.getJDBCConnection()) {
            String deleteTemplate = "DELETE FROM cake_template WHERE Template_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteTemplate)) {
                ps.setString(1, id);
                ps.executeUpdate();
            }
        }
    }

    /**
     * Deactivates a product by setting its Status to 'Inactive' in the
     * database.
     */
    public boolean deactivateProduct(String id) {
        if (id == null || id.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE cake_template SET Status = 'Inactive' WHERE Template_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to deactivate product: " + id, e);
        }
        return false;
    }

    /**
     * Activates a product by setting its Status to 'Active' in the database.
     */
    public boolean activateProduct(String id) {
        if (id == null || id.trim().isEmpty()) {
            return false;
        }
        String sql = "UPDATE cake_template SET Status = 'Active' WHERE Template_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to activate product: " + id, e);
        }
        return false;
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
                        if (rs.next() && rs.getInt(1) > 0) {
                            exists = true;
                        }
                    }
                }

                if (exists) {
                    String updateT = "UPDATE cake_template SET Template_Name = ?, "
                            + "Estimated_Labor_Hours = ?, Allows_Greeting = ?, Image_URL = ?, Status = ?, "
                            + "Is_Featured = ?, Full_Description = ?, Category_ID = ?, "
                            + "Default_Margin_Percent = ?, Default_Service_Percent = ?, Instruction_Steps = ? "
                            + "WHERE Template_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateT)) {
                        ps.setString(1, product.getName());
                        ps.setDouble(2, product.getEstimatedLaborHours());
                        ps.setBoolean(3, product.isAllowsGreeting());
                        ps.setString(4, product.getImageUrl());
                        ps.setString(5, product.getStatus());
                        ps.setBoolean(6, product.isFeatured());
                        ps.setString(7, product.getFullDescription());

                        String cId = product.getCategoryId();
                        ps.setString(8, (cId == null || cId.trim().isEmpty()) ? null : cId.trim());

                        ps.setDouble(9, product.getDefaultMarginPercent());
                        ps.setDouble(10, product.getDefaultServicePercent());
                        ps.setString(11, product.getInstructionSteps());
                        ps.setString(12, product.getId());

                        success = ps.executeUpdate() > 0;
                    }
                } else {
                    String insertT = "INSERT INTO cake_template (Template_ID, Template_Name, Estimated_Labor_Hours, "
                            + "Allows_Greeting, Image_URL, Status, Is_Featured, Full_Description, Category_ID, "
                            + "Default_Margin_Percent, Default_Service_Percent, Instruction_Steps) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertT)) {
                        ps.setString(1, product.getId());
                        ps.setString(2, product.getName());
                        ps.setDouble(3, product.getEstimatedLaborHours());
                        ps.setBoolean(4, product.isAllowsGreeting());
                        ps.setString(5, product.getImageUrl());
                        ps.setString(6, product.getStatus());
                        ps.setBoolean(7, product.isFeatured());
                        ps.setString(8, product.getFullDescription());

                        String cId = product.getCategoryId();
                        ps.setString(9, (cId == null || cId.trim().isEmpty()) ? null : cId.trim());

                        ps.setDouble(10, product.getDefaultMarginPercent());
                        ps.setDouble(11, product.getDefaultServicePercent());
                        ps.setString(12, product.getInstructionSteps());

                        success = ps.executeUpdate() > 0;
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

        String sql = """
                     SELECT Category_ID, Category_Name, image_url AS Icon_URL
                     FROM product_category
                     WHERE enable = 1
                     ORDER BY Category_Name ASC
                     """;

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> cat = new HashMap<>();
                cat.put("id", rs.getString("Category_ID"));
                cat.put("name", rs.getString("Category_Name"));
                cat.put("iconUrl", rs.getString("Icon_URL"));
                categories.add(cat);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get product categories.", e);
        }
        return categories;
    }

    /* Helper Methods */
    public String getBaseUnionQuery() {
        return "SELECT "
                + "    t.Template_ID AS Product_ID, "
                + "    t.Template_Name AS Product_Name, "
                + "    t.Allows_Greeting AS Allows_Greeting, "
                + "    t.Image_URL AS Image_URL, "
                + "    t.Status AS Status, "
                + "    t.Is_Featured AS Is_Featured, "
                + "    t.Full_Description AS Full_Description, "
                + "    'Cake' AS Product_Type, "
                + "    t.Category_ID AS Category_ID, "
                + "    c.Category_Name AS Category_Name, "
                + "    t.Estimated_Labor_Hours AS Estimated_Labor_Hours, "
                + "    t.Default_Margin_Percent AS Default_Margin_Percent, "
                + "    t.Default_Service_Percent AS Default_Service_Percent, "
                + "    t.Instruction_Steps AS Instruction_Steps, "
                + "    (SELECT COALESCE(SUM(d.Quantity * i.Price_Per_Unit), 0) " // Fixed: Used d.Quantity instead of d.Standard_Gram
                + "     FROM template_ingredient_detail d "
                + "     JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID "
                + "     WHERE d.Template_ID = t.Template_ID) AS Ingredient_Cost "
                + "FROM cake_template t "
                + "LEFT JOIN product_category c ON t.Category_ID = c.Category_ID";
    }

    public Product mapRowToProduct(ResultSet rs) throws SQLException {
        Product p;
        try {
            p = new Product(
                    rs.getString("Product_ID"),
                    rs.getString("Product_Name"),
                    rs.getString("Category_ID"),
                    rs.getString("Category_Name"),
                    rs.getDouble("Estimated_Labor_Hours"),
                    rs.getBoolean("Allows_Greeting"),
                    rs.getString("Image_URL"),
                    rs.getString("Status"),
                    rs.getBoolean("Is_Featured"),
                    rs.getString("Full_Description"),
                    rs.getString("Product_Type"),
                    rs.getDouble("Default_Margin_Percent"),
                    rs.getDouble("Default_Service_Percent"),
                    rs.getString("Instruction_Steps")
            );
        } catch (Exception e) {
            p = new Product();
            p.setId(rs.getString("Product_ID"));
            p.setName(rs.getString("Product_Name"));
            p.setCategoryId(rs.getString("Category_ID"));
            p.setCategoryName(rs.getString("Category_Name"));
            p.setEstimatedLaborHours(rs.getDouble("Estimated_Labor_Hours"));
            p.setAllowsGreeting(rs.getBoolean("Allows_Greeting"));
            p.setImageUrl(rs.getString("Image_URL"));
            p.setStatus(rs.getString("Status"));
            p.setFeatured(rs.getBoolean("Is_Featured"));
            p.setFullDescription(rs.getString("Full_Description"));
            p.setDefaultMarginPercent(rs.getDouble("Default_Margin_Percent"));
            p.setDefaultServicePercent(rs.getDouble("Default_Service_Percent"));
            p.setInstructionSteps(rs.getString("Instruction_Steps"));
        }

        // Calculate dynamic base price using margin math formulas from template ingredient dependencies
        double ingredientCost = rs.getDouble("Ingredient_Cost");
        double margin = rs.getDouble("Default_Margin_Percent");
        double service = rs.getDouble("Default_Service_Percent");
        double divisor = 1.0 - ((margin + service) / 100.0);

        double calculatedBasePrice = 0.0;
        if (divisor > 0.0) {
            calculatedBasePrice = ingredientCost / divisor;
        } else {
            calculatedBasePrice = ingredientCost;
        }

        p.setBasePrice(calculatedBasePrice);
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
            return " ORDER BY p.Ingredient_Cost / (1.0 - (p.Default_Margin_Percent + p.Default_Service_Percent)/100.0) ASC";
        } else if ("price-desc".equalsIgnoreCase(sortBy)) {
            return " ORDER BY p.Ingredient_Cost / (1.0 - (p.Default_Margin_Percent + p.Default_Service_Percent)/100.0) DESC";
        }
        return " ORDER BY p.Product_ID DESC";
    }

    public List<Product> getHomepageBestSellerProducts(int limit) {
        List<Product> products = new ArrayList<>();

        String sql = "SELECT p.*, COALESCE(sales.total_qty, 0) as total_sold "
                + "FROM (" + getBaseUnionQuery() + ") AS p "
                + "LEFT JOIN ("
                + "    SELECT cc.Template_ID, SUM(oi.Quantity) as total_qty "
                + "    FROM order_item oi "
                + "    JOIN custom_cake cc ON oi.Custom_Cake_ID = cc.Custom_Cake_ID "
                + "    JOIN orders o ON oi.Order_No = o.Order_No "
                + "    WHERE o.OrderStatus = 'Completed' "
                + "    GROUP BY cc.Template_ID"
                + ") AS sales ON p.Product_ID = sales.Template_ID "
                + "WHERE p.Status = ? "
                + "ORDER BY total_sold DESC, p.Is_Featured DESC, p.Product_ID DESC "
                + "LIMIT ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "Active");
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRowToProduct(rs));
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get homepage best seller products.", e);
        }

        return products;
    }

    public List<Map<String, Object>> getProductIngredients(String templateId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.Ingredient_ID, d.Standard_Gram, i.Ingredient_Name, i.Price_Per_Unit "
                + "FROM template_ingredient_detail d "
                + "JOIN ingredients i ON d.Ingredient_ID = i.Ingredient_ID "
                + "WHERE d.Template_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, templateId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("ingredientId", rs.getString("Ingredient_ID"));
                    map.put("ingredientName", rs.getString("Ingredient_Name"));
                    map.put("standardGram", rs.getDouble("Standard_Gram"));
                    map.put("pricePerUnit", rs.getDouble("Price_Per_Unit"));
                    list.add(map);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get product ingredients for template: " + templateId, e);
        }
        return list;
    }

    public boolean saveProductIngredients(String templateId, String[] ingredientIds, String[] standardGrams) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            conn.setAutoCommit(false);
            try {
                String deleteSql = "DELETE FROM template_ingredient_detail WHERE Template_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                    ps.setString(1, templateId);
                    ps.executeUpdate();
                }

                if (ingredientIds != null && standardGrams != null) {
                    // Find this inside saveProductIngredients and change standard_gram to Quantity:
                    String insertSql = "INSERT INTO template_ingredient_detail (Template_ID, Ingredient_ID, Quantity) VALUES (?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        for (int i = 0; i < ingredientIds.length; i++) {
                            if (ingredientIds[i] != null && !ingredientIds[i].trim().isEmpty()) {
                                double grams = 0.0;
                                try {
                                    grams = Double.parseDouble(standardGrams[i]);
                                } catch (NumberFormatException e) {
                                    grams = 0.0;
                                }
                                if (grams > 0) {
                                    ps.setString(1, templateId);
                                    ps.setString(2, ingredientIds[i].trim());
                                    ps.setDouble(3, grams);
                                    ps.addBatch();
                                }
                            }
                        }
                        ps.executeBatch();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save product ingredients for template: " + templateId, e);
        }
        return false;
    }
}
