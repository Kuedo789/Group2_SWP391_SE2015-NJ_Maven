<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="top-header">
    <div class="header-left">
        <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
        <div class="breadcrumbs">
            <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
            <c:if test="${not empty param.parentMenu}">
                <span>&gt;</span>
                <a href="${not empty param.parentUrl ? param.parentUrl : '#'}">${param.parentMenu}</a>
            </c:if>
            <c:if test="${not empty param.activeMenu}">
                <span>&gt;</span>
                <a href="#" class="active text-dark font-weight-bold">${param.activeMenu}</a>
            </c:if>
        </div>
    </div>
    
    <div class="header-right">
        <button class="header-icon-btn"><i class="fa-regular fa-bell"></i><span class="badge-dot"></span></button>
        <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>
        
        <a href="${pageContext.request.contextPath}/profile" style="text-decoration: none; color: inherit;">
            <div class="profile-section">
                <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                <div class="profile-info">
                    <div class="profile-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                    <div class="profile-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
                </div>
            </div>
        </a>
    </div>
</div>
