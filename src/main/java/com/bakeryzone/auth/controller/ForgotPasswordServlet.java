package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.EmailUtils;
import com.bakeryzone.utils.OtpUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        email = email == null ? "" : email.trim().toLowerCase();

        request.setAttribute("email", email);

        if (email.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Email không đúng định dạng.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email);

        if (user == null) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!user.isVerified()) {
            request.setAttribute("error", "Tài khoản chưa xác thực OTP đăng ký.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản đang bị khóa hoặc không hoạt động.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        String otp = OtpUtil.generateOtp();
        Timestamp otpExpiry = OtpUtil.generateExpiryTime();

        boolean updated = dao.updateOtpByEmail(email, otp, otpExpiry);

        if (!updated) {
            request.setAttribute("error", "Không thể tạo mã OTP. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        boolean sent = EmailUtils.sendForgotPasswordOtpEmail(email, otp);

        if (!sent) {
            dao.clearOtp(email);
            request.setAttribute("error", "Không thể gửi mã OTP. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("resetEmail", email);
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        request.setAttribute("message", "Mã OTP đặt lại mật khẩu đã được gửi đến email của bạn.");
        request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
    }
}