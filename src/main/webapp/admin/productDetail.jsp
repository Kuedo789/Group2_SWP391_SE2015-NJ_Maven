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
                <input type="hidden" name="id" value="${product.id()}">
                <input type="hidden" name="imageUrl" value="${product.imageUrl()}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Product Detail <span class="level-badge">Level 4</span></h1>
                        <p class="page-subtitle">View and manage cake product information, pricing, inventory, and recipe.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="button" class="btn-cz-outline" onclick="alert('Previewing cake layers structure...')"><i class="fa-regular fa-eye"></i> Preview</button>
                        <button type="button" class="btn-cz-outline" onclick="alert('Draft saved successfully!')">Save Draft</button>
                        <button type="submit" class="btn-cz-primary">Publish</button>
                        <button type="button" class="btn-cz-danger" onclick="if(confirm('Are you sure you want to delete this product?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=delete&id=${product.id()}'; }">Delete</button>
                    </div>
                </div>

                <div class="row">
                    <!-- Left Column -->
                    <div class="col-lg-5">
                        
                        <!-- Product Images Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Product Images</h5>
                            <p class="card-header-desc">Upload high quality images of the cake. First image will be used as the cover.</p>
                            
                            <div class="main-cover-wrapper">
                                <c:choose>
                                    <c:when test="${not empty product.imageUrl()}">
                                        <img src="${product.imageUrl()}" alt="${product.name()}" class="main-cover-img">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587" alt="Default Cover" class="main-cover-img">
                                    </c:otherwise>
                                </c:choose>
                                <span class="cover-badge">Cover</span>
                                <div class="image-controls">
                                    <button type="button" class="img-control-btn"><i class="fa-regular fa-pen-to-square"></i></button>
                                    <button type="button" class="img-control-btn delete"><i class="fa-regular fa-trash-can"></i></button>
                                </div>
                            </div>
                            
                            <div class="thumbnails-grid">
                                <div class="thumb-box">
                                    <c:choose>
                                        <c:when test="${not empty product.imageUrl()}">
                                            <img src="${product.imageUrl()}" alt="Thumbnail">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587" alt="Thumbnail">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="thumb-box">
                                    <img src="https://images.unsplash.com/photo-1565958011703-44f9829ba187" alt="Thumbnail 2">
                                </div>
                                <div class="thumb-box">
                                    <img src="https://images.unsplash.com/photo-1524351199679-46cddf530c04" alt="Thumbnail 3">
                                </div>
                                <div class="upload-placeholder-box" onclick="alert('Select image to upload...')">
                                    <i class="fa-solid fa-plus"></i>
                                    <span>Upload Image</span>
                                </div>
                                <div class="upload-info-text">Drag & drop or click to upload (You can upload up to 8 images, max 5MB each)</div>
                            </div>
                        </div>

                        <!-- Recipe Configuration Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Recipe Configuration</h5>
                            <p class="card-header-desc">Define the core components that make up this delicious cake.</p>
                            
                            <!-- Sponge -->
                            <div class="recipe-item-wrapper">
                                <label class="form-label-cz">Sponge Flavor <span>*</span></label>
                                <select class="form-select-cz" name="spongeFlavor">
                                    <option value="Chocolate Sponge" ${product.spongeFlavor() eq 'Chocolate Sponge' ? 'selected' : ''}>Chocolate Sponge</option>
                                    <option value="Vanilla Sponge" ${product.spongeFlavor() eq 'Vanilla Sponge' ? 'selected' : ''}>Vanilla Sponge</option>
                                    <option value="Graham Cracker Crust" ${product.spongeFlavor() eq 'Graham Cracker Crust' ? 'selected' : ''}>Graham Cracker Crust</option>
                                    <option value="Moist Chocolate Cupcake" ${product.spongeFlavor() eq 'Moist Chocolate Cupcake' ? 'selected' : ''}>Moist Chocolate Cupcake</option>
                                </select>
                                
                                <div class="recipe-preview-card">
                                    <img src="https://images.unsplash.com/photo-1606313564200-e75d5e30476c" alt="Sponge Preview" class="recipe-preview-img">
                                    <div class="recipe-preview-info">
                                        <div class="recipe-preview-title">Sponge Layer Preview</div>
                                        <p class="recipe-preview-desc">
                                            <c:choose>
                                                <c:when test="${not empty product.spongeFlavor()}">${product.spongeFlavor()} layer base prepared fresh.</c:when>
                                                <c:otherwise>Delicious sponge layer prepared according to traditional recipe.</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <!-- Frosting -->
                            <div class="recipe-item-wrapper">
                                <label class="form-label-cz">Frosting <span>*</span></label>
                                <select class="form-select-cz" name="frostingFlavor">
                                    <option value="Chocolate Ganache" ${product.frostingFlavor() eq 'Chocolate Ganache' ? 'selected' : ''}>Chocolate Ganache</option>
                                    <option value="Strawberry Frosting" ${product.frostingFlavor() eq 'Strawberry Frosting' ? 'selected' : ''}>Strawberry Frosting</option>
                                    <option value="Cream Cheese" ${product.frostingFlavor() eq 'Cream Cheese' ? 'selected' : ''}>Cream Cheese</option>
                                    <option value="Creamy Chocolate Frosting" ${product.frostingFlavor() eq 'Creamy Chocolate Frosting' ? 'selected' : ''}>Creamy Chocolate Frosting</option>
                                    <option value="Vanilla Buttercream" ${product.frostingFlavor() eq 'Vanilla Buttercream' ? 'selected' : ''}>Vanilla Buttercream</option>
                                </select>
                                
                                <div class="recipe-preview-card">
                                    <img src="https://images.unsplash.com/photo-1511018556340-d16986a1c194" alt="Frosting Preview" class="recipe-preview-img">
                                    <div class="recipe-preview-info">
                                        <div class="recipe-preview-title">Frosting Layer Preview</div>
                                        <p class="recipe-preview-desc">
                                            <c:choose>
                                                <c:when test="${not empty product.frostingFlavor()}">${product.frostingFlavor()} whipped coating.</c:when>
                                                <c:otherwise>Creamy and rich frosting layer applied by master decorators.</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <!-- Topping -->
                            <div class="recipe-item-wrapper">
                                <label class="form-label-cz">Topping <span>*</span></label>
                                <select class="form-select-cz" name="toppingChoice">
                                    <option value="Chocolate Shavings & Cherry" ${product.toppingChoice() eq 'Chocolate Shavings & Cherry' ? 'selected' : ''}>Chocolate Shavings & Cherry</option>
                                    <option value="Fresh Strawberries & Whipped Cream" ${product.toppingChoice() eq 'Fresh Strawberries & Whipped Cream' ? 'selected' : ''}>Fresh Strawberries & Whipped Cream</option>
                                    <option value="Sour Cream Layer" ${product.toppingChoice() eq 'Sour Cream Layer' ? 'selected' : ''}>Sour Cream Layer</option>
                                    <option value="Chocolate Shavings" ${product.toppingChoice() eq 'Chocolate Shavings' ? 'selected' : ''}>Chocolate Shavings</option>
                                    <option value="Colorful Sprinkles" ${product.toppingChoice() eq 'Colorful Sprinkles' ? 'selected' : ''}>Colorful Sprinkles</option>
                                </select>
                                
                                <div class="recipe-preview-card">
                                    <img src="https://images.unsplash.com/photo-1519869325930-281384150729" alt="Topping Preview" class="recipe-preview-img">
                                    <div class="recipe-preview-info">
                                        <div class="recipe-preview-title">Topping Choice Preview</div>
                                        <p class="recipe-preview-desc">
                                            <c:choose>
                                                <c:when test="${not empty product.toppingChoice()}">Finished with ${product.toppingChoice()} garnish.</c:when>
                                                <c:otherwise>Beautiful selection of toppings and candy drops to garnish the top.</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <!-- Allergens -->
                            <div class="recipe-item-wrapper">
                                <label class="form-label-cz">Allergens</label>
                                <select class="form-select-cz" name="allergens">
                                    <option value="Egg, Milk, Wheat, Soy" ${product.allergens() eq 'Egg, Milk, Wheat, Soy' ? 'selected' : ''}>Egg, Milk, Wheat, Soy</option>
                                    <option value="Egg, Milk, Wheat" ${product.allergens() eq 'Egg, Milk, Wheat' ? 'selected' : ''}>Egg, Milk, Wheat</option>
                                    <option value="Milk, Egg, Wheat" ${product.allergens() eq 'Milk, Egg, Wheat' ? 'selected' : ''}>Milk, Egg, Wheat</option>
                                    <option value="None" ${product.allergens() eq 'None' ? 'selected' : ''}>None (Allergen Free)</option>
                                </select>
                            </div>

                            <!-- Weight / Size -->
                            <div class="recipe-item-wrapper">
                                <label class="form-label-cz">Weight / Size</label>
                                <select class="form-select-cz" name="weightSize">
                                    <option value="1 kg" ${product.weightSize() eq '1 kg' ? 'selected' : ''}>1 kg</option>
                                    <option value="1.2 kg" ${product.weightSize() eq '1.2 kg' ? 'selected' : ''}>1.2 kg</option>
                                    <option value="6 pieces" ${product.weightSize() eq '6 pieces' ? 'selected' : ''}>6 pieces (Pack)</option>
                                    <option value="Standard" ${product.weightSize() eq 'Standard' ? 'selected' : ''}>Standard</option>
                                </select>
                            </div>

                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="col-lg-7">
                        
                        <!-- Product Information Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Product Information</h5>
                            
                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label class="form-label-cz">Cake Name <span>*</span></label>
                                    <input type="text" class="form-control-cz" name="name" value="${product.name()}" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label-cz">SKU <span>*</span></label>
                                    <input type="text" class="form-control-cz" name="sku" value="${product.sku()}" required>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Category <span>*</span></label>
                                    <select class="form-select-cz" name="category">
                                        <option value="Chocolate Cakes" ${product.category() eq 'Chocolate Cakes' ? 'selected' : ''}>Chocolate Cakes</option>
                                        <option value="Fruit Cakes" ${product.category() eq 'Fruit Cakes' ? 'selected' : ''}>Fruit Cakes</option>
                                        <option value="Cheesecakes" ${product.category() eq 'Cheesecakes' ? 'selected' : ''}>Cheesecakes</option>
                                        <option value="Cupcakes" ${product.category() eq 'Cupcakes' ? 'selected' : ''}>Cupcakes</option>
                                        <option value="Accessories" ${product.category() eq 'Accessories' ? 'selected' : ''}>Accessories</option>
                                        <option value="Celebration Cakes" ${product.category() eq 'Celebration Cakes' ? 'selected' : ''}>Celebration Cakes</option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label-cz">Base Price (USD) <span>*</span></label>
                                    <input type="number" step="0.01" class="form-control-cz" name="price" value="${product.price()}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label-cz">Sale Price (USD)</label>
                                    <input type="number" step="0.01" class="form-control-cz" name="salePrice" value="${product.price() * 0.9}">
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label-cz">Stock Quantity <span>*</span></label>
                                    <input type="number" class="form-control-cz" name="stock" value="${product.stock()}" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label-cz">Preparation Time</label>
                                    <select class="form-select-cz" name="laborHours">
                                        <option value="1.0" ${product.laborHours() == 1.0 ? 'selected' : ''}>1 hour</option>
                                        <option value="1.5" ${product.laborHours() == 1.5 ? 'selected' : ''}>1.5 hours</option>
                                        <option value="2.0" ${product.laborHours() == 2.0 ? 'selected' : ''}>2 hours</option>
                                        <option value="2.5" ${product.laborHours() == 2.5 ? 'selected' : ''}>2.5 hours</option>
                                        <option value="3.0" ${product.laborHours() == 3.0 ? 'selected' : ''}>3 hours</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label-cz">Availability</label>
                                    <select class="form-select-cz" name="availability">
                                        <option value="Same Day" ${product.availability() eq 'Same Day' ? 'selected' : ''}>Same Day</option>
                                        <option value="1 Day Notice" ${product.availability() eq '1 Day Notice' ? 'selected' : ''}>1 Day Notice</option>
                                        <option value="2 Days Notice" ${product.availability() eq '2 Days Notice' ? 'selected' : ''}>2 Days Notice</option>
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label-cz">Status <span>*</span></label>
                                    <div class="status-radio-group">
                                        <label class="status-radio-label">
                                            <input type="radio" name="status" class="status-radio-input" value="Active" ${product.status() eq 'Active' ? 'checked' : ''}>
                                            Active
                                        </label>
                                        <label class="status-radio-label">
                                            <input type="radio" name="status" class="status-radio-input" value="Inactive" ${product.status() eq 'Inactive' ? 'checked' : ''}>
                                            Inactive
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label-cz">Featured</label>
                                    <div class="switch-container">
                                        <span class="switch-label-text">Show on homepage & featured section</span>
                                        <input type="checkbox" class="switch-input" name="featured" value="true" ${product.featured() ? 'checked' : ''}>
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Short Description <span>*</span></label>
                                    <textarea class="form-control-cz" name="shortDescription" rows="2" required>${product.shortDescription()}</textarea>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Full Description</label>
                                    <div class="editor-toolbar">
                                        <i class="fa-solid fa-bold" title="Bold"></i>
                                        <i class="fa-solid fa-italic" title="Italic"></i>
                                        <i class="fa-solid fa-underline" title="Underline"></i>
                                        <i class="fa-solid fa-strikethrough" title="Strikethrough"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-align-left" title="Align Left"></i>
                                        <i class="fa-solid fa-align-center" title="Align Center"></i>
                                        <i class="fa-solid fa-align-right" title="Align Right"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-list-ul" title="Unordered List"></i>
                                        <i class="fa-solid fa-list-ol" title="Ordered List"></i>
                                        <span style="border-right: 1px solid #ddd; margin: 0 5px;"></span>
                                        <i class="fa-solid fa-link" title="Insert Link"></i>
                                        <i class="fa-solid fa-image" title="Insert Image"></i>
                                    </div>
                                    <textarea class="editor-textarea" name="fullDescription" rows="5">${product.fullDescription()}</textarea>
                                </div>
                            </div>
                        </div>

                        <!-- Additional Information Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Additional Information</h5>
                            
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label-cz">Tags</label>
                                    <div class="tags-wrapper">
                                        <span class="tag-badge">Chocolate <i class="fa-solid fa-xmark"></i></span>
                                        <span class="tag-badge">Best Seller <i class="fa-solid fa-xmark"></i></span>
                                        <span class="tag-badge">Birthday <i class="fa-solid fa-xmark"></i></span>
                                        <div class="upload-placeholder-box" style="height: auto; padding: 5px 12px; border-radius: 6px; border-style: solid; border-width: 1px;" onclick="alert('Add custom tags...')">
                                            <span style="font-size: 12px; font-weight: 500;"><i class="fa-solid fa-plus" style="font-size: 10px; margin-right: 4px;"></i> Add Tag</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Shelf Life</label>
                                    <select class="form-select-cz" name="shelfLife">
                                        <option value="1 Day" ${product.shelfLife() eq '1 Day' ? 'selected' : ''}>1 Day</option>
                                        <option value="2 Days" ${product.shelfLife() eq '2 Days' ? 'selected' : ''}>2 Days</option>
                                        <option value="3 Days" ${product.shelfLife() eq '3 Days' ? 'selected' : ''}>3 Days</option>
                                        <option value="5 Days" ${product.shelfLife() eq '5 Days' ? 'selected' : ''}>5 Days</option>
                                        <option value="1 Year" ${product.shelfLife() eq '1 Year' ? 'selected' : ''}>1 Year</option>
                                    </select>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Storage Instructions</label>
                                    <textarea class="form-control-cz" name="storageInstructions" rows="2">${product.storageInstructions()}</textarea>
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
</body>
</html>
