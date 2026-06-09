/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.dao;
import com.bakeryzone.model.CategoryDTO;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author thais
 */
public class CategoryDAO {

    // 1. Fetch all categories using the UNION strategy
    public List<CategoryDTO> getAllAdminCategories() throws SQLException, ClassNotFoundException {
        List<CategoryDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = 
            "SELECT Category_ID, Category_Name, Description, 'Sản phẩm chính' AS Category_Type " +
            "FROM product_category " +
            "UNION ALL " +
            "SELECT Category_ID, Category_Name, NULL AS Description, 'Nguyên liệu' AS Category_Type " +
            "FROM ingredient_category " +
            "ORDER BY Category_ID";

        try {
            conn = DBContext.getJDBCConnection(); // Use your project's connection method
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                CategoryDTO cat = new CategoryDTO(
                    rs.getString("Category_ID"),
                    rs.getString("Category_Name"),
                    rs.getString("Description"),
                    rs.getString("Category_Type")
                );
                list.add(cat);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
        return list;
    }

    // 2. Insert a new category, dynamically routing it to the correct table
    public boolean addCategory(CategoryDTO cat) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps = null;
        boolean isSuccess = false;

        try {
            conn = DBContext.getJDBCConnection();
            
            // Business Logic: Route to the correct table based on Type
            if ("Sản phẩm chính".equals(cat.getCategoryType())) {
                String sql = "INSERT INTO product_category (Category_ID, Category_Name, Description) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryId());
                ps.setString(2, cat.getCategoryName());
                ps.setString(3, cat.getDescription());
            } 
            else if ("Nguyên liệu".equals(cat.getCategoryType())) {
                String sql = "INSERT INTO ingredient_category (Category_ID, Category_Name) VALUES (?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryId());
                ps.setString(2, cat.getCategoryName());
                // Ingredients don't have descriptions in our schema
            }

            if (ps != null) {
                int rowsAffected = ps.executeUpdate();
                isSuccess = (rowsAffected > 0);
            }
        } finally {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
        return isSuccess;
    }
    
// 1. Get the total count (Now with Search & Filter support)
    public int getTotalCategoriesCount(String search, String filterType) throws SQLException, ClassNotFoundException {
        int total = 0;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String searchPattern = "%" + (search != null ? search : "") + "%";
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT COUNT(*) AS TotalCount FROM ( ");
        sql.append("SELECT Category_ID, Category_Name, 'Sản phẩm chính' AS Category_Type FROM product_category ");
        sql.append("UNION ALL ");
        sql.append("SELECT Category_ID, Category_Name, 'Nguyên liệu' AS Category_Type FROM ingredient_category ");
        sql.append(") AS combined ");
        sql.append("WHERE (Category_ID LIKE ? OR Category_Name LIKE ?) ");

        boolean hasFilter = (filterType != null && !filterType.isEmpty() && !filterType.equals("all"));
        if (hasFilter) {
            sql.append("AND Category_Type = ? ");
        }

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql.toString());
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            if (hasFilter) {
                ps.setString(3, filterType);
            }
            
            rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("TotalCount");
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
        return total;
    }

    // 2. Fetch pages (Now with Search & Filter support)
    public List<CategoryDTO> getAdminCategoriesByPage(int offset, int limit, String search, String filterType) throws SQLException, ClassNotFoundException {
        List<CategoryDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String searchPattern = "%" + (search != null ? search : "") + "%";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT Category_ID, Category_Name, Description, Category_Type FROM ( ");
        sql.append("SELECT Category_ID, Category_Name, Description, 'Sản phẩm chính' AS Category_Type FROM product_category ");
        sql.append("UNION ALL ");
        sql.append("SELECT Category_ID, Category_Name, NULL AS Description, 'Nguyên liệu' AS Category_Type FROM ingredient_category ");
        sql.append(") AS combined ");
        sql.append("WHERE (Category_ID LIKE ? OR Category_Name LIKE ?) ");

        boolean hasFilter = (filterType != null && !filterType.isEmpty() && !filterType.equals("all"));
        if (hasFilter) {
            sql.append("AND Category_Type = ? ");
        }
        sql.append("ORDER BY Category_ID LIMIT ? OFFSET ?");

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql.toString());
            
            int paramIndex = 1;
            ps.setString(paramIndex++, searchPattern);
            ps.setString(paramIndex++, searchPattern);
            if (hasFilter) {
                ps.setString(paramIndex++, filterType);
            }
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            rs = ps.executeQuery();
            while (rs.next()) {
                CategoryDTO cat = new CategoryDTO(
                    rs.getString("Category_ID"),
                    rs.getString("Category_Name"),
                    rs.getString("Description"),
                    rs.getString("Category_Type")
                );
                list.add(cat);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
        return list;
    }
    
    // 3. Delete a category
    public boolean deleteCategory(String categoryId) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        boolean isSuccess = false;

        try {
            conn = DBContext.getJDBCConnection();
            
            // Try deleting from product_category
            String sqlProduct = "DELETE FROM product_category WHERE Category_ID = ?";
            ps1 = conn.prepareStatement(sqlProduct);
            ps1.setString(1, categoryId);
            int row1 = ps1.executeUpdate();
            
            // Try deleting from ingredient_category
            String sqlIngredient = "DELETE FROM ingredient_category WHERE Category_ID = ?";
            ps2 = conn.prepareStatement(sqlIngredient);
            ps2.setString(1, categoryId);
            int row2 = ps2.executeUpdate();
            
            // If either of those queries successfully deleted a row, return true
            isSuccess = (row1 > 0 || row2 > 0);
            
        } finally {
            if (ps1 != null) ps1.close();
            if (ps2 != null) ps2.close();
            if (conn != null) conn.close();
        }
        return isSuccess;
    }
    
}
