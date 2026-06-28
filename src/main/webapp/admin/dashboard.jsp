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
    <!-- Dark Mode Init: chạy trước khi render để tránh flash trắng -->
    <script>
        (function() {
            var globalDark = ${not empty settings.darkMode ? settings.darkMode : 'false'};
            var saved = localStorage.getItem('darkMode');
            if (globalDark || saved === 'true') {
                document.documentElement.classList.add('dark-theme');
            }
        })();
    </script>

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
    <link href="${pageContext.request.contextPath}/assets/css/all/admin-global.css?v=1.3" rel="stylesheet">
    <!-- Dashboard Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/admindashbroad.css?v=1.3" rel="stylesheet">
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="dashboard" />
    </jsp:include>

    <!-- Main Content Panel -->
    <main class="main-wrapper">
        
        <!-- Top Header Navbar -->
        <nav class="navbar dashboard-navbar">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/admin/dashboard"><i class="fa-solid fa-house"></i> Bảng điều khiển</a>
                <span>›</span>
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
                        <div class="user-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                        <div class="user-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
                    </div>
                    <div class="avatar" style="background-image: url('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde');"></div>
                </div>
            </div>
        </nav>

        <!-- Dashboard Content -->
        <div class="content">
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="margin: 20px 0; border-radius: 12px; font-weight: 500;">
                    <i class="fa-solid fa-triangle-exclamation" style="margin-right: 8px;"></i>
                    <c:out value="${errorMessage}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>
            
            <!-- Page Title Area -->
            <div class="page-header dashboard-page-header">
                <div class="page-title">
                    <h2>Bảng điều khiển <span class="badge dashboard-badge-admin">ADMIN</span></h2>
                    <p>Xem báo cáo doanh thu, đơn hàng gần đây và quản lý hoạt động tiệm bánh.</p>
                </div>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card stat-revenue">
                    <div class="stat-icon"><i class="fa-solid fa-money-bill-trend-up"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">
                            <span>Tổng doanh thu</span>
                            <span class="stat-trend trend-up">+12.5% <i class="fa-solid fa-arrow-trend-up"></i></span>
                        </div>
                        <div class="stat-value">
                            <fmt:formatNumber value="${totalRevenue}" type="number" pattern="#,##0"/>đ
                        </div>
                    </div>
                </div>

                <div class="stat-card stat-orders">
                    <div class="stat-icon"><i class="fa-solid fa-cart-shopping"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">
                            <span>Đơn hàng</span>
                            <span class="stat-trend trend-up">+8.2% <i class="fa-solid fa-arrow-trend-up"></i></span>
                        </div>
                        <div class="stat-value">${totalOrders}</div>
                    </div>
                </div>

                <a href="${pageContext.request.contextPath}/customer" class="stat-card stat-customers">
                    <div class="stat-icon"><i class="fa-solid fa-users"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">
                            <span>Khách hàng</span>
                            <span class="stat-trend trend-down">-2.1% <i class="fa-solid fa-arrow-trend-down"></i></span>
                        </div>
                        <div class="stat-value">${totalCustomers}</div>
                    </div>
                </a>

                <a href="${pageContext.request.contextPath}/admin/product?action=list" class="stat-card stat-products">
                    <div class="stat-icon"><i class="fa-solid fa-cake-candles"></i></div>
                    <div class="stat-info">
                        <div class="stat-label">
                            <span>Mẫu bánh</span>
                            <span class="stat-trend trend-up">+4% <i class="fa-solid fa-arrow-trend-up"></i></span>
                        </div>
                        <div class="stat-value">${totalProducts}</div>
                    </div>
                </a>
            </div>

            <!-- Charts Row -->
            <div class="charts-row">
                <div class="chart-card">
                    <div id="chartHeader" class="chart-title d-flex justify-content-between align-items-center flex-nowrap gap-3">
                        <div class="d-flex flex-column" style="min-width: 0; flex-shrink: 1; margin-right: 15px;">
                            <span id="chartMetricTitle" style="font-family:'Playfair Display', serif; font-weight:700; white-space: nowrap;">Báo cáo doanh thu</span>
                            <span id="chartTimeframeSubtitle" style="font-family:'Inter', sans-serif; font-size:12px; color:var(--cz-text-muted); font-weight:500;">Xu hướng 6 tháng gần nhất</span>
                        </div>
                        <div id="chartControlsContainer" class="d-flex align-items-center gap-3 flex-nowrap">
                            <!-- Timeframe Select Dropdown -->
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

                            <!-- Custom Date Range inline picker -->
                            <div id="customDateRangeContainer" style="display: none; align-items: center; gap: 8px;">
                                <input type="date" id="startDate" name="startDate" class="form-control form-control-sm" style="max-width: 140px; font-size:12px;" value="${startDate}">
                                <span style="font-size:13px; font-weight:500;">đến</span>
                                <input type="date" id="endDate" name="endDate" class="form-control form-control-sm" style="max-width: 140px; font-size:12px;" value="${endDate}">
                                <button type="button" id="btnApplyCustomDate" class="btn btn-sm text-white" style="background-color:#1E3224; border-color:#1E3224; padding: 4px 12px; font-size:12px; border-radius:15px; font-weight:600;">Lọc</button>
                            </div>

                            <!-- Metrics -->
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
                                    <c:otherwise>
                                        ${totalOrders}
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="chart-center-lbl">TỔNG CỘNG</div>
                        </div>
                    </div>
                    <!-- Custom legend below Doughnut -->
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
            </div>

            <!-- Bento Grid Row for Best Sellers and Top Customers -->
            <div class="bento-row">
                <!-- Best Selling Products Card -->
                <div class="bento-card">
                    <div class="bento-card-title">
                        <div>
                            Sản phẩm bán chạy nhất
                            <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Thống kê sản phẩm được yêu thích nhất tháng này</span>
                        </div>
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
                                                    <span class="badge bg-light text-dark ms-1 border" style="font-size:11px;"><c:out value="${item.quantitySold}"/> đã bán</span>
                                                </td>
                                                <td class="text-end fw-bold text-dark font-monospace">
                                                    <fmt:formatNumber value="${item.totalRevenue}" type="number" pattern="#,##0"/>đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="3" class="text-center py-4 text-muted">Chưa có dữ liệu sản phẩm bán chạy.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Top Customers Card -->
                <div class="bento-card">
                    <div class="bento-card-title">
                        <div>
                            Khách hàng thân thiết
                            <span class="d-block" style="font-size: 12px; font-weight: 500; color: var(--cz-text-muted);">Top 5 khách hàng chi tiêu nhiều nhất</span>
                        </div>
                    </div>
                    <div class="customer-list">
                        <c:choose>
                            <c:when test="${not empty topCustomers}">
                                <c:forEach var="cust" items="${topCustomers}" varStatus="status">
                                    <div class="customer-list-item">
                                        <div class="customer-info-wrap">
                                            <div class="customer-index-badge">
                                                ${status.index + 1}
                                            </div>
                                            <div>
                                                <div class="customer-name"><c:out value="${cust.fullName}"/></div>
                                                <div class="customer-orders-count">${cust.orderCount} đơn hàng</div>
                                            </div>
                                        </div>
                                        <div class="customer-spending">
                                            <fmt:formatNumber value="${cust.totalSpent / 1000}" pattern="#,##0"/>k
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-4 text-muted">Chưa có dữ liệu khách hàng thân thiết.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Footer at Bottom -->
            <footer class="text-center py-4 mt-auto border-top" style="font-size: 13px; color: var(--cz-text-muted); background-color: #ffffff; border-radius: 12px; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.01);">
                <div class="container d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <span>&copy; 2024 Crumb & Craft. Sourdough with Soul.</span>
                    <div class="d-flex gap-3">
                        <a href="#" style="color: inherit; text-decoration: none;">Điều khoản</a>
                        <a href="#" style="color: inherit; text-decoration: none;">Bảo mật</a>
                        <a href="#" style="color: inherit; text-decoration: none;">Liên hệ hỗ trợ</a>
                    </div>
                </div>
            </footer>

        </div>
    </main>

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

            document.getElementById('lbl-completed').innerText = getPercentageString(completedVal);
            document.getElementById('lbl-delivering').innerText = getPercentageString(deliveringVal);
            document.getElementById('lbl-pending').innerText = getPercentageString(pendingVal);
            document.getElementById('lbl-cancelled').innerText = getPercentageString(cancelledVal);

            // Initialize revenue chart
            const ctxRev = document.getElementById('revenueChart').getContext('2d');
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

            // Initial chart rendering
            const timeframeSelect = document.getElementById('timeframeSelect');
            const customDateContainer = document.getElementById('customDateRangeContainer');
            
            timeframeSelect.value = activeTimeframe;
            if (activeTimeframe === 'custom') {
                customDateContainer.style.display = 'inline-flex';
            }
            
            updateChart();

            // Set up chart select change listener
            timeframeSelect.addEventListener('change', function() {
                activeTimeframe = this.value;
                if (activeTimeframe === 'custom') {
                    customDateContainer.style.display = 'inline-flex';
                } else {
                    customDateContainer.style.display = 'none';
                }
                updateChart();
            });

            // Set up custom date range apply button listener
            document.getElementById('btnApplyCustomDate').addEventListener('click', function() {
                const start = document.getElementById('startDate').value;
                const end = document.getElementById('endDate').value;
                if (start && end) {
                    window.location.href = '${pageContext.request.contextPath}/admin/dashboard?startDate=' + start + '&endDate=' + end;
                } else {
                    alert('Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc!');
                }
            });

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
            
            document.getElementById('chartMetricTitle').innerText = "Báo cáo " + metricText.toLowerCase();
            document.getElementById('chartTimeframeSubtitle').innerText = timeframeText;

            revenueChart.update();
        }

        // Initialize Order Status Doughnut Chart
        const ctxStatus = document.getElementById('statusChart').getContext('2d');
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

        function formatDateDMY(dateStr) {
            if (!dateStr) return "";
            const parts = dateStr.split('-');
            if (parts.length === 3) {
                return parts[2] + "/" + parts[1] + "/" + parts[0];
            }
            return dateStr;
        }
    </script>
</body>
</html>
