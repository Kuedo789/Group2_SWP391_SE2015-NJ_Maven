package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    // Nếu truy cập /login bằng GET thì quay về login.jsp
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
    }

    // Xử lý submit form login
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // login.jsp dùng name="account" nên phải lấy account
        String email = request.getParameter("account");

        // Lấy password
        String password = request.getParameter("password");

        // Kiểm tra rỗng
        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập email và mật khẩu.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        // Kiểm tra email + password
        User user = dao.checkLogin(email.trim(), password);

        // Phải check null trước, nếu không sẽ lỗi NullPointerException
        if (user == null) {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // Nếu chưa xác thực OTP thì không cho đăng nhập
        if (!user.isVerified()) {
            request.setAttribute("error", "Tài khoản chưa xác thực OTP. Vui lòng xác thực trước khi đăng nhập.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // Nếu tài khoản bị khóa thì không cho đăng nhập
        if (!"Active".equalsIgnoreCase(user.getAccountStatus())) {
            request.setAttribute("error", "Tài khoản của bạn đang bị khóa hoặc không hoạt động.");
            request.setAttribute("accountInput", email);
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        // Đăng nhập thành công thì lưu user vào session
        request.getSession().setAttribute("user", user);

        // Nếu admin/staff thì vào admin
        if ("ADMIN".equalsIgnoreCase(user.getRoleId()) || user.isActiveStaff()) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}