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

        request.getSession().setAttribute("user", user);

        String roleId = user.getRoleId();

        if ("ADMIN".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/userList");
        } else if ("STAFF".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/userList");
        } else if ("SHIPPER".equalsIgnoreCase(roleId)) {
            response.sendRedirect(request.getContextPath() + "/home");
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
