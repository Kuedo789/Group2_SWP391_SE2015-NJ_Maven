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

        if ("CUSTOMER".equalsIgnoreCase(roleId)) {
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

    private String getStaffPositionByRole(String roleId) {
        if ("ADMIN".equalsIgnoreCase(roleId)) {
            return "Quản trị viên";
        }

        if ("SHIPPER".equalsIgnoreCase(roleId)) {
            return "Nhân viên giao hàng";
        }

        if ("STAFF".equalsIgnoreCase(roleId)) {
            return "Nhân viên làm bánh";
        }

        return "Nhân viên";
    }

    private String getBaseSelectSql() {
        return "SELECT "
                + "u.User_ID, u.Email, u.Password, u.Role_ID, r.Role_Name, "
                + "u.Is_Verified, u.OTP_Code, u.OTP_Expiry, u.Created_At, u.Account_Status, "
                + "COALESCE(c.Full_Name, s.Full_Name) AS Full_Name, "
                + "COALESCE(c.Phone, s.Phone) AS Phone, "
                + "c.Default_Address "
                + "FROM `user` u "
                + "JOIN `role` r ON u.Role_ID = r.Role_ID "
                + "LEFT JOIN customer c ON u.User_ID = c.User_ID "
                + "LEFT JOIN staff s ON u.User_ID = s.User_ID ";
    }

    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();

        u.setUserId(rs.getString("User_ID"));
        u.setEmail(rs.getString("Email"));
        u.setPassword(rs.getString("Password"));
        u.setRoleId(rs.getString("Role_ID"));
        u.setRoleName(rs.getString("Role_Name"));
        u.setVerified(rs.getBoolean("Is_Verified"));
        u.setOtpCode(rs.getString("OTP_Code"));
        u.setOtpExpiry(rs.getTimestamp("OTP_Expiry"));
        u.setCreatedAt(rs.getTimestamp("Created_At"));
        u.setAccountStatus(rs.getString("Account_Status"));

        u.setFullName(rs.getString("Full_Name"));
        u.setPhone(rs.getString("Phone"));
        u.setDefaultAddress(rs.getString("Default_Address"));

        boolean activeStaff = "ADMIN".equalsIgnoreCase(u.getRoleId())
                || "STAFF".equalsIgnoreCase(u.getRoleId())
                || "SHIPPER".equalsIgnoreCase(u.getRoleId());

        u.setActiveStaff(activeStaff);

        return u;
    }

    // Hàm lấy toàn bộ danh sách user kèm role tương ứng
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();

        String sql = getBaseSelectSql()
                + "ORDER BY u.Created_At DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapUser(rs));
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
        PreparedStatement psUser = null;
        PreparedStatement psProfile = null;

        try {
            conn = DBContext.getJDBCConnection();

            if (conn == null) {
                return;
            }

            conn.setAutoCommit(false);

            if (user.getRoleId() == null || user.getRoleId().trim().isEmpty()) {
                user.setRoleId("CUSTOMER");
            }

            if (user.getUserId() == null || user.getUserId().trim().isEmpty()) {
                user.setUserId(generateUserId(user.getRoleId()));
            }

            if (user.getAccountStatus() == null || user.getAccountStatus().trim().isEmpty()) {
                user.setAccountStatus("Active");
            }

            user.setVerified(true);

            String sqlUser = "INSERT INTO `user` "
                    + "(User_ID, Email, Password, Role_ID, Is_Verified, OTP_Code, OTP_Expiry, Account_Status) "
                    + "VALUES (?, ?, ?, ?, ?, NULL, NULL, ?)";

            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, user.getUserId());
            psUser.setString(2, user.getEmail());
            psUser.setString(3, user.getPassword());
            psUser.setString(4, user.getRoleId());
            psUser.setBoolean(5, user.isVerified());
            psUser.setString(6, user.getAccountStatus());

            int userRows = psUser.executeUpdate();

            int profileRows = 0;

            if ("CUSTOMER".equalsIgnoreCase(user.getRoleId())) {
                String sqlCustomer = "INSERT INTO customer "
                        + "(Customer_ID, User_ID, Full_Name, Phone, Default_Address) "
                        + "VALUES (?, ?, ?, ?, ?)";

                psProfile = conn.prepareStatement(sqlCustomer);
                psProfile.setString(1, user.getUserId());
                psProfile.setString(2, user.getUserId());
                psProfile.setString(3, user.getFullName());
                psProfile.setString(4, user.getPhone());
                psProfile.setString(5, user.getDefaultAddress());

                profileRows = psProfile.executeUpdate();

            } else {
                String sqlStaff = "INSERT INTO staff "
                        + "(Staff_ID, User_ID, Full_Name, Phone, Position, Is_Active_Staff) "
                        + "VALUES (?, ?, ?, ?, ?, ?)";

                psProfile = conn.prepareStatement(sqlStaff);
                psProfile.setString(1, user.getUserId());
                psProfile.setString(2, user.getUserId());
                psProfile.setString(3, user.getFullName());
                psProfile.setString(4, user.getPhone());
                psProfile.setString(5, getStaffPositionByRole(user.getRoleId()));
                psProfile.setBoolean(6, true);

                profileRows = psProfile.executeUpdate();
            }

            if (userRows > 0 && profileRows > 0) {
                conn.commit();
            } else {
                conn.rollback();
            }

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            close(null, psProfile, null);
            close(conn, psUser, null);
        }
    }

    // Hàm xóa tài khoản theo User_ID
    public void deleteUser(String id) {
        String sql = "DELETE FROM `user` WHERE User_ID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
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

    // Hàm tìm user theo User_ID
    public User getUserById(String id) {
        String sql = getBaseSelectSql()
                + "WHERE u.User_ID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return null;
    }

    // Hàm update thông tin user
    public void updateUser(User user) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psProfile = null;

        try {
            conn = DBContext.getJDBCConnection();

            if (conn == null) {
                return;
            }

            conn.setAutoCommit(false);

            if (user.getAccountStatus() == null || user.getAccountStatus().trim().isEmpty()) {
                user.setAccountStatus("Active");
            }

            String sqlUser = "UPDATE `user` SET "
                    + "Email = ?, "
                    + "Password = ?, "
                    + "Role_ID = ?, "
                    + "Is_Verified = ?, "
                    + "Account_Status = ? "
                    + "WHERE User_ID = ?";

            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, user.getEmail());
            psUser.setString(2, user.getPassword());
            psUser.setString(3, user.getRoleId());
            psUser.setBoolean(4, user.isVerified());
            psUser.setString(5, user.getAccountStatus());
            psUser.setString(6, user.getUserId());

            int userRows = psUser.executeUpdate();

            int profileRows = 0;

            if ("CUSTOMER".equalsIgnoreCase(user.getRoleId())) {
                String sqlCustomer = "UPDATE customer "
                        + "SET Full_Name = ?, Phone = ?, Default_Address = ? "
                        + "WHERE User_ID = ?";

                psProfile = conn.prepareStatement(sqlCustomer);
                psProfile.setString(1, user.getFullName());
                psProfile.setString(2, user.getPhone());
                psProfile.setString(3, user.getDefaultAddress());
                psProfile.setString(4, user.getUserId());

                profileRows = psProfile.executeUpdate();

            } else {
                String sqlStaff = "UPDATE staff "
                        + "SET Full_Name = ?, Phone = ?, Position = ?, Is_Active_Staff = ? "
                        + "WHERE User_ID = ?";

                psProfile = conn.prepareStatement(sqlStaff);
                psProfile.setString(1, user.getFullName());
                psProfile.setString(2, user.getPhone());
                psProfile.setString(3, getStaffPositionByRole(user.getRoleId()));
                psProfile.setBoolean(4, true);
                psProfile.setString(5, user.getUserId());

                profileRows = psProfile.executeUpdate();
            }

            if (userRows > 0 && profileRows > 0) {
                conn.commit();
            } else {
                conn.rollback();
            }

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            close(null, psProfile, null);
            close(conn, psUser, null);
        }
    }

    // Tìm kiếm, lọc user theo tên/email, role, trạng thái và phân trang
    public List<User> searchAndFilterUsers(String keyword, String roleId, String status, int pageIndex, int pageSize) {
        List<User> list = new ArrayList<>();

        String sql = getBaseSelectSql()
                + "WHERE 1=1 ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (COALESCE(c.Full_Name, s.Full_Name) LIKE ? OR u.Email LIKE ?) ";
        }

        if (roleId != null && !roleId.trim().isEmpty()) {
            sql += "AND u.Role_ID = ? ";
        }

        if (status != null && !status.trim().isEmpty()) {
            sql += "AND u.Account_Status = ? ";
        }

        sql += "ORDER BY u.Created_At DESC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
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
                list.add(mapUser(rs));
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

    public boolean isEmailExists(String email) {
        String sql = "SELECT User_ID FROM `user` WHERE Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return false;
    }

    public User findByEmail(String email) {
        String sql = getBaseSelectSql()
                + "WHERE u.Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return null;
    }

    public User checkLogin(String email, String password) {
        String sql = getBaseSelectSql()
                + "WHERE u.Email = ? "
                + "AND u.Password = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return null;
    }

    public boolean createCustomerAccountForRegister(User user) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psCustomer = null;

        try {
            conn = DBContext.getJDBCConnection();

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            String userId = user.getUserId();

            if (userId == null || userId.trim().isEmpty()) {
                userId = generateUserId("CUSTOMER");
                user.setUserId(userId);
            }

            String sqlUser = "INSERT INTO `user` "
                    + "(User_ID, Email, Password, Role_ID, Is_Verified, OTP_Code, OTP_Expiry, Created_At, Account_Status) "
                    + "VALUES (?, ?, ?, 'CUSTOMER', ?, ?, ?, NOW(), ?)";

            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, userId);
            psUser.setString(2, user.getEmail());
            psUser.setString(3, user.getPassword());
            psUser.setBoolean(4, false);
            psUser.setString(5, user.getOtpCode());
            psUser.setTimestamp(6, user.getOtpExpiry());
            psUser.setString(7, "Active");

            int userRows = psUser.executeUpdate();

            String sqlCustomer = "INSERT INTO customer "
                    + "(Customer_ID, User_ID, Full_Name, Phone, Default_Address, Created_At) "
                    + "VALUES (?, ?, ?, ?, ?, NOW())";

            psCustomer = conn.prepareStatement(sqlCustomer);
            psCustomer.setString(1, userId);
            psCustomer.setString(2, userId);
            psCustomer.setString(3, user.getFullName());
            psCustomer.setString(4, user.getPhone());
            psCustomer.setString(5, user.getDefaultAddress());

            int customerRows = psCustomer.executeUpdate();

            if (userRows > 0 && customerRows > 0) {
                conn.commit();
                return true;
            }

            conn.rollback();

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            close(null, psCustomer, null);
            close(conn, psUser, null);
        }

        return false;
    }

    public boolean updateOtpByEmail(String email, String otpCode, Timestamp otpExpiry) {
        String sql = "UPDATE `user` "
                + "SET OTP_Code = ?, OTP_Expiry = ? "
                + "WHERE Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, otpCode);
            ps.setTimestamp(2, otpExpiry);
            ps.setString(3, email);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }

        return false;
    }

    public boolean verifyForgotOtp(String email, String otpCode) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT User_ID FROM `user` "
                    + "WHERE Email = ? "
                    + "AND OTP_Code = ? "
                    + "AND OTP_Expiry > NOW() "
                    + "AND Is_Verified = true "
                    + "AND Account_Status = 'Active'";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, otpCode);

            rs = ps.executeQuery();
            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return false;
    }

    public boolean verifyRegisterOtp(String email, String otpCode) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT User_ID FROM `user` "
                    + "WHERE Email = ? "
                    + "AND OTP_Code = ? "
                    + "AND OTP_Expiry > NOW() "
                    + "AND Is_Verified = false";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, otpCode);

            rs = ps.executeQuery();
            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return false;
    }

    public void markUserVerified(String email) {
        String sql = "UPDATE `user` "
                + "SET Is_Verified = true "
                + "WHERE Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    public void clearOtp(String email) {
        String sql = "UPDATE `user` "
                + "SET OTP_Code = NULL, OTP_Expiry = NULL "
                + "WHERE Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    public boolean markUserVerifiedAndClearOtp(String email) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "UPDATE `user` "
                    + "SET Is_Verified = true, OTP_Code = NULL, OTP_Expiry = NULL "
                    + "WHERE Email = ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }

        return false;
    }

    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE `user` "
                + "SET Password = ?, OTP_Code = NULL, OTP_Expiry = NULL "
                + "WHERE Email = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, newPassword);
            ps.setString(2, email);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }

        return false;
    }

    public void deleteUnverifiedUsersExpired() {
        String sql = "DELETE FROM `user` "
                + "WHERE Is_Verified = false "
                + "AND OTP_Expiry IS NOT NULL "
                + "AND OTP_Expiry < NOW()";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
    }

    // Cập nhật lại thông tin và OTP mới cho tài khoản đã đăng ký nhưng chưa xác thực
    public boolean updateUnverifiedRegisterByEmail(User user) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psCustomer = null;

        try {
            User existing = findByEmail(user.getEmail());

            if (existing == null) {
                return false;
            }

            conn = DBContext.getJDBCConnection();

            if (conn == null) {
                return false;
            }

            conn.setAutoCommit(false);

            String sqlUser = "UPDATE `user` "
                    + "SET Password = ?, OTP_Code = ?, OTP_Expiry = ?, Account_Status = 'Active' "
                    + "WHERE Email = ? "
                    + "AND Is_Verified = false";

            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, user.getPassword());
            psUser.setString(2, user.getOtpCode());
            psUser.setTimestamp(3, user.getOtpExpiry());
            psUser.setString(4, user.getEmail());

            int userRows = psUser.executeUpdate();

            String sqlCustomer = "UPDATE customer "
                    + "SET Full_Name = ?, Phone = ?, Default_Address = ? "
                    + "WHERE User_ID = ?";

            psCustomer = conn.prepareStatement(sqlCustomer);
            psCustomer.setString(1, user.getFullName());
            psCustomer.setString(2, user.getPhone());
            psCustomer.setString(3, user.getDefaultAddress());
            psCustomer.setString(4, existing.getUserId());

            psCustomer.executeUpdate();

            if (userRows > 0) {
                conn.commit();
                return true;
            } else {
                conn.rollback();
            }

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            close(null, psCustomer, null);
            close(conn, psUser, null);
        }

        return false;
    }

    // Kiểm tra email đã tồn tại chưa
    public boolean checkEmailExist(String email, String currentUserId) {
        String sql = "SELECT User_ID FROM `user` WHERE Email = ?";

        if (currentUserId != null && !currentUserId.trim().isEmpty()) {
            sql += " AND User_ID != ?";
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, email.trim());

            if (currentUserId != null && !currentUserId.trim().isEmpty()) {
                ps.setString(2, currentUserId);
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

    // Đếm tổng số user sau khi lọc để phục vụ phân trang
    public int getTotalUsers(String keyword, String roleId, String status) {
        String sql = "SELECT COUNT(*) "
                + "FROM `user` u "
                + "LEFT JOIN customer c ON u.User_ID = c.User_ID "
                + "LEFT JOIN staff s ON u.User_ID = s.User_ID "
                + "WHERE 1=1 ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND (COALESCE(c.Full_Name, s.Full_Name) LIKE ? OR u.Email LIKE ?) ";
        }

        if (roleId != null && !roleId.trim().isEmpty()) {
            sql += "AND u.Role_ID = ? ";
        }

        if (status != null && !status.trim().isEmpty()) {
            sql += "AND u.Account_Status = ? ";
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
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

    public boolean updateProfile(String userId, String fullName, String phone) {
        User user = getUserById(userId);

        if (user == null) {
            return false;
        }

        String sql;

        if ("CUSTOMER".equalsIgnoreCase(user.getRoleId())) {
            sql = "UPDATE customer "
                    + "SET Full_Name = ?, Phone = ? "
                    + "WHERE User_ID = ?";
        } else {
            sql = "UPDATE staff "
                    + "SET Full_Name = ?, Phone = ? "
                    + "WHERE User_ID = ?";
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, fullName);
            ps.setString(2, phone);

            ps.setString(3, userId);

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
