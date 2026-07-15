<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Quản lý đơn vị tính" />
    </jsp:include>
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.6">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="units" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">

        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Cấu hình" />
            <jsp:param name="activeMenu" value="Đơn vị tính" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">

            <!-- Flash Message Alerts -->
            <c:if test="${param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success' or param.msg eq 'delete_error'}">
                <div class="alert alert-${param.msg eq 'delete_error' ? 'danger' : 'success'} alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-${param.msg eq 'delete_error' ? 'triangle-exclamation' : 'circle-check'} me-2"></i>
                    <c:choose>
                        <c:when test="${param.msg eq 'add_success'}">Đã thêm mới đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'edit_success'}">Đã cập nhật đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'delete_success'}">Đã xóa đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'delete_error'}">Xóa thất bại! Đơn vị tính này đang được liên kết trong bảng nguyên liệu.</c:when>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                </div>
            </c:if>

            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý đơn vị tính</h1>
                    <p class="page-subtitle">Định nghĩa danh mục các đơn vị đo lường sử dụng cho công thức và kho hàng.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/unit?action=create&search=${search}" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm đơn vị tính
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/unit" method="get">
                    <input type="hidden" name="action" value="list">

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm đơn vị theo mã, tên...">
                    </div>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/unit?action=list" class="btn-clear-filter"><i class="fa-solid fa-arrow-rotate-left"></i> Làm mới</a>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 70px;">STT</th>
                            <th style="width: 160px;">Mã đơn vị (ID)</th>
                            <th style="width: 220px;">Tên đơn vị</th>
                            <th>Mô tả chi tiết</th>
                            <th style="width: 150px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty unitList}">
                                <c:forEach var="u" items="${unitList}" varStatus="status">
                                    <tr>
                                        <td>${((currentPage - 1) * pageSize) + status.index + 1}</td>
                                        <td>
                                            <span class="badge" style="background-color: #f5f5f5; color: #666; border: 1px solid #ddd; font-size: 11px; font-weight: 500; padding: 5px 10px; border-radius: 4px; display: inline-flex; align-items: center; letter-spacing: 0.5px;">
                                                ${u.unitId}
                                            </span>
                                        </td>
                                        <td style="max-width: 220px; word-break: break-all; white-space: normal;"><strong>${u.unitName}</strong></td>
                                        <td class="text-muted" style="font-size: 13.5px; font-weight: 400; color: var(--cz-text-muted) !important; max-width: 300px; word-break: break-all; white-space: normal;">${not empty u.description ? u.description : '—'}</td>
                                        <td>
                                            <div class="actions-cell">
                                                <a href="${pageContext.request.contextPath}/admin/unit?action=edit&id=${u.unitId}&search=${search}&page=${currentPage}" class="btn-action-edit" title="Chỉnh sửa">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </a>
                                                <button type="button" class="btn-action-delete" title="Xóa" onclick="confirmDelete('${u.unitId}', '${u.unitName}')">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                             <c:otherwise>
                                 <tr>
                                     <td colspan="5" class="text-center py-5 text-muted">
                                         <i class="fa-solid fa-ruler-combined d-block fs-2 mb-3" style="color: #ccc;"></i>
                                         Không tìm thấy đơn vị tính nào phù hợp.
                                     </td>
                                 </tr>
                             </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalCount > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + unitList.size()} trong tổng số ${totalCount} đơn vị tính</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <!-- Prev page -->
                             <c:if test="${currentPage > 1}">
                                 <li class="page-num-item">
                                     <a href="${pageContext.request.contextPath}/admin/unit?action=list&page=${currentPage - 1}&search=${search}">
                                         <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                             
                             <!-- Page Numbers -->
                             <c:forEach var="pageNum" begin="1" end="${totalPages}">
                                 <li class="page-num-item ${pageNum == currentPage ? 'active' : ''}">
                                     <a href="${pageContext.request.contextPath}/admin/unit?action=list&page=${pageNum}&search=${search}">${pageNum}</a>
                                 </li>
                             </c:forEach>
                             
                             <!-- Next page -->
                             <c:if test="${currentPage < totalPages}">
                                 <li class="page-num-item">
                                     <a href="${pageContext.request.contextPath}/admin/unit?action=list&page=${currentPage + 1}&search=${search}">
                                         <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                        </ul>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Hidden form for deleting -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/unit?action=delete" method="post" style="display: none;">
        <input type="hidden" name="id" id="deleteId">
        <input type="hidden" name="search" value="${search}">
    </form>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        window.addEventListener('DOMContentLoaded', () => {
            // Sidebar toggle
            const sidebarToggle = document.querySelector('.sidebar-toggle');
            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', () => {
                    document.querySelector('.sidebar')?.classList.toggle('collapsed');
                    document.querySelector('.main-panel')?.classList.toggle('expanded');
                });
            }
        });

        function confirmDelete(id, name) {
            if (confirm('Bạn có chắc chắn muốn xóa đơn vị tính "' + name + '" không?\nLưu ý: Bạn không thể xóa nếu có nguyên liệu đang sử dụng đơn vị này.')) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }
    </script>
</body>
</html>
</body>
</html>
