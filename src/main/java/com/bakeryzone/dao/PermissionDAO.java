package com.bakeryzone.dao;

import com.bakeryzone.model.Role;
import com.bakeryzone.model.ScreenPermission;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PermissionDAO {

    static {
        try (Connection conn = DBContext.getJDBCConnection()) {
            if (conn != null) {
                // 1. Insert FEAT_PROD_BOM_VIEW screen permission
                String sqlScreen = "INSERT IGNORE INTO screen_permission (Screen_ID, Screen_Name, Endpoint_URL) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlScreen)) {
                    ps.setString(1, "FEAT_PROD_BOM_VIEW");
                    ps.setString(2, "Xem định lượng nguyên liệu bánh");
                    ps.setString(3, "/admin/product?action=bom");
                    ps.executeUpdate();
                }
                
                // 2. Grant to ADMIN and STAFF
                String sqlRole = "INSERT IGNORE INTO role_permission (Role_ID, Screen_ID) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlRole)) {
                    ps.setString(1, "ADMIN");
                    ps.setString(2, "FEAT_PROD_BOM_VIEW");
                    ps.executeUpdate();
                    
                    ps.setString(1, "STAFF");
                    ps.setString(2, "FEAT_PROD_BOM_VIEW");
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT Role_ID, Role_Name FROM role";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Role(rs.getString("Role_ID")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<ScreenPermission> getScreensWithStatus(String roleId) {
        List<ScreenPermission> list = new ArrayList<>();
        String fieldsOrder = "'FEAT_DASHBOARD_VIEW', 'FEAT_ORDER_VIEW', 'FEAT_ORDER_DETAIL', 'FEAT_ORDER_UPDATE', "
                + "'FEAT_PROD_VIEW', 'FEAT_PROD_DETAIL', 'FEAT_PROD_ADD', 'FEAT_PROD_EDIT', 'FEAT_PROD_UPDATE', 'FEAT_PROD_DEL', "
                + "'FEAT_CAT_VIEW', 'FEAT_CAT_ADD', 'FEAT_CAT_EDIT', 'FEAT_CAT_DEL', 'FEAT_CAT_RESTORE', "
                + "'FEAT_ING_VIEW', 'FEAT_ING_ADD', 'FEAT_ING_EDIT', 'FEAT_ING_UPDATE', 'FEAT_ING_DEL', "
                + "'FEAT_UNIT_VIEW', 'FEAT_UNIT_ADD', 'FEAT_UNIT_EDIT', 'FEAT_UNIT_UPDATE', 'FEAT_UNIT_DEL', "
                + "'FEAT_ATTR_VIEW', 'FEAT_ATTR_ADD', "
                + "'FEAT_CUST_VIEW', 'FEAT_CUST_ADD', 'FEAT_CUST_EDIT', 'FEAT_CUST_DEL', "
                + "'FEAT_REV_VIEW', 'FEAT_REV_DETAIL', 'FEAT_REV_UPDATE', "
                + "'FEAT_BLOG_VIEW', 'FEAT_BLOG_DETAIL', 'FEAT_BLOG_ADD', 'FEAT_BLOG_EDIT', 'FEAT_BLOG_UPDATE', 'FEAT_BLOG_DEL', "
                + "'FEAT_STAFF_VIEW', 'FEAT_STAFF_ADD', 'FEAT_STAFF_EDIT', 'FEAT_STAFF_DEL', "
                + "'FEAT_ROLE_VIEW', 'FEAT_SETTING_MNG', 'FEAT_VOUCHER_VIEW', 'FEAT_VOUCHER_ADD', 'FEAT_VOUCHER_UPDATE', 'FEAT_VOUCHER_TOGGLE', 'FEAT_VOUCHER_DEL'";

        String sql = "SELECT s.Screen_ID, s.Screen_Name, s.Endpoint_URL, "
                + "CASE WHEN rp.Role_ID IS NOT NULL THEN 1 ELSE 0 END as is_active "
                + "FROM screen_permission s "
                + "LEFT JOIN role_permission rp ON s.Screen_ID = rp.Screen_ID AND rp.Role_ID = ? "
                + "WHERE s.Screen_Name NOT LIKE '[HIDDEN]%' "
                + "ORDER BY FIELD(s.Screen_ID, " + fieldsOrder + ") = 0, "
                + "FIELD(s.Screen_ID, " + fieldsOrder + ") ASC, "
                + "s.Screen_Name ASC";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ScreenPermission(
                            rs.getString("Screen_ID"),
                            rs.getString("Screen_Name"),
                            rs.getString("Endpoint_URL"),
                            rs.getInt("is_active") == 1
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertScreen(String screenId, String screenName, String endpointUrl) {
        String sql = "INSERT INTO `screen_permission` (Screen_ID, Screen_Name, Endpoint_URL) VALUES (?, ?, ?)";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, screenId.trim().toUpperCase());
            ps.setString(2, screenName.trim());
            ps.setString(3, endpointUrl.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateScreen(String screenId, String screenName, String endpointUrl) {
        String sql = "UPDATE `screen_permission` SET Screen_Name = ?, Endpoint_URL = ? WHERE Screen_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, screenName.trim());
            ps.setString(2, endpointUrl.trim());
            ps.setString(3, screenId.trim());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteScreen(String screenId) {
        Connection conn = null;
        PreparedStatement psRolePerm = null;
        PreparedStatement psScreen = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);

            String sqlRolePerm = "DELETE FROM `role_permission` WHERE Screen_ID = ?";
            psRolePerm = conn.prepareStatement(sqlRolePerm);
            psRolePerm.setString(1, screenId);
            psRolePerm.executeUpdate();

            String sqlScreen = "UPDATE `screen_permission` SET Screen_Name = CONCAT('[HIDDEN]', Screen_Name) WHERE Screen_ID = ?";
            psScreen = conn.prepareStatement(sqlScreen);
            psScreen.setString(1, screenId);
            psScreen.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (psRolePerm != null) {
                    psRolePerm.close();
                }
                if (psScreen != null) {
                    psScreen.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
    }

    public boolean togglePermission(String roleId, String screenId, String action) {
        String sql = action.equalsIgnoreCase("on")
                ? "INSERT IGNORE INTO role_permission (Role_ID, Screen_ID) VALUES (?, ?)"
                : "DELETE FROM role_permission WHERE Role_ID = ? AND Screen_ID = ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, screenId);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

   public boolean checkPermission(String roleId, String currentUrl) {
    // ĐỔI CHIỀU SO KHỚP: Đảm bảo kiểm tra xem URL hiện tại có chứa hoặc bắt đầu bằng Endpoint tĩnh trong DB hay không.
    // Sử dụng toán tử LIKE chuẩn hóa giúp loại bỏ hoàn toàn lỗi chặn 403 do lệch tham số Query String (?action=...)
    String sql = "SELECT COUNT(*) FROM role_permission rp "
            + "JOIN screen_permission s ON rp.Screen_ID = s.Screen_ID "
            + "WHERE UPPER(TRIM(rp.Role_ID)) = UPPER(TRIM(?)) "
            + "AND (LOWER(TRIM(?)) LIKE CONCAT(LOWER(TRIM(s.Endpoint_URL)), '%') "
            + "OR LOWER(TRIM(s.Endpoint_URL)) LIKE CONCAT(LOWER(TRIM(?)), '%'))";

    try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, roleId);
        ps.setString(2, currentUrl);
        ps.setString(3, currentUrl); // Truyền tham số thứ 3 phục vụ kiểm tra chiều ngược lại

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("--> [DEBUG AUTH] Role: " + roleId + " | URL: " + currentUrl + " | Match Count: " + count);
                return count > 0;
            }
        }
    } catch (Exception e) {
        System.err.println("🔴 LỖI TẠI CHECK PERMISSION DAO:");
        e.printStackTrace();
    }
    return false;
}

    public boolean checkUrlPermission(String roleId, String targetUrl) {
        return checkPermission(roleId, targetUrl);
    }
}

