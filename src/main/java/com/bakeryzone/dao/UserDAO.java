package com.bakeryzone.dao;

import com.bakeryzone.model.User;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserDAO {

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
                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

// Hàm thêm mới 1 tài khoản từ trang admin
    public void insertUser(User user) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // Nếu User_ID chưa có thì tự tạo theo role
            if (user.getUserId() == null || user.getUserId().trim().isEmpty()) {
                user.setUserId(generateUserId(user.getRoleId()));
            }
            // Nếu provider chưa có thì mặc định là LOCAL
            // LOCAL = tài khoản đăng ký/đăng nhập bằng email + password
            if (user.getProvider() == null || user.getProvider().trim().isEmpty()) {
                user.setProvider("LOCAL");
            }

            // Nếu trạng thái tài khoản chưa có thì mặc định là Active
            if (user.getAccountStatus() == null || user.getAccountStatus().trim().isEmpty()) {
                user.setAccountStatus("Active");
            }

            // Nếu user được tạo từ admin thì nên cho xác thực sẵn
            // Tránh trường hợp admin tạo user xong nhưng user không đăng nhập được vì Is_Verified = false
            user.setVerified(true);

            // Nếu role là ADMIN / STAFF / SHIPPER thì đánh dấu là nhân viên đang hoạt động
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

            // User tạo từ admin thì verified = true
            ps.setBoolean(7, user.isVerified());

            // Tạo từ admin thì không cần OTP
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

    // Hàm xóa tài khoản theo User_ID
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
            // Đóng kết nối
            close(conn, ps, null);
        }
    }

    // Hàm tìm user theo User_ID
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
                u = new User();

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
            // Nếu provider chưa có thì mặc định là LOCAL
            if (user.getProvider() == null || user.getProvider().trim().isEmpty()) {
                user.setProvider("LOCAL");
            }

            // Nếu trạng thái tài khoản chưa có thì mặc định là Active
            if (user.getAccountStatus() == null || user.getAccountStatus().trim().isEmpty()) {
                user.setAccountStatus("Active");
            }

            // Nếu role là ADMIN / STAFF / SHIPPER thì đánh dấu là nhân viên đang hoạt động
            boolean activeStaff = "ADMIN".equalsIgnoreCase(user.getRoleId())
                    || "STAFF".equalsIgnoreCase(user.getRoleId())
                    || "SHIPPER".equalsIgnoreCase(user.getRoleId());

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
            ps.setBoolean(10, activeStaff);

            ps.setString(11, user.getUserId());

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    // Tìm kiếm, lọc user theo tên/email, role, trạng thái và phân trang
    public List<User> searchAndFilterUsers(String keyword, String roleId, String status, int pageIndex, int pageSize) {
        List<User> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Select đủ cột vì bên dưới cần map OTP, Provider, ActiveStaff
            String sql = "SELECT "
                    + "u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, "
                    + "u.Role_ID, r.Role_Name, "
                    + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, "
                    + "u.Provider, u.Provider_ID, "
                    + "u.Account_Status, u.Is_Active_Staff "
                    + "FROM `user` u "
                    + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                    + "WHERE 1=1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (u.Full_Name LIKE ? OR u.Email LIKE ?)";
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

                list.add(u);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    // Tìm kiếm và lọc user
    public List<User> searchAndFilterUsers(String keyword, String roleId) {
        return searchAndFilterUsers(keyword, roleId, null, 1, 1000);
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

    public boolean createLocalUserForRegister(User user) {
        String sql = "INSERT INTO `user` "
                + "(User_ID, Full_Name, Email, Password, Phone, Role_ID, "
                + "Is_Verified, OTP_Code, OTP_Expiry, "
                + "Provider, Provider_ID, Created_At, Account_Status, Is_Active_Staff) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), ?, ?)";

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

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
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

    public boolean verifyForgotOtp(String email, String otpCode) {
        String sql = "SELECT User_ID FROM `user` "
                + "WHERE Email = ? "
                + "AND OTP_Code = ? "
                + "AND OTP_Expiry > NOW() "
                + "AND Is_Verified = true "
                + "AND Provider = 'LOCAL' "
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

    public boolean verifyRegisterOtp(String email, String otpCode) {
        String sql = "SELECT User_ID FROM `user` "
                + "WHERE Email = ? "
                + "AND OTP_Code = ? "
                + "AND OTP_Expiry > NOW() "
                + "AND Is_Verified = false "
                + "AND Provider = 'LOCAL' "
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

    public void markUserVerifiedAndClearOtp(String email) {
        String sql = "UPDATE `user` "
                + "SET Is_Verified = true, OTP_Code = NULL, OTP_Expiry = NULL "
                + "WHERE Email = ? "
                + "AND Provider = 'LOCAL'";

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

    public boolean createGoogleUser(User user) {
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

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
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
// Cập nhật lại thông tin và OTP mới cho tài khoản đã đăng ký nhưng chưa xác thực

    public void updateUnverifiedRegisterByEmail(User user) {
        String sql = "UPDATE `user` "
                + "SET Full_Name = ?, Password = ?, Phone = ?, "
                + "OTP_Code = ?, OTP_Expiry = ?, "
                + "Provider = 'LOCAL', Account_Status = 'Active' "
                + "WHERE Email = ? "
                + "AND Is_Verified = false";

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getOtpCode());
            ps.setTimestamp(5, user.getOtpExpiry());
            ps.setString(6, user.getEmail());

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

// Kiểm tra email đã tồn tại chưa
// currentUserId dùng khi edit: bỏ qua chính user đang sửa
    public boolean checkEmailExist(String email, String currentUserId) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            // Neu la Edit thi bo qua chinh Email cua minh, neu la Add thi kiem tra toan bo
            String sql = "SELECT * FROM user WHERE Email = ?";
            if (currentUserId != null && !currentUserId.isEmpty()) {
                sql += " AND User_ID != ?";
            }
            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim());
            if (currentUserId != null && !currentUserId.isEmpty()) {
                ps.setString(2, currentUserId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return true; // Email da ton tai
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            /* close resources */ }
        return false;
    }
// Đếm tổng số user sau khi lọc để phục vụ phân trang

    public int getTotalUsers(String keyword, String roleId, String status) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM user WHERE 1=1";
            if (keyword != null) {
                sql += " AND (Full_Name LIKE ? OR Email LIKE ?)";
            }
            if (roleId != null) {
                sql += " AND Role_ID = ?";
            }
            if (status != null) {
                sql += " AND Account_Status = ?";
            }

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;
            if (keyword != null) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            }
            if (roleId != null) {
                ps.setString(paramIndex++, roleId);
            }
            if (status != null) {
                ps.setString(paramIndex++, status);
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        }
        return 0;
    }
    
    public boolean updateProfile(String userId, String fullName, String phone, String address) {
    String sql = "UPDATE `user` "
            + "SET Full_Name = ?, Phone = ?, Default_Address = ? "
            + "WHERE User_ID = ?";

    try (
            Connection conn = DBContext.getJDBCConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, fullName);
        ps.setString(2, phone);
        ps.setString(3, address);
        ps.setString(4, userId);

        return ps.executeUpdate() > 0;

    } catch (Exception e) {
        e.printStackTrace();
    }

    return false;
}

}// end class

