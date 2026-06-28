package com.bakeryzone.controller.auth;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.EmailUtils;
import com.bakeryzone.utils.OtpUtil;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

public class VerifyForgotOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("resend".equalsIgnoreCase(action)) {
            resendForgotOtp(request, response);
            return;
        }

        request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = (String) request.getSession().getAttribute("resetEmail");
        String otp = request.getParameter("otp");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn.Vui lòng nhập lại email.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        otp = otp.trim();

        String otpError = ValidationUtils.validateOtpInput(otp);
        if (otpError != null) {
            request.setAttribute("error", otpError);
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        boolean validOtp = dao.verifyForgotOtp(email, otp);

        if (!validOtp) {
            User user = dao.findByEmail(email);

            if (user == null) {
                request.setAttribute("error", "Không tìm thấy tài khoản.");
            } else if (user.getOtpExpiry() == null || user.getOtpExpiry().before(new Timestamp(System.currentTimeMillis()))) {
                request.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng bấm gửi lại mã.");
            } else {
                request.setAttribute("error", "Mã OTP không đúng. Vui lòng kiểm tra lại.");
            }

            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("resetVerified", true);

        request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
    }

    private void resendForgotOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = (String) request.getSession().getAttribute("resetEmail");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng nhập lại email.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        Long lastResend = (Long) request.getSession().getAttribute("lastOtpResendTime");
        long now = System.currentTimeMillis();
        if (lastResend != null && (now - lastResend) < 180000L) {
            long waitSec = (180000L - (now - lastResend) + 999L) / 1000L;
            long mins = waitSec / 60;
            long secs = waitSec % 60;
            String waitText = mins > 0 ? (mins + " phút " + secs + " giây") : (secs + " giây");
            request.setAttribute("error", "Vui lòng đợi " + waitText + " trước khi yêu cầu gửi lại mã.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }
        request.getSession().setAttribute("lastOtpResendTime", now);

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

        String newOtp = OtpUtil.generateOtp();
        Timestamp newExpiry = OtpUtil.generateExpiryTime();

        boolean updated = dao.updateOtpByEmail(email, newOtp, newExpiry);

        if (!updated) {
            request.setAttribute("error", "Không thể tạo mã OTP mới.Vui lòng nhập lại email.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        boolean sent = EmailUtils.sendForgotPasswordOtpEmail(email, newOtp);

        if (!sent) {
            request.setAttribute("error", "Không thể gửi lại mã OTP. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("otpExpireAtMillis", newExpiry.getTime());
        request.setAttribute("message", "Mã OTP mới đã được gửi đến email của bạn.");

        request.getRequestDispatcher("/auth/verify-forgot-otp.jsp").forward(request, response);
    }
}