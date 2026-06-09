package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.EmailUtils;
import com.bakeryzone.utils.OtpUtil;
import com.bakeryzone.utils.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;

public class RegisterServlet extends HttpServlet {

    private static final int name_max_length = 25;
    private static final int email_max_length = 100;
    private static final int password_max_length = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        fullName = fullName == null ? null : fullName.trim();
        email = email == null ? null : email.trim().toLowerCase();
        password = password == null ? null : password.trim();
        confirmPassword = confirmPassword == null ? null : confirmPassword.trim();

        if (fullName == null || fullName.isEmpty()
                || email == null || email.isEmpty()
                || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (fullName.length() > name_max_length) {
            request.setAttribute("error", "Họ tên không được vượt quá " + name_max_length + " ký tự.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (email.length() > email_max_length) {
            request.setAttribute("error", "Email không được vượt quá " + email_max_length + " ký tự.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Email không đúng định dạng.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() > password_max_length) {
            request.setAttribute("error", "Mật khẩu không được vượt quá " + password_max_length + " ký tự.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtils.hashPassword(password);

        if (hashedPassword == null) {
            request.setAttribute("error", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        String otp = OtpUtil.generateOtp();
        Timestamp otpExpiry = OtpUtil.generateExpiryTime();

        User existingUser = dao.findByEmail(email);

        if (existingUser != null) {

            if (existingUser.isVerified()) {
                request.setAttribute("error", "Email này đã được đăng ký. Vui lòng đăng nhập.");
                request.setAttribute("fullName", fullName);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

            User pendingUser = new User();
            pendingUser.setFullName(fullName);
            pendingUser.setEmail(email);
            pendingUser.setPassword(hashedPassword);
            pendingUser.setPhone(null);
            pendingUser.setOtpCode(otp);
            pendingUser.setOtpExpiry(otpExpiry);

            dao.updateUnverifiedRegisterByEmail(pendingUser);

            boolean sent = EmailUtils.sendOtpEmail(email, otp);

            if (!sent) {
                request.setAttribute("error", "Không thể gửi mã OTP. Vui lòng kiểm tra email hoặc thử lại sau.");
                request.setAttribute("fullName", fullName);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

            request.setAttribute("message", "Email này chưa xác thực. Mã OTP mới đã được gửi đến email của bạn.");

        } else {

            User user = new User();
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPassword(hashedPassword);
            user.setPhone(null);
            user.setRoleId("CUS");
            user.setVerified(false);
            user.setOtpCode(otp);
            user.setOtpExpiry(otpExpiry);
            user.setProvider("LOCAL");
            user.setProviderId(null);
            user.setAccountStatus("Active");
            user.setActiveStaff(false);

            boolean created = dao.createLocalUserForRegister(user);

            if (!created) {
                request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại.");
                request.setAttribute("fullName", fullName);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

            boolean sent = EmailUtils.sendOtpEmail(email, otp);

            if (!sent) {
                request.setAttribute("error", "Tạo tài khoản thành công nhưng không thể gửi mã OTP. Vui lòng bấm gửi lại OTP hoặc thử lại sau.");

                request.getSession().setAttribute("otpEmail", email);
                request.getSession().setAttribute("otpType", "register");
                request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

                request.setAttribute("otpType", "register");
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                return;
            }

            request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn.");
        }

        request.getSession().setAttribute("otpEmail", email);
        request.getSession().setAttribute("otpType", "register");
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        request.setAttribute("otpType", "register");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}
