package com.bakeryzone.controller.auth;

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
        password = password == null ? "" : password;
        confirmPassword = confirmPassword == null ? "" : confirmPassword;

        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("password", password);
        request.setAttribute("confirmPassword", confirmPassword);
        
        String validationError = com.bakeryzone.utils.ValidationUtils.validateRegisterInput(fullName, email, phone, password, confirmPassword);
        if (validationError != null) {
            request.setAttribute("error", validationError);
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
            user.setUserId(com.bakeryzone.utils.IDGenerator.generateUserId("CUSTOMER"));
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

        final String finalEmail = email;
        final String finalOtp = otp;
        new Thread(() -> {
            EmailUtils.sendRegisterOtpEmail(finalEmail, finalOtp);
        }).start();

        request.getSession().setAttribute("otpEmail", email);
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn.");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}