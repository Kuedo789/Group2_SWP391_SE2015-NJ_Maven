package com.bakeryzone.dao;

import com.bakeryzone.model.Staff;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {

    public Staff getStaffById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT s.Staff_ID, s.User_ID, s.Full_Name, s.Phone, s.Position, s.Is_Active_Staff, s.Managed_Zone, "
                    + "u.Email, u.Password, u.Role_ID, u.Account_Status, u.Is_Verified "
                    + "FROM `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "WHERE s.Staff_ID = ?";
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
                s.setManagedZone(rs.getString("Managed_Zone"));

                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setVerified(rs.getBoolean("Is_Verified"));

                s.setUser(u); // Nhúng user vào staff
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    public boolean insertStaff(Staff s) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psStaff = null;
        boolean isSuccess = false;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false); // Transaction

            // 1. Insert vào bảng User
            String sqlUser = "INSERT INTO `user` (User_ID, Email, Password, Role_ID, Account_Status, Is_Verified) VALUES (?, ?, ?, ?, ?, ?)";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, s.getUser().getUserId());
            psUser.setString(2, s.getUser().getEmail());
            psUser.setString(3, s.getUser().getPassword());
            psUser.setString(4, s.getUser().getRoleId()); // Lấy Role từ object User
            psUser.setString(5, s.getUser().getAccountStatus() != null ? s.getUser().getAccountStatus() : "Active");
            psUser.setBoolean(6, s.getUser().isVerified());
            psUser.executeUpdate();

            // 2. Insert vào bảng Staff
            String sqlStaff = "INSERT INTO `staff` (Staff_ID, User_ID, Full_Name, Phone, Position, Managed_Zone, Is_Active_Staff) VALUES (?, ?, ?, ?, ?, ?, 1)";
            psStaff = conn.prepareStatement(sqlStaff);
            psStaff.setString(1, s.getStaffId());
            psStaff.setString(2, s.getUser().getUserId());
            psStaff.setString(3, s.getFullName());
            psStaff.setString(4, s.getPhone());
            psStaff.setString(5, s.getPosition());
            psStaff.setString(6, s.getManagedZone() != null ? s.getManagedZone() : "Toàn thành phố");
            psStaff.executeUpdate();

            conn.commit();
            isSuccess = true;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            close(null, psUser, null);
            close(conn, psStaff, null);
        }
        return isSuccess;
    }

    public boolean updateStaff(Staff s) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "SET s.Full_Name = ?, s.Phone = ?, s.Position = ?, s.Managed_Zone = ?, u.Email = ?, u.Password = ?, u.Role_ID = ?, u.Account_Status = ? "
                    + "WHERE s.Staff_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, s.getFullName());
            ps.setString(2, s.getPhone());
            ps.setString(3, s.getPosition());
            ps.setString(4, s.getManagedZone() != null ? s.getManagedZone() : "Toàn thành phố");
            ps.setString(5, s.getUser().getEmail());
            ps.setString(6, s.getUser().getPassword());
            ps.setString(7, s.getUser().getRoleId());
            ps.setString(8, s.getUser().getAccountStatus());
            ps.setString(9, s.getStaffId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public boolean deleteStaff(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "SET u.Is_Verified = 0, s.Is_Active_Staff = 0 "
                    + "WHERE s.Staff_ID = ?";
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

    public boolean checkEmailExist(String email, String staffId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT Email FROM `user` WHERE Email = ?";

            if (staffId != null) {
                sql += " AND User_ID != (SELECT User_ID FROM `staff` WHERE Staff_ID = ?)";
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

    public int getTotalStaffs(String keyword, String roleId, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "WHERE u.Is_Verified = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (s.Full_Name LIKE ? OR u.Email LIKE ?)";
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

    public List<Staff> searchAndFilterStaffs(String keyword, String roleId, String status, int pageIndex, int pageSize) {
        List<Staff> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT s.Staff_ID, s.User_ID, s.Full_Name, s.Phone, s.Position, s.Is_Active_Staff, s.Managed_Zone, "
                    + "u.Email, u.Password, u.Role_ID, u.Account_Status, u.Is_Verified "
                    + "FROM `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "WHERE u.Is_Verified = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (s.Full_Name LIKE ? OR u.Email LIKE ?)";
            }
            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND u.Role_ID = ?";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND u.Account_Status = ?";
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
                s.setUserId(rs.getString("User_ID"));
                s.setFullName(rs.getString("Full_Name"));
                s.setPhone(rs.getString("Phone"));
                s.setPosition(rs.getString("Position"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                s.setManagedZone(rs.getString("Managed_Zone"));

                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setVerified(rs.getBoolean("Is_Verified"));

                s.setUser(u);
                list.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return list;
    }

    public Staff getStaffByUserId(String userId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT s.Staff_ID, s.User_ID, s.Full_Name, s.Phone, s.Position, s.Is_Active_Staff, s.Managed_Zone, "
                    + "u.Email, u.Password, u.Role_ID, u.Account_Status, u.Is_Verified "
                    + "FROM `staff` s "
                    + "JOIN `user` u ON s.User_ID = u.User_ID "
                    + "WHERE s.User_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Staff s = new Staff();
                s.setStaffId(rs.getString("Staff_ID"));
                s.setUserId(rs.getString("User_ID"));
                s.setFullName(rs.getString("Full_Name"));
                s.setPhone(rs.getString("Phone"));
                s.setPosition(rs.getString("Position"));
                s.setIsActiveStaff(rs.getBoolean("Is_Active_Staff"));
                s.setManagedZone(rs.getString("Managed_Zone"));

                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setVerified(rs.getBoolean("Is_Verified"));

                s.setUser(u);
                return s;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    public boolean updateShipperStatusAndZone(String staffId, boolean isActive, String workingZoneId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            String sql;
            if (workingZoneId == null || workingZoneId.trim().isEmpty()) {
                sql = "UPDATE `staff` SET Is_Active_Staff = ? WHERE Staff_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, isActive ? 1 : 0);
                ps.setString(2, staffId);
            } else {
                sql = "UPDATE `staff` SET Is_Active_Staff = ?, Managed_Zone = ? WHERE Staff_ID = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, isActive ? 1 : 0);
                ps.setString(2, workingZoneId);
                ps.setString(3, staffId);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
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
}
