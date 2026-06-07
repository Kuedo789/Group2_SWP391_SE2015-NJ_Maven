package com.bakeryzone.dao;

import com.bakeryzone.model.User;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.sql.Timestamp;

public class UserDAO {

    // Hàm map ResultSet sang User để tránh lặp code
    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();

        u.setUserId(rs.getString("User_ID"));
        u.setFullName(rs.getString("Full_Name"));
        u.setEmail(rs.getString("Email"));
        u.setPassword(rs.getString("Password"));
        u.setPhone(rs.getString("Phone"));
        u.setRoleId(rs.getString("Role_ID"));

        try {
            u.setRoleName(rs.getString("Role_Name"));
        } catch (Exception ignored) {
        }

        u.setVerified(rs.getBoolean("Is_Verified"));
        u.setOtpCode(rs.getString("OTP_Code"));
        u.setOtpExpiry(rs.getTimestamp("OTP_Expiry"));
        u.setProvider(rs.getString("Provider"));
        u.setProviderId(rs.getString("Provider_ID"));
        u.setAccountStatus(rs.getString("Account_Status"));
        u.setActiveStaff(rs.getBoolean("Is_Active_Staff"));

        return u;
    }

    // Tạo User_ID nếu chưa có
    private String generateUserId(String roleId) {
        String prefix = "U";

        if ("CUS".equalsIgnoreCase(roleId)) {
            prefix = "CUS";
        } else if ("STAFF".equalsIgnoreCase(roleId)) {
            prefix = "STAFF";
        } else if ("ADMIN".equalsIgnoreCase(roleId)) {
            prefix = "ADMIN";
        } else if ("SHIPPER".equalsIgnoreCase(roleId)) {
            prefix = "SHIP";
        }

        return prefix + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    // Hàm lấy toàn bộ danh sách user kèm role tương ứng
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT "
                    + "u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                    + "u.Role_ID, r.Role_Name, "
                    + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                    + "u.Provider, u.Provider_ID, "
                    + "u.Account_Status, u.Is_Active_Staff "
                    + "FROM `user` u "
                    + "JOIN `role` r ON u.Role_ID = r.Role_ID";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                User u = mapUser(rs);
                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    // Hàm thêm mới 1 tài khoản
    public void insertUser(User user) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            if (user.getUserId() == null || user.getUserId().trim().isEmpty()) {
                user.setUserId(generateUserId(user.getRoleId()));
            }

            if (user.getProvider() == null || user.getProvider().trim().isEmpty()) {
                user.setProvider("LOCAL");
            }

            if (user.getAccountStatus() == null || user.getAccountStatus().trim().isEmpty()) {
                user.setAccountStatus("Active");
            }

            boolean activeStaff = "ADMIN".equalsIgnoreCase(user.getRoleId())
                    || "STAFF".equalsIgnoreCase(user.getRoleId())
                    || "SHIPPER".equalsIgnoreCase(user.getRoleId());

            String sql = "INSERT INTO `user` "
                    + "(User_ID, Full_Name, Email, Password, Phone, Role_ID, "
                    + "Is_Verified, OTP_Code, OTP_Expiry, Provider, Provider_ID, "
                    + "Account_Status, Is_Active_Staff) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getUserId());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRoleId());
            ps.setBoolean(7, user.isVerified());
            ps.setString(8, user.getOtpCode());
            ps.setTimestamp(9, user.getOtpExpiry());
            ps.setString(10, user.getProvider());
            ps.setString(11, user.getProviderId());
            ps.setString(12, user.getAccountStatus());
            ps.setBoolean(13, activeStaff);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    // Hàm xóa tài khoản theo id
    public void deleteUser(String id) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "DELETE FROM `user` WHERE User_ID = ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    // Hàm tìm user theo id
    public User getUserById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        User u = null;

        try {
            String sql = "SELECT "
                    + "u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                    + "u.Role_ID, r.Role_Name, "
                    + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                    + "u.Provider, u.Provider_ID, "
                    + "u.Account_Status, u.Is_Active_Staff "
                    + "FROM `user` u "
                    + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                    + "WHERE u.User_ID = ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);

            rs = ps.executeQuery();

            if (rs.next()) {
                u = mapUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return u;
    }

    // Hàm update thông tin user
    public void updateUser(User user) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "UPDATE `user` SET "
                    + "Full_Name = ?, "
                    + "Email = ?, "
                    + "Password = ?, "
                    + "Phone = ?, "
                    + "Role_ID = ?, "
                    + "Is_Verified = ?, "
                    + "Provider = ?, "
                    + "Provider_ID = ?, "
                    + "Account_Status = ?, "
                    + "Is_Active_Staff = ? "
                    + "WHERE User_ID = ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRoleId());
            ps.setBoolean(6, user.isVerified());
            ps.setString(7, user.getProvider());
            ps.setString(8, user.getProviderId());
            ps.setString(9, user.getAccountStatus());
            ps.setBoolean(10, user.isActiveStaff());
            ps.setString(11, user.getUserId());

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    // Tìm kiếm và lọc user
    public List<User> searchAndFilterUsers(String keyword, String roleId) {
        List<User> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT "
                    + "u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                    + "u.Role_ID, r.Role_Name, "
                    + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                    + "u.Provider, u.Provider_ID, "
                    + "u.Account_Status, u.Is_Active_Staff "
                    + "FROM `user` u "
                    + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                    + "WHERE 1 = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (u.Full_Name LIKE ? OR u.Email LIKE ?)";
            }

            if (roleId != null && !roleId.trim().isEmpty()) {
                sql += " AND u.Role_ID = ?";
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

            rs = ps.executeQuery();

            while (rs.next()) {
                User u = mapUser(rs);
                list.add(u);
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

    public boolean isEmailExists(String email) {
        String sql = "SELECT User_ID FROM `user` WHERE Email = ?";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public User findByEmail(String email) {
        String sql = "SELECT u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                + "u.Role_ID, r.Role_Name, "
                + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                + "u.Provider, u.Provider_ID, "
                + "u.Account_Status, u.Is_Active_Staff "
                + "FROM `user` u "
                + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                + "WHERE u.Email = ?";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();

                    u.setUserId(rs.getString("User_ID"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setEmail(rs.getString("Email"));
                    u.setPassword(rs.getString("Password"));
                    u.setPhone(rs.getString("Phone"));
                    u.setRoleId(rs.getString("Role_ID"));
                    u.setRoleName(rs.getString("Role_Name"));

                    u.setVerified(rs.getBoolean("Is_Verified"));
                    u.setOtpCode(rs.getString("OTP_Code"));
                    u.setOtpExpiry(rs.getTimestamp("OTP_Expiry"));

                    u.setProvider(rs.getString("Provider"));
                    u.setProviderId(rs.getString("Provider_ID"));
                    u.setAccountStatus(rs.getString("Account_Status"));
                    u.setActiveStaff(rs.getBoolean("Is_Active_Staff"));

                    return u;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User checkLogin(String email, String password) {
        String sql = "SELECT u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                + "u.Role_ID, r.Role_Name, "
                + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                + "u.Provider, u.Provider_ID, "
                + "u.Account_Status, u.Is_Active_Staff "
                + "FROM `user` u "
                + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                + "WHERE u.Email = ? "
                + "AND u.Password = ? "
                + "AND u.Provider = 'LOCAL'";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();

                    u.setUserId(rs.getString("User_ID"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setEmail(rs.getString("Email"));
                    u.setPassword(rs.getString("Password"));
                    u.setPhone(rs.getString("Phone"));
                    u.setRoleId(rs.getString("Role_ID"));
                    u.setRoleName(rs.getString("Role_Name"));

                    u.setVerified(rs.getBoolean("Is_Verified"));
                    u.setOtpCode(rs.getString("OTP_Code"));
                    u.setOtpExpiry(rs.getTimestamp("OTP_Expiry"));

                    u.setProvider(rs.getString("Provider"));
                    u.setProviderId(rs.getString("Provider_ID"));
                    u.setAccountStatus(rs.getString("Account_Status"));
                    u.setActiveStaff(rs.getBoolean("Is_Active_Staff"));

                    return u;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void createLocalUserForRegister(User user) {
        String sql = "INSERT INTO `user` "
                + "(User_ID, Full_Name, Email, Password, Phone, Role_ID, "
                + "Is_Verified, OTP_Code, OTP_Expiry, "
                + "Provider, Provider_ID, Account_Status, Is_Active_Staff) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String userId = user.getUserId();

            if (userId == null || userId.trim().isEmpty()) {
                userId = generateUserId("CUS");
            }

            ps.setString(1, userId);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getPhone());
            ps.setString(6, "CUS");

            ps.setBoolean(7, false);
            ps.setString(8, user.getOtpCode());
            ps.setTimestamp(9, user.getOtpExpiry());

            ps.setString(10, "LOCAL");
            ps.setString(11, null);
            ps.setString(12, "Active");
            ps.setBoolean(13, false);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updateOtpByEmail(String email, String otpCode, Timestamp otpExpiry) {
        String sql = "UPDATE `user` "
                + "SET OTP_Code = ?, OTP_Expiry = ? "
                + "WHERE Email = ?";
        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, otpCode);
            ps.setTimestamp(2, otpExpiry);
            ps.setString(3, email);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public boolean verifyOtp(String email, String otpCode) {
        String sql = "SELECT User_ID FROM `user` "
                + "WHERE Email = ? "
                + "AND OTP_Code = ? "
                + "AND OTP_Expiry > NOW() "
                + "AND Is_Verified = false "
                + "AND Account_Status = 'Active'";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, otpCode);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public void markUserVerified(String email) {
        String sql = "UPDATE `user` "
                + "SET Is_Verified = true "
                + "WHERE Email = ?";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void clearOtp(String email) {
        String sql = "UPDATE `user` "
                + "SET OTP_Code = NULL, OTP_Expiry = NULL "
                + "WHERE Email = ?";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE `user` "
                + "SET Password = ?, OTP_Code = NULL, OTP_Expiry = NULL "
                + "WHERE Email = ? "
                + "AND Provider = 'LOCAL'";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, email);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public User findByProvider(String provider, String providerId) {
        String sql = "SELECT u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                + "u.Role_ID, r.Role_Name, "
                + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                + "u.Provider, u.Provider_ID, "
                + "u.Account_Status, u.Is_Active_Staff "
                + "FROM `user` u "
                + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                + "WHERE u.Provider = ? "
                + "AND u.Provider_ID = ?";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, provider);
            ps.setString(2, providerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();

                    u.setUserId(rs.getString("User_ID"));
                    u.setFullName(rs.getString("Full_Name"));
                    u.setEmail(rs.getString("Email"));
                    u.setPassword(rs.getString("Password"));
                    u.setPhone(rs.getString("Phone"));
                    u.setRoleId(rs.getString("Role_ID"));
                    u.setRoleName(rs.getString("Role_Name"));

                    u.setVerified(rs.getBoolean("Is_Verified"));
                    u.setOtpCode(rs.getString("OTP_Code"));
                    u.setOtpExpiry(rs.getTimestamp("OTP_Expiry"));

                    u.setProvider(rs.getString("Provider"));
                    u.setProviderId(rs.getString("Provider_ID"));
                    u.setAccountStatus(rs.getString("Account_Status"));
                    u.setActiveStaff(rs.getBoolean("Is_Active_Staff"));

                    return u;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public void createGoogleUser(User user) {
        String sql = "INSERT INTO `user` "
                + "(User_ID, Full_Name, Email, Password, Phone, Role_ID, "
                + "Is_Verified, OTP_Code, OTP_Expiry, "
                + "Provider, Provider_ID, Account_Status, Is_Active_Staff) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            String userId = user.getUserId();

            if (userId == null || userId.trim().isEmpty()) {
                userId = generateUserId("CUS");
            }

            ps.setString(1, userId);
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, null);
            ps.setString(5, user.getPhone());
            ps.setString(6, "CUS");

            ps.setBoolean(7, true);
            ps.setString(8, null);
            ps.setTimestamp(9, null);

            ps.setString(10, "GOOGLE");
            ps.setString(11, user.getProviderId());
            ps.setString(12, "Active");
            ps.setBoolean(13, false);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void deleteUnverifiedUsersExpired() {
        String sql = "DELETE FROM `user` "
                + "WHERE Is_Verified = false "
                + "AND Provider = 'LOCAL' "
                + "AND OTP_Expiry IS NOT NULL "
                + "AND OTP_Expiry < NOW()";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}// end class
