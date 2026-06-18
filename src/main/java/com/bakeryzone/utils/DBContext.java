package com.bakeryzone.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
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
        if(conn!= null){
            System.out.println("Thanh cong");
             
        } else {
            System.out.println("That bai");
        }
    }
    
}