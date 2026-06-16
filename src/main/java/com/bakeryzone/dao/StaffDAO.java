package com.bakeryzone.dao;

import com.bakeryzone.model.Staff;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {

    // 1. Hàm bốc 1 nhân viên theo ID phục vụ Form Sửa (Gộp thông tin từ 2 bảng staff và user)
    public Staff getStaffById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT s.Staff_ID, s.User_ID, s.Full_Name, s.Phone, s.Position, s.Is_Active_Staff, s.Created_At, "
                       + "u.Email, u.Password, u.Role_ID, u.Account_Status "
                       + "FROM `staff` s "
                       + "JOIN `user` u ON s.User_ID = u.User_ID WHERE s.Staff_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getString("Staff_ID"));
                s.setUserId(rs.getString("User_ID"));
                s.setFullName(rs.getString("Full_Name"));
                s.setPhone(rs.getString("Phone"));
                s.setPosition(rs.getString("Position"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                s.setCreatedAt(rs.getTimestamp("Created_At"));
                
                // Đập thêm các trường tài khoản được map từ bảng user sang
                s.setEmail(rs.getString("Email"));
                s.setPassword(rs.getString("Password"));
                s.setRoleId(rs.getString("Role_ID"));
                s.setAccountStatus(rs.getString("Account_Status"));
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    // 2. Hàm Thêm mới Nhân viên (Sử dụng TRANSACTION ghi dữ liệu đồng thời vào cả 2 bảng user và staff)
    public boolean insertStaff(Staff s) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psStaff = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false); // Bật chế độ quản lý giao dịch an toàn

            String genUserId = "USR_" + System.currentTimeMillis();
            String genStaffId = "STF_" + System.currentTimeMillis();

            // Bước A: Nhét dữ liệu đăng nhập cơ sở vào bảng `user` trước
            String sqlUser = "INSERT INTO `user` (User_ID, Email, Password, Role_ID, Is_Verified, Account_Status) "
                           + "VALUES (?, ?, ?, ?, 1, ?)";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, genUserId);
            psUser.setString(2, s.getEmail());
            psUser.setString(3, s.getPassword());
            psUser.setString(4, s.getRoleId()); // Gán quyền động gửi từ Form (ADMIN, STAFF, SHIPPER)
            psUser.setString(5, s.getAccountStatus());
            psUser.executeUpdate();

            // Bước B: Nhét dữ liệu thông tin nhân sự mở rộng vào bảng `staff`
            String sqlStaff = "INSERT INTO `staff` (Staff_ID, User_ID, Full_Name, Phone, Position, Is_Active_Staff) "
                            + "VALUES (?, ?, ?, ?, ?, ?)";
            psStaff = conn.prepareStatement(sqlStaff);
            psStaff.setString(1, genStaffId);
            psStaff.setString(2, genUserId);
            psStaff.setString(3, s.getFullName());
            psStaff.setString(4, s.getPhone());
            psStaff.setString(5, s.getPosition());
            psStaff.setBoolean(6, s.isIsActiveStaff());
            psStaff.executeUpdate();

            conn.commit(); // Hoàn tất thành công chuỗi lệnh
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            try { if (psUser != null) psUser.close(); if (psStaff != null) psStaff.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return false;
    }

    // 3. Hàm Cập nhật thông tin Nhân viên đồng bộ lên cả 2 bảng
    public boolean updateStaff(Staff s) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psStaff = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);

            // Bước A: Cập nhật thông tin bảng staff trước
            String sqlStaff = "UPDATE `staff` SET Full_Name = ?, Phone = ?, Position = ?, Is_Active_Staff = ? WHERE Staff_ID = ?";
            psStaff = conn.prepareStatement(sqlStaff);
            psStaff.setString(1, s.getFullName());
            psStaff.setString(2, s.getPhone());
            psStaff.setString(3, s.getPosition());
            psStaff.setBoolean(4, s.isIsActiveStaff());
            psStaff.setString(5, s.getStaffId());
            psStaff.executeUpdate();

            // Bước B: Cập nhật thông tin tài khoản (Email, Password, Quyền, Trạng thái) bên bảng user liên kết
            String sqlUser = "UPDATE `user` SET Email = ?, Password = ?, Role_ID = ?, Account_Status = ? WHERE User_ID = ?";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, s.getEmail());
            psUser.setString(2, s.getPassword());
            psUser.setString(3, s.getRoleId());
            psUser.setString(4, s.getAccountStatus());
            psUser.setString(5, s.getUserId());
            psUser.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            try { if (psUser != null) psUser.close(); if (psStaff != null) psStaff.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return false;
    }

    // 4. Hàm Xóa mềm nhân viên khỏi hệ thống (Đồng thời đổi Is_Active_Staff = 0 và Account_Status = 'Inactive')
    public boolean deleteStaff(String id) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psStaff = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);

            // Tắt cờ hoạt động nhân sự
            String sqlStaff = "UPDATE `staff` SET `Is_Active_Staff` = 0 WHERE `Staff_ID` = ?";
            psStaff = conn.prepareStatement(sqlStaff);
            psStaff.setString(1, id);
            psStaff.executeUpdate();

            // Khóa trạng thái tài khoản đăng nhập bên bảng user luôn
            String sqlUser = "UPDATE `user` u JOIN `staff` s ON u.User_ID = s.User_ID SET u.Account_Status = 'Inactive' WHERE s.Staff_ID = ?";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, id);
            psUser.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            try { if (psUser != null) psUser.close(); if (psStaff != null) psStaff.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return false;
    }

    // 5. Hàm check trùng email kết hợp bảng user
    public boolean checkEmailExist(String email, String staffId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT u.User_ID FROM `user` u WHERE u.Email = ?";
            if (staffId != null && !staffId.trim().isEmpty()) {
                sql += " AND u.User_ID NOT IN (SELECT User_ID FROM `staff` WHERE Staff_ID = ?)";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            if (staffId != null && !staffId.trim().isEmpty()) {
                ps.setString(2, staffId);
            }

            rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return false;
    }

    // 6. Hàm đếm tổng số nhân sự phục vụ phân trang (Chỉ quét các Role thuộc khối nhân sự nội bộ)
    public int getTotalStaffs(String keyword, String roleId, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM `staff` s JOIN `user` u ON s.User_ID = u.User_ID WHERE u.Role_ID IN ('ADMIN', 'STAFF', 'SHIPPER') AND s.Is_Active_Staff = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (s.Full_Name LIKE ? OR u.Email LIKE ? OR s.Phone LIKE ?)";
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND u.Role_ID = ?";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND u.Account_Status = ?";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                ps.setString(paramIndex++, roleId);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return 0;
    }

    // 7. Hàm tìm kiếm, lọc và phân trang đổ dữ liệu lên bảng quản trị Staff chính
    public List<Staff> searchAndFilterStaffs(String keyword, String roleId, String status, int pageIndex, int pageSize) {
        List<Staff> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT s.Staff_ID, s.User_ID, s.Full_Name, s.Phone, s.Position, s.Is_Active_Staff, s.Created_At, "
                       + "u.Email, u.Role_ID, u.Account_Status "
                       + "FROM `staff` s "
                       + "JOIN `user` u ON s.User_ID = u.User_ID "
                       + "WHERE u.Role_ID IN ('ADMIN', 'STAFF', 'SHIPPER') AND s.Is_Active_Staff = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (s.Full_Name LIKE ? OR u.Email LIKE ? OR s.Phone LIKE ?)";
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND u.Role_ID = ?";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND u.Account_Status = ?";
            }

            sql += " ORDER BY s.Created_At DESC LIMIT ? OFFSET ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                ps.setString(paramIndex++, roleId);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }

            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, (pageIndex - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getString("Staff_ID"));
                s.setUserId(rs.getString("User_ID"));
                s.setFullName(rs.getString("Full_Name"));
                s.setPhone(rs.getString("Phone"));
                s.setPosition(rs.getString("Position"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                s.setCreatedAt(rs.getTimestamp("Created_At"));
                
                // Map thông tin tài khoản user vào Object nhân sự để mang đi hiển thị
                s.setEmail(rs.getString("Email"));
                s.setRoleId(rs.getString("Role_ID"));
                s.setAccountStatus(rs.getString("Account_Status"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return list;
    }

    private void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (Exception e) { e.printStackTrace(); }
    }
}