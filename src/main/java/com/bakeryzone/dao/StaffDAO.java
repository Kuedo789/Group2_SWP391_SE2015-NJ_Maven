package com.bakeryzone.dao;

import com.bakeryzone.model.Staff;
import com.bakeryzone.utils.DBContext; // Hướng đúng đường dẫn DBContext của nhóm bạn
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {

    public Staff getStaffById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM `staff` WHERE `Staff_ID` = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getString("Staff_ID"));
                s.setFullName(rs.getString("Full_Name"));
                s.setEmail(rs.getString("Email"));
                s.setPassword(rs.getString("Password"));
                s.setPhone(rs.getString("Phone"));
                s.setRoleId(rs.getString("Role_ID"));
                s.setAccountStatus(rs.getString("Account_Status"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    // 2. Hàm Thêm mới Nhân viên vào Database
    public boolean insertStaff(Staff s) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "INSERT INTO `staff` (Staff_ID, Full_Name, Email, Password, Phone, Role_ID, Account_Status, Is_Active_Staff) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            String generatedId = (s.getStaffId() == null || s.getStaffId().trim().isEmpty())
                    ? "STF" + System.currentTimeMillis()
                    : s.getStaffId();

            ps.setString(1, generatedId);
            ps.setString(2, s.getFullName());
            ps.setString(3, s.getEmail());
            ps.setString(4, s.getPassword());
            ps.setString(5, s.getPhone());
            ps.setString(6, s.getRoleId());
            ps.setString(7, s.getAccountStatus());
            ps.setBoolean(8, s.isIsActiveStaff());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    // 3. Hàm Cập nhật thông tin nhân viên
    public boolean updateStaff(Staff s) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `staff` SET Full_Name = ?, Email = ?, Password = ?, Phone = ?, Role_ID = ?, Account_Status = ? WHERE Staff_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, s.getFullName());
            ps.setString(2, s.getEmail());
            ps.setString(3, s.getPassword());
            ps.setString(4, s.getPhone());
            ps.setString(5, s.getRoleId());
            ps.setString(6, s.getAccountStatus());
            ps.setString(7, s.getStaffId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    // 4. Hàm Xóa nhân viên khỏi hệ thống
    public boolean deleteStaff(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `staff` SET `Is_Active_Staff` = 0 WHERE `Staff_ID` = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    // 5. Hàm check trùng email trong bảng staff
    public boolean checkEmailExist(String email, String staffId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM `staff` WHERE Email = ?";
            if (staffId != null) {
                sql += " AND Staff_ID != ?";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            if (staffId != null) {
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

    private void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int getTotalStaffs(String keyword, String roleId, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM `staff` WHERE `Is_Active_Staff` = 1";
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (Full_Name LIKE ? OR Email LIKE ?)";
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND Role_ID = ?";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND Account_Status = ?";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
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

    // 7. Hàm tìm kiếm, lọc và phân trang nhân viên (Đổ ra bảng hiển thị chính)
    public List<Staff> searchAndFilterStaffs(String keyword, String roleId, String status, int pageIndex, int pageSize) {
        List<Staff> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT * FROM `staff` WHERE `Is_Active_Staff` = 1";
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (Full_Name LIKE ? OR Email LIKE ?)";
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND Role_ID = ?";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND Account_Status = ?";
            }

            sql += " LIMIT ? OFFSET ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
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
                s.setFullName(rs.getString("Full_Name"));
                s.setEmail(rs.getString("Email"));
                s.setPassword(rs.getString("Password"));
                s.setPhone(rs.getString("Phone"));
                s.setRoleId(rs.getString("Role_ID"));
                s.setAccountStatus(rs.getString("Account_Status"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return list;
    }
}
