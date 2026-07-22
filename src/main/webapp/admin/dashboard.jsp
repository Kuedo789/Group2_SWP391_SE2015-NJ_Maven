<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Dashboard" />
    </jsp:include>
    <!-- Dashboard Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/admindashbroad.css?v=1.8" rel="stylesheet">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="activeMenu" value="Tổng quan hệ thống" />
        </jsp:include>

        <!-- Dashboard Content -->
        <div class="content">
            
            <!-- Page Title Area -->
            <div class="page-header dashboard-page-header">
                <div class="page-title">
                    <c:choose>
                        <c:when test="${sessionScope.user.roleId eq 'STAFF'}">
                            <h2>Bảng điều khiển <span class="badge dashboard-badge-staff">NHÂN VIÊN (STAFF)</span></h2>
                            <p>Theo dõi đơn hàng cần chế biến, mẫu bánh và các công việc tại xưởng bếp tiệm bánh.</p>
                        </c:when>
                        <c:when test="${sessionScope.user.roleId eq 'SHIPPER'}">
                            <h2>Bảng điều khiển <span class="badge dashboard-badge-shipper">SHIPPER</span></h2>
                            <p>Quản lý danh sách đơn giao theo khu vực phụ trách: <strong style="color: var(--cz-primary);"><c:out value="${not empty shipperManagedZone ? shipperManagedZone : 'Toàn thành phố'}" /></strong></p>
                        </c:when>
                        <c:otherwise>
                            <h2>Bảng điều khiển <span class="badge dashboard-badge-admin">ADMIN</span></h2>
                            <p>Xem báo cáo doanh thu, đơn hàng gần đây và quản lý hoạt động tiệm bánh.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <c:choose>
                    <c:when test="${sessionScope.user.roleId eq 'STAFF'}">
                        <a href="${pageContext.request.contextPath}/admin/orders?action=list&status=Pending" class="stat-card stat-orders" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-clock"></i></div>
                            <div class="stat-info">
                                <div class="stat-label"><span>Đơn chờ duyệt</span></div>
                                <div class="stat-value">${pendingCount}</div>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/orders?action=list&status=Processing" class="stat-card stat-revenue" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-fire-burner"></i></div>
                            <div class="stat-info">
                                <div class="stat-label"><span>Đơn đang chế biến</span></div>
                                <div class="stat-value">${processingCount}</div>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/product?action=list" class="stat-card stat-products" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-cake-candles"></i></div>
                            <div class="stat-info">
                                <div class="stat-label"><span>Mẫu bánh</span></div>
                                <div class="stat-value">${totalProducts}</div>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/ingredient?action=list" class="stat-card stat-customers" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-boxes-stacked"></i></div>
                            <div class="stat-info">
                                <div class="stat-label"><span>Tổng nguyên liệu</span></div>
                                <div class="stat-value">${totalIngredients}</div>
                            </div>
                        </a>
                    </c:when>
                    <c:when test="${sessionScope.user.roleId eq 'SHIPPER'}">
                        <!-- Các thẻ thống kê Shipper được hiển thị ở bố cục bên dưới -->
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/admin/orders?action=list&status=Completed" class="stat-card stat-revenue" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-money-bill-trend-up"></i></div>
                            <div class="stat-info">
                                <div class="stat-label">
                                    <span>Tổng doanh thu</span>
                                    <c:choose>
                                        <c:when test="${revChangePct >= 0}">
                                            <span class="stat-trend trend-up">+<fmt:formatNumber value="${revChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-up"></i></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="stat-trend trend-down"><fmt:formatNumber value="${revChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-down"></i></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="stat-value">
                                    <fmt:formatNumber value="${totalRevenue}" type="number" pattern="#,##0"/>đ
                                </div>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/orders?action=list" class="stat-card stat-orders" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                            <div class="stat-info">
                                <div class="stat-label">
                                    <span>Đơn hàng</span>
                                    <c:choose>
                                        <c:when test="${ordChangePct >= 0}">
                                            <span class="stat-trend trend-up">+<fmt:formatNumber value="${ordChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-up"></i></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="stat-trend trend-down"><fmt:formatNumber value="${ordChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-down"></i></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="stat-value">${totalOrders}</div>
                            </div>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/customer?action=list" class="stat-card stat-customers" style="text-decoration: none; color: inherit;">
                            <div class="stat-icon"><i class="fa-solid fa-users"></i></div>
                            <div class="stat-info">
                                <div class="stat-label">
                                    <span>Khách hàng</span>
                                    <c:choose>
                                        <c:when test="${custChangePct >= 0}">
                                            <span class="stat-trend trend-up">+<fmt:formatNumber value="${custChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-up"></i></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="stat-trend trend-down"><fmt:formatNumber value="${custChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-down"></i></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="stat-value">${totalCustomers}</div>
                            </div>
                        </a>
                        <div class="stat-card stat-products" style="text-decoration: none; color: inherit; cursor: default;">
                            <div class="stat-icon" style="background-color: #dcfce7; color: #15803d;"><i class="fa-solid fa-sack-dollar"></i></div>
                            <div class="stat-info">
                                <div class="stat-label">
                                    <span>Tổng lợi nhuận</span>
                                    <c:choose>
                                        <c:when test="${profitChangePct >= 0}">
                                            <span class="stat-trend trend-up">+<fmt:formatNumber value="${profitChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-up"></i></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="stat-trend trend-down"><fmt:formatNumber value="${profitChangePct}" pattern="#.#"/>% <i class="fa-solid fa-arrow-trend-down"></i></span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="stat-value">
                                    <fmt:formatNumber value="${totalProfit != null ? totalProfit : 0}" type="number" pattern="#,##0"/>đ
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Dòng Biểu đồ & Thao tác chính -->
            <div class="charts-row">
                <c:choose>
                    <c:when test="${sessionScope.user.roleId eq 'STAFF'}">
                        <!-- NHÂN VIÊN: Hàng đợi chế biến bếp toàn màn hình (Giao diện KDS xưởng bếp) -->
                        <div class="kitchen-queue-container w-100" style="grid-column: 1 / -1; margin-bottom:0;">
                            <!-- Tiêu đề hàng đợi bếp -->
                            <div class="kitchen-queue-header">
                                <div class="kitchen-title">
                                    <i class="fa-solid fa-fire-burner"></i> Hàng Đợi Chế Biến
                                    <span class="kitchen-badge-live">CẬP NHẬT TRỰC TIẾP</span>
                                    <span class="kitchen-badge-count">${processingCount} ĐƠN ĐANG THỰC HIỆN</span>
                                </div>
                            </div>

                            <!-- SECTION: ĐANG THỰC HIỆN CA LÀM -->
                            <div class="kitchen-section-label">
                                <i class="fa-solid fa-rotate-right fa-spin me-1"></i> ĐANG THỰC HIỆN CA LÀM
                            </div>
                            
                            <div class="kitchen-card-grid" style="grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));">
                                <c:choose>
                                    <c:when test="${not empty processingOrders}">
                                        <c:forEach var="pOrd" items="${processingOrders}">
                                            <div class="kitchen-order-card">
                                                <div>
                                                    <div class="kitchen-card-top">
                                                        <div>
                                                            <div class="kitchen-order-no">#${pOrd.orderNo}</div>
                                                            <div class="kitchen-pickup-time">
                                                                Giao/Lấy: <fmt:formatDate value="${pOrd.deliveryWindowStart}" pattern="HH:mm"/>
                                                            </div>
                                                        </div>
                                                        <span class="kitchen-status-badge">Đang chế biến</span>
                                                    </div>

                                                    <div class="kitchen-items-list">
                                                        <c:choose>
                                                            <c:when test="${not empty pOrd.items}">
                                                                <c:forEach var="itm" items="${pOrd.items}">
                                                                    <div class="kitchen-item-row">
                                                                        <span><strong class="kitchen-item-qty">${itm.quantity}x</strong> <c:out value="${itm.itemName}"/></span>
                                                                        <span class="kitchen-item-status">Đang làm</span>
                                                                    </div>
                                                                </c:forEach>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="kitchen-item-row">
                                                                    <span><strong class="kitchen-item-qty">1x</strong> Bánh sinh nhật trang trí</span>
                                                                    <span class="kitchen-item-status">Đang nướng</span>
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>

                                                <div class="mt-3">
                                                    <form action="${pageContext.request.contextPath}/admin/orders" method="POST">
                                                        <input type="hidden" name="action" value="update-status" />
                                                        <input type="hidden" name="orderNo" value="${pOrd.orderNo}" />
                                                        <input type="hidden" name="status" value="Ready" />
                                                        <button type="submit" class="kitchen-btn-finish">
                                                            <i class="fa-solid fa-circle-check me-1"></i> HOÀN THÀNH MẺ BÁNH
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="kitchen-order-card text-center py-4" style="grid-column: 1 / -1;">
                                            <div class="text-muted"><i class="fa-solid fa-cookie me-1"></i> Chưa có đơn hàng nào đang thực hiện.</div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:when>

                    <c:when test="${sessionScope.user.roleId eq 'SHIPPER'}">
                        <!-- BỐ CỤC CHÍNH BẢNG ĐIỀU KHIỂN SHIPPER KHỚP THIẾT KẾ MẪU -->
                        <div class="w-100" style="grid-column: 1 / -1;">
                            
                            <!-- LƯỚI PHÂN CHIA SHIPPER (8 Cột Trái, 4 Cột Phải) -->
                            <div class="row g-3 mb-4">
                                <!-- BÊN TRÁI: CÁC THẺ THỐNG KÊ + DOANH THU HÔM NAY (8 Cột) -->
                                <div class="col-lg-8 col-md-12 d-flex flex-column gap-3">
                                    <!-- Hàng 2 Thẻ thống kê (Độ rộng 8 cột) -->
                                    <div class="row g-3">
                                        <div class="col-md-6 col-sm-6 col-12">
                                            <a href="${pageContext.request.contextPath}/shipper/orders?action=list&status=Delivering" class="text-decoration-none">
                                                <div class="card border-0 shadow-sm p-4 h-100" style="border-radius: 20px; background-color: #ffffff; transition: transform 0.2s ease, box-shadow 0.2s ease;">
                                                    <div class="d-flex align-items-center gap-3">
                                                        <div class="d-flex align-items-center justify-content-center flex-shrink-0" style="width: 64px; height: 64px; border-radius: 18px; background-color: #fff1e6; color: #c88636;">
                                                            <i class="fa-solid fa-clipboard-list" style="font-size: 26px;"></i>
                                                        </div>
                                                        <div class="ms-1">
                                                            <div style="font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.6px;">ĐƠN HÀNG CHỜ GIAO</div>
                                                            <div style="font-size: 36px; font-weight: 800; color: #1e293b; line-height: 1.1; margin-top: 4px;">
                                                                <c:out value="${not empty deliveringCount ? deliveringCount : 0}"/>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>

                                        <div class="col-md-6 col-sm-6 col-12">
                                            <a href="${pageContext.request.contextPath}/shipper/orders?action=list&status=Completed" class="text-decoration-none">
                                                <div class="card border-0 shadow-sm p-4 h-100" style="border-radius: 20px; background-color: #ffffff; transition: transform 0.2s ease, box-shadow 0.2s ease;">
                                                    <div class="d-flex align-items-center gap-3">
                                                        <div class="d-flex align-items-center justify-content-center flex-shrink-0" style="width: 64px; height: 64px; border-radius: 18px; background-color: #eaf4ec; color: #2d5a37;">
                                                            <i class="fa-solid fa-circle-check" style="font-size: 26px;"></i>
                                                        </div>
                                                        <div class="ms-1">
                                                            <div style="font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.6px;">ĐÃ GIAO THÀNH CÔNG</div>
                                                            <div style="font-size: 36px; font-weight: 800; color: #1e293b; line-height: 1.1; margin-top: 4px;">
                                                                <c:out value="${not empty completedCount ? completedCount : 0}"/>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </div>

                                    <!-- Thẻ Doanh thu hôm nay (VNĐ) (Độ rộng 8 cột) -->
                                    <div class="card border-0 shadow-sm flex-grow-1" style="border-radius: 16px; background-color: #ffffff; overflow: hidden;">
                                        <div class="card-body p-4 d-flex flex-column justify-content-between">
                                            <div>
                                                <div class="d-flex align-items-center justify-content-between mb-4">
                                                    <h5 class="fw-bold text-dark m-0 d-flex align-items-center gap-2" style="font-size: 18px;">
                                                        <i class="fa-solid fa-chart-line" style="color: #162e21;"></i> Doanh thu hôm nay (VNĐ)
                                                    </h5>
                                                    <a href="${pageContext.request.contextPath}/shipper/orders?action=list&status=Completed" style="font-size: 13px; font-weight: 600; color: #475569; text-decoration: none;">
                                                        Xem tất cả
                                                    </a>
                                                </div>

                                                <!-- Khung hiển thị nổi bật màu tối -->
                                                <div class="p-4 mb-3 text-white" style="border-radius: 14px; background: linear-gradient(135deg, #162e21 0%, #1a3828 100%); position: relative; overflow: hidden;">
                                                    <div style="font-size: 32px; font-weight: 800; letter-spacing: -0.5px;">
                                                        <fmt:formatNumber value="${not empty dailyStats.todayRevenue ? dailyStats.todayRevenue : 0}" type="number" pattern="#,##0"/>đ
                                                    </div>
                                                    <div class="mt-2 d-flex align-items-center gap-2">
                                                        <c:choose>
                                                            <c:when test="${dailyStats.revDiffPercent >= 0}">
                                                                <span class="badge" style="background-color: rgba(34, 197, 94, 0.2); color: #4ade80; font-weight: 700; font-size: 12.5px; padding: 5px 12px; border-radius: 20px;">
                                                                    <i class="fa-solid fa-arrow-trend-up me-1"></i>+<fmt:formatNumber value="${dailyStats.revDiffPercent}" pattern="#,##0.0"/>% so với hôm qua
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge" style="background-color: rgba(239, 68, 68, 0.2); color: #f87171; font-weight: 700; font-size: 12.5px; padding: 5px 12px; border-radius: 20px;">
                                                                    <i class="fa-solid fa-arrow-trend-down me-1"></i><fmt:formatNumber value="${dailyStats.revDiffPercent}" pattern="#,##0.0"/>% so với hôm qua
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Thanh tổng kết tình hình giao hàng phía dưới -->
                                            <div class="p-3 d-flex align-items-center justify-content-between" style="background-color: #f0f7ff; border-radius: 12px;">
                                                <span style="font-size: 14px; font-weight: 600; color: #334155;">Số lượt giao thành công</span>
                                                <strong style="font-size: 17px; font-weight: 800; color: #0f172a;">
                                                    <c:out value="${not empty dailyStats.todayDeliveriesCount ? dailyStats.todayDeliveriesCount : 0}"/> đơn
                                                </strong>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- BÊN PHẢI: LỊCH SỬ GIAO HÀNG (4 Cột bên trên góc phải) -->
                                <div class="col-lg-4 col-md-12">
                                    <div class="card border-0 shadow-sm h-100" style="border-radius: 16px; background-color: #ffffff;">
                                        <div class="card-body p-4">
                                            <div class="d-flex align-items-center justify-content-between mb-4">
                                                <h5 class="fw-bold text-dark m-0 d-flex align-items-center gap-2" style="font-size: 18px;">
                                                    <i class="fa-solid fa-clock-rotate-left" style="color: #162e21;"></i> Lịch sử giao
                                                </h5>
                                                <a href="${pageContext.request.contextPath}/shipper/orders?action=list&status=Completed" style="font-size: 13px; font-weight: 600; color: #475569; text-decoration: none;">
                                                    Tất cả
                                                </a>
                                            </div>

                                            <div class="delivered-list-wrapper">
                                                <c:choose>
                                                    <c:when test="${not empty deliveredOrders}">
                                                        <c:forEach items="${deliveredOrders}" var="doItem">
                                                            <div class="py-2.5 mb-2 border-bottom" onclick="window.location.href='${pageContext.request.contextPath}/shipper/orders?action=detail&orderNo=${doItem.orderNo}'" style="cursor: pointer;">
                                                                <div class="d-flex align-items-center justify-content-between">
                                                                    <div style="min-width: 0; flex: 1; padding-right: 10px;">
                                                                        <div style="font-weight: 800; color: #0f172a; font-size: 14px;">#${doItem.orderNo.replace("ORD_", "")}</div>
                                                                        <div style="font-size: 11.5px; color: #64748b; margin-top: 2px;" class="text-truncate" title="${doItem.deliveryAddress}">
                                                                            <c:out value="${doItem.deliveryAddress}" />
                                                                        </div>
                                                                    </div>
                                                                    <div class="text-end" style="white-space: nowrap;">
                                                                        <div style="font-size: 13.5px; font-weight: 800; color: #0f172a;">
                                                                            <fmt:formatNumber value="${doItem.totalCost}" type="number" pattern="#,##0"/>đ
                                                                        </div>
                                                                        <span class="badge" style="font-size: 10px; background-color: #dcfce7; color: #15803d; font-weight: 700; padding: 3px 8px; border-radius: 10px;">
                                                                            Đã giao
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="text-center py-4 text-muted" style="font-size: 13px;">
                                                            Chưa có đơn hàng nào được giao gần đây.
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 3. THẺ THỐNG KÊ BÊN DƯỚI TOÀN MÀN HÌNH (Đơn hàng sẵn sàng) -->
                            <div class="card border-0 shadow-sm mb-4" style="border-radius: 16px; background-color: #ffffff; overflow: hidden;">
                                <div class="card-body p-4">
                                    <!-- Tiêu đề & Thanh tìm kiếm -->
                                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
                                        <h5 class="fw-bold text-dark m-0 d-flex align-items-center gap-2" style="font-size: 18px;">
                                            <i class="fa-solid fa-truck" style="color: #162e21;"></i> Đơn hàng sẵn sàng
                                        </h5>
                                        <div style="position: relative; width: 280px;">
                                            <i class="fa-solid fa-magnifying-glass" style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #94a3b8; font-size: 13px;"></i>
                                            <input type="text" id="shipperReadyOrderSearch" class="form-control form-control-sm" placeholder="Tìm mã đơn..." style="padding-left: 36px; border-radius: 20px; border: 1px solid #cbd5e1; font-size: 13px; height: 38px;">
                                        </div>
                                    </div>

                                    <!-- Bảng danh sách đơn hàng -->
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0" id="readyOrdersTable" style="font-size: 13.5px;">
                                            <thead style="background-color: #f8fafc; color: #475569; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px;">
                                                <tr>
                                                    <th class="py-3 ps-3" style="font-weight: 700; width: 110px;">MÃ ĐƠN</th>
                                                    <th class="py-3" style="font-weight: 700;">KHÁCH HÀNG</th>
                                                    <th class="py-3" style="font-weight: 700;">ĐỊA CHỈ GIAO HÀNG</th>
                                                    <th class="py-3" style="font-weight: 700; width: 140px;">GIÁ TIỀN</th>
                                                    <th class="py-3 text-center" style="font-weight: 700; width: 130px;">TRẠNG THÁI</th>
                                                    <th class="py-3 text-center" style="font-weight: 700; width: 140px;">THAO TÁC</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:choose>
                                                    <c:when test="${not empty readyOrders}">
                                                        <c:forEach items="${readyOrders}" var="ro">
                                                            <tr onclick="window.location.href='${pageContext.request.contextPath}/shipper/orders?action=detail&orderNo=${ro.orderNo}'" style="cursor: pointer;">
                                                                <td class="ps-3 fw-bold" style="color: #0f172a;">
                                                                    #${ro.orderNo.replace("ORD_", "")}
                                                                </td>
                                                                <td>
                                                                    <div class="d-flex align-items-center gap-2">
                                                                        <div class="d-flex align-items-center justify-content-center rounded-circle fw-bold" style="width: 32px; height: 32px; background-color: #e2e8f0; color: #334155; font-size: 11px; text-transform: uppercase;">
                                                                            <c:out value="${not empty ro.customerName ? ro.customerName.substring(0, 1).toUpperCase() : 'K'}" />
                                                                        </div>
                                                                        <span class="fw-bold text-dark"><c:out value="${not empty ro.customerName ? ro.customerName : 'Khách hàng'}" /></span>
                                                                    </div>
                                                                </td>
                                                                <td style="color: #475569;" class="text-truncate" title="${ro.deliveryAddress}">
                                                                    <c:out value="${ro.deliveryAddress}" />
                                                                </td>
                                                                <td class="fw-bold text-dark font-monospace">
                                                                    <fmt:formatNumber value="${ro.totalCost}" type="number" pattern="#,##0"/>đ
                                                                </td>
                                                                <td class="text-center">
                                                                    <span class="badge" style="background-color: #fef3c7; color: #b45309; font-weight: 700; font-size: 11px; padding: 5px 12px; border-radius: 12px;">
                                                                        Chờ nhận
                                                                    </span>
                                                                </td>
                                                                <td class="text-center" onclick="event.stopPropagation();">
                                                                    <button type="button" class="btn btn-sm text-white fw-bold px-3 py-1.5" style="background-color: #16a34a; border-radius: 8px; font-size: 12.5px; box-shadow: 0 2px 4px rgba(22, 163, 74, 0.2);" onclick="acceptAndShowDetail('${ro.orderNo}')">
                                                                        <i class="fa-solid fa-check me-1"></i> Chấp nhận
                                                                    </button>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <tr>
                                                            <td colspan="6" class="text-center py-4 text-muted">
                                                                Hiện không có đơn hàng nào đang chờ nhận giao.
                                                            </td>
                                                        </tr>
                                                    </c:otherwise>
                                                </c:choose>
                                            </tbody>
                                        </table>
                                    </div>

                                    <!-- Tóm tắt số lượng & Phân trang phía dưới -->
                                    <div class="d-flex align-items-center justify-content-between mt-3 pt-3 border-top" style="font-size: 12.5px; color: #64748b;">
                                        <div>
                                            Hiển thị <strong><c:out value="${not empty readyOrders ? readyOrders.size() : 0}"/></strong> đơn hàng khả dụng
                                        </div>
                                        <div class="d-flex align-items-center gap-1">
                                            <button class="btn btn-sm btn-outline-secondary disabled" style="padding: 2px 8px; border-radius: 6px;">&lt;</button>
                                            <span class="btn btn-sm text-white fw-bold" style="background-color: #162e21; padding: 2px 10px; border-radius: 6px;">1</span>
                                            <button class="btn btn-sm btn-outline-secondary disabled" style="padding: 2px 8px; border-radius: 6px;">&gt;</button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Script Lọc tìm kiếm động trên bảng -->
                            <script>
                                document.addEventListener("DOMContentLoaded", function() {
                                    const searchInput = document.getElementById('shipperReadyOrderSearch');
                                    if (searchInput) {
                                        searchInput.addEventListener('input', function() {
                                            const query = this.value.toLowerCase().trim();
                                            const rows = document.querySelectorAll('#readyOrdersTable tbody tr');
                                            rows.forEach(row => {
                                                const text = row.textContent.toLowerCase();
                                                if (text.includes(query)) {
                                                    row.style.display = '';
                                                } else {
                                                    row.style.display = 'none';
                                                }
                                            });
                                        });
                                    }
                                });
                            </script>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <!-- QUẢN TRỊ VIÊN: Biểu đồ đường Doanh thu Tài chính -->
                        <div class="chart-card">
                            <div id="chartHeader" class="chart-title d-flex justify-content-between align-items-center flex-nowrap gap-3">
                                <div class="d-flex flex-column" style="min-width: 0; flex-shrink: 1; margin-right: 15px;">
                                    <span id="chartMetricTitle" style="font-family:'Playfair Display', serif; font-weight:700; white-space: nowrap;">Báo cáo doanh thu</span>
                                    <span id="chartTimeframeSubtitle" style="font-family:'Inter', sans-serif; font-size:12px; color:var(--cz-text-muted); font-weight:500;">Xu hướng 6 tháng gần nhất</span>
                                </div>
                                <div id="chartControlsContainer" class="d-flex align-items-center gap-3 flex-nowrap">
                                    <div class="chart-select-container">
                                        <span class="calendar-icon-wrap"><i class="fa-regular fa-calendar"></i></span>
                                        <select id="timeframeSelect" class="chart-select">
                                            <option value="7days">7 ngày qua</option>
                                            <option value="30days">30 ngày qua</option>
                                            <option value="6months">6 tháng gần nhất</option>
                                            <option value="custom">Tùy chọn...</option>
                                        </select>
                                        <i class="fa-solid fa-chevron-down select-chevron"></i>
                                    </div>
                                    <div id="customDateRangeContainer" style="display: none; align-items: center; gap: 8px;">
                                        <input type="date" id="startDate" name="startDate" class="form-control form-control-sm" style="max-width: 140px; font-size:12px;" value="${startDate}">
                                        <span style="font-size:13px; font-weight:500;">đến</span>
                                        <input type="date" id="endDate" name="endDate" class="form-control form-control-sm" style="max-width: 140px; font-size:12px;" value="${endDate}">
                                        <button type="button" id="btnApplyCustomDate" class="btn btn-sm text-white" style="background-color:#1E3224; border-color:#1E3224; padding: 4px 12px; font-size:12px; border-radius:15px; font-weight:600;">Lọc</button>
                                    </div>
                                    <div class="chart-controls" id="metricControls">
                                        <button class="btn-toggle-pill active" data-metric="revenue">Doanh thu</button>
                                        <button class="btn-toggle-pill" data-metric="orders">Đơn hàng</button>
                                        <button class="btn-toggle-pill" data-metric="profit">Lợi nhuận</button>
                                    </div>
                                </div>
                            </div>
                            <div class="chart-body">
                                <canvas id="revenueChart"></canvas>
                            </div>
                        </div>

                        <!-- ADMIN: Status Distribution Doughnut -->
                        <div class="chart-card">
                            <div class="chart-title">
                                Trạng thái đơn hàng <span>Tỷ lệ phân bổ đơn hàng</span>
                            </div>
                            <div class="chart-body" style="min-height: 200px; max-height: 200px;">
                                <canvas id="statusChart"></canvas>
                                <div class="chart-center-text">
                                    <div class="chart-center-val">
                                        <c:choose>
                                            <c:when test="${totalOrders >= 1000}">
                                                <fmt:formatNumber value="${totalOrders / 1000}" pattern="#.0"/>k
                                            </c:when>
                                            <c:otherwise>${totalOrders}</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="chart-center-lbl">TỔNG CỘNG</div>
                                </div>
                            </div>
                            <div class="d-flex flex-wrap justify-content-between mt-3 px-2" style="font-size: 13px;">
                                <div class="w-50 mb-2 d-flex align-items-center gap-2">
                                    <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background-color:#3f5f36;"></span>
                                    <span>Hoàn thành: <strong id="lbl-completed">-</strong></span>
                                </div>
                                <div class="w-50 mb-2 d-flex align-items-center gap-2">
                                    <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background-color:#c8a46d;"></span>
                                    <span>Đang giao: <strong id="lbl-delivering">-</strong></span>
                                </div>
                                <div class="w-50 mb-2 d-flex align-items-center gap-2">
                                    <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background-color:#ffe082;"></span>
                                    <span>Chờ xử lý: <strong id="lbl-pending">-</strong></span>
                                </div>
                                <div class="w-50 mb-2 d-flex align-items-center gap-2">
                                    <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background-color:#ef9a9a;"></span>
                                    <span>Đã hủy: <strong id="lbl-cancelled">-</strong></span>
                                </div>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Bento Grid Row (ADMIN & STAFF only) -->
            <c:if test="${sessionScope.user.roleId ne 'SHIPPER'}">
            <div class="bento-row">
                <c:choose>
                    <c:when test="${sessionScope.user.roleId eq 'STAFF'}">
                        <!-- STAFF Bento: 1. Recent Orders (Sorted by priority) & 2. Best Sellers -->
                        <div class="bento-card">
                            <div class="bento-card-title">
                                <div>Đơn hàng vừa đặt <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Sắp xếp: Đang chờ duyệt &rarr; Đã thanh toán &rarr; Đang làm bánh</span></div>
                                <a href="${pageContext.request.contextPath}/admin/orders?action=list">Quản lý đơn hàng</a>
                            </div>
                            <div class="table-responsive">
                                <table class="bento-table">
                                    <thead>
                                        <tr>
                                            <th>Mã đơn</th>
                                            <th>Khách hàng</th>
                                            <th>Thời gian</th>
                                            <th class="text-center">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty staffOrders}">
                                                <c:forEach var="order" items="${staffOrders}" end="6">
                                                    <c:set var="stLow" value="${fn:toLowerCase(order.orderStatus)}" />
                                                    
                                                    <c:set var="rowBgStyle" value="" />
                                                    <c:set var="badgeClass" value="bg-light text-dark" />
                                                    <c:set var="statusDisplay" value="${order.orderStatus}" />

                                                    <c:choose>
                                                        <c:when test="${stLow eq 'pending' || fn:contains(stLow, 'chờ')}">
                                                            <c:set var="badgeClass" value="badge-pending" />
                                                            <c:set var="statusDisplay" value="Đang chờ duyệt" />
                                                        </c:when>
                                                        <c:when test="${stLow eq 'confirmed' || stLow eq 'paid' || fn:contains(stLow, 'xác nhận') || fn:contains(stLow, 'thanh toán')}">
                                                            <c:set var="badgeClass" value="badge-confirmed" />
                                                            <c:set var="statusDisplay" value="Đã thanh toán" />
                                                        </c:when>
                                                        <c:when test="${stLow eq 'processing' || fn:contains(stLow, 'xử lý') || fn:contains(stLow, 'bếp') || fn:contains(stLow, 'làm bánh')}">
                                                            <c:set var="badgeClass" value="badge-processing" />
                                                            <c:set var="statusDisplay" value="Đang làm bánh" />
                                                        </c:when>
                                                        <c:when test="${stLow eq 'delivering' || fn:contains(stLow, 'giao')}">
                                                            <c:set var="badgeClass" value="badge-delivering" />
                                                            <c:set var="statusDisplay" value="Đang giao hàng" />
                                                        </c:when>
                                                        <c:when test="${stLow eq 'completed' || fn:contains(stLow, 'hoàn thành')}">
                                                            <c:set var="badgeClass" value="badge-completed" />
                                                            <c:set var="statusDisplay" value="Hoàn thành" />
                                                        </c:when>
                                                        <c:when test="${stLow eq 'cancelled' || fn:contains(stLow, 'hủy')}">
                                                            <c:set var="badgeClass" value="badge-cancelled" />
                                                            <c:set var="statusDisplay" value="Đã hủy" />
                                                        </c:when>
                                                    </c:choose>

                                                    <tr>
                                                        <td><strong>#${order.orderNo}</strong></td>
                                                        <td><span class="cz-text-dark fw-medium" style="font-size:13px;"><c:out value="${order.customerName}"/></span></td>
                                                        <td class="text-muted" style="font-size:12.5px;"><fmt:formatDate value="${order.orderTime}" pattern="dd/MM HH:mm"/></td>
                                                        <td class="text-center">
                                                            <span class="badge ${badgeClass}" style="font-weight: 600; font-size: 11.5px; padding: 5px 10px; border-radius: 6px;">
                                                                ${statusDisplay}
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr><td colspan="4" class="text-center py-4 text-muted">Chưa có đơn hàng mới nào.</td></tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div class="bento-card">
                            <div class="bento-card-title">
                                <div>Sản phẩm bán chạy nhất <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Các mẫu bánh yêu thích nhất tháng này</span></div>
                                <a href="${pageContext.request.contextPath}/admin/product?action=list">Xem danh sách mẫu bánh</a>
                            </div>
                            <div class="table-responsive">
                                <table class="bento-table">
                                    <thead>
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th class="text-end">Đã bán</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty bestSellers}">
                                                <c:forEach var="item" items="${bestSellers}">
                                                    <tr>
                                                        <td>
                                                            <div class="bento-product-info">
                                                                <c:choose>
                                                                    <c:when test="${not empty item.imageUrl}">
                                                                        <img class="bento-product-img" src="${pageContext.request.contextPath}/${item.imageUrl}" alt="${item.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/default-cake.png';">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <img class="bento-product-img" src="${pageContext.request.contextPath}/assets/images/default-cake.png" alt="Default Product">
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <span class="bento-product-name"><c:out value="${item.name}"/></span>
                                                            </div>
                                                        </td>
                                                        <td><span class="text-secondary"><c:out value="${item.category}"/></span></td>
                                                        <td class="text-end fw-bold cz-text-dark"><c:out value="${item.quantitySold}"/> bánh</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr><td colspan="3" class="text-center py-4 text-muted">Chưa có dữ liệu sản phẩm bán chạy.</td></tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </c:when>



                    <c:otherwise>
                        <!-- ADMIN Bento: Best Sellers & Top Customers -->
                        <div class="bento-card">
                            <div class="bento-card-title">
                                <div>Sản phẩm bán chạy nhất <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Thống kê sản phẩm được yêu thích nhất tháng này</span></div>
                                <a href="${pageContext.request.contextPath}/admin/product?action=list">Xem báo cáo chi tiết</a>
                            </div>
                            <div class="table-responsive">
                                <table class="bento-table">
                                    <thead>
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Danh mục</th>
                                            <th class="text-end">Doanh thu</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty bestSellers}">
                                                <c:forEach var="item" items="${bestSellers}">
                                                    <tr>
                                                        <td>
                                                            <div class="bento-product-info">
                                                                <c:choose>
                                                                    <c:when test="${not empty item.imageUrl}">
                                                                        <img class="bento-product-img" src="${pageContext.request.contextPath}/${item.imageUrl}" alt="${item.name}" onerror="this.src='${pageContext.request.contextPath}/assets/images/default-cake.png';">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <img class="bento-product-img" src="${pageContext.request.contextPath}/assets/images/default-cake.png" alt="Default Product">
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <span class="bento-product-name"><c:out value="${item.name}"/></span>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <span class="text-secondary"><c:out value="${item.category}"/></span>
                                                            <span class="badge border cz-text-dark ms-1" style="font-size:11px;"><c:out value="${item.quantitySold}"/> đã bán</span>
                                                        </td>
                                                        <td class="text-end fw-bold cz-text-dark font-monospace">
                                                            <fmt:formatNumber value="${item.totalRevenue}" type="number" pattern="#,##0"/>đ
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr><td colspan="3" class="text-center py-4 text-muted">Chưa có dữ liệu sản phẩm bán chạy.</td></tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div class="bento-card">
                            <div class="bento-card-title">
                                <div>Khách hàng thân thiết <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Top 5 khách hàng chi tiêu nhiều nhất</span></div>
                            </div>
                            <div class="customer-list">
                                <c:choose>
                                    <c:when test="${not empty topCustomers}">
                                        <c:forEach var="cust" items="${topCustomers}" varStatus="status">
                                            <div class="customer-list-item">
                                                <div class="customer-info-wrap">
                                                    <div class="customer-index-badge">${status.index + 1}</div>
                                                    <div>
                                                        <div class="customer-name"><c:out value="${cust.fullName}"/></div>
                                                        <div class="customer-orders-count">${cust.orderCount} đơn hàng</div>
                                                    </div>
                                                </div>
                                                <div class="customer-spending"><fmt:formatNumber value="${cust.totalSpent / 1000}" pattern="#,##0"/>k</div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4 text-muted">Chưa có dữ liệu khách hàng thân thiết.</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            </c:if>



        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
        // Multi-dimensional datasets populated from AdminDashboardServlet
        const trends = {
            "custom": {
                "revenue": {
                    labels: [${customRevLabels}],
                    data: [${customRevData}]
                },
                "orders": {
                    labels: [${customOrdLabels}],
                    data: [${customOrdData}]
                },
                "profit": {
                    labels: [${customPrfLabels}],
                    data: [${customPrfData}]
                }
            },
            "6months": {
                "revenue": {
                    labels: [${monthlyRevLabels}],
                    data: [${monthlyRevData}]
                },
                "orders": {
                    labels: [${monthlyOrdLabels}],
                    data: [${monthlyOrdData}]
                },
                "profit": {
                    labels: [${monthlyPrfLabels}],
                    data: [${monthlyPrfData}]
                }
            },
            "30days": {
                "revenue": {
                    labels: [${daily30RevLabels}],
                    data: [${daily30RevData}]
                },
                "orders": {
                    labels: [${daily30OrdLabels}],
                    data: [${daily30OrdData}]
                },
                "profit": {
                    labels: [${daily30PrfLabels}],
                    data: [${daily30PrfData}]
                }
            },
            "7days": {
                "revenue": {
                    labels: [${daily7RevLabels}],
                    data: [${daily7RevData}]
                },
                "orders": {
                    labels: [${daily7OrdLabels}],
                    data: [${daily7OrdData}]
                },
                "profit": {
                    labels: [${daily7PrfLabels}],
                    data: [${daily7PrfData}]
                }
            }
        };

        const statusLabels = [${statusLabels}];
        const statusData = [${statusData}];

        // Initialize state variables
        let activeMetric = "revenue";
        let activeTimeframe = "${hasCustomDate}" === "true" ? "custom" : "6months";

        // Create Chart instances
        let revenueChart;
        
        document.addEventListener("DOMContentLoaded", function() {
            // Calculate doughnut percentages for custom legend
            const totalStatusCount = statusData.reduce((a, b) => a + b, 0);
            const getPercentageString = (val) => {
                if (totalStatusCount === 0) return "0%";
                return Math.round((val / totalStatusCount) * 100) + "%";
            };

            let completedVal = 0;
            let deliveringVal = 0;
            let pendingVal = 0;
            let cancelledVal = 0;

            statusLabels.forEach((lbl, idx) => {
                const val = statusData[idx];
                if (lbl === "Hoàn thành") {
                    completedVal += val;
                } else if (lbl === "Đang giao") {
                    deliveringVal += val;
                } else if (lbl === "Chờ xác nhận" || lbl === "Đã xác nhận" || lbl === "Đang xử lý") {
                    pendingVal += val;
                } else if (lbl === "Đã hủy") {
                    cancelledVal += val;
                }
            });

            if (document.getElementById('lbl-completed')) {
                document.getElementById('lbl-completed').innerText = getPercentageString(completedVal);
                document.getElementById('lbl-delivering').innerText = getPercentageString(deliveringVal);
                document.getElementById('lbl-pending').innerText = getPercentageString(pendingVal);
                document.getElementById('lbl-cancelled').innerText = getPercentageString(cancelledVal);
            }

            // Initialize revenue chart
            const revCanvas = document.getElementById('revenueChart');
            if (revCanvas) {
                const ctxRev = revCanvas.getContext('2d');
                revenueChart = new Chart(ctxRev, {
                    type: 'bar',
                    data: {
                        labels: [],
                        datasets: [{
                            label: 'Doanh thu (đ)',
                            data: [],
                            backgroundColor: '#a3b89e',
                            borderRadius: 8,
                            borderSkipped: false,
                            maxBarThickness: 35
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        let label = context.dataset.label || '';
                                        if (label) {
                                            label += ': ';
                                        }
                                        if (context.parsed.y !== null) {
                                            if (activeMetric === "orders") {
                                                label += context.parsed.y;
                                            } else {
                                                label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                                            }
                                        }
                                        return label;
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: {
                                    color: '#f3ede5'
                                },
                                ticks: {
                                    callback: function(value) {
                                        if (activeMetric === "orders") {
                                            return value;
                                        }
                                        return new Intl.NumberFormat('vi-VN', { notation: 'compact' }).format(value);
                                    }
                                }
                            },
                            x: {
                                grid: {
                                    display: false
                                }
                            }
                        }
                    }
                });
            }

            // Initial chart rendering
            const timeframeSelect = document.getElementById('timeframeSelect');
            const customDateContainer = document.getElementById('customDateRangeContainer');
            
            if (timeframeSelect) {
                timeframeSelect.value = activeTimeframe;
                if (activeTimeframe === 'custom' && customDateContainer) {
                    customDateContainer.style.display = 'inline-flex';
                }
                
                updateChart();

                // Set up chart select change listener
                timeframeSelect.addEventListener('change', function() {
                    activeTimeframe = this.value;
                    if (activeTimeframe === 'custom' && customDateContainer) {
                        customDateContainer.style.display = 'inline-flex';
                    } else if (customDateContainer) {
                        customDateContainer.style.display = 'none';
                    }
                    updateChart();
                });
            }

            // Set up custom date range apply button listener
            const btnApplyCustomDate = document.getElementById('btnApplyCustomDate');
            if (btnApplyCustomDate) {
                btnApplyCustomDate.addEventListener('click', function() {
                    const start = document.getElementById('startDate').value;
                    const end = document.getElementById('endDate').value;
                    if (start && end) {
                        window.location.href = '${pageContext.request.contextPath}/admin/dashboard?startDate=' + start + '&endDate=' + end;
                    } else {
                        alert('Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc!');
                    }
                });
            }

            document.querySelectorAll('#metricControls .btn-toggle-pill').forEach(btn => {
                btn.addEventListener('click', function() {
                    document.querySelectorAll('#metricControls .btn-toggle-pill').forEach(b => b.classList.remove('active'));
                    this.classList.add('active');
                    activeMetric = this.getAttribute('data-metric');
                    updateChart();
                });
            });
        });

        function updateChart() {
            if (!revenueChart) return;
            const chartHeader = document.getElementById('chartHeader');
            const chartControlsContainer = document.getElementById('chartControlsContainer');
            if (chartHeader && chartControlsContainer) {
                if (activeTimeframe === 'custom') {
                    chartHeader.classList.remove('flex-nowrap');
                    chartHeader.classList.add('flex-wrap');
                    chartControlsContainer.classList.remove('flex-nowrap');
                    chartControlsContainer.classList.add('flex-wrap');
                } else {
                    chartHeader.classList.remove('flex-wrap');
                    chartHeader.classList.add('flex-nowrap');
                    chartControlsContainer.classList.remove('flex-wrap');
                    chartControlsContainer.classList.add('flex-nowrap');
                }
            }
            const dataset = trends[activeTimeframe][activeMetric];
            let labels = dataset.labels;
            
            // Format monthly labels for readable display
            if (activeTimeframe === "6months") {
                labels = labels.map(label => {
                    if (typeof label === 'string' && label.includes('/')) {
                        const parts = label.split('/');
                        return "Tháng " + parseInt(parts[0]);
                    }
                    return label;
                });
            }

            // Set bar colors: last bar is glowing green in dark mode, others are dark sage green
            const isDark = document.documentElement.classList.contains('dark-theme');
            const activeColor = isDark ? '#b5cfa3' : '#1E3224';
            const inactiveColor = isDark ? '#242b20' : '#a3b89e';
            const barColors = dataset.data.map((val, idx) => {
                return (idx === dataset.data.length - 1) ? activeColor : inactiveColor;
            });

            revenueChart.data.labels = labels.length > 0 ? labels : ["Chưa có dữ liệu"];
            revenueChart.data.datasets[0].data = dataset.data.length > 0 ? dataset.data : [0];
            revenueChart.data.datasets[0].backgroundColor = dataset.data.length > 0 ? barColors : (isDark ? '#242b20' : '#a3b89e');
            revenueChart.data.datasets[0].label = activeMetric === "revenue" ? "Doanh thu (đ)" : (activeMetric === "orders" ? "Đơn hàng" : "Lợi nhuận (đ)");

            // Update axis and grid colors for dark mode dynamically
            const gridColor = isDark ? 'rgba(255, 255, 255, 0.05)' : '#f3ede5';
            const tickColor = isDark ? '#959893' : '#666';
            revenueChart.options.scales.y.grid.color = gridColor;
            revenueChart.options.scales.y.ticks.color = tickColor;
            if (!revenueChart.options.scales.x.ticks) {
                revenueChart.options.scales.x.ticks = {};
            }
            revenueChart.options.scales.x.ticks.color = tickColor;

            // Title labels updating
            const metricText = activeMetric === "revenue" ? "Doanh thu" : (activeMetric === "orders" ? "Đơn hàng" : "Lợi nhuận");
            let timeframeText = "";
            if (activeTimeframe === "6months") {
                timeframeText = "Xu hướng kinh doanh 6 tháng gần nhất";
            } else if (activeTimeframe === "30days") {
                timeframeText = "Xu hướng kinh doanh 30 ngày gần nhất";
            } else if (activeTimeframe === "7days") {
                timeframeText = "Xu hướng kinh doanh 7 ngày gần nhất";
            } else if (activeTimeframe === "custom") {
                const startVal = document.getElementById('startDate').value;
                const endVal = document.getElementById('endDate').value;
                timeframeText = "Xu hướng kinh doanh từ " + formatDateDMY(startVal) + " đến " + formatDateDMY(endVal);
            }
            
            const chartMetricTitle = document.getElementById('chartMetricTitle');
            if (chartMetricTitle) chartMetricTitle.innerText = "Báo cáo " + metricText.toLowerCase();
            const chartTimeframeSubtitle = document.getElementById('chartTimeframeSubtitle');
            if (chartTimeframeSubtitle) chartTimeframeSubtitle.innerText = timeframeText;

            revenueChart.update();
        }

        // Initialize Order Status Doughnut Chart
        const statusCanvas = document.getElementById('statusChart');
        if (statusCanvas) {
            const ctxStatus = statusCanvas.getContext('2d');
            const isDarkDoughnut = document.documentElement.classList.contains('dark-theme');
            const statusColors = {
                "Hoàn thành": "#b5cfa3",
                "Đang giao": "#c8a46d",
                "Chờ xác nhận": "#ffe082",
                "Đã xác nhận": "#90caf9",
                "Đang xử lý": "#d7ccc8",
                "Đã hủy": "#ef9a9a"
            };
            const defaultPalette = ["#b5cfa3", "#c8a46d", "#ffe082", "#90caf9", "#d7ccc8", "#ef9a9a"];
            const backgroundColors = statusLabels.map((lbl, idx) => statusColors[lbl] || defaultPalette[idx % defaultPalette.length]);

            new Chart(ctxStatus, {
                type: 'doughnut',
                data: {
                    labels: statusLabels.length > 0 ? statusLabels : ["Chưa có đơn"],
                    datasets: [{
                        data: statusData.length > 0 ? statusData : [1],
                        backgroundColor: statusData.length > 0 ? backgroundColors : (isDarkDoughnut ? ['#242b20'] : ['#eee5d8']),
                        borderWidth: 2,
                        borderColor: isDarkDoughnut ? '#131612' : '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    cutout: '70%'
                }
            });
        }

        function formatDateDMY(dateStr) {
            if (!dateStr) return "";
            const parts = dateStr.split('-');
            if (parts.length === 3) {
                return parts[2] + "/" + parts[1] + "/" + parts[0];
            }
            return dateStr;
        }

    </script>

    <!-- MODAL CHI TIẾT ĐƠN HÀNG (Order Detail Modal for Shipper Dashboard) -->
    <div class="modal fade" id="orderDetailModal" tabindex="-1" aria-labelledby="orderDetailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content" style="border-radius: 14px; border: none; overflow: hidden; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);">
                <div class="modal-header" style="background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%); color: #fff; border-bottom: none;">
                    <div>
                        <h5 class="modal-title fw-bold" id="orderDetailModalLabel">
                            <i class="fa-solid fa-truck-fast me-2" style="color: #ec4899;"></i> Chi Tiết Đơn Hàng <span id="modalOrderNo" style="color: #f472b6;">#</span>
                        </h5>
                        <span id="modalOrderStatusBadge" class="badge bg-success mt-1" style="font-size: 11px; text-transform: uppercase;"></span>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4" style="background-color: #f8fafc;">
                    <!-- Customer & Delivery Info Card -->
                    <div class="card mb-3 border-0 shadow-sm" style="border-radius: 10px;">
                        <div class="card-body">
                            <h6 class="fw-bold text-dark mb-3">
                                <i class="fa-solid fa-user-gear me-2" style="color: #2563eb;"></i> Thông Tin Giao Hàng & Người Nhận
                            </h6>
                            <div class="row g-2" style="font-size: 13px;">
                                <div class="col-md-6">
                                    <span class="text-muted">Khách đặt hàng:</span> <strong id="modalCustomerName" class="text-dark">---</strong>
                                </div>
                                <div class="col-md-6">
                                    <span class="text-muted">Số điện thoại nhận:</span> <strong id="modalReceiverPhone" class="text-dark">---</strong>
                                </div>
                                <div class="col-12 mt-2">
                                    <span class="text-muted">Địa chỉ nhận hàng:</span> 
                                    <div id="modalDeliveryAddress" class="p-2 mt-1" style="background-color: #f1f5f9; border-radius: 6px; font-weight: 600; color: #0f172a; border: 1px solid #cbd5e1;">
                                        ---
                                    </div>
                                </div>
                                <div class="col-12 mt-2" id="modalCustomerNoteWrapper" style="display: none;">
                                    <span class="text-muted">Ghi chú khách hàng:</span> 
                                    <div id="modalCustomerNote" class="p-2 mt-1" style="background-color: #fffbeb; border-radius: 6px; font-style: italic; border: 1px solid #fde68a; color: #92400e;">
                                        ---
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Products Table Card -->
                    <div class="card border-0 shadow-sm" style="border-radius: 10px; overflow: hidden;">
                        <div class="card-body p-0">
                            <div class="p-3 bg-white border-bottom">
                                <h6 class="fw-bold text-dark m-0">
                                    <i class="fa-solid fa-cake-candles me-2" style="color: #ec4899;"></i> Danh Sách Sản Phẩm Trong Đơn
                                </h6>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover mb-0" style="font-size: 13px;">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Sản phẩm</th>
                                            <th>Phân loại</th>
                                            <th class="text-center" style="width: 80px;">SL</th>
                                            <th class="text-end" style="width: 120px;">Đơn giá</th>
                                            <th class="text-end" style="width: 130px;">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody id="modalItemsTbody">
                                        <!-- Items dynamic -->
                                    </tbody>
                                </table>
                            </div>
                            <!-- Payment Totals -->
                            <div class="p-3 bg-light border-top" style="font-size: 13px;">
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="text-muted">Tổng cộng đơn hàng:</span>
                                    <strong id="modalTotalCost" class="text-dark">0đ</strong>
                                </div>
                                <div class="d-flex justify-content-between mb-1">
                                    <span class="text-muted">Đã đặt cọc:</span>
                                    <span id="modalDepositAmount" class="text-success fw-bold">0đ</span>
                                </div>
                                <div class="d-flex justify-content-between pt-2 border-top" style="font-size: 15px;">
                                    <strong class="text-dark">Còn lại cần thu (COD):</strong>
                                    <strong id="modalRemainingCod" class="text-danger font-monospace" style="font-size: 17px;">0đ</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" style="background-color: #ffffff;">
                    <a id="modalFullDetailBtn" href="#" class="btn btn-outline-primary btn-sm fw-bold">
                        <i class="fa-solid fa-up-right-from-square me-1"></i> Trang quản lý đơn chi tiết
                    </a>
                    <button type="button" class="btn btn-secondary btn-sm fw-bold" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function formatVND(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount || 0) + 'đ';
        }

        function openOrderDetailModal(orderNo) {
            if (!orderNo) return;
            
            const contextPath = '${pageContext.request.contextPath}';
            fetch(contextPath + '/shipper/orders?action=detail-json&orderNo=' + encodeURIComponent(orderNo))
                .then(response => response.json())
                .then(data => {
                    if (!data.success) {
                        alert(data.message || 'Không thể lấy thông tin chi tiết đơn hàng!');
                        return;
                    }
                    populateOrderDetailModal(data);
                    const modalEl = document.getElementById('orderDetailModal');
                    const bsModal = new bootstrap.Modal(modalEl);
                    bsModal.show();
                })
                .catch(err => {
                    console.error(err);
                    alert('Có lỗi xảy ra khi kết nối máy chủ!');
                });
        }

        function acceptAndShowDetail(orderNo) {
            if (!orderNo) return;
            const contextPath = '${pageContext.request.contextPath}';
            window.location.href = contextPath + '/shipper/orders?action=accept&orderNo=' + encodeURIComponent(orderNo);
        }

        function populateOrderDetailModal(data) {
            const cleanOrderNo = data.orderNo ? data.orderNo.replace('ORD_', '') : '';
            document.getElementById('modalOrderNo').textContent = '#' + cleanOrderNo;
            document.getElementById('modalCustomerName').textContent = data.customerName || 'Khách hàng';
            document.getElementById('modalReceiverPhone').textContent = data.receiverPhone || data.receiverName || 'Chưa cung cấp';
            document.getElementById('modalDeliveryAddress').textContent = data.deliveryAddress || 'Chưa có địa chỉ';

            const statusBadge = document.getElementById('modalOrderStatusBadge');
            statusBadge.textContent = data.orderStatus || 'Đang xử lý';

            const noteWrapper = document.getElementById('modalCustomerNoteWrapper');
            const noteEl = document.getElementById('modalCustomerNote');
            if (data.customerNote && data.customerNote.trim()) {
                noteEl.textContent = data.customerNote;
                noteWrapper.style.display = 'block';
            } else {
                noteWrapper.style.display = 'none';
            }

            const total = data.totalCost || 0;
            const deposit = data.depositAmount || 0;
            const remaining = Math.max(0, total - deposit);

            document.getElementById('modalTotalCost').textContent = formatVND(total);
            document.getElementById('modalDepositAmount').textContent = formatVND(deposit);
            document.getElementById('modalRemainingCod').textContent = formatVND(remaining);

            const tbody = document.getElementById('modalItemsTbody');
            tbody.innerHTML = '';
            if (data.items && data.items.length > 0) {
                data.items.forEach(item => {
                    const row = document.createElement('tr');
                    const itemTotal = (item.quantity || 1) * (item.price || 0);
                    row.innerHTML = `
                        <td class="fw-bold text-dark">\${item.itemName || 'Sản phẩm'}</td>
                        <td><span class="badge bg-light text-dark font-normal">\${item.variation || 'Tiêu chuẩn'}</span></td>
                        <td class="text-center fw-bold">\${item.quantity || 1}</td>
                        <td class="text-end font-monospace">\${formatVND(item.price)}</td>
                        <td class="text-end font-monospace fw-bold text-dark">\${formatVND(itemTotal)}</td>
                    `;
                    tbody.appendChild(row);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-3">Không có thông tin chi tiết sản phẩm.</td></tr>';
            }

            const contextPath = '${pageContext.request.contextPath}';
            document.getElementById('modalFullDetailBtn').href = contextPath + '/shipper/orders?action=detail&orderNo=' + encodeURIComponent(data.orderNo);
        }
    </script>
</body>
</html>
