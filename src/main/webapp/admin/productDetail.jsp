<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Product Detail</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Quill Rich Text Editor CSS -->
    <link href="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.snow.css" rel="stylesheet">
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductDetail.css?v=1.4">
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
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="#">Bảng điều khiển</a>
                    <span>&gt;</span>
                    <a href="#">Sản phẩm</a>
                    <span>&gt;</span>
                    <a href="${pageContext.request.contextPath}/admin/product?action=list">Danh sách bánh kem</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Chi tiết bánh kem</a>
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
            
            <form action="${pageContext.request.contextPath}/admin/product?action=${formAction}" method="post" enctype="multipart/form-data">
                <!-- Keep track of the product ID -->
                <input type="hidden" name="id" value="${product.id}">
                <input type="hidden" name="productType" value="${product.productType}">

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

                                 <div class="col-md-4">
                                     <label class="form-label-cz">Biên Lợi Nhuận (%) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" id="defaultMarginPercent" name="defaultMarginPercent" value="${product.defaultMarginPercent}" required>
                                 </div>
                                 <div class="col-md-4">
                                     <label class="form-label-cz">Phí Dịch Vụ / Bếp (%) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" id="defaultServicePercent" name="defaultServicePercent" value="${product.defaultServicePercent}" required>
                                 </div>
                                 <div class="col-md-4">
                                     <label class="form-label-cz">Giá Bán Đề Xuất (VND)</label>
                                     <input type="text" class="form-control-cz" id="productBasePrice" value="${product.basePrice}" readonly style="background-color: #f5f5f5; font-weight: bold; color: var(--cz-primary);">
                                     <span class="small text-muted">Giá đề xuất = Chi phí NL / (1 - (Lãi + Dịch vụ)/100)</span>
                                 </div>

                                 <div class="col-md-12">
                                     <label class="form-label-cz">Cho Phép Ghi Chữ</label>
                                     <div class="switch-container">
                                         <span class="switch-label-text">Cho phép khách ghi chữ chúc mừng lên mặt bánh</span>
                                         <input type="checkbox" class="switch-input" name="allowsGreeting" value="true" ${product.allowsGreeting ? 'checked' : ''}>
                                     </div>
                                 </div>

                                 <div class="col-md-12">
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

                                <div class="col-md-12">
                                    <label class="form-label-cz" style="display: block; margin-bottom: 8px;">Mô Tả Chi Tiết</label>
                                    <div id="editor-container" style="height: 200px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff;">
                                        ${product.fullDescription}
                                    </div>
                                    <input type="hidden" name="fullDescription" id="fullDescription">
                                </div>
                            </div>
                        </div>

                        <!-- Quick Links / Detailed Settings Card -->
                        <div class="detail-card mt-4">
                            <h5 class="card-header-title">Thiết Lập Quy Trình & Nguyên Liệu</h5>
                            <p class="card-header-desc">Cấu hình định lượng nguyên liệu sản xuất bánh kem và ghi chú hướng dẫn thợ làm bếp thực hiện.</p>
                            <div class="d-flex flex-wrap gap-3">
                                <button type="button" class="btn btn-cz-primary flex-grow-1" data-bs-toggle="modal" data-bs-target="#bomModal" style="padding: 12px 20px; font-weight: 600;">
                                    <i class="fa-solid fa-calculator me-2"></i> Định Lượng Nguyên Liệu & BOM
                                </button>
                                <button type="button" class="btn btn-outline-secondary flex-grow-1" data-bs-toggle="modal" data-bs-target="#recipeModal" style="padding: 12px 20px; font-weight: 600;">
                                    <i class="fa-solid fa-kitchen-set me-2"></i> Quy Trình & Hướng Dẫn Làm Bếp
                                </button>
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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
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
                    errorDiv.textContent = `Dung lượng tệp "${file.name}" vượt quá giới hạn cho phép (tối đa 5MB).`;
                    errorDiv.style.display = 'block';
                    event.target.value = '';
                    return;
                }
                
                // Validate extension
                const allowedExtensions = /(\.jpg|\.jpeg|\.png)$/i;
                if (!allowedExtensions.exec(file.name)) {
                    errorDiv.textContent = `Định dạng tệp "${file.name}" không hợp lệ. Chỉ chấp nhận các đuôi .jpg, .jpeg, .png.`;
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
    <script src="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.js"></script>
    <script>
        let quill;
        let recipeQuill;

        // Sync Quill HTML contents on form submit
        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            let hasError = false;
            
            const errorName = document.getElementById('error-name');
            const errorLabor = document.getElementById('error-estimatedLaborHours');
            
            errorName.style.display = 'none';
            errorLabor.style.display = 'none';
            
            const nameInput = document.getElementById('productName');
            const laborInput = document.getElementById('productEstimatedLaborHours');
            const marginInput = document.getElementById('defaultMarginPercent');
            const serviceInput = document.getElementById('defaultServicePercent');
            
            nameInput.classList.remove('is-invalid');
            laborInput.classList.remove('is-invalid');
            marginInput.classList.remove('is-invalid');
            serviceInput.classList.remove('is-invalid');

            // 1. Validate name
            const nameVal = nameInput.value.trim();
            if (nameVal.length === 0) {
                errorName.textContent = 'Tên bánh kem không được để trống.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            }

            // 2. Validate estimated labor hours
            const laborVal = parseFloat(laborInput.value);
            if (isNaN(laborVal) || laborVal < 0) {
                errorLabor.textContent = 'Thời gian làm việc phải lớn hơn hoặc bằng 0.';
                errorLabor.style.display = 'block';
                laborInput.classList.add('is-invalid');
                hasError = true;
            }

            // 3. Validate financial percents
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
                alert('Tổng tỷ lệ Biên lãi và Phí dịch vụ phải nhỏ hơn 100%.');
                hasError = true;
            }

            if (hasError) {
                e.preventDefault();
                return false;
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
            let totalCost = 0.0;
            const rows = document.querySelectorAll('#bomTableBody tr');
            
            rows.forEach(row => {
                const select = row.querySelector('.bom-select');
                const gramsInput = row.querySelector('.bom-grams');
                
                if (select && gramsInput) {
                    const option = select.options[select.selectedIndex];
                    const price = option ? (parseFloat(option.getAttribute('data-price')) || 0.0) : 0.0;
                    const grams = parseFloat(gramsInput.value) || 0.0;
                    
                    const rowTotal = price * grams;
                    totalCost += rowTotal;
                    
                    row.querySelector('.bom-unit-price').textContent = price.toLocaleString('vi-VN', {minimumFractionDigits: 2}) + ' đ';
                    row.querySelector('.bom-row-total').textContent = rowTotal.toLocaleString('vi-VN', {minimumFractionDigits: 2}) + ' đ';
                }
            });
            
            document.getElementById('bomCostTotal').textContent = totalCost.toLocaleString('vi-VN') + ' đ';
            
            // Recalculate Proposed Base Price
            const marginInput = document.getElementById('defaultMarginPercent');
            const serviceInput = document.getElementById('defaultServicePercent');
            const priceInput = document.getElementById('productBasePrice');
            
            const margin = parseFloat(marginInput.value) || 0.0;
            const service = parseFloat(serviceInput.value) || 0.0;
            
            const divisor = 1.0 - ((margin + service) / 100.0);
            let proposedPrice = 0.0;
            if (divisor > 0.0) {
                proposedPrice = totalCost / divisor;
            } else {
                proposedPrice = totalCost;
            }
            
            priceInput.value = Math.round(proposedPrice).toLocaleString('vi-VN') + ' đ';
        }

        function updateBomRowPrice(select) {
            recalculateBom();
        }

        function removeBomRow(btn) {
            btn.closest('tr').remove();
            recalculateBom();
        }

        function addBomRow() {
            const tbody = document.getElementById('bomTableBody');
            const tr = document.createElement('tr');
            
            let optionsHtml = '';
            <c:forEach var="ing" items="${allIngredients}">
                optionsHtml += '<option value="${ing.ingredientId}" data-price="${ing.pricePerUnit}">${ing.ingredientName} (${ing.pricePerUnit}đ/g)</option>';
            </c:forEach>
            
            tr.innerHTML = `
                <td>
                    <select class="form-select-cz bom-select" name="bomIngredientId" onchange="updateBomRowPrice(this)" style="padding: 5px 10px; height: 38px;">
                        ` + optionsHtml + `
                    </select>
                </td>
                <td>
                    <input type="number" step="0.01" class="form-control-cz bom-grams" name="bomStandardGram" value="100" oninput="recalculateBom()" style="padding: 5px 10px; height: 38px;" required>
                </td>
                <td class="bom-unit-price">0.00 đ</td>
                <td class="bom-row-total" style="font-weight: 600;">0.00 đ</td>
                <td>
                    <button type="button" class="btn-action-delete" onclick="removeBomRow(this)" style="width: 32px; height: 32px;">
                        <i class="fa-regular fa-trash-can"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(tr);
            recalculateBom();
        }
        
        window.addEventListener('load', () => {
            // Initialize Quill editor for description
            quill = new Quill('#editor-container', {
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

            // Initialize Quill editor for recipe instructions
            recipeQuill = new Quill('#recipe-editor-container', {
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

            recalculateBom();
            
            const marginEl = document.getElementById('defaultMarginPercent');
            const serviceEl = document.getElementById('defaultServicePercent');
            if (marginEl) marginEl.addEventListener('input', recalculateBom);
            if (serviceEl) serviceEl.addEventListener('input', recalculateBom);
        });
    </script>
    
    <!-- Hidden delete form for POST request -->
    <form id="deleteProductForm" action="${pageContext.request.contextPath}/admin/product?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" id="deleteProductId">
    </form>
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

        // Trigger updates when modals show to handle Quill resize properly
        document.getElementById('recipeModal').addEventListener('shown.bs.modal', function () {
            if (recipeQuill) {
                recipeQuill.update();
                recipeQuill.focus();
            }
        });
    </script>

    <!-- Modal Định Lượng Nguyên Liệu & Giá Thành (BOM) -->
    <div class="modal fade" id="bomModal" tabindex="-1" aria-labelledby="bomModalLabel" aria-hidden="true" style="font-family: 'Be Vietnam Pro', sans-serif;">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background-color: #f97316; color: white; padding: 18px 24px;">
                    <h5 class="modal-title" id="bomModalLabel" style="font-weight: 700;"><i class="fa-solid fa-calculator me-2"></i> Định Lượng Nguyên Liệu (BOM)</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <p class="text-muted" style="font-size: 13.5px; margin-bottom: 20px;">Quản lý các nguyên liệu sử dụng để sản xuất bánh kem và tự động cập nhật giá thành.</p>
                    
                    <div class="table-responsive">
                        <table class="table align-middle" id="bomTable" style="border-color: #f3f4f6;">
                            <thead>
                                <tr style="border-bottom: 2px solid #e5e7eb;">
                                    <th style="font-size: 13px; font-weight: 700; color: #374151; padding-bottom: 12px;">Nguyên Liệu</th>
                                    <th style="font-size: 13px; font-weight: 700; color: #374151; width: 180px; padding-bottom: 12px;">Số Lượng (g)</th>
                                    <th style="font-size: 13px; font-weight: 700; color: #374151; width: 120px; padding-bottom: 12px;">Đơn Giá</th>
                                    <th style="font-size: 13px; font-weight: 700; color: #374151; width: 150px; padding-bottom: 12px;">Thành Tiền</th>
                                    <th style="font-size: 13px; font-weight: 700; color: #374151; width: 80px; padding-bottom: 12px; text-align: center;">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="bomTableBody">
                                <c:forEach var="item" items="${productIngredients}">
                                    <tr data-price="${item.pricePerUnit}">
                                        <td>
                                            <select class="form-select-cz bom-select" name="bomIngredientId" onchange="updateBomRowPrice(this)" style="padding: 6px 12px; height: 38px;">
                                                <c:forEach var="ing" items="${allIngredients}">
                                                    <option value="${ing.ingredientId}" data-price="${ing.pricePerUnit}" ${item.ingredientId eq ing.ingredientId ? 'selected' : ''}>
                                                        ${ing.ingredientName} (đ/g)
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </td>
                                        <td>
                                            <input type="number" step="0.01" class="form-control-cz bom-grams" name="bomStandardGram" value="${item.standardGram}" oninput="recalculateBom()" style="padding: 6px 12px; height: 38px;" required>
                                        </td>
                                        <td class="bom-unit-price" style="font-size: 13.5px; color: #4b5563;">
                                            <fmt:formatNumber value="${item.pricePerUnit}" type="number" pattern="#,##0.00"/> đ
                                        </td>
                                        <td class="bom-row-total" style="font-weight: 600; font-size: 14px; color: #1f2937;">
                                            <fmt:formatNumber value="${item.standardGram * item.pricePerUnit}" type="number" pattern="#,##0.00"/> đ
                                        </td>
                                        <td style="text-align: center;">
                                            <button type="button" class="btn-action-delete" onclick="removeBomRow(this)" style="width: 34px; height: 34px; border-radius: 6px;">
                                                <i class="fa-regular fa-trash-can"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3 pt-3" style="border-top: 1px dashed #e5e7eb;">
                        <button type="button" class="btn btn-sm btn-cz-primary" onclick="addBomRow()" style="font-size: 13px; padding: 8px 18px; font-weight: 600;"><i class="fa-solid fa-plus me-1"></i> Thêm Nguyên Liệu</button>
                        <div>
                            <span style="color: #4b5563; font-weight: 500;">Tổng chi phí nguyên liệu:</span> 
                            <span id="bomCostTotal" style="font-size: 18px; font-weight: 700; color: var(--cz-primary); margin-left: 10px;">0 đ</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="background-color: #f9fafb; border-top: 1px solid #f3f4f6; padding: 15px 24px;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="font-weight: 600; padding: 8px 20px; border-radius: 6px;">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Hướng Dẫn Làm Bếp / Quy Trình Chế Biến -->
    <div class="modal fade" id="recipeModal" tabindex="-1" aria-labelledby="recipeModalLabel" aria-hidden="true" style="font-family: 'Be Vietnam Pro', sans-serif;">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background-color: #f97316; color: white; padding: 18px 24px;">
                    <h5 class="modal-title" id="recipeModalLabel" style="font-weight: 700;"><i class="fa-solid fa-kitchen-set me-2"></i> Quy Trình & Hướng Dẫn Làm Bếp</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <p class="text-muted" style="font-size: 13.5px; margin-bottom: 20px;">Nhập quy trình, các bước chế biến cụ thể dành cho thợ làm bếp.</p>
                    
                    <div id="recipe-editor-container" style="height: 300px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff; border-radius: 8px;">
                        ${product.instructionSteps}
                    </div>
                    <input type="hidden" name="instructionSteps" id="instructionSteps">
                </div>
                <div class="modal-footer" style="background-color: #f9fafb; border-top: 1px solid #f3f4f6; padding: 15px 24px;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="font-weight: 600; padding: 8px 20px; border-radius: 6px;">Đóng</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
