package com.bakeryzone.controller.auth;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.dao.CartDAO; // Import your CartDAO
import com.bakeryzone.model.User;
import com.bakeryzone.utils.PasswordUtils;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Clean explicit import
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        email = email == null ? "" : email.trim().toLowerCase();

        // Không trim password để tránh sai logic khi password có khoảng trắng.
        // Dù hiện tại register/reset đã cấm space, login vẫn nên giữ nguyên input.
        password = password == null ? "" : password;

        request.setAttribute("accountInput", email);

        if (email.isEmpty() || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email và mật khẩu.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // Validate định dạng và độ dài email trước khi truy vấn DB
        String emailError = ValidationUtils.validateEmailInput(email);
        if (emailError != null) {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.findByEmail(email);

        if (user == null || !PasswordUtils.checkPassword(password, user.getPassword())) {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        if (!user.isVerified()) {
            request.getSession().setAttribute("otpEmail", email);
            request.getSession().removeAttribute("otpExpireAtMillis");

            request.setAttribute("unverifiedAccount", true);
            request.setAttribute("error", "Tài khoản chưa xác thực OTP.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản đang bị khóa hoặc không hoạt động.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // --- SUCCESS LOGIN PIPELINE ---
        HttpSession session = request.getSession();
        session.setAttribute("user", user);

        // FIXED: Dynamically load and bind cart state balance badge immediately on
        // successful sign-in
        try {
            CartDAO cartDAO = new CartDAO();
            int initialCount = cartDAO.getCartCountForUser(user.getUserId());
            session.setAttribute("cartCount", initialCount);
        } catch (Exception e) {
            e.printStackTrace(); // Keep logging clean but defensive so a cart issue doesn't block login
            session.setAttribute("cartCount", 0);
        }

        String roleId = user.getRoleId();

        if ("ADMIN".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if ("STAFF".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if ("SHIPPER".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}