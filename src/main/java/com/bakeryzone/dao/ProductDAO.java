

/**
 * DAO class for managing Product CRUD operations matching the simplified MySQL schema.
 * Operates on Cake_Template and Accessory tables.
 */
package com.bakeryzone.dao;

import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO class for managing Product CRUD operations matching the simplified MySQL schema.
 * Operates strictly on Cake_Template and Accessory tables from the database.
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
     * Retrieves a single product by its ID from either Cake_Template or Accessory.
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
                    return mapRowToProduct(rs);
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

    public void deleteProduct(String id) throws SQLException {
        try (Connection conn = DBContext.getJDBCConnection()) {
            // Check & delete from Accessory
            String deleteAcc = "DELETE FROM Accessory WHERE Accessory_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteAcc)) {
                ps.setString(1, id);
                if (ps.executeUpdate() > 0) return;
            }

            // Check & delete from Cake_Template
            String deleteTemplate = "DELETE FROM Cake_Template WHERE Template_ID = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteTemplate)) {
                ps.setString(1, id);
                ps.executeUpdate();
            }
        }
    }

    /**
     * Creates or updates a product in the database.
     */
    public boolean saveProduct(Product product) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            boolean exists = false;
            
            if ("Accessory".equalsIgnoreCase(product.getProductType())) {
                // Clean up from Cake_Template if type changed
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Cake_Template WHERE Template_ID = ?")) {
                    ps.setString(1, product.getId());
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Accessory WHERE Accessory_ID = ?")) {
                    ps.setString(1, product.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) exists = true;
                    }
                }

                if (exists) {
                    // Update
                    String sql = "UPDATE Accessory SET Accessory_Name = ?, Price = ?, SKU = ?, Image_URL = ?, "
                               + "Status = ?, Is_Featured = ?, Short_Description = ?, Full_Description = ? WHERE Accessory_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, product.getName());
                        ps.setDouble(2, product.getPrice());
                        ps.setString(3, product.getSku());
                        ps.setString(4, product.getImageUrl());
                        ps.setString(5, product.getStatus());
                        ps.setBoolean(6, product.isFeatured());
                        ps.setString(7, product.getShortDescription());
                        ps.setString(8, product.getFullDescription());
                        ps.setString(9, product.getId());
                        return ps.executeUpdate() > 0;
                    }
                } else {
                    // Insert
                    String sql = "INSERT INTO Accessory (Accessory_ID, Accessory_Name, Price, SKU, Image_URL, Status, Is_Featured, Short_Description, Full_Description) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, product.getId());
                        ps.setString(2, product.getName());
                        ps.setDouble(3, product.getPrice());
                        ps.setString(4, product.getSku());
                        ps.setString(5, product.getImageUrl());
                        ps.setString(6, product.getStatus());
                        ps.setBoolean(7, product.isFeatured());
                        ps.setString(8, product.getShortDescription());
                        ps.setString(9, product.getFullDescription());
                        return ps.executeUpdate() > 0;
                    }
                }
            } else {
                // Clean up from Accessory if type changed
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM Accessory WHERE Accessory_ID = ?")) {
                    ps.setString(1, product.getId());
                    ps.executeUpdate();
                }

                // Cake Template
                try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Cake_Template WHERE Template_ID = ?")) {
                    ps.setString(1, product.getId());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) exists = true;
                    }
                }

                if (exists) {
                    // Update Template
                    String updateT = "UPDATE Cake_Template SET Template_Name = ?, Base_Price = ?, Estimated_Labor_Hours = ?, "
                                   + "SKU = ?, Image_URL = ?, Status = ?, Is_Featured = ?, Short_Description = ?, Full_Description = ? "
                                   + "WHERE Template_ID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateT)) {
                        ps.setString(1, product.getName());
                        ps.setDouble(2, product.getPrice());
                        ps.setDouble(3, product.getLaborHours());
                        ps.setString(4, product.getSku());
                        ps.setString(5, product.getImageUrl());
                        ps.setString(6, product.getStatus());
                        ps.setBoolean(7, product.isFeatured());
                        ps.setString(8, product.getShortDescription());
                        ps.setString(9, product.getFullDescription());
                        ps.setString(10, product.getId());
                        return ps.executeUpdate() > 0;
                    }
                } else {
                    // Insert Template
                    String insertT = "INSERT INTO Cake_Template (Template_ID, Template_Name, Base_Price, Estimated_Labor_Hours, SKU, Image_URL, Status, Is_Featured, Short_Description, Full_Description) "
                                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertT)) {
                        ps.setString(1, product.getId());
                        ps.setString(2, product.getName());
                        ps.setDouble(3, product.getPrice());
                        ps.setDouble(4, product.getLaborHours());
                        ps.setString(5, product.getSku());
                        ps.setString(6, product.getImageUrl());
                        ps.setString(7, product.getStatus());
                        ps.setBoolean(8, product.isFeatured());
                        ps.setString(9, product.getShortDescription());
                        ps.setString(10, product.getFullDescription());
                        return ps.executeUpdate() > 0;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save product in database: " + product.getId(), e);
        }
        return false;
    }

    /* Helper Methods */

    public String getBaseUnionQuery() {
        return "SELECT "
             + "    t.Template_ID AS Product_ID, "
             + "    t.Template_Name AS Product_Name, "
             + "    t.SKU AS SKU, "
             + "    t.Base_Price AS Price, "
             + "    t.Estimated_Labor_Hours AS Labor_Hours, "
             + "    t.Image_URL AS Image_URL, "
             + "    t.Status AS Status, "
             + "    t.Is_Featured AS Is_Featured, "
             + "    t.Short_Description AS Short_Description, "
             + "    t.Full_Description AS Full_Description, "
             + "    'Cake' AS Product_Type, "
             + "    CASE "
             + "        WHEN t.Template_Name LIKE '%Chocolate%' THEN 'Chocolate Cakes' "
             + "        WHEN t.Template_Name LIKE '%Strawberry%' OR t.Template_Name LIKE '%Fruit%' THEN 'Fruit Cakes' "
             + "        WHEN t.Template_Name LIKE '%Cheesecake%' THEN 'Cheesecakes' "
             + "        WHEN t.Template_Name LIKE '%Cupcake%' THEN 'Cupcakes' "
             + "        WHEN t.Template_Name LIKE '%Celebration%' OR t.Template_Name LIKE '%Birthday%' THEN 'Celebration Cakes' "
             + "        ELSE 'Cakes' "
             + "    END AS Category "
             + "FROM Cake_Template t ";
//             + "UNION ALL "
//             + "SELECT "
//             + "    a.Accessory_ID AS Product_ID, "
//             + "    a.Accessory_Name AS Product_Name, "
//             + "    a.SKU AS SKU, "
//             + "    a.Price AS Price, "
//             + "    0.0 AS Labor_Hours, "
//             + "    a.Image_URL AS Image_URL, "
//             + "    a.Status AS Status, "
//             + "    a.Is_Featured AS Is_Featured, "
//             + "    a.Short_Description AS Short_Description, "
//             + "    a.Full_Description AS Full_Description, "
//             + "    'Accessory' AS Product_Type, "
//             + "    'Accessories' AS Category "
//             + "FROM Accessory a"; 
    }

    public Product mapRowToProduct(ResultSet rs) throws SQLException {
        return new Product(
            rs.getString("Product_ID"),
            rs.getString("Product_Name"),
            rs.getString("SKU"),
            rs.getString("Category"),
            rs.getDouble("Price"),
            rs.getDouble("Labor_Hours"),
            rs.getString("Status"),
            rs.getBoolean("Is_Featured"),
            rs.getString("Image_URL"),
            rs.getString("Short_Description"),
            rs.getString("Full_Description"),
            rs.getString("Product_Type")
        );
    }

    private String appendFilterConditions(String sql, String category, String status, String search, List<Object> params) {
        StringBuilder sb = new StringBuilder(sql);
        if (category != null && !category.trim().isEmpty()) {
            sb.append(" AND p.Category = ?");
            params.add(category);
        }
        if (status != null && !status.trim().isEmpty()) {
            sb.append(" AND p.Status = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sb.append(" AND (p.Product_Name LIKE ? OR p.SKU LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }
        return sb.toString();
    }

    private String getOrderByClause(String sortBy) {
        if ("price-asc".equalsIgnoreCase(sortBy)) {
            return " ORDER BY p.Price ASC";
        } else if ("price-desc".equalsIgnoreCase(sortBy)) {
            return " ORDER BY p.Price DESC";
        } else {
            return " ORDER BY p.Product_ID DESC"; // newest first
        }
    }
}
