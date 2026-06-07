<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Product List</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Custom styling -->
    <style>
        :root {
            --cz-primary: #F28123;
            --cz-primary-hover: #e06f14;
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
        }

        /* Sidebar Styling */
        .sidebar {
            width: 260px;
            background-color: var(--cz-dark-bg);
            min-height: 100vh;
            position: fixed;
            top: 0;
            left: 0;
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            z-index: 100;
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
            border-left: 3px solid transparent;
        }

        .menu-item a:hover {
            color: #fff;
            background-color: var(--cz-sidebar-active);
        }

        .menu-item.active a {
            color: var(--cz-primary);
            background-color: var(--cz-sidebar-active);
            border-left-color: var(--cz-primary);
            font-weight: 600;
        }

        .menu-item a i {
            width: 20px;
            font-size: 16px;
            margin-right: 12px;
        }

        .menu-item .arrow {
            margin-left: auto;
            font-size: 12px;
        }

        /* Sidebar Seeding Card */
        .sidebar-banner {
            margin: auto 20px 20px 20px;
            background: linear-gradient(135deg, #232222, #181717);
            border-radius: 12px;
            padding: 20px;
            border: 1px dashed var(--cz-primary);
            text-align: center;
            position: relative;
        }

        .sidebar-banner i.cake-icon {
            font-size: 40px;
            color: var(--cz-primary);
            margin-bottom: 10px;
            display: inline-block;
            animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-5px); }
            100% { transform: translateY(0px); }
        }

        .sidebar-banner h6 {
            color: #fff;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .sidebar-banner p {
            color: #999;
            font-size: 11px;
            margin-bottom: 0;
            line-height: 1.4;
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

        /* Dashboard Container */
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
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .level-badge {
            background-color: #fef0e4;
            color: var(--cz-primary);
            font-size: 11px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 6px;
            letter-spacing: 0.5px;
            border: 1px solid #ffd8b8;
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
        }

        .btn-cz-primary:hover {
            background-color: var(--cz-primary-hover);
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(242, 129, 35, 0.25);
        }

        /* Filters Card */
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

        .btn-filter-action i {
            margin-right: 6px;
        }

        /* Table Card */
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

        /* Product cell design */
        .product-cell {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .product-thumb {
            width: 54px;
            height: 54px;
            border-radius: 8px;
            object-fit: cover;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
        }

        .product-meta {
            display: flex;
            flex-direction: column;
        }

        .product-name-link {
            font-size: 14px;
            font-weight: 600;
            color: #222;
            text-decoration: none;
            transition: color 0.15s;
        }

        .product-name-link:hover {
            color: var(--cz-primary);
        }

        .product-sku {
            font-size: 11.5px;
            color: var(--cz-text-muted);
            font-weight: 500;
            margin-top: 1px;
        }

        .product-desc {
            font-size: 12px;
            color: #777;
            margin-top: 3px;
            max-width: 250px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .stock-badge-in {
            color: #2d8636;
            font-weight: 600;
            font-size: 13.5px;
        }
        
        .stock-subtext {
            display: block;
            font-size: 11px;
            color: #28a745;
            font-weight: 500;
            margin-top: 1px;
        }

        .featured-star {
            color: #ddd;
            font-size: 16px;
            cursor: pointer;
            transition: color 0.2s;
        }

        .featured-star.active {
            color: #FFB800;
        }

        .status-badge-active {
            background-color: #e6f6eb;
            color: #28a745;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 30px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-badge-active::before {
            content: '';
            width: 6px;
            height: 6px;
            background-color: #28a745;
            border-radius: 50%;
        }

        .status-badge-inactive {
            background-color: #fcebeb;
            color: #dc3545;
            font-size: 12px;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 30px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-badge-inactive::before {
            content: '';
            width: 6px;
            height: 6px;
            background-color: #dc3545;
            border-radius: 50%;
        }

        /* Action Buttons */
        .actions-cell {
            display: flex;
            gap: 12px;
        }

        .btn-action-view, .btn-action-edit, .btn-action-delete {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #666;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .btn-action-view:hover {
            color: #0b5ed7;
            border-color: #0b5ed7;
            background-color: #f4f8fd;
        }

        .btn-action-edit:hover {
            color: var(--cz-primary);
            border-color: var(--cz-primary);
            background-color: #fef8f4;
        }

        .btn-action-delete:hover {
            color: #dc3545;
            border-color: #dc3545;
            background-color: #fdf3f4;
        }

        /* Pagination area */
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
            background-color: var(--cz-primary);
            border-color: var(--cz-primary);
            color: #fff;
        }

        .page-num-item.dots a {
            border: none;
            background: none;
            cursor: default;
            color: #aaa;
        }
    </style>
</head>
<body>

    <!-- Left Sidebar -->
    <div class="sidebar">
        <div class="sidebar-brand">
            <i class="fa-solid fa-cake-candles"></i>
            <span>Cake<span>Zone</span> Admin</span>
        </div>
        
        <div class="nav-section-title">Hệ thống chính</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-gauge"></i> Bảng điều khiển</a>
            </li>
        </ul>

        <div class="nav-section-title">Quản lý</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-receipt"></i> Đơn hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/admin/products"><i class="fa-solid fa-cookie-bite"></i> Sản phẩm <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item" style="padding-left: 20px;">
                <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Danh mục</a>
            </li>
            <li class="menu-item" style="padding-left: 20px;">
                <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Thuộc tính</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-users"></i> Khách hàng</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-percent"></i> Khuyến mãi <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-warehouse"></i> Kho hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-truck-ramp-box"></i> Giao hàng <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-star-half-stroke"></i> Đánh giá</a>
            </li>
        </ul>

        <div class="nav-section-title">Hệ thống</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-user-gear"></i> Tài khoản</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-shield-halved"></i> Vai trò & Quyền hạn</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-sliders"></i> Cài đặt chung</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-clock-rotate-left"></i> Nhật ký hoạt động</a>
            </li>
        </ul>

        <!-- Grow Your Bakery card -->
        <div class="sidebar-banner">
            <i class="fa-solid fa-cake-candles cake-icon"></i>
            <h6>Phát triển tiệm bánh</h6>
            <p>Tạo ra những chiếc bánh đẹp và trao gửi hạnh phúc!</p>
        </div>
    </div>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="#">Bảng điều khiển</a>
                    <span>&gt;</span>
                    <a href="#">Sản phẩm</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Danh sách bánh kem</a>
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
             <c:if test="${not empty sessionScope.errorMessage or param.msg eq 'save_error' or param.msg eq 'delete_error'}">
                  <div class="alert alert-danger alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-triangle-exclamation me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'save_error'}">Lưu thông tin bánh kem thất bại. Vui lòng kiểm tra lại!</c:when>
                          <c:when test="${param.msg eq 'delete_error'}">Không thể xóa bánh kem này vì đang có ràng buộc dữ liệu.</c:when>
                          <c:otherwise>${sessionScope.errorMessage}</c:otherwise>
                      </c:choose>
                      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                  </div>
                  <c:remove var="errorMessage" scope="session" />
             </c:if>
             <c:if test="${not empty sessionScope.successMessage or param.msg eq 'save_success' or param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success'}">
                  <div class="alert alert-success alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-circle-check me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'add_success'}">Đã thêm mới bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'edit_success' or param.msg eq 'save_success'}">Đã cập nhật thông tin bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_success'}">Đã xóa bánh kem thành công!</c:when>
                          <c:otherwise>${sessionScope.successMessage}</c:otherwise>
                      </c:choose>
                      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                  </div>
                  <c:remove var="successMessage" scope="session" />
             </c:if>
            
            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Danh sách bánh kem</h1>
                    <p class="page-subtitle">Quản lý tất cả sản phẩm bánh kem, nguyên liệu và trạng thái kinh doanh.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/product-detail?id=new" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm bánh mới
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/products" method="get">
                    <!-- Maintain page size -->
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    
                     <select class="filter-select" name="category" onchange="this.form.submit()">
                        <option value="" ${empty category ? 'selected' : ''}>Tất cả danh mục</option>
                        <c:forEach var="cat" items="${productCategories}">
                            <option value="${cat.id}" ${category eq cat.id or category eq cat.name ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>

                    <select class="filter-select" name="status" onchange="this.form.submit()">
                        <option value="" ${empty status ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Active" ${status eq 'Active' ? 'selected' : ''}>Hoạt động</option>
                        <option value="Inactive" ${status eq 'Inactive' ? 'selected' : ''}>Ngưng bán</option>
                    </select>

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm kiếm bánh theo tên, mã...">
                    </div>

                    <select class="filter-select" name="sortBy" onchange="this.form.submit()">
                        <option value="newest" ${sortBy eq 'newest' ? 'selected' : ''}>Sắp xếp: Mới nhất</option>
                        <option value="price-asc" ${sortBy eq 'price-asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                        <option value="price-desc" ${sortBy eq 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                    </select>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Hình ảnh & Tên bánh</th>
                            <th>Danh mục</th>
                            <th style="min-width: 180px;">Giá & Giờ công</th>
                            <th class="text-center" style="width: 160px;">Cho phép ghi chữ</th>
                            <th class="text-center" style="width: 100px;">Nổi bật</th>
                            <th class="text-center" style="width: 150px;">Trạng thái</th>
                            <th style="width: 150px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty productList}">
                                <c:forEach var="p" items="${productList}" varStatus="status">
                                    <tr>
                                        <td>${((currentPage - 1) * pageSize) + status.index + 1}</td>
                                        <td>
                                            <div class="product-cell">
                                                <c:choose>
                                                    <c:when test="${not empty p.imageUrl}">
                                                        <img src="${p.imageUrl}" alt="${p.name}" class="product-thumb">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=100" alt="Default Cake" class="product-thumb">
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="product-meta">
                                                    <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="product-name-link">${p.name}</a>
                                                    <span class="product-sku">Mã: ${p.id}</span>
                                                </div>
                                            </div>
                                        </td>
                                         <td>${p.categoryName}</td>
                                         <td>
                                             <span style="font-size: 14.5px; font-weight: 700; color: #e06f14; display: block;">
                                                 <fmt:formatNumber value="${p.basePrice}" type="number" pattern="#,##0"/> đ
                                             </span>
                                             <div class="text-muted mt-1" style="font-size: 12px; font-weight: 500;">
                                                 <i class="fa-regular fa-clock me-1" style="color: #aaa;"></i> Giờ công: ${p.estimatedLaborHours} giờ
                                             </div>
                                         </td>
                                         <td class="text-center">
                                             <c:choose>
                                                 <c:when test="${p.allowsGreeting}">
                                                     <span class="badge" style="background-color: #e3f2fd; color: #0d6efd; border: 1px solid #bbdefb; font-size: 11px; font-weight: 600; padding: 5px 10px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px;">
                                                         <i class="fa-regular fa-pen-to-square"></i> Được ghi chữ
                                                     </span>
                                                 </c:when>
                                                 <c:otherwise>
                                                     <span class="badge" style="background-color: #f5f5f5; color: #888; border: 1px solid #ddd; font-size: 11px; font-weight: 500; padding: 5px 10px; border-radius: 4px;">
                                                         Không hỗ trợ
                                                     </span>
                                                 </c:otherwise>
                                             </c:choose>
                                         </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${p.featured}">
                                                    <i class="fa-solid fa-star featured-star active"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-regular fa-star featured-star"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${p.status eq 'Active'}">
                                                    <span class="status-badge-active">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge-inactive">Ngưng bán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="actions-cell">
                                                <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="btn-action-view" title="Xem chi tiết">
                                                    <i class="fa-regular fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="btn-action-edit" title="Chỉnh sửa">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </a>
                                                <button class="btn-action-delete" title="Xóa" onclick="if(confirm('Bạn có chắc chắn muốn xóa bánh kem ${p.name} không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=delete&id=${p.id}'; }">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-2 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy bánh kem nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalCount > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + productList.size()} trong tổng số ${totalCount} sản phẩm</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <!-- Prev page -->
                            <li class="page-num-item ${currentPage <= 1 ? 'disabled' : ''}">
                                <a href="${pageContext.request.contextPath}/admin/products?page=${currentPage > 1 ? currentPage - 1 : 1}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                </a>
                            </li>
                            
                            <!-- Page Numbers -->
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-num-item ${i == currentPage ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/products?page=${i}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <!-- Next page -->
                            <li class="page-num-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                <a href="${pageContext.request.contextPath}/admin/products?page=${currentPage < totalPages ? currentPage + 1 : totalPages}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
                                    <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </ul>
                        
                        <form action="${pageContext.request.contextPath}/admin/products" method="get" class="d-inline">
                            <input type="hidden" name="category" value="${category}">
                            <input type="hidden" name="status" value="${status}">
                            <input type="hidden" name="search" value="${search}">
                            <input type="hidden" name="sortBy" value="${sortBy}">
                            <select class="filter-select" name="pageSize" onchange="this.form.submit()" style="min-width: auto; padding: 5px 25px 5px 10px; font-size: 12.5px;">
                                <option value="5" ${pageSize == 5 ? 'selected' : ''}>5 / trang</option>
                                <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / trang</option>
                                <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 / trang</option>
                            </select>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
