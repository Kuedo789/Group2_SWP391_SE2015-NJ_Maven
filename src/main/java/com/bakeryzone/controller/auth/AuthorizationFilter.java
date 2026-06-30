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

    // Các trang không tuân theo quy luật CRUD (Không dùng ?action=list làm mặc định)
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

        // 1. Cho phép qua các tài nguyên tĩnh và trang lỗi
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

        // 2. ĐẶC QUYỀN TỐI CAO CỦA ADMIN: Đi qua mọi cửa không cần check
        if ("ADMIN".equals(roleId)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        // 3. LOGIC QUÉT QUYỀN HẠT NHÂN (FINE-GRAINED RBAC)
        String action = request.getParameter("action");
        String targetUrl = servletPath;

        if (action != null && !action.trim().isEmpty()) {
            // Nối action vào để check (VD: /admin/product?action=delete)
            targetUrl += "?action=" + action.trim();
        } else {
            // Nếu không có action (User gõ link trần), Controller mặc định là 'list'.
            // Filter cũng tự động gắn '?action=list' để so sánh cho khớp với DB.
            if (!NON_CRUD_URLS.contains(servletPath)) {
                targetUrl += "?action=list";
            }
        }

        // 4. Kiểm tra quyền thực tế
        boolean hasPermission = permissionDAO.checkUrlPermission(roleId, targetUrl);

        if (hasPermission) {
            chain.doFilter(servletRequest, servletResponse);
        } else {
            // Xử lý báo lỗi nến User cố tình dùng mã JavaScript/AJAX gọi ngầm
            String isAjax = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(isAjax)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("Tài khoản của bạn không được cấp quyền cho thao tác này!");
                return;
            }

            // Chuyển hướng ra trang lỗi 403 nếu cố tình gõ URL trực tiếp
            request.setAttribute("error", "Tài khoản của bạn chưa được kích hoạt tính năng này.");
            request.getRequestDispatcher("/common/403.jsp").forward(request, response);
        }
    }

    @Override
    public void destroy() {
    }
}
