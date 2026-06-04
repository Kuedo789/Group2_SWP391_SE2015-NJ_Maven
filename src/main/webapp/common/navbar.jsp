<%-- 
    Document   : navbar
    Created on : Jun 4, 2026, 1:27:02 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<nav class="navbar">
    <div class="navbar-inner">
        <a href="${pageContext.request.contextPath}/common/home.jsp" class="logo">
            Tiệm Bánh Thủ Công
        </a>

        <div class="nav-menu">
            <a href="${pageContext.request.contextPath}/common/home.jsp" class="active">Trang chủ</a>
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

            <button type="button" class="cart-btn" aria-label="Giỏ hàng">
                <span class="material-symbols-outlined">shopping_cart</span>
                <span class="cart-count">2</span>
            </button>

            <button type="button" aria-label="Tài khoản">
                <span class="material-symbols-outlined">account_circle</span>
            </button>
        </div>
    </div>
</nav>