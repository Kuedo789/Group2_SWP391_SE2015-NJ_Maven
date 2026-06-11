package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class VerifyForgotOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = (String) request.getSession().getAttribute("resetEmail");
        String otp = request.getParameter("otp");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        otp = otp.trim();

        if (!otp.matches("\\d{6}")) {
            request.setAttribute("error", "Mã OTP phải gồm 6 chữ số.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        boolean validOtp = dao.verifyForgotOtp(email, otp);

        if (!validOtp) {
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("resetVerified", true);

        request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
    }
}