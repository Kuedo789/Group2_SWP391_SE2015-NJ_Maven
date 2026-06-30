<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (application.getAttribute("settings") == null) {
        com.bakeryzone.dao.SettingDAO settingDAO = new com.bakeryzone.dao.SettingDAO();
        java.util.Map<String, Object> dbSettings = settingDAO.getSettings();
        if (dbSettings == null || dbSettings.isEmpty()) {
            dbSettings = new java.util.HashMap<>();
            dbSettings.put("bakeryName", "BakeryZone");
            dbSettings.put("hotline", "0901234567");
            dbSettings.put("email", "support@bakeryzone.vn");
            dbSettings.put("address", "123 Đường Sourdough, TP. Hồ Chí Minh");
            dbSettings.put("announcement", "Chào mừng bạn đến với BakeryZone - Thế giới bánh ngọt tinh tế!");
            dbSettings.put("banner1", "assets/images/banner1.jpg");
            dbSettings.put("banner2", "assets/images/banner2.jpg");
            dbSettings.put("banner3", "assets/images/banner3.jpg");
            dbSettings.put("banner4", "assets/images/hero/hero-4.jpg");
            dbSettings.put("darkMode", false);
        } else {
            String currentHotline = (String) dbSettings.get("hotline");
            if (currentHotline != null) {
                dbSettings.put("hotline", currentHotline.replaceAll("\\s+", ""));
            }
        }
        application.setAttribute("settings", dbSettings);
    }
%>

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
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="margin-bottom: 20px; border-radius: 12px; font-weight: 500;">
                    <i class="fa-solid fa-triangle-exclamation" style="margin-right: 8px;"></i>
                    <c:out value="${errorMessage}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Quản lý đơn hàng</h1>
                    <p class="page-subtitle">Hệ thống theo dõi đơn đặt bánh, cập nhật trạng thái chế biến và giao hàng</p>
                </div>
            </div>

            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/admin/orders" method="GET">
                    <input type="hidden" name="action" value="list">
                    
                    <div class="search-wrapper">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" class="search-input" name="search" value="<c:out value="${search}"/>" placeholder="Tìm kiếm theo mã đơn, tên hoặc SĐT khách...">
                    </div>

                    <select class="filter-select" name="status" onchange="this.form.submit()">
                        <option value="all" ${empty status || status eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                        <option value="Pending" ${status eq 'Pending' ? 'selected' : ''}>Chờ xác nhận</option>
                        <option value="Confirmed" ${status eq 'Confirmed' ? 'selected' : ''}>Đã xác nhận</option>
                        <option value="Processing" ${status eq 'Processing' ? 'selected' : ''}>Đang xử lý</option>
                        <option value="Delivering" ${status eq 'Delivering' ? 'selected' : ''}>Đang giao</option>
                        <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                        <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>Đã hủy</option>
                    </select>

                    <select class="filter-select" name="sort" onchange="this.form.submit()">
                        <option value="date_desc" ${empty sort || sort eq 'date_desc' ? 'selected' : ''}>Mới nhất xếp trước</option>
                        <option value="date_asc" ${sort eq 'date_asc' ? 'selected' : ''}>Cũ nhất xếp trước</option>
                        <option value="price_desc" ${sort eq 'price_desc' ? 'selected' : ''}>Tổng tiền giảm dần</option>
                        <option value="price_asc" ${sort eq 'price_asc' ? 'selected' : ''}>Tổng tiền tăng dần</option>
                    </select>

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
                </form>
            </div>

            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 120px;">Mã đơn</th>
                            <th>Khách hàng</th>
                            <th style="width: 160px;">Thời gian đặt</th>
                            <th style="width: 150px; text-align: right;">Tiền cọc</th>
                            <th style="width: 150px; text-align: right;">Tổng cộng</th>
                            <th style="width: 150px; text-align: center;">Trạng thái</th>
                            <th style="width: 120px; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach items="${orders}" var="o">
                                    <tr class="clickable-row"
                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/orders?action=detail&orderNo=${o.orderNo}'"
                                    >
                                        <td class="fw-bold" style="color: var(--cz-primary);">
                                            #${o.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td>
                                            <div class="fw-bold"><c:out value="${not empty o.customerName ? o.customerName : 'Khách vãng lai'}" /></div>
                                            <div class="text-muted" style="font-size: 12px;">ID: ${o.customerId}</div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${o.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>

                                        <td style="text-align: right;" class="font-monospace admin-order-deposit">
                                            <fmt:formatNumber value="${o.depositAmount}" type="number" pattern="#,##0"/>đ
                                        </td>
                                        <td style="text-align: right;" class="fw-bold font-monospace admin-order-total">
                                            <fmt:formatNumber value="${o.totalCost}" type="number" pattern="#,##0"/>đ
                                        </td>

                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus eq 'Pending' || o.orderStatus eq 'Chờ xác nhận'}">
                                                    <span class="status-badge status-pending">Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Confirmed' || o.orderStatus eq 'Đã xác nhận'}">
                                                    <span class="status-badge status-confirmed">Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Processing' || o.orderStatus eq 'Đang xử lý'}">
                                                    <span class="status-badge status-processing">Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Delivering' || o.orderStatus eq 'Đang giao hàng' || o.orderStatus eq 'Đang giao'}">
                                                    <span class="status-badge status-delivering">Đang giao</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Completed' || o.orderStatus eq 'Hoàn thành' || o.orderStatus eq 'Đã giao'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-cancelled">Đã hủy</span>
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
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <script>
        <c:if test="${not empty sessionScope.successMessage}">
            Toastify({
                text: "${sessionScope.successMessage}",
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: "linear-gradient(to right, #3f5f36, #5c8350)",
                stopOnFocus: true
            }).showToast();
            <c:remove var="successMessage" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMessage}">
            Toastify({
                text: "${sessionScope.errorMessage}",
                duration: 4000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: "linear-gradient(to right, #ff5f6d, #ffc371)",
                stopOnFocus: true
            }).showToast();
            <c:remove var="errorMessage" scope="session" />
        </c:if>
    </script>
</body>
</html>
