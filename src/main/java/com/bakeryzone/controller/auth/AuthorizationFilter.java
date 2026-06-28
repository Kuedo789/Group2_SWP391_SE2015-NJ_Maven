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

        // 1. Kiểm tra đăng nhập trước tiên
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 🟢 ĐƯA LÊN ĐÂY: Chuẩn hóa Role_ID từ đối tượng User hệ thống
        String roleId = user.getRoleId();
        if (roleId != null) {
            roleId = roleId.trim().toUpperCase();
        }

        // 🟢 CẢI TIẾN BẢO VỆ: Nếu là ADMIN tối cao -> Cho qua luôn toàn bộ, không check thêm bất cứ điều gì nữa!
        if ("ADMIN".equals(roleId)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        if (servletPath.startsWith("/admin/role-permissions") || servletPath.startsWith("/admin/staff")) {
            request.setAttribute("error", "Tài khoản của bạn không có quyền quản trị.");
            request.getRequestDispatcher("/common/403.jsp").forward(request, response);
            return;
        }

        // 3. Xử lý quét quyền động từ Database cho các màn hình nghiệp vụ thông thường (Khách hàng, Đánh giá...)
        String cleanPath = servletPath;
        if (servletPath.contains("?")) {
            cleanPath = servletPath.split("\\?")[0];
        }

        boolean hasPermission = permissionDAO.checkPermission(roleId, cleanPath);

        if (hasPermission) {
            chain.doFilter(servletRequest, servletResponse);
        } else {
            request.setAttribute("error", "Tài khoản của bạn không có quyền truy cập tính năng này.");
            request.getRequestDispatcher("/common/403.jsp").forward(request, response);
            return;
        }
    }

    @Override
    public void destroy() {
    }
}
