package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.utils.EmailUtils;
import com.bakeryzone.utils.OtpUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("resend".equalsIgnoreCase(action)) {
            String email = (String) request.getSession().getAttribute("otpEmail");

            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
                return;
            }

            email = email.trim().toLowerCase();

            String newOtp = OtpUtil.generateOtp();
            Timestamp newExpiry = OtpUtil.generateExpiryTime();

            UserDAO dao = new UserDAO();
            dao.updateOtpByEmail(email, newOtp, newExpiry);

            boolean sent = EmailUtils.sendOtpEmail(email, newOtp);

            if (!sent) {
                request.setAttribute("otpType", "register");
                request.setAttribute("error", "Không thể gửi lại mã OTP. Vui lòng thử lại sau.");
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            request.getSession().setAttribute("otpEmail", email);
            request.getSession().setAttribute("otpType", "register");
            request.getSession().setAttribute("otpExpireAtMillis", newExpiry.getTime());

            request.setAttribute("otpType", "register");
            request.setAttribute("message", "Mã OTP mới đã được gửi đến email của bạn.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
    }

    // Xử lý OTP người dùng nhập để xác thực tài khoản đăng ký
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String otp = request.getParameter("otp");
        String email = (String) request.getSession().getAttribute("otpEmail");

        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
            return;
        }

        email = email.trim().toLowerCase();

        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("otpType", "register");
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        otp = otp.trim();

        if (!otp.matches("\\d{6}")) {
            request.setAttribute("otpType", "register");
            request.setAttribute("error", "Mã OTP phải gồm đúng 6 chữ số.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        boolean validOtp = dao.verifyRegisterOtp(email, otp);

        if (!validOtp) {
            request.setAttribute("otpType", "register");
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        dao.markUserVerifiedAndClearOtp(email);

        request.getSession().removeAttribute("otpEmail");
        request.getSession().removeAttribute("otpType");
        request.getSession().removeAttribute("otpExpireAtMillis");

        request.setAttribute("message", "Xác thực tài khoản thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }
}
