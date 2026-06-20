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
                        <div class="profile-name">Nguyễn Anh Quân</div>
                        <div class="profile-role">PIC</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <form action="${pageContext.request.contextPath}/admin/ingredient?action=${formAction}" method="post">
                <!-- Keep track of the ingredient ID -->
                <input type="hidden" name="ingredientId" value="${ingredient.ingredientId}">

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
                    <!-- Column -->
                    <div class="col-lg-12">
                        
                        <!-- Product Information Card -->
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Nguyên Liệu</h5>
                            
                            <div class="row g-3">
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Tên Nguyên Liệu <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="ingredientName" name="ingredientName" value="${ingredient.ingredientName}" required>
                                     <div id="error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Đơn vị đo (Ví dụ: gram, ml, cái) <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="unitMeasure" name="unitMeasure" value="${ingredient.unitMeasure}" required>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Đường dẫn ảnh (Image URL)</label>
                                     <input type="text" class="form-control-cz" id="imageUrl" name="imageUrl" value="${ingredient.imageUrl}">
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
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteIngredient(id) {
            document.getElementById('deleteIngredientForm').submit();
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
            if (nameVal.length < 2) {
                errorName.textContent = 'Tên nguyên liệu phải có tối thiểu 2 ký tự.';
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
