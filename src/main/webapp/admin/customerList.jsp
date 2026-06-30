<%-- 
    Document   : customerList
    Created on : Jun 10, 2026, 11:57:56 PM
    Author     : Asus
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%-- Khai báo cả 2 phiên bản URI để đảm bảo NetBeans/Tomcat không bao giờ bị báo đỏ sọc --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin - Customer Management" />
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

            /* CSS SIDEBAR */
            .sidebar {
                width: 260px;
                background-color: var(--cz-dark-bg);
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                display: flex;
                flex-direction: column;
                padding: 20px 0;
                z-index: 100;
                overflow-y: auto;
            }

            .sidebar::-webkit-scrollbar {
                width: 6px;
            }
            .sidebar::-webkit-scrollbar-track {
                background: transparent;
            }
            .sidebar::-webkit-scrollbar-thumb {
                background: rgba(255, 255, 255, 0.25);
                border-radius: 4px;
            }
            .sidebar::-webkit-scrollbar-thumb:hover {
                background: rgba(255, 255, 255, 0.45);
            }

            .sidebar-brand {
                padding: 0 25px 25px 25px;
                display: flex;
                align-items: center;
                border-bottom: 1px solid #2d2b2b;
            }

            .sidebar-brand i {
                color: var(--cz-primary);
                font-size: 24px;
                margin-right: 10px;
            }
            .sidebar-brand span {
                color: #fff;
                font-size: 20px;
                font-weight: 700;
                letter-spacing: 0.5px;
            }
            .sidebar-brand span span {
                color: var(--cz-primary);
            }
            .nav-section-title {
                color: var(--cz-text-muted);
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                padding: 20px 25px 8px 25px;
            }
            .sidebar-menu {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .menu-item a {
                display: flex;
                align-items: center;
                padding: 11px 25px;
                color: #b5b5b5;
                text-decoration: none;
                font-size: 14px;
                font-weight: 500;
                transition: all 0.2s ease;
            }
            .menu-item a:hover {
                color: #fff;
                background-color: var(--cz-sidebar-active);
            }
            .menu-item.active a {
                color: var(--cz-primary);
                background-color: var(--cz-sidebar-active);
                border-left: 3px solid var(--cz-primary);
                font-weight: 600;
            }
            .menu-item a i {
                display: inline-block;
                width: 20px;
                font-size: 16px;
                margin-right: 12px;
                text-align: center;
            }

            .sidebar-banner {
                margin: auto 20px 20px 20px;
                background: linear-gradient(135deg, #232222, #181717);
                border-radius: 12px;
                padding: 20px;
                border: 1px dashed var(--cz-primary);
                text-align: center;
            }
            .sidebar-banner i.cake-icon {
                font-size: 40px;
                color: var(--cz-primary);
                margin-bottom: 10px;
                display: inline-block;
            }
            .sidebar-banner h6 {
                color: #fff;
                font-size: 14px;
                margin-bottom: 6px;
            }
            .sidebar-banner p {
                color: #999;
                font-size: 11px;
                margin-bottom: 0;
            }

            /* Main Content Panel */
            .main-panel {
                margin-left: 260px;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }

            /* Top Header */
            .top-header {
                height: 70px;
                background-color: #fff;
                border-bottom: 1px solid var(--cz-border-color);
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 35px;
                position: sticky;
                top: 0;
                z-index: 90;
            }

            .header-left {
                display: flex;
                align-items: center;
                gap: 15px;
            }
            .sidebar-toggle {
                background: none;
                border: none;
                font-size: 18px;
                color: #555;
                cursor: pointer;
            }


            .header-right {
                display: flex;
                align-items: center;
                gap: 20px;
            }
            .header-icon-btn {
                background: none;
                border: none;
                font-size: 18px;
                color: #555;
                position: relative;
                cursor: pointer;
                transition: color 0.2s;
            }
            .header-icon-btn:hover {
                color: var(--cz-primary);
            }
            .header-icon-btn .badge-dot {
                position: absolute;
                top: -2px;
                right: -2px;
                width: 8px;
                height: 8px;
                background-color: var(--cz-primary);
                border-radius: 50%;
                border: 1px solid #fff;
            }

            .profile-section {
                display: flex;
                align-items: center;
                gap: 10px;
                border-left: 1px solid var(--cz-border-color);
                padding-left: 20px;
            }
            .profile-img {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid var(--cz-border-color);
            }
            .profile-info {
                line-height: 1.2;
            }
            .profile-name {
                font-size: 13.5px;
                font-weight: 600;
                color: #333;
            }
            .profile-role {
                font-size: 10.5px;
                color: var(--cz-text-muted);
                font-weight: 500;
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
            .badge-customer {
                background-color: #6c757d !important;
                color: white;
                font-weight: 600;
                padding: 5px 10px;
                border-radius: 6px;
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

            /* ĐỒNG BỘ CSS NÚT SỬA XOÁ ĐỂ HIỆN ICON CHUẨN MẪU */
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

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="customers" />
        </jsp:include>

        <div class="main-panel">



            <!-- Top Header -->
            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="Hệ thống" />
                <jsp:param name="activeMenu" value="Quản lý khách hàng" />
            </jsp:include>

            <div class="content-container">

                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Quản lý khách hàng</h1>
                        <p class="page-subtitle">Hệ thống quản lý tài khoản khách hàng mua sắm hệ thống Bakery</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/customer?action=add" class="btn btn-cz-primary">
                        <i class="fa-solid fa-circle-plus"></i> Thêm khách hàng mới
                    </a>
                </div>

                <div class="filter-card">
                    <form class="filter-form" action="${pageContext.request.contextPath}/admin/customer" method="GET">
                        <input type="hidden" name="action" value="list">
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" class="search-input" name="searchKeyword" value="${param.searchKeyword}" placeholder="Tìm kiếm khách hàng theo tên, email...">
                        </div>

                        <select class="filter-select" name="filterStatus" onchange="this.form.submit()">
                            <option value="" ${empty param.filterStatus ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="Active" ${param.filterStatus eq 'Active' ? 'selected' : ''}>Đang hoạt động</option>
                            <option value="Deactive" ${param.filterStatus eq 'Deactive' ? 'selected' : ''}>Đã khóa</option>
                        </select>

                        <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                        <a href="${pageContext.request.contextPath}/admin/customer?action=list" class="btn-clear-filter text-center">Làm mới</a>
                    </form>
                </div>

                <div class="table-card">
                    <table class="cz-table">
                        <thead>
                            <tr>
                                <th style="width: 60px; text-align: center;">STT</th>
                                <th>Họ và Tên</th>
                                <th>Email đăng nhập</th>
                                <th>Số điện thoại</th>
                                <th style="width: 150px; text-align: center;">Chức vụ</th>
                                <th style="width: 150px; text-align: center;">Trạng thái</th>
                                <th style="width: 130px; text-align: center;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${CUSTOMERS}" var="c" varStatus="status">
                                <tr>
                                    <td style="text-align: center;">${(currentPage - 1) * 5 + status.count}</td>
                                    <td class="font-weight-bold">${c.fullName}</td>
                                    <td>${c.user.email}</td>
                                    <td class="text-warning">${c.phone}</td>
                                    <td style="text-align: center;">
                                        <span class="badge badge-customer">Khách hàng</span>
                                    </td>
                                    <td style="text-align: center;">
                                        <c:set var="statusKey" value="${not empty c.user.accountStatus ? c.user.accountStatus : c.user.account_Status}" />
                                        <span class="badge ${statusKey eq 'Active' ? 'badge-success' : 'badge-secondary'}">
                                            <c:choose>
                                                <c:when test="${statusKey eq 'Active'}">Đang hoạt động</c:when>
                                                <c:when test="${statusKey eq 'Deactive'}">Đã khóa</c:when>
                                                <c:otherwise>${statusKey}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center justify-content-center gap-2">
                                            <c:set var="cusIdKey" value="${not empty c.customerId ? c.customerId : c.customer_ID}" />
                                            <a href="${pageContext.request.contextPath}/admin/customer?action=edit&id=${c.customerId}" class="btn-action-edit" title="Chỉnh sửa">
                                                <i class="fa-regular fa-pen-to-square"></i>
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/customer?action=delete&id=${c.customerId}" class="btn-action-delete"
                                               onclick="return confirm('Bạn có chắc chắn muốn xóa tài khoản của ${c.fullName} không?')" title="Xóa">
                                                <i class="fa-regular fa-trash-can"></i>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <div class="pagination-area">
                        <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${endPage}</b> trang</span>
                        <ul class="pagination-nav">
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/customer?action=list&page=${currentPage - 1}&searchKeyword=${param.searchKeyword}&filterStatus=${param.filterStatus}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>

                            <c:forEach begin="1" end="${endPage}" var="i">
                                <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/customer?action=list&page=${i}&searchKeyword=${param.searchKeyword}&filterStatus=${param.filterStatus}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:if test="${currentPage < endPage}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/customer?action=list&page=${currentPage + 1}&searchKeyword=${param.searchKeyword}&filterStatus=${param.filterStatus}">
                                        <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>   
                </div>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

        <script>
            <c:if test="${not empty sessionScope.successMessage}">
                                                   Toastify({
                                                       text: "${sessionScope.successMessage}",
                                                       duration: 4000,
                                                       close: true,
                                                       gravity: "top",
                                                       position: "right",
                                                       backgroundColor: "linear-gradient(to right, #00b09b, #96c93d)",
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
                                                       backgroundColor: "linear-gradient(to right, #ff5f6d, #ffc371)",
                                                       stopOnFocus: true
                                                   }).showToast();
                <c:remove var="errorMessage" scope="session" />
            </c:if>
        </script>
    </body>
</html>
