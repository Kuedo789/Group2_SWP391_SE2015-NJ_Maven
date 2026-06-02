/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import com.mycompany.bakery_swp.DBContext;
import entities.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Asus
 */
public class UserDAO {

    //ham lay toan bo danh sach user kem theo role tuong ung
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<User>();

        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "Select u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, u.Role_ID, r.Role_Name " + "FROM User u JOIN Role r ON u.Role_ID = r.Role_ID";
            conn = db.getJDBCConnection(); //mo cong ket noi
            ps = conn.prepareStatement(sql); //dua cau lenh sql vao duong truyen
            rs = ps.executeQuery(); //execute va nhan ket qua tu bien rs

            while (rs.next() == true) { //doc du lieu tung dong tu tren xuong duoi
                User u = new User();
                u.setUserId(rs.getInt("User_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setRoleName(rs.getString("Role_Name"));

                list.add(u); //truyen du lieu vao trong list

            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
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

        return list;
    }

    //ham them moi 1 tai khoan
    public void insertUser(User user) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "INSERT INTO User (Full_Name, Email, Password, Phone, Role_ID) VALUES (?,?,?,?,?)";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRoleId());

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
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

    //ham xoa tai khoan theo id
    public void deleteUser(int id) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "DELETE FROM User WHERE User_ID = ?";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setInt(1, id);

            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
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

    //ham tim user theo id
    public User getUserById(int id) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        User u = null;

        try {
            String sql = "SELECT * FROM User WHERE User_ID = ?";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            rs = ps.executeQuery();

            if (rs.next() == true) {
                u = new User();
                u.setUserId(rs.getInt("User_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("Role_ID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
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
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        return u;
    }

    //ham update thong tin user
    public void updateUser(User user) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "UPDATE User SET Full_Name = ?, Email = ?, Password = ?, Phone = ?, Role_ID = ? WHERE User_ID = ?";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRoleId());

            ps.setInt(6, user.getUserId());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {

                if (ps != null) {
                    ps.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    public List<User> searchAndFilterUsers(String keyword, String roleId) {
        List<User> list = new java.util.ArrayList<>();
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT u.*, r.roleName FROM Users u JOIN Roles r ON u.roleId = r.roleId WHERE 1=1";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (u.fullName LIKE ? OR u.email LIKE ?)";
        }
        if (roleId != null && !roleId.trim().isEmpty()) {
            sql += " AND u.roleId = ?";
        }

        try {
            conn = new DBContext().getJDBCConnection();
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
                User u = new User();
                u.setUserId(rs.getInt("userId"));
                u.setFullName(rs.getString("fullName"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("roleId"));
                u.setRoleName(rs.getString("roleName"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
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
            }
        }
        return list;
    }

}
