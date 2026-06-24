<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<nav class="navbar">
    <div class="breadcrumb">
        <span>Dashboard &nbsp;/&nbsp; Catalog &nbsp;/&nbsp; <strong>${pageTitle}</strong></span>
    </div>
    
    <div class="user-profile">
        <div class="user-info">
            <div class="user-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
            <div class="user-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
        </div>
        <div class="avatar" style="background-image: url('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'); background-size: cover; background-position: center; width: 35px; height: 35px; border-radius: 50%;"></div>
    </div>
</nav>
