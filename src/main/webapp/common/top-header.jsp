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
        
        <!-- Profile Dropdown Section -->
        <div class="user-dropdown" style="position: relative; display: inline-block;">
            <button type="button" id="adminDropdownBtn" style="border: none; background: transparent; cursor: pointer; padding: 4px 8px; border-radius: 8px; display: flex; align-items: center; gap: 8px; outline: none; transition: background 0.2s;">
                <div class="profile-section" style="display: flex; align-items: center; gap: 10px;">
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img" style="width: 38px; height: 38px; border-radius: 50%; object-fit: cover;">
                    <div class="profile-info" style="text-align: left;">
                        <div class="profile-name" style="font-size: 14px; font-weight: 600; color: #2c3e2b;"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                        <div class="profile-role" style="font-size: 12px; color: #888; font-weight: 500;"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
                    </div>
            </button>
            
            <div class="user-dropdown-menu" id="adminDropdownMenu" style="display: none; position: absolute; top: 115%; right: 0; width: 220px; background: #ffffff; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.15); z-index: 9999; padding: 8px 0; border: 1px solid #eee; font-family: inherit;">
                <div class="user-dropdown-item-static" style="padding: 10px 16px; font-size: 14px; color: #666; font-weight: 500; display: flex; align-items: center; gap: 10px;">
                    <i class="fa-solid fa-user-shield" style="font-size: 16px; color: #345f3d; width: 18px; text-align: center;"></i>
                    <span>Vai trò: <c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></span>
                </div>
                <div style="height: 1px; background: #eee; margin: 6px 0;"></div>
                <a href="${pageContext.request.contextPath}/profile" style="display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 14px; color: #333; text-decoration: none; font-weight: 600; transition: background 0.2s;" class="admin-dropdown-item">
                    <i class="fa-regular fa-user" style="font-size: 16px; color: #345f3d; width: 18px; text-align: center;"></i>
                    <span>Hồ sơ cá nhân</span>
                </a>

                <a href="${pageContext.request.contextPath}/logout" style="display: flex; align-items: center; gap: 10px; padding: 10px 16px; font-size: 14px; color: #dc3545; text-decoration: none; font-weight: 600; transition: background 0.2s;" class="admin-dropdown-item">
                    <i class="fa-solid fa-arrow-right-from-bracket" style="font-size: 16px; color: #dc3545; width: 18px; text-align: center;"></i>
                    <span>Đăng xuất</span>
                </a>
            </div>
        </div>

        <style>
            #adminDropdownBtn:hover {
                background-color: #f1f5f9;
            }
            .admin-dropdown-item:hover {
                background-color: #f7f9f6 !important;
                color: #345f3d !important;
            }
        </style>
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                const btn = document.getElementById("adminDropdownBtn");
                const menu = document.getElementById("adminDropdownMenu");
                const arrow = btn ? btn.querySelector(".profile-dropdown-arrow") : null;
                
                if (btn && menu) {
                    btn.addEventListener("click", function(e) {
                        e.stopPropagation();
                        const isShown = menu.style.display === "block";
                        menu.style.display = isShown ? "none" : "block";
                        if (arrow) {
                            arrow.style.transform = isShown ? "rotate(0deg)" : "rotate(180deg)";
                        }
                    });
                    
                    document.addEventListener("click", function() {
                        menu.style.display = "none";
                        if (arrow) {
                            arrow.style.transform = "rotate(0deg)";
                        }
                    });
                    
                    menu.addEventListener("click", function(e) {
                        e.stopPropagation();
                    });
                }
            });
        </script>
    </div>
</div>
