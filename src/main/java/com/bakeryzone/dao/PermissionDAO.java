/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.dao;

import com.bakeryzone.model.Role;
import com.bakeryzone.model.ScreenPermission;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Asus
 */
public class PermissionDAO {

    // 1. Lấy danh sách các Role nội bộ để làm thanh Tab chọn trên giao diện
    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT Role_ID FROM role WHERE Role_ID IN ('ADMIN', 'STAFF', 'SHIPPER')";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Role(rs.getString("Role_ID")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 2. Lấy thông tin 3 màn hình mục tiêu kèm trạng thái Bật/Tắt của từng Role dựa trên JOIN bảng công nghệ
    public List<ScreenPermission> getScreensWithStatus(String roleId) {
        List<ScreenPermission> list = new ArrayList<>();
        String sql = "SELECT s.Screen_ID, s.Screen_Name, s.Endpoint_URL, "
                + "CASE WHEN rp.Role_ID IS NOT NULL THEN 1 ELSE 0 END as is_active "
                + "FROM screen_permission s "
                + "LEFT JOIN role_permission rp ON s.Screen_ID = rp.Screen_ID AND rp.Role_ID = ? "
                + "WHERE s.Screen_ID IN ('SCR_DASHBOARD', 'SCR_REVIEW', 'SCR_USER', 'SCR_CUSTOMER')";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new ScreenPermission(
                            rs.getString("Screen_ID"),
                            rs.getString("Screen_Name"),
                            rs.getString("Endpoint_URL"),
                            rs.getInt("is_active") == 1 // Trả về true nếu bản ghi có tồn tại trong role_permission
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. Thực thi hành động bấm nút: Bật (ON) thì nạp vào bảng liên kết, Tắt (OFF) thì xóa khỏi bảng liên kết
    public void togglePermission(String roleId, String screenId, String action) {
        String sql = action.equalsIgnoreCase("on")
                ? "INSERT IGNORE INTO role_permission (Role_ID, Screen_ID) VALUES (?, ?)"
                : "DELETE FROM role_permission WHERE Role_ID = ? AND Screen_ID = ?";

        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, screenId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean checkPermission(String roleId, String currentUrl) {
        // Câu lệnh quét xem cặp (Role_ID, URL) có đang được bật ON (tồn tại trong bảng liên kết) không
        String sql = "SELECT COUNT(*) FROM role_permission rp "
                + "JOIN screen_permission s ON rp.Screen_ID = s.Screen_ID "
                + "WHERE rp.Role_ID = ? AND ? LIKE CONCAT(s.Endpoint_URL, '%')";
        try (Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, currentUrl);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0; // Trả về true nếu COUNT > 0 (Trạng thái ON)
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // Mặc định không tìm thấy bản ghi liên kết là TẮT (Trạng thái OFF)
    }
}
