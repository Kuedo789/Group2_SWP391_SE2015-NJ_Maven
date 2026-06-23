<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<link href="${pageContext.request.contextPath}/assets/css/sidebar-submenu.css" rel="stylesheet">
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
            <a href="${pageContext.request.contextPath}/admin/orders"><i class="fa-solid fa-receipt"></i> Đơn hàng</a>
        </li>
        <c:set var="isProductActive" value="${param.activeMenu == 'products' || param.activeMenu == 'categories' || param.activeMenu == 'ingredients' || param.activeMenu == 'units' || param.activeMenu == 'attributes'}" />
        <li class="menu-item ${param.activeMenu == 'products' ? 'active' : ''}" id="product-parent-menu">
            <a href="${pageContext.request.contextPath}/admin/product?action=list" id="product-parent-link">
                <i class="fa-solid fa-cookie-bite"></i> <span>Sản phẩm</span>
                <i class="fa-solid ${isProductActive ? 'fa-chevron-up' : 'fa-chevron-down'} arrow" id="product-chevron"></i>
            </a>
        </li>
        <li class="menu-item ${param.activeMenu == 'categories' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
            <a href="${pageContext.request.contextPath}/admin/categories" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Danh mục</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'ingredients' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
            <a href="${pageContext.request.contextPath}/admin/ingredient?action=list" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Nguyên liệu</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'units' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
            <a href="${pageContext.request.contextPath}/admin/unit?action=list" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Đơn vị tính</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'attributes' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
            <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Thuộc tính</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'customers' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/customer?action=list"><i class="fa-solid fa-users"></i> Khách hàng</a>
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
            <a href="${pageContext.request.contextPath}/admin/reviews?action=list"><i class="fa-solid fa-star-half-stroke"></i> Đánh giá</a>
        </li>
    </ul>

    <div class="nav-section-title">Hệ thống</div>
    <ul class="sidebar-menu">
        <li class="menu-item ${param.activeMenu == 'users' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/staff?action=list"><i class="fa-solid fa-user-gear"></i> Tài khoản</a>
        </li>
        <li class="menu-item ${param.activeMenu == 'roles' ? 'active' : ''}">
            <a href="${pageContext.request.contextPath}/admin/role-permissions?action=list"><i class="fa-solid fa-shield-halved"></i> Vai trò & Quyền hạn</a>
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

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const productChevron = document.getElementById("product-chevron");
        const productParentLink = document.getElementById("product-parent-link");
        const childItems = document.querySelectorAll(".product-child-item");
        
        function toggleProductMenu() {
            let isExpanded = false;
            childItems.forEach(item => {
                if (item.style.display === "none") {
                    item.style.display = "block";
                    isExpanded = true;
                } else {
                    item.style.display = "none";
                    isExpanded = false;
                }
            });
            if (productChevron) {
                if (isExpanded) {
                    productChevron.classList.remove("fa-chevron-down");
                    productChevron.classList.add("fa-chevron-up");
                } else {
                    productChevron.classList.remove("fa-chevron-up");
                    productChevron.classList.add("fa-chevron-down");
                }
            }
        }

        if (productChevron) {
            productChevron.addEventListener("click", function(e) {
                e.preventDefault();
                e.stopPropagation();
                toggleProductMenu();
            });
        }

        if (productParentLink) {
            productParentLink.addEventListener("click", function(e) {
                const activeMenu = "${param.activeMenu}";
                if (activeMenu === "products" || activeMenu === "categories" || activeMenu === "ingredients" || activeMenu === "units" || activeMenu === "attributes") {
                    e.preventDefault();
                    toggleProductMenu();
                }
            });
        }
    });
</script>

            