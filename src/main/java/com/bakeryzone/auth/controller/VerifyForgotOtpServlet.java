package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Random;

public class VerifyForgotOtpServlet extends HttpServlet {

    // Tạo OTP 6 chữ số
    private String generateOtp() {
        return String.format("%06d", new Random().nextInt(1000000));
    }

    // Xử lý gửi lại OTP quên mật khẩu
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("resend".equalsIgnoreCase(action)) {
            String email = (String) request.getSession().getAttribute("resetEmail");

            if (email == null) {
                response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
                return;
            }

            String newOtp = generateOtp();
            Timestamp newExpiry = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000);

            UserDAO dao = new UserDAO();
            dao.updateOtpByEmail(email, newOtp, newExpiry);

            request.getSession().setAttribute("otpExpireAtMillis", newExpiry.getTime());

            System.out.println("OTP quên mật khẩu mới cho " + email + " là: " + newOtp);

            request.setAttribute("otpType", "forgot");
            request.setAttribute("message", "Mã OTP mới đã được gửi lại.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
    }

    // Xác thực OTP quên mật khẩu
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String otp = request.getParameter("otp");
        String email = (String) request.getSession().getAttribute("resetEmail");

        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/auth/forgot-password.jsp");
            return;
        }

        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("otpType", "forgot");
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Kiểm tra OTP đúng/sai
        boolean validOtp = dao.verifyOtp(email, otp.trim());

        if (!validOtp) {
            request.setAttribute("otpType", "forgot");
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Đánh dấu đã xác thực OTP quên mật khẩu
        request.getSession().setAttribute("resetOtpVerified", true);
        request.getSession().removeAttribute("otpExpireAtMillis");

        // Chuyển sang trang đặt lại mật khẩu
        response.sendRedirect(request.getContextPath() + "/auth/reset-password.jsp");
    }
}