package com.bakeryzone.dao;

import com.bakeryzone.model.Ingredient;
import com.bakeryzone.model.IngredientCategory;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class IngredientDAO {
    private static final Logger LOGGER = Logger.getLogger(IngredientDAO.class.getName());

    public List<Ingredient> getAllIngredients() {
        List<Ingredient> list = new ArrayList<>();
        String sql = "SELECT i.Ingredient_ID, i.Ingredient_Name, i.Category_ID, i.Price_Per_Unit, c.Category_Name, i.Status " +
                     "FROM ingredients i " +
                     "JOIN ingredient_category c ON i.Category_ID = c.Category_ID " +
                     "WHERE i.Status = 'Active' " +
                     "ORDER BY i.Ingredient_ID DESC";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ingredient ing = new Ingredient(
                    rs.getString("Ingredient_ID"),
                    rs.getString("Ingredient_Name"),
                    rs.getString("Category_ID"),
                    rs.getDouble("Price_Per_Unit"),
                    rs.getString("Status")
                );
                ing.setCategoryName(rs.getString("Category_Name"));
                list.add(ing);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all ingredients", e);
        }
        return list;
    }

    public List<Ingredient> getIngredientsFiltered(String search, String categoryId, int page, int pageSize) {
        List<Ingredient> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT i.Ingredient_ID, i.Ingredient_Name, i.Category_ID, i.Price_Per_Unit, c.Category_Name, i.Status " +
            "FROM ingredients i " +
            "JOIN ingredient_category c ON i.Category_ID = c.Category_ID " +
            "WHERE i.Status = 'Active' "
        );
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (i.Ingredient_Name LIKE ? OR i.Ingredient_ID LIKE ?) ");
        }
        if (categoryId != null && !categoryId.trim().isEmpty()) {
            sql.append("AND i.Category_ID = ? ");
        }
        sql.append("ORDER BY i.Ingredient_ID DESC ");
        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (categoryId != null && !categoryId.trim().isEmpty()) {
                ps.setString(paramIndex++, categoryId.trim());
            }
            
            int offset = (page - 1) * pageSize;
            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ingredient ing = new Ingredient(
                        rs.getString("Ingredient_ID"),
                        rs.getString("Ingredient_Name"),
                        rs.getString("Category_ID"),
                        rs.getDouble("Price_Per_Unit"),
                        rs.getString("Status")
                    );
                    ing.setCategoryName(rs.getString("Category_Name"));
                    list.add(ing);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get filtered ingredients", e);
        }
        return list;
    }

    public int getIngredientsCountFiltered(String search, String categoryId) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM ingredients i WHERE i.Status = 'Active' "
        );
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (i.Ingredient_Name LIKE ? OR i.Ingredient_ID LIKE ?) ");
        }
        if (categoryId != null && !categoryId.trim().isEmpty()) {
            sql.append("AND i.Category_ID = ? ");
        }

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (categoryId != null && !categoryId.trim().isEmpty()) {
                ps.setString(paramIndex++, categoryId.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count filtered ingredients", e);
        }
        return 0;
    }

    public Ingredient getIngredientById(String id) {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = "SELECT i.Ingredient_ID, i.Ingredient_Name, i.Category_ID, i.Price_Per_Unit, c.Category_Name, i.Status " +
                     "FROM ingredients i " +
                     "JOIN ingredient_category c ON i.Category_ID = c.Category_ID " +
                     "WHERE i.Ingredient_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Ingredient ing = new Ingredient(
                        rs.getString("Ingredient_ID"),
                        rs.getString("Ingredient_Name"),
                        rs.getString("Category_ID"),
                        rs.getDouble("Price_Per_Unit"),
                        rs.getString("Status")
                    );
                    ing.setCategoryName(rs.getString("Category_Name"));
                    return ing;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get ingredient by ID: " + id, e);
        }
        return null;
    }

    public boolean saveIngredient(Ingredient ingredient) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM ingredients WHERE Ingredient_ID = ?")) {
                ps.setString(1, ingredient.getIngredientId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            }

            if (exists) {
                String sql = "UPDATE ingredients SET Ingredient_Name = ?, Category_ID = ?, Price_Per_Unit = ?, Status = ? WHERE Ingredient_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, ingredient.getIngredientName());
                    ps.setString(2, ingredient.getCategoryId());
                    ps.setDouble(3, ingredient.getPricePerUnit());
                    ps.setString(4, ingredient.getStatus() != null ? ingredient.getStatus() : "Active");
                    ps.setString(5, ingredient.getIngredientId());
                    return ps.executeUpdate() > 0;
                }
            } else {
                String sql = "INSERT INTO ingredients (Ingredient_ID, Ingredient_Name, Category_ID, Price_Per_Unit, Status) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, ingredient.getIngredientId());
                    ps.setString(2, ingredient.getIngredientName());
                    ps.setString(3, ingredient.getCategoryId());
                    ps.setDouble(4, ingredient.getPricePerUnit());
                    ps.setString(5, ingredient.getStatus() != null ? ingredient.getStatus() : "Active");
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save ingredient: " + ingredient.getIngredientId(), e);
        }
        return false;
    }

    public boolean deleteIngredient(String id) {
        if (id == null || id.trim().isEmpty()) return false;
        String sql = "UPDATE ingredients SET Status = 'Inactive' WHERE Ingredient_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to delete ingredient: " + id, e);
        }
        return false;
    }

    public List<IngredientCategory> getAllIngredientCategories() {
        List<IngredientCategory> list = new ArrayList<>();
        String sql = "SELECT Category_ID, Category_Name FROM ingredient_category ORDER BY Category_Name ASC";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new IngredientCategory(
                    rs.getString("Category_ID"),
                    rs.getString("Category_Name")
                ));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all ingredient categories", e);
        }
        return list;
    }
}
