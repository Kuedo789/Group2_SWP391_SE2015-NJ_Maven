import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/bakery?useUnicode=true&characterEncoding=UTF-8";
        String user = "root";
        String password = "1234";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, password)) {
                System.out.println("Connection successful!");

                try (Statement stmt = conn.createStatement()) {
                    System.out.println("\n--- Category query check ---");
                    String query = "SELECT Category_ID, Category_Name, Description, "
                            + "CASE WHEN Category_ID LIKE 'CAT-ACC-%' THEN 'Phụ kiện' ELSE 'Sản phẩm chính' END AS Category_Type, enable, image_url AS Icon_URL "
                            + "FROM product_category "
                            + "ORDER BY Category_ID";
                    
                    try (ResultSet rs = stmt.executeQuery(query)) {
                        int count = 0;
                        while (rs.next()) {
                            count++;
                            if (count <= 5) {
                                System.out.printf("ID: %s | Name: %s | Icon_URL: %s\n",
                                        rs.getString("Category_ID"),
                                        rs.getString("Category_Name"),
                                        rs.getString("Icon_URL"));
                            }
                        }
                        System.out.println("Total categories returned: " + count);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
