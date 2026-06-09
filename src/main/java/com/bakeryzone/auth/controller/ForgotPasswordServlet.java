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
        response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        UserDAO dao = new UserDAO();

        User user = dao.findByEmail(email);

        if (user == null) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!"LOCAL".equalsIgnoreCase(user.getProvider())) {
            request.setAttribute("error", "Tài khoản này đăng nhập bằng Google, không thể đặt lại mật khẩu tại đây.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!user.isVerified()) {
            request.setAttribute("error", "Tài khoản này chưa xác thực OTP đăng ký.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản của bạn đang bị khóa hoặc không hoạt động.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        String otp = OtpUtil.generateOtp();
        Timestamp otpExpiry = OtpUtil.generateExpiryTime();

        dao.updateOtpByEmail(email, otp, otpExpiry);

        boolean sent = EmailUtils.sendOtpEmail(email, otp);

        if (!sent) {
            dao.clearOtp(email);
            request.setAttribute("error", "Không thể gửi mã OTP. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("resetEmail", email);
        request.getSession().setAttribute("otpType", "forgot");
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        request.setAttribute("otpType", "forgot");
        request.setAttribute("message", "Mã OTP đặt lại mật khẩu đã được gửi đến email.");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}
