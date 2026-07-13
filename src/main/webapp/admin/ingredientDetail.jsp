<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Ingredient Detail</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
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
        <jsp:param name="activeMenu" value="ingredients" />
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
                    <a href="${pageContext.request.contextPath}/admin/ingredient?action=list">Danh sách nguyên liệu</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Chi tiết nguyên liệu</a>
                </div>
            </div>
            
            <div class="header-right">
                <div class="profile-section">
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                    <div class="profile-info">
                        <div class="profile-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                        <div class="profile-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <form action="${pageContext.request.contextPath}/admin/ingredient?action=${formAction}" method="post" enctype="multipart/form-data">
                <!-- Keep track of the ingredient ID -->
                <input type="hidden" name="ingredientId" value="${ingredient.ingredientId}">
                <!-- Keep track of pagination/filters -->
                <input type="hidden" name="page" value="${param.page}">
                <input type="hidden" name="pageSize" value="${param.pageSize}">
                <input type="hidden" name="search" value="${param.search}">
                <input type="hidden" name="unitId" value="${param.unitId}">
                <input type="hidden" name="sortBy" value="${param.sortBy}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Chi Tiết Nguyên Liệu</h1>
                        <p class="page-subtitle">Xem và quản lý thông tin phân nhóm, đơn giá nguyên liệu làm bánh.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="submit" class="btn-cz-primary"><i class="fa-regular fa-floppy-disk me-1"></i> Lưu Lại</button>
                        <c:if test="${ingredient.ingredientId ne 'new' and not empty ingredient.ingredientId}">
                            <button type="button" class="btn-cz-danger" onclick="if(confirm('Bạn có chắc chắn muốn xóa nguyên liệu này không?')) { deleteIngredient('${ingredient.ingredientId}'); }">Xóa nguyên liệu</button>
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
                    <!-- Left Column: Image Upload -->
                    <div class="col-lg-5">
                        <div class="product-images-container">
                            <div class="product-images-header">
                                <h5 class="images-title">Hình Ảnh Nguyên Liệu</h5>
                                <p class="images-subtitle">Tải lên hình ảnh nguyên liệu chất lượng cao. Ảnh bìa lớn bên dưới sẽ được sử dụng làm ảnh đại diện chính.</p>
                            </div>
                            
                            <c:set var="resolvedImageUrl" value="https://images.unsplash.com/photo-1506084868230-bb9d95c24759" />
                            <c:if test="${not empty ingredient.imageUrl}">
                                <c:choose>
                                    <c:when test="${ingredient.imageUrl.startsWith('http://') or ingredient.imageUrl.startsWith('https://')}">
                                        <c:set var="resolvedImageUrl" value="${ingredient.imageUrl}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="resolvedImageUrl" value="${pageContext.request.contextPath}/${ingredient.imageUrl}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            
                            <div class="images-layout-grid">
                                <!-- Cover Image Panel -->
                                <div class="cover-image-panel">
                                    <div class="cover-image-wrapper" title="Nhấp để xem ảnh lớn hơn">
                                        <img id="mainCoverImage" src="${resolvedImageUrl}" alt="Ảnh Nguyên Liệu" onclick="openLightbox(this.src)" onerror="this.src='https://images.unsplash.com/photo-1506084868230-bb9d95c24759';">
                                        <div class="cover-badge">Ảnh nguyên liệu</div>
                                        <div class="cover-actions">
                                            <button type="button" class="action-btn edit-cover-btn" onclick="event.stopPropagation(); document.getElementById('imageFileInput').click()" title="Thay đổi ảnh">
                                                <i class="fa-solid fa-pencil"></i>
                                            </button>
                                            <button type="button" class="action-btn delete-cover-btn" onclick="event.stopPropagation(); resetCoverImage()" title="Xóa ảnh">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <input type="file" name="imageFile" id="imageFileInput" accept=".jpg,.jpeg,.png" style="display: none;">
                                    <input type="hidden" name="imageUrl" id="imageUrlHidden" value="${ingredient.imageUrl}">
                                    <div id="imageError" class="text-danger mt-1" style="font-size: 13px; display: none;"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Detail Info -->
                    <div class="col-lg-7">
                        <!-- Product Information Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Nguyên Liệu</h5>
                            
                            <div class="row g-3">
                                 <div class="col-12">
                                     <label class="form-label-cz">Tên Nguyên Liệu <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="ingredientName" name="ingredientName" value="${ingredient.ingredientName}" required>
                                     <div id="error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Đơn vị đo <span>*</span></label>
                                     <select class="form-select-cz" id="unitMeasure" name="unitMeasure" required style="height: 48px; border-radius: 8px;">
                                         <c:forEach var="u" items="${unitMeasures}">
                                             <option value="${u.unitId}" ${ingredient.unitMeasure eq u.unitId ? 'selected' : ''}>
                                                 ${u.unitName} (${u.unitId})
                                             </option>
                                         </c:forEach>
                                     </select>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Đơn giá (VND) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" id="pricePerUnit" name="pricePerUnit" value="${ingredient.pricePerUnit}" required>
                                     <div id="error-price" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>

        </div>
    </div>

    <!-- Hidden delete form for POST request -->
    <form id="deleteIngredientForm" action="${pageContext.request.contextPath}/admin/ingredient?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" value="${ingredient.ingredientId}">
        <input type="hidden" name="page" value="${param.page}">
        <input type="hidden" name="pageSize" value="${param.pageSize}">
        <input type="hidden" name="search" value="${param.search}">
        <input type="hidden" name="unitId" value="${param.unitId}">
        <input type="hidden" name="sortBy" value="${param.sortBy}">
    </form>

    <!-- Lightbox Modal for viewing large images -->
    <div id="imageLightbox" class="lightbox-modal" onclick="closeLightbox()">
        <span class="lightbox-close" onclick="closeLightbox()">&times;</span>
        <img class="lightbox-content" id="lightboxImg">
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteIngredient(id) {
            document.getElementById('deleteIngredientForm').submit();
        }

        // Live preview for image upload
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

        function resetCoverImage() {
            document.getElementById('imageFileInput').value = '';
            document.getElementById('imageUrlHidden').value = '';
            document.getElementById('mainCoverImage').src = 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759';
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

        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            const nameInput = document.getElementById('ingredientName');
            const priceInput = document.getElementById('pricePerUnit');
            const errorName = document.getElementById('error-name');
            const errorPrice = document.getElementById('error-price');
            
            errorName.style.display = 'none';
            errorPrice.style.display = 'none';
            nameInput.classList.remove('is-invalid');
            priceInput.classList.remove('is-invalid');

            let hasError = false;

            const nameVal = nameInput.value.trim();
            if (nameVal.length === 0) {
                errorName.textContent = 'Tên nguyên liệu không được để trống hoặc chỉ chứa khoảng trắng.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            } else if (nameVal.length < 2) {
                errorName.textContent = 'Tên nguyên liệu phải có tối thiểu 2 ký tự (không tính khoảng trắng).';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            }

            const priceVal = parseFloat(priceInput.value);
            if (isNaN(priceVal) || priceVal < 0) {
                errorPrice.textContent = 'Đơn giá phải lớn hơn hoặc bằng 0.';
                errorPrice.style.display = 'block';
                priceInput.classList.add('is-invalid');
                hasError = true;
            }

            if (hasError) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>
