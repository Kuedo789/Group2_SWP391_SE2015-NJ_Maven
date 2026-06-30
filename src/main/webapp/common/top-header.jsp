<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="top-header">
    <div class="header-left">
        <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
        <jsp:include page="breadcrumb.jsp">
            <jsp:param name="parentMenu" value="${param.parentMenu}" />
            <jsp:param name="parentUrl" value="${param.parentUrl}" />
            <jsp:param name="parentMenu2" value="${param.parentMenu2}" />
            <jsp:param name="parentUrl2" value="${param.parentUrl2}" />
            <jsp:param name="activeMenu" value="${param.activeMenu}" />
        </jsp:include>
    </div>
    
    <div class="header-right">
        <button class="header-icon-btn"><i class="fa-regular fa-bell"></i><span class="badge-dot"></span></button>
        <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>
        
        <div class="profile-section">
            <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
            <div class="profile-info">
                <div class="profile-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                <div class="profile-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
            </div>
        </div>
    </div>
</div>
