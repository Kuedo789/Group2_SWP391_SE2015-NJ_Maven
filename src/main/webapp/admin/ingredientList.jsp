<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.3">
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
                    <a href="#">Nguyên liệu</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Danh sách nguyên liệu</a>
                </div>
            </div>
            
            <div class="header-right">
                <button class="header-icon-btn"><i class="fa-regular fa-bell"></i><span class="badge-dot"></span></button>
                <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>
                
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
                <a href="${pageContext.request.contextPath}/admin/ingredient?action=create" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm nguyên liệu
                </a>
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
                                         <td>${i.unitMeasure}</td>
                                         <td>
                                             <c:if test="${not empty i.imageUrl}">
                                                 <img src="${i.imageUrl}" alt="${i.ingredientName}" style="max-height: 40px; max-width: 60px; border-radius: 4px; border: 1px solid #ddd; object-fit: cover;">
                                             </c:if>
                                             <c:if test="${empty i.imageUrl}">
                                                 <span class="text-muted">Không có ảnh</span>
                                             </c:if>
                                         </td>
                                         <td>
                                             <span style="font-weight: 600; color: var(--cz-primary);">
                                                 <fmt:formatNumber value="${i.pricePerUnit}" type="number" pattern="#,##0.00"/> đ / ${i.unitMeasure}
                                             </span>
                                         </td>
                                        <td>
                                            <div class="actions-cell">
                                                <a href="${pageContext.request.contextPath}/admin/ingredient?action=edit&id=${i.ingredientId}" class="btn-action-edit" title="Chỉnh sửa">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </a>
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
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteIngredient(id) {
            document.getElementById('deleteIngredientId').value = id;
            document.getElementById('deleteIngredientForm').submit();
        }
    </script>
</body>
</html>
