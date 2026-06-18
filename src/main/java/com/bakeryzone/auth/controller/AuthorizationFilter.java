package com.bakeryzone.auth.controller;

import com.bakeryzone.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        User user = (User) request.getSession().getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String uri = request.getRequestURI();
        String roleId = user.getRoleId();

        // Chỉ chặn /admin/ và /staff/ — KHÔNG chặn /customer/ (khách hàng có quyền vào)
        if (uri.contains("/admin/") || uri.contains("/staff/")) {
            if (!"ADMIN".equalsIgnoreCase(roleId) && !"STAFF".equalsIgnoreCase(roleId)) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        }

        if (uri.contains("/shipper/")) {
            if (!"SHIPPER".equalsIgnoreCase(roleId)) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        }

        chain.doFilter(servletRequest, servletResponse);
    }

    @Override
    public void destroy() {
    }
}
