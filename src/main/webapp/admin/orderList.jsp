<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Order Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

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

        /* Sidebar margin */
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
        .breadcrumbs {
            font-size: 13px;
            color: var(--cz-text-muted);
            margin-bottom: 0;
        }
        .breadcrumbs a {
            color: var(--cz-text-muted);
            text-decoration: none;
            transition: color 0.2s;
        }
        .breadcrumbs a:hover {
            color: var(--cz-primary);
        }
        .breadcrumbs span {
            margin: 0 6px;
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
        .filter-select, .filter-date {
            padding: 10px 15px;
            font-size: 13.5px;
            font-weight: 500;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #444;
            outline: none;
            transition: border-color 0.2s;
        }
        .filter-select {
            min-width: 160px;
            cursor: pointer;
        }
        .filter-select:focus, .filter-date:focus {
            border-color: var(--cz-primary);
        }

        .search-wrapper {
            position: relative;
            flex: 1;
            min-width: 280px;
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
            cursor: pointer;
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
            cursor: pointer;
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

        /* Custom Status Badges */
        .status-badge {
            font-size: 12px;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 30px;
            display: inline-block;
            text-align: center;
            white-space: nowrap;
        }
        .status-pending {
            background-color: #fef9c3;
            color: #a16207;
        }
        .status-confirmed {
            background-color: #dbeafe;
            color: #1e40af;
        }
        .status-processing {
            background-color: #f3e8ff;
            color: #6b21a8;
        }
        .status-delivering {
            background-color: #ffedd5;
            color: #9a3412;
        }
        .status-completed {
            background-color: #dcfce7;
            color: #166534;
        }
        .status-cancelled {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .btn-action-detail {
            padding: 6px 16px;
            font-size: 13px;
            font-weight: 600;
            border-radius: 8px;
            border: 1px solid var(--cz-primary);
            background-color: #fff;
            color: var(--cz-primary);
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-action-detail:hover {
            background-color: #f6faf5;
            border-color: var(--cz-primary-hover);
            color: var(--cz-primary-hover);
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
        
        .date-label {
            font-size: 12.5px;
            font-weight: 600;
            color: var(--cz-text-muted);
            margin-right: 5px;
        }
        .date-container {
            display: flex;
            align-items: center;
        }

        /* Clickable row */
        .cz-table tbody tr.clickable-row {
            cursor: pointer;
            transition: background-color 0.15s;
        }
        .cz-table tbody tr.clickable-row:hover td {
            background-color: #f0f7ee;
        }
    </style>
</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <div class="main-panel">
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Quản lý đơn hàng</a>
                </div>
            </div>

            <div class="header-right">
                <button class="header-icon-btn"><i class="fa-regular fa-bell"></i><span class="badge-dot"></span></button>
                <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>

                <div class="profile-section">
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                    <div class="profile-info">
                        <div class="profile-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                        <div class="profile-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="content-container">
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý đơn hàng</h1>
                    <p class="page-subtitle">Hệ thống theo dõi đơn đặt bánh, cập nhật trạng thái chế biến và giao hàng</p>
                </div>
            </div>

            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/orders" method="GET">
                    <input type="hidden" name="action" value="list">
                    
                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="<c:out value="${search}"/>" placeholder="Tìm kiếm theo mã đơn, tên hoặc SĐT khách...">
                    </div>

                    <select class="filter-select" name="status" onchange="this.form.submit()">
                        <option value="all" ${empty status || status eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Pending" ${status eq 'Pending' ? 'selected' : ''}>Chờ xác nhận</option>
                        <option value="Confirmed" ${status eq 'Confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                        <option value="Processing" ${status eq 'Processing' ? 'selected' : ''}>Đang xử lý</option>
                        <option value="Delivering" ${status eq 'Delivering' ? 'selected' : ''}>Đang giao</option>
                        <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                        <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                    </select>

                    <div class="date-container">
                        <span class="date-label">Từ:</span>
                        <input type="date" class="filter-date" name="startDate" value="${startDate}">
                    </div>

                    <div class="date-container">
                        <span class="date-label">Đến:</span>
                        <input type="date" class="filter-date" name="endDate" value="${endDate}">
                    </div>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/orders?action=list" class="btn-clear-filter text-center">Làm mới</a>
                </form>
            </div>

            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 120px;">Mã đơn</th>
                            <th>Khách hàng</th>
                            <th style="width: 160px;">Thời gian đặt</th>
                            <th style="width: 150px; text-align: right;">Tiền cọc</th>
                            <th style="width: 150px; text-align: right;">Tổng cộng</th>
                            <th style="width: 150px; text-align: center;">Trạng thái</th>
                            <th style="width: 120px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach items="${orders}" var="o">
                                    <tr class="clickable-row"
                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/orders?action=detail&orderNo=${o.orderNo}'"
                                    >
                                        <td class="fw-bold" style="color: var(--cz-primary);">
                                            #${o.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td>
                                            <div class="fw-bold"><c:out value="${not empty o.customerName ? o.customerName : 'Khách vãng lai'}" /></div>
                                            <div class="text-muted" style="font-size: 12px;">ID: ${o.customerId}</div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${o.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: right;" class="text-secondary font-monospace">
                                            <fmt:formatNumber value="${o.depositAmount}" type="number" pattern="#,##0"/>đ
                                        </td>
                                        <td style="text-align: right;" class="fw-bold font-monospace text-dark">
                                            <fmt:formatNumber value="${o.totalCost}" type="number" pattern="#,##0"/>đ
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus eq 'Pending' || o.orderStatus eq 'Chờ xác nhận'}">
                                                    <span class="status-badge status-pending">Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Confirmed' || o.orderStatus eq 'Đã xác nhận'}">
                                                    <span class="status-badge status-confirmed">Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Processing' || o.orderStatus eq 'Đang xử lý'}">
                                                    <span class="status-badge status-processing">Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Delivering' || o.orderStatus eq 'Đang giao hàng' || o.orderStatus eq 'Đang giao'}">
                                                    <span class="status-badge status-delivering">Đang giao</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Completed' || o.orderStatus eq 'Hoàn thành' || o.orderStatus eq 'Đã giao'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-cancelled">Đã hủy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;" onclick="event.stopPropagation();">
                                            <a href="${pageContext.request.contextPath}/admin/orders?action=detail&orderNo=${o.orderNo}" class="btn-action-detail" title="Chi tiết đơn hàng">
                                                Chi tiết <i class="fa-solid fa-angle-right"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-3 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy đơn hàng nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <div class="pagination-area">
                    <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang (${totalRecords} đơn hàng)</span>
                    <ul class="pagination-nav">
                        <c:if test="${currentPage > 1}">
                            <li class="page-num-item">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${currentPage - 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${i}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}">${i}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <li class="page-num-item">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${currentPage + 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}">
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
                backgroundColor: "linear-gradient(to right, #3f5f36, #5c8350)",
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
