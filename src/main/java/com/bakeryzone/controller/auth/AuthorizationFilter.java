package com.bakeryzone.controller.auth;

import com.bakeryzone.dao.PermissionDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/admin/*", "/staff/*", "/shipper/*"})
public class AuthorizationFilter implements Filter {

    private final PermissionDAO permissionDAO = new PermissionDAO();

    private static final List<String> NON_CRUD_URLS = Arrays.asList(
            "/admin/dashboard",
            "/admin/settings",
            "/admin/role-permissions"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String servletPath = request.getServletPath();

        if (servletPath.startsWith("/common/") || servletPath.contains("403.jsp") || servletPath.contains("/assets/")) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleId = user.getRoleId().trim().toUpperCase();

        if ("ADMIN".equals(roleId)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }


        String normalizedPath = servletPath;
        if (servletPath.startsWith("/staff/")) {
            normalizedPath = "/admin/" + servletPath.substring(7);
        } else if (servletPath.startsWith("/shipper/")) {
            normalizedPath = "/admin/" + servletPath.substring(9);
        }

        String action = request.getParameter("action");
        String targetUrl = normalizedPath;

        if (action != null && !action.trim().isEmpty()) {
            targetUrl += "?action=" + action.trim();
        } else {
            if (!NON_CRUD_URLS.contains(normalizedPath)) {
                targetUrl += "?action=list";
            }
        }

        System.out.println("--> [AUTH FILTER] Check roleId: " + roleId + " for targetUrl: " + targetUrl);
        boolean hasPermission = permissionDAO.checkUrlPermission(roleId, targetUrl);

        if (hasPermission) {
            chain.doFilter(servletRequest, servletResponse);
        } else {
            System.out.println("--> [AUTH FILTER BLOCKED] Role: " + roleId + " was BLOCKED for URL: " + targetUrl);
            String isAjax = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(isAjax)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("Tài khoản của bạn không được cấp quyền cho thao tác này!");
                return;
            }

            request.setAttribute("error", "Tài khoản của bạn chưa được kích hoạt hệ thống tính năng này.");
            request.getRequestDispatcher("/common/403.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
    }
}
