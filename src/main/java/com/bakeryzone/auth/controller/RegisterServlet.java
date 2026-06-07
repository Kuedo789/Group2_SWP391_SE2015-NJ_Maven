<<<<<<< Updated upstream
package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
=======
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.auth.controller;
import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import java.io.IOException;
import java.io.PrintWriter;
>>>>>>> Stashed changes
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
<<<<<<< Updated upstream
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Random;
=======
import java.sql.Timestamp;
>>>>>>> Stashed changes

public class RegisterServlet extends HttpServlet {

<<<<<<< Updated upstream
    // Tạo OTP 6 chữ số
    private String generateOtp() {
        return String.format("%06d", new Random().nextInt(1000000));
    }

    // Khi truy cập /register bằng GET thì chuyển về trang register.jsp
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
=======
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
        
        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
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
        
          UserDAO dao = new UserDAO();

        if (dao.isEmailExists(email)) {
            request.setAttribute("error", "Email này đã được đăng ký.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }
        String otp = generateOtp();
        Timestamp otpExpiry = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000);

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPassword(password); // Nếu bạn có PasswordUtils thì hash ở đây
        user.setPhone(null);
        user.setRoleId("CUS");
        user.setVerified(false);
        user.setOtpCode(otp);
        user.setOtpExpiry(otpExpiry);
        user.setProvider("LOCAL");
        user.setProviderId(null);
        user.setAccountStatus("Active");
        user.setActiveStaff(false);
    }

    @Override
    public String getServletInfo() {
        return "Short description";
>>>>>>> Stashed changes
    }

    // Khi submit form đăng ký
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Đọc tiếng Việt đúng
        request.setCharacterEncoding("UTF-8");

        // Lấy dữ liệu từ form register.jsp
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Kiểm tra rỗng
        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ thông tin.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // Kiểm tra mật khẩu nhập lại
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        // Kiểm tra độ dài mật khẩu
        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.setAttribute("fullName", fullName);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Tạo OTP và thời gian hết hạn 5 phút
        String otp = generateOtp();
        Timestamp otpExpiry = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000);

        // Kiểm tra email đã có trong database chưa
        User existingUser = dao.findByEmail(email.trim());

        if (existingUser != null) {

            // Nếu email đã xác thực rồi thì không cho đăng ký lại
            if (existingUser.isVerified()) {
                request.setAttribute("error", "Email này đã được đăng ký. Vui lòng đăng nhập.");
                request.setAttribute("fullName", fullName);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/auth/register.jsp").forward(request, response);
                return;
            }

            // Nếu email có rồi nhưng chưa xác thực OTP
            // thì cập nhật lại thông tin và gửi OTP mới
            User pendingUser = new User();
            pendingUser.setFullName(fullName.trim());
            pendingUser.setEmail(email.trim());
            pendingUser.setPassword(password);
            pendingUser.setPhone(null);
            pendingUser.setOtpCode(otp);
            pendingUser.setOtpExpiry(otpExpiry);

            dao.updateUnverifiedRegisterByEmail(pendingUser);

            // Lưu thông tin OTP vào session để trang OTP dùng
            request.getSession().setAttribute("otpEmail", email.trim());
            request.getSession().setAttribute("otpType", "register");
            request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

            // Tạm thời in OTP ra console để test
            System.out.println("OTP đăng ký mới cho " + email + " là: " + otp);

            request.setAttribute("otpType", "register");
            request.setAttribute("message", "Email này chưa xác thực. Mã OTP mới đã được gửi lại.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Nếu email chưa tồn tại thì tạo user mới
        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim());
        user.setPassword(password);
        user.setPhone(null);
        user.setRoleId("CUS");
        user.setVerified(false);
        user.setOtpCode(otp);
        user.setOtpExpiry(otpExpiry);
        user.setProvider("LOCAL");
        user.setProviderId(null);
        user.setAccountStatus("Active");
        user.setActiveStaff(false);

        dao.createLocalUserForRegister(user);

        // Lưu session để VerifyOtpServlet biết email nào đang xác thực
        request.getSession().setAttribute("otpEmail", email.trim());
        request.getSession().setAttribute("otpType", "register");
        request.getSession().setAttribute("otpExpireAtMillis", otpExpiry.getTime());

        // Tạm thời in OTP ra console để test
        System.out.println("OTP đăng ký cho " + email + " là: " + otp);

        request.setAttribute("otpType", "register");
        request.setAttribute("message", "Mã OTP đã được gửi đến email của bạn.");
        request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
    }
}