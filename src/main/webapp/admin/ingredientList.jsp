<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Ingredient Management" />
    </jsp:include>
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.5">
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
                <a href="${pageContext.request.contextPath}/admin/ingredient?action=create&page=${currentPage}&pageSize=${pageSize}&search=${search}&unitId=${unitId}&sortBy=${sortBy}" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm nguyên liệu
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/ingredient" method="get">
                    <input type="hidden" name="action" value="list">
                    <!-- Maintain page size -->
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    
                    <select class="filter-select" name="unitId" onchange="this.form.submit()" style="height: 42px; border-radius: 8px; border: 1px solid #ddd; padding: 0 15px;">
                        <option value="" ${empty unitId ? 'selected' : ''}>Tất cả đơn vị</option>
                        <c:forEach var="u" items="${unitMeasures}">
                            <option value="${u.unitId}" ${unitId eq u.unitId ? 'selected' : ''}>${u.unitName} (${u.unitId})</option>
                        </c:forEach>
                    </select>

                    <select class="filter-select" name="sortBy" onchange="this.form.submit()" style="height: 42px; border-radius: 8px; border: 1px solid #ddd; padding: 0 15px;">
                        <option value="" ${empty sortBy ? 'selected' : ''}>Sắp xếp mặc định</option>
                        <option value="price_asc" ${sortBy eq 'price_asc' ? 'selected' : ''}>Giá tăng dần</option>
                        <option value="price_desc" ${sortBy eq 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
                        <option value="name_asc" ${sortBy eq 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                        <option value="name_desc" ${sortBy eq 'name_desc' ? 'selected' : ''}>Tên Z-A</option>
                    </select>

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
                                                  <c:choose>
                                                      <c:when test="${i.imageUrl.startsWith('http://') or i.imageUrl.startsWith('https://')}">
                                                          <c:set var="resolvedUrl" value="${i.imageUrl}" />
                                                      </c:when>
                                                      <c:otherwise>
                                                          <c:set var="resolvedUrl" value="${pageContext.request.contextPath}/${i.imageUrl}" />
                                                      </c:otherwise>
                                                  </c:choose>
                                                  <img src="${resolvedUrl}" alt="${i.ingredientName}" style="max-height: 40px; max-width: 60px; border-radius: 4px; border: 1px solid #ddd; object-fit: cover;">
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
                                                <a href="${pageContext.request.contextPath}/admin/ingredient?action=edit&id=${i.ingredientId}&page=${currentPage}&pageSize=${pageSize}&search=${search}&unitId=${unitId}&sortBy=${sortBy}" class="btn-action-edit" title="Chỉnh sửa">
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
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${currentPage - 1}&search=${search}&pageSize=${pageSize}&unitId=${unitId}&sortBy=${sortBy}">
                                         <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                             
                             <!-- Page Numbers -->
                             <c:forEach var="pageNum" begin="1" end="${totalPages}">
                                 <li class="page-num-item ${pageNum == currentPage ? 'active' : ''}">
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${pageNum}&search=${search}&pageSize=${pageSize}&unitId=${unitId}&sortBy=${sortBy}">${pageNum}</a>
                                 </li>
                             </c:forEach>
                             
                             <!-- Next page -->
                             <c:if test="${currentPage < totalPages}">
                                 <li class="page-num-item">
                                     <a href="${pageContext.request.contextPath}/admin/ingredient?action=list&page=${currentPage + 1}&search=${search}&pageSize=${pageSize}&unitId=${unitId}&sortBy=${sortBy}">
                                         <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                     </a>
                                 </li>
                             </c:if>
                        </ul>
                        

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
