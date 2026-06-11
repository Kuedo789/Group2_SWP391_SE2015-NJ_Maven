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
            String sql = "SELECT * FROM `customer` WHERE `Customer_ID` = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getString("Customer_ID"));
                c.setFullName(rs.getString("Full_Name"));
                c.setEmail(rs.getString("Email"));
                c.setPassword(rs.getString("Password"));
                c.setPhone(rs.getString("Phone"));
                c.setAccountStatus(rs.getString("Account_Status"));
                c.setIsVerified(rs.getBoolean("Is_Verified"));
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
            String sql = "INSERT INTO `customer` (Customer_ID, Full_Name, Email, Password, Phone, Account_Status, Is_Verified) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            String generatedId = (c.getCustomerId() == null || c.getCustomerId().trim().isEmpty())
                    ? "CUS" + System.currentTimeMillis()
                    : c.getCustomerId();

            ps.setString(1, generatedId);
            ps.setString(2, c.getFullName());
            ps.setString(3, c.getEmail());
            ps.setString(4, c.getPassword());
            ps.setString(5, c.getPhone());
            ps.setString(6, c.getAccountStatus());
            ps.setBoolean(7, c.isIsVerified());

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
            String sql = "UPDATE `customer` SET Full_Name = ?, Email = ?, Password = ?, Phone = ?, Account_Status = ? WHERE Customer_ID = ?";
            conn = DBContext.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, c.getFullName());
            ps.setString(2, c.getEmail());
            ps.setString(3, c.getPassword());
            ps.setString(4, c.getPhone());
            ps.setString(5, c.getAccountStatus());
            ps.setString(6, c.getCustomerId());
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
            String sql = "UPDATE `customer` SET `Is_Verified` = 0 WHERE `Customer_ID` = ?";
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
            String sql = "SELECT * FROM `customer` WHERE Email = ?";
            if (customerId != null) {
                sql += " AND Customer_ID != ?";
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

    // 6. Hàm đếm tổng số khách hàng hoạt động phục vụ phân trang
    public int getTotalCustomers(String keyword, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM `customer` WHERE `Is_Verified` = 1";
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (Full_Name LIKE ? OR Email LIKE ?)";
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
            String sql = "SELECT * FROM `customer` WHERE `Is_Verified` = 1";
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql += " AND (Full_Name LIKE ? OR Email LIKE ?)";
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
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(paramIndex++, status);
            }

            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex++, (pageIndex - 1) * pageSize);

            rs = ps.executeQuery();
            while (rs.next()) {
                Customer c = new Customer();
                c.setCustomerId(rs.getString("Customer_ID"));
                c.setFullName(rs.getString("Full_Name"));
                c.setEmail(rs.getString("Email"));
                c.setPassword(rs.getString("Password"));
                c.setPhone(rs.getString("Phone"));
                c.setAccountStatus(rs.getString("Account_Status"));
                c.setIsVerified(rs.getBoolean("Is_Verified"));
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
