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
        <link href="${pageContext.request.contextPath}/assets/css/admin-global.css?v=1.1" rel="stylesheet">
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

                    <div class="pagination">
                        <span>
                            Tổng cộng <strong>${totalRecords != null ? totalRecords : 0}</strong> danh mục 
                            <span style="color: #64748b; font-size: 13px; font-weight: normal; margin-left: 5px;">
                                (${totalActive != null ? totalActive : 0} đang hoạt động / <span style="color: #ef4444;">${totalDisabled != null ? totalDisabled : 0} đã vô hiệu hóa</span>)
                            </span>
                        </span>

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