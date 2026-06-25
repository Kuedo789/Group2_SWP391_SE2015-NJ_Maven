<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CakeZone Admin - Order Detail #${order.orderNo.replace('ORD_', '')}</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

    <style>
        :root {
            --cz-primary: #3f5f36;
            --cz-primary-hover: #2f4728;
            --cz-dark-bg: #111010;
            --cz-sidebar-active: #232222;
            --cz-text-muted: #888888;
            --cz-border-color: #f1ede8;
            --cz-light-bg: #f8f6f4;
            --cz-card-bg: #ffffff;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--cz-light-bg);
            color: #333;
            overflow-x: hidden;
            margin: 0;
        }

        .main-panel {
            margin-left: 260px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Top Header */
        .top-header {
            height: 70px;
            background-color: #fff;
            border-bottom: 1px solid var(--cz-border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 35px;
            position: sticky;
            top: 0;
            z-index: 90;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .sidebar-toggle {
            background: none;
            border: none;
            font-size: 18px;
            color: #555;
            cursor: pointer;
        }
        .breadcrumbs {
            font-size: 13px;
            color: var(--cz-text-muted);
            margin-bottom: 0;
        }
        .breadcrumbs a {
            color: var(--cz-text-muted);
            text-decoration: none;
            transition: color 0.2s;
        }
        .breadcrumbs a:hover {
            color: var(--cz-primary);
        }
        .breadcrumbs span {
            margin: 0 6px;
        }

        .header-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .header-icon-btn {
            background: none;
            border: none;
            font-size: 18px;
            color: #555;
            position: relative;
            cursor: pointer;
            transition: color 0.2s;
        }
        .header-icon-btn:hover {
            color: var(--cz-primary);
        }

        .profile-section {
            display: flex;
            align-items: center;
            gap: 10px;
            border-left: 1px solid var(--cz-border-color);
            padding-left: 20px;
        }
        .profile-img {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--cz-border-color);
        }
        .profile-info {
            line-height: 1.2;
        }
        .profile-name {
            font-size: 13.5px;
            font-weight: 600;
            color: #333;
        }
        .profile-role {
            font-size: 10.5px;
            color: var(--cz-text-muted);
            font-weight: 500;
        }

        /* Container */
        .content-container {
            padding: 35px;
            flex: 1;
        }
        
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: #555;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 20px;
            transition: color 0.2s;
        }
        .btn-back:hover {
            color: var(--cz-primary);
        }

        .page-title-area {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 25px;
        }
        .page-title {
            font-size: 26px;
            font-weight: 700;
            color: #111;
            margin-bottom: 4px;
        }
        
        /* Grid Layout */
        .grid-layout {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
        }
        @media (max-width: 991px) {
            .grid-layout {
                grid-template-columns: 1fr;
            }
        }

        .cz-card {
            background-color: var(--cz-card-bg);
            border-radius: 12px;
            border: 1px solid var(--cz-border-color);
            padding: 24px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            margin-bottom: 25px;
        }
        .cz-card-title {
            font-size: 16px;
            font-weight: 700;
            color: #111;
            margin-bottom: 18px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--cz-border-color);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Info Item */
        .info-row {
            display: flex;
            margin-bottom: 12px;
            font-size: 14px;
        }
        .info-label {
            width: 140px;
            color: var(--cz-text-muted);
            font-weight: 500;
            flex-shrink: 0;
        }
        .info-value {
            color: #222;
            font-weight: 600;
        }

        /* Status Badges */
        .status-badge {
            font-size: 12px;
            font-weight: 600;
            padding: 5px 14px;
            border-radius: 30px;
            display: inline-block;
        }
        .status-pending { background-color: #fef9c3; color: #a16207; }
        .status-confirmed { background-color: #dbeafe; color: #1e40af; }
        .status-processing { background-color: #f3e8ff; color: #6b21a8; }
        .status-delivering { background-color: #ffedd5; color: #9a3412; }
        .status-completed { background-color: #dcfce7; color: #166534; }
        .status-cancelled { background-color: #fee2e2; color: #991b1b; }

        /* Items list */
        .order-item-row {
            display: flex;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid var(--cz-border-color);
        }
        .order-item-row:last-child {
            border-bottom: none;
        }
        .item-img {
            width: 70px;
            height: 70px;
            border-radius: 8px;
            object-fit: cover;
            background-color: #fcfcfc;
            border: 1px solid var(--cz-border-color);
            margin-right: 16px;
            flex-shrink: 0;
        }
        .item-details {
            flex-grow: 1;
        }
        .item-name {
            font-size: 14.5px;
            font-weight: 700;
            color: #222;
            margin-bottom: 4px;
        }
        .item-meta {
            font-size: 12px;
            color: var(--cz-text-muted);
            margin-bottom: 2px;
        }
        .item-meta span {
            color: #444;
            font-weight: 600;
        }
        .item-price-qty {
            text-align: right;
            flex-shrink: 0;
        }
        .item-price {
            font-size: 14.5px;
            font-weight: 700;
            color: #222;
            font-family: monospace;
        }
        .item-qty {
            font-size: 12.5px;
            color: var(--cz-text-muted);
        }

        /* Status Form dropdown */
        .status-form {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .status-select {
            padding: 10px 15px;
            font-size: 14px;
            font-weight: 600;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            outline: none;
            cursor: pointer;
            background-color: #fff;
            width: 100%;
        }
        .btn-update-status {
            background-color: var(--cz-primary);
            color: #fff;
            border: none;
            padding: 10px 15px;
            font-weight: 600;
            border-radius: 8px;
            cursor: pointer;
            transition: background 0.2s;
            width: 100%;
        }
        .btn-update-status:hover {
            background-color: var(--cz-primary-hover);
        }

        /* Cost Table */
        .cost-row {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .cost-row.total {
            font-size: 16px;
            font-weight: 700;
            border-top: 1px solid var(--cz-border-color);
            padding-top: 12px;
            margin-top: 5px;
            color: var(--cz-primary);
        }
        .font-mono {
            font-family: monospace;
        }
    </style>
</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <div class="main-panel">
        <div class="top-header">
            <div class="header-left">
                <button class="sidebar-toggle"><i class="fa-solid fa-bars"></i></button>
                <div class="breadcrumbs">
                    <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
                    <span>&gt;</span>
                    <a href="${pageContext.request.contextPath}/admin/orders">Quản lý đơn hàng</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">Chi tiết đơn hàng</a>
                </div>
            </div>

            <div class="header-right">
                <button class="header-icon-btn"><i class="fa-regular fa-bell"></i></button>
                <button class="header-icon-btn"><i class="fa-regular fa-circle-question"></i></button>

                <div class="profile-section">
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                    <div class="profile-info">
                        <div class="profile-name">Nguyễn Anh Quân</div>
                        <div class="profile-role">Quản trị viên</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="content-container">
            <a href="${pageContext.request.contextPath}/admin/orders" class="btn-back">
                <i class="fa-solid fa-arrow-left-long"></i> Quay lại danh sách đơn hàng
            </a>

            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}</h1>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ xác nhận'}">
                            <span class="status-badge status-pending">Chờ xác nhận</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Đã xác nhận'}">
                            <span class="status-badge status-confirmed">Đã xác nhận</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý'}">
                            <span class="status-badge status-processing">Đang xử lý</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao'}">
                            <span class="status-badge status-delivering">Đang giao</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao'}">
                            <span class="status-badge status-completed">Hoàn thành</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge status-cancelled">Đã hủy</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="grid-layout">
                <!-- Left Column -->
                <div>
                    <!-- Order Items -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-cake-candles" style="color: var(--cz-primary);"></i> Danh sách sản phẩm đặt mua
                        </div>
                        <div class="order-items-list">
                        <%
                            Order adminOrder = (Order) request.getAttribute("order");
                            String ctxPath = request.getContextPath();
                            String defaultImg = ctxPath + "/assets/images/default-cake.png";
                            java.text.DecimalFormat czFmt = new java.text.DecimalFormat("#,###");
                            java.text.DecimalFormatSymbols czSym = new java.text.DecimalFormatSymbols();
                            czSym.setGroupingSeparator('.');
                            czFmt.setDecimalFormatSymbols(czSym);

                            if (adminOrder != null && adminOrder.getItems() != null && !adminOrder.getItems().isEmpty()) {
                                for (OrderItem oi : adminOrder.getItems()) {
                                    String rawImg = oi.getItemImage();
                                    String resolvedImg = defaultImg;
                                    if (rawImg != null && !rawImg.trim().isEmpty()) {
                                        if (rawImg.startsWith("data:") || rawImg.startsWith("http://") || rawImg.startsWith("https://")) {
                                            resolvedImg = rawImg;
                                        } else if (rawImg.startsWith("/")) {
                                            if (!ctxPath.isEmpty() && rawImg.startsWith(ctxPath + "/")) {
                                                resolvedImg = rawImg;
                                            } else {
                                                resolvedImg = ctxPath + rawImg;
                                            }
                                        } else {
                                            resolvedImg = ctxPath + "/" + rawImg;
                                        }
                                    }

                                    String resolvedTemplateImg = defaultImg;
                                    if (oi.getTemplateImage() != null && !oi.getTemplateImage().trim().isEmpty()) {
                                        String tImg = oi.getTemplateImage();
                                        if (tImg.startsWith("data:") || tImg.startsWith("http://") || tImg.startsWith("https://")) {
                                            resolvedTemplateImg = tImg;
                                        } else if (tImg.startsWith("/")) {
                                            if (!ctxPath.isEmpty() && tImg.startsWith(ctxPath + "/")) {
                                                resolvedTemplateImg = tImg;
                                            } else {
                                                resolvedTemplateImg = ctxPath + tImg;
                                            }
                                        } else {
                                            resolvedTemplateImg = ctxPath + "/" + tImg;
                                        }
                                    }

                                    String itemName   = oi.getItemName()   != null ? oi.getItemName()   : "Sản phẩm";
                                    String catName    = oi.getCategoryName() != null ? oi.getCategoryName() : "Bánh ngọt";
                                    String varName    = oi.getVariationName() != null ? oi.getVariationName() : "Tiêu chuẩn";
                                    String greeting   = oi.getGreetingText();
                                    String ccId       = oi.getCustomCakeId();
                                    int qty           = oi.getQuantity();
                                    double price      = oi.getPriceAtPurchase() != null ? oi.getPriceAtPurchase().doubleValue() : 0;
                                    double lineTotal  = price * qty;
                        %>
                            <div class="order-item-row">
                                <img src="<%= resolvedImg %>" data-template-image="<%= resolvedTemplateImg %>" alt="<%= itemName %>" class="item-img"
                                     onerror="this.src = this.getAttribute('data-template-image') || '<%= defaultImg %>'; this.onerror = function() { this.src = '<%= defaultImg %>'; };">
                                <div class="item-details">
                                    <div class="item-name"><%= itemName %></div>
                                    <div class="item-meta">Phân loại: <span><%= catName %></span></div>
                                    <div class="item-meta">Kích cỡ/Tùy chọn: <span><%= varName %></span></div>
                                    <% if (greeting != null && !greeting.trim().isEmpty()) { %>
                                        <div class="item-meta" style="color: var(--cz-primary); font-style: italic;">
                                            Lời chúc trên bánh: <span>"<%= greeting %>"</span>
                                        </div>
                                    <% } %>
                                    <% if (ccId != null && !ccId.trim().isEmpty()) { %>
                                        <div class="item-meta" style="font-size: 11px;">
                                            Mã bánh: <span><%= ccId %></span>
                                        </div>
                                    <% } %>
                                </div>
                                <div class="item-price-qty">
                                    <div class="item-price font-mono"><%= czFmt.format(price) %>đ</div>
                                    <div class="item-qty">Số lượng: x<%= qty %></div>
                                    <div class="item-qty fw-bold" style="color:#222;">
                                        Thành tiền: <%= czFmt.format(lineTotal) %>đ
                                    </div>
                                </div>
                            </div>
                        <% } // end for
                           } else { %>
                            <div class="text-center py-4 text-muted">
                                <i class="fa-solid fa-circle-info me-2"></i>Không có sản phẩm nào trong đơn hàng này.
                            </div>
                        <% } %>
                        </div>
                    </div>

                    <!-- Customer & Delivery Address Info -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-truck" style="color: var(--cz-primary);"></i> Thông tin giao hàng & Khách hàng
                        </div>
                        <div class="info-row">
                            <div class="info-label">Khách hàng:</div>
                            <div class="info-value"><c:out value="${not empty customer.fullName ? customer.fullName : 'Khách vãng lai'}" /></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Số điện thoại:</div>
                            <div class="info-value"><c:out value="${not empty customer.phone ? customer.phone : 'Không có'}" /></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Email tài khoản:</div>
                            <div class="info-value"><c:out value="${not empty customer.user.email ? customer.user.email : 'Không có'}" /></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Địa chỉ giao hàng:</div>
                            <div class="info-value"><c:out value="${order.deliveryAddress}" /></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Giờ giao dự kiến:</div>
                            <div class="info-value" style="color: #c07b0c;">
                                <fmt:formatDate value="${order.deliveryWindowStart}" pattern="dd/MM/yyyy HH:mm" />
                                -
                                <fmt:formatDate value="${order.deliveryWindowEnd}" pattern="HH:mm" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div>
                    <!-- Status Management -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-arrows-spin" style="color: var(--cz-primary);"></i> Xử lý trạng thái đơn
                        </div>
                        <form action="${pageContext.request.contextPath}/admin/orders" method="POST" class="status-form">
                            <input type="hidden" name="action" value="update-status">
                            <input type="hidden" name="orderNo" value="${order.orderNo}">
                            
                            <select name="status" class="status-select">
                                <option value="Pending" ${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                                <option value="Confirmed" ${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Đã xác nhận' ? 'selected' : ''}>Đã xác nhận (Bắt đầu làm)</option>
                                <option value="Processing" ${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý' ? 'selected' : ''}>Đang xử lý (Làm bánh xong)</option>
                                <option value="Delivering" ${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao' ? 'selected' : ''}>Đang giao hàng</option>
                                <option value="Completed" ${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao' ? 'selected' : ''}>Đã hoàn thành</option>
                                <option value="Cancelled" ${order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Đã hủy' ? 'selected' : ''}>Hủy đơn hàng</option>
                            </select>

                            <button type="submit" class="btn-update-status" onclick="return confirm('Bạn có chắc chắn muốn chuyển trạng thái đơn hàng này không?')">
                                Cập nhật trạng thái
                            </button>
                        </form>
                    </div>

                    <!-- Payment Summary -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-receipt" style="color: var(--cz-primary);"></i> Tóm tắt thanh toán
                        </div>
                        <div class="cost-row">
                            <span>Tạm tính:</span>
                            <span class="font-mono">
                                <c:set var="subtot" value="0" />
                                <c:forEach items="${order.items}" var="i">
                                    <c:set var="subtot" value="${subtot + (i.priceAtPurchase * i.quantity)}" />
                                </c:forEach>
                                <fmt:formatNumber value="${subtot}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                        <div class="cost-row">
                            <span>Phí vận chuyển:</span>
                            <span class="font-mono">
                                <c:choose>
                                    <c:when test="${order.totalCost > subtot}">
                                        <fmt:formatNumber value="${order.totalCost - subtot}" type="number" pattern="#,##0"/>đ
                                    </c:when>
                                    <c:otherwise>0đ</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cost-row">
                            <span>Đặt cọc trước:</span>
                            <span class="font-mono text-danger">
                                -<fmt:formatNumber value="${order.depositAmount}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                        <div class="cost-row total">
                            <span>Cần thu COD:</span>
                            <span class="font-mono">
                                <fmt:formatNumber value="${order.remainingCodBalance}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                    </div>
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
