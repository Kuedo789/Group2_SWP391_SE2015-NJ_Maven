/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.PermissionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 *
 * @author Asus
 */

@WebServlet(name = "RolePermissionServlet", urlPatterns = {"/admin/role-permissions"})

public class RolePermissionServlet extends HttpServlet {

    private final PermissionDAO permissionDAO = new PermissionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String currentRoleId = request.getParameter("roleId");
        if (currentRoleId == null || currentRoleId.trim().isEmpty()) {
            currentRoleId = "ADMIN";
        }

        // 2. Kiểm tra xem người dùng có thực hiện hành động bấm On/Off không
        String action = request.getParameter("action");
        String screenId = request.getParameter("screenId");
        if (action != null && screenId != null) {
            // Gọi xuống DAO để thực hiện INSERT hoặc DELETE tương ứng
            permissionDAO.togglePermission(currentRoleId, screenId, action);

            // Xử lý xong thì chuyển hướng (Redirect) quay lại chính trang này để cập nhật giao diện mới nhất
            response.sendRedirect(request.getContextPath() + "/admin/role-permissions?roleId=" + currentRoleId);
            return;
        }

        // 3. Đẩy danh sách các Roles và danh sách Màn hình kèm trạng thái On/Off ra trang JSP
        request.setAttribute("ALL_ROLES", permissionDAO.getAllRoles());
        request.setAttribute("SCREEN_LIST", permissionDAO.getScreensWithStatus(currentRoleId));
        request.setAttribute("CURRENT_ROLE_ID", currentRoleId);

        // Chuyển tiếp (Forward) dữ liệu sang file JSP ở Bước 5
        request.getRequestDispatcher("/admin/permissionList.jsp").forward(request, response);
    }


/**
 * Handles the HTTP <code>POST</code> method.
 *S
 * @param request servlet request
 * @param response servlet response
 * @throws ServletException if a servlet-specific error occurs
 * @throws IOException if an I/O error occurs
 */
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
