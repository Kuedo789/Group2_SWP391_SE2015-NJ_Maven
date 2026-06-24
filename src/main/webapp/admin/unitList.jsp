<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Quản lý đơn vị tính</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.3">
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
            <jsp:param name="parentMenu" value="Cấu hình" />
            <jsp:param name="activeMenu" value="Đơn vị tính" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">

            <!-- Flash Message Alerts -->
            <c:if test="${param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success' or param.msg eq 'delete_error'}">
                <div class="alert alert-${param.msg eq 'delete_error' ? 'danger' : 'success'} alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-${param.msg eq 'delete_error' ? 'triangle-exclamation' : 'circle-check'} me-2"></i>
                    <c:choose>
                        <c:when test="${param.msg eq 'add_success'}">Đã thêm mới đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'edit_success'}">Đã cập nhật đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'delete_success'}">Đã xóa đơn vị tính thành công!</c:when>
                        <c:when test="${param.msg eq 'delete_error'}">Xóa thất bại! Đơn vị tính này đang được liên kết trong bảng nguyên liệu.</c:when>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                </div>
            </c:if>

            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý đơn vị tính</h1>
                    <p class="page-subtitle">Định nghĩa danh mục các đơn vị đo lường sử dụng cho công thức và kho hàng.</p>
                </div>
                <button type="button" class="btn btn-cz-primary" onclick="openCreateModal()">
                    <i class="fa-solid fa-circle-plus"></i> Thêm đơn vị tính
                </button>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/unit" method="get">
                    <input type="hidden" name="action" value="list">

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm đơn vị theo mã, tên...">
                    </div>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/unit?action=list" class="btn-clear-filter"><i class="fa-solid fa-arrow-rotate-left"></i> Làm mới</a>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 70px;">STT</th>
                            <th style="width: 160px;">Mã đơn vị (ID)</th>
                            <th style="width: 220px;">Tên đơn vị</th>
                            <th>Mô tả chi tiết</th>
                            <th style="width: 150px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty unitList}">
                                <c:forEach var="u" items="${unitList}" varStatus="status">
                                    <tr>
                                        <td>${status.index + 1}</td>
                                        <td>
                                            <span class="badge" style="background-color: #f5f5f5; color: #666; border: 1px solid #ddd; font-size: 11px; font-weight: 500; padding: 5px 10px; border-radius: 4px; display: inline-flex; align-items: center; letter-spacing: 0.5px;">
                                                ${u.unitId}
                                            </span>
                                        </td>
                                        <td><strong>${u.unitName}</strong></td>
                                        <td class="text-muted" style="font-size: 13.5px; font-weight: 400; color: var(--cz-text-muted) !important;">${not empty u.description ? u.description : '—'}</td>
                                        <td>
                                            <div class="actions-cell">
                                                <button type="button" class="btn-action-edit" title="Chỉnh sửa" onclick="openEditModal('${u.unitId}', '${u.unitName}', '${not empty u.description ? u.description : ''}')">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </button>
                                                <button type="button" class="btn-action-delete" title="Xóa" onclick="confirmDelete('${u.unitId}', '${u.unitName}')">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                             <c:otherwise>
                                 <tr>
                                     <td colspan="5" class="text-center py-5 text-muted">
                                         <i class="fa-solid fa-ruler-combined d-block fs-2 mb-3" style="color: #ccc;"></i>
                                         Không tìm thấy đơn vị tính nào phù hợp.
                                     </td>
                                 </tr>
                             </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Tổng cộng <strong>${not empty unitList ? unitList.size() : 0}</strong> đơn vị tính</span>
                </div>
            </div>

        </div>
    </div>

    <!-- Hidden form for deleting -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/unit?action=delete" method="post" style="display: none;">
        <input type="hidden" name="id" id="deleteId">
        <input type="hidden" name="search" value="${search}">
    </form>

    <!-- Bootstrap Modal for Add/Edit Unit of Measure -->
    <div class="modal fade" id="unitModal" tabindex="-1" aria-labelledby="unitModalLabel" aria-hidden="true" style="font-family: 'Be Vietnam Pro', sans-serif;">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 5px 25px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background-color: #0f2d1e; color: white; border-top-left-radius: 12px; border-top-right-radius: 12px; padding: 16px 24px;">
                    <h5 class="modal-title" id="unitModalLabel" style="font-weight: 700; font-size: 16px;">Thêm Đơn Vị Tính</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="unitForm" action="${pageContext.request.contextPath}/admin/unit?action=create" method="post">
                    <input type="hidden" name="search" value="${search}">
                    
                    <div class="modal-body" style="padding: 24px;">
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Mã Đơn Vị (ID) <span>*</span></label>
                                <input type="text" class="form-control-cz" id="modalUnitId" name="unitId" required placeholder="Ví dụ: G, KG, ITEM, BOX" style="border-radius: 8px;">
                                <div id="modal-error-id" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                <span id="modalIdHelp" class="text-muted small mt-1 d-none"><i class="fa-solid fa-circle-info"></i> Không thể thay đổi Mã đơn vị tính khi đã được khởi tạo.</span>
                            </div>
                            
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Tên Đơn Vị <span>*</span></label>
                                <input type="text" class="form-control-cz" id="modalUnitName" name="unitName" required placeholder="Ví dụ: Gram, Kilogram" style="border-radius: 8px;">
                                <div id="modal-error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                            </div>
                            
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Mô Tả Chi Tiết</label>
                                <textarea class="form-control-cz" id="modalDescription" name="description" rows="3" placeholder="Mô tả cụ thể về đơn vị..." style="border-radius: 8px; height: auto;"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer" style="border-top: 1px solid #f3f4f6; padding: 16px 24px;">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 8px; padding: 8px 16px; font-weight: 600; font-size: 14px;">Hủy bỏ</button>
                        <button type="submit" class="btn btn-cz-primary" style="border-radius: 8px; padding: 8px 20px; font-weight: 600; font-size: 14px; background-color: #0f2d1e; border-color: #0f2d1e; color: white;">Lưu Lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let uModal;
        window.addEventListener('DOMContentLoaded', () => {
            uModal = new bootstrap.Modal(document.getElementById('unitModal'));
            
            // Sidebar toggle
            const sidebarToggle = document.querySelector('.sidebar-toggle');
            if (sidebarToggle) {
                sidebarToggle.addEventListener('click', () => {
                    document.querySelector('.sidebar')?.classList.toggle('collapsed');
                    document.querySelector('.main-panel')?.classList.toggle('expanded');
                });
            }
        });

        function confirmDelete(id, name) {
            if (confirm('Bạn có chắc chắn muốn xóa đơn vị tính "' + name + '" không?\nLưu ý: Bạn không thể xóa nếu có nguyên liệu đang sử dụng đơn vị này.')) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }

        function openCreateModal() {
            document.getElementById('unitModalLabel').textContent = 'Thêm Đơn Vị Tính';
            document.getElementById('unitForm').action = '${pageContext.request.contextPath}/admin/unit?action=create';
            
            const idInput = document.getElementById('modalUnitId');
            idInput.value = '';
            idInput.removeAttribute('readonly');
            idInput.style.backgroundColor = '';
            idInput.style.cursor = '';
            
            document.getElementById('modalUnitName').value = '';
            document.getElementById('modalDescription').value = '';
            
            // Validation reset
            document.getElementById('modal-error-id').style.display = 'none';
            document.getElementById('modal-error-name').style.display = 'none';
            idInput.classList.remove('is-invalid');
            document.getElementById('modalUnitName').classList.remove('is-invalid');
            document.getElementById('modalIdHelp').classList.add('d-none');
            
            uModal.show();
        }

        function openEditModal(id, name, desc) {
            document.getElementById('unitModalLabel').textContent = 'Chỉnh Sửa Đơn Vị Tính';
            document.getElementById('unitForm').action = '${pageContext.request.contextPath}/admin/unit?action=update';
            
            const idInput = document.getElementById('modalUnitId');
            idInput.value = id;
            idInput.setAttribute('readonly', 'readonly');
            idInput.style.backgroundColor = '#e9ecef';
            idInput.style.cursor = 'not-allowed';
            
            document.getElementById('modalUnitName').value = name;
            document.getElementById('modalDescription').value = desc;
            
            // Validation reset
            document.getElementById('modal-error-id').style.display = 'none';
            document.getElementById('modal-error-name').style.display = 'none';
            idInput.classList.remove('is-invalid');
            document.getElementById('modalUnitName').classList.remove('is-invalid');
            document.getElementById('modalIdHelp').classList.remove('d-none');
            
            uModal.show();
        }

        document.getElementById('unitForm').addEventListener('submit', function(e) {
            let hasError = false;
            const errorId = document.getElementById('modal-error-id');
            const errorName = document.getElementById('modal-error-name');
            const idInput = document.getElementById('modalUnitId');
            const nameInput = document.getElementById('modalUnitName');
            
            errorId.style.display = 'none';
            errorName.style.display = 'none';
            idInput.classList.remove('is-invalid');
            nameInput.classList.remove('is-invalid');

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
            }

            if (hasError) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>
