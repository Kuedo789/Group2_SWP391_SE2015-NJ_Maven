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
            
            <form action="${pageContext.request.contextPath}/admin/product?action=${formAction}" method="post">
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
                        <div class="detail-card">
                            <h5 class="card-header-title">Hình Ảnh Bánh Kem</h5>
                            <p class="card-header-desc">Nhập liên kết hình ảnh bánh chất lượng cao từ internet.</p>
                            
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
                            
                            <div class="main-cover-wrapper mb-3">
                                <img id="mainCoverImage" src="${resolvedImageUrl}" alt="${product.name}" class="main-cover-img">
                                <span class="cover-badge">Ảnh Hiện Tại</span>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label-cz">Liên kết ảnh (URL)</label>
                                <input type="text" class="form-control-cz" name="imageUrl" id="imageUrlInput" value="${product.imageUrl}" oninput="updatePreviewImage(this.value)">
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

                        <!-- BOM Card -->
                        <div class="detail-card mt-4">
                            <h5 class="card-header-title">Định Lượng Nguyên Liệu & Giá Thành (BOM)</h5>
                            <p class="card-header-desc">Quản lý các nguyên liệu sử dụng để sản xuất bánh kem và tự động cập nhật giá thành.</p>
                            
                            <table class="table table-borderless align-middle" id="bomTable">
                                <thead>
                                    <tr style="border-bottom: 2px solid var(--cz-border-color);">
                                        <th style="font-size: 12px; font-weight: 700; color: #666;">Nguyên Liệu</th>
                                        <th style="font-size: 12px; font-weight: 700; color: #666; width: 180px;">Số Lượng (g)</th>
                                        <th style="font-size: 12px; font-weight: 700; color: #666; width: 120px;">Đơn Giá / g</th>
                                        <th style="font-size: 12px; font-weight: 700; color: #666; width: 150px;">Thành Tiền</th>
                                        <th style="font-size: 12px; font-weight: 700; color: #666; width: 80px;">Xóa</th>
                                    </tr>
                                </thead>
                                <tbody id="bomTableBody">
                                    <c:forEach var="item" items="${productIngredients}">
                                        <tr data-price="${item.pricePerUnit}">
                                            <td>
                                                <select class="form-select-cz bom-select" name="bomIngredientId" onchange="updateBomRowPrice(this)" style="padding: 5px 10px; height: 38px;">
                                                    <c:forEach var="ing" items="${allIngredients}">
                                                        <option value="${ing.ingredientId}" data-price="${ing.pricePerUnit}" ${item.ingredientId eq ing.ingredientId ? 'selected' : ''}>
                                                            ${ing.ingredientName} (đ/g)
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </td>
                                            <td>
                                                <input type="number" step="0.01" class="form-control-cz bom-grams" name="bomStandardGram" value="${item.standardGram}" oninput="recalculateBom()" style="padding: 5px 10px; height: 38px;" required>
                                            </td>
                                            <td class="bom-unit-price">
                                                <fmt:formatNumber value="${item.pricePerUnit}" type="number" pattern="#,##0.00"/> đ
                                            </td>
                                            <td class="bom-row-total" style="font-weight: 600;">
                                                <fmt:formatNumber value="${item.standardGram * item.pricePerUnit}" type="number" pattern="#,##0.00"/> đ
                                            </td>
                                            <td>
                                                <button type="button" class="btn-action-delete" onclick="removeBomRow(this)" style="width: 32px; height: 32px;">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                            <div class="d-flex justify-content-between align-items-center mt-3 pt-3" style="border-top: 1px dashed var(--cz-border-color);">
                                <button type="button" class="btn btn-sm btn-cz-primary" onclick="addBomRow()" style="font-size: 12.5px; padding: 6px 15px;"><i class="fa-solid fa-plus"></i> Thêm Nguyên Liệu</button>
                                <div>
                                    <strong>Tổng chi phí nguyên liệu:</strong> 
                                    <span id="bomCostTotal" style="font-size: 16px; font-weight: 700; color: var(--cz-primary); margin-left: 10px;">0 đ</span>
                                </div>
                            </div>
                        </div>

                        <!-- Cake Recipe Card (Unified into template steps) -->
                        <div class="detail-card mt-4" id="recipe-editor-container-wrapper">
                            <h5 class="card-header-title">Hướng Dẫn Làm Bếp / Quy Trình Chế Biến</h5>
                            <p class="card-header-desc">Nhập quy trình, các bước chế biến cụ thể dành cho thợ làm bánh.</p>
                            
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <div id="recipe-editor-container" style="height: 250px; font-family: 'Be Vietnam Pro', sans-serif; background-color: #fff;">
                                        ${product.instructionSteps}
                                    </div>
                                    <input type="hidden" name="instructionSteps" id="instructionSteps">
                                </div>
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
        function updatePreviewImage(url) {
            const preview = document.getElementById('mainCoverImage');
            if (url && url.trim() !== '') {
                preview.src = url;
            } else {
                preview.src = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587';
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
                    ['bold', 'italic', 'underline', 'strike'],
                    [{ 'list': 'ordered'}, { 'list': 'bullet' }],
                    [{ 'align': [] }],
                    ['link', 'image'],
                    ['clean']
                ]
            }
        });

        // Initialize Quill editor for recipe instructions
        const recipeQuill = new Quill('#recipe-editor-container', {
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
            document.getElementById('fullDescription').value = quill.root.innerHTML;
            document.getElementById('instructionSteps').value = recipeQuill.root.innerHTML;
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
                    const price = parseFloat(option.getAttribute('data-price')) || 0.0;
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
            recalculateBom();
            document.getElementById('defaultMarginPercent').addEventListener('input', recalculateBom);
            document.getElementById('defaultServicePercent').addEventListener('input', recalculateBom);
        });
    </script>
    
    <!-- Hidden delete form for POST request -->
    <form id="deleteProductForm" action="${pageContext.request.contextPath}/admin/product?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" id="deleteProductId">
    </form>
    <script>
        function deleteProduct(id) {
            document.getElementById('deleteProductId').value = id;
            document.getElementById('deleteProductForm').submit();
        }
    </script>
</body>
</html>
