package com.bakeryzone.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * DBContext helper class for establishing JDBC connection to SQL Server.
 * Configured with standard security settings required by newer JDBC drivers.
 */
public class DBContext {

    public static Connection getJDBCConnection() {
        String url = "jdbc:mysql://localhost:3306/bakery?useUnicode=true&characterEncoding=UTF-8";
        String user = "root";
        String password = "1234";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;

    }

    public static void main(String[] args) {
        Connection conn = getJDBCConnection();
        if (conn != null) {
            System.out.println("Thanh cong");
            try {
                java.sql.Statement stmt = conn.createStatement();
                java.sql.ResultSet rs;

                try {
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM `orders`");
                    if (rs.next()) {
                        System.out.println("Orders count: " + rs.getInt(1));
                    }
                } catch (Exception e) {
                    System.out.println("Orders query failed: " + e.getMessage());
                }

                try {
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM `customer`");
                    if (rs.next()) {
                        System.out.println("Customer count: " + rs.getInt(1));
                    }
                } catch (Exception e) {
                    System.out.println("Customer query failed: " + e.getMessage());
                }

                try {
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM `cake_template`");
                    if (rs.next()) {
                        System.out.println("Cake_template count: " + rs.getInt(1));
                    }
                } catch (Exception e) {
                    System.out.println("Cake_template query failed: " + e.getMessage());
                }

                try {
                    rs = stmt.executeQuery("SELECT COUNT(*) FROM `ingredients`");
                    if (rs.next()) {
                        System.out.println("Ingredients count: " + rs.getInt(1));
                    }
                } catch (Exception e) {
                    System.out.println("Ingredients query failed: " + e.getMessage());
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            System.out.println("That bai");
        }
    }

}
