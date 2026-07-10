<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.bakeryzone.dao.PermissionDAO" %>
<%@ page import="com.bakeryzone.model.ScreenPermission" %>
<%@ page import="com.bakeryzone.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    User currentUser = (User) session.getAttribute("user");
    List<String> liveAllowedUrls = new ArrayList<>();
    
    if (currentUser != null) {
        PermissionDAO pDAO = new PermissionDAO();
        List<ScreenPermission> screens = pDAO.getScreensWithStatus(currentUser.getRoleId());
        if (screens != null) {
            for (ScreenPermission sp : screens) {
                if (sp.isActivated()) {
                    liveAllowedUrls.add(sp.getEndpointUrl());
                }
            }
        }
    }
    // Đẩy thẳng vào requestScope để JSTL bên dưới đọc ép cấu trúc real-time
    request.setAttribute("LIVE_PERMISSIONS", liveAllowedUrls);
%>

<link href="${pageContext.request.contextPath}/assets/css/sidebar-submenu.css?v=2.0" rel="stylesheet">
<div class="sidebar">
    <div class="sidebar-brand">
        <i class="fa-solid fa-cake-candles"></i>
        <span>${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'} Admin</span>
    </div>

    <div class="nav-section-title">Hệ thống chính</div>
    <ul class="sidebar-menu">
        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/dashboard')}">
            <li class="menu-item ${param.activeMenu == 'dashboard' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-gauge"></i> Bảng điều khiển</a>
            </li>
        </c:if>
    </ul>

    <div class="nav-section-title">Quản lý</div>
    <ul class="sidebar-menu">
        <!-- Đơn hàng -->
        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/orders?action=list')}">
            <li class="menu-item ${param.activeMenu == 'orders' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/${sessionScope.user.roleId eq 'SHIPPER' ? 'shipper' : 'admin'}/orders?action=list"><i class="fa-solid fa-receipt"></i> Đơn hàng</a>
            </li>
        </c:if>

        <c:set var="canViewProduct" value="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/product?action=list')}" />
        <c:set var="canViewCat" value="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/categories?action=list')}" />
        <c:set var="canViewIng" value="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/ingredient?action=list')}" />
        <c:set var="canViewUnit" value="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/unit?action=list')}" />

        <c:if test="${canViewProduct || canViewCat || canViewIng || canViewUnit}">
            <li class="menu-item ${isProductActive ? 'active' : ''}" id="product-parent-menu">
                <a href="${pageContext.request.contextPath}/admin/product?action=list" id="product-parent-link">
                    <i class="fa-solid fa-cookie-bite"></i> <span>Sản phẩm</span>
                    <i class="fa-solid ${isProductActive ? 'fa-chevron-up' : 'fa-chevron-down'} arrow" id="product-chevron"></i>
                </a>
            </li>

            <%-- 2. Các mục con (đóng các thẻ if của từng mục con ngay sau mỗi thẻ li) --%>
            <c:if test="${canViewCat}">
                <li class="menu-item ${param.activeMenu == 'categories' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
                    <a href="${pageContext.request.contextPath}/admin/categories?action=list" style="font-size: 13px; padding: 8px 25px;">
                        <i class="fa-solid fa-caret-right"></i> Danh mục
                    </a>
                </li>
            </c:if>

            <c:if test="${canViewIng}">
                <li class="menu-item ${param.activeMenu == 'ingredients' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
                    <a href="${pageContext.request.contextPath}/admin/ingredient?action=list" style="font-size: 13px; padding: 8px 25px;">
                        <i class="fa-solid fa-caret-right"></i> Nguyên liệu
                    </a>
                </li>
            </c:if>

            <c:if test="${canViewUnit}">
                <li class="menu-item ${param.activeMenu == 'units' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
                    <a href="${pageContext.request.contextPath}/admin/unit?action=list" style="font-size: 13px; padding: 8px 25px;">
                        <i class="fa-solid fa-caret-right"></i> Đơn vị tính
                    </a>
                </li>
            </c:if>

            <li class="menu-item ${param.activeMenu == 'attributes' ? 'active' : ''} product-child-item" style="padding-left: 20px; display: ${isProductActive ? 'block' : 'none'};">
                <a href="#" style="font-size: 13px; padding: 8px 25px;">
                    <i class="fa-solid fa-caret-right"></i> Thuộc tính
                </a>
            </li>

        </c:if>

        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/customer?action=list')}">
            <li class="menu-item ${param.activeMenu == 'customers' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/customer?action=list"><i class="fa-solid fa-users"></i> Khách hàng</a>
            </li>
        </c:if>

        <li class="menu-item ${param.activeMenu == 'inventory' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-warehouse"></i> Kho hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>
        <li class="menu-item ${param.activeMenu == 'delivery' ? 'active' : ''}">
            <a href="#"><i class="fa-solid fa-truck-ramp-box"></i> Giao hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
        </li>

        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/reviews?action=list')}">
            <li class="menu-item ${param.activeMenu == 'reviews' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/reviews?action=list"><i class="fa-solid fa-star-half-stroke"></i> Đánh giá</a>
            </li>
        </c:if>

    </ul>


    <div class="nav-section-title">Hệ thống</div>
    <ul class="sidebar-menu">

        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/staff?action=list')}">
            <li class="menu-item ${param.activeMenu == 'users' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/staff?action=list"><i class="fa-solid fa-user-gear"></i> Tài khoản</a>
            </li>
        </c:if>

        <c:if test="${sessionScope.user.roleId eq 'ADMIN'}">
            <li class="menu-item ${param.activeMenu == 'roles' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/role-permissions?action=list"><i class="fa-solid fa-shield-halved"></i> Vai trò & Quyền hạn</a>
            </li>
        </c:if>

        <c:if test="${sessionScope.user.roleId eq 'ADMIN' || requestScope.LIVE_PERMISSIONS.contains('/admin/settings')}">
            <li class="menu-item ${param.activeMenu == 'settings' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/admin/settings"><i class="fa-solid fa-sliders"></i> Cài đặt chung</a>
            </li>
        </c:if>
    </ul>

    <!-- Technical Support button matching mockup -->
    <div class="sidebar-banner support-box">
        <div class="support-title">HỖ TRỢ</div>
        <a href="tel:0901234567" class="support-btn">Liên hệ kỹ thuật</a>
    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const productChevron = document.getElementById("product-chevron");
        const productParentLink = document.getElementById("product-parent-link");
        const childItems = document.querySelectorAll(".product-child-item");

        function toggleProductMenu() {
            let isExpanded = false;
            childItems.forEach(item => {
                if (item.style.display === "none" || item.style.display === "") {
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

        // Toggle when clicking the chevron
        if (productChevron) {
            productChevron.addEventListener("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                toggleProductMenu();
            });
        }

        // Allow clicking the parent link to ALWAYS navigate to the product list page
        // (This ensures clicking 'Sản phẩm' will work even when viewing submenus like 'Danh mục' or 'Đơn vị tính')
        if (productParentLink) {
            productParentLink.addEventListener("click", function (e) {
                const activeMenu = "${param.activeMenu}";
                // If we are already on the main products list page, toggle the submenu instead of reloading
                if (activeMenu === "products") {
                    e.preventDefault();
                    toggleProductMenu();
                }
            });
        }
    });
</script>

<div class="nav-section-title">Quản lý</div>
