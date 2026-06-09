<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                    <a href="${pageContext.request.contextPath}/admin/products">Danh sách bánh kem</a>
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
                        <c:if test="${product.id ne 'new' and not empty product.id}">
                            <c:choose>
                                <c:when test="${product.status eq 'Active'}">
                                    <button type="button" class="btn-cz-danger" onclick="if(confirm('Bạn có chắc chắn muốn vô hiệu hóa bánh kem này không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=deactivate&id=${product.id}'; }">Vô hiệu hóa</button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="btn-cz-primary" style="background-color: #3f5f36; color: #fff;" onclick="if(confirm('Bạn có chắc chắn muốn kích hoạt lại bánh kem này không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=activate&id=${product.id}'; }">Kích hoạt</button>
                                </c:otherwise>
                            </c:choose>
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
                        <div class="detail-card">
                            <h5 class="card-header-title">Hình Ảnh Bánh Kem</h5>
                            <p class="card-header-desc">Nhập liên kết hình ảnh bánh chất lượng cao. Bấm chọn ảnh nhỏ bên dưới để chọn làm hình đại diện (ảnh bìa chính) hiển thị trên cửa hàng.</p>
                            
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
                            
                            <div class="main-cover-wrapper">
                                <img id="mainCoverImage" src="${resolvedImageUrl}" alt="${product.name}" class="main-cover-img">
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
                                    <c:set var="resolvedThumbUrl" value="${img}" />
                                    <c:if test="${not empty img and not (img.startsWith('http://') or img.startsWith('https://'))}">
                                        <c:set var="resolvedThumbUrl" value="${pageContext.request.contextPath}/${img}" />
                                    </c:if>
                                    <div class="thumb-box" onclick="setAsCover('${img}')" data-url="${img}">
                                        <img src="${resolvedThumbUrl}" alt="Thumbnail">
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
                                     <label class="form-label-cz">Giá Bán Gốc (VND) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" id="productBasePrice" name="basePrice" value="${product.basePrice}" required>
                                     <div id="error-basePrice" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Thời Gian Làm Việc Ước Tính (giờ) <span>*</span></label>
                                     <input type="number" step="0.01" class="form-control-cz" id="productEstimatedLaborHours" name="estimatedLaborHours" value="${product.estimatedLaborHours}" required>
                                     <div id="error-estimatedLaborHours" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>
                                 <div class="col-md-6">
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
                                    <div id="editor-container" style="height: 220px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff;">
                                        ${product.fullDescription}
                                    </div>
                                    <input type="hidden" name="fullDescription" id="fullDescription">
                                </div>
                            </div>
                        </div>

                        <!-- Cake Recipe Card -->
                        <div class="detail-card mt-4">
                            <h5 class="card-header-title">Công Thức Chế Biến</h5>
                            <p class="card-header-desc">Quản lý quy trình làm bánh và các bước thực hành (Tương quan 1:1 với mẫu bánh).</p>
                            
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label-cz">Tên Công Thức</label>
                                    <input type="text" class="form-control-cz" name="recipeName" value="${not empty product.recipeName ? product.recipeName : ''}" placeholder="Ví dụ: Công thức làm bánh bông lan bắp">
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label-cz" style="display: block; margin-bottom: 8px;">Các Bước Thực Hiện</label>
                                    <div id="recipe-editor-container" style="height: 220px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff;">
                                        ${product.recipeInstructions}
                                    </div>
                                    <input type="hidden" name="recipeInstructions" id="recipeInstructions">
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
        // Helper to resolve relative path
        function resolveUrl(url) {
            if (!url) return 'https://images.unsplash.com/photo-1578985545062-69928b1d9587';
            if (url.startsWith('http://') || url.startsWith('https://')) {
                return url;
            }
            return '${pageContext.request.contextPath}/' + url;
        }

        // Set main cover image when a thumbnail is clicked
        function setAsCover(url) {
            document.getElementById('mainCoverImage').src = resolveUrl(url);
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
                
                thumbBox.innerHTML = 
                    '<img src="' + resolveUrl(cleanUrl) + '" alt="Thumbnail">' +
                    '<button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-1" style="font-size: 8px; line-height: 1;" onclick="event.stopPropagation(); removeThumbnail(\'' + cleanUrl + '\')">' +
                        '<i class="fa-solid fa-xmark"></i>' +
                    '</button>';
                
                grid.insertBefore(thumbBox, placeholder);
            }
        }

        // Remove a thumbnail and its corresponding hidden input
        function removeThumbnail(url) {
            // Remove the hidden input element
            const inputs = document.querySelectorAll('input[name="additionalImages"][value="' + url + '"]');
            inputs.forEach(input => input.remove());

            // Remove the thumbnail block
            const thumbs = document.querySelectorAll('.thumb-box[data-url="' + url + '"]');
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
                const existingInput = document.querySelector('input[name="additionalImages"][value="' + cleanUrl + '"]');
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
                    thumbBox.innerHTML = 
                        '<img src="' + resolveUrl(cleanUrl) + '" alt="Thumbnail">' +
                        '<button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-1" style="font-size: 8px; line-height: 1;" onclick="event.stopPropagation(); removeThumbnail(\'' + cleanUrl + '\')">' +
                            '<i class="fa-solid fa-xmark"></i>' +
                        '</button>';
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
    
    <!-- Quill Library -->
    <script src="https://cdn.jsdelivr.net/npm/quill@2.0.2/dist/quill.js"></script>
    <script>
        // Initialize Quill editor for description
        const quill = new Quill('#editor-container', {
            theme: 'snow',
            placeholder: 'Nhập mô tả chi tiết bánh kem...',
            modules: {
                toolbar: [
                    ['bold', 'italic', 'underline', 'strike'],        // toggled buttons
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                    [{ 'align': [] }],
                    ['link', 'image'],
                    ['clean']                                         // remove formatting button
                ]
            }
        });

        // Initialize Quill editor for recipe instructions
        const recipeQuill = new Quill('#recipe-editor-container', {
            theme: 'snow',
            placeholder: 'Nhập các bước thực hiện, nhiệt độ nướng, thời gian làm bánh...',
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

        // Sync Quill HTML contents to hidden inputs on form submit
        const form = document.querySelector('form');
        form.addEventListener('submit', function(e) {
            // Clear previous errors
            let hasError = false;
            
            const errorName = document.getElementById('error-name');
            const errorPrice = document.getElementById('error-basePrice');
            const errorLabor = document.getElementById('error-estimatedLaborHours');
            
            errorName.style.display = 'none';
            errorPrice.style.display = 'none';
            errorLabor.style.display = 'none';
            
            const nameInput = document.getElementById('productName');
            const priceInput = document.getElementById('productBasePrice');
            const laborInput = document.getElementById('productEstimatedLaborHours');
            
            nameInput.classList.remove('is-invalid');
            priceInput.classList.remove('is-invalid');
            laborInput.classList.remove('is-invalid');

            // 1. Validate name
            const nameVal = nameInput.value.trim();
            if (nameVal.length === 0) {
                errorName.textContent = 'Tên bánh kem không được để trống hoặc chỉ chứa khoảng trắng.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            } else if (nameVal.length < 3 || nameVal.length > 100) {
                errorName.textContent = 'Tên bánh kem phải từ 3 đến 100 ký tự.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            }

            // 2. Validate base price
            const priceVal = parseFloat(priceInput.value);
            if (isNaN(priceVal) || priceInput.value.trim() === '') {
                errorPrice.textContent = 'Vui lòng nhập giá bán gốc.';
                errorPrice.style.display = 'block';
                priceInput.classList.add('is-invalid');
                hasError = true;
            } else if (priceVal < 0) {
                errorPrice.textContent = 'Giá bán gốc phải lớn hơn hoặc bằng 0.';
                errorPrice.style.display = 'block';
                priceInput.classList.add('is-invalid');
                hasError = true;
            }

            // 3. Validate estimated labor hours
            const laborVal = parseFloat(laborInput.value);
            if (isNaN(laborVal) || laborInput.value.trim() === '') {
                errorLabor.textContent = 'Vui lòng nhập thời gian làm việc ước tính.';
                errorLabor.style.display = 'block';
                laborInput.classList.add('is-invalid');
                hasError = true;
            } else if (laborVal < 0) {
                errorLabor.textContent = 'Thời gian làm việc ước tính phải lớn hơn hoặc bằng 0.';
                errorLabor.style.display = 'block';
                laborInput.classList.add('is-invalid');
                hasError = true;
            }

            if (hasError) {
                e.preventDefault(); // Prevent form submission
                // Scroll to the first error input
                const firstError = document.querySelector('.is-invalid');
                if (firstError) {
                    firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    firstError.focus();
                }
                return false;
            }

            // Sync editors
            const descriptionInput = document.getElementById('fullDescription');
            descriptionInput.value = quill.root.innerHTML;

            const recipeInput = document.getElementById('recipeInstructions');
            recipeInput.value = recipeQuill.root.innerHTML;
        });
    </script>
</body>
</html>
