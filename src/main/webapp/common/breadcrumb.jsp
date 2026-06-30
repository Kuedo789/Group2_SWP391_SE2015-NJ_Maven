<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<div class="breadcrumbs">
    <a href="${pageContext.request.contextPath}/admin/dashboard">Bảng điều khiển</a>
    
    <%-- Level 1 Parent --%>
    <c:if test="${not empty param.parentMenu}">
        <span>&gt;</span>
        <c:choose>
            <c:when test="${not empty param.parentUrl and param.parentUrl ne '#'}">
                <a href="${param.parentUrl}">${param.parentMenu}</a>
            </c:when>
            <c:otherwise>
                <a href="#">${param.parentMenu}</a>
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
                <a href="#">${param.parentMenu2}</a>
            </c:otherwise>
        </c:choose>
    </c:if>
    
    <%-- Active Page --%>
    <c:if test="${not empty param.activeMenu}">
        <span>&gt;</span>
        <a href="#" class="active text-dark font-weight-bold">${param.activeMenu}</a>
    </c:if>
</div>
