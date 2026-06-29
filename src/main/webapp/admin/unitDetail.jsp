<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Đơn vị tính chi tiết</title>
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
        <jsp:param name="activeMenu" value="units" />
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
                    <a href="${pageContext.request.contextPath}/admin/unit?action=list">Danh sách đơn vị</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Chi tiết đơn vị tính</a>
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

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <form action="${pageContext.request.contextPath}/admin/unit?action=${formAction}" method="post" id="unitForm">
                <!-- Keep track of the mode -->
                <input type="hidden" name="isEdit" value="${isEdit}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Chi Tiết Đơn Vị Tính</h1>
                        <p class="page-subtitle">Cấu hình thông tin mã nhận diện, mô tả của đơn vị đo lường trong hệ thống.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="submit" class="btn-cz-primary"><i class="fa-regular fa-floppy-disk me-1"></i> Lưu Lại</button>
                        <c:if test="${isEdit}">
                            <button type="button" class="btn-cz-danger" onclick="confirmDeleteUnit('${unit.unitId}')">Xóa đơn vị</button>
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
                    <div class="col-lg-8">
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Đơn Vị Tính</h5>
                            
                            <div class="row g-3">
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Mã Đơn Vị (ID) <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="unitId" name="unitId" value="${unit.unitId}" maxlength="10" required ${isEdit ? 'readonly style="background-color: #e9ecef; cursor: not-allowed;"' : ''} placeholder="Ví dụ: G, KG, ITEM, BOX">
                                     <div id="error-id" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                     <c:if test="${isEdit}">
                                         <span class="text-muted small mt-1 d-block"><i class="fa-solid fa-circle-info"></i> Không thể thay đổi Mã đơn vị tính khi đã được khởi tạo.</span>
                                     </c:if>
                                 </div>

                                 <div class="col-md-6">
                                     <label class="form-label-cz">Tên Đơn Vị <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="unitName" name="unitName" value="${unit.unitName}" maxlength="50" required placeholder="Ví dụ: Gram, Kilogram, Hộp / Thùng">
                                     <div id="error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>

                                 <div class="col-md-12">
                                     <label class="form-label-cz">Mô Tả Chi Tiết</label>
                                     <textarea class="form-control-cz" id="description" name="description" rows="4" maxlength="255" style="height: auto; border-radius: 8px;" placeholder="Nhập mô tả cụ thể về đơn vị đo lường...">${unit.description}</textarea>
                                     <div id="error-desc" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden delete form -->
    <c:if test="${isEdit}">
        <form id="deleteUnitForm" action="${pageContext.request.contextPath}/admin/unit?action=delete" method="post" style="display:none;">
            <input type="hidden" name="id" value="${unit.unitId}">
        </form>
    </c:if>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDeleteUnit(id) {
            if (confirm('Bạn có chắc chắn muốn xóa đơn vị tính "' + id + '" này không?')) {
                document.getElementById('deleteUnitForm').submit();
            }
        }

        document.getElementById('unitForm').addEventListener('submit', function(e) {
            let hasError = false;
            
            const errorId = document.getElementById('error-id');
            const errorName = document.getElementById('error-name');
            const errorDesc = document.getElementById('error-desc');
            
            if (errorId) errorId.style.display = 'none';
            errorName.style.display = 'none';
            if (errorDesc) errorDesc.style.display = 'none';
            
            const idInput = document.getElementById('unitId');
            const nameInput = document.getElementById('unitName');
            const descInput = document.getElementById('description');
            
            idInput.classList.remove('is-invalid');
            nameInput.classList.remove('is-invalid');
            if (descInput) descInput.classList.remove('is-invalid');

            // Validate ID only if creating new
            if (!idInput.hasAttribute('readonly')) {
                const idVal = idInput.value.trim();
                if (idVal.length === 0) {
                    errorId.textContent = 'Mã đơn vị tính không được để trống.';
                    errorId.style.display = 'block';
                    idInput.classList.add('is-invalid');
                    hasError = true;
                } else if (idVal.length > 10) {
                    errorId.textContent = 'Mã đơn vị tính tối đa 10 ký tự.';
                    errorId.style.display = 'block';
                    idInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            // Validate name
            const nameVal = nameInput.value.trim();
            if (nameVal.length === 0) {
                errorName.textContent = 'Tên đơn vị tính không được để trống.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            } else if (nameVal.length < 2) {
                errorName.textContent = 'Tên đơn vị tính tối thiểu 2 ký tự.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            } else if (nameVal.length > 50) {
                errorName.textContent = 'Tên đơn vị tính tối đa 50 ký tự.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                hasError = true;
            }

            // Validate description length
            if (descInput) {
                const descVal = descInput.value;
                if (descVal.length > 255) {
                    errorDesc.textContent = 'Mô tả chi tiết không được vượt quá 255 ký tự.';
                    errorDesc.style.display = 'block';
                    descInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            if (hasError) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>
