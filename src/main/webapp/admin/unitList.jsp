<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Đơn vị tính</title>
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
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="#">Bảng điều khiển</a>
                    <span>&gt;</span>
                    <a href="#">Cấu hình</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Đơn vị tính</a>
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
                  <div class="alert alert-success alert-dismissible fade show" role="alert" style="border-radius: 8px; font-weight: 500;">
                      <i class="fa-solid fa-circle-check me-2"></i> 
                      <c:choose>
                          <c:when test="${param.msg eq 'add_success'}">Đã thêm mới đơn vị tính thành công!</c:when>
                          <c:when test="${param.msg eq 'edit_success'}">Đã cập nhật đơn vị tính thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_success'}">Đã xóa đơn vị tính thành công!</c:when>
                          <c:when test="${param.msg eq 'delete_error'}">Xóa thất bại! Đơn vị tính này hiện đang được liên kết trong bảng nguyên liệu.</c:when>
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
                <a href="${pageContext.request.contextPath}/admin/unit?action=create" class="btn btn-cz-primary">
                    <i class="fa-solid fa-circle-plus"></i> Thêm đơn vị tính
                </a>
            </div>

            <!-- Table Card -->
            <div class="table-card">
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 80px;">STT</th>
                                <th style="width: 150px;">Mã đơn vị (ID)</th>
                                <th style="width: 250px;">Tên đơn vị</th>
                                <th>Mô tả chi tiết</th>
                                <th style="width: 150px;" class="text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty unitList}">
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-4">Chưa có đơn vị tính nào trong hệ thống.</td>
                                </tr>
                            </c:if>
                            <c:forEach var="u" items="${unitList}" varStatus="status">
                                <tr>
                                    <td>${status.index + 1}</td>
                                    <td><span class="badge bg-secondary" style="font-size: 13px; font-weight: 600; padding: 6px 12px; background-color: #64748b !important;">${u.unitId}</span></td>
                                    <td><strong>${u.unitName}</strong></td>
                                    <td>${u.description}</td>
                                    <td>
                                        <div class="actions-cell justify-content-center">
                                            <a href="${pageContext.request.contextPath}/admin/unit?action=edit&id=${u.unitId}" class="btn-action-edit me-2" title="Chỉnh sửa">
                                                <i class="fa-regular fa-pen-to-square"></i>
                                            </a>
                                            <button type="button" class="btn-action-delete" title="Xóa" onclick="confirmDelete('${u.unitId}')">
                                                <i class="fa-regular fa-trash-can"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden form for deleting -->
    <form id="deleteForm" action="${pageContext.request.contextPath}/admin/unit?action=delete" method="post" style="display: none;">
        <input type="hidden" name="id" id="deleteId">
    </form>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function confirmDelete(id) {
            if (confirm('Bạn có chắc chắn muốn xóa đơn vị tính "' + id + '" không?\nLưu ý: Bạn không thể xóa nếu có nguyên liệu đang sử dụng đơn vị này.')) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteForm').submit();
            }
        }
    </script>
</body>
</html>
