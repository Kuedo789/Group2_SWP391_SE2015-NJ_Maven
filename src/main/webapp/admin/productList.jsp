<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Product List" />
    </jsp:include>
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.6">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all/order.css">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="products" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Sản phẩm" />
            <jsp:param name="activeMenu" value="Danh sách bánh kem" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
             <!-- Flash Message Alerts -->
             <c:if test="${not empty sessionScope.errorMessage or param.msg eq 'save_error' or param.msg eq 'delete_error' or param.msg eq 'deactivate_error' or param.msg eq 'activate_error'}">
                  <div class="alert alert-danger alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-triangle-exclamation me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'save_error'}">Lưu thông tin bánh kem thất bại. Vui lòng kiểm tra lại!</c:when>
                          <c:when test="${param.msg eq 'delete_error'}">Không thể xóa bánh kem này vì đang có ràng buộc dữ liệu.</c:when>
                          <c:when test="${param.msg eq 'deactivate_error'}">Vô hiệu hóa bánh kem thất bại. Vui lòng thử lại!</c:when>
                          <c:when test="${param.msg eq 'activate_error'}">Kích hoạt bánh kem thất bại. Vui lòng thử lại!</c:when>
                          <c:otherwise>${sessionScope.errorMessage}</c:otherwise>
                      </c:choose>
                      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                  </div>
                  <c:remove var="errorMessage" scope="session" />
             </c:if>
             <c:if test="${not empty sessionScope.successMessage or param.msg eq 'save_success' or param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success' or param.msg eq 'deactivate_success' or param.msg eq 'activate_success' or param.msg eq 'new_version_success'}">
                  <div class="alert alert-success alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-circle-check me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'add_success'}">Đã thêm mới bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'new_version_success'}">Do bánh cũ đã có đơn hàng, hệ thống tự động tạo phiên bản bánh mới với định lượng BOM mới và tạm ngưng bánh cũ!</c:when>
                          <c:when test="${param.msg eq 'edit_success' or param.msg eq 'save_success'}">Đã cập nhật thông tin bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_success'}">Đã xóa bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'deactivate_success'}">Đã vô hiệu hóa bánh kem thành công!</c:when>
                          <c:when test="${param.msg eq 'activate_success'}">Đã kích hoạt bánh kem thành công!</c:when>
                          <c:otherwise>${sessionScope.successMessage}</c:otherwise>
                      </c:choose>
                      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Đóng"></button>
                  </div>
                  <c:remove var="successMessage" scope="session" />
             </c:if>
            
            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Danh sách bánh kem</h1>
                    <p class="page-subtitle">Quản lý tất cả sản phẩm bánh kem, nguyên liệu và trạng thái kinh doanh.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/product?action=create&page=${currentPage}&pageSize=${pageSize}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm bánh mới
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/product" method="get">
                    <input type="hidden" name="action" value="list">
                    <!-- Maintain page size -->
                    <input type="hidden" name="pageSize" value="${pageSize}">
                    
                     <select class="filter-select" name="category" onchange="this.form.submit()">
                        <option value="" ${empty category ? 'selected' : ''}>Tất cả danh mục</option>
                        <c:forEach var="cat" items="${productCategories}">
                            <option value="${cat.id}" ${category eq cat.id or category eq cat.name ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>

                    <select class="filter-select" name="status" onchange="this.form.submit()">
                        <option value="" ${empty status ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Active" ${status eq 'Active' ? 'selected' : ''}>Hoạt động</option>
                        <option value="Inactive" ${status eq 'Inactive' ? 'selected' : ''}>Ngưng bán</option>
                    </select>

                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="${search}" placeholder="Tìm kiếm bánh theo tên, mã...">
                    </div>

                    <select class="filter-select" name="sortBy" onchange="this.form.submit()">
                        <option value="price-asc" ${sortBy eq 'price-asc' or empty sortBy ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                        <option value="price-desc" ${sortBy eq 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                    </select>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                    <a href="${pageContext.request.contextPath}/admin/product?action=list" class="btn-clear-filter"><i class="fa-solid fa-arrow-rotate-left"></i> Làm mới</a>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <div class="table-responsive">
                    <table class="cz-table">
                        <thead>
                             <tr>
                                 <th class="text-center" style="width: 50px; text-align: center;">STT</th>
                                 <th style="min-width: 200px;">Hình ảnh & Tên bánh</th>
                                 <th style="white-space: nowrap; width: 140px;">Danh mục</th>
                                 <th style="white-space: nowrap; width: 150px;">Giá & Giờ công</th>
                                 <th class="text-center" style="white-space: nowrap; width: 150px; text-align: center;">Cho phép ghi chữ</th>
                                 <th class="text-center" style="white-space: nowrap; width: 120px; text-align: center;">Trạng thái</th>
                                 <th class="text-center" style="white-space: nowrap; width: 130px; text-align: center;">Thao tác</th>
                             </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty productList}">
                                    <c:forEach var="p" items="${productList}" varStatus="status">
                                        <tr>
                                            <td class="text-center" style="text-align: center;">${((currentPage - 1) * pageSize) + status.index + 1}</td>
                                            <td>
                                                <div class="product-cell">
                                                    <c:choose>
                                                        <c:when test="${not empty p.imageUrl}">
                                                            <c:set var="resolvedListImgUrl" value="${p.imageUrl}" />
                                                            <c:if test="${not (p.imageUrl.startsWith('http://') or p.imageUrl.startsWith('https://'))}">
                                                                <c:set var="resolvedListImgUrl" value="${pageContext.request.contextPath}/${p.imageUrl}" />
                                                            </c:if>
                                                            <img src="${resolvedListImgUrl}" alt="${p.name}" class="product-thumb">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=100" alt="Default Cake" class="product-thumb">
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="product-meta">
                                                        <a href="${pageContext.request.contextPath}/admin/product?action=edit&id=${p.id}&page=${currentPage}&pageSize=${pageSize}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}" class="product-name-link">${p.name}</a>
                                                        <span class="product-sku">Mã: ${p.id}</span>
                                                    </div>
                                                </div>
                                            </td>
                                             <td style="white-space: nowrap;">${p.categoryName}</td>
                                             <td style="white-space: nowrap;">
                                                 <span style="font-size: 14.5px; font-weight: 600; color: var(--cz-primary); display: block;">
                                                     <fmt:formatNumber value="${p.basePrice}" type="number" pattern="#,##0"/>đ
                                                 </span>
                                                 <div class="text-muted mt-1" style="font-size: 12px; font-weight: 500;">
                                                     <i class="fa-regular fa-clock me-1" style="color: #aaa;"></i> Giờ công: ${p.estimatedLaborHours} giờ
                                                 </div>
                                             </td>
                                             <td class="text-center" style="text-align: center;">
                                                 <c:choose>
                                                     <c:when test="${p.allowsGreeting}">
                                                          <span class="badge" style="background-color: #e3f2fd; color: #0d6efd; border: 1px solid #bbdefb; font-size: 11px; font-weight: 600; padding: 5px 10px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px;">
                                                              <i class="fa-regular fa-pen-to-square"></i> Được ghi chữ
                                                          </span>
                                                     </c:when>
                                                     <c:otherwise>
                                                          <span class="badge" style="background-color: #f5f5f5; color: #888; border: 1px solid #ddd; font-size: 11px; font-weight: 500; padding: 5px 10px; border-radius: 4px;">
                                                              Không hỗ trợ
                                                          </span>
                                                     </c:otherwise>
                                                 </c:choose>
                                             </td>
                                             <td class="text-center" style="text-align: center;">
                                                 <c:choose>
                                                     <c:when test="${p.status eq 'Active'}">
                                                         <span class="status-badge-active" style="white-space: nowrap;">Hoạt động</span>
                                                     </c:when>
                                                     <c:otherwise>
                                                         <span class="status-badge-inactive" style="white-space: nowrap;">Ngưng bán</span>
                                                     </c:otherwise>
                                                 </c:choose>
                                             </td>
                                            <td class="text-center" style="text-align: center;">
                                                <div class="actions-cell" style="justify-content: center; display: inline-flex; gap: 8px;">
                                                    <a href="${pageContext.request.contextPath}/admin/product?action=detail&id=${p.id}&page=${currentPage}&pageSize=${pageSize}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}" class="btn-action-view" title="Xem chi tiết">
                                                        <i class="fa-regular fa-eye"></i>
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/admin/product?action=edit&id=${p.id}&page=${currentPage}&pageSize=${pageSize}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}" class="btn-action-edit" title="Chỉnh sửa">
                                                        <i class="fa-regular fa-pen-to-square"></i>
                                                    </a>
                                                    <c:choose>
                                                        <c:when test="${p.status eq 'Active'}">
                                                            <button class="btn-action-delete" title="Vô hiệu hóa" onclick="if(confirm('Bạn có chắc chắn muốn vô hiệu hóa bánh kem ${p.name} không?')) { deleteProduct('${p.id}'); }">
                                                                <i class="fa-regular fa-trash-can"></i>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button class="btn-action-restore" title="Khôi phục" onclick="if(confirm('Bạn có chắc chắn muốn khôi phục bánh kem ${p.name} không?')) { restoreProduct('${p.id}'); }" style="border: none; background: none; color: #10b981; cursor: pointer; padding: 6px; font-size: 15px; display: inline-flex; align-items: center; justify-content: center; transition: color 0.2s;">
                                                                <i class="fa-solid fa-rotate-left"></i>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center py-5 text-muted">
                                            <i class="fa-solid fa-box-open d-block fs-2 mb-3" style="color: #ccc;"></i>
                                            Không tìm thấy bánh kem nào phù hợp với bộ lọc.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalCount > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + productList.size()} trong tổng số ${totalCount} sản phẩm</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <!-- Prev page -->
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/product?action=list&page=${currentPage - 1}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                            
                            <!-- Page Numbers -->
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-num-item ${i == currentPage ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/product?action=list&page=${i}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <!-- Next page -->
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/product?action=list&page=${currentPage + 1}&category=${category}&status=${requestScope.status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
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
    <form id="deleteProductForm" action="${pageContext.request.contextPath}/admin/product?action=delete" method="post" style="display:none;">
        <input type="hidden" name="id" id="deleteProductId">
        <input type="hidden" name="page" value="${currentPage}">
        <input type="hidden" name="pageSize" value="${pageSize}">
        <input type="hidden" name="category" value="${category}">
        <input type="hidden" name="status" value="${status}">
        <input type="hidden" name="search" value="${search}">
        <input type="hidden" name="sortBy" value="${sortBy}">
    </form>

    <!-- Hidden restore form for POST request -->
    <form id="restoreProductForm" action="${pageContext.request.contextPath}/admin/product?action=restore" method="post" style="display:none;">
        <input type="hidden" name="id" id="restoreProductId">
        <input type="hidden" name="page" value="${currentPage}">
        <input type="hidden" name="pageSize" value="${pageSize}">
        <input type="hidden" name="category" value="${category}">
        <input type="hidden" name="status" value="${status}">
        <input type="hidden" name="search" value="${search}">
        <input type="hidden" name="sortBy" value="${sortBy}">
    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function deleteProduct(id) {
            document.getElementById('deleteProductId').value = id;
            document.getElementById('deleteProductForm').submit();
        }
        function restoreProduct(id) {
            document.getElementById('restoreProductId').value = id;
            document.getElementById('restoreProductForm').submit();
        }
    </script>
</body>
</html>
