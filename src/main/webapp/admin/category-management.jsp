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
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin - Categories" />
        </jsp:include>
        <style>
            /* Pagination Design */
            .pagination-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px 25px;
                border-top: 1px solid #f1ede8;
                background-color: #fff;
            }
            .pagination-text {
                font-size: 13px;
                color: #888888;
            }
            .pagination-nav {
                display: flex;
                gap: 5px;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .page-num-item a {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: 6px;
                border: 1px solid #f1ede8;
                font-size: 13px;
                font-weight: 600;
                color: #555;
                text-decoration: none;
                transition: all 0.2s;
            }
            .page-num-item a:hover {
                background-color: #fafafa;
                border-color: #ccc;
            }
            .page-num-item.active a {
                background-color: #3f5f36;
                border-color: #3f5f36;
                color: #fff;
            }
            .page-num-item.disabled a {
                opacity: 0.5;
                pointer-events: none;
                background-color: #f8f6f4;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="categories" />
        </jsp:include>

        <div class="main-panel">

            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="Sản phẩm" />
                <jsp:param name="activeMenu" value="Danh mục sản phẩm" />
            </jsp:include>

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

                <c:if test="${not empty message or not empty success}">
                    <div style="background-color: #dcfce7; color: #166534; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #bbf7d0;">
                        <i class="fa-solid fa-circle-check"></i> Thao tác thành công!
                    </div>
                </c:if>

                <c:if test="${not empty error}">
                    <div style="background-color: #fee2e2; color: #991b1b; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #fecaca;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <strong>Thất bại:</strong> 
                        <c:choose>
                            <c:when test="${error == 'duplicate_id'}">
                                Mã danh mục này đã tồn tại trong hệ thống! Vui lòng chọn mã khác.
                            </c:when>
                            <c:when test="${error == 'invalid_id_format'}">
                                Mã danh mục không hợp lệ. Vui lòng chỉ sử dụng chữ in hoa, số và dấu gạch ngang (VD: CAT-ABC).
                            </c:when>
                            <c:when test="${error == 'desc_too_long'}">
                                Mô tả quá dài! Vui lòng nhập dưới 255 ký tự.
                            </c:when>
                            <c:when test="${error == 'delete_failed'}">
                                Không thể xóa danh mục này! Có thể danh mục đang chứa sản phẩm hoặc nguyên liệu bên trong.
                            </c:when>
                            <c:when test="${error == 'not_found'}">
                                Không tìm thấy danh mục bạn yêu cầu.
                            </c:when>
                            <c:otherwise>
                                Đã xảy ra lỗi cơ sở dữ liệu. Vui lòng thử lại sau.
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

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
                                <th>Icon</th>
                                <th>Tên Danh Mục</th>
                                <th>Mô Tả</th>
                                <th>Phân Loại</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cat" items="${categoryList}">
                                <tr style="${!cat.enable ? 'opacity: 0.6; background-color: #f8fafc;' : ''}">
                                    <td class="cat-id">
                                        ${cat.categoryId}
                                        <c:if test="${!cat.enable}">
                                            <br><span class="badge" style="background: #fee2e2; color: #991b1b; font-size: 10px; margin-top: 4px; padding: 2px 6px;">Đã vô hiệu hóa</span>
                                        </c:if>
                                    </td>
                                    <td class="cat-icon">
                                        <c:choose>
                                            <c:when test="${not empty cat.iconUrl}">
                                                <img src="${pageContext.request.contextPath}/${cat.iconUrl}" alt="${cat.categoryName}" style="width: 32px; height: 32px; object-fit: contain; border-radius: 4px; background-color: #f1f5f9; padding: 2px;">
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: #94a3b8; font-size: 11px;">Mặc định</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
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
                                        <a href="${pageContext.request.contextPath}/admin/categories?action=edit&id=${cat.categoryId}" class="btn-icon" title="Chỉnh sửa" style="text-decoration: none;"><i class="fa-regular fa-pen-to-square"></i></a>

                                        <c:choose>
                                            <c:when test="${cat.enable}">
                                                <a href="${pageContext.request.contextPath}/admin/categories?action=delete&id=${cat.categoryId}" class="btn-icon" title="Vô hiệu hóa" style="text-decoration: none; color: #ef4444;" onclick="return confirm('Bạn có chắc chắn muốn vô hiệu hóa danh mục này?');"><i class="fa-regular fa-trash-can"></i></a>
                                                </c:when>
                                                <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/admin/categories?action=restore&id=${cat.categoryId}" class="btn-icon" title="Khôi phục" style="text-decoration: none; color: #10b981;" onclick="return confirm('Bạn có muốn khôi phục danh mục này không?');"><i class="fa-solid fa-rotate-left"></i></a>
                                                </c:otherwise>
                                            </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <div class="pagination-area">
                        <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages != null && totalPages > 0 ? totalPages : 1}</b> trang</span>
                        <ul class="pagination-nav">
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/categories?action=list&page=${currentPage - 1}&search=${param.search}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages != null && totalPages > 0 ? totalPages : 1}" var="i">
                                <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/categories?action=list&page=${i}&search=${param.search}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/categories?action=list&page=${currentPage + 1}&search=${param.search}">
                                        <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </body>
</html>