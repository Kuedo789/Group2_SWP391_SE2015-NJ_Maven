<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Quản lý đơn vị tính</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.3">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="units" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">

        <!-- Top Header -->
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="#">Bảng điều khiển</a>
                    <span>&gt;</span>
                    <a href="#">Cấu hình</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Đơn vị tính</a>
                </div>
            </div>

            <div class="header-right">
                <button class="header-icon-btn"><i class="fa-regular fa-bell"></i><span class="badge-dot"></span></button>
                <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>

                <div class="profile-section">
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                    <div class="profile-info">
                        <div class="profile-name">Nguyễn Anh Quân</div>
                        <div class="profile-role">PIC</div>
                    </div>
                </div>
            </div>
        </div>

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
                <a href="${pageContext.request.contextPath}/admin/unit?action=create" class="btn btn-cz-primary">
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
                                        <td>${status.index + 1}</td>
                                        <td>
                                            <span class="badge" style="background-color: #64748b; font-size: 12.5px; font-weight: 600; padding: 5px 11px; border-radius: 6px; color: #fff; letter-spacing: 0.5px;">
                                                ${u.unitId}
                                            </span>
                                        </td>
                                        <td><strong>${u.unitName}</strong></td>
                                        <td class="text-muted">${not empty u.description ? u.description : '—'}</td>
                                        <td>
                                            <div class="actions-cell">
                                                <a href="${pageContext.request.contextPath}/admin/unit?action=edit&id=${u.unitId}" class="btn-action-edit" title="Chỉnh sửa">
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
                    <span class="pagination-text">Tổng cộng <strong>${not empty unitList ? unitList.size() : 0}</strong> đơn vị tính</span>
                </div>
            </div>

        </div>
    </div>

    <!-- Hidden form for deleting -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/unit?action=delete" method="post" style="display: none;">
        <input type="hidden" name="id" id="deleteId">
    </form>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(id, name) {
            if (confirm('Bạn có chắc chắn muốn xóa đơn vị tính "' + name + '" không?\nLưu ý: Bạn không thể xóa nếu có nguyên liệu đang sử dụng đơn vị này.')) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }

        // Sidebar toggle
        const sidebarToggle = document.querySelector('.sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                document.querySelector('.sidebar')?.classList.toggle('collapsed');
                document.querySelector('.main-panel')?.classList.toggle('expanded');
            });
        }
    </script>
</body>
</html>
