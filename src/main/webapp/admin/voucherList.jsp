<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Quản lý Voucher" />
    </jsp:include>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductList.css?v=1.5">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="vouchers" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Marketing" />
            <jsp:param name="activeMenu" value="Quản lý Voucher" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý Voucher & Ưu đãi</h1>
                    <p class="page-subtitle">Xem toàn bộ danh sách mã giảm giá trên hệ thống.</p>
                </div>
            </div>

            <!-- Table Card -->
            <div class="cz-card">
                <div class="table-responsive">
                    <table class="table cz-table align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Mã Voucher</th>
                                <th>Tiêu đề</th>
                                <th>Mức giảm</th>
                                <th>Thời hạn</th>
                                <th>Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${voucherList}">
                                <tr>
                                    <td><strong>${v.voucherCode}</strong></td>
                                    <td>${v.title}</td>
                                    <td><span class="badge" style="background-color: var(--cz-primary); color: white;">${v.discountLabel}</span></td>
                                    <td>
                                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy" /> - 
                                        <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy" />
                                    </td>
                                    <td>
                                        <c:if test="${v.active}">
                                            <span class="badge bg-success">Hoạt động</span>
                                        </c:if>
                                        <c:if test="${!v.active}">
                                            <span class="badge bg-secondary">Ngừng hoạt động</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty voucherList}">
                                <tr>
                                    <td colspan="5" class="text-center py-4 text-muted">
                                        Không có dữ liệu voucher.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            
        </div>
    </div>

    <!-- Scripts -->
    <jsp:include page="/common/admin-scripts.jsp" />
</body>
</html>
