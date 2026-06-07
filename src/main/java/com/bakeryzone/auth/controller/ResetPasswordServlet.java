package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ResetPasswordServlet extends HttpServlet {

    // Không cho vào reset trực tiếp nếu chưa xác thực OTP
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

    // Xử lý đổi mật khẩu mới
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = (String) request.getSession().getAttribute("resetEmail");
        Boolean verified = (Boolean) request.getSession().getAttribute("resetOtpVerified");

        // Nếu chưa qua bước OTP thì không cho reset
        if (email == null || verified == null || !verified) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
            return;
        }

        // Lấy mật khẩu mới từ form reset-password.jsp
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Kiểm tra rỗng
        if (password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ mật khẩu.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra độ dài
        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        // Kiểm tra nhập lại mật khẩu
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Cập nhật mật khẩu mới
        dao.updatePasswordByEmail(email, password);

        // Xóa OTP trong database
        dao.clearOtp(email);

        // Xóa session reset
        request.getSession().removeAttribute("resetEmail");
        request.getSession().removeAttribute("resetOtpVerified");
        request.getSession().removeAttribute("otpType");
        request.getSession().removeAttribute("otpExpireAtMillis");

        // Quay về login
        request.setAttribute("message", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }
}