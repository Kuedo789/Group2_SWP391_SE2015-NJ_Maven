/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 *
 * @author Nguyễn Hùng
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        boolean updated = userDAO.updateProfile(
                user.getUserId(),
                fullName,
                phone,
                address
        );

        if (updated) {
            user.setFullName(fullName);
            user.setPhone(phone);
            user.setDefaultAddress(address);
            session.setAttribute("user", user);
        }

        boolean wantChangePassword
                = (currentPassword != null && !currentPassword.trim().isEmpty())
                || (newPassword != null && !newPassword.trim().isEmpty())
                || (confirmPassword != null && !confirmPassword.trim().isEmpty());

        if (wantChangePassword) {

            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập mật khẩu hiện tại.");
                request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
                return;
            }

            if (!currentPassword.equals(user.getPassword())) {
                request.setAttribute("errorMessage", "Mật khẩu hiện tại không đúng.");
                request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
                return;
            }

            if (newPassword == null || newPassword.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng nhập mật khẩu mới.");
                request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
                return;
            }

            if (confirmPassword == null || confirmPassword.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Vui lòng xác nhận mật khẩu mới.");
                request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Xác nhận mật khẩu mới không khớp.");
                request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
                return;
            }

            userDAO.updatePasswordByEmail(user.getEmail(), newPassword);

            user.setPassword(newPassword);
            session.setAttribute("user", user);
        }

        if (updated || wantChangePassword) {
            request.setAttribute("successMessage", "Cập nhật thông tin thành công.");
        } else {
            request.setAttribute("errorMessage", "Cập nhật thất bại. Vui lòng thử lại.");
        }

        request.getRequestDispatcher("/common/profile.jsp").forward(request, response);
    }
}
