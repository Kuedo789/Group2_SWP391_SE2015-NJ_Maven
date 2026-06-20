package com.bakeryzone.controller.auth;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.utils.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ResetPasswordServlet extends HttpServlet {

    private static final int PASSWORD_MIN_LENGTH = 6;
    private static final int PASSWORD_MAX_LENGTH = 20;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Boolean resetVerified = (Boolean) request.getSession().getAttribute("resetVerified");

        if (resetVerified == null || !resetVerified) {
            response.sendRedirect(request.getContextPath() + "/forgot-password");
            return;
        }

        request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = (String) request.getSession().getAttribute("resetEmail");
        Boolean resetVerified = (Boolean) request.getSession().getAttribute("resetVerified");

        if (email == null || resetVerified == null || !resetVerified) {
            request.setAttribute("error", "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Không trim password để bắt lỗi space đúng yêu cầu
        newPassword = newPassword == null ? "" : newPassword;
        confirmPassword = confirmPassword == null ? "" : confirmPassword;

        if (newPassword.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ mật khẩu.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.matches(".*\\s.*") || confirmPassword.matches(".*\\s.*")) {
            request.setAttribute("error", "Mật khẩu không được chứa khoảng trắng.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < PASSWORD_MIN_LENGTH) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất " + PASSWORD_MIN_LENGTH + " ký tự.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() > PASSWORD_MAX_LENGTH) {
            request.setAttribute("error", "Mật khẩu không được vượt quá " + PASSWORD_MAX_LENGTH + " ký tự.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtils.hashPassword(newPassword);

        if (hashedPassword == null) {
            request.setAttribute("error", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        boolean updated = dao.updatePasswordByEmail(email, hashedPassword);

        if (!updated) {
            request.setAttribute("error", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/reset-password.jsp").forward(request, response);
            return;
        }

        dao.clearOtp(email);

        request.getSession().removeAttribute("resetEmail");
        request.getSession().removeAttribute("resetVerified");
        request.getSession().removeAttribute("otpExpireAtMillis");

        request.setAttribute("message", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }
}