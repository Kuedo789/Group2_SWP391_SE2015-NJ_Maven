<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Product List</title>
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
                    <a href="#" class="active text-dark font-weight-bold">Danh sách bánh kem</a>
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
             <c:if test="${not empty sessionScope.successMessage or param.msg eq 'save_success' or param.msg eq 'add_success' or param.msg eq 'edit_success' or param.msg eq 'delete_success' or param.msg eq 'deactivate_success' or param.msg eq 'activate_success'}">
                  <div class="alert alert-success alert-dismissible fade show" role="alert">
                      <i class="fa-solid fa-circle-check me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'add_success'}">Đã thêm mới bánh kem thành công!</c:when>
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
                <a href="${pageContext.request.contextPath}/admin/product-detail?id=new" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm bánh mới
                </a>
            </div>

            <!-- Filters -->
            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/products" method="get">
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
                        <option value="newest" ${sortBy eq 'newest' ? 'selected' : ''}>Sắp xếp: Mới nhất</option>
                        <option value="price-asc" ${sortBy eq 'price-asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                        <option value="price-desc" ${sortBy eq 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                    </select>

                    <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                </form>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">STT</th>
                            <th>Hình ảnh & Tên bánh</th>
                            <th>Danh mục</th>
                            <th style="min-width: 180px;">Giá & Giờ công</th>
                            <th class="text-center" style="width: 160px;">Cho phép ghi chữ</th>
                            <th style="min-width: 180px;">Công thức làm bánh</th>
                            <th class="text-center" style="width: 150px;">Trạng thái</th>
                            <th style="width: 180px; min-width: 160px;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty productList}">
                                <c:forEach var="p" items="${productList}" varStatus="status">
                                    <tr>
                                        <td>${((currentPage - 1) * pageSize) + status.index + 1}</td>
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
                                                    <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="product-name-link">${p.name}</a>
                                                    <span class="product-sku">Mã: ${p.id}</span>
                                                </div>
                                            </div>
                                        </td>
                                         <td>${p.categoryName}</td>
                                         <td>
                                             <span style="font-size: 14.5px; font-weight: 700; color: var(--cz-primary); display: block;">
                                                 <fmt:formatNumber value="${p.basePrice}" type="number" pattern="#,##0"/> đ
                                             </span>
                                             <div class="text-muted mt-1" style="font-size: 12px; font-weight: 500;">
                                                 <i class="fa-regular fa-clock me-1" style="color: #aaa;"></i> Giờ công: ${p.estimatedLaborHours} giờ
                                             </div>
                                         </td>
                                         <td class="text-center">
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
                                         <td>
                                             <c:choose>
                                                 <c:when test="${not empty p.recipeName}">
                                                     <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}#recipe-editor-container" class="product-name-link" style="font-weight: 500; font-size: 13px; display: inline-flex; align-items: center; gap: 4px;">
                                                         <i class="fa-solid fa-receipt" style="color: var(--cz-secondary); font-size: 12px;"></i> ${p.recipeName}
                                                     </a>
                                                 </c:when>
                                                 <c:otherwise>
                                                     <span class="text-muted" style="font-size: 12px; font-style: italic;">Chưa thiết lập</span>
                                                 </c:otherwise>
                                             </c:choose>
                                         </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${p.status eq 'Active'}">
                                                    <span class="status-badge-active">Hoạt động</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge-inactive">Ngưng bán</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div class="actions-cell">
                                                <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="btn-action-view" title="Xem chi tiết">
                                                    <i class="fa-regular fa-eye"></i>
                                                </a>
                                                <a href="${pageContext.request.contextPath}/admin/product-detail?id=${p.id}" class="btn-action-edit" title="Chỉnh sửa">
                                                    <i class="fa-regular fa-pen-to-square"></i>
                                                </a>
                                                 <c:choose>
                                                     <c:when test="${p.status eq 'Active'}">
                                                         <button class="btn-action-delete" title="Vô hiệu hóa" onclick="if(confirm('Bạn có chắc chắn muốn vô hiệu hóa bánh kem ${p.name} không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=deactivate&id=${p.id}'; }">
                                                             <i class="fa-solid fa-ban"></i>
                                                         </button>
                                                     </c:when>
                                                     <c:otherwise>
                                                         <button class="btn-action-view" style="color: #3f5f36; border-color: #3f5f36; background-color: #eaf1e6;" title="Kích hoạt" onclick="if(confirm('Bạn có chắc chắn muốn kích hoạt lại bánh kem ${p.name} không?')) { window.location.href='${pageContext.request.contextPath}/admin/products?action=activate&id=${p.id}'; }">
                                                             <i class="fa-solid fa-circle-check"></i>
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
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-2 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy bánh kem nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Pagination area -->
                <div class="pagination-area">
                    <span class="pagination-text">Hiển thị ${totalCount > 0 ? ((currentPage - 1) * pageSize) + 1 : 0} đến ${((currentPage - 1) * pageSize) + productList.size()} trong tổng số ${totalCount} sản phẩm</span>
                    <div class="d-flex align-items-center gap-3">
                        <ul class="pagination-nav">
                            <!-- Prev page -->
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/products?page=${currentPage - 1}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                            
                            <!-- Page Numbers -->
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-num-item ${i == currentPage ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/products?page=${i}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <!-- Next page -->
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/products?page=${currentPage + 1}&category=${category}&status=${status}&search=${search}&sortBy=${sortBy}&pageSize=${pageSize}">
                                        <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                        
                        <form action="${pageContext.request.contextPath}/admin/products" method="get" class="d-inline">
                            <input type="hidden" name="category" value="${category}">
                            <input type="hidden" name="status" value="${status}">
                            <input type="hidden" name="search" value="${search}">
                            <input type="hidden" name="sortBy" value="${sortBy}">
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

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
