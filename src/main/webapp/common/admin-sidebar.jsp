<%-- 
    Document   : admin-sidebar
    Created on : Jun 8, 2026, 4:52:04 PM
    Author     : thais
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<aside class="sidebar">
    <div class="sidebar-header">
        <div class="brand-logo">CakeZone</div>
    </div>

    <div class="menu-group">
        <div class="menu-title">Main Menu</div>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="menu-item">
            <div class="menu-item-left"><i class="fa-solid fa-house"></i> Dashboard</div>
        </a>
        <a href="${pageContext.request.contextPath}/admin/orders" class="menu-item">
            <div class="menu-item-left"><i class="fa-solid fa-receipt"></i> Orders</div>
        </a>
        
        <div class="menu-item active">
            <div class="menu-item-left"><i class="fa-solid fa-cake-candles"></i> Catalog</div>
            <i class="fa-solid fa-chevron-up" style="font-size: 12px;"></i>
        </div>
        <div class="sub-menu">
            <a href="${pageContext.request.contextPath}/admin/products" class="sub-menu-item">Products</a>
            <a href="${pageContext.request.contextPath}/admin/categories" class="sub-menu-item active">Categories</a>
            <a href="${pageContext.request.contextPath}/admin/accessories" class="sub-menu-item">Accessories</a>
        </div>

        <a href="${pageContext.request.contextPath}/admin/customers" class="menu-item">
            <div class="menu-item-left"><i class="fa-solid fa-users"></i> Customers</div>
        </a>
    </div>
</aside>