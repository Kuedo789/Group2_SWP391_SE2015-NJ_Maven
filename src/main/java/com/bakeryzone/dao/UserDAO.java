/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.dao;

import com.bakeryzone.utils.DBContext;

import com.bakeryzone.model.User;
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
        List<User> list = new ArrayList<>();

        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "Select u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, u.Role_ID, u.Account_Status, r.Role_Name " + "FROM user u JOIN role r ON u.Role_ID = r.Role_ID";
            conn = db.getJDBCConnection(); //mo cong ket noi
            ps = conn.prepareStatement(sql); //dua cau lenh sql vao duong truyen
            rs = ps.executeQuery(); //execute va nhan ket qua tu bien rs

            while (rs.next() == true) { //doc du lieu tung dong tu tren xuong duoi
                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
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
            String sql = "INSERT INTO user (User_ID, Full_Name, Email, Password, Phone, Role_ID, Account_Status) VALUES (?,?,?,?,?,?,?)";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getUserId());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRoleId());
            ps.setString(7, "Active");

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
    public void deleteUser(String id) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            String sql = "DELETE FROM user WHERE User_ID = ?";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, id);

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
    public User getUserById(String id) {
        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        User u = null;

        try {
            String sql = "SELECT u.*, r.Role_Name FROM user u JOIN role r ON u.Role_ID = r.Role_ID WHERE u.User_ID = ?";
            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, id);

            rs = ps.executeQuery();

            if (rs.next() == true) {
                u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
                u.setRoleName(rs.getString("Role_Name"));
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
            String sql = "UPDATE user SET Full_Name = ?, Email = ?, Password = ?, Phone = ?, Role_ID = ?, Account_Status = ? WHERE User_ID = ?";

            conn = db.getJDBCConnection();
            ps = conn.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRoleId());
            ps.setString(6, user.getAccountStatus());
            ps.setString(7, user.getUserId());

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

    public List<User> searchAndFilterUsers(String keyword, String roleId, String status) {
        List<User> list = new ArrayList<>();

        DBContext db = new DBContext();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT u.User_ID, u.Full_Name, u.Email, u.Password, u.Phone, u.Role_ID, u.Account_Status, r.Role_Name "
                    + "FROM user u JOIN role r ON u.Role_ID = r.Role_ID WHERE 1=1";

            if (keyword != null) {
                sql += " AND (u.Full_Name LIKE ? OR u.Email LIKE ?)";
            }
            if (roleId != null) {
                sql += " AND u.Role_ID = ?";
            }
            if (status != null) {
                sql += " AND u.Account_Status = ?";
            }

            conn = db.getJDBCConnection(); //mo cong ket noi
            ps = conn.prepareStatement(sql); //dua cau lenh sql vao duong truyen

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

            rs = ps.executeQuery(); //execute va nhan ket qua tu bien rs

            while (rs.next() == true) { //doc du lieu tung dong tu tren xuong duoi
                User u = new User();
                u.setUserId(rs.getString("User_ID"));
                u.setFullName(rs.getString("Full_Name"));
                u.setEmail(rs.getString("Email"));
                u.setPassword(rs.getString("Password"));
                u.setPhone(rs.getString("Phone"));
                u.setRoleId(rs.getString("Role_ID"));
                u.setAccountStatus(rs.getString("Account_Status"));
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

}
