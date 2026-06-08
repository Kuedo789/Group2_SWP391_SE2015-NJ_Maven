<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.User" %>

<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
%>

<nav class="navbar">
    <div class="navbar-inner">

        <!-- Logo -->
        <a href="<%= contextPath %>/home" class="logo">
            BakeryZone
        </a>

        <!-- Menu chính -->
        <div class="nav-menu">
            <a href="#" class="active">Trang chủ</a>
            <a href="#">Sản phẩm</a>
            <a href="#">Thiết kế bánh</a>
            <a href="#">Về chúng tôi</a>
            <a href="#">Liên hệ</a>
        </div>

        <!-- Icons bên phải -->
        <div class="nav-icons">

            <!-- Search -->
            <button type="button" title="Tìm kiếm">
                <span class="material-symbols-outlined">search</span>
            </button>

            <!-- Cart -->
            <button type="button" title="Giỏ hàng">
                <span class="material-symbols-outlined">shopping_cart</span>
                <span class="cart-count">0</span>
            </button>

            <!-- User dropdown -->
            <div class="user-dropdown">

                <% if (currentUser == null) { %>

                <!-- Chưa đăng nhập -->
                <a href="<%= contextPath %>/auth/login.jsp"
                   class="btn btn-primary">
                    Đăng nhập
                </a>

                <% } else { %>

                <!-- Đã đăng nhập -->
                <button type="button" class="user-dropdown-btn" id="userDropdownBtn" title="Tài khoản">
                    <span class="material-symbols-outlined">account_circle</span>
                </button>

                <div class="user-dropdown-menu" id="userDropdownMenu">

                    <!-- Header user -->
                    <div class="user-dropdown-header">
                        <div class="user-dropdown-avatar">
                            <span class="material-symbols-outlined">account_circle</span>
                        </div>

                        <div class="user-dropdown-info">
                            <div class="user-dropdown-hello">Xin chào,</div>
                            <div class="user-dropdown-fullname">
                                <%= currentUser.getFullName() %>
                            </div>
                        </div>
                    </div>

                    <div class="user-dropdown-divider"></div>

                    <!-- Profile -->
                    <a href="<%= contextPath %>/profile" class="user-dropdown-item">
                        <span class="material-symbols-outlined">person</span>
                        <span>Hồ sơ cá nhân</span>
                    </a>

                    <!-- Orders -->
                    <a href="<%= contextPath %>/orders" class="user-dropdown-item">
                        <span class="material-symbols-outlined">receipt_long</span>
                        <span>Xem đơn hàng</span>
                    </a>

                    <!-- My designs -->
                    <a href="<%= contextPath %>/my-designs" class="user-dropdown-item">
                        <span class="material-symbols-outlined">cake</span>
                        <span>Thiết kế của tôi</span>
                    </a>

                    <div class="user-dropdown-divider"></div>

                    <!-- Logout -->
                    <a href="<%= contextPath %>/logout" class="user-dropdown-item logout-item">
                        <span class="material-symbols-outlined">logout</span>
                        <span>Đăng xuất</span>
                    </a>

                </div>

                <% } %>

            </div>
        </div>
    </div>
</nav>