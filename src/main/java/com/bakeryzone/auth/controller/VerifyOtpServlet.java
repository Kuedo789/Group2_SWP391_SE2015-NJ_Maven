package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.Random;

public class VerifyOtpServlet extends HttpServlet {

    // Tạo OTP 6 chữ số
    private String generateOtp() {
        return String.format("%06d", new Random().nextInt(1000000));
    }

    // Xử lý gửi lại OTP bằng link ?action=resend
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Nếu người dùng bấm gửi lại OTP
        if ("resend".equalsIgnoreCase(action)) {

            // Lấy email đang xác thực từ session
            String email = (String) request.getSession().getAttribute("otpEmail");

            // Nếu không có email trong session thì quay lại đăng ký
            if (email == null) {
                response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
                return;
            }

            // Tạo OTP mới
            String newOtp = generateOtp();
            Timestamp newExpiry = new Timestamp(System.currentTimeMillis() + 5 * 60 * 1000);

            // Cập nhật OTP mới vào database
            UserDAO dao = new UserDAO();
            dao.updateOtpByEmail(email, newOtp, newExpiry);

            // Cập nhật lại thời gian đếm ngược trên JSP
            request.getSession().setAttribute("otpExpireAtMillis", newExpiry.getTime());

            // Tạm thời in OTP ra console để test
            System.out.println("OTP đăng ký mới cho " + email + " là: " + newOtp);

            request.setAttribute("otpType", "register");
            request.setAttribute("message", "Mã OTP mới đã được gửi lại.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // Nếu GET bình thường thì quay về đăng ký
        response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
    }

    // Xử lý khi người dùng nhập OTP và bấm xác nhận
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Lấy OTP người dùng nhập
        String otp = request.getParameter("otp");

        // Lấy email đang xác thực từ session
        String email = (String) request.getSession().getAttribute("otpEmail");

        // Nếu mất session thì bắt đăng ký lại
        if (email == null) {
            response.sendRedirect(request.getContextPath() + "/auth/register.jsp");
            return;
        }

        // Kiểm tra OTP rỗng
        if (otp == null || otp.trim().isEmpty()) {
            request.setAttribute("otpType", "register");
            request.setAttribute("error", "Vui lòng nhập mã OTP.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Kiểm tra OTP đúng/sai và còn hạn không
        boolean validOtp = dao.verifyOtp(email, otp.trim());

        // Nếu OTP sai hoặc hết hạn thì ở lại trang OTP
        if (!validOtp) {
            request.setAttribute("otpType", "register");
            request.setAttribute("error", "Mã OTP không đúng hoặc đã hết hạn.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        // OTP đúng thì đánh dấu user đã xác thực
        dao.markUserVerified(email);

        // Xóa OTP trong database
        dao.clearOtp(email);

        // Xóa session liên quan OTP
        request.getSession().removeAttribute("otpEmail");
        request.getSession().removeAttribute("otpType");
        request.getSession().removeAttribute("otpExpireAtMillis");

        // Chuyển sang login
        request.setAttribute("message", "Xác thực tài khoản thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }
}