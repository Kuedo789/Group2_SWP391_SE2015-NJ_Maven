package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Random;

public class ForgotPasswordServlet extends HttpServlet {

    // Tạo OTP 6 chữ số
    private String generateOtp() {
        return String.format("%06d", new Random().nextInt(1000000));
    }

    // GET thì quay về trang quên mật khẩu
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
    }

    // Xử lý submit email quên mật khẩu
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Lấy email từ forgot-password.jsp
        String email = request.getParameter("email");

        // Kiểm tra rỗng
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Tìm user theo email
        User user = dao.findByEmail(email.trim());

        // Email không tồn tại
        if (user == null) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Tài khoản Google không reset password ở đây
        if (!"LOCAL".equalsIgnoreCase(user.getProvider())) {
            request.setAttribute("error", "Tài khoản này đăng nhập bằng Google, không thể đặt lại mật khẩu tại đây.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Tài khoản bị khóa
        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản của bạn đang bị khóa hoặc không hoạt động.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        // Tạo OTP reset password
        String otp = generateOtp();
        Timestamp otpExpiry = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000);

        // Lưu OTP vào database
        dao.updateOtpByEmail(email.trim(), otp, otpExpiry);

        // Lưu session cho bước xác thực OTP quên mật khẩu
        request.getSession().setAttribute("resetEmail", email.trim());
        request.getSession().setAttribute("otpType", "forgot");
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        // Tạm thời in OTP ra console để test
        System.out.println("OTP quên mật khẩu cho " + email + " là: " + otp);

        request.setAttribute("otpType", "forgot");
        request.setAttribute("message", "Mã OTP đặt lại mật khẩu đã được gửi đến email.");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}