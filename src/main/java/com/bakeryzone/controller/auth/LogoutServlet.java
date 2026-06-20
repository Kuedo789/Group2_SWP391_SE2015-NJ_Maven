package com.bakeryzone.controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LogoutServlet extends HttpServlet {

    // Đăng xuất bằng GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Xóa toàn bộ session
        request.getSession().invalidate();

        // Quay về home
        response.sendRedirect(request.getContextPath() + "/home");
    }

    // Nếu form dùng POST logout thì vẫn xử lý giống GET
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}