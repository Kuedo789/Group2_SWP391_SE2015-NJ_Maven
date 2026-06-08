<%-- 
    Document   : category-management
    Created on : Jun 8, 2026, 4:53:40 PM
    Author     : thais
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CakeZone Admin - Categories</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/admin-global.css" rel="stylesheet">
    </head>
    <body>

        <jsp:include page="/common/admin-sidebar.jsp" />

        <main class="main-wrapper">

            <c:set var="pageTitle" value="Categories" scope="request" />
            <jsp:include page="/common/admin-navbar.jsp" />

            <div class="content">
                <div class="page-header">
                    <div class="page-title">
                        <h2>Danh mục sản phẩm</h2>
                        <p>Manage and organize your bakery's product offerings.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/categories?action=add" class="btn-primary" style="text-decoration: none;">
                        <i class="fa-solid fa-plus"></i> Thêm danh mục
                    </a>
                </div>

                <div class="table-card">

                    <div class="table-controls">
                        <form action="${pageContext.request.contextPath}/admin/categories" method="GET" style="display: flex; gap: 15px; width: 100%; align-items: center;">

                            <div class="search-bar" style="flex-grow: 1; max-width: 400px;">
                                <i class="fa-solid fa-magnifying-glass" style="color: #a0a0a0;"></i>
                                <input type="text" name="search" value="${searchQuery}" placeholder="Tìm kiếm theo mã, tên danh mục...">
                            </div>

                            <select name="filterType" style="padding: 10px 15px; border-radius: 50px; border: 1px solid var(--border-soft); background: var(--bg-cream); outline: none; font-size: 14px; cursor: pointer;">
                                <option value="all" ${filterType == 'all' ? 'selected' : ''}>Tất cả phân loại</option>
                                <option value="Sản phẩm chính" ${filterType == 'Sản phẩm chính' ? 'selected' : ''}>Sản phẩm chính</option>
                                <option value="Nguyên liệu" ${filterType == 'Nguyên liệu' ? 'selected' : ''}>Nguyên liệu</option>
                            </select>

                            <button type="submit" class="btn-primary" style="padding: 10px 20px;">Lọc</button>
                        </form>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th>Mã Danh Mục</th>
                                <th>Tên Danh Mục</th>
                                <th>Mô Tả</th>
                                <th>Phân Loại</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cat" items="${categoryList}">
                                <tr>
                                    <td class="cat-id">${cat.categoryId}</td>
                                    <td class="cat-name">${cat.categoryName}</td>
                                    <td class="cat-desc">${cat.description != null ? cat.description : 'Không có mô tả'}</td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${cat.categoryType == 'Nguyên liệu'}">
                                                <span class="badge" style="background: #f1f5f9; color: #475569;">${cat.categoryType}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge">${cat.categoryType}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td class="action-btns">
                                        <a href="${pageContext.request.contextPath}/admin/categories/view?id=${cat.categoryId}" class="btn-icon" title="View" style="text-decoration: none;"><i class="fa-regular fa-eye"></i></a>
                                        <a href="${pageContext.request.contextPath}/admin/categories/edit?id=${cat.categoryId}" class="btn-icon" title="Edit" style="text-decoration: none;"><i class="fa-regular fa-pen-to-square"></i></a>
                                        <a href="${pageContext.request.contextPath}/admin/categories?action=delete&id=${cat.categoryId}" class="btn-icon" title="Delete" style="text-decoration: none; color: #ef4444;" onclick="return confirm('Bạn có chắc chắn muốn xóa danh mục này?');"><i class="fa-regular fa-trash-can"></i></a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <div class="pagination">
                        <span>Tổng cộng <strong>${totalRecords != null ? totalRecords : 0}</strong> danh mục</span>

                        <c:set var="queryStr" value="&search=${searchQuery}&filterType=${filterType}" />

                        <div class="page-numbers">
                            <c:if test="${currentPage > 1}">
                                <a href="${pageContext.request.contextPath}/admin/categories?page=${currentPage - 1}${queryStr}" class="page-btn" style="text-decoration: none;">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 10px;"></i>
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages != null && totalPages > 0 ? totalPages : 1}" var="i">
                                <c:choose>
                                    <c:when test="${currentPage == i}">
                                        <span class="page-btn active">${i}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/admin/categories?page=${i}${queryStr}" class="page-btn" style="text-decoration: none; color: inherit;">
                                            ${i}
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="${pageContext.request.contextPath}/admin/categories?page=${currentPage + 1}${queryStr}" class="page-btn" style="text-decoration: none;">
                                    <i class="fa-solid fa-chevron-right" style="font-size: 10px;"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </main>

    </body>
</html>