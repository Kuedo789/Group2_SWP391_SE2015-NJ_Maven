/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.bakery_swp;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Asus
 */
public class DBContext {

    public static Connection getJDBCConnection() {
        String url = "jdbc:mysql://localhost:3306/bakery_db";
        String user = "root"; 
        String password = "1234";
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, user, password); //quan li driver(tao ra 1 ket noi tu netbean sang my sql
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
