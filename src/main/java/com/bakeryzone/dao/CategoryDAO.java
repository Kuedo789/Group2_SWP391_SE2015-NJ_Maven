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

        String sql
                = "SELECT Category_ID, Category_Name, Description, "
                + "CASE WHEN Category_ID LIKE 'CAT-ACC-%' THEN 'Phụ kiện' ELSE 'Sản phẩm chính' END AS Category_Type, enable "
                + "FROM product_category "
                + "UNION ALL "
                + "SELECT Category_ID, Category_Name, NULL AS Description, 'Nguyên liệu' AS Category_Type, enable "
                + "FROM ingredient_category "
                + "ORDER BY Category_ID";

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                CategoryDTO cat = new CategoryDTO(
                        rs.getString("Category_ID"),
                        rs.getString("Category_Name"),
                        rs.getString("Description"),
                        rs.getString("Category_Type"),
                        rs.getBoolean("enable") // ADDED THIS LINE
                );
                list.add(cat);
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
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

            // Route "Sản phẩm chính" and "Phụ kiện" to product_category
            if ("Sản phẩm chính".equals(cat.getCategoryType()) || "Phụ kiện".equals(cat.getCategoryType())) {
                String sql = "INSERT INTO product_category (Category_ID, Category_Name, Description) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryId());
                ps.setString(2, cat.getCategoryName());
                ps.setString(3, cat.getDescription());
            } else if ("Nguyên liệu".equals(cat.getCategoryType())) {
                String sql = "INSERT INTO ingredient_category (Category_ID, Category_Name) VALUES (?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryId());
                ps.setString(2, cat.getCategoryName());
            }

            if (ps != null) {
                int rowsAffected = ps.executeUpdate();
                isSuccess = (rowsAffected > 0);
            }
        } finally {
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return isSuccess;
    }

// 3. Get the total counts (Returns an array: [Total, Active, Disabled])
    public int[] getTotalCategoriesCount(String search, String filterType) throws SQLException, ClassNotFoundException {
        int[] counts = new int[3]; // [0] = Total, [1] = Active, [2] = Disabled
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String searchPattern = "%" + (search != null ? search : "") + "%";

        StringBuilder sql = new StringBuilder();
        // Using COALESCE to ensure it returns 0 instead of NULL if the table is totally empty
        sql.append("SELECT COUNT(*) AS TotalCount, ");
        sql.append("COALESCE(SUM(CASE WHEN enable = 1 THEN 1 ELSE 0 END), 0) AS ActiveCount, ");
        sql.append("COALESCE(SUM(CASE WHEN enable = 0 THEN 1 ELSE 0 END), 0) AS DisabledCount ");
        sql.append("FROM ( ");
        sql.append("SELECT Category_ID, Category_Name, CASE WHEN Category_ID LIKE 'CAT-ACC-%' THEN 'Phụ kiện' ELSE 'Sản phẩm chính' END AS Category_Type, enable FROM product_category ");
        sql.append("UNION ALL ");
        sql.append("SELECT Category_ID, Category_Name, 'Nguyên liệu' AS Category_Type, enable FROM ingredient_category ");
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
                counts[0] = rs.getInt("TotalCount");
                counts[1] = rs.getInt("ActiveCount");
                counts[2] = rs.getInt("DisabledCount");
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return counts;
    }

    // 4. Fetch pages (Now with Search & Filter support)
    public List<CategoryDTO> getAdminCategoriesByPage(int offset, int limit, String search, String filterType) throws SQLException, ClassNotFoundException {
        List<CategoryDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String searchPattern = "%" + (search != null ? search : "") + "%";

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT Category_ID, Category_Name, Description, Category_Type, enable FROM ( ");
        sql.append("SELECT Category_ID, Category_Name, Description, CASE WHEN Category_ID LIKE 'CAT-ACC-%' THEN 'Phụ kiện' ELSE 'Sản phẩm chính' END AS Category_Type, enable FROM product_category ");
        sql.append("UNION ALL ");
        sql.append("SELECT Category_ID, Category_Name, NULL AS Description, 'Nguyên liệu' AS Category_Type, enable FROM ingredient_category ");
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
                        rs.getString("Category_Type"),
                        rs.getBoolean("enable") // Pull the soft-delete status
                );
                list.add(cat);
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return list;
    }

// 5. Soft Delete a category (Sets enable = 0 instead of destroying data)
    public boolean deleteCategory(String categoryId) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        boolean isSuccess = false;

        try {
            conn = DBContext.getJDBCConnection();

            // Soft delete from product_category
            String sqlProduct = "UPDATE product_category SET enable = 0 WHERE Category_ID = ?";
            ps1 = conn.prepareStatement(sqlProduct);
            ps1.setString(1, categoryId);
            int row1 = ps1.executeUpdate();

            // Soft delete from ingredient_category
            String sqlIngredient = "UPDATE ingredient_category SET enable = 0 WHERE Category_ID = ?";
            ps2 = conn.prepareStatement(sqlIngredient);
            ps2.setString(1, categoryId);
            int row2 = ps2.executeUpdate();

            // If either updated successfully, return true
            isSuccess = (row1 > 0 || row2 > 0);

        } finally {
            if (ps1 != null) {
                ps1.close();
            }
            if (ps2 != null) {
                ps2.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return isSuccess;
    }

// 6. Fetch a single category by ID (Searches both tables)
    public CategoryDTO getCategoryById(String categoryId) throws SQLException, ClassNotFoundException {
        CategoryDTO cat = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql
                = "SELECT Category_ID, Category_Name, Description, CASE WHEN Category_ID LIKE 'CAT-ACC-%' THEN 'Phụ kiện' ELSE 'Sản phẩm chính' END AS Category_Type, enable FROM product_category WHERE Category_ID = ? "
                + "UNION ALL "
                + "SELECT Category_ID, Category_Name, NULL AS Description, 'Nguyên liệu' AS Category_Type, enable FROM ingredient_category WHERE Category_ID = ?";

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, categoryId);
            ps.setString(2, categoryId);
            rs = ps.executeQuery();

            if (rs.next()) {
                cat = new CategoryDTO(
                        rs.getString("Category_ID"),
                        rs.getString("Category_Name"),
                        rs.getString("Description"),
                        rs.getString("Category_Type"),
                        rs.getBoolean("enable") // ADDED THIS LINE
                );
            }
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return cat;
    }

    // 7. Update an existing category
    public boolean updateCategory(CategoryDTO cat) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps = null;
        boolean isSuccess = false;

        try {
            conn = DBContext.getJDBCConnection();

            // Route "Sản phẩm chính" and "Phụ kiện" to product_category
            if ("Sản phẩm chính".equals(cat.getCategoryType()) || "Phụ kiện".equals(cat.getCategoryType())) {
                String sql = "UPDATE product_category SET Category_Name = ?, Description = ? WHERE Category_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryName());
                ps.setString(2, cat.getDescription());
                ps.setString(3, cat.getCategoryId());
            } else if ("Nguyên liệu".equals(cat.getCategoryType())) {
                String sql = "UPDATE ingredient_category SET Category_Name = ? WHERE Category_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, cat.getCategoryName());
                ps.setString(2, cat.getCategoryId());
            }

            if (ps != null) {
                int rowsAffected = ps.executeUpdate();
                isSuccess = (rowsAffected > 0);
            }
        } finally {
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return isSuccess;
    }

    //8. Check if a Category ID already exists in EITHER table
    public boolean isCategoryIdExists(String categoryId) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean exists = false;

        String sql
                = "SELECT 1 FROM product_category WHERE Category_ID = ? "
                + "UNION ALL "
                + "SELECT 1 FROM ingredient_category WHERE Category_ID = ?";

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, categoryId);
            ps.setString(2, categoryId);
            rs = ps.executeQuery();

            // If rs.next() is true, it means it found at least one match!
            exists = rs.next();
        } finally {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return exists;
    }

    //9. Restore a soft-deleted category
    public boolean restoreCategory(String categoryId) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        boolean isSuccess = false;

        try {
            conn = DBContext.getJDBCConnection();

            String sqlProduct = "UPDATE product_category SET enable = 1 WHERE Category_ID = ?";
            ps1 = conn.prepareStatement(sqlProduct);
            ps1.setString(1, categoryId);
            int row1 = ps1.executeUpdate();

            String sqlIngredient = "UPDATE ingredient_category SET enable = 1 WHERE Category_ID = ?";
            ps2 = conn.prepareStatement(sqlIngredient);
            ps2.setString(1, categoryId);
            int row2 = ps2.executeUpdate();

            isSuccess = (row1 > 0 || row2 > 0);
        } finally {
            if (ps1 != null) {
                ps1.close();
            }
            if (ps2 != null) {
                ps2.close();
            }
            if (conn != null) {
                conn.close();
            }
        }
        return isSuccess;
    }
}
