<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Shipper - Đơn hàng được phân công" />
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
        <jsp:include page="/common/top-header.jsp">
            <jsp:param name="activeMenu" value="Đơn hàng được phân công" />
        </jsp:include>

        <div class="content-container">
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Đơn hàng được phân công</h1>
                    <p class="page-subtitle" style="display: flex; align-items: center; gap: 8px; margin-top: 5px;">
                        Khu vực giao hàng phụ trách của bạn: 
                        <span class="badge" style="font-size: 13px; padding: 5px 10px; border-radius: 4px; font-weight: 700; background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; display: inline-flex; align-items: center; gap: 4px;">
                            <i class="fa-solid fa-location-dot"></i> <c:out value="${not empty managedZone ? managedZone : 'Toàn thành phố'}" />
                        </span>
                    </p>
                </div>
            </div>

            <!-- Shipper Working Status & Zone Picker -->
            <div class="cz-card" style="margin-bottom: 20px; border-left: 5px solid var(--cz-primary); padding: 20px; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
                <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="background-color: #f5f3f0; padding: 10px; border-radius: 8px; color: var(--cz-primary);">
                            <i class="fa-solid fa-truck-ramp-box" style="font-size: 24px; color: var(--cz-primary);"></i>
                        </div>
                        <div>
                            <h5 style="margin: 0; font-weight: 700; color: #333;">Trạng thái hoạt động & Khu vực làm việc</h5>
                            <p style="margin: 0; font-size: 13px; color: #666;">
                                Cập nhật trạng thái trực tuyến và khu vực giao hàng của bạn để nhận đơn tự động
                            </p>
                        </div>
                    </div>
                    
                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
                        <!-- Toggle Online/Offline -->
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="font-weight: 600; font-size: 14px;">Trạng thái:</span>
                            <div class="form-check form-switch" style="padding-left: 2.5em; margin: 0; display: inline-block;">
                                <input class="form-check-input" type="checkbox" role="switch" id="shipper-active-switch" style="width: 2.5em; height: 1.25em; cursor: pointer;" ${isActiveStaff ? 'checked' : ''}>
                                <label class="form-check-label fw-bold" for="shipper-active-switch" id="shipper-status-label" style="cursor: pointer; margin-left: 5px; font-size: 13.5px; color: ${isActiveStaff ? '#166534' : '#991b1b'};">
                                    ${isActiveStaff ? 'Trực tuyến (Online)' : 'Ngoại tuyến (Offline)'}
                                </label>
                            </div>
                        </div>

                        <!-- Zone Selector -->
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="font-weight: 600; font-size: 14px;">Khu vực:</span>
                            <select id="shipper-zone-select" class="filter-select" style="padding: 6px 12px; border-radius: 6px; font-size: 13.5px; width: 180px; border: 1px solid #ccc;" ${not isActiveStaff ? 'disabled' : ''}>
                                <option value="Zone 1" ${managedZone eq 'Zone 1' ? 'selected' : ''}>Zone 1</option>
                                <option value="Zone 2" ${managedZone eq 'Zone 2' ? 'selected' : ''}>Zone 2</option>
                                <option value="Zone 3" ${managedZone eq 'Zone 3' ? 'selected' : ''}>Zone 3</option>
                                <option value="Zone 4" ${managedZone eq 'Zone 4' ? 'selected' : ''}>Zone 4</option>
                                <option value="Zone 5" ${managedZone eq 'Zone 5' ? 'selected' : ''}>Zone 5</option>
                                <option value="Zone 6" ${managedZone eq 'Zone 6' ? 'selected' : ''}>Zone 6</option>
                                <option value="Toàn thành phố" ${managedZone eq 'Toàn thành phố' ? 'selected' : ''}>Toàn thành phố</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>

            <div class="filter-card">
                <form class="filter-form" action="${pageContext.request.contextPath}/shipper/orders" method="GET" style="display: flex; flex-direction: column; gap: 15px; align-items: stretch;">
                    <input type="hidden" name="action" value="list">
                    
                    <!-- Row 1: Search & Status Filter & Sort -->
                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap; width: 100%;">
                        <div class="search-wrapper" style="flex: 1; min-width: 280px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" class="search-input" name="search" value="<c:out value="${search}"/>" placeholder="Tìm theo mã đơn, tên hoặc SĐT khách...">
                        </div>

                        <select class="filter-select" name="status" onchange="this.form.submit()">
                            <option value="all" ${empty status || status eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="Delivering" ${status eq 'Delivering' ? 'selected' : ''}>Đang giao hàng</option>
                            <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}>Hoàn thành</option>
                            <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}>Đã hủy / Thất bại</option>
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
                        <a href="${pageContext.request.contextPath}/shipper/orders?action=list" class="btn-clear-filter text-center">Làm mới</a>
                    </div>
                </form>
            </div>

            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 120px;">Mã đơn</th>
                            <th>Khách hàng</th>
                            <th style="width: 160px;">Thời gian đặt</th>
                            <th style="width: 130px; text-align: center;">Kiểu bánh</th>
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
                                        onclick="window.location.href='${pageContext.request.contextPath}/shipper/orders?action=detail&orderNo=${o.orderNo}'"
                                    >
                                        <td class="fw-bold" style="color: var(--cz-primary);">
                                            #${o.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td>
                                            <div class="fw-bold"><c:out value="${not empty o.customerName ? o.customerName : 'Khách vãng lai'}" /></div>
                                            <div class="text-muted" style="font-size: 11px; margin-bottom: 4px;">ID: ${o.customerId}</div>
                                            <div style="font-size: 11px; color: #555; background-color: #f3f4f6; border: 1px solid #e5e7eb; padding: 2px 6px; border-radius: 4px; display: inline-block; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${o.deliveryAddress}">
                                                <i class="fa-solid fa-map-location-dot" style="color: #6b7280;"></i> <c:out value="${o.deliveryAddress}" />
                                            </div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${o.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.customCake}">
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
                                        <td style="text-align: right;" class="font-monospace admin-order-deposit">
                                            <fmt:formatNumber value="${o.depositAmount}" type="number" pattern="#,##0"/>đ
                                        </td>
                                        <td style="text-align: right;" class="fw-bold font-monospace admin-order-total" title="Giá tiền cuối phải trả">
                                            <fmt:formatNumber value="${o.totalCost}" type="number" pattern="#,##0"/>đ
                                        </td>

                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus eq 'Pending' || o.orderStatus eq 'Chờ xác nhận'}">
                                                    <span class="status-badge status-pending">Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Confirmed' || o.orderStatus eq 'Đã xác nhận'}">
                                                    <span class="status-badge status-processing">Đang làm bánh</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'PAID' || o.orderStatus eq 'Đã chuyển khoản'}">
                                                    <span class="status-badge status-confirmed" style="background-color: #d1fae5; color: #065f46;">Đã thanh toán (Duyệt gấp)</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Processing' || o.orderStatus eq 'Đang xử lý'}">
                                                    <span class="status-badge status-processing">Đang làm bánh</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Delivering' || o.orderStatus eq 'Đang giao hàng' || o.orderStatus eq 'Đang giao'}">
                                                    <span class="status-badge status-delivering">Đang giao hàng</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Completed' || o.orderStatus eq 'Hoàn thành' || o.orderStatus eq 'Đã giao'}">
                                                    <span class="status-badge status-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-cancelled">Đã hủy / Thất bại</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;" onclick="event.stopPropagation();">
                                            <a href="${pageContext.request.contextPath}/shipper/orders?action=detail&orderNo=${o.orderNo}" class="btn-action-detail" title="Chi tiết đơn hàng">
                                                Chi tiết <i class="fa-solid fa-angle-right"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-3 mb-3" style="color: #ccc;"></i>
                                        Bạn chưa được phân công đơn hàng nào phù hợp với bộ lọc.
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
                                <a href="${pageContext.request.contextPath}/shipper/orders?action=list&page=${currentPage - 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/shipper/orders?action=list&page=${i}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">${i}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <li class="page-num-item">
                                <a href="${pageContext.request.contextPath}/shipper/orders?action=list&page=${currentPage + 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
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
        document.addEventListener('DOMContentLoaded', function() {
            const activeSwitch = document.getElementById('shipper-active-switch');
            const zoneSelect = document.getElementById('shipper-zone-select');
            const statusLabel = document.getElementById('shipper-status-label');

            if (activeSwitch && zoneSelect && statusLabel) {
                function updateShipperStatusZone() {
                    const isActive = activeSwitch.checked;
                    const workingZoneId = zoneSelect.value;

                    activeSwitch.disabled = true;
                    zoneSelect.disabled = true;

                    const payload = {
                        isActive: isActive,
                        workingZoneId: workingZoneId
                    };

                    fetch('${pageContext.request.contextPath}/api/v1/shipper/status-zone', {
                        method: 'PATCH',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(payload)
                    })
                    .then(res => {
                        if (!res.ok) {
                            return res.json().then(err => { throw new Error(err.message || 'Server error'); });
                        }
                        return res.json();
                    })
                    .then(data => {
                        if (data.success) {
                            if (isActive) {
                                statusLabel.innerText = 'Trực tuyến (Online)';
                                statusLabel.style.color = '#166534';
                                zoneSelect.disabled = false;
                            } else {
                                statusLabel.innerText = 'Ngoại tuyến (Offline)';
                                statusLabel.style.color = '#991b1b';
                                zoneSelect.disabled = true;
                            }
                            alert("Cập nhật trạng thái hoạt động thành công!");
                            window.location.reload();
                        } else {
                            alert("Lỗi: " + data.message);
                            window.location.reload();
                        }
                    })
                    .catch(err => {
                        console.error("Error updating shipper status/zone:", err);
                        alert("Lỗi kết nối hoặc phân quyền: " + err.message);
                        window.location.reload();
                    })
                    .finally(() => {
                        activeSwitch.disabled = false;
                    });
                }

                activeSwitch.addEventListener('change', updateShipperStatusZone);
                zoneSelect.addEventListener('change', updateShipperStatusZone);
            }
        });
    </script>
</body>
</html>
