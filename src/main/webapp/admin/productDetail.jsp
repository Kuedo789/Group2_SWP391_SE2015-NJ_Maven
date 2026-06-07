<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Product Detail</title>
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

        .profile-name {
            font-size: 13.5px;
            font-weight: 600;
            color: #333;
        }

        .profile-role {
            font-size: 10.5px;
            color: var(--cz-text-muted);
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
            margin-bottom: 30px;
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
            background-color: #f0f7f1;
            color: #28a745;
            font-size: 11px;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 6px;
            letter-spacing: 0.5px;
            border: 1px solid #c7ebcf;
        }

        .page-subtitle {
            font-size: 13.5px;
            color: var(--cz-text-muted);
            margin-bottom: 0;
        }

        /* Form Buttons */
        .action-button-group {
            display: flex;
            gap: 10px;
        }

        .btn-cz-outline {
            border: 1px solid var(--cz-border-color);
            background-color: #fff;
            color: #444;
            font-weight: 600;
            font-size: 13.5px;
            padding: 10px 18px;
            border-radius: 8px;
            transition: all 0.2s;
        }

        .btn-cz-outline:hover {
            background-color: #fcfcfc;
            border-color: #bbb;
        }

        .btn-cz-primary {
            background-color: var(--cz-primary);
            color: #fff;
            font-weight: 600;
            font-size: 13.5px;
            padding: 10px 22px;
            border-radius: 8px;
            border: none;
            transition: all 0.2s;
        }

        .btn-cz-primary:hover {
            background-color: var(--cz-primary-hover);
            color: #fff;
            box-shadow: 0 4px 10px rgba(242, 129, 35, 0.25);
        }

        .btn-cz-danger {
            border: 1px solid #fcebeb;
            background-color: #fdf3f3;
            color: #dc3545;
            font-weight: 600;
            font-size: 13.5px;
            padding: 10px 18px;
            border-radius: 8px;
            transition: all 0.2s;
        }

        .btn-cz-danger:hover {
            background-color: #dc3545;
            color: #fff;
        }

        /* Cards Layout */
        .detail-card {
            background-color: var(--cz-card-bg);
            border-radius: 12px;
            border: 1px solid var(--cz-border-color);
            padding: 24px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.01);
        }

        .card-header-title {
            font-size: 16px;
            font-weight: 700;
            color: #111;
            margin-bottom: 4px;
        }

        .card-header-desc {
            font-size: 12px;
            color: var(--cz-text-muted);
            margin-bottom: 20px;
        }

        /* Images Grid */
        .main-cover-wrapper {
            position: relative;
            width: 100%;
            height: 280px;
            border-radius: 10px;
            overflow: hidden;
            border: 1px solid var(--cz-border-color);
            background-color: #fafafa;
            margin-bottom: 15px;
        }

        .main-cover-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .cover-badge {
            position: absolute;
            top: 15px;
            left: 15px;
            background-color: var(--cz-primary);
            color: #fff;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: 4px;
            letter-spacing: 0.5px;
        }

        .image-controls {
            position: absolute;
            top: 15px;
            right: 15px;
            display: flex;
            gap: 8px;
        }

        .img-control-btn {
            width: 30px;
            height: 30px;
            border-radius: 6px;
            background-color: rgba(255, 255, 255, 0.9);
            border: none;
            color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .img-control-btn:hover {
            background-color: #fff;
            color: var(--cz-primary);
        }

        .img-control-btn.delete:hover {
            color: #dc3545;
        }

        .thumbnails-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
        }

        .thumb-box {
            height: 75px;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid var(--cz-border-color);
            cursor: pointer;
            position: relative;
        }

        .thumb-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .upload-placeholder-box {
            border: 1px dashed var(--cz-primary);
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background-color: #fffbf7;
            height: 75px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .upload-placeholder-box:hover {
            background-color: #fef4ec;
        }

        .upload-placeholder-box i {
            color: var(--cz-primary);
            font-size: 16px;
            margin-bottom: 2px;
        }

        .upload-placeholder-box span {
            font-size: 9px;
            color: var(--cz-primary);
            font-weight: 600;
        }

        .upload-info-text {
            grid-column: span 4;
            font-size: 11.5px;
            color: var(--cz-text-muted);
            text-align: center;
            margin-top: 5px;
        }

        /* Recipe Grid Config */
        .recipe-item-wrapper {
            margin-bottom: 20px;
        }

        .recipe-preview-card {
            margin-top: 10px;
            border: 1px solid var(--cz-border-color);
            border-radius: 10px;
            overflow: hidden;
            display: flex;
            background-color: #fff;
        }

        .recipe-preview-img {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-right: 1px solid var(--cz-border-color);
        }

        .recipe-preview-info {
            padding: 12px 15px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .recipe-preview-title {
            font-size: 12.5px;
            font-weight: 700;
            color: #222;
            margin-bottom: 4px;
        }

        .recipe-preview-desc {
            font-size: 11.5px;
            color: #777;
            line-height: 1.4;
            margin-bottom: 0;
        }

        /* Forms Details styling */
        .form-label-cz {
            font-size: 13px;
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }

        .form-label-cz span {
            color: #dc3545;
        }

        .form-control-cz {
            width: 100%;
            padding: 10px 15px;
            font-size: 13.5px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            outline: none;
            background-color: #fff;
            transition: all 0.2s;
        }

        .form-control-cz:focus {
            border-color: var(--cz-primary);
            box-shadow: 0 0 0 3px rgba(242, 129, 35, 0.1);
        }

        .form-select-cz {
            width: 100%;
            padding: 10px 15px;
            font-size: 13.5px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            outline: none;
            background-color: #fff;
            cursor: pointer;
            transition: border-color 0.2s;
        }

        .form-select-cz:focus {
            border-color: var(--cz-primary);
        }

        /* Radio & Toggle styling */
        .status-radio-group {
            display: flex;
            gap: 20px;
            margin-top: 5px;
        }

        .status-radio-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13.5px;
            font-weight: 500;
            cursor: pointer;
            color: #555;
        }

        .status-radio-input {
            width: 17px;
            height: 17px;
            accent-color: var(--cz-primary);
            cursor: pointer;
        }

        /* Featured switch */
        .switch-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background-color: var(--cz-light-bg);
            padding: 12px 18px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            margin-top: 5px;
        }

        .switch-label-text {
            font-size: 13px;
            font-weight: 500;
            color: #555;
        }

        .switch-input {
            width: 40px;
            height: 20px;
            appearance: none;
            background-color: #ccc;
            border-radius: 20px;
            position: relative;
            outline: none;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .switch-input:checked {
            background-color: var(--cz-primary);
        }

        .switch-input::before {
            content: '';
            width: 16px;
            height: 16px;
            background-color: #fff;
            border-radius: 50%;
            position: absolute;
            top: 2px;
            left: 2px;
            transition: transform 0.2s;
        }

        .switch-input:checked::before {
            transform: translateX(20px);
        }

        /* Description rich editor mock */
        .editor-toolbar {
            border: 1px solid var(--cz-border-color);
            border-bottom: none;
            background-color: #fcfcfc;
            padding: 8px 12px;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
            display: flex;
            gap: 15px;
            color: #666;
            font-size: 14px;
        }

        .editor-toolbar i {
            cursor: pointer;
            transition: color 0.15s;
        }

        .editor-toolbar i:hover {
            color: var(--cz-primary);
        }

        .editor-textarea {
            border: 1px solid var(--cz-border-color);
            border-bottom-left-radius: 8px;
            border-bottom-right-radius: 8px;
            width: 100%;
            padding: 15px;
            font-size: 13.5px;
            outline: none;
            resize: vertical;
            min-height: 120px;
        }

        .editor-textarea:focus {
            border-color: var(--cz-primary);
        }

        /* Tags and Badge Info */
        .tags-wrapper {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 10px;
        }

        .tag-badge {
            background-color: #fef0e4;
            color: var(--cz-primary);
            border: 1px solid #ffd8b8;
            border-radius: 6px;
            padding: 6px 12px;
            font-size: 12.5px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .tag-badge i {
            font-size: 11px;
            cursor: pointer;
            color: #aaa;
            transition: color 0.15s;
        }

        .tag-badge i:hover {
            color: var(--cz-primary);
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
        
        <div class="nav-section-title">Core</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-gauge"></i> Dashboard</a>
            </li>
        </ul>

        <div class="nav-section-title">Management</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-receipt"></i> Orders <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/admin/products"><i class="fa-solid fa-cookie-bite"></i> Products <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item" style="padding-left: 20px;">
                <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Categories</a>
            </li>
            <li class="menu-item" style="padding-left: 20px;">
                <a href="#" style="font-size: 13px; padding: 8px 25px;"><i class="fa-solid fa-caret-right"></i> Attributes</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-users"></i> Customers</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-percent"></i> Promotions <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-warehouse"></i> Inventory <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-truck-ramp-box"></i> Delivery <i class="fa-solid fa-chevron-down arrow"></i></a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-star-half-stroke"></i> Reviews</a>
            </li>
        </ul>

        <div class="nav-section-title">System</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-user-gear"></i> Users</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-shield-halved"></i> Roles & Permissions</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-sliders"></i> Settings</a>
            </li>
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-clock-rotate-left"></i> Activity Logs</a>
            </li>
        </ul>

        <div class="sidebar-banner">
            <i class="fa-solid fa-cake-candles cake-icon"></i>
            <h6>Grow Your Bakery</h6>
            <p>Create beautiful cakes and deliver happiness!</p>
        </div>
    </div>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="#">Dashboard</a>
                    <span>&gt;</span>
                    <a href="#">Products</a>
                    <span>&gt;</span>
                    <a href="${pageContext.request.contextPath}/admin/products">Product List</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Product Detail</a>
                </div>
            </div>
            
            <div class="header-right">
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
            
            <form action="${pageContext.request.contextPath}/admin/product-detail" method="post">
                <!-- Keep track of the product ID -->
                <input type="hidden" name="id" value="${product.id}">
                <input type="hidden" name="imageUrl" value="${product.imageUrl}">
                <input type="hidden" name="productType" value="${product.productType}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Chi Tiết Bánh Kem</h1>
                        <p class="page-subtitle">Xem và quản lý thông tin chi tiết, giá bán gốc và số giờ làm việc ước tính.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="submit" class="btn-cz-primary"><i class="fa-regular fa-floppy-disk me-1"></i> Lưu Lại</button>
                        <button type="button" class="btn-cz-danger" onclick="if(confirm('Bạn có chắc chắn muốn xóa bánh kem này không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=delete&id=${product.id}'; }">Xóa Bánh</button>
                    </div>
                </div>

                <div class="row">
                    <!-- Left Column -->
                    <div class="col-lg-5">
                        
                        <!-- Product Images Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Hình Ảnh Bánh Kem</h5>
                            <p class="card-header-desc">Nhập liên kết hình ảnh bánh chất lượng cao. Bấm chọn ảnh nhỏ bên dưới để chọn làm hình đại diện (ảnh bìa chính) hiển thị trên cửa hàng.</p>
                            
                            <div class="main-cover-wrapper">
                                <img id="mainCoverImage" src="${not empty product.imageUrl ? product.imageUrl : 'https://images.unsplash.com/photo-1578985545062-69928b1d9587'}" alt="${product.name}" class="main-cover-img">
                                <span class="cover-badge">Ảnh Bìa</span>
                                <div class="image-controls">
                                    <button type="button" class="img-control-btn" onclick="editMainImageUrl()"><i class="fa-regular fa-pen-to-square"></i></button>
                                    <button type="button" class="img-control-btn delete" onclick="deleteMainImage()"><i class="fa-regular fa-trash-can"></i></button>
                                </div>
                            </div>
                            
                            <!-- Container for hidden inputs to keep the list synchronized with POST -->
                            <div id="hiddenImagesContainer">
                                <c:forEach var="img" items="${product.additionalImages}">
                                    <input type="hidden" name="additionalImages" value="${img}">
                                </c:forEach>
                            </div>

                            <div class="thumbnails-grid" id="thumbnailsGrid">
                                <c:forEach var="img" items="${product.additionalImages}">
                                    <div class="thumb-box" onclick="setAsCover('${img}')" data-url="${img}">
                                        <img src="${img}" alt="Thumbnail">
                                        <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-1" style="font-size: 8px; line-height: 1;" onclick="event.stopPropagation(); removeThumbnail('${img}')">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </div>
                                </c:forEach>
                                <div class="upload-placeholder-box" onclick="addNewImagePrompt()">
                                    <i class="fa-solid fa-plus"></i>
                                    <span>Thêm Ảnh</span>
                                </div>
                                <div class="upload-info-text">Bấm 'Thêm Ảnh' để dán link ảnh mới từ internet. Bấm ảnh nhỏ để chọn làm ảnh đại diện chính.</div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="col-lg-7">
                        
                        <!-- Product Information Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Bánh Kem</h5>
                            
                            <div class="row g-3">
                                 <div class="col-md-12">
                                     <label class="form-label-cz">Tên Bánh Kem <span>*</span></label>
                                     <input type="text" class="form-control-cz" name="name" value="${product.name}" required>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Danh mục <span>*</span></label>
                                     <select class="form-select-cz" name="categoryId">
                                         <c:forEach var="cat" items="${productCategories}">
                                             <option value="${cat.id}" ${product.categoryId eq cat.id ? 'selected' : ''}>${cat.name}</option>
                                         </c:forEach>
                                     </select>
                                 </div>
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Giá Bán Gốc ($) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" name="basePrice" value="${product.basePrice}" required>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Thời Gian Làm Việc Ước Tính (giờ) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" name="estimatedLaborHours" value="${product.estimatedLaborHours}" required>
                                 </div>
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Cho Phép Ghi Chữ</label>
                                     <div class="switch-container">
                                         <span class="switch-label-text">Cho phép khách ghi chữ chúc mừng lên mặt bánh</span>
                                         <input type="checkbox" class="switch-input" name="allowsGreeting" value="true" ${product.allowsGreeting ? 'checked' : ''}>
                                     </div>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Trạng Thái Kinh Doanh <span>*</span></label>
                                     <div class="status-radio-group">
                                         <label class="status-radio-label">
                                             <input type="radio" name="status" class="status-radio-input" value="Active" ${product.status eq 'Active' ? 'checked' : ''}>
                                             Đang hoạt động
                                         </label>
                                         <label class="status-radio-label">
                                             <input type="radio" name="status" class="status-radio-input" value="Inactive" ${product.status eq 'Inactive' ? 'checked' : ''}>
                                             Tạm ngưng bán
                                         </label>
                                     </div>
                                 </div>
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Nổi Bật / Khuyên Dùng</label>
                                     <div class="switch-container">
                                         <span class="switch-label-text">Hiển thị nổi bật trên trang chủ & danh mục nổi bật</span>
                                         <input type="checkbox" class="switch-input" name="isFeatured" value="true" ${product.featured ? 'checked' : ''}>
                                     </div>
                                 </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Mô Tả Chi Tiết</label>
                                    <div class="editor-toolbar">
                                        <i class="fa-solid fa-bold" title="In đậm"></i>
                                        <i class="fa-solid fa-italic" title="In nghiêng"></i>
                                        <i class="fa-solid fa-underline" title="Gạch chân"></i>
                                        <i class="fa-solid fa-strikethrough" title="Gạch ngang"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-align-left" title="Căn lề trái"></i>
                                        <i class="fa-solid fa-align-center" title="Căn giữa"></i>
                                        <i class="fa-solid fa-align-right" title="Căn lề phải"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-list-ul" title="Danh sách không thứ tự"></i>
                                        <i class="fa-solid fa-list-ol" title="Danh sách có thứ tự"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-link" title="Thêm liên kết"></i>
                                        <i class="fa-solid fa-image" title="Thêm ảnh"></i>
                                    </div>
                                    <textarea class="editor-textarea" name="fullDescription" rows="5">${product.fullDescription}</textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Set main cover image when a thumbnail is clicked
        function setAsCover(url) {
            document.getElementById('mainCoverImage').src = url;
            document.querySelector('input[name="imageUrl"]').value = url;
        }

        // Add new image URL dynamically to form and thumbnail grid
        function addNewImagePrompt() {
            const url = prompt("Please enter the Image URL:");
            if (url && url.trim() !== "") {
                const cleanUrl = url.trim();
                
                // Add to hidden container
                const container = document.getElementById('hiddenImagesContainer');
                const hiddenInput = document.createElement('input');
                hiddenInput.type = 'hidden';
                hiddenInput.name = 'additionalImages';
                hiddenInput.value = cleanUrl;
                container.appendChild(hiddenInput);

                // Add thumbnail box
                const grid = document.getElementById('thumbnailsGrid');
                const placeholder = grid.querySelector('.upload-placeholder-box');
                
                const thumbBox = document.createElement('div');
                thumbBox.className = 'thumb-box';
                thumbBox.setAttribute('data-url', cleanUrl);
                thumbBox.onclick = function() { setAsCover(cleanUrl); };
                
                thumbBox.innerHTML = `
                    <img src="${cleanUrl}" alt="Thumbnail">
                    <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-1" style="font-size: 8px; line-height: 1;" onclick="event.stopPropagation(); removeThumbnail('${cleanUrl}')">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                `;
                
                grid.insertBefore(thumbBox, placeholder);
            }
        }

        // Remove a thumbnail and its corresponding hidden input
        function removeThumbnail(url) {
            // Remove the hidden input element
            const inputs = document.querySelectorAll(`input[name="additionalImages"][value="${url}"]`);
            inputs.forEach(input => input.remove());

            // Remove the thumbnail block
            const thumbs = document.querySelectorAll(`.thumb-box[data-url="${url}"]`);
            thumbs.forEach(thumb => thumb.remove());

            // Check if deleted image was the cover image
            const mainImgInput = document.querySelector('input[name="imageUrl"]');
            if (mainImgInput.value === url) {
                // Try to fallback to the first remaining thumbnail
                const remainingThumbs = document.querySelectorAll('.thumb-box');
                if (remainingThumbs.length > 0) {
                    const fallbackUrl = remainingThumbs[0].getAttribute('data-url');
                    setAsCover(fallbackUrl);
                } else {
                    const defaultUrl = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587';
                    document.getElementById('mainCoverImage').src = defaultUrl;
                    mainImgInput.value = defaultUrl;
                }
            }
        }

        // Edit the main cover image URL directly
        function editMainImageUrl() {
            const currentUrl = document.querySelector('input[name="imageUrl"]').value;
            const newUrl = prompt("Enter main cover Image URL:", currentUrl);
            if (newUrl && newUrl.trim() !== "") {
                const cleanUrl = newUrl.trim();
                setAsCover(cleanUrl);
                
                // Add to list if not already present
                const existingInput = document.querySelector(`input[name="additionalImages"][value="${cleanUrl}"]`);
                if (!existingInput) {
                    // Add hidden input
                    const container = document.getElementById('hiddenImagesContainer');
                    const hiddenInput = document.createElement('input');
                    hiddenInput.type = 'hidden';
                    hiddenInput.name = 'additionalImages';
                    hiddenInput.value = cleanUrl;
                    container.appendChild(hiddenInput);

                    // Add thumbnail box
                    const grid = document.getElementById('thumbnailsGrid');
                    const placeholder = grid.querySelector('.upload-placeholder-box');
                    const thumbBox = document.createElement('div');
                    thumbBox.className = 'thumb-box';
                    thumbBox.setAttribute('data-url', cleanUrl);
                    thumbBox.onclick = function() { setAsCover(cleanUrl); };
                    thumbBox.innerHTML = `
                        <img src="${cleanUrl}" alt="Thumbnail">
                        <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-1" style="font-size: 8px; line-height: 1;" onclick="event.stopPropagation(); removeThumbnail('${cleanUrl}')">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    `;
                    grid.insertBefore(thumbBox, placeholder);
                }
            }
        }

        // Reset main cover image to default
        function deleteMainImage() {
            if (confirm("Reset cover image to default template image?")) {
                const defaultUrl = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587';
                document.getElementById('mainCoverImage').src = defaultUrl;
                document.querySelector('input[name="imageUrl"]').value = defaultUrl;
            }
        }
    </script>
</body>
</html>
