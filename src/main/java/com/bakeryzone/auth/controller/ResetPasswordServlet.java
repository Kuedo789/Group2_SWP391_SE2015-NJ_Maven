package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.utils.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = (String) request.getSession().getAttribute("resetEmail");
        Boolean verified = (Boolean) request.getSession().getAttribute("resetOtpVerified");

        if (email == null || verified == null || !verified) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
            return;
        }

        request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = (String) request.getSession().getAttribute("resetEmail");
        Boolean verified = (Boolean) request.getSession().getAttribute("resetOtpVerified");

        if (email == null || verified == null || !verified) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
            return;
        }

        email = email.trim().toLowerCase();

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ mật khẩu.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        password = password.trim();
        confirmPassword = confirmPassword.trim();

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (password.length() > 20) {
            request.setAttribute("error", "Mật khẩu không được vượt quá 20 ký tự.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        String hashedPassword = PasswordUtils.hashPassword(password);

        if (hashedPassword == null) {
            request.setAttribute("error", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        dao.updatePasswordByEmail(email, hashedPassword);

        request.getSession().removeAttribute("resetEmail");
        request.getSession().removeAttribute("resetOtpVerified");
        request.getSession().removeAttribute("otpType");
        request.getSession().removeAttribute("otpExpireAtMillis");

        request.setAttribute("message", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }
}