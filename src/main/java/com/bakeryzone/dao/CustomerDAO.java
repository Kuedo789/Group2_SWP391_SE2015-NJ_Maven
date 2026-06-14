package com.bakeryzone.dao;

import com.bakeryzone.model.Customer; // Đảm bảo bạn đã có class Model Customer
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    // 1. Hàm bốc 1 khách hàng theo ID để đổ dữ liệu lên Form Sửa
    public Customer getCustomerById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT Customer_ID, User_ID, Full_Name, Phone, Default_Address, Created_At "
                    + "FROM `customer` WHERE `Customer_ID` = ?";
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
                c.setCreatedAt(rs.getTimestamp("Created_At"));
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    // 2. Hàm Thêm mới Khách hàng vào Database
    public boolean insertCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "INSERT INTO `customer` "
                    + "(Customer_ID, User_ID, Full_Name, Phone, Default_Address) "
                    + "VALUES (?, ?, ?, ?, ?)";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            String generatedId = (c.getCustomerId() == null || c.getCustomerId().trim().isEmpty())
                    ? "CUS_" + System.currentTimeMillis()
                    : c.getCustomerId();

            String userId = (c.getUserId() == null || c.getUserId().trim().isEmpty())
                    ? generatedId
                    : c.getUserId();

            ps.setString(1, generatedId);
            ps.setString(2, userId);
            ps.setString(3, c.getFullName());
            ps.setString(4, c.getPhone());
            ps.setString(5, c.getDefaultAddress());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    // 3. Hàm Cập nhật thông tin khách hàng từ trang quản trị
    public boolean updateCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `customer` "
                    + "SET Full_Name = ?, Phone = ?, Default_Address = ? "
                    + "WHERE Customer_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getFullName());
            ps.setString(2, c.getPhone());
            ps.setString(3, c.getDefaultAddress());
            ps.setString(4, c.getCustomerId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    // 4. Hàm Xóa mềm khách hàng khỏi hệ thống (Chỉ ẩn, không mất dữ liệu DB)
    public boolean deleteCustomer(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String sql = "UPDATE `user` u "
                    + "JOIN `customer` c ON u.User_ID = c.User_ID "
                    + "SET u.Account_Status = 'Inactive' "
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

    // 5. Hàm check trùng email trong bảng khách hàng
    public boolean checkEmailExist(String email, String customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT u.User_ID "
                    + "FROM `user` u "
                    + "JOIN `customer` c ON u.User_ID = c.User_ID "
                    + "WHERE u.Email = ?";
            if (customerId != null && !customerId.trim().isEmpty()) {
                sql += " AND c.Customer_ID != ?";
            }

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            if (customerId != null && !customerId.trim().isEmpty()) {
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

    // 6. Hàm đếm tổng số khách hàng hoạt động phục vụ phân trang
    public int getTotalCustomers(String keyword, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE u.Role_ID = 'CUSTOMER'";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (c.Full_Name LIKE ? OR u.Email LIKE ? OR c.Phone LIKE ?)";
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

    // 7. Hàm tìm kiếm, lọc và phân trang Khách hàng (Đổ ra bảng hiển thị chính)
    public List<Customer> searchAndFilterCustomers(String keyword, String status, int pageIndex, int pageSize) {
        List<Customer> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT c.Customer_ID, c.User_ID, c.Full_Name, c.Phone, c.Default_Address, c.Created_At "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE u.Role_ID = 'CUSTOMER'";

            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (c.Full_Name LIKE ? OR u.Email LIKE ? OR c.Phone LIKE ?)";
            }
            if (status != null && !status.trim().isEmpty()) {
                sql += " AND u.Account_Status = ?";
            }

            sql += " ORDER BY c.Created_At DESC LIMIT ? OFFSET ?";

            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
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
                c.setCreatedAt(rs.getTimestamp("Created_At"));
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