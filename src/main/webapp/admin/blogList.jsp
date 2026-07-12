<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Quản lý bài viết" />
    </jsp:include>
    <style>
        :root {
            --cz-primary: #3f5f36;
            --cz-primary-hover: #2f4728;
            --cz-dark-bg: #111010;
            --cz-sidebar-active: #232222;
            --cz-text-muted: #888888;
            --cz-border-color: #f1ede8;
            --cz-light-bg: #f8f6f4;
            --cz-card-bg: #ffffff;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--cz-light-bg);
            color: #333;
            overflow-x: hidden;
            margin: 0;
        }

        /* Main Content Panel */
        .main-panel {
            margin-left: 260px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Container & Elements */
        .content-container {
            padding: 35px;
            flex: 1;
        }
        .page-title-area {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 25px;
        }
        .page-title {
            font-size: 26px;
            font-weight: 700;
            color: #111;
            margin-bottom: 4px;
        }
        .page-subtitle {
            font-size: 13.5px;
            color: var(--cz-text-muted);
            margin-bottom: 0;
        }

        .btn-cz-primary {
            background-color: var(--cz-primary);
            color: #fff;
            font-weight: 600;
            font-size: 14.5px;
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        .btn-cz-primary:hover {
            background-color: var(--cz-primary-hover);
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(63, 95, 54, 0.25);
        }

        .filter-card {
            background-color: var(--cz-card-bg);
            border-radius: 12px;
            padding: 20px;
            border: 1px solid var(--cz-border-color);
            margin-bottom: 25px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
        }
        .filter-form {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        .filter-select {
            min-width: 160px;
            padding: 10px 15px;
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #444;
            cursor: pointer;
            outline: none;
            transition: border-color 0.2s;
        }
        .filter-select:focus {
            border-color: var(--cz-primary);
        }

        .search-wrapper {
            position: relative;
            flex: 1;
            min-width: 250px;
        }
        .search-input {
            width: 100%;
            padding: 10px 15px 10px 40px;
            font-size: 13.5px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            outline: none;
            transition: border-color 0.2s;
        }
        .search-input:focus {
            border-color: var(--cz-primary);
        }
        .search-wrapper i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #aaa;
            font-size: 14px;
        }

        .btn-filter-action {
            padding: 10px 20px;
            font-size: 13.5px;
            font-weight: 600;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #444;
            transition: all 0.2s;
        }
        .btn-filter-action:hover {
            background-color: #fdfdfd;
            border-color: #ccc;
        }
        .btn-clear-filter {
            padding: 10px 15px;
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 8px;
            background-color: #555;
            color: #fff;
            text-decoration: none;
            transition: background 0.2s;
        }
        .btn-clear-filter:hover {
            background-color: #333;
            color: #fff;
        }

        /* Table Design */
        .table-card {
            background-color: var(--cz-card-bg);
            border-radius: 12px;
            border: 1px solid var(--cz-border-color);
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            margin-bottom: 25px;
        }
        .cz-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: collapse;
        }
        .cz-table th {
            background-color: #fffaf5;
            color: #666;
            font-size: 11.5px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 20px;
            border-bottom: 2px solid var(--cz-border-color);
        }
        .cz-table td {
            padding: 16px 20px;
            vertical-align: middle;
            font-size: 14px;
            border-bottom: 1px solid var(--cz-border-color);
        }
        .cz-table tr:hover td {
            background-color: #fdfbf9;
        }

        /* Badges Custom */
        .badge-category {
            background-color: #e8f0fe !important;
            color: #1a73e8 !important;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 30px;
        }
        .badge-success {
            background-color: #e6f6eb !important;
            color: #28a745 !important;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 30px;
        }
        .badge-secondary {
            background-color: #fcebeb !important;
            color: #dc3545 !important;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 30px;
        }

        .btn-action-edit, .btn-action-delete {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #666;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        .btn-action-edit {
            color: var(--cz-primary);
        }
        .btn-action-edit:hover {
            background-color: #f6faf5;
            border-color: var(--cz-primary);
        }
        .btn-action-delete {
            color: #dc3545;
        }
        .btn-action-delete:hover {
            background-color: #fdf3f4;
            border-color: #dc3545;
        }

        /* Pagination Design */
        .pagination-area {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 25px;
            border-top: 1px solid var(--cz-border-color);
            background-color: #fff;
        }
        .pagination-text {
            font-size: 13px;
            color: var(--cz-text-muted);
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
            border: 1px solid var(--cz-border-color);
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
            background-color: var(--cz-primary) !important;
            border-color: var(--cz-primary) !important;
            color: #fff !important;
        }
        .page-num-item.disabled a {
            opacity: 0.5;
            pointer-events: none;
            background-color: #f8f6f4;
        }
    </style>
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="blogs" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">

        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Hệ thống" />
            <jsp:param name="activeMenu" value="Quản lý bài viết" />
        </jsp:include>

        <div class="content-container">



            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý bài viết</h1>
                    <p class="page-subtitle">Quản lý các tin tức, bài hướng dẫn làm bánh, và bài quảng bá thương hiệu ngoài trang chủ.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/blog?action=create" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm bài viết mới
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/blog" method="get">
                    <input type="hidden" name="action" value="list">

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm kiếm bài viết theo tiêu đề, tóm tắt...">
                    </div>

                    <select name="category" class="filter-select">
                        <option value="all" ${selectedCategory eq 'all' ? 'selected' : ''}>Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat}" ${selectedCategory eq cat ? 'selected' : ''}>${cat}</option>
                        </c:forEach>
                    </select>

                    <select name="status" class="filter-select">
                        <option value="all" ${selectedStatus eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Active" ${selectedStatus eq 'Active' ? 'selected' : ''}>Đang hoạt động</option>
                        <option value="Hidden" ${selectedStatus eq 'Hidden' ? 'selected' : ''}>Đang ẩn</option>
                    </select>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/blog?action=list" class="btn-clear-filter text-center">Làm mới</a>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 60px; text-align: center;">STT</th>
                            <th style="width: 100px;">Ảnh đại diện</th>
                            <th>Tiêu đề bài viết</th>
                            <th style="width: 150px;">Danh mục</th>
                            <th style="width: 150px; text-align: center;">Trạng thái</th>
                            <th style="width: 160px;">Ngày đăng</th>
                            <th style="width: 130px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty blogList}">
                                <c:forEach var="b" items="${blogList}" varStatus="status">
                                    <tr>
                                        <td style="text-align: center;">${((currentPage - 1) * pageSize) + status.index + 1}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty b.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/${b.imageUrl}" alt="Thumbnail" style="width: 70px; height: 45px; object-fit: cover; border-radius: 4px; border: 1px solid #eee;">
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="width: 70px; height: 45px; background: #eee; display: flex; align-items: center; justify-content: center; border-radius: 4px;">
                                                        <i class="fa-regular fa-image text-muted" style="font-size: 16px;"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="font-weight: 600; color: #111; font-size: 14.5px; line-height: 1.4; max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                ${b.title}
                                            </div>
                                            <div class="text-muted" style="font-size: 12.5px; max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-top: 3px;">
                                                ${b.summary}
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-category">
                                                ${b.category}
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${b.status eq 'Active'}">
                                                    <span class="badge badge-success">Đang hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">Đang ẩn</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size: 13.5px; color: #666;">
                                            <fmt:formatDate value="${b.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center justify-content-center gap-2">
                                                <a href="${pageContext.request.contextPath}/admin/blog?action=edit&id=${b.postId}" class="btn-action-edit" title="Chỉnh sửa">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </a>
                                                <button type="button" class="btn-action-delete" title="Xóa" onclick="confirmDelete('${b.postId}', '${b.title}')">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fa-regular fa-folder-open d-block fs-1 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy bài viết nào phù hợp.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalRecords > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + blogList.size()} trong tổng số ${totalRecords} bài viết</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/blog?action=list&page=${currentPage - 1}&search=${search}&category=${selectedCategory}&status=${selectedStatus}&sort=${sort}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                            
                            <c:forEach var="pageNum" begin="1" end="${totalPages}">
                                <li class="page-num-item ${pageNum == currentPage ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/blog?action=list&page=${pageNum}&search=${search}&category=${selectedCategory}&status=${selectedStatus}&sort=${sort}">${pageNum}</a>
                                </li>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/blog?action=list&page=${currentPage + 1}&search=${search}&category=${selectedCategory}&status=${selectedStatus}&sort=${sort}">
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

    <!-- Hidden Form to execute DELETE request -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/blog" method="POST" style="display: none;">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="id" id="deleteId">
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        function confirmDelete(id, title) {
            if (confirm("Bạn có chắc chắn muốn xóa bài viết \"" + title + "\" không? Hành động này sẽ xóa vĩnh viễn hình ảnh đại diện và dữ liệu bài viết!")) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }

        // --- Toastify Alerts ---
        <c:if test="${not empty sessionScope.successMessage}">
            Toastify({
                text: "${sessionScope.successMessage}",
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                style: {
                    background: "linear-gradient(to right, #00b09b, #96c93d)"
                },
                stopOnFocus: true
            }).showToast();
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            Toastify({
                text: "${sessionScope.errorMessage}",
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                style: {
                    background: "linear-gradient(to right, #ff5f6d, #ffc371)"
                },
                stopOnFocus: true
            }).showToast();
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <c:if test="${not empty param.msg}">
            let msgText = "";
            let msgBg = "linear-gradient(to right, #00b09b, #96c93d)";
            const msgType = "${param.msg}";
            
            if (msgType === "add_success") {
                msgText = "Đã thêm mới bài viết thành công!";
            } else if (msgType === "edit_success") {
                msgText = "Đã cập nhật bài viết thành công!";
            } else if (msgType === "delete_success") {
                msgText = "Đã xóa bài viết thành công!";
            } else if (msgType === "delete_error") {
                msgText = "Xóa thất bại! Vui lòng thử lại.";
                msgBg = "linear-gradient(to right, #ff5f6d, #ffc371)";
            } else {
                msgText = msgType;
            }

            if (msgText) {
                Toastify({
                    text: msgText,
                    duration: 4000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: {
                        background: msgBg
                    },
                    stopOnFocus: true
                }).showToast();
            }
        </c:if>
    </script>
</body>
</html>
