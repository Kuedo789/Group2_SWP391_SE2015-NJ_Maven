<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="com.bakeryzone.model.Customer" %>
<%@ page import="com.bakeryzone.model.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<%
    Order order = (Order) request.getAttribute("order");
    Customer customer = (Customer) request.getAttribute("customer");

    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderList");
        return;
    }

    User sessionUser = (User) session.getAttribute("user");
    String recipientName = "Khách hàng";
    String recipientPhone = "";
    if (customer != null) {
        recipientName = customer.getFullName();
        recipientPhone = customer.getPhone();
    } else if (sessionUser != null && sessionUser.getUserId().equals(order.getCustomerId())) {
        recipientName = sessionUser.getFullName();
        recipientPhone = sessionUser.getPhone();
    }

    String dbStatus = order.getOrderStatus();
    String dataStatus = "processing";
    String badgeClass = "status-processing";
    String displayStatus = dbStatus != null ? dbStatus : "Đang xử lý";

    if (dbStatus != null) {
        if (dbStatus.equalsIgnoreCase("Pending")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Chờ xác nhận";
        } else if (dbStatus.equalsIgnoreCase("Confirmed")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Đã xác nhận";
        } else if (dbStatus.equalsIgnoreCase("Processing")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Đang nướng bánh";
        } else if (dbStatus.equalsIgnoreCase("Delivering")) {
            dataStatus = "shipping";
            badgeClass = "status-shipping";
            displayStatus = "Đang giao hàng";
        } else if (dbStatus.equalsIgnoreCase("Completed")) {
            dataStatus = "completed";
            badgeClass = "status-completed";
            displayStatus = "Hoàn thành";
        } else if (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled")) {
            dataStatus = "cancelled";
            badgeClass = "status-cancelled";
            displayStatus = "Đã hủy";
        }
    }

    // Timeline steps activation logic
    boolean step1Active = true; // Đã xác nhận
    boolean step2Active = false; // Đang nướng
    boolean step3Active = false; // Đang giao
    boolean step4Active = false; // Hoàn thành

    if (dbStatus != null) {
        if (dbStatus.equalsIgnoreCase("Processing")) {
            step2Active = true;
        } else if (dbStatus.equalsIgnoreCase("Delivering")) {
            step2Active = true;
            step3Active = true;
        } else if (dbStatus.equalsIgnoreCase("Completed")) {
            step2Active = true;
            step3Active = true;
            step4Active = true;
        }
    }

    // Formatting date and numbers
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("HH:mm, dd/MM/yyyy");

    String orderTimeStr = order.getOrderTime() != null ? dateTimeFormat.format(order.getOrderTime()) : "";

    String deliveryTimeWindow = "";
    if (order.getDeliveryWindowStart() != null && order.getDeliveryWindowEnd() != null) {
        deliveryTimeWindow = timeFormat.format(order.getDeliveryWindowStart()) + " - " + timeFormat.format(order.getDeliveryWindowEnd());
    }

    String deliveryDateStr = "";
    if (order.getDeliveryWindowStart() != null) {
        java.util.Date deliveryDate = new java.util.Date(order.getDeliveryWindowStart().getTime());
        java.util.Date today = new java.util.Date();
        SimpleDateFormat dayCompare = new SimpleDateFormat("yyyyMMdd");
        if (dayCompare.format(deliveryDate).equals(dayCompare.format(today))) {
            deliveryDateStr = "Hôm nay, " + dateFormat.format(deliveryDate);
        } else {
            deliveryDateStr = dateFormat.format(deliveryDate);
        }
    }

    DecimalFormat currencyFormat = new DecimalFormat("#,###");
    DecimalFormatSymbols symbols = new DecimalFormatSymbols();
    symbols.setGroupingSeparator('.');
    currencyFormat.setDecimalFormatSymbols(symbols);

    // Calculate financials
    double subtotal = 0;
    int totalItemsQty = 0;
    if (order.getItems() != null) {
        for (OrderItem item : order.getItems()) {
            double price = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().doubleValue() : 0;
            subtotal += price * item.getQuantity();
            totalItemsQty += item.getQuantity();
        }
    }

    double totalCost = order.getTotalCost() != null ? order.getTotalCost().doubleValue() : 0;
    double shippingFee = 0;
    double discount = 0;

    if (totalCost > 0) {
        if (Math.abs(totalCost - subtotal) < 1.0) {
            shippingFee = 0;
            discount = 0;
        } else {
            shippingFee = 35000; // Phí vận chuyển tiêu chuẩn
            discount = subtotal + shippingFee - totalCost;
            if (discount < 0) {
                shippingFee = totalCost - subtotal;
                discount = 0;
            }
        }
    }

    // Payment Method & Status
    double depositAmount = order.getDepositAmount() != null ? order.getDepositAmount().doubleValue() : 0;
    String paymentMethodStr = "Thanh toán khi nhận hàng (COD)";
    if (depositAmount > 0) {
        if (Math.abs(depositAmount - totalCost) < 1.0) {
            paymentMethodStr = "Chuyển khoản Ngân hàng (Đã thanh toán)";
        } else {
            paymentMethodStr = "Chuyển khoản (Đã đặt cọc " + currencyFormat.format(depositAmount) + "đ)";
        }
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Chi tiết đơn hàng #<%= order.getOrderNo().replace("ORD_", "") %> - BakeryZone</title>
    
    <style>
        .order-detail-page {
            max-width: 1180px;
            margin: 0 auto;
            padding: 120px 32px 90px;
        }

        /* Breadcrumbs */
        .breadcrumbs {
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .breadcrumbs a {
            color: var(--muted);
            transition: color 0.2s;
        }

        .breadcrumbs a:hover {
            color: var(--primary);
        }

        .breadcrumbs span {
            font-size: 12px;
        }

        /* Order Header */
        .order-header-wrap {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 34px;
        }

        .order-header-info h1 {
            margin: 0 0 10px 0;
            font-family: "Playfair Display", serif;
            font-size: 38px;
            font-weight: 800;
            color: var(--text);
        }

        .order-meta-info {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            font-size: 14px;
            color: var(--muted);
        }

        .order-meta-info .status-badge {
            font-size: 11px;
            padding: 6px 16px;
        }

        .order-header-actions {
            display: flex;
            gap: 12px;
        }

        .order-header-actions .btn {
            height: 44px;
            padding: 0 24px;
            font-size: 14px;
            font-weight: 600;
            border-radius: 999px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .btn-support {
            background: var(--bg-soft);
            color: var(--text);
            border: 1px solid var(--border);
        }

        .btn-support:hover {
            background: var(--border);
        }

        .btn-cancel {
            background: #fff0ee;
            color: #bd3d2d;
            border: 1px solid #ffd2cb;
        }

        .btn-cancel:hover {
            background: #fecaca;
        }

        /* Timeline Section */
        .timeline-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 30px;
            box-shadow: var(--shadow-soft);
            margin-bottom: 40px;
        }

        .timeline-container {
            display: flex;
            justify-content: space-between;
            position: relative;
            max-width: 900px;
            margin: 0 auto;
            padding: 10px 0;
        }

        /* The progress bar line behind the circles */
        .timeline-line {
            position: absolute;
            top: 35px;
            left: 50px;
            right: 50px;
            height: 2px;
            background: var(--border);
            z-index: 1;
        }

        .timeline-line-active {
            position: absolute;
            top: 35px;
            left: 50px;
            height: 2px;
            background: var(--primary);
            z-index: 2;
            transition: width 0.4s ease;
        }

        .timeline-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            width: 100px;
            z-index: 3;
        }

        .step-circle {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: var(--bg-soft);
            border: 2px solid var(--border);
            color: var(--muted);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
            transition: all 0.3s ease;
        }

        .step-circle span {
            font-size: 24px;
        }

        .step-text {
            font-size: 14px;
            font-weight: 600;
            color: var(--muted);
            transition: color 0.3s ease;
        }

        /* Active Step styling */
        .timeline-step.active .step-circle {
            background: var(--primary);
            border-color: var(--primary);
            color: #fff;
            box-shadow: 0 0 0 6px var(--primary-soft);
        }

        .timeline-step.active .step-text {
            color: var(--primary-dark);
            font-weight: 700;
        }

        /* Cancelled order banner */
        .cancelled-banner {
            background: #fee2e2;
            border: 1px solid #fecaca;
            color: #991b1b;
            padding: 20px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 40px;
        }

        .cancelled-banner span {
            font-size: 36px;
        }

        .cancelled-banner h3 {
            margin: 0 0 4px 0;
            font-size: 18px;
            font-weight: 700;
        }

        .cancelled-banner p {
            margin: 0;
            font-size: 14px;
            opacity: 0.9;
        }

        /* Bento Grid */
        .bento-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
        }

        .left-column {
            display: flex;
            flex-direction: column;
            gap: 30px;
        }

        /* Cards styling */
        .detail-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            padding: 32px;
            box-shadow: var(--shadow-soft);
        }

        .card-title {
            font-family: "Playfair Display", serif;
            font-size: 22px;
            font-weight: 700;
            color: var(--text);
            margin: 0 0 24px 0;
            border-bottom: 1px solid var(--border);
            padding-bottom: 16px;
        }

        /* Food List */
        .food-list {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .food-item {
            display: flex;
            align-items: center;
            gap: 20px;
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border);
        }

        .food-item:last-child {
            padding-bottom: 0;
            border-bottom: none;
        }

        .food-img {
            width: 80px;
            height: 80px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            background: var(--bg-soft);
            border: 1px solid var(--border);
            flex-shrink: 0;
        }

        .food-details {
            flex: 1;
        }

        .food-name {
            font-size: 16px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 6px;
            line-height: 1.4;
        }

        .food-note {
            font-size: 13px;
            color: var(--muted);
            margin: 4px 0 8px;
        }

        .food-note span {
            font-weight: 500;
        }

        .food-qty-badge {
            font-size: 13px;
            font-weight: 600;
            color: var(--muted);
            background: var(--bg-soft);
            padding: 4px 12px;
            border-radius: 999px;
            display: inline-block;
        }

        .food-price {
            font-size: 18px;
            font-weight: 700;
            color: var(--text);
            white-space: nowrap;
        }

        /* Delivery Grid */
        .delivery-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 30px;
        }

        .delivery-item {
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .delivery-icon-wrap {
            color: var(--primary);
            flex-shrink: 0;
            margin-top: 2px;
        }

        .delivery-icon-wrap span {
            font-size: 26px;
        }

        .delivery-info-wrap {
            display: flex;
            flex-direction: column;
        }

        .delivery-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
            color: var(--muted);
            text-transform: uppercase;
            margin-bottom: 6px;
        }

        .delivery-value {
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            line-height: 1.5;
        }

        .delivery-value strong {
            display: block;
            color: var(--text);
            margin-bottom: 2px;
        }

        /* Right Column - Invoice block */
        .invoice-card {
            background: var(--primary-dark);
            color: #ffffff;
            border-radius: var(--radius-md);
            padding: 32px;
            box-shadow: var(--shadow-soft);
            display: flex;
            flex-direction: column;
            gap: 22px;
        }

        .invoice-title {
            font-family: "Playfair Display", serif;
            font-size: 22px;
            font-weight: 700;
            margin: 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            padding-bottom: 16px;
        }

        .invoice-rows {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .invoice-row {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: rgba(255, 255, 255, 0.8);
            font-weight: 500;
        }

        .invoice-row.discount {
            color: #fca5a5; /* Soft red/pink for discount */
        }

        .invoice-total-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            padding-top: 18px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.12);
            padding-bottom: 18px;
        }

        .invoice-total-label {
            font-size: 16px;
            font-weight: 700;
        }

        .invoice-total-val {
            font-size: 26px;
            font-weight: 800;
        }

        .payment-method-row {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .payment-method-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.5px;
            color: rgba(255, 255, 255, 0.6);
            text-transform: uppercase;
        }

        .payment-method-val {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 600;
        }

        .payment-method-val span {
            font-size: 20px;
        }

        .btn-reorder {
            background: #ffffff;
            color: var(--primary-dark);
            border: none;
            font-weight: 700;
            height: 48px;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.25s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .btn-reorder:hover {
            background: var(--primary-soft);
            transform: translateY(-2px);
        }

        .btn-pdf {
            background: var(--bg-soft);
            color: var(--text);
            border: 1px solid var(--border);
            font-weight: 600;
            height: 48px;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 13px;
            cursor: pointer;
            width: 100%;
            transition: all 0.25s ease;
            margin-top: 16px;
        }

        .btn-pdf:hover {
            background: var(--border);
        }

        /* Responsive styling */
        @media (max-width: 992px) {
            .order-detail-page {
                padding: 100px 16px 60px;
            }

            .bento-grid {
                grid-template-columns: 1fr;
            }

            .delivery-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .order-header-wrap {
                flex-direction: column;
                align-items: stretch;
            }

            .order-header-actions {
                grid-template-columns: 1fr 1fr;
                display: grid;
            }

            .order-header-actions .btn {
                width: 100%;
            }
        }

        @media (max-width: 768px) {
            .timeline-line,
            .timeline-line-active {
                display: none;
            }

            .timeline-container {
                flex-direction: column;
                align-items: flex-start;
                gap: 20px;
                padding-left: 20px;
            }

            .timeline-step {
                flex-direction: row;
                text-align: left;
                width: 100%;
                gap: 16px;
            }

            .step-circle {
                margin-bottom: 0;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <jsp:include page="../common/navbar.jsp" />

    <main class="order-detail-page">
        <!-- Breadcrumbs -->
        <nav class="breadcrumbs">
            <a href="<%= request.getContextPath() %>/home">Trang chủ</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <a href="<%= request.getContextPath() %>/OrderList">Đơn hàng của tôi</a>
            <span class="material-symbols-outlined">chevron_right</span>
            <span>Chi tiết đơn hàng</span>
        </nav>

        <!-- Order Header -->
        <section class="order-header-wrap">
            <div class="order-header-info">
                <h1>Chi tiết đơn hàng #<%= order.getOrderNo().replace("ORD_", "") %></h1>
                <div class="order-meta-info">
                    <span class="status-badge <%= badgeClass %>"><%= displayStatus %></span>
                    <span>•</span>
                    <span>Đặt lúc: <%= orderTimeStr %></span>
                </div>
            </div>
            
            <div class="order-header-actions">
                <button class="btn btn-support" onclick="alert('Hotline hỗ trợ khách hàng: 090 123 4567. BakeryZone rất hân hạnh được hỗ trợ bạn!')">
                    Cần hỗ trợ?
                </button>
                
                <% if (dbStatus != null && (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equalsIgnoreCase("Processing"))) { %>
                    <button class="btn btn-cancel" onclick="confirmCancelOrder()">
                        Hủy đơn hàng
                    </button>
                    <form id="cancelOrderForm" action="<%= request.getContextPath() %>/OrderDetail" method="POST" style="display:none;">
                        <input type="hidden" name="action" value="cancel" />
                        <input type="hidden" name="orderNo" value="<%= order.getOrderNo() %>" />
                    </form>
                <% } %>
            </div>
        </section>

        <!-- Timeline Section / Cancelled Banner -->
        <% if (dbStatus != null && (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled"))) { %>
            <div class="cancelled-banner">
                <span class="material-symbols-outlined">cancel</span>
                <div>
                    <h3>Đơn hàng đã bị hủy</h3>
                    <p>Đơn hàng này đã được hủy bỏ và không thể tiến hành xử lý tiếp. Vui lòng đặt đơn hàng mới hoặc liên hệ tiệm bánh nếu có nhầm lẫn.</p>
                </div>
            </div>
        <% } else { %>
            <div class="timeline-card">
                <%
                    // Calculate active progress line percentage
                    String lineWidth = "0%";
                    if (step4Active) {
                        lineWidth = "100%";
                    } else if (step3Active) {
                        lineWidth = "66.6%";
                    } else if (step2Active) {
                        lineWidth = "33.3%";
                    }
                %>
                <div class="timeline-container">
                    <div class="timeline-line"></div>
                    <div class="timeline-line-active" style="width: <%= lineWidth %>;"></div>
                    
                    <div class="timeline-step <%= step1Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">check_circle</span>
                        </div>
                        <span class="step-text">Đã xác nhận</span>
                    </div>
                    
                    <div class="timeline-step <%= step2Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">cookie</span>
                        </div>
                        <span class="step-text">Đang nướng</span>
                    </div>
                    
                    <div class="timeline-step <%= step3Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">local_shipping</span>
                        </div>
                        <span class="step-text">Đang giao</span>
                    </div>
                    
                    <div class="timeline-step <%= step4Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">star</span>
                        </div>
                        <span class="step-text">Hoàn thành</span>
                    </div>
                </div>
            </div>
        <% } %>

        <!-- Bento Grid Main Content -->
        <div class="bento-grid">
            
            <!-- Left Column: Items and Delivery Address -->
            <div class="left-column">
                
                <!-- Food List Card -->
                <div class="detail-card">
                    <h2 class="card-title">Danh sách món ăn</h2>
                    <div class="food-list">
                    <%
                        com.bakeryzone.dao.ReviewDAO reviewDAO = new com.bakeryzone.dao.ReviewDAO();
                        if (order.getItems() != null && !order.getItems().isEmpty()) {
                            for (OrderItem item : order.getItems()) {
                                String itemImage = item.getItemImage();
                                if (itemImage == null || itemImage.trim().isEmpty()) {
                                    itemImage = request.getContextPath() + "/assets/images/default-cake.png";
                                } else if (!itemImage.startsWith("http") && !itemImage.startsWith("https")) {
                                    if (!itemImage.startsWith("/")) {
                                        itemImage = request.getContextPath() + "/" + itemImage;
                                    } else {
                                        itemImage = request.getContextPath() + itemImage;
                                    }
                                }

                                String formattedPrice = item.getPriceAtPurchase() != null ? currencyFormat.format(item.getPriceAtPurchase()) + "đ" : "0đ";
                                String itemLink = "";
                                if (item.getTemplateId() != null && !item.getTemplateId().trim().isEmpty()) {
                                    itemLink = request.getContextPath() + "/product-detail?id=" + item.getTemplateId().trim();
                                }
                                
                                String itemTemplateId = item.getTemplateId() != null ? item.getTemplateId() : "";
                                String itemCustomCakeId = item.getCustomCakeId() != null ? item.getCustomCakeId() : "";
                                boolean itemReviewed = false;
                                if (sessionUser != null && !itemTemplateId.isEmpty()) {
                                    itemReviewed = reviewDAO.hasReviewed(sessionUser.getUserId(), itemTemplateId);
                                }
                    %>
                                <div class="food-item">
                                    <% if (!itemLink.isEmpty()) { %>
                                        <a href="<%= itemLink %>">
                                            <img class="food-img" src="<%= itemImage %>" data-template-image="<%= item.getTemplateImage() != null ? (item.getTemplateImage().startsWith("http") ? item.getTemplateImage() : request.getContextPath() + "/" + item.getTemplateImage()) : "" %>" alt="<%= item.getItemName() %>" onerror="this.src = this.getAttribute('data-template-image') || '<%= request.getContextPath() %>/assets/images/default-cake.png'; this.onerror = function() { this.src = '<%= request.getContextPath() %>/assets/images/default-cake.png'; };" />
                                        </a>
                                    <% } else { %>
                                        <img class="food-img" src="<%= itemImage %>" alt="<%= item.getItemName() %>" onerror="this.src='<%= request.getContextPath() %>/assets/images/default-cake.png';" />
                                    <% } %>
                                    <div class="food-details">
                                        <% if (!itemLink.isEmpty()) { %>
                                            <div class="food-name"><a href="<%= itemLink %>" style="color: inherit; text-decoration: none;"><%= item.getItemName() %></a></div>
                                        <% } else { %>
                                            <div class="food-name"><%= item.getItemName() %></div>
                                        <% } %>
                                        
                                        <!-- Custom note or Category classification -->
                                        <div class="food-note" style="margin-bottom: 4px;">
                                            <% if (item.getGreetingText() != null && !item.getGreetingText().trim().isEmpty()) { %>
                                                Ghi chú viết lên bánh: <span>"<%= item.getGreetingText() %>"</span>
                                            <% } else { %>
                                                Phân loại: <span><%= item.getCategoryName() != null ? item.getCategoryName() : "Sản phẩm" %></span>
                                            <% } %>
                                        </div>
                                        
                                        <div class="food-version" style="font-size: 13px; color: var(--muted); margin-bottom: 8px;">
                                            Phiên bản: <span><%= item.getVariationName() != null ? item.getVariationName() : "Tiêu chuẩn" %></span>
                                        </div>
                                        
                                        <div class="food-qty-badge" style="margin-bottom: 5px;">Số lượng: x<%= item.getQuantity() %></div>

                                        <% if ("completed".equals(dataStatus) && !itemTemplateId.isEmpty()) { %>
                                            <div style="margin-top: 10px;">
                                                <% if (itemReviewed) { %>
                                                    <button class="btn" style="background: var(--bg-soft); color: var(--text); border: 1px solid var(--border); padding: 5px 12px; font-size: 12px; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer;" onclick="window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review'">Xem đánh giá</button>
                                                <% } else { %>
                                                    <button class="btn" style="background: var(--primary); color: white; border: none; padding: 5px 12px; font-size: 12px; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer;" onclick="window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review&customCakeId=<%= itemCustomCakeId %>'">Đánh giá</button>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                    <div class="food-price"><%= formattedPrice %></div>
                                </div>
                    <%
                            }
                        } else {
                    %>
                            <div style="text-align: center; padding: 20px; color: var(--muted);">Không có sản phẩm nào trong đơn hàng.</div>
                    <%
                        }
                    %>
                    </div>
                </div>
                
                <!-- Delivery Info Card -->
                <div class="detail-card">
                    <h2 class="card-title">Thông tin nhận hàng</h2>
                    <div class="delivery-grid">
                        
                        <!-- Receiver -->
                        <div class="delivery-item">
                            <div class="delivery-icon-wrap">
                                <span class="material-symbols-outlined">person</span>
                            </div>
                            <div class="delivery-info-wrap">
                                <span class="delivery-label">Người nhận</span>
                                <span class="delivery-value">
                                    <strong><%= recipientName %></strong>
                                    <%= recipientPhone %>
                                </span>
                            </div>
                        </div>
                        
                        <!-- Delivery Time Window -->
                        <div class="delivery-item">
                            <div class="delivery-icon-wrap">
                                <span class="material-symbols-outlined">schedule</span>
                            </div>
                            <div class="delivery-info-wrap">
                                <span class="delivery-label">Thời gian giao dự kiến</span>
                                <span class="delivery-value">
                                    <strong><%= deliveryTimeWindow %></strong>
                                    <%= deliveryDateStr %>
                                </span>
                            </div>
                        </div>
                        
                        <!-- Address -->
                        <div class="delivery-item" style="grid-column: span 1;">
                            <div class="delivery-icon-wrap">
                                <span class="material-symbols-outlined">location_on</span>
                            </div>
                            <div class="delivery-info-wrap">
                                <span class="delivery-label">Địa chỉ giao hàng</span>
                                <span class="delivery-value"><%= order.getDeliveryAddress() %></span>
                            </div>
                        </div>
                        
                        <!-- Delivery Note -->
                        <div class="delivery-item">
                            <div class="delivery-icon-wrap">
                                <span class="material-symbols-outlined">note_alt</span>
                            </div>
                            <div class="delivery-info-wrap">
                                <span class="delivery-label">Ghi chú giao hàng</span>
                                <span class="delivery-value">"Vui lòng gọi điện trước khi giao hàng 10 phút, xin cảm ơn!"</span>
                            </div>
                        </div>
                        
                    </div>
                </div>
                
            </div>
            
            <!-- Right Column: Invoice summary -->
            <div>
                <div class="invoice-card">
                    <h2 class="invoice-title">Tóm tắt thanh toán</h2>
                    
                    <div class="invoice-rows">
                        <div class="invoice-row">
                            <span>Tạm tính (<%= totalItemsQty %> món)</span>
                            <span><%= currencyFormat.format(subtotal) %>đ</span>
                        </div>
                        
                        <div class="invoice-row">
                            <span>Phí vận chuyển</span>
                            <span><%= currencyFormat.format(shippingFee) %>đ</span>
                        </div>
                        
                        <% if (discount > 0) { %>
                            <div class="invoice-row discount">
                                <span>Giảm giá (BAKERY10)</span>
                                <span>-<%= currencyFormat.format(discount) %>đ</span>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="invoice-total-row">
                        <span class="invoice-total-label">TỔNG CỘNG</span>
                        <span class="invoice-total-val"><%= currencyFormat.format(totalCost) %>đ</span>
                    </div>
                    
                    <div class="payment-method-row">
                        <span class="payment-method-label">Phương thức thanh toán</span>
                        <span class="payment-method-val">
                            <span class="material-symbols-outlined">credit_card</span>
                            <%= paymentMethodStr %>
                        </span>
                    </div>
                    
                    <% if (dbStatus != null && dbStatus.equalsIgnoreCase("Completed")) { %>
                        <div class="reorder-actions-row" style="display: flex; gap: 10px; width: 100%;">
                            <button class="btn-reorder" style="flex: 1;" onclick="alert('Đã thêm tất cả món ăn trong đơn vào giỏ hàng của bạn!')">
                                <span class="material-symbols-outlined">shopping_bag</span>
                                Mua lại
                            </button>
                            <% if (!firstTplId.isEmpty()) { %>
                                <button class="btn-reorder" style="flex: 1; background: var(--bg-soft); color: var(--text); border: 1px solid var(--border);" onclick="window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= firstTplId %>&tab=review&customCakeId=<%= firstCCId %>'">
                                    <span class="material-symbols-outlined">star</span>
                                    Đánh giá
                                </button>
                            <% } %>

                        </div>
                    <% } %>
                </div>
                
                <button class="btn-pdf" onclick="window.print()">
                    <span class="material-symbols-outlined">download</span>
                    TẢI HÓA ĐƠN (PDF)
                </button>
            </div>
            
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />
    
    <script>
        function confirmCancelOrder() {
            if (confirm("Bạn có chắc chắn muốn hủy đơn hàng này không?")) {
                document.getElementById('cancelOrderForm').submit();
            }
        }
    </script>
</body>
</html>
