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
        String sql = "SELECT Ingredient_ID, Ingredient_Name, Price_Per_Unit, Unit_Measure, Image_URL, enable " +
                     "FROM ingredients " +
                     "WHERE enable = 1 " +
                     "ORDER BY Ingredient_ID DESC";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Ingredient ing = new Ingredient(
                    rs.getString("Ingredient_ID"),
                    rs.getString("Ingredient_Name"),
                    rs.getDouble("Price_Per_Unit"),
                    rs.getString("Unit_Measure"),
                    rs.getString("Image_URL"),
                    rs.getBoolean("enable")
                );
                list.add(ing);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all ingredients", e);
        }
        return list;
    }

    public List<Ingredient> getIngredientsFiltered(String search, int page, int pageSize) {
        List<Ingredient> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT Ingredient_ID, Ingredient_Name, Price_Per_Unit, Unit_Measure, Image_URL, enable " +
            "FROM ingredients " +
            "WHERE enable = 1 "
        );
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (Ingredient_Name LIKE ? OR Ingredient_ID LIKE ?) ");
        }
        sql.append("ORDER BY Ingredient_ID DESC ");
        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            
            int offset = (page - 1) * pageSize;
            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Ingredient ing = new Ingredient(
                        rs.getString("Ingredient_ID"),
                        rs.getString("Ingredient_Name"),
                        rs.getDouble("Price_Per_Unit"),
                        rs.getString("Unit_Measure"),
                        rs.getString("Image_URL"),
                        rs.getBoolean("enable")
                    );
                    list.add(ing);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get filtered ingredients", e);
        }
        return list;
    }

    public int getIngredientsCountFiltered(String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM ingredients WHERE enable = 1 "
        );
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (Ingredient_Name LIKE ? OR Ingredient_ID LIKE ?) ");
        }

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
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
        String sql = "SELECT Ingredient_ID, Ingredient_Name, Price_Per_Unit, Unit_Measure, Image_URL, enable " +
                     "FROM ingredients " +
                     "WHERE Ingredient_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Ingredient(
                        rs.getString("Ingredient_ID"),
                        rs.getString("Ingredient_Name"),
                        rs.getDouble("Price_Per_Unit"),
                        rs.getString("Unit_Measure"),
                        rs.getString("Image_URL"),
                        rs.getBoolean("enable")
                    );
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
                String sql = "UPDATE ingredients SET Ingredient_Name = ?, Price_Per_Unit = ?, Unit_Measure = ?, Image_URL = ?, enable = ? WHERE Ingredient_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, ingredient.getIngredientName());
                    ps.setDouble(2, ingredient.getPricePerUnit());
                    ps.setString(3, ingredient.getUnitMeasure());
                    ps.setString(4, ingredient.getImageUrl());
                    ps.setInt(5, ingredient.isEnable() ? 1 : 0);
                    ps.setString(6, ingredient.getIngredientId());
                    return ps.executeUpdate() > 0;
                }
            } else {
                String sql = "INSERT INTO ingredients (Ingredient_ID, Ingredient_Name, Price_Per_Unit, Unit_Measure, Image_URL, enable) VALUES (?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, ingredient.getIngredientId());
                    ps.setString(2, ingredient.getIngredientName());
                    ps.setDouble(3, ingredient.getPricePerUnit());
                    ps.setString(4, ingredient.getUnitMeasure());
                    ps.setString(5, ingredient.getImageUrl());
                    ps.setInt(6, ingredient.isEnable() ? 1 : 0);
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
        String sql = "UPDATE ingredients SET enable = 0 WHERE Ingredient_ID = ?";
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
        return new ArrayList<>();
    }
}
