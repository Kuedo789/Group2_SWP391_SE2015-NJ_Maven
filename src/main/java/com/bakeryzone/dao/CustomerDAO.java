package com.bakeryzone.dao;

import com.bakeryzone.model.Customer;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    public Customer getCustomerById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT c.Customer_ID, c.User_ID, c.Full_Name, c.Phone,c.Default_Address, u.Email, u.Password, u.Account_Status, u.Is_Verified "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE c.Customer_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getString("Customer_ID"));
                c.setUserId(rs.getString("User_ID"));
                c.setFullName(rs.getString("Full_Name"));
                c.setPhone(rs.getString("Phone"));
                c.setDefaultAddress(rs.getString("Default_Address"));

                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setVerified(rs.getBoolean("Is_Verified"));

                c.setUser(u);
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    public boolean insertCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psCus = null;
        boolean isSuccess = false;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);

            String userId = "USR_" + System.currentTimeMillis();
            String generatedCusId = (c.getCustomerId() == null || c.getCustomerId().trim().isEmpty())
                    ? "CUS_" + System.currentTimeMillis()
                    : c.getCustomerId();

            // Insert vào bảng user lấy thông tin từ c.getUser()
            String sqlUser = "INSERT INTO `user` (User_ID, Email, Password, Role_ID, Account_Status, Is_Verified) VALUES (?, ?, ?, 'CUSTOMER', ?, ?)";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, userId);
            psUser.setString(2, c.getUser().getEmail());
            psUser.setString(3, c.getUser().getPassword());
            psUser.setString(4, c.getUser().getAccountStatus() != null ? c.getUser().getAccountStatus() : "Active");
            psUser.setBoolean(5, c.getUser().isVerified());
            psUser.executeUpdate();

            // Insert vào bảng customer
            String sqlCus = "INSERT INTO `customer` (Customer_ID, User_ID, Full_Name, Phone, Default_Address, Is_Active_Customer) VALUES (?, ?, ?, ?, ?, 1)";
            psCus = conn.prepareStatement(sqlCus);
            psCus.setString(1, generatedCusId);
            psCus.setString(2, userId);
            psCus.setString(3, c.getFullName());
            psCus.setString(4, c.getPhone());
            psCus.setString(5, c.getDefaultAddress());
            psCus.executeUpdate();

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
            close(conn, psCus, null);
        }
        return isSuccess;
    }

    public boolean updateCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement psSync = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);
            String sql = "UPDATE `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "SET c.Full_Name = ?, c.Phone = ?, c.Default_Address = ?, u.Email = ?, u.Password = ?, u.Account_Status = ? "
                    + "WHERE c.Customer_ID = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getFullName());
            ps.setString(2, c.getPhone());
            ps.setString(3, c.getDefaultAddress());
            ps.setString(4, c.getUser().getEmail());
            ps.setString(5, c.getUser().getPassword());
            ps.setString(6, c.getUser().getAccountStatus());
            ps.setString(7, c.getCustomerId());
            int rowsUpdated = ps.executeUpdate();
            if (rowsUpdated > 0 && c.getDefaultAddress() != null && !c.getDefaultAddress().trim().isEmpty()) {
                String syncAddressSql = "UPDATE `delivery_address` da "
                        + "JOIN `customer` c ON da.User_ID = c.User_ID "
                        + "SET da.Address_Detail = ?, da.Receiver_Name = ?, da.Receiver_Phone = ? "
                        + "WHERE c.Customer_ID = ? AND da.Is_Default = 1";
                psSync = conn.prepareStatement(syncAddressSql);
                psSync.setString(1, c.getDefaultAddress().trim());
                psSync.setString(2, c.getFullName().trim());
                psSync.setString(3, c.getPhone().trim());
                psSync.setString(4, c.getCustomerId());
                int syncRows = psSync.executeUpdate();
                if (syncRows == 0) {
                    String insertAddressSql = "INSERT INTO `delivery_address` (User_ID, Receiver_Name, Receiver_Phone, Address_Detail, Is_Default) "
                            + "SELECT User_ID, Full_Name, Phone, ?, 1 FROM `customer` WHERE Customer_ID = ?";
                    try (PreparedStatement psInsert = conn.prepareStatement(insertAddressSql)) {
                        psInsert.setString(1, c.getDefaultAddress().trim());
                        psInsert.setString(2, c.getCustomerId());
                        psInsert.executeUpdate();
                    }
                }
            }
            conn.commit();
            return rowsUpdated > 0;
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            close(null, psSync, null);
            close(conn, ps, null);
        }
        return false;
    }

    public boolean deleteCustomer(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "SET u.Is_Verified = 0, c.Is_Active_Customer = 0 "
                    + "WHERE c.Customer_ID = ?";
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

    public boolean checkEmailExist(String email, String customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT Email FROM `user` WHERE Email = ?";

            if (customerId != null) {
                sql += " AND User_ID != (SELECT User_ID FROM `customer` WHERE Customer_ID = ?)";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            if (customerId != null) {
                ps.setString(2, customerId);
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

    public int getTotalCustomers(String keyword, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE u.Is_Verified = 1";
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (c.Full_Name LIKE ? OR u.Email LIKE ?)";
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

    public List<Customer> searchAndFilterCustomers(String keyword, String status, int pageIndex, int pageSize) {
        List<Customer> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT c.Customer_ID, c.User_ID, c.Full_Name, c.Phone,c.Default_Address, u.Email, u.Password, u.Account_Status, u.Is_Verified "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE u.Is_Verified = 1";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (c.Full_Name LIKE ? OR u.Email LIKE ?)";
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
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }

            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, (pageIndex - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getString("Customer_ID"));
                c.setUserId(rs.getString("User_ID"));
                c.setFullName(rs.getString("Full_Name"));
                c.setPhone(rs.getString("Phone"));
                c.setDefaultAddress(rs.getString("Default_Address"));

                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setVerified(rs.getBoolean("Is_Verified"));

                c.setUser(u);
                list.add(c);
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
}
