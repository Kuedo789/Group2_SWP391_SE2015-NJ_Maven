<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Ingredient Management</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.4">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="ingredients" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Nguyên liệu" />
            <jsp:param name="activeMenu" value="Danh sách nguyên liệu" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
             <!-- Flash Message Alerts -->
             <c:if test="${param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success' or param.msg eq 'delete_error'}">
                  <div class="alert alert-success alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-circle-check me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'add_success'}">Đã thêm mới nguyên liệu thành công!</c:when>
                          <c:when test="${param.msg eq 'edit_success'}">Đã cập nhật nguyên liệu thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_success'}">Đã xóa nguyên liệu thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_error'}">Xóa thất bại do lỗi ràng buộc dữ liệu (nguyên liệu đang có trong bánh mẫu)!</c:when>
                      </c:choose>
                      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                  </div>
             </c:if>
            
            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý nguyên liệu</h1>
                    <p class="page-subtitle">Quản lý định giá và phân nhóm nguyên liệu làm bánh.</p>
                </div>
                <button type="button" class="btn btn-cz-primary" onclick="openCreateModal()">
                    <i class="fa-solid fa-circle-plus"></i> Thêm nguyên liệu
                </button>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/ingredient" method="get">
                    <input type="hidden" name="action" value="list">
                    <!-- Maintain page size -->
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    
                    <!-- Category filter removed -->

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm nguyên liệu theo tên, mã...">
                    </div>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/ingredient?action=list" class="btn-clear-filter"><i class="fa-solid fa-arrow-rotate-left"></i> Làm mới</a>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                             <th style="width: 80px;">STT</th>
                             <th>Mã nguyên liệu</th>
                             <th>Tên nguyên liệu</th>
                             <th>Đơn vị tính</th>
                             <th>Ảnh</th>
                             <th>Đơn giá</th>
                             <th style="width: 180px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty ingredientList}">
                                <c:forEach var="i" items="${ingredientList}" varStatus="status">
                                    <tr>
                                         <td>${((currentPage - 1) * pageSize) + status.index + 1}</td>
                                         <td><strong>${i.ingredientId}</strong></td>
                                         <td>${i.ingredientName}</td>
                                          <td>
                                              <span class="badge" style="background-color: #f5f5f5; color: #666; border: 1px solid #ddd; font-size: 11px; font-weight: 500; padding: 5px 10px; border-radius: 4px; display: inline-flex; align-items: center; letter-spacing: 0.5px;">
                                                  ${i.unitName}
                                              </span>
                                          </td>
                                          <td>
                                              <c:if test="${not empty i.imageUrl}">
                                                  <img src="${i.imageUrl}" alt="${i.ingredientName}" style="max-height: 40px; max-width: 60px; border-radius: 4px; border: 1px solid #ddd; object-fit: cover;">
                                              </c:if>
                                              <c:if test="${empty i.imageUrl}">
                                                  <span class="text-muted" style="font-size: 13.5px;">Không có ảnh</span>
                                              </c:if>
                                          </td>
                                          <td>
                                              <span style="font-size: 14px; font-weight: 600; color: var(--cz-primary);">
                                                  <fmt:formatNumber value="${i.pricePerUnit}" type="number" pattern="#,##0.00"/> đ / ${i.unitName}
                                              </span>
                                          </td>
                                        <td>
                                            <div class="actions-cell">
                                                <button type="button" class="btn-action-edit" title="Chỉnh sửa" onclick="openEditModal('${i.ingredientId}', '${fn:escapeXml(i.ingredientName)}', '${i.unitMeasure}', '${i.pricePerUnit}', '${i.imageUrl}')">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </button>
                                                <button class="btn-action-delete" title="Xóa nguyên liệu" onclick="if(confirm('Bạn có chắc chắn muốn xóa nguyên liệu ${i.ingredientName} không?')) { deleteIngredient('${i.ingredientId}'); }">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                 <tr>
                                     <td colspan="7" class="text-center py-5 text-muted">
                                         <i class="fa-solid fa-warehouse d-block fs-2 mb-3" style="color: #ccc;"></i>
                                         Không tìm thấy nguyên liệu nào phù hợp với bộ lọc.
                                     </td>
                                 </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalCount > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + ingredientList.size()} trong tổng số ${totalCount} nguyên liệu</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <!-- Prev page -->
                             <c:if test="${currentPage > 1}">
                                 <li class="page-num-item">
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${currentPage - 1}&search=${search}&pageSize=${pageSize}">
                                         <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                             
                             <!-- Page Numbers -->
                             <c:forEach var="i" begin="1" end="${totalPages}">
                                 <li class="page-num-item ${i == currentPage ? 'active' : ''}">
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${i}&search=${search}&pageSize=${pageSize}">${i}</a>
                                 </li>
                             </c:forEach>
                             
                             <!-- Next page -->
                             <c:if test="${currentPage < totalPages}">
                                 <li class="page-num-item">
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${currentPage + 1}&search=${search}&pageSize=${pageSize}">
                                         <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                        </ul>
                        
                        <form action="${pageContext.request.contextPath}/admin/ingredient" method="get" class="d-inline">
                            <input type="hidden" name="action" value="list">
                             <input type="hidden" name="search" value="${search}">
                             <select class="filter-select" name="pageSize" onchange="this.form.submit()" style="min-width: auto; padding: 5px 25px 5px 10px; font-size: 12.5px;">
                                 <option value="5" ${pageSize == 5 ? 'selected' : ''}>5 / trang</option>
                                 <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 / trang</option>
                                 <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 / trang</option>
                             </select>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Hidden delete form for POST request -->
    <form id="deleteIngredientForm" action="${pageContext.request.contextPath}/admin/ingredient?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" id="deleteIngredientId">
        <input type="hidden" name="page" value="${currentPage}">
        <input type="hidden" name="pageSize" value="${pageSize}">
        <input type="hidden" name="search" value="${search}">
    </form>

    <!-- Bootstrap Modal for Add/Edit Ingredient -->
    <div class="modal fade" id="ingredientModal" tabindex="-1" aria-labelledby="ingredientModalLabel" aria-hidden="true" style="font-family: 'Be Vietnam Pro', sans-serif;">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 5px 25px rgba(0,0,0,0.15);">
                <div class="modal-header" style="background-color: #0f2d1e; color: white; border-top-left-radius: 12px; border-top-right-radius: 12px; padding: 16px 24px;">
                    <h5 class="modal-title" id="ingredientModalLabel" style="font-weight: 700; font-size: 16px;">Thêm Nguyên Liệu</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form id="ingredientForm" action="${pageContext.request.contextPath}/admin/ingredient?action=create" method="post">
                    <input type="hidden" name="ingredientId" id="modalIngredientId" value="">
                    <input type="hidden" name="page" value="${currentPage}">
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    <input type="hidden" name="search" value="${search}">
                    
                    <div class="modal-body" style="padding: 24px;">
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Tên Nguyên Liệu <span>*</span></label>
                                <input type="text" class="form-control-cz" id="modalIngredientName" name="ingredientName" required style="border-radius: 8px;">
                                <div id="modal-error-name" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                            </div>
                            
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Đơn vị đo <span>*</span></label>
                                <select class="form-select-cz" id="modalUnitMeasure" name="unitMeasure" required style="border-radius: 8px; height: 42px; font-size: 13.5px; padding: 0 15px;">
                                    <c:forEach var="u" items="${unitMeasures}">
                                        <option value="${u.unitId}">${u.unitName} (${u.unitId})</option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Đường dẫn ảnh (Image URL)</label>
                                <input type="text" class="form-control-cz" id="modalImageUrl" name="imageUrl" style="border-radius: 8px;">
                            </div>
                            
                            <div class="col-md-12">
                                <label class="form-label-cz" style="font-weight: 600; color: #374151; margin-bottom: 6px; display: block;">Đơn giá (VND) <span>*</span></label>
                                <input type="number" step="0.01" class="form-control-cz" id="modalPricePerUnit" name="pricePerUnit" required style="border-radius: 8px;">
                                <div id="modal-error-price" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
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

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let ingModal;
        window.addEventListener('DOMContentLoaded', () => {
            ingModal = new bootstrap.Modal(document.getElementById('ingredientModal'));
        });

        function deleteIngredient(id) {
            document.getElementById('deleteIngredientId').value = id;
            document.getElementById('deleteIngredientForm').submit();
        }

        function openCreateModal() {
            document.getElementById('ingredientModalLabel').textContent = 'Thêm Nguyên Liệu';
            document.getElementById('ingredientForm').action = '${pageContext.request.contextPath}/admin/ingredient?action=create';
            document.getElementById('modalIngredientId').value = 'new';
            document.getElementById('modalIngredientName').value = '';
            document.getElementById('modalImageUrl').value = '';
            document.getElementById('modalPricePerUnit').value = '';
            
            // Reset validation errors
            document.getElementById('modal-error-name').style.display = 'none';
            document.getElementById('modal-error-price').style.display = 'none';
            document.getElementById('modalIngredientName').classList.remove('is-invalid');
            document.getElementById('modalPricePerUnit').classList.remove('is-invalid');
            
            ingModal.show();
        }

        function openEditModal(id, name, unit, price, imageUrl) {
            document.getElementById('ingredientModalLabel').textContent = 'Chỉnh Sửa Nguyên Liệu';
            document.getElementById('ingredientForm').action = '${pageContext.request.contextPath}/admin/ingredient?action=update';
            document.getElementById('modalIngredientId').value = id;
            document.getElementById('modalIngredientName').value = name;
            document.getElementById('modalUnitMeasure').value = unit;
            document.getElementById('modalImageUrl').value = imageUrl;
            document.getElementById('modalPricePerUnit').value = price;
            
            // Reset validation errors
            document.getElementById('modal-error-name').style.display = 'none';
            document.getElementById('modal-error-price').style.display = 'none';
            document.getElementById('modalIngredientName').classList.remove('is-invalid');
            document.getElementById('modalPricePerUnit').classList.remove('is-invalid');
            
            ingModal.show();
        }

        document.getElementById('ingredientForm').addEventListener('submit', function(e) {
            const nameInput = document.getElementById('modalIngredientName');
            const priceInput = document.getElementById('modalPricePerUnit');
            const errorName = document.getElementById('modal-error-name');
            const errorPrice = document.getElementById('modal-error-price');
            
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
