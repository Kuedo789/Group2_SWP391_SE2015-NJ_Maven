package com.bakeryzone.dao;

import com.bakeryzone.model.Customer;
import com.bakeryzone.utils.DBContext;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CustomerDAO {

    // 1. Hàm bốc 1 khách hàng theo ID phục vụ đổ Form Sửa (Gộp dữ liệu từ 2 bảng)
    public Customer getCustomerById(String id) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT c.Customer_ID, c.User_ID, c.Full_Name, c.Phone, c.Default_Address, c.Created_At, "
                    + "u.Email, u.Password, u.Account_Status "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID WHERE c.Customer_ID = ?";
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

                // Map thêm trường ảo từ bảng user
                c.setEmail(rs.getString("Email"));
                c.setPassword(rs.getString("Password"));
                c.setAccountStatus(rs.getString("Account_Status"));
                return c;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return null;
    }

    // 2. Hàm Thêm mới Khách hàng (Sử dụng TRANSACTION ghi đồng bộ thông suốt cả 2 bảng)
    public boolean insertCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psCustomer = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false); // Kích hoạt Transaction kiểm soát lỗi chuỗi

            String genUserId = "USR_" + System.currentTimeMillis();
            String genCustomerId = "CUS_" + System.currentTimeMillis();

            // Bước A: Nhét tài khoản vào bảng user trước (Mã quyền mặc định khách hàng là CUS)
            String sqlUser = "INSERT INTO `user` (User_ID, Email, Password, Role_ID, Is_Verified, Account_Status) "
                    + "VALUES (?, ?, ?, 'CUS', 1, ?)";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, genUserId);
            psUser.setString(2, c.getEmail());
            psUser.setString(3, c.getPassword());
            psUser.setString(4, c.getAccountStatus() != null ? c.getAccountStatus() : "Active");
            psUser.executeUpdate();

            // Bước B: Nhét thông tin cá nhân bổ sung vào bảng customer
            String sqlCustomer = "INSERT INTO `customer` (Customer_ID, User_ID, Full_Name, Phone, Default_Address) "
                    + "VALUES (?, ?, ?, ?, ?)";
            psCustomer = conn.prepareStatement(sqlCustomer);
            psCustomer.setString(1, genCustomerId);
            psCustomer.setString(2, genUserId);
            psCustomer.setString(3, c.getFullName());
            psCustomer.setString(4, c.getPhone());
            psCustomer.setString(5, c.getDefaultAddress());
            psCustomer.executeUpdate();

            conn.commit(); // Thành công thực thi đẩy xuống DB
            return true;
        } catch (Exception e) {
            System.out.println("LỖI SQL THỰC TẾ: " + e.getMessage()); // THÊM DÒNG NÀY
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            try {
                if (psUser != null) {
                    psUser.close();
                }
                if (psCustomer != null) {
                    psCustomer.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
        return false;
    }

    // 3. Hàm Cập nhật thông tin khách hàng đồng bộ lên 2 bảng
    public boolean updateCustomer(Customer c) {
        Connection conn = null;
        PreparedStatement psUser = null;
        PreparedStatement psCustomer = null;
        try {
            conn = DBContext.getJDBCConnection();
            conn.setAutoCommit(false);

            // Bước A: Sửa bảng customer trước
            String sqlCustomer = "UPDATE `customer` SET Full_Name = ?, Phone = ?, Default_Address = ? WHERE Customer_ID = ?";
            psCustomer = conn.prepareStatement(sqlCustomer);
            psCustomer.setString(1, c.getFullName());
            psCustomer.setString(2, c.getPhone());
            psCustomer.setString(3, c.getDefaultAddress());
            psCustomer.setString(4, c.getCustomerId());
            psCustomer.executeUpdate();

            // Bước B: Sửa Email, Password, Trạng thái bên bảng user liên kết
            String sqlUser = "UPDATE `user` SET Email = ?, Password = ?, Account_Status = ? WHERE User_ID = ?";
            psUser = conn.prepareStatement(sqlUser);
            psUser.setString(1, c.getEmail());
            psUser.setString(2, c.getPassword());
            psUser.setString(3, c.getAccountStatus());
            psUser.setString(4, c.getUserId());
            psUser.executeUpdate();

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            try {
                if (psUser != null) {
                    psUser.close();
                }
                if (psCustomer != null) {
                    psCustomer.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
            }
        }
        return false;
    }

    // 4. Hàm Xóa mềm khách hàng (Chuyển Account_Status thành Inactive bên bảng user)
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

    // 5. Hàm check trùng email kết hợp bảng user
    public boolean checkEmailExist(String email, String customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT u.User_ID FROM `user` u WHERE u.Email = ?";
            if (customerId != null && !customerId.trim().isEmpty()) {
                sql += " AND u.User_ID NOT IN (SELECT User_ID FROM `customer` WHERE Customer_ID = ?)";
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

    // 6. Hàm đếm tổng số khách hàng hoạt động phục vụ phân trang (Khớp quyền 'CUS')
    public int getTotalCustomers(String keyword, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT COUNT(*) FROM `customer` c JOIN `user` u ON c.User_ID = u.User_ID WHERE u.Role_ID = 'CUS'";

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

    // 7. Hàm tìm kiếm, lọc và phân trang Khách hàng (Gộp bảng đổ ra giao diện hiển thị chính)
    public List<Customer> searchAndFilterCustomers(String keyword, String status, int pageIndex, int pageSize) {
        List<Customer> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            String sql = "SELECT c.Customer_ID, c.User_ID, c.Full_Name, c.Phone, c.Default_Address, c.Created_At, "
                    + "u.Email, u.Account_Status "
                    + "FROM `customer` c "
                    + "JOIN `user` u ON c.User_ID = u.User_ID "
                    + "WHERE u.Role_ID = 'CUS'";

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

                // Đồng bộ bốc tiếp trường lấy từ bảng user map vào Object
                c.setEmail(rs.getString("Email"));
                c.setAccountStatus(rs.getString("Account_Status"));
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
