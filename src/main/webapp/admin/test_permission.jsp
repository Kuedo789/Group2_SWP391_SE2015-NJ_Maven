<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bakeryzone.dao.PermissionDAO" %>
<%@ page import="com.bakeryzone.utils.DBContext" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Permission Test & DB Sync Utility</title>
</head>
<body style="font-family: Arial, sans-serif; padding: 30px; background-color: #f4f6f9; color: #333;">
    <div style="max-width: 900px; margin: 0 auto; background: #fff; padding: 25px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.08);">
        
        <h2 style="color: #3f5f36; border-bottom: 2px solid #3f5f36; padding-bottom: 10px; margin-top: 0;">
            🛠️ Permission Test & DB Sync Utility
        </h2>
        
        <h3>1. Database Connection Status:</h3>
        <%
            try (Connection conn = DBContext.getJDBCConnection()) {
                if (conn != null) {
                    out.println("<p style='color: green; font-weight: bold;'>✅ Connected to Database successfully.</p>");
                } else {
                    out.println("<p style='color: red; font-weight: bold;'>❌ Failed to connect to Database.</p>");
                }
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error: " + e.getMessage() + "</p>");
            }
        %>

        <!-- SECTION: SYNC UTILITY -->
        <h3>2. Database Sync Utility:</h3>
        <p>Click the button below to update the <code>Role_ID</code> of all users based on their <code>User_ID</code> prefix:</p>
        <ul>
            <li><code>ADMIN_...</code> &rarr; <code>ADMIN</code></li>
            <li><code>CUS_...</code> &rarr; <code>CUSTOMER</code></li>
            <li><code>SHIP_...</code> &rarr; <code>SHIPPER</code></li>
            <li><code>STAFF_...</code> &rarr; <code>STAFF</code></li>
        </ul>

        <%
            String syncAction = request.getParameter("sync");
            if ("run".equals(syncAction)) {
                String sql = "UPDATE `user` SET Role_ID = CASE " +
                             "    WHEN User_ID LIKE 'ADMIN%' THEN 'ADMIN' " +
                             "    WHEN User_ID LIKE 'CUS%' THEN 'CUSTOMER' " +
                             "    WHEN User_ID LIKE 'SHIP%' THEN 'SHIPPER' " +
                             "    WHEN User_ID LIKE 'STAFF%' THEN 'STAFF' " +
                             "    ELSE Role_ID " +
                             "END";
                try (Connection conn = DBContext.getJDBCConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {
                    int rows = ps.executeUpdate();
                    out.println("<div style='background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: bold;'>");
                    out.println("🎉 Success! Synchronized " + rows + " user accounts in database successfully.");
                    out.println("</div>");
                } catch (Exception e) {
                    out.println("<div style='background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px;'>");
                    out.println("❌ Execution error: " + e.getMessage());
                    out.println("</div>");
                }
            }
        %>

        <form action="" method="GET" style="margin-bottom: 25px;">
            <input type="hidden" name="sync" value="run" />
            <button type="submit" style="background-color: #3f5f36; color: white; padding: 12px 20px; border: none; border-radius: 5px; font-size: 14px; font-weight: bold; cursor: pointer; transition: 0.2s;">
                ⚡ Sync Role_ID with User_ID Prefix Now
            </button>
        </form>

        <h3>3. Active Permissions for role 'STAFF':</h3>
        <table border="1" cellpadding="8" cellspacing="0" style="width: 100%; border-collapse: collapse; margin-bottom: 25px;">
            <tr bgcolor="#3f5f36" style="color: white;">
                <th>Role_ID</th>
                <th>Screen_ID</th>
                <th>Screen_Name</th>
                <th>Endpoint_URL</th>
            </tr>
            <%
                try (Connection conn = DBContext.getJDBCConnection()) {
                    String sql = "SELECT rp.Role_ID, rp.Screen_ID, s.Screen_Name, s.Endpoint_URL " +
                                 "FROM role_permission rp " +
                                 "JOIN screen_permission s ON rp.Screen_ID = s.Screen_ID " +
                                 "WHERE rp.Role_ID = 'STAFF'";
                    try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
                        boolean hasData = false;
                        while (rs.next()) {
                            hasData = true;
                            out.println("<tr>");
                            out.println("<td>" + rs.getString("Role_ID") + "</td>");
                            out.println("<td>" + rs.getString("Screen_ID") + "</td>");
                            out.println("<td>" + rs.getString("Screen_Name") + "</td>");
                            out.println("<td>" + rs.getString("Endpoint_URL") + "</td>");
                            out.println("</tr>");
                        }
                        if (!hasData) {
                            out.println("<tr><td colspan='4' style='text-align: center; color: #888;'>No permissions assigned to STAFF yet.</td></tr>");
                        }
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4' style='color: red;'>Error: " + e.getMessage() + "</td></tr>");
                }
            %>
        </table>

        <h3>4. Test checkPermission() Java Logic for STAFF:</h3>
        <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #3f5f36; line-height: 1.6;">
            <%
                PermissionDAO permissionDAO = new PermissionDAO();
                String testRole = "STAFF";
                String[] testUrls = {
                    "/admin/orders?action=list",
                    "/admin/orders",
                    "/admin/reviews?action=list",
                    "/admin/reviews"
                };
                
                for (String url : testUrls) {
                    boolean hasPerm = permissionDAO.checkUrlPermission(testRole, url);
                    out.println("Check: <b>" + testRole + "</b> for URL: <b>" + url + "</b> &rarr; Result: <b style='color: " + (hasPerm ? "green" : "red") + ";'>" + hasPerm + "</b><br/>");
                }
            %>
        </div>
        
    </div>
</body>
</html>
