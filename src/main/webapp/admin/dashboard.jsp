<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Dashboard</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Main Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/admin-global.css?v=1.2" rel="stylesheet">
    <!-- Dashboard Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/admindashbroad.css?v=1.0" rel="stylesheet">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Main Content Panel -->
    <main class="main-wrapper">
        
        <!-- Top Header Navbar -->
        <nav class="navbar" style="border-bottom: 1px solid var(--border-soft);">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/admin/dashboard" style="color: var(--text-muted); text-decoration: none;"><i class="fa-solid fa-house"></i> Bảng điều khiển</a>
                <span style="margin: 0 8px; color: var(--text-muted);">›</span>
                <strong>Tổng quan hệ thống</strong>
            </div>
            
            <div class="navbar-right">
                <button class="notification-btn">
                    <i class="fa-regular fa-bell"></i>
                    <span class="badge-dot"></span>
                </button>
                <div class="header-divider"></div>
                <div class="user-profile">
                    <div class="user-info">
                        <div class="user-name">Nguyễn Anh Quân</div>
                        <div class="user-role">Quản trị viên</div>
                    </div>
                    <div class="avatar" style="background-image: url('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde');"></div>
                </div>
            </div>
        </nav>

        <!-- Dashboard Content -->
        <div class="content">
            
            <!-- Page Title Area -->
            <div class="page-header" style="margin-top: 30px;">
                <div class="page-title">
                    <h2>Bảng điều khiển <span class="badge" style="background-color: var(--primary-green); color: white; font-size: 13px; font-weight: 600; padding: 6px 12px; border-radius: 50px; margin-left: 8px; vertical-align: middle;">ADMIN</span></h2>
                    <p>Xem báo cáo doanh thu, đơn hàng gần đây và quản lý hoạt động tiệm bánh.</p>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card stat-revenue">
                    <div class="stat-trend trend-up">+12.5% <i class="fa-solid fa-arrow-trend-up"></i></div>
                    <div class="stat-icon"><i class="fa-solid fa-money-bill-trend-up"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">Tổng doanh thu</div>
                        <div class="stat-value">
                            <fmt:formatNumber value="${totalRevenue}" type="number" pattern="#,##0"/>đ
                        </div>
                    </div>
                </div>

                <div class="stat-card stat-orders">
                    <div class="stat-trend trend-up">+8.2% <i class="fa-solid fa-arrow-trend-up"></i></div>
                    <div class="stat-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">Đơn hàng</div>
                        <div class="stat-value">${totalOrders}</div>
                    </div>
                </div>

                <div class="stat-card stat-customers">
                    <div class="stat-trend trend-down">-2.1% <i class="fa-solid fa-arrow-trend-down"></i></div>
                    <div class="stat-icon"><i class="fa-solid fa-users"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">Khách hàng</div>
                        <div class="stat-value">${totalCustomers}</div>
                    </div>
                </div>

                <div class="stat-card stat-products">
                    <div class="stat-trend trend-up">+4% <i class="fa-solid fa-arrow-trend-up"></i></div>
                    <div class="stat-icon"><i class="fa-solid fa-cake-candles"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">Mẫu bánh</div>
                        <div class="stat-value">${totalProducts}</div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="charts-row">
                <div class="chart-card">
                    <div class="chart-title">
                        Báo cáo doanh thu <span>Xu hướng 6 tháng gần nhất</span>
                    </div>
                    <div class="chart-body">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

                <div class="chart-card">
                    <div class="chart-title">
                        Trạng thái đơn hàng <span>Tỷ lệ phân bổ</span>
                    </div>
                    <div class="chart-body" style="position: relative;">
                        <canvas id="statusChart"></canvas>
                        <div class="chart-center-text">
                            <div class="chart-center-val">
                                <c:choose>
                                    <c:when test="${totalOrders >= 1000}">
                                        <fmt:formatNumber value="${totalOrders / 1000}" pattern="#.0"/>k
                                    </c:when>
                                    <c:otherwise>
                                        ${totalOrders}
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="chart-center-lbl">TỔNG CỘNG</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Orders Table -->
            <div class="table-card">
                <div class="table-controls" style="padding: 20px 25px; border-bottom: 1px solid var(--cz-border-color);">
                    <h5 style="font-family: 'Playfair Display', serif; font-weight: 700; color: #241d18; margin: 0;">Đơn hàng mới nhận</h5>
                    <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary btn-sm" style="font-size: 12.5px; border-radius: 6px; padding: 6px 12px; display: inline-flex; align-items: center; gap: 6px; text-decoration: none;">
                        Xem tất cả đơn hàng <i class="fa-solid fa-arrow-right-long" style="font-size: 11px;"></i>
                    </a>
                </div>
                
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Thời gian</th>
                            <th>Tổng thanh toán</th>
                            <th class="text-center">Trạng thái</th>
                            <th class="text-center">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty recentOrders}">
                                <c:forEach var="ord" items="${recentOrders}">
                                    <tr>
                                        <td style="font-weight: 700; color: var(--cz-primary);">
                                            #${ord.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td>
                                            <div style="font-weight: 600; color: #241d18;">
                                                <c:out value="${not empty ord.customerName ? ord.customerName : 'Khách vãng lai'}" />
                                            </div>
                                            <div style="font-size: 11.5px; color: var(--cz-text-muted); margin-top: 2px;">
                                                ID: ${ord.customerId}
                                            </div>
                                        </td>
                                        <td>
                                            <fmt:formatDate value="${ord.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td>
                                            <span style="font-weight: 700; color: var(--cz-primary);">
                                                <fmt:formatNumber value="${ord.totalCost}" type="number" pattern="#,##0"/>đ
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <c:choose>
                                                <c:when test="${ord.orderStatus eq 'Pending' || ord.orderStatus eq 'Chờ xác nhận'}">
                                                    <span class="status-badge-custom badge-pending">Chờ xác nhận</span>
                                                </c:when>
                                                <c:when test="${ord.orderStatus eq 'Confirmed' || ord.orderStatus eq 'Đã xác nhận'}">
                                                    <span class="status-badge-custom badge-confirmed">Đã xác nhận</span>
                                                </c:when>
                                                <c:when test="${ord.orderStatus eq 'Processing' || ord.orderStatus eq 'Đang xử lý'}">
                                                    <span class="status-badge-custom badge-processing">Đang xử lý</span>
                                                </c:when>
                                                <c:when test="${ord.orderStatus eq 'Delivering' || ord.orderStatus eq 'Đang giao hàng' || ord.orderStatus eq 'Đang giao'}">
                                                    <span class="status-badge-custom badge-delivering">Đang giao</span>
                                                </c:when>
                                                <c:when test="${ord.orderStatus eq 'Completed' || ord.orderStatus eq 'Hoàn thành' || ord.orderStatus eq 'Đã giao'}">
                                                    <span class="status-badge-custom badge-completed">Hoàn thành</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge-custom badge-cancelled">Đã hủy</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-center">
                                            <a href="${pageContext.request.contextPath}/OrderDetail?orderNo=${ord.orderNo}" class="btn btn-sm btn-outline-success" style="border-radius: 6px; padding: 4px 10px; font-size: 12.5px; text-decoration: none;">
                                                Chi tiết
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-3 mb-3" style="color: #ccc;"></i>
                                        Chưa có đơn hàng nào được ghi nhận trên hệ thống.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div>
    </main>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
        // Data populated dynamically from AdminDashboardServlet
        const revenueLabels = [${revenueLabels}];
        const revenueData = [${revenueData}];
        
        const statusLabels = [${statusLabels}];
        const statusData = [${statusData}];

        // Map labels like "06/2026" to "Tháng 6"
        const formattedLabels = revenueLabels.map(label => {
            if (typeof label === 'string' && label.includes('/')) {
                const parts = label.split('/');
                return "Tháng " + parseInt(parts[0]);
            }
            return label;
        });

        // Set bar colors: last bar (current month) is dark green, others are sage green
        const barColors = revenueData.map((val, idx) => {
            return (idx === revenueData.length - 1) ? '#3f5f36' : '#a3b89e';
        });

        // Initialize Revenue Bar Chart
        const ctxRev = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctxRev, {
            type: 'bar',
            data: {
                labels: formattedLabels.length > 0 ? formattedLabels : ["Chưa có dữ liệu"],
                datasets: [{
                    label: 'Doanh thu (đ)',
                    data: revenueData.length > 0 ? revenueData : [0],
                    backgroundColor: revenueData.length > 0 ? barColors : '#a3b89e',
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
                                    label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
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

        // Initialize Order Status Doughnut Chart
        const ctxStatus = document.getElementById('statusChart').getContext('2d');
        
        // Custom palette matching the warm green/gold branding
        const statusColors = {
            "Hoàn thành": "#3f5f36",
            "Đang giao": "#c8a46d",
            "Chờ xác nhận": "#ffe082",
            "Đã xác nhận": "#90caf9",
            "Đang xử lý": "#d7ccc8",
            "Đã hủy": "#ef9a9a"
        };
        const defaultPalette = ["#3f5f36", "#c8a46d", "#ffe082", "#90caf9", "#d7ccc8", "#ef9a9a"];
        const backgroundColors = statusLabels.map((lbl, idx) => statusColors[lbl] || defaultPalette[idx % defaultPalette.length]);

        new Chart(ctxStatus, {
            type: 'doughnut',
            data: {
                labels: statusLabels.length > 0 ? statusLabels : ["Chưa có đơn"],
                datasets: [{
                    data: statusData.length > 0 ? statusData : [1],
                    backgroundColor: statusData.length > 0 ? backgroundColors : ['#eee5d8'],
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            boxWidth: 12,
                            padding: 15,
                            font: {
                                size: 11
                            }
                        }
                    }
                },
                cutout: '70%'
            }
        });
    </script>
</body>
</html>
