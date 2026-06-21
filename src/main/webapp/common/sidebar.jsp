<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-cake-candles"></i>
        <span>Bakery<span>Zone</span> Admin</span>
    </div>
    
    <div class="nav-section-title">Hệ thống chính</div>
    <ul class="sidebar-menu">
        <li class="menu-item ${param.activeMenu == 'dashboard' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-gauge"></i> Bảng điều khiển</a>
        </li>
    </ul>

    <div class="nav-section-title">Quản lý</div>
    <ul class="sidebar-menu">
        <li class="menu-item ${param.activeMenu == 'orders' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-receipt"></i> Đơn hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'products' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/product?action=list"><i class="fa-solid fa-cookie-bite"></i> Sản phẩm <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'categories' ? 'active' : ''}" style="padding-left: 20px;">
            <a href="${pageContext.request.contextPath}/admin/categories" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Danh mục</a>
        </li>

        <li class="menu-item ${param.activeMenu == 'ingredients' ? 'active' : ''}" style="padding-left: 20px;">
            <a href="${pageContext.request.contextPath}/admin/ingredient?action=list" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Nguyên liệu</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'attributes' ? 'active' : ''}" style="padding-left: 20px;">
            <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Thuộc tính</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'customers' ? 'active' : ''}">
            <a href="<%= request.getContextPath() %>/customer"><i class="fa-solid fa-users"></i> Khách hàng</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'promotions' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-percent"></i> Khuyến mãi <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'inventory' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-warehouse"></i> Kho hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'delivery' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-truck-ramp-box"></i> Giao hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'reviews' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-star-half-stroke"></i> Đánh giá</a>
        </li>
    </ul>

    <div class="nav-section-title">Hệ thống</div>
    <ul class="sidebar-menu">
        <li class="menu-item ${param.activeMenu == 'users' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/userList?action=list"><i class="fa-solid fa-user-gear"></i> Tài khoản</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'roles' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-shield-halved"></i> Vai trò & Quyền hạn</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'settings' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-sliders"></i> Cài đặt chung</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'logs' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-clock-rotate-left"></i> Nhật ký hoạt động</a>
        </li>
    </ul>

    <!-- Grow Your Bakery card -->
    <div class="sidebar-banner">
        <i class="fa-solid fa-cake-candles cake-icon"></i>
        <h6>Phát triển tiệm bánh</h6>
        <p>Tạo ra những chiếc bánh đẹp và trao gửi hạnh phúc!</p>
    </div>
</div>

            