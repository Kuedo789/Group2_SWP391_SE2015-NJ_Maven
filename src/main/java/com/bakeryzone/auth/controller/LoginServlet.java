package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập email và mật khẩu.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        email = email.trim().toLowerCase();

        UserDAO dao = new UserDAO();

        User user = dao.findByEmail(email);

        if (user == null
                || !"LOCAL".equalsIgnoreCase(user.getProvider())
                || !PasswordUtils.checkPassword(password, user.getPassword())) {

            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        if (!user.isVerified()) {
            request.setAttribute("error", "Tài khoản chưa xác thực OTP. Vui lòng xác thực trước khi đăng nhập.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản của bạn đang bị khóa hoặc không hoạt động.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        request.getSession().setAttribute("user", user);

        if ("ADMIN".equalsIgnoreCase(user.getRoleId()) || user.isActiveStaff()) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}