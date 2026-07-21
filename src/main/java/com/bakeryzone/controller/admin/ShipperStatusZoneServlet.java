package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.StaffDAO;
import com.bakeryzone.model.Staff;
import com.bakeryzone.model.User;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet("/api/v1/shipper/status-zone")
public class ShipperStatusZoneServlet extends HttpServlet {

    private final StaffDAO staffDAO = new StaffDAO();

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if ("PATCH".equalsIgnoreCase(request.getMethod())) {
            doPatch(request, response);
        } else {
            super.service(request, response);
        }
    }

    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        JsonObject jsonResponse = new JsonObject();

        // 1. Session verification
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Bạn cần đăng nhập trước!");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // 2. Role verification
        String roleId = user.getRoleId().trim().toUpperCase();
        if (!"SHIPPER".equals(roleId) && !"ADMIN".equals(roleId)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Bạn không có quyền thực hiện chức năng này!");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // 3. Read body payload
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        String jsonStr = sb.toString();
        if (jsonStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Yêu cầu rỗng!");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        try {
            JsonObject payload = JsonParser.parseString(jsonStr).getAsJsonObject();
            boolean isActive = payload.has("isActive") && payload.get("isActive").getAsBoolean();
            String workingZoneId = (payload.has("workingZoneId") && !payload.get("workingZoneId").isJsonNull()) 
                                   ? payload.get("workingZoneId").getAsString() : null;

            // Fetch Staff profile
            Staff staff = staffDAO.getStaffByUserId(user.getUserId());
            if (staff == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Không tìm thấy hồ sơ nhân viên giao hàng!");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Update status and zone
            boolean updateSuccess = staffDAO.updateShipperStatusAndZone(staff.getStaffId(), isActive, workingZoneId);
            if (updateSuccess) {
                // If workingZoneId was updated, save it back into staff profile object
                if (workingZoneId != null && !workingZoneId.trim().isEmpty()) {
                    staff.setManagedZone(workingZoneId);
                }
                staff.setIsActiveStaff(isActive);
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Cập nhật thành công!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Cập nhật cơ sở dữ liệu thất bại!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Dữ liệu JSON không hợp lệ: " + e.getMessage());
        }

        response.getWriter().write(jsonResponse.toString());
    }
}
