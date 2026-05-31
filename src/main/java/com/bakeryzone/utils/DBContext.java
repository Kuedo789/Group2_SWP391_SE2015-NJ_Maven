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
    private static final Logger LOGGER = Logger.getLogger(DBContext.class.getName());
    
    // Change these values to match your local SQL Server instance
    private static final String HOST = "localhost";
    private static final String PORT = "1433";
    private static final String DB_NAME = "BarkeryManagerment"; // Hãy đảm bảo tên DB này trùng 100% với SQL Server
    private static final String USER = "sa";
    private static final String PASSWORD = "123";

    /**
     * Obtains a SQL connection using MS SQL Server JDBC driver.
     * * @return Connection instance
     * @throws SQLException if a database error occurs
     * @throws ClassNotFoundException if the driver class is missing
     */
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        try {
            // Load driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            
            // Modern JDBC connection string (requires encrypt and trustServerCertificate config)
            String url = String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=true;trustServerCertificate=true;",
                HOST, PORT, DB_NAME
            );
            
            return DriverManager.getConnection(url, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC Driver not found in classpath.", e);
            throw e;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to connect to the SQL Server database.", e);
            throw e;
        }
    }

    /**
     * Hàm main dùng để test kết nối trực tiếp dưới máy Local
     */
    public static void main(String[] args) {
        System.out.println("=== TIẾN HÀNH KIỂM TRA KẾT NỐI DATABASE ===");
        try {
            Connection conn = DBContext.getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("🎉 KẾT NỐI THÀNH CÔNG RỒI BẠN ƠI!");
                System.out.println("Thông tin kết nối:");
                System.out.println("- Database: " + DB_NAME);
                System.out.println("- User: " + USER);
                
                // Đóng kết nối sau khi test xong
                conn.close();
            }
        } catch (ClassNotFoundException e) {
            System.err.println("❌ LỖI: Thiếu thư viện JDBC Driver trong file pom.xml!");
        } catch (SQLException e) {
            System.err.println("❌ LỖI KẾT NỐI: Hãy kiểm tra lại các yếu tố sau:");
            System.err.println("1. SQL Server đã được bật lên chưa?");
            System.err.println("2. Tài khoản '" + USER + "' và mật khẩu '" + PASSWORD + "' có đúng không?");
            System.err.println("3. Tên Database '" + DB_NAME + "' đã tồn tại trong SQL Server chưa?");
            System.err.println("4. SQL Server đã bật cổng 1433 và cho phép đăng nhập bằng SQL Server Authentication chưa?");
        }
    }
}