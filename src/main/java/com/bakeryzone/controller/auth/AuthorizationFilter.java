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

@WebFilter(filterName = "AuthorizationFilter", urlPatterns = {"/admin/*", "/staff/*", "/shipper/*"})
public class AuthorizationFilter implements Filter {

    private final PermissionDAO permissionDAO = new PermissionDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        String currentUri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String servletPath = currentUri.substring(contextPath.length());

        if (servletPath.contains("/admin/role-permissions") || servletPath.contains("/admin/staff") || servletPath.contains("/admin/test-reviews")) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleId = user.getRoleId();
        if (roleId != null) {
            roleId = roleId.trim().toUpperCase();
        }

        if ("ADMIN".equals(roleId)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }
        boolean hasPermission = false;

        String cleanPath = servletPath;
        if (servletPath.contains("?")) {
            cleanPath = servletPath.split("\\?")[0];
        }

        hasPermission = permissionDAO.checkPermission(roleId, cleanPath);

        if (hasPermission) {
            chain.doFilter(servletRequest, servletResponse);
        } else {
            request.setAttribute("error", "Tài khoản của bạn không có quyền truy cập tính năng này.");
            request.getRequestDispatcher("/common/home.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
    }
}
