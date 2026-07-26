<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Đơn vị tính chi tiết" />
    </jsp:include>
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductDetail.css?v=1.5">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="units" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Danh sách đơn vị" />
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/admin/unit?action=list" />
            <jsp:param name="activeMenu" value="Chi tiết đơn vị tính" />
        </jsp:include>

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

                <div id="js-alert-container">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert" style="background-color: #fdf3f3; border-color: #fcebeb; color: #dc3545; border-radius: 8px; font-weight: 500; font-size: 14px; margin-bottom: 25px;">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i> ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                </div>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Đơn Vị Tính</h5>
                            
                            <div class="row g-3">
                                 <div class="col-md-6">
                                     <label class="form-label-cz">Mã Đơn Vị (ID) <span>*</span></label>
                                     <input type="text" class="form-control-cz" id="unitId" name="unitId" value="${unit.unitId}" required ${isEdit ? 'readonly style="background-color: #e9ecef; cursor: not-allowed;"' : ''} placeholder="Ví dụ: G, KG, ITEM, BOX">
                                     <c:if test="${isEdit}">
                                         <span class="text-muted small mt-1 d-block"><i class="fa-solid fa-circle-info"></i> Không thể thay đổi Mã đơn vị tính khi đã được khởi tạo.</span>
                                     </c:if>
                                 </div>

                                  <div class="col-md-6">
                                      <label class="form-label-cz">Tên Đơn Vị <span>*</span></label>
                                      <input type="text" class="form-control-cz" id="unitName" name="unitName" value="${unit.unitName}" required placeholder="Ví dụ: Gram, Kilo, Hộp">
                                  </div>

                                  <div class="col-md-12">
                                      <label class="form-label-cz">Mô Tả Chi Tiết <span>*</span></label>
                                      <textarea class="form-control-cz" id="description" name="description" rows="4" required style="height: auto; border-radius: 8px;" placeholder="Nhập mô tả cụ thể về đơn vị đo lường (3-100 ký tự)...">${unit.description}</textarea>
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

        const idInput = document.getElementById('unitId');
        const nameInput = document.getElementById('unitName');
        const descInput = document.getElementById('description');

        // Validation helper functions
        function validateId() {
            if (!idInput || idInput.hasAttribute('readonly')) return true;
            
            const errorId = document.getElementById('error-id');
            const idVal = idInput.value;
            const trimmed = idVal.trim();
            
            idInput.classList.remove('is-invalid');
            if (errorId) errorId.style.display = 'none';

            if (idVal.length === 0) {
                errorId.textContent = 'Mã đơn vị tính không được để trống.';
                errorId.style.display = 'block';
                idInput.classList.add('is-invalid');
                return false;
            }
            if (idVal !== trimmed || idVal.includes(' ')) {
                errorId.textContent = 'Mã đơn vị không được chứa khoảng trắng.';
                errorId.style.display = 'block';
                idInput.classList.add('is-invalid');
                return false;
            }
            if (idVal.length > 10) {
                errorId.textContent = 'Mã đơn vị tính tối đa 10 ký tự.';
                errorId.style.display = 'block';
                idInput.classList.add('is-invalid');
                return false;
            }
            if (!/^[a-zA-Z0-9]+$/.test(idVal)) {
                errorId.textContent = 'Mã đơn vị chỉ được phép chứa chữ cái không dấu và chữ số (không ký tự đặc biệt).';
                errorId.style.display = 'block';
                idInput.classList.add('is-invalid');
                return false;
            }
            return true;
        }

        function validateName() {
            if (!nameInput) return true;
            
            const errorName = document.getElementById('error-name');
            const nameVal = nameInput.value;
            const trimmed = nameVal.trim();
            
            nameInput.classList.remove('is-invalid');
            if (errorName) errorName.style.display = 'none';

            if (nameVal.length === 0) {
                errorName.textContent = 'Tên đơn vị tính không được để trống.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                return false;
            }
            if (nameVal.length < 3) {
                errorName.textContent = 'Tên đơn vị tính tối thiểu 3 ký tự.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                return false;
            }
            if (nameVal.length > 10) {
                errorName.textContent = 'Tên đơn vị tính tối đa 10 ký tự.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                return false;
            }
            
            const namePattern = /^(?=.*[a-zA-Z0-9ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂÂÊÔƠưăâêôơ])[a-zA-Z0-9\sÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂÂÊÔƠưăâêôơ\/\-]+$/;
            if (!namePattern.test(trimmed)) {
                errorName.textContent = 'Tên đơn vị không được chứa toàn bộ khoảng trắng, ký tự đặc biệt hoặc ký tự không hợp lệ.';
                errorName.style.display = 'block';
                nameInput.classList.add('is-invalid');
                return false;
            }
            return true;
        }

        function validateDesc() {
            if (!descInput) return true;
            
            const errorDesc = document.getElementById('error-desc');
            const descVal = descInput.value;
            const trimmed = descVal.trim();
            
            descInput.classList.remove('is-invalid');
            if (errorDesc) errorDesc.style.display = 'none';

            if (descVal.length === 0) {
                errorDesc.textContent = 'Mô tả chi tiết không được để trống.';
                errorDesc.style.display = 'block';
                descInput.classList.add('is-invalid');
                return false;
            }
            if (descVal.length < 3) {
                errorDesc.textContent = 'Mô tả chi tiết tối thiểu 3 ký tự.';
                errorDesc.style.display = 'block';
                descInput.classList.add('is-invalid');
                return false;
            }
            if (descVal.length > 100) {
                errorDesc.textContent = 'Mô tả chi tiết tối đa 100 ký tự.';
                errorDesc.style.display = 'block';
                descInput.classList.add('is-invalid');
                return false;
            }
            
            const descPattern = /^(?=.*[a-zA-Z0-9ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂÂÊÔƠưăâêôơ]).+$/;
            if (!descPattern.test(trimmed)) {
                errorDesc.textContent = 'Mô tả chi tiết không được chứa toàn bộ khoảng trắng hoặc ký tự đặc biệt.';
                errorDesc.style.display = 'block';
                descInput.classList.add('is-invalid');
                return false;
            }
            return true;
        }

        // Live validation listeners
        if (idInput && !idInput.hasAttribute('readonly')) {
            idInput.addEventListener('input', validateId);
        }
        if (nameInput) {
            nameInput.addEventListener('input', validateName);
        }
        if (descInput) {
            descInput.addEventListener('input', validateDesc);
        }

        // Form Submit Validation
        document.getElementById('unitForm').addEventListener('submit', function(e) {
            const isIdValid = validateId();
            const isNameValid = validateName();
            const isDescValid = validateDesc();

            if (!isIdValid || !isNameValid || !isDescValid) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>
