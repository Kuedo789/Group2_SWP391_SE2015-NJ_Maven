<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="breadcrumbs" style="display: flex; align-items: center; flex-wrap: wrap; gap: 4px;">
    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
    
    <%-- Level 1 Parent --%>
    <c:if test="${not empty param.parentMenu}">
        <span>&gt;</span>
        <c:choose>
            <c:when test="${not empty param.parentUrl and param.parentUrl ne '#'}">
                <a href="${param.parentUrl}">${param.parentMenu}</a>
            </c:when>
            <c:otherwise>
                <span class="text-secondary">${param.parentMenu}</span>
            </c:otherwise>
        </c:choose>
    </c:if>
    
    <%-- Level 2 Parent --%>
    <c:if test="${not empty param.parentMenu2}">
        <span>&gt;</span>
        <c:choose>
            <c:when test="${not empty param.parentUrl2 and param.parentUrl2 ne '#'}">
                <a href="${param.parentUrl2}">${param.parentMenu2}</a>
            </c:when>
            <c:otherwise>
                <span class="text-secondary">${param.parentMenu2}</span>
            </c:otherwise>
        </c:choose>
    </c:if>
    
    <%-- Active Page --%>
    <c:if test="${not empty param.activeMenu}">
        <span>&gt;</span>
        <span class="active text-dark fw-bold" style="font-weight: 700; color: #1e293b;">${param.activeMenu}</span>
    </c:if>

</div>

<style>
    .bc-drop-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 14px;
        color: #334155 !important;
        text-decoration: none !important;
        font-weight: 500;
        transition: background 0.15s, color 0.15s;
    }
    .bc-drop-item:hover {
        background-color: #f8fafc !important;
        color: #0f172a !important;
    }
    .breadcrumb-dropdown-btn:hover {
        background: #e2e8f0 !important;
        border-color: #94a3b8 !important;
    }
</style>

<script>
    function showFloatingAlert(msg, type) {
        if (!msg || msg.trim() === "") return;
        
        let alertDiv = document.createElement('div');
        alertDiv.className = 'custom-floating-alert alert-' + type;
        
        let icon = type === 'success' 
            ? '<i class="fa-solid fa-circle-check" style="font-size: 18px; margin-right: 10px;"></i>' 
            : '<i class="fa-solid fa-triangle-exclamation" style="font-size: 18px; margin-right: 10px;"></i>';
            
        alertDiv.innerHTML = icon + '<span>' + msg + '</span>';
        
        alertDiv.style.cssText = `
            position: fixed;
            top: 24px;
            right: 24px;
            z-index: 10000;
            padding: 14px 24px;
            border-radius: 8px;
            color: white;
            font-family: 'Be Vietnam Pro', sans-serif;
            font-size: 14px;
            font-weight: 500;
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            opacity: 0;
            transform: translateY(-20px);
        `;
        
        if (type === 'success') {
            alertDiv.style.background = 'linear-gradient(135deg, #059669, #10b981)';
        } else {
            alertDiv.style.background = 'linear-gradient(135deg, #dc2626, #ef4444)';
        }
        
        document.body.appendChild(alertDiv);
        
        setTimeout(() => {
            alertDiv.style.opacity = '1';
            alertDiv.style.transform = 'translateY(0)';
        }, 50);
        
        setTimeout(() => {
            alertDiv.style.opacity = '0';
            alertDiv.style.transform = 'translateY(-20px)';
            setTimeout(() => alertDiv.remove(), 400);
        }, 3500);
    }

    document.addEventListener("DOMContentLoaded", function() {
        const bcBtn = document.getElementById("breadcrumbNavBtn");
        const bcMenu = document.getElementById("breadcrumbNavMenu");
        if (bcBtn && bcMenu) {
            bcBtn.addEventListener("click", function(e) {
                e.stopPropagation();
                const isVisible = bcMenu.style.display === "block";
                bcMenu.style.display = isVisible ? "none" : "block";
            });
            document.addEventListener("click", function() {
                bcMenu.style.display = "none";
            });
            bcMenu.addEventListener("click", function(e) {
                e.stopPropagation();
            });
        }

        <c:if test="${not empty sessionScope.successMessage}">
            showFloatingAlert(`${sessionScope.successMessage}`, 'success');
            <c:remove var="successMessage" scope="session" />
        </c:if>
        <c:if test="${not empty requestScope.successMessage}">
            showFloatingAlert(`${requestScope.successMessage}`, 'success');
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            showFloatingAlert(`${sessionScope.errorMessage}`, 'error');
            <c:remove var="errorMessage" scope="session" />
        </c:if>
        <c:if test="${not empty requestScope.errorMessage}">
            showFloatingAlert(`${requestScope.errorMessage}`, 'error');
        </c:if>
    });
</script>
