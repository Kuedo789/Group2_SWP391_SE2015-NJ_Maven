package com.bakeryzone.dao;

import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DAO class for managing Product CRUD operations, filtering, search, and pagination.
 * Syncs SQL Server database changes with a thread-safe, static in-memory fallback list.
 */
public class ProductDAO {
    private static final Logger LOGGER = Logger.getLogger(ProductDAO.class.getName());
    
    // Thread-safe in-memory product database (synced with SQL Server when database is connected)
    private static final List<Product> mockProducts = new CopyOnWriteArrayList<>();

    static {
        // Seed default mockup products into the in-memory fallback database
        mockProducts.add(new Product(
            "CZ-CHOC-001", "Chocolate Fudge Cake", "CZ-CHOC-001", "Chocolate Cakes", 35.00, 2.0, 48, "Active", true,
            "https://images.unsplash.com/photo-1578985545062-69928b1d9587", 
            "Chocolate Sponge", "Chocolate Ganache", "Chocolate Shavings & Cherry", "Cake",
            "Egg, Milk, Wheat, Soy", "1 kg", "3 Days", "Keep refrigerated. Best served chilled.",
            "Rich chocolate cake with chocolate ganache.", 
            "Indulge in our signature Chocolate Fudge Cake - a moist, rich chocolate sponge layered with smooth chocolate ganache and topped with chocolate shavings and fresh cherries.", 
            "Same Day"
        ));
        mockProducts.add(new Product(
            "CZ-STRAW-002", "Strawberry Shortcake", "CZ-STRAW-002", "Fruit Cakes", 32.00, 1.5, 36, "Active", true,
            "https://images.unsplash.com/photo-1565958011703-44f9829ba187", 
            "Vanilla Sponge", "Strawberry Frosting", "Fresh Strawberries & Whipped Cream", "Cake",
            "Egg, Milk, Wheat", "1 kg", "2 Days", "Keep refrigerated. Best served chilled.",
            "Light vanilla sponge with fresh strawberries.", 
            "A light and airy vanilla sponge cake layered with fresh hand-picked organic strawberries and fluffy whipped cream frosting.", 
            "Same Day"
        ));
        mockProducts.add(new Product(
            "CZ-CHEESE-003", "Classic Cheesecake", "CZ-CHEESE-003", "Cheesecakes", 30.00, 2.5, 22, "Active", false,
            "https://images.unsplash.com/photo-1524351199679-46cddf530c04", 
            "Graham Cracker Crust", "Cream Cheese", "Sour Cream Layer", "Cake",
            "Milk, Egg, Wheat", "1.2 kg", "5 Days", "Keep refrigerated. Best served chilled.",
            "Creamy New York style cheesecake.", 
            "Creamy and rich New York style cheesecake baked slowly on a buttery graham cracker crust.", 
            "Same Day"
        ));
        mockProducts.add(new Product(
            "CZ-CUP-004", "Chocolate Cupcakes (6pcs)", "CZ-CUP-004", "Cupcakes", 18.00, 1.0, 63, "Active", true,
            "https://images.unsplash.com/photo-1587314168485-3236d6710814", 
            "Moist Chocolate Cupcake", "Creamy Chocolate Frosting", "Chocolate Shavings", "Cake",
            "Egg, Milk, Wheat", "6 pieces", "3 Days", "Keep refrigerated. Best served chilled.",
            "Moist chocolate cupcakes with creamy frosting.", 
            "Box of 6 delicious, moist chocolate cupcakes topped with a rich, creamy chocolate frosting and finished with chocolate shavings.", 
            "Same Day"
        ));
        mockProducts.add(new Product(
            "CZ-ACC-005", "Premium Gift Box", "CZ-ACC-005", "Accessories", 5.00, 0.0, 150, "Active", false,
            "https://images.unsplash.com/photo-1549465220-1a8b9238cd48", 
            "", "", "", "Accessory",
            "None", "Standard", "1 Year", "Store in cool, dry place.",
            "Elegant gift box for cakes and cupcakes.", 
            "Add an elegant touch to your cake gift with our premium designer box, featuring a silk handle and gold foil branding.", 
            "Same Day"
        ));
        mockProducts.add(new Product(
            "CZ-BDAY-006", "Birthday Celebration Cake", "CZ-BDAY-006", "Celebration Cakes", 28.00, 3.0, 31, "Active", true,
            "https://images.unsplash.com/photo-1535141192574-5d4897c13636", 
            "Vanilla Sponge", "Vanilla Buttercream", "Colorful Sprinkles", "Cake",
            "Egg, Milk, Wheat", "1 kg", "3 Days", "Keep refrigerated. Best served chilled.",
            "Vanilla cake with colorful sprinkles.", 
            "A delightful vanilla celebration cake covered in delicious buttercream frosting and coated with colorful sprinkles.", 
            "Same Day"
        ));
    }

    /**
     * Legacy method for retrieving all products without filters.
     */
    public List<Product> getAllProductsAdmin() {
        return getAllProductsAdmin("", "", "", "newest", 1, 100).list();
    }

    /**
     * Retrieves filtered, sorted, and paginated products.
     */
    public ProductSearchResult getAllProductsAdmin(String category, String status, String search, String sortBy, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        int totalCount = 0;

        try (Connection conn = DBContext.getConnection()) {
            seedDatabaseIfEmpty(conn);

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
            
            // Add pagination (SQL Server dialect)
            filteredItemsSql += " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            itemParams.add((page - 1) * pageSize);
            itemParams.add(pageSize);

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
            
            return new ProductSearchResult(list, totalCount);

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "getAllProductsAdmin query failed. Using in-memory fallback filtering.", e);
            return getFallbackFilterResult(category, status, search, sortBy, page, pageSize);
        }
    }

    /**
     * Performs a delete operation.
     */
    public boolean deleteProduct(String id) {
        // Sync in-memory list
        mockProducts.removeIf(p -> p.id().equals(id) || p.sku().equals(id));

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // If it is an Accessory
                String deleteAcc = "DELETE FROM Accessory WHERE Accessory_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteAcc)) {
                    ps.setString(1, id);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        conn.commit();
                        return true;
                    }
                }

                // If it is a Cake, delete layers, custom cake, then template
                String deleteLayers = "DELETE FROM Cake_Layer_Detail WHERE Custom_Cake_ID IN (SELECT Custom_Cake_ID FROM Custom_Cake WHERE Template_ID = ?)";
                try (PreparedStatement ps = conn.prepareStatement(deleteLayers)) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }

                String deleteCustom = "DELETE FROM Custom_Cake WHERE Template_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteCustom)) {
                    ps.setString(1, id);
                    ps.executeUpdate();
                }

                String deleteTemplate = "DELETE FROM Cake_Template WHERE Template_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(deleteTemplate)) {
                    ps.setString(1, id);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        conn.commit();
                        return true;
                    }
                }

                conn.rollback();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to delete product in database: " + id, e);
        }
        return true; // Returns true because we successfully removed it from in-memory fallback
    }

    /**
     * Creates or updates a product.
     */
    public boolean saveProduct(Product product) {
        // Sync/Update in-memory list
        int existingIdx = -1;
        for (int i = 0; i < mockProducts.size(); i++) {
            if (mockProducts.get(i).id().equals(product.id()) || mockProducts.get(i).sku().equals(product.sku())) {
                existingIdx = i;
                break;
            }
        }
        if (existingIdx != -1) {
            mockProducts.set(existingIdx, product);
        } else {
            mockProducts.add(product);
        }

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean exists = false;
                
                if ("Accessory".equalsIgnoreCase(product.type())) {
                    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Accessory WHERE Accessory_ID = ?")) {
                        ps.setString(1, product.id());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next() && rs.getInt(1) > 0) exists = true;
                        }
                    }

                    if (exists) {
                        // Update
                        String sql = "UPDATE Accessory SET Accessory_Name = ?, Price = ? WHERE Accessory_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setString(1, product.name());
                            ps.setDouble(2, product.price());
                            ps.setString(3, product.id());
                            ps.executeUpdate();
                        }
                    } else {
                        // Insert
                        String sql = "INSERT INTO Accessory (Accessory_ID, Accessory_Name, Price) VALUES (?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                            ps.setString(1, product.id());
                            ps.setString(2, product.name());
                            ps.setDouble(3, product.price());
                            ps.executeUpdate();
                        }
                    }
                } else {
                    // Cake Template
                    try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM Cake_Template WHERE Template_ID = ?")) {
                        ps.setString(1, product.id());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next() && rs.getInt(1) > 0) exists = true;
                        }
                    }

                    if (exists) {
                        // Update Template
                        String updateT = "UPDATE Cake_Template SET Template_Name = ?, Base_Price = ?, Estimated_Labor_Hours = ? WHERE Template_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(updateT)) {
                            ps.setString(1, product.name());
                            ps.setDouble(2, product.price());
                            ps.setDouble(3, product.laborHours());
                            ps.setString(4, product.id());
                            ps.executeUpdate();
                        }
                        
                        // Update Custom Cake
                        String updateC = "UPDATE Custom_Cake SET Calculated_Price = ?, Canvas_Image_URL = ? WHERE Template_ID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(updateC)) {
                            ps.setDouble(1, product.price());
                            ps.setString(2, product.imageUrl());
                            ps.setString(3, product.id());
                            ps.executeUpdate();
                        }

                        // Update Layer Details
                        String updateL = "UPDATE Cake_Layer_Detail SET Sponge_Flavor = ?, Frosting_Flavor = ?, Topping_Choice = ? "
                                       + "WHERE Custom_Cake_ID IN (SELECT Custom_Cake_ID FROM Custom_Cake WHERE Template_ID = ?)";
                        try (PreparedStatement ps = conn.prepareStatement(updateL)) {
                            ps.setString(1, product.spongeFlavor());
                            ps.setString(2, product.frostingFlavor());
                            ps.setString(3, product.toppingChoice());
                            ps.setString(4, product.id());
                            ps.executeUpdate();
                        }
                    } else {
                        // Insert Template
                        String insertT = "INSERT INTO Cake_Template (Template_ID, Template_Name, Base_Price, Estimated_Labor_Hours) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertT)) {
                            ps.setString(1, product.id());
                            ps.setString(2, product.name());
                            ps.setDouble(3, product.price());
                            ps.setDouble(4, product.laborHours());
                            ps.executeUpdate();
                        }
                        
                        // Insert Custom Cake
                        String customCakeId = "CC-" + product.id();
                        String insertC = "INSERT INTO Custom_Cake (Custom_Cake_ID, Template_ID, Canvas_Image_URL, Greeting_Text, Total_Layers, Calculated_Price) VALUES (?, ?, ?, ?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertC)) {
                            ps.setString(1, customCakeId);
                            ps.setString(2, product.id());
                            ps.setString(3, product.imageUrl());
                            ps.setString(4, "Greetings");
                            ps.setInt(5, 1);
                            ps.setDouble(6, product.price());
                            ps.executeUpdate();
                        }

                        // Insert Layer Detail
                        String insertL = "INSERT INTO Cake_Layer_Detail (Layer_ID, Custom_Cake_ID, Layer_Position, Sponge_Flavor, Frosting_Flavor, Topping_Choice) VALUES (?, ?, ?, ?, ?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertL)) {
                            ps.setString(1, "L-" + product.id());
                            ps.setString(2, customCakeId);
                            ps.setInt(3, 1);
                            ps.setString(4, product.spongeFlavor());
                            ps.setString(5, product.frostingFlavor());
                            ps.setString(6, product.toppingChoice());
                            ps.executeUpdate();
                        }
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save product in database: " + product.id(), e);
        }
        return true;
    }

    /* Helper Methods */

    private String getBaseUnionQuery() {
        return "SELECT "
             + "    t.Template_ID AS Product_ID, "
             + "    t.Template_Name AS Product_Name, "
             + "    'Cake' AS Product_Type, "
             + "    t.Base_Price AS Price, "
             + "    t.Estimated_Labor_Hours AS Labor_Hours, "
             + "    CASE "
             + "        WHEN t.Template_Name LIKE '%Chocolate%' THEN 'Chocolate Cakes' "
             + "        WHEN t.Template_Name LIKE '%Strawberry%' OR t.Template_Name LIKE '%Fruit%' THEN 'Fruit Cakes' "
             + "        WHEN t.Template_Name LIKE '%Cheesecake%' THEN 'Cheesecakes' "
             + "        WHEN t.Template_Name LIKE '%Cupcake%' THEN 'Cupcakes' "
             + "        WHEN t.Template_Name LIKE '%Celebration%' OR t.Template_Name LIKE '%Birthday%' THEN 'Celebration Cakes' "
             + "        ELSE 'Cakes' "
             + "    END AS Category, "
             + "    COALESCE(cc.Canvas_Image_URL, '') AS Image_URL, "
             + "    COALESCE(ld.Sponge_Flavor, '') AS Sponge_Flavor, "
             + "    COALESCE(ld.Frosting_Flavor, '') AS Frosting_Flavor, "
             + "    COALESCE(ld.Topping_Choice, '') AS Topping_Choice, "
             + "    CASE "
             + "        WHEN t.Template_Name LIKE '%Chocolate%' THEN 48 "
             + "        WHEN t.Template_Name LIKE '%Strawberry%' THEN 36 "
             + "        WHEN t.Template_Name LIKE '%Cheesecake%' THEN 22 "
             + "        WHEN t.Template_Name LIKE '%Cupcake%' THEN 63 "
             + "        WHEN t.Template_Name LIKE '%Celebration%' THEN 31 "
             + "        ELSE 15 "
             + "    END AS Stock, "
             + "    'Active' AS Status, "
             + "    CASE "
             + "        WHEN t.Template_Name LIKE '%Chocolate%' OR t.Template_Name LIKE '%Strawberry%' OR t.Template_Name LIKE '%Cupcake%' OR t.Template_Name LIKE '%Celebration%' THEN 1 "
             + "        ELSE 0 "
             + "    END AS Featured, "
             + "    'Egg, Milk, Wheat, Soy' AS Allergens, "
             + "    '1 kg' AS Weight_Size, "
             + "    '3 Days' AS Shelf_Life, "
             + "    'Keep refrigerated. Best served chilled.' AS Storage_Instructions, "
             + "    'Delicious cake made with quality ingredients.' AS Short_Description, "
             + "    'Enjoy our premium bakery selection crafted by top artisans. Fresh ingredients and delicious flavors guaranteed.' AS Full_Description, "
             + "    'Same Day' AS Availability, "
             + "    t.Template_ID AS SKU "
             + "FROM Cake_Template t "
             + "LEFT JOIN Custom_Cake cc ON t.Template_ID = cc.Template_ID "
             + "LEFT JOIN Cake_Layer_Detail ld ON cc.Custom_Cake_ID = ld.Custom_Cake_ID AND ld.Layer_Position = 1 "
             + "UNION ALL "
             + "SELECT "
             + "    a.Accessory_ID AS Product_ID, "
             + "    a.Accessory_Name AS Product_Name, "
             + "    'Accessory' AS Product_Type, "
             + "    a.Price AS Price, "
             + "    0.0 AS Labor_Hours, "
             + "    'Accessories' AS Category, "
             + "    '' AS Image_URL, "
             + "    '' AS Sponge_Flavor, "
             + "    '' AS Frosting_Flavor, "
             + "    '' AS Topping_Choice, "
             + "    150 AS Stock, "
             + "    'Active' AS Status, "
             + "    0 AS Featured, "
             + "    'None' AS Allergens, "
             + "    'Standard' AS Weight_Size, "
             + "    '1 Year' AS Shelf_Life, "
             + "    'Store in cool, dry place.' AS Storage_Instructions, "
             + "    'Premium accessories for your party celebrations.' AS Short_Description, "
             + "    'High quality accessories, perfect for adding flair to your cakes and celebrations.' AS Full_Description, "
             + "    'Same Day' AS Availability, "
             + "    a.Accessory_ID AS SKU "
             + "FROM Accessory a";
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

    private Product mapRowToProduct(ResultSet rs) throws SQLException {
        return new Product(
            rs.getString("Product_ID"),
            rs.getString("Product_Name"),
            rs.getString("SKU"),
            rs.getString("Category"),
            rs.getDouble("Price"),
            rs.getDouble("Labor_Hours"),
            rs.getInt("Stock"),
            rs.getString("Status"),
            rs.getInt("Featured") == 1,
            rs.getString("Image_URL"),
            rs.getString("Sponge_Flavor"),
            rs.getString("Frosting_Flavor"),
            rs.getString("Topping_Choice"),
            rs.getString("Product_Type"),
            rs.getString("Allergens"),
            rs.getString("Weight_Size"),
            rs.getString("Shelf_Life"),
            rs.getString("Storage_Instructions"),
            rs.getString("Short_Description"),
            rs.getString("Full_Description"),
            rs.getString("Availability")
        );
    }

    /**
     * Fallback in-memory query processing.
     */
    private ProductSearchResult getFallbackFilterResult(String category, String status, String search, String sortBy, int page, int pageSize) {
        java.util.stream.Stream<Product> stream = mockProducts.stream();

        // Category Filter
        if (category != null && !category.trim().isEmpty()) {
            stream = stream.filter(p -> p.category().equalsIgnoreCase(category.trim()));
        }

        // Status Filter
        if (status != null && !status.trim().isEmpty()) {
            stream = stream.filter(p -> p.status().equalsIgnoreCase(status.trim()));
        }

        // Search Filter
        if (search != null && !search.trim().isEmpty()) {
            final String finalSearch = search.trim().toLowerCase();
            stream = stream.filter(p -> p.name().toLowerCase().contains(finalSearch) || p.sku().toLowerCase().contains(finalSearch));
        }

        // Sorting
        if ("price-asc".equalsIgnoreCase(sortBy)) {
            stream = stream.sorted((p1, p2) -> Double.compare(p1.price(), p2.price()));
        } else if ("price-desc".equalsIgnoreCase(sortBy)) {
            stream = stream.sorted((p1, p2) -> Double.compare(p2.price(), p1.price()));
        } else {
            stream = stream.sorted((p1, p2) -> p2.id().compareTo(p1.id()));
        }

        List<Product> filtered = stream.collect(java.util.stream.Collectors.toList());
        int total = filtered.size();

        // Paging
        int skip = (page - 1) * pageSize;
        List<Product> paginated = filtered.stream()
                .skip(skip)
                .limit(pageSize)
                .collect(java.util.stream.Collectors.toList());

        return new ProductSearchResult(paginated, total);
    }

    /**
     * Seeds database with sample data if tables are empty.
     */
    private void seedDatabaseIfEmpty(Connection conn) {
        try {
            boolean templatesEmpty = true;
            try (Statement s = conn.createStatement();
                 ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM Cake_Template")) {
                if (rs.next() && rs.getInt(1) > 0) {
                    templatesEmpty = false;
                }
            } catch (SQLException e) {
                LOGGER.warning("Cake_Template checking skipped: " + e.getMessage());
                return;
            }

            if (templatesEmpty) {
                LOGGER.info("Seeding SQL Server tables with CakeZone products...");
                conn.setAutoCommit(false);
                
                // Copy mockProducts contents to SQL Database
                String insertTemplate = "INSERT INTO Cake_Template (Template_ID, Template_Name, Base_Price, Estimated_Labor_Hours) VALUES (?, ?, ?, ?)";
                String insertCustom = "INSERT INTO Custom_Cake (Custom_Cake_ID, Template_ID, Canvas_Image_URL, Greeting_Text, Total_Layers, Calculated_Price) VALUES (?, ?, ?, ?, ?, ?)";
                String insertLayer = "INSERT INTO Cake_Layer_Detail (Layer_ID, Custom_Cake_ID, Layer_Position, Sponge_Flavor, Frosting_Flavor, Topping_Choice) VALUES (?, ?, ?, ?, ?, ?)";
                String insertAcc = "INSERT INTO Accessory (Accessory_ID, Accessory_Name, Price) VALUES (?, ?, ?)";

                try (PreparedStatement psT = conn.prepareStatement(insertTemplate);
                     PreparedStatement psC = conn.prepareStatement(insertCustom);
                     PreparedStatement psL = conn.prepareStatement(insertLayer);
                     PreparedStatement psA = conn.prepareStatement(insertAcc)) {

                    for (Product p : mockProducts) {
                        if ("Accessory".equalsIgnoreCase(p.type())) {
                            psA.setString(1, p.id());
                            psA.setString(2, p.name());
                            psA.setDouble(3, p.price());
                            psA.addBatch();
                        } else {
                            psT.setString(1, p.id());
                            psT.setString(2, p.name());
                            psT.setDouble(3, p.price());
                            psT.setDouble(4, p.laborHours());
                            psT.addBatch();

                            String ccId = "CC-" + p.id();
                            psC.setString(1, ccId);
                            psC.setString(2, p.id());
                            psC.setString(3, p.imageUrl());
                            psC.setString(4, "Seeded greeting");
                            psC.setInt(5, 1);
                            psC.setDouble(6, p.price());
                            psC.addBatch();

                            psL.setString(1, "L-" + p.id());
                            psL.setString(2, ccId);
                            psL.setInt(3, 1);
                            psL.setString(4, p.spongeFlavor());
                            psL.setString(5, p.frostingFlavor());
                            psL.setString(6, p.toppingChoice());
                            psL.addBatch();
                        }
                    }
                    psT.executeBatch();
                    psC.executeBatch();
                    psL.executeBatch();
                    psA.executeBatch();
                }
                conn.commit();
                LOGGER.info("Successfully seeded SQL Server.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Ignored seeding error: " + e.getMessage());
        }
    }
}
