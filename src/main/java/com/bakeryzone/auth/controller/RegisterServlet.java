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

    private static final int NAME_MAX_LENGTH = 100;
    private static final int EMAIL_MAX_LENGTH = 100;
    private static final int PASSWORD_MAX_LENGTH = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        fullName = fullName == null ? "" : fullName.trim();
        email = email == null ? "" : email.trim().toLowerCase();
        phone = phone == null ? "" : phone.trim();
        password = password == null ? "" : password.trim();
        confirmPassword = confirmPassword == null ? "" : confirmPassword.trim();

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);

        if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty()
                || password.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (fullName.length() > NAME_MAX_LENGTH) {
            request.setAttribute("error", "Họ tên không được vượt quá " + NAME_MAX_LENGTH + " ký tự.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (email.length() > EMAIL_MAX_LENGTH) {
            request.setAttribute("error", "Email không được vượt quá " + EMAIL_MAX_LENGTH + " ký tự.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            request.setAttribute("error", "Email không đúng định dạng.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (!phone.matches("^(0|\\+84)[0-9]{9,10}$")) {
            request.setAttribute("error", "Số điện thoại không đúng định dạng.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() > PASSWORD_MAX_LENGTH) {
            request.setAttribute("error", "Mật khẩu không được vượt quá " + PASSWORD_MAX_LENGTH + " ký tự.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtils.hashPassword(password);

        if (hashedPassword == null) {
            request.setAttribute("error", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
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
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

            User pendingUser = new User();
            pendingUser.setFullName(fullName);
            pendingUser.setEmail(email);
            pendingUser.setPassword(hashedPassword);
            pendingUser.setPhone(phone);
            pendingUser.setDefaultAddress(null);
            pendingUser.setOtpCode(otp);
            pendingUser.setOtpExpiry(otpExpiry);

            boolean updated = dao.updateUnverifiedRegisterByEmail(pendingUser);

            if (!updated) {
                request.setAttribute("error", "Không thể cập nhật thông tin đăng ký. Vui lòng thử lại.");
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

        } else {

            User user = new User();
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPassword(hashedPassword);
            user.setPhone(phone);
            user.setDefaultAddress(null);
            user.setRoleId("CUSTOMER");
            user.setVerified(false);
            user.setOtpCode(otp);
            user.setOtpExpiry(otpExpiry);
            user.setAccountStatus("Active");
            user.setActiveStaff(false);

            boolean created = dao.createCustomerAccountForRegister(user);

            if (!created) {
                request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại.");
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }
        }

        boolean sent = EmailUtils.sendRegisterOtpEmail(email, otp);

        if (!sent) {
            request.setAttribute("error", "Không thể gửi mã OTP. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("otpEmail", email);
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn.");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}