<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Quản lý đơn hàng" />
    </jsp:include>
    <!-- Order Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <div class="main-panel">
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="activeMenu" value="Quản lý đơn hàng" />
        </jsp:include>

        <div class="content-container">
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý đơn hàng</h1>
                    <p class="page-subtitle">Hệ thống theo dõi đơn đặt bánh, cập nhật trạng thái chế biến và giao hàng</p>
                </div>
            </div>

            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/orders" method="GET" style="display: flex; flex-direction: column; gap: 15px; align-items: stretch;">
                    <input type="hidden" name="action" value="list">
                    
                    <!-- Row 1: Search & Status Filter & Sort -->
                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap; width: 100%;">
                        <div class="search-wrapper" style="flex: 1; min-width: 280px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" class="search-input" name="search" value="<c:out value="${search}"/>" placeholder="Tìm kiếm theo mã đơn, tên hoặc SĐT khách...">
                        </div>

                        <select class="filter-select" name="status" onchange="this.form.submit()">
                            <option value="all" ${empty status || status eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="Waiting_Payment" ${status eq 'Waiting_Payment' ? 'selected' : ''}>Chờ thanh toán</option>
                            <option value="PAID" ${status eq 'PAID' ? 'selected' : ''}>Đã thanh toán</option>
                            <option value="Processing" ${status eq 'Processing' ? 'selected' : ''}>Đang làm bánh</option>
                            <option value="Waiting_Delivery" ${status eq 'Waiting_Delivery' ? 'selected' : ''}>Chờ giao hàng</option>
                            <option value="Delivering" ${status eq 'Delivering' ? 'selected' : ''}>Đang giao hàng</option>
                            <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                            <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                        </select>

                        <select class="filter-select" name="cakeType" onchange="this.form.submit()">
                            <option value="all" ${empty cakeType || cakeType eq 'all' ? 'selected' : ''}>Tất cả loại bánh</option>
                            <option value="template" ${cakeType eq 'template' ? 'selected' : ''}>Bánh có sẵn</option>
                            <option value="custom" ${cakeType eq 'custom' ? 'selected' : ''}>Bánh thiết kế</option>
                        </select>

                        <select class="filter-select" name="sort" onchange="this.form.submit()">
                            <option value="date_desc" ${empty sort || sort eq 'date_desc' ? 'selected' : ''}>Mới nhất xếp trước</option>
                            <option value="date_asc" ${sort eq 'date_asc' ? 'selected' : ''}>Cũ nhất xếp trước</option>
                            <option value="price_desc" ${sort eq 'price_desc' ? 'selected' : ''}>Tổng tiền giảm dần</option>
                            <option value="price_asc" ${sort eq 'price_asc' ? 'selected' : ''}>Tổng tiền tăng dần</option>
                        </select>
                    </div>

                    <!-- Row 2: Date Filters & Action Buttons -->
                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap; width: 100%;">
                        <div class="date-container">
                            <span class="date-label">Từ:</span>
                            <input type="date" class="filter-date" name="startDate" value="${startDate}">
                        </div>

                        <div class="date-container">
                            <span class="date-label">Đến:</span>
                            <input type="date" class="filter-date" name="endDate" value="${endDate}">
                        </div>

                        <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                        <a href="${pageContext.request.contextPath}/admin/orders?action=list" class="btn-clear-filter text-center">Làm mới</a>
                    </div>
                </form>
            </div>

            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 13%; text-align: left;">Mã đơn</th>
                            <th style="width: 23%; text-align: left;">Khách hàng</th>
                            <th style="width: 17%; text-align: center;">Thời gian đặt</th>
                            <th style="width: 14%; text-align: center;">Kiểu bánh</th>
                            <th style="width: 16%; text-align: right;">Tổng cộng</th>
                            <th style="width: 15%; text-align: center;">Trạng thái</th>
                            <th style="width: 12%; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach items="${orders}" var="o">
                                    <tr class="clickable-row"
                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/orders?action=detail&orderNo=${o.orderNo}'"
                                    >
                                        <td class="fw-bold" style="color: var(--cz-primary); text-align: left;">
                                            #${o.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td style="text-align: left;">
                                            <div class="fw-bold"><c:out value="${not empty o.customerName ? o.customerName : 'Khách vãng lai'}" /></div>
                                            <div class="text-muted" style="font-size: 12px;">ID: ${o.customerId}</div>
                                        </td>
                                        <td style="text-align: center;">
                                            <fmt:formatDate value="${o.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.cakeTypeLabel eq 'Hỗn hợp'}">
                                                    <%-- Đơn hỗn hợp: vừa có bánh có sẵn (TPL) vừa có bánh thiết kế (CC) --%>
                                                    <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
                                                        <span class="badge" style="background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-weight: 700; padding: 3px 8px; border-radius: 8px; font-size: 11px; width: fit-content;">
                                                            <i class="fa-solid fa-store me-1"></i>Có sẵn
                                                        </span>
                                                        <span class="badge" style="background-color: #f3e8ff; color: #7e22ce; border: 1px solid #e9d5ff; font-weight: 700; padding: 3px 8px; border-radius: 8px; font-size: 11px; width: fit-content;">
                                                            <i class="fa-solid fa-wand-magic-sparkles me-1"></i>Thiết kế
                                                        </span>
                                                    </div>
                                                </c:when>
                                                <c:when test="${o.cakeTypeLabel eq 'Thiết kế'}">
                                                    <span class="badge" style="background-color: #f3e8ff; color: #7e22ce; border: 1px solid #e9d5ff; font-weight: 700; padding: 4px 10px; border-radius: 8px; font-size: 11.5px;">
                                                        <i class="fa-solid fa-wand-magic-sparkles me-1"></i>Thiết kế
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-weight: 700; padding: 4px 10px; border-radius: 8px; font-size: 11.5px;">
                                                        <i class="fa-solid fa-store me-1"></i>Có sẵn
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td style="text-align: right;" class="fw-bold font-monospace admin-order-total" title="Số tiền thu cuối (sau cọc/giảm giá)">
                                            <c:choose>
                                                <c:when test="${not empty o.remainingCodBalance}">
                                                    <fmt:formatNumber value="${o.remainingCodBalance}" type="number" pattern="#,##0"/>đ
                                                </c:when>
                                                <c:when test="${not empty o.totalCost}">
                                                    <fmt:formatNumber value="${o.totalCost}" type="number" pattern="#,##0"/>đ
                                                </c:when>
                                                <c:otherwise>0đ</c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus eq 'Waiting_Payment'}">
                                                    <span class="status-badge status-pending" style="background-color: #fef08a; color: #854d0e;">Chờ thanh toán</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'PAID'}">
                                                    <span class="status-badge status-confirmed" style="background-color: #d1fae5; color: #065f46;">Đã thanh toán</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Processing'}">
                                                    <span class="status-badge status-processing">Đang làm bánh</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Waiting_Delivery'}">
                                                    <span class="status-badge status-pending" style="background-color: #fef08a; color: #854d0e;">Chờ giao hàng</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Delivering'}">
                                                    <span class="status-badge status-delivering">Đang giao hàng</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Completed'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">Đã hủy</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-pending">${o.orderStatus}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;" onclick="event.stopPropagation();">
                                            <a href="${pageContext.request.contextPath}/admin/orders?action=detail&orderNo=${o.orderNo}" class="btn-action-detail" title="Chi tiết đơn hàng">
                                                Chi tiết <i class="fa-solid fa-angle-right"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-3 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy đơn hàng nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <div class="pagination-area">
                    <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang (${totalRecords} đơn hàng)</span>
                    <ul class="pagination-nav">
                        <c:if test="${currentPage > 1}">
                            <li class="page-num-item">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${currentPage - 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${i}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">${i}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <li class="page-num-item">
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list&page=${currentPage + 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
                                    <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>
                    </ul>
                </div>   
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const filterForm = document.querySelector('.filter-form');
            if (filterForm) {
                filterForm.addEventListener('submit', function(e) {
                    const startInput = filterForm.querySelector('input[name="startDate"]');
                    const endInput = filterForm.querySelector('input[name="endDate"]');
                    if (startInput && endInput) {
                        const startVal = startInput.value;
                        const endVal = endInput.value;
                        if (startVal && endVal) {
                            const start = new Date(startVal);
                            const end = new Date(endVal);
                            if (start > end) {
                                e.preventDefault();
                                alert("Ngày bắt đầu không được lớn hơn Ngày kết thúc!");
                                return false;
                            }
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>
