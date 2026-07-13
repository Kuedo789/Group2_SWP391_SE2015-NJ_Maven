<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Product Detail" />
    </jsp:include>
    <!-- Quill Rich Text Editor CSS -->
    <link href="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.snow.css" rel="stylesheet" crossorigin="anonymous">
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductDetail.css?v=1.5">
    <style>
        .product-images-container {
            background: #ffffff;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            font-family: 'Be Vietnam Pro', sans-serif;
            margin-bottom: 25px;
        }
        .product-images-header {
            margin-bottom: 20px;
        }
        .images-title {
            font-size: 16px;
            font-weight: 700;
            color: #1f2937;
            margin-bottom: 4px;
        }
        .images-subtitle {
            font-size: 12.5px;
            color: #6b7280;
            margin: 0;
        }
        .images-layout-grid {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        .cover-image-panel {
            display: flex;
            flex-direction: column;
        }
        .cover-image-wrapper {
            position: relative;
            width: 100%;
            aspect-ratio: 16/10;
            border-radius: 12px;
            overflow: hidden;
            background-color: #f3f4f6;
            border: 1px solid #e5e7eb;
            cursor: zoom-in;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.02);
        }
        .cover-image-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        .cover-image-wrapper:hover img {
            transform: scale(1.02);
        }
        .cover-badge {
            position: absolute;
            top: 16px;
            left: 16px;
            background-color: #f97316;
            color: #ffffff;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-transform: capitalize;
            box-shadow: 0 2px 4px rgba(249, 115, 22, 0.3);
        }
        .cover-actions {
            position: absolute;
            top: 16px;
            right: 16px;
            display: flex;
            gap: 8px;
            background: rgba(31, 41, 55, 0.75);
            backdrop-filter: blur(4px);
            padding: 6px;
            border-radius: 8px;
            opacity: 0;
            transition: opacity 0.25s ease;
        }
        .cover-image-wrapper:hover .cover-actions {
            opacity: 1;
        }
        .action-btn {
            background: none;
            border: none;
            color: #ffffff;
            font-size: 14px;
            padding: 6px;
            cursor: pointer;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s;
        }
        .action-btn:hover {
            background-color: rgba(255, 255, 255, 0.15);
        }
        .delete-cover-btn:hover {
            color: #ef4444;
        }
        
        .gallery-grid-panel {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
        }
        .gallery-item-wrapper {
            position: relative;
            aspect-ratio: 1/1;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #e5e7eb;
            background: #f9fafb;
            cursor: zoom-in;
            transition: transform 0.2s;
        }
        .gallery-item-wrapper:hover {
            transform: translateY(-2px);
        }
        .gallery-item-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .delete-gallery-btn {
            position: absolute;
            top: 4px;
            right: 4px;
            background: rgba(239, 68, 68, 0.9);
            color: #ffffff;
            border: none;
            width: 18px;
            height: 18px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 9px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
            transition: transform 0.2s, background-color 0.2s;
            padding: 0;
        }
        .delete-gallery-btn:hover {
            transform: scale(1.15);
            background-color: #dc2626;
        }
        
        .upload-trigger-card {
            aspect-ratio: 1/1;
            border: 2px dashed #d1d5db;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: border-color 0.3s, background-color 0.3s;
            background: #ffffff;
            padding: 8px;
            text-align: center;
        }
        .upload-trigger-card:hover {
            border-color: #f97316;
            background-color: #fffaf7;
        }
        .upload-icon {
            font-size: 16px;
            color: #f97316;
            margin-bottom: 4px;
        }
        .upload-text {
            font-size: 11px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 2px;
        }
        .upload-hint {
            font-size: 9px;
            color: #9ca3af;
        }
        
        .drag-drop-info-card {
            border: 1px solid #f3f4f6;
            background-color: #f9fafb;
            border-radius: 8px;
            padding: 10px 14px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
        }
        .info-title {
            font-size: 12px;
            font-weight: 600;
            color: #4b5563;
            margin-bottom: 2px;
        }
        .info-desc {
            font-size: 10px;
            color: #9ca3af;
        }

        /* Lightbox modal */
        .lightbox-modal {
            display: none;
            position: fixed;
            z-index: 9999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.85);
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.25s ease;
        }
        .lightbox-modal.show {
            display: flex;
            opacity: 1;
        }
        .lightbox-content {
            margin: auto;
            display: block;
            max-width: 90%;
            max-height: 90%;
            border-radius: 8px;
            box-shadow: 0 4px 30px rgba(0,0,0,0.5);
            transform: scale(0.95);
            transition: transform 0.25s ease;
        }
        .lightbox-modal.show .lightbox-content {
            transform: scale(1);
        }
        .lightbox-close {
            position: absolute;
            top: 25px;
            right: 30px;
            color: #f1f1f1;
            font-size: 36px;
            font-weight: bold;
            transition: color 0.2s;
            cursor: pointer;
        }
        .lightbox-close:hover {
            color: #f97316;
        }
        
        /* Custom modal overrides to bypass Bootstrap JS backdrop bugs */
        .modal.custom-active {
            display: block !important;
            background: rgba(0, 0, 0, 0.5) !important;
            opacity: 1 !important;
        }
        .modal.custom-active .modal-dialog {
            transform: none !important;
        }
        
        /* New premium design system overrides to match mockups */
        .pricing-suggested-card {
            background-color: #0f2d1e;
            color: #ffffff;
            border-radius: 8px;
            padding: 15px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            box-shadow: 0 4px 15px rgba(15, 45, 30, 0.2);
            border: 1px solid #1e4d35;
            margin-top: 5px;
            height: 100%;
            justify-content: center;
        }
        .pricing-suggested-card .pricing-title {
            font-size: 11px;
            font-weight: 700;
            color: #a3b899;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 6px;
        }
        .pricing-suggested-card .pricing-value {
            font-size: 24px;
            font-weight: 800;
            color: #eab308;
            margin-bottom: 6px;
        }
        .pricing-suggested-card .pricing-formula {
            font-size: 11px;
            color: #8fae85;
        }
        
        .input-group-cz {
            display: flex;
            align-items: center;
            position: relative;
        }
        .input-group-cz .form-control-cz {
            padding-right: 35px;
        }
        .input-group-cz .input-group-addon {
            position: absolute;
            right: 15px;
            color: #7c8b74;
            font-weight: 600;
            font-size: 13.5px;
            pointer-events: none;
        }
        
        .btn-modern-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 20px 15px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            transition: all 0.25s ease;
            cursor: pointer;
            width: calc(50% - 8px);
            text-align: center;
            min-height: 100px;
            border: none;
        }
        .btn-modern-card.btn-bom {
            background-color: #0f2d1e;
            border: 1px solid #0f2d1e;
            color: #ffffff;
        }
        .btn-modern-card.btn-bom:hover {
            background-color: #17472f;
            border-color: #17472f;
            box-shadow: 0 6px 18px rgba(15, 45, 30, 0.25);
        }
        .btn-modern-card.btn-recipe {
            background-color: #ffffff;
            border: 1.5px solid #0f2d1e;
            color: #0f2d1e;
        }
        .btn-modern-card.btn-recipe:hover {
            background-color: #f4f7f5;
            box-shadow: 0 6px 18px rgba(15, 45, 30, 0.1);
        }
        .btn-modern-card .card-icon {
            font-size: 20px;
        }
        
        .alert-info-cz {
            background-color: #eff6ff;
            border: 1px solid #dbeafe;
            border-radius: 8px;
            padding: 12px 16px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 20px;
            text-align: left;
        }
        .alert-info-cz .info-icon {
            color: #2563eb;
            font-size: 16px;
            margin-top: 2px;
        }
        .alert-info-cz .info-text {
            color: #1e3a8a;
            font-size: 13px;
            font-weight: 500;
            line-height: 1.5;
        }
        
        .btn-delete-bom-row {
            background: none;
            border: none;
            color: #ef4444;
            font-size: 16px;
            cursor: pointer;
            transition: transform 0.2s, color 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            margin: 0 auto;
        }
        .btn-delete-bom-row:hover {
            color: #b91c1c;
            transform: scale(1.15);
        }
        .modal-header-cz {
            background-color: #0f2d1e !important;
            color: white !important;
        }
    </style>
</head>
<body>


    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="products" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Sản phẩm" />
            <jsp:param name="parentUrl" value="#" />
            <jsp:param name="parentMenu2" value="Danh sách bánh kem" />
            <jsp:param name="parentUrl2" value="${pageContext.request.contextPath}/admin/product?action=list" />
            <jsp:param name="activeMenu" value="Chi tiết bánh kem" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <form action="${pageContext.request.contextPath}/admin/product?action=${formAction}" method="post" enctype="multipart/form-data">
                <!-- Keep track of the product ID -->
                <input type="hidden" name="id" value="${product.id}">
                <input type="hidden" name="productType" value="${product.productType}">
                <!-- Keep track of pagination/filters -->
                <input type="hidden" name="page" value="${param.page}">
                <input type="hidden" name="pageSize" value="${param.pageSize}">
                <input type="hidden" name="category" value="${param.category}">
                <input type="hidden" name="statusFilter" value="${param.status}">
                <input type="hidden" name="search" value="${param.search}">
                <input type="hidden" name="sortBy" value="${param.sortBy}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Chi Tiết Bánh Kem</h1>
                        <p class="page-subtitle">Xem và quản lý thông tin chi tiết, cấu trúc tài chính và quy trình chế biến của bánh kem.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="submit" class="btn-cz-primary"><i class="fa-regular fa-floppy-disk me-1"></i> Lưu Lại</button>
                        <c:if test="${product.id ne 'new' and not empty product.id}">
                            <button type="button" class="btn-cz-danger" onclick="if(confirm('Bạn có chắc chắn muốn xóa bánh kem này không?')) { deleteProduct('${product.id}'); }">Xóa bánh kem</button>
                        </c:if>
                    </div>
                </div>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert" style="background-color: #fdf3f3; border-color: #fcebeb; color: #dc3545; border-radius: 8px; font-weight: 500; font-size: 14px; margin-bottom: 25px;">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="row">
                    <!-- Left Column -->
                    <div class="col-lg-5">
                        
                        <!-- Product Images Card -->
                        <div class="product-images-container">
                            <div class="product-images-header">
                                <h5 class="images-title">Hình Ảnh Bánh Kem</h5>
                                <p class="images-subtitle">Tải lên hình ảnh bánh kem chất lượng cao. Ảnh bìa lớn bên dưới sẽ được sử dụng làm ảnh đại diện chính.</p>
                            </div>
                            
                            <c:set var="resolvedImageUrl" value="https://images.unsplash.com/photo-1578985545062-69928b1d9587" />
                            <c:if test="${not empty product.imageUrl}">
                                <c:choose>
                                    <c:when test="${product.imageUrl.startsWith('http://') or product.imageUrl.startsWith('https://')}">
                                        <c:set var="resolvedImageUrl" value="${product.imageUrl}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="resolvedImageUrl" value="${pageContext.request.contextPath}/${product.imageUrl}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            
                            <div class="images-layout-grid">
                                <!-- Cover Image Panel -->
                                <div class="cover-image-panel">
                                    <div class="cover-image-wrapper" title="Nhấp để xem ảnh lớn hơn">
                                        <img id="mainCoverImage" src="${resolvedImageUrl}" alt="Ảnh Bìa Bánh" onclick="openLightbox(this.src)" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587';">
                                        <div class="cover-badge">Ảnh Bìa</div>
                                        <div class="cover-actions">
                                            <button type="button" class="action-btn edit-cover-btn" onclick="event.stopPropagation(); document.getElementById('imageFileInput').click()" title="Thay đổi ảnh bìa">
                                                <i class="fa-solid fa-pencil"></i>
                                            </button>
                                            <button type="button" class="action-btn delete-cover-btn" onclick="event.stopPropagation(); resetCoverImage()" title="Xóa ảnh bìa">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <input type="file" name="imageFile" id="imageFileInput" accept=".jpg,.jpeg,.png" style="display: none;">
                                    <input type="hidden" name="imageUrl" id="imageUrlHidden" value="${product.imageUrl}">
                                    <div id="imageError" class="text-danger mt-1" style="font-size: 13px; display: none;"></div>
                                </div>
                                
                                <!-- Gallery Grid -->
                                <div class="gallery-grid-panel">
                                    <div id="additionalImagesContainer" class="gallery-grid">
                                        <c:forEach var="addImg" items="${product.additionalImages}">
                                            <div class="gallery-item-wrapper" title="Nhấp để xem ảnh lớn hơn">
                                                <c:set var="resolvedAddImg" value="${addImg}" />
                                                <c:if test="${not (addImg.startsWith('http://') or addImg.startsWith('https://'))}">
                                                    <c:set var="resolvedAddImg" value="${pageContext.request.contextPath}/${addImg}" />
                                                </c:if>
                                                <img src="${resolvedAddImg}" onclick="openLightbox(this.src)" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587';">
                                                <input type="hidden" name="existingAdditionalImages" value="${addImg}">
                                                <button type="button" class="delete-gallery-btn" onclick="event.stopPropagation(); this.parentElement.remove()" title="Xóa ảnh này">
                                                    <i class="fa-solid fa-xmark"></i>
                                                </button>
                                            </div>
                                        </c:forEach>
                                        
                                        <!-- Upload Box -->
                                        <div class="upload-trigger-card" onclick="document.getElementById('additionalImageFilesInput').click()" title="Tải thêm ảnh phụ">
                                            <i class="fa-solid fa-plus upload-icon"></i>
                                            <span class="upload-text">Thêm Ảnh</span>
                                            <span class="upload-hint">JPG, PNG (Tối đa 5MB)</span>
                                        </div>
                                    </div>
                                    <input type="file" id="additionalImageFilesInput" accept=".jpg,.jpeg,.png" multiple style="display: none;">
                                    <input type="file" name="additionalImageFiles" id="additionalImageFilesHidden" multiple style="display: none;">
                                    <div id="additionalImagesError" class="text-danger mt-2" style="font-size: 13px; display: none;"></div>
                                    
                                    <!-- Info footer -->
                                    <div class="drag-drop-info-card">
                                        <span class="info-title">Nhấp vào ô trên để tải thêm ảnh chi tiết</span>
                                        <span class="info-desc">Bạn có thể chọn và tải lên cùng lúc tối đa 8 ảnh phụ</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="col-lg-7">
                        <style>
                            .cz-tabs {
                                display: flex;
                                border-bottom: 2px solid #e5e7eb;
                                margin-bottom: 20px;
                                gap: 6px;
                                flex-wrap: wrap;
                            }
                            .cz-tab-btn {
                                background: none;
                                border: none;
                                padding: 12px 20px;
                                font-size: 14.5px;
                                font-weight: 600;
                                color: #4b5563;
                                border-bottom: 3px solid transparent;
                                cursor: pointer;
                                transition: all 0.2s;
                                display: flex;
                                align-items: center;
                                gap: 8px;
                                border-radius: 6px 6px 0 0;
                            }
                            .cz-tab-btn:hover {
                                color: var(--cz-primary);
                                background-color: rgba(30, 58, 36, 0.04);
                            }
                            .cz-tab-btn.active {
                                color: var(--cz-primary) !important;
                                border-bottom-color: var(--cz-primary) !important;
                                background-color: rgba(30, 58, 36, 0.08);
                            }
                            div.cz-tab-pane {
                                display: none;
                                animation: tabFadeIn 0.3s ease;
                            }
                            div.cz-tab-pane.active {
                                display: block !important;
                            }
                            @keyframes tabFadeIn {
                                from { opacity: 0; transform: translateY(4px); }
                                to { opacity: 1; transform: translateY(0); }
                            }
                            .pricing-suggested-card-tab {
                                background: #f0fdf4;
                                border: 1px solid #bbf7d0;
                                border-radius: 8px;
                                padding: 16px;
                                display: flex;
                                flex-direction: column;
                                justify-content: center;
                            }
                        </style>

                        <!-- Navigation Tabs -->
                        <div class="cz-tabs">
                            <button type="button" class="cz-tab-btn active" data-tab="basic" onclick="switchTab('basic')">
                                <i class="fa-solid fa-circle-info me-1"></i> Thông Tin Cơ Bản
                            </button>
                            <button type="button" class="cz-tab-btn" data-tab="bom" onclick="switchTab('bom')">
                                <i class="fa-solid fa-calculator me-1"></i> Định Lượng & BOM
                            </button>
                            <button type="button" class="cz-tab-btn" data-tab="recipe" onclick="switchTab('recipe')">
                                <i class="fa-solid fa-kitchen-set me-1"></i> Quy Trình Hướng Dẫn
                            </button>
                        </div>

                        <!-- Tab 1: Basic Info -->
                        <div id="tab-basic" class="cz-tab-pane active">
                            <!-- Product Information Card -->
                            <div class="detail-card">
                                <h5 class="card-header-title">Thông Tin Bánh Kem</h5>
                                
                                <div class="row g-3">
                                     <div class="col-md-12">
                                         <label class="form-label-cz">Tên Bánh Kem <span>*</span></label>
                                         <input type="text" class="form-control-cz" id="productName" name="name" value="${product.name}" required>
                                         <div id="error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
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
                                         <label class="form-label-cz">Thời Gian Làm Việc Ước Tính (giờ) <span>*</span></label>
                                         <input type="number" step="0.01" class="form-control-cz" id="productEstimatedLaborHours" name="estimatedLaborHours" value="${product.estimatedLaborHours}" required>
                                         <div id="error-estimatedLaborHours" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                     </div>

                                     <div class="col-md-12">
                                         <label class="form-label-cz">Cho Phép Ghi Chú</label>
                                         <div class="switch-container">
                                             <span class="switch-label-text">Cho phép khách ghi chú chúc mừng lên mặt bánh</span>
                                             <input type="checkbox" class="switch-input" name="allowsGreeting" value="true" ${product.allowsGreeting ? 'checked' : ''}>
                                         </div>
                                         <input type="hidden" name="status" value="${not empty product.status ? product.status : 'Active'}">
                                     </div>

                                    <div class="col-md-12">
                                        <label class="form-label-cz" style="display: block; margin-bottom: 8px;">Mô Tả Chi Tiết</label>
                                        <div id="editor-container" style="height: 200px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff;">
                                            ${product.fullDescription}
                                        </div>
                                        <input type="hidden" name="fullDescription" id="fullDescription">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tab 2: BOM Settings -->
                        <div id="tab-bom" class="cz-tab-pane">
                            <!-- BOM Ingredients Table Card -->
                            <div class="detail-card">
                                <h5 class="card-header-title">Định Lượng Nguyên Liệu (BOM)</h5>
                                <p class="card-header-desc" style="font-size: 13px; color: #6b7280; margin-bottom: 15px;">Quản lý các nguyên liệu sử dụng để sản xuất bánh kem này. Hệ thống sẽ tự động cập nhật giá thành.</p>
                                
                                <!-- Template for JS options -->
                                <template id="bom-options-template">
                                    <c:forEach var="ing" items="${allIngredients}">
                                        <option value="${ing.ingredientId}" data-price="${ing.pricePerUnit}" data-unit="${ing.unitName}">${fn:escapeXml(ing.ingredientName)} (đ/${ing.unitName})</option>
                                    </c:forEach>
                                </template>

                                <div class="table-responsive">
                                    <table class="table align-middle" id="bomTable" style="border-color: #f3f4f6;">
                                        <thead>
                                            <tr style="border-bottom: 2px solid #e5e7eb;">
                                                <th style="font-size: 13px; font-weight: 700; color: #374151; padding-bottom: 12px; min-width: 220px;">Nguyên Liệu</th>
                                                <th style="font-size: 13px; font-weight: 700; color: #374151; width: 140px; padding-bottom: 12px;">Số Lượng</th>
                                                <th style="font-size: 13px; font-weight: 700; color: #374151; width: 130px; padding-bottom: 12px; white-space: nowrap;">Đơn Giá</th>
                                                <th style="font-size: 13px; font-weight: 700; color: #374151; width: 130px; padding-bottom: 12px; white-space: nowrap;">Thành Tiền</th>
                                                <th style="font-size: 13px; font-weight: 700; color: #374151; width: 50px; padding-bottom: 12px; text-align: center;">Xóa</th>
                                            </tr>
                                        </thead>
                                        <tbody id="bomTableBody">
                                            <c:forEach var="item" items="${productIngredients}">
                                                <tr data-price="${item.pricePerUnit}">
                                                    <td>
                                                        <select class="form-select-cz bom-select" name="bomIngredientId" onchange="updateBomRowPrice(this)" style="padding: 6px 12px; height: 38px;">
                                                            <c:forEach var="ing" items="${allIngredients}">
                                                                <option value="${ing.ingredientId}" data-price="${ing.pricePerUnit}" data-unit="${ing.unitName}" ${item.ingredientId eq ing.ingredientId ? 'selected' : ''}>
                                                                    ${fn:escapeXml(ing.ingredientName)} (đ/${ing.unitName})
                                                                </option>
                                                            </c:forEach>
                                                        </select>
                                                    </td>
                                                    <td>
                                                        <div class="d-flex align-items-center gap-2">
                                                            <input type="number" step="0.01" class="form-control-cz bom-grams" name="bomStandardGram" value="${item.standardGram}" oninput="recalculateBom()" style="padding: 6px 12px; height: 38px; width: 90px; min-width: 90px;" required>
                                                            <span class="bom-unit-label text-muted small" style="min-width: 45px; text-align: left; font-weight: 500;">${item.unitMeasure}</span>
                                                        </div>
                                                    </td>
                                                    <td class="bom-unit-price" style="font-size: 13px; color: #4b5563; white-space: nowrap;">
                                                        <fmt:formatNumber value="${item.pricePerUnit}" type="number" pattern="#,##0"/> đ/${item.unitMeasure}
                                                    </td>
                                                    <td class="bom-row-total" style="font-weight: 600; font-size: 13.5px; color: #1f2937; white-space: nowrap;">
                                                        <fmt:formatNumber value="${item.standardGram * item.pricePerUnit}" type="number" pattern="#,##0"/> đ
                                                    </td>
                                                    <td style="text-align: center;">
                                                        <button type="button" class="btn-delete-bom-row" onclick="removeBomRow(this)" title="Xóa nguyên liệu">
                                                            <i class="fa-regular fa-trash-can"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mt-3 pt-3" style="border-top: 1px dashed #e5e7eb; margin-bottom: 25px;">
                                    <button type="button" class="btn btn-sm btn-cz-primary" onclick="addBomRow()" style="font-size: 13px; padding: 8px 18px; font-weight: 600;"><i class="fa-solid fa-plus me-1"></i> Thêm Nguyên Liệu</button>
                                    <div>
                                        <span style="color: #4b5563; font-weight: 500;">Tổng chi phí nguyên liệu:</span> 
                                        <span id="bomCostTotal" style="font-size: 18px; font-weight: 700; color: var(--cz-primary); margin-left: 10px;">0 đ</span>
                                    </div>
                                </div>

                                <!-- Financial markup and pricing suggest cards -->
                                <h5 class="card-header-title mt-4" style="border-top: 1px solid #e5e7eb; padding-top: 20px;">Cơ Cấu Giá Bán Đề Xuất</h5>
                                <div class="row g-3 mt-1">
                                                                    <div class="col-md-4">
                                        <label class="form-label-cz">Biên Lợi Nhuận (%) <span>*</span></label>
                                        <div class="input-group-cz">
                                            <input type="number" step="0.01" class="form-control-cz" id="defaultMarginPercent" name="defaultMarginPercent" value="${product.defaultMarginPercent}" readonly style="background-color: #f3f4f6; cursor: not-allowed;" required>
                                            <span class="input-group-addon">%</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label-cz">Phí Dịch Vụ / Bếp (%) <span>*</span></label>
                                        <div class="input-group-cz">
                                            <input type="number" step="0.01" class="form-control-cz" id="defaultServicePercent" name="defaultServicePercent" value="${product.defaultServicePercent}" readonly style="background-color: #f3f4f6; cursor: not-allowed;" required>
                                            <span class="input-group-addon">%</span>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="pricing-suggested-card-tab">
                                            <span class="pricing-title" style="font-size: 11px; font-weight: 600; color: #166534; text-transform: uppercase;">Giá Bán Đề Xuất</span>
                                            <span class="pricing-value" id="productBasePriceText" style="font-size: 22px; font-weight: 700; color: #15803d; margin: 2px 0;">
                                                <fmt:formatNumber value="${product.basePrice}" type="number" pattern="#,##0"/> đ
                                            </span>
                                            <span class="pricing-formula" style="font-size: 10px; color: #166534; opacity: 0.8;">Giá = Chi phí / (1 - Tổng phí %)</span>
                                            <input type="hidden" id="productBasePrice" value="${product.basePrice}">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tab 3: Recipe Steps -->
                        <div id="tab-recipe" class="cz-tab-pane">
                            <!-- Recipe Instructions Card -->
                            <div class="detail-card">
                                <h5 class="card-header-title">Quy Trình & Hướng Dẫn Làm Bếp</h5>
                                <p class="card-header-desc" style="font-size: 13px; color: #6b7280; margin-bottom: 15px;">Nhập chi tiết các bước chế biến dành riêng cho nhân viên bếp sản xuất.</p>
                                
                                <div id="recipe-editor-container" style="height: 300px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff; border-radius: 8px;">
                                    ${product.instructionSteps}
                                </div>
                                <input type="hidden" name="instructionSteps" id="instructionSteps">
                            </div>
                        </div>

                    </div>
                </div>
            </form>

        </div>
    </div>

    <!-- Hidden delete form for POST request -->
    <form id="deleteProductForm" action="${pageContext.request.contextPath}/admin/product?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" id="deleteProductId">
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" crossorigin="anonymous"></script>
    
    <script>
        document.getElementById('imageFileInput').addEventListener('change', function(event) {
            const file = event.target.files[0];
            const errorDiv = document.getElementById('imageError');
            const preview = document.getElementById('mainCoverImage');
            
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
            
            if (file) {
                // Validate size (5MB = 5 * 1024 * 1024)
                if (file.size > 5 * 1024 * 1024) {
                    errorDiv.textContent = 'Dung lượng ảnh vượt quá giới hạn cho phép (tối đa 5MB).';
                    errorDiv.style.display = 'block';
                    event.target.value = ''; // Reset file input
                    return;
                }
                
                // Validate extension
                const allowedExtensions = /(\.jpg|\.jpeg|\.png)$/i;
                if (!allowedExtensions.exec(file.name)) {
                    errorDiv.textContent = 'Định dạng tệp không hợp lệ. Chỉ chấp nhận các đuôi .jpg, .jpeg, .png.';
                    errorDiv.style.display = 'block';
                    event.target.value = ''; // Reset file input
                    return;
                }
                
                // Show preview
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });

        let additionalFilesList = [];

        function updateHiddenInput() {
            const dt = new DataTransfer();
            additionalFilesList.forEach(item => {
                dt.items.add(item.file);
            });
            const hiddenInput = document.getElementById('additionalImageFilesHidden');
            if (hiddenInput) {
                hiddenInput.files = dt.files;
            }
        }

        document.getElementById('additionalImageFilesInput').addEventListener('change', function(event) {
            const files = event.target.files;
            const errorDiv = document.getElementById('additionalImagesError');
            const container = document.getElementById('additionalImagesContainer');
            const uploadTrigger = container.querySelector('.upload-trigger-card');
            
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
            
            if (files.length === 0) return;
            
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                // Validate size (5MB = 5 * 1024 * 1024)
                if (file.size > 5 * 1024 * 1024) {
                    errorDiv.textContent = 'Dung lượng tệp "' + file.name + '" vượt quá giới hạn cho phép (tối đa 5MB).';
                    errorDiv.style.display = 'block';
                    event.target.value = '';
                    return;
                }
                
                // Validate extension
                const allowedExtensions = /(\.jpg|\.jpeg|\.png)$/i;
                if (!allowedExtensions.exec(file.name)) {
                    errorDiv.textContent = 'Định dạng tệp "' + file.name + '" không hợp lệ. Chỉ chấp nhận các đuôi .jpg, .jpeg, .png.';
                    errorDiv.style.display = 'block';
                    event.target.value = '';
                    return;
                }
            }
            
            // Limit additional images (max 8)
            const existingCount = container.querySelectorAll('.gallery-item-wrapper').length;
            if (existingCount + files.length > 8) {
                errorDiv.textContent = 'Bạn chỉ được tải lên tối đa 8 ảnh chi tiết khác.';
                errorDiv.style.display = 'block';
                event.target.value = '';
                return;
            }
            
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                const uniqueId = 'add_img_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
                
                // Track in our global list
                additionalFilesList.push({ id: uniqueId, file: file });
                
                // Read and show preview in the grid
                const reader = new FileReader();
                reader.onload = function(e) {
                    const itemWrapper = document.createElement('div');
                    itemWrapper.className = 'gallery-item-wrapper';
                    itemWrapper.title = 'Nhấp để xem ảnh lớn hơn';
                    
                    const img = document.createElement('img');
                    img.src = e.target.result;
                    img.onclick = function() { openLightbox(this.src); };
                    img.onerror = function() { this.src = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587'; };
                    
                    const deleteBtn = document.createElement('button');
                    deleteBtn.type = 'button';
                    deleteBtn.className = 'delete-gallery-btn';
                    deleteBtn.title = 'Xóa ảnh này';
                    deleteBtn.innerHTML = '<i class="fa-solid fa-xmark"></i>';
                    deleteBtn.onclick = function(ev) {
                        ev.stopPropagation();
                        itemWrapper.remove();
                        // Remove from tracking list and update hidden input
                        additionalFilesList = additionalFilesList.filter(item => item.id !== uniqueId);
                        updateHiddenInput();
                    };
                    
                    itemWrapper.appendChild(img);
                    itemWrapper.appendChild(deleteBtn);
                    
                    // Insert before the upload trigger card
                    container.insertBefore(itemWrapper, uploadTrigger);
                };
                reader.readAsDataURL(file);
            }
            
            // Update hidden input after adding all files
            updateHiddenInput();
            
            // Clear value of the trigger file input so it can trigger change again
            event.target.value = '';
        });

        function resetCoverImage() {
            document.getElementById('imageFileInput').value = '';
            document.getElementById('imageUrlHidden').value = '';
            document.getElementById('mainCoverImage').src = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587';
        }
    </script>
    
    <!-- Quill Library -->
    <script src="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.js" crossorigin="anonymous"></script>
    <script>
        let quill;
        let recipeQuill;

        // Custom Tab Switching function
        function switchTab(tabId) {
            console.log("switchTab called for tab:", tabId);
            try {
                document.querySelectorAll('.cz-tab-btn').forEach(btn => btn.classList.remove('active'));
                document.querySelectorAll('.cz-tab-pane').forEach(pane => pane.classList.remove('active'));
                
                const activeBtn = document.querySelector('.cz-tab-btn[data-tab="' + tabId + '"]');
                const activePane = document.getElementById('tab-' + tabId);
                
                console.log("switchTab targets: btn=", activeBtn, "pane=", activePane);
                
                if (activeBtn && activePane) {
                    activeBtn.classList.add('active');
                    activePane.classList.add('active');
                    console.log("switchTab successfully activated tab:", tabId);
                    
                    // Refresh Quill editor inside recipe if visible
                    if (tabId === 'recipe' && recipeQuill) {
                        recipeQuill.update();
                    }
                } else {
                    console.error("switchTab failed: activeBtn or activePane is null for tabId:", tabId);
                }
            } catch (err) {
                console.error("Exception in switchTab:", err);
                alert("Lỗi khi chuyển tab: " + err.message);
            }
        }

        // Sync Quill HTML contents on form submit
        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            let hasError = false;
            
            const errorName = document.getElementById('error-name');
            const errorLabor = document.getElementById('error-estimatedLaborHours');
            
            if (errorName) errorName.style.display = 'none';
            if (errorLabor) errorLabor.style.display = 'none';
            
            const nameInput = document.getElementById('productName');
            const laborInput = document.getElementById('productEstimatedLaborHours');
            const marginInput = document.getElementById('defaultMarginPercent');
            const serviceInput = document.getElementById('defaultServicePercent');
            
            if (nameInput) nameInput.classList.remove('is-invalid');
            if (laborInput) laborInput.classList.remove('is-invalid');
            if (marginInput) marginInput.classList.remove('is-invalid');
            if (serviceInput) serviceInput.classList.remove('is-invalid');

            // 1. Validate name
            if (nameInput) {
                const nameVal = nameInput.value.trim();
                if (nameVal.length === 0) {
                    if (errorName) {
                        errorName.textContent = 'Tên bánh kem không được để trống hoặc chỉ chứa khoảng trắng.';
                        errorName.style.display = 'block';
                    }
                    nameInput.classList.add('is-invalid');
                    hasError = true;
                } else if (nameVal.length < 3) {
                    if (errorName) {
                        errorName.textContent = 'Tên bánh kem phải có tối thiểu 3 ký tự (không tính khoảng trắng).';
                        errorName.style.display = 'block';
                    }
                    nameInput.classList.add('is-invalid');
                    hasError = true;
                } else if (nameVal.length > 100) {
                    if (errorName) {
                        errorName.textContent = 'Tên bánh kem không được vượt quá 100 ký tự.';
                        errorName.style.display = 'block';
                    }
                    nameInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            // 2. Validate estimated labor hours
            if (laborInput) {
                const laborVal = parseFloat(laborInput.value);
                if (isNaN(laborVal) || laborVal < 0) {
                    if (errorLabor) {
                        errorLabor.textContent = 'Thời gian làm việc phải lớn hơn hoặc bằng 0.';
                        errorLabor.style.display = 'block';
                    }
                    laborInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            // 3. Validate financial percents
            if (marginInput && serviceInput) {
                const marginVal = parseFloat(marginInput.value);
                const serviceVal = parseFloat(serviceInput.value);
                if (isNaN(marginVal) || marginVal < 0 || marginVal >= 100) {
                    marginInput.classList.add('is-invalid');
                    hasError = true;
                }
                if (isNaN(serviceVal) || serviceVal < 0 || serviceVal >= 100) {
                    serviceInput.classList.add('is-invalid');
                    hasError = true;
                }
                if (!hasError && (marginVal + serviceVal >= 100)) {
                    marginInput.classList.add('is-invalid');
                    serviceInput.classList.add('is-invalid');
                    alert('Tổng tỷ lệ Biên lợi và Phí dịch vụ phải nhỏ hơn 100%.');
                    hasError = true;
                }
            }

            if (hasError) {
                e.preventDefault();
                return false;
            }

            // 4. Warning confirmation if no ingredients (BOM) are configured
            const bomRowsCount = document.querySelectorAll('#bomTableBody tr').length;
            if (bomRowsCount === 0) {
                const confirmSave = confirm('Sản phẩm này chưa được thiết lập định lượng nguyên liệu. Bạn có muốn tiếp tục lưu không?');
                if (!confirmSave) {
                    e.preventDefault();
                    return false;
                }
            }

            // Sync editors
            if (quill) {
                document.getElementById('fullDescription').value = quill.root.innerHTML;
            }
            if (recipeQuill) {
                document.getElementById('instructionSteps').value = recipeQuill.root.innerHTML;
            }
        });

        // BOM Dynamism
        function recalculateBom() {
            console.log("recalculateBom starting...");
            try {
                let totalCost = 0.0;
                const rows = document.querySelectorAll('#bomTableBody tr');
                console.log("recalculateBom: found BOM table rows:", rows.length);
                
                rows.forEach((row, index) => {
                    const select = row.querySelector('.bom-select');
                    const gramsInput = row.querySelector('.bom-grams');
                    
                    if (select && gramsInput) {
                        const option = select.options[select.selectedIndex];
                        const price = option ? (parseFloat(option.getAttribute('data-price')) || 0.0) : 0.0;
                        const unit = option ? (option.getAttribute('data-unit') || '') : '';
                        const grams = parseFloat(gramsInput.value) || 0.0;
                        
                        const rowTotal = price * grams;
                        totalCost += rowTotal;
                        
                        const unitPriceEl = row.querySelector('.bom-unit-price');
                        const rowTotalEl = row.querySelector('.bom-row-total');
                        const unitLabel = row.querySelector('.bom-unit-label');
                        if (unitPriceEl) {
                            unitPriceEl.textContent = Math.round(price).toLocaleString('vi-VN') + ' đ/' + unit;
                        }
                        if (rowTotalEl) {
                            rowTotalEl.textContent = Math.round(rowTotal).toLocaleString('vi-VN') + ' đ';
                        }
                        if (unitLabel) {
                            unitLabel.textContent = unit;
                        }
                    }
                });
                
                const bomCostTotalEl = document.getElementById('bomCostTotal');
                if (bomCostTotalEl) {
                    bomCostTotalEl.textContent = Math.round(totalCost).toLocaleString('vi-VN') + ' đ';
                }
                
                // Recalculate Proposed Base Price
                const marginInput = document.getElementById('defaultMarginPercent');
                const serviceInput = document.getElementById('defaultServicePercent');
                const priceInput = document.getElementById('productBasePrice');
                
                console.log("recalculateBom financials: marginInput=", marginInput, "serviceInput=", serviceInput, "priceInput=", priceInput);
                
                if (marginInput && serviceInput && priceInput) {
                    const margin = parseFloat(marginInput.value) || 0.0;
                    const service = parseFloat(serviceInput.value) || 0.0;
                    
                    const divisor = 1.0 - ((margin + service) / 100.0);
                    let proposedPrice = 0.0;
                    if (divisor > 0.0) {
                        proposedPrice = totalCost / divisor;
                    } else {
                        proposedPrice = totalCost;
                    }
                    
                    const formatted = Math.round(proposedPrice).toLocaleString('vi-VN') + ' đ';
                    priceInput.value = Math.round(proposedPrice);
                    const textEl = document.getElementById('productBasePriceText');
                    if (textEl) {
                        textEl.textContent = formatted;
                    }
                }
                console.log("recalculateBom finished. totalCost:", totalCost);
            } catch (err) {
                console.error("Exception in recalculateBom:", err);
                alert("Lỗi khi tính toán định lượng: " + err.message);
            }
        }

        function updateBomRowPrice(select) {
            const selectedVal = select.value;
            const currentGramInput = select.closest('tr').querySelector('.bom-grams');
            const currentGram = parseFloat(currentGramInput.value) || 0;
            
            // Check if there is another row with the same ingredient selected
            let duplicateRowFound = false;
            const rows = document.querySelectorAll('#bomTableBody tr');
            rows.forEach(row => {
                const rowSelect = row.querySelector('.bom-select');
                if (rowSelect && rowSelect !== select && rowSelect.value === selectedVal) {
                    // Merge quantities
                    const existingGramInput = row.querySelector('.bom-grams');
                    if (existingGramInput) {
                        const existingGram = parseFloat(existingGramInput.value) || 0;
                        existingGramInput.value = (existingGram + currentGram).toFixed(2);
                        duplicateRowFound = true;
                    }
                }
            });
            
            if (duplicateRowFound) {
                // Remove this duplicate row
                select.closest('tr').remove();
            }
            recalculateBom();
        }

        function removeBomRow(btn) {
            btn.closest('tr').remove();
            recalculateBom();
        }

        function addBomRow(targetId = "", defaultQty = 100) {
            try {
                const tbody = document.getElementById('bomTableBody');
                const templateEl = document.getElementById('bom-options-template');
                if (!templateEl) return;
                
                // Find already selected IDs
                const selectedIds = Array.from(document.querySelectorAll('#bomTableBody .bom-select')).map(s => s.value);
                
                // Create a temporary div to parse options
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = templateEl.innerHTML;
                const options = tempDiv.querySelectorAll('option');
                
                // Find first option that is not selected if no targetId is specified
                let targetValue = targetId;
                if (targetValue === "") {
                    for (let opt of options) {
                        if (!selectedIds.includes(opt.value)) {
                            targetValue = opt.value;
                            break;
                        }
                    }
                }
                
                // If all are selected, just default to first
                if (targetValue === "" && options.length > 0) {
                    targetValue = options[0].value;
                }
                
                // Prevent duplicate addition
                if (selectedIds.includes(targetValue) && targetId !== "") {
                    return;
                }
                
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>
                        <select class="form-select-cz bom-select" name="bomIngredientId" onchange="updateBomRowPrice(this)" style="padding: 5px 10px; height: 38px;">
                            ` + templateEl.innerHTML + `
                        </select>
                    </td>
                    <td>
                        <div class="d-flex align-items-center gap-2">
                            <input type="number" step="0.01" class="form-control-cz bom-grams" name="bomStandardGram" value="${defaultQty}" oninput="recalculateBom()" style="padding: 5px 10px; height: 38px; width: 90px; min-width: 90px;" required>
                            <span class="bom-unit-label text-muted small" style="min-width: 45px; text-align: left; font-weight: 500;"></span>
                        </div>
                    </td>
                    <td class="bom-unit-price" style="font-size: 13px; color: #4b5563; white-space: nowrap;">0 đ</td>
                    <td class="bom-row-total" style="font-weight: 600; font-size: 13.5px; color: #1f2937; white-space: nowrap;">0 đ</td>
                    <td style="text-align: center;">
                        <button type="button" class="btn-delete-bom-row" onclick="removeBomRow(this)" title="Xóa nguyên liệu này">
                            <i class="fa-regular fa-trash-can"></i>
                        </button>
                    </td>
                `;
                
                const selectEl = tr.querySelector('.bom-select');
                if (selectEl && targetValue !== "") {
                    selectEl.value = targetValue;
                }
                
                tbody.appendChild(tr);
                recalculateBom();
            } catch (err) {
                console.error("Exception in addBomRow:", err);
            }
        }
        
        window.addEventListener('load', () => {
            console.log("Window load listener started");
            try {
                // Initialize Quill editor for description
                const editorEl = document.getElementById('editor-container');
                if (editorEl) {
                    quill = new Quill(editorEl, {
                        theme: 'snow',
                        placeholder: 'Nhập mô tả chi tiết bánh kem...',
                        modules: {
                            toolbar: [
                                ['bold', 'italic', 'underline', 'strike'],
                                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                                [{ 'align': [] }],
                                ['link', 'image'],
                                ['clean']
                            ]
                        }
                    });
                }

                // Initialize Quill editor for recipe instructions
                const recipeEditorEl = document.getElementById('recipe-editor-container');
                if (recipeEditorEl) {
                    recipeQuill = new Quill(recipeEditorEl, {
                        theme: 'snow',
                        placeholder: 'Nhập các bước thực hiện chế biến cụ thể...',
                        modules: {
                            toolbar: [
                                ['bold', 'italic', 'underline', 'strike'],
                                [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                                [{ 'align': [] }],
                                ['link', 'image'],
                                ['clean']
                            ]
                        }
                    });
                }

                // Prepopulate common ingredients for new products
                const isNew = document.querySelector('input[name="id"]')?.value === 'new';
                const bomRowsCount = document.querySelectorAll('#bomTableBody tr').length;
                if (isNew && bomRowsCount === 0) {
                    const templateEl = document.getElementById('bom-options-template');
                    if (templateEl) {
                        const tempDiv = document.createElement('div');
                        tempDiv.innerHTML = templateEl.innerHTML;
                        const options = tempDiv.querySelectorAll('option');
                        const commonKeywords = ['bột', 'đường', 'bơ', 'sữa', 'trứng'];
                        
                        options.forEach(opt => {
                            const nameLower = opt.textContent.toLowerCase();
                            const isCommon = commonKeywords.some(keyword => nameLower.includes(keyword));
                            if (isCommon) {
                                addBomRow(opt.value, 100);
                            }
                        });
                    }
                }

                // Format existing ingredient quantities to remove trailing .0
                document.querySelectorAll('.bom-grams').forEach(input => {
                    const val = parseFloat(input.value);
                    if (!isNaN(val)) {
                        input.value = parseFloat(val.toFixed(2));
                    }
                });

                recalculateBom();
                
                const marginEl = document.getElementById('defaultMarginPercent');
                const serviceEl = document.getElementById('defaultServicePercent');
                if (marginEl) marginEl.addEventListener('input', recalculateBom);
                if (serviceEl) serviceEl.addEventListener('input', recalculateBom);
                
                // Programmatically switch to basic tab on load to ensure classes are synced
                switchTab('basic');
                console.log("Window load listener completed successfully");
            } catch (err) {
                console.error("Exception in window load:", err);
                alert("Lỗi tải trang: " + err.message);
            }
        });
    </script>
    
    <!-- Lightbox Modal for viewing large images -->
    <div id="imageLightbox" class="lightbox-modal" onclick="closeLightbox()">
        <span class="lightbox-close" onclick="closeLightbox()">&times;</span>
        <img class="lightbox-content" id="lightboxImg">
    </div>

    <script>
        function deleteProduct(id) {
            document.getElementById('deleteProductId').value = id;
            document.getElementById('deleteProductForm').submit();
        }
        function openLightbox(src) {
            const lightbox = document.getElementById('imageLightbox');
            const lightboxImg = document.getElementById('lightboxImg');
            lightboxImg.src = src;
            lightbox.classList.add('show');
        }
        function closeLightbox() {
            const lightbox = document.getElementById('imageLightbox');
            document.getElementById('lightboxImg').src = '';
            lightbox.classList.remove('show');
        }
    </script>
</body>
</html>
