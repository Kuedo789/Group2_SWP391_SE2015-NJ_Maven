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

        String action = request.getParameter("action");
        String screenId = request.getParameter("screenId");
        String isAjax = request.getHeader("X-Requested-With");

        if ("delete-feature".equals(action)) {
            String id = request.getParameter("id");
            if (permissionDAO.deleteScreen(id)) {
                request.getSession().setAttribute("successMessage", "Xóa mềm (ẩn) tính năng khỏi hệ thống thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Xóa tính năng thất bại!");
            }
            response.sendRedirect(request.getContextPath() + "/admin/role-permissions?roleId=" + currentRoleId);
            return;
        }

        if (action != null && screenId != null && ("on".equals(action) || "off".equals(action))) {
            boolean isSuccess = permissionDAO.togglePermission(currentRoleId, screenId, action);

            if ("XMLHttpRequest".equals(isAjax)) {
                response.setContentType("text/plain");
                response.setCharacterEncoding("UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    if (isSuccess) {
                        out.print("SUCCESS");
                    } else {
                        out.print("FAILED_DB");
                    }
                }
                return;
            }
            response.sendRedirect(request.getContextPath() + "/admin/role-permissions?roleId=" + currentRoleId);
            return;
        }

        request.setAttribute("ALL_ROLES", permissionDAO.getAllRoles());
        request.setAttribute("SCREEN_LIST", permissionDAO.getScreensWithStatus(currentRoleId));
        request.setAttribute("CURRENT_ROLE_ID", currentRoleId);

        request.getRequestDispatcher("/admin/permissionList.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method. S
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String currentRoleId = request.getParameter("roleId");
        if (currentRoleId == null || currentRoleId.trim().isEmpty()) {
            currentRoleId = "ADMIN";
        }

        if ("add-feature".equals(action)) {
            String screenId = request.getParameter("screenId");
            String screenName = request.getParameter("screenName");
            String endpointUrl = request.getParameter("endpointUrl");

            boolean isSuccess = permissionDAO.insertScreen(screenId, screenName, endpointUrl);
            if (isSuccess) {
                request.getSession().setAttribute("successMessage", "Khai báo tính năng hệ thống mới thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Thêm thất bại! Mã ID tính năng đã tồn tại.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/role-permissions?roleId=" + currentRoleId);
            return;
        } 
        else if ("edit-feature".equals(action)) {
            String screenId = request.getParameter("screenId");
            String screenName = request.getParameter("screenName");
            String endpointUrl = request.getParameter("endpointUrl");

            boolean isSuccess = permissionDAO.updateScreen(screenId, screenName, endpointUrl);
            if (isSuccess) {
                request.getSession().setAttribute("successMessage", "Cập nhật thông tin tính năng thành công!");
            } else {
                request.getSession().setAttribute("errorMessage", "Cập nhật tính năng thất bại! Vui lòng kiểm tra lại.");
            }
            response.sendRedirect(request.getContextPath() + "/admin/role-permissions?roleId=" + currentRoleId);
            return;
        }

        doGet(request, response);
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
