<%-- 
    Document   : navbar
    Created on : Jun 4, 2026, 1:27:02 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    Object user = session.getAttribute("user");
    boolean loggedIn = user != null;

    Integer cartCount = (Integer) session.getAttribute("cartCount");
    if (cartCount == null) {
        cartCount = 0;
    }
%>

<nav class="navbar">
    <div class="navbar-inner">

        <a href="<%= contextPath %>/common/home.jsp" class="logo">
            Tiệm Bánh Thủ Công
        </a>

        <div class="nav-menu">
            <a href="<%= contextPath %>/common/home.jsp" class="active">Trang chủ</a>
            <a href="#">Menu bánh</a>
            <a href="#">Tự thiết kế</a>
            <a href="#">Bộ sưu tập</a>
            <a href="#">Ưu đãi</a>
            <a href="#">Liên hệ</a>
        </div>

        <div class="nav-icons">

            <button type="button" aria-label="Tìm kiếm">
                <span class="material-symbols-outlined">search</span>
            </button>

            <button type="button"
                    class="cart-btn"
                    aria-label="Giỏ hàng"
                    onclick="window.location.href='<%= contextPath %>/cart'">
                <span class="material-symbols-outlined">shopping_cart</span>

                <% if (cartCount > 0) { %>
                    <span class="cart-count"><%= cartCount %></span>
                <% } %>
            </button>

            <% if (!loggedIn) { %>

                <button type="button"
                        aria-label="Tài khoản"
                        onclick="window.location.href='<%= contextPath %>/auth/login.jsp'">
                    <span class="material-symbols-outlined">account_circle</span>
                </button>

            <% } else { %>

                <div class="user-dropdown">

                    <button type="button"
                            class="user-dropdown-btn"
                            id="userDropdownBtn"
                            aria-label="Tài khoản">
                        <span class="material-symbols-outlined">account_circle</span>
                    </button>

                    <div class="user-dropdown-menu" id="userDropdownMenu">
                        <a href="<%= contextPath %>/profile">Profile</a>
                        <a href="<%= contextPath %>/orders">Đơn hàng của tôi</a>
                        <a href="<%= contextPath %>/my-designs">Thiết kế của tôi</a>
                        <a href="<%= contextPath %>/logout">Đăng xuất</a>
                    </div>

                </div>

            <% } %>

        </div>

    </div>
</nav>