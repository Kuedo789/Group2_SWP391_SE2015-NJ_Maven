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

    // 🟢 1. LẤY TOÀN BỘ ROLE (ĐỘNG KHÔNG HARDCODE)
    // Giúp hệ thống tự nhận diện nếu sau này CRUD thêm vai trò mới (VD: STAFF_QUAN_LY)
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
        // Bỏ điều kiện WHERE s.Screen_ID IN (...) để lấy toàn bộ tính năng ra màn hình phân quyền
        String sql = "SELECT s.Screen_ID, s.Screen_Name, s.Endpoint_URL, "
                + "CASE WHEN rp.Role_ID IS NOT NULL THEN 1 ELSE 0 END as is_active "
                + "FROM screen_permission s "
                + "LEFT JOIN role_permission rp ON s.Screen_ID = rp.Screen_ID AND rp.Role_ID = ? "
                + "ORDER BY FIELD(s.Screen_ID, "
                + "'FEAT_DASHBOARD_VIEW', 'FEAT_ORDER_VIEW', 'FEAT_ORDER_DETAIL', 'FEAT_ORDER_UPDATE', "
                + "'FEAT_PROD_VIEW', 'FEAT_PROD_DETAIL', 'FEAT_PROD_ADD', 'FEAT_PROD_EDIT', 'FEAT_PROD_UPDATE', 'FEAT_PROD_DEL', "
                + "'FEAT_CAT_VIEW', 'FEAT_CAT_ADD', 'FEAT_CAT_EDIT', 'FEAT_CAT_DEL', 'FEAT_CAT_RESTORE', "
                + "'FEAT_ING_VIEW', 'FEAT_ING_ADD', 'FEAT_ING_EDIT', 'FEAT_ING_UPDATE', 'FEAT_ING_DEL', "
                + "'FEAT_UNIT_VIEW', 'FEAT_UNIT_ADD', 'FEAT_UNIT_EDIT', 'FEAT_UNIT_UPDATE', 'FEAT_UNIT_DEL', "
                + "'FEAT_ATTR_VIEW', 'FEAT_ATTR_ADD', "
                + "'FEAT_CUST_VIEW', 'FEAT_CUST_ADD', 'FEAT_CUST_EDIT', 'FEAT_CUST_DEL', "
                + "'FEAT_REV_VIEW', 'FEAT_REV_DETAIL', 'FEAT_REV_UPDATE', "
                + "'FEAT_STAFF_VIEW', 'FEAT_STAFF_ADD', 'FEAT_STAFF_EDIT', 'FEAT_STAFF_DEL', "
                + "'FEAT_ROLE_VIEW', 'FEAT_SETTING_MNG')";

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

    public boolean togglePermission(String roleId, String screenId, String action) {
        // Đảm bảo tên cột khớp 100% chữ hoa chữ thường với DB: Role_ID, Screen_ID
        String sql = action.equalsIgnoreCase("on")
                ? "INSERT IGNORE INTO role_permission (Role_ID, Screen_ID) VALUES (?, ?)"
                : "DELETE FROM role_permission WHERE Role_ID = ? AND Screen_ID = ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, screenId);

            int rowsAffected = ps.executeUpdate();
            // Nếu action là 'off' (DELETE), rowsAffected > 0 tức là đã xóa thành công.
            // Nếu action là 'on' (INSERT IGNORE), rowsAffected > 0 tức là đã chèn thành công.
            // Lưu ý: INSERT IGNORE nếu trùng khóa sẽ trả về 0, nên ta có thể linh động check rowsAffected >= 0 tùy logic, 
            // nhưng an toàn nhất đối với DELETE là rowsAffected > 0.
            return true;
        } catch (Exception e) {
            System.err.println("🔴 LỖI SQL PHÂN QUYỀN TRÊN DB:");
            e.printStackTrace();
            return false;
        }
    }

    // 🟢 4. BỘ LỌC SO KHỚP URL (CHECK PERMISSION)
    // Quét logic động để Filter chặn/cho phép người dùng truy cập dựa theo dữ liệu DB thật
    public boolean checkPermission(String roleId, String currentUrl) {
        String sql = "SELECT COUNT(*) FROM role_permission rp "
                + "JOIN screen_permission s ON rp.Screen_ID = s.Screen_ID "
                + "WHERE rp.Role_ID = ? AND ? LIKE CONCAT(s.Endpoint_URL, '%')";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, currentUrl);
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

    public boolean checkUrlPermission(String roleId, String targetUrl) {
        return checkPermission(roleId, targetUrl);
    }
}
