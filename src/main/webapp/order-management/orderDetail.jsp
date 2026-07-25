<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="com.bakeryzone.model.User" %>
<%@ page import="com.bakeryzone.model.Customer" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.DecimalFormatSymbols" %>

<c:set var="userRole" value="${sessionScope.user.roleId}" />

<c:choose>
    <c:when test="${userRole eq 'CUSTOMER'}">
<%
    Order order = (Order) request.getAttribute("order");
    Customer customer = (Customer) request.getAttribute("customer");
    String firstTplId = "";
    String firstCCId = "";

    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderList");
        return;
    }

    User sessionUser = (User) session.getAttribute("user");
    String recipientName = order.getReceiverName();
    String recipientPhone = order.getReceiverPhone();
    
    String rawAddress = order.getDeliveryAddress();
    String displayAddress = rawAddress;
    
    if (rawAddress != null && rawAddress.contains("|")) {
        String[] parts = rawAddress.split("\\|");
        if (parts.length >= 3) {
            recipientName = parts[0].trim();
            recipientPhone = parts[1].trim();
            StringBuilder addressBuilder = new StringBuilder();
            for (int i = 2; i < parts.length; i++) {
                if (i > 2) addressBuilder.append(" | ");
                addressBuilder.append(parts[i].trim());
            }
            displayAddress = addressBuilder.toString();
        }
    }

    if (recipientName == null || recipientName.trim().isEmpty()) {
        recipientName = "Khách hàng";
        recipientPhone = "";
        if (customer != null) {
            recipientName = customer.getFullName();
            recipientPhone = customer.getPhone();
        } else if (sessionUser != null && sessionUser.getUserId().equals(order.getCustomerId())) {
            recipientName = sessionUser.getFullName();
            recipientPhone = sessionUser.getPhone();
        }
    }

    String dbStatus = order.getOrderStatus();
    String dataStatus = "processing";
    String badgeClass = "status-processing";
    String displayStatus = dbStatus != null ? dbStatus : "Đang xử lý";

    if (dbStatus != null) {
        displayStatus = order.getOrderStatusForCustomer();
        if (dbStatus.equals("Waiting_Payment")) {
            dataStatus = "processing";
            badgeClass = "status-pending";
        } else if (dbStatus.equals("PAID")) {
            dataStatus = "paid";
            badgeClass = "status-confirmed";
        } else if (dbStatus.equals("Processing") || dbStatus.equals("Waiting_Delivery")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
        } else if (dbStatus.equals("Delivering")) {
            dataStatus = "shipping";
            badgeClass = "status-shipping";
        } else if (dbStatus.equals("Completed")) {
            dataStatus = "completed";
            badgeClass = "status-completed";
        } else if (dbStatus.equals("Cancelled")) {
            dataStatus = "cancelled";
            badgeClass = "status-cancelled";
        }
    }

    // Timeline steps activation logic
    boolean step1Active = false; // Đã nhận đơn
    boolean step2Active = false; // Đang làm bánh (Bao gồm Waiting_Delivery)
    boolean step3Active = false; // Đang giao
    boolean step4Active = false; // Hoàn thành

    if (dbStatus != null) {
        if (!dbStatus.equals("Waiting_Payment") && !dbStatus.equals("Cancelled") && !dbStatus.equals("Canceled")) {
            step1Active = true;
        }

        if (dbStatus.equals("Processing") || dbStatus.equals("Waiting_Delivery")) {
            step2Active = true;
        } else if (dbStatus.equals("Delivering")) {
            step2Active = true;
            step3Active = true;
        } else if (dbStatus.equals("Completed")) {
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
    double shippingFee = order.getShippingFee() != null ? order.getShippingFee().doubleValue() : 0;
    double discount = order.getDiscountAmount() != null ? order.getDiscountAmount().doubleValue() : 0;

    // Fallback if shippingFee/discount are zero but subtotal/totalCost mismatch (legacy orders support)
    if (shippingFee == 0 && discount == 0 && totalCost > 0 && Math.abs(totalCost - subtotal) >= 1.0) {
        shippingFee = 35000;
        discount = subtotal + shippingFee - totalCost;
        if (discount < 0) {
            shippingFee = totalCost - subtotal;
            discount = 0;
        }
    }

    // Payment Method & Status
    String method = order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD";
    String paymentMethodStr = "";
    if ("BANK_TRANSFER_FULL".equalsIgnoreCase(method) || "Chuyển khoản".equalsIgnoreCase(method) || "Bank Transfer".equalsIgnoreCase(method)) {
        paymentMethodStr = "Chuyển khoản (Cần thanh toán: 0đ)";
    } else {
        double remCod = order.getRemainingCodBalance() != null ? order.getRemainingCodBalance().doubleValue() : totalCost;
        paymentMethodStr = "COD (Nhận hàng) (Cần thanh toán: " + currencyFormat.format(remCod) + "đ)";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/header.jsp" />
    <title>Chi tiết đơn hàng #<%= order.getOrderNo().replace("ORD_", "") %> - ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}</title>
</head>
<body>
    <!-- Navigation Bar -->
    <jsp:include page="/common/navbar.jsp" />

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
                <h1>Chi tiết đơn hàng #<span class="order-no-display"><%= order.getOrderNo().replace("ORD_", "") %></span></h1>
                <div class="order-meta-info">
                    <span class="status-badge <%= badgeClass %>"><%= displayStatus %></span>
                    <span>•</span>
                    <span>Đặt lúc: <%= orderTimeStr %></span>
                </div>
            </div>
            
            <div class="order-header-actions" style="display: flex; gap: 12px; margin-left: auto; justify-content: flex-end; align-items: center;">
                <%
                    java.util.Map<String, Object> settingsMap = (java.util.Map<String, Object>) application.getAttribute("settings");
                    String supportHotline = (settingsMap != null && settingsMap.get("hotline") != null) ? (String) settingsMap.get("hotline") : "0901234567";
                    String supportName = (settingsMap != null && settingsMap.get("bakeryName") != null) ? (String) settingsMap.get("bakeryName") : "BakeryZone";
                %>
                
                <% if (dbStatus != null && dbStatus.equals("Waiting_Payment") && order.getDepositAmount() != null && order.getDepositAmount().compareTo(java.math.BigDecimal.ZERO) > 0) { %>
                    <a href="<%= request.getContextPath() %>/bank-transfer?orderNo=<%= order.getOrderNo() %>&total=<%= order.getDepositAmount().toPlainString() %>" class="btn btn-primary" style="background-color: var(--primary); color: white; text-decoration: none; display: flex; align-items: center; gap: 8px; border-radius: 8px; font-weight: 500;">
                        <span class="material-symbols-outlined">qr_code_2</span> Thanh toán ngay
                    </a>
                <% } %>

                <button class="btn btn-support" onclick="alert('Hotline hỗ trợ khách hàng: <%= supportHotline %>. <%= supportName %> rất hân hạnh được hỗ trợ bạn!')">
                    Cần hỗ trợ?
                </button>
                
                <% if (com.bakeryzone.dao.OrderDAO.canCustomerCancel(dbStatus)) { %>
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
                    // Calculate active progress line percentage (cải tiến CSS calc để tránh bị lố)
                    String lineWidth = "0px";
                    if (step4Active) {
                        lineWidth = "calc(100% - 100px)";
                    } else if (step3Active) {
                        lineWidth = "calc(66.6% - 66.6px)";
                    } else if (step2Active) {
                        lineWidth = "calc(33.3% - 33.3px)";
                    }
                %>
                <div class="timeline-container">
                    <div class="timeline-line"></div>
                    <div class="timeline-line-active" style="width: <%= lineWidth %>;"></div>
                    
                    <div class="timeline-step <%= step1Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">shopping_bag</span>
                        </div>
                        <span class="step-text">Đã thanh toán</span>
                    </div>
                    
                    <div class="timeline-step <%= step2Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">skillet</span>
                        </div>
                        <span class="step-text">Đang làm bánh</span>
                    </div>
                    
                    <div class="timeline-step <%= step3Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">local_shipping</span>
                        </div>
                        <span class="step-text">Đang giao</span>
                    </div>
                    
                    <div class="timeline-step <%= step4Active ? "active" : "" %>">
                        <div class="step-circle">
                            <span class="material-symbols-outlined">task_alt</span>
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
                                } else if (!itemImage.startsWith("data:") && !itemImage.startsWith("http://") && !itemImage.startsWith("https://")) {
                                    if (!itemImage.startsWith("/")) {
                                        itemImage = request.getContextPath() + "/" + itemImage;
                                    } else {
                                        itemImage = request.getContextPath() + itemImage;
                                    }
                                }

                                String itemTemplateImage = "";
                                if (item.getTemplateImage() != null && !item.getTemplateImage().trim().isEmpty()) {
                                    String tplImg = item.getTemplateImage();
                                    if (tplImg.startsWith("data:") || tplImg.startsWith("http://") || tplImg.startsWith("https://")) {
                                        itemTemplateImage = tplImg;
                                    } else if (tplImg.startsWith("/")) {
                                        itemTemplateImage = request.getContextPath() + tplImg;
                                    } else {
                                        itemTemplateImage = request.getContextPath() + "/" + tplImg;
                                    }
                                }

                                String formattedPrice = item.getPriceAtPurchase() != null ? currencyFormat.format(item.getPriceAtPurchase()) + "đ" : "0đ";
                                String itemLink = "";
                                if (item.getTemplateId() != null && !item.getTemplateId().trim().isEmpty()) {
                                    itemLink = request.getContextPath() + "/product-detail?id=" + item.getTemplateId().trim();
                                }
                                
                                String itemTemplateId = item.getTemplateId() != null ? item.getTemplateId() : "";
                                String itemCustomCakeId = item.getCustomCakeId() != null ? item.getCustomCakeId() : "";
                                if (firstTplId.isEmpty() && !itemTemplateId.isEmpty()) {
                                    firstTplId = itemTemplateId;
                                    firstCCId = itemCustomCakeId;
                                }
                                boolean itemReviewed = false;
                                if (sessionUser != null && !itemTemplateId.isEmpty()) {
                                    itemReviewed = reviewDAO.hasReviewed(sessionUser.getUserId(), itemTemplateId);
                                }
                    %>
                                <div class="food-item">
                                    <% if (!itemLink.isEmpty()) { %>
                                        <a href="<%= itemLink %>">
                                            <img class="food-img" src="<%= itemImage %>" data-template-image="<%= itemTemplateImage %>" alt="<%= item.getItemName() %>" onerror="this.src = this.getAttribute('data-template-image') || '<%= request.getContextPath() %>/assets/images/default-cake.png'; this.onerror = function() { this.src = '<%= request.getContextPath() %>/assets/images/default-cake.png'; };" />
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
                                        
                                        <!-- Category classification -->
                                        <div class="food-note" style="margin-bottom: 4px;">
                                            Phân loại: <span><%= item.getCategoryName() != null ? item.getCategoryName() : "Sản phẩm" %></span>
                                        </div>
                                        
                                        <div class="food-version" style="font-size: 13px; color: var(--muted); margin-bottom: 8px;">
                                            Phiên bản: <span><%= item.getVariationName() != null ? item.getVariationName() : "Tiêu chuẩn" %></span>
                                        </div>

                                        <% if (item.getGreetingText() != null && !item.getGreetingText().trim().isEmpty()) { %>
                                            <div class="food-note mb-2" style="font-size: 12px; color: #7e22ce; background-color: #f3e8ff; border: 1px solid #e9d5ff; padding: 4px 10px; border-radius: 8px; display: inline-block;">
                                                <i class="fa-solid fa-pen-nib me-1"></i> Thông điệp trang trí: <strong style="color: #6b21a8;"><%= item.getGreetingText() %></strong>
                                            </div>
                                        <% } %>
                                        
                                        <div class="food-qty-badge" style="margin-bottom: 5px;">Số lượng: x<%= item.getQuantity() %></div>

                                        <% if ("completed".equals(dataStatus) && !itemTemplateId.isEmpty()) { %>
                                            <div class="no-print" style="margin-top: 10px;">
                                                <% if (itemReviewed) { %>
                                                    <button class="btn" style="background: var(--bg-soft); color: var(--text); border: 1px solid var(--border); padding: 5px 12px; font-size: 12px; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer;" onclick="event.stopPropagation(); window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review'">Xem đánh giá</button>
                                                <% } else { %>
                                                    <button class="btn" style="background: var(--primary); color: white; border: none; padding: 5px 12px; font-size: 12px; border-radius: var(--radius-sm); font-weight: 600; cursor: pointer;" onclick="event.stopPropagation(); window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review&customCakeId=<%= itemCustomCakeId %>'">Đánh giá</button>
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
                                <span class="delivery-value"><%= displayAddress %></span>
                            </div>
                        </div>
                        
                        <!-- Delivery Note -->
                        <div class="delivery-item">
                            <div class="delivery-icon-wrap">
                                <span class="material-symbols-outlined">note_alt</span>
                            </div>
                            <div class="delivery-info-wrap">
                                <span class="delivery-label">Ghi chú giao hàng</span>
                                <span class="delivery-value">
                                    <%= (order.getCustomerNote() != null && !order.getCustomerNote().trim().isEmpty()) ? order.getCustomerNote() : "Không có ghi chú." %>
                                </span>
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
                    
                    <div class="invoice-row" style="font-weight: 700; border-top: 1px dashed var(--border); padding-top: 15px; margin-top: 5px;">
                        <span>Tổng cộng đơn hàng</span>
                        <span><%= currencyFormat.format(totalCost) %>đ</span>
                    </div>
                    
                    <div class="invoice-row">
                        <span>Phương thức thanh toán</span>
                        <span>
                            <% if ("BANK_TRANSFER_FULL".equalsIgnoreCase(method) || "Chuyển khoản".equalsIgnoreCase(method) || "Bank Transfer".equalsIgnoreCase(method)) { %>
                                Chuyển khoản
                            <% } else { %>
                                COD (Nhận hàng)
                            <% } %>
                        </span>
                    </div>
                    
                    <div class="invoice-row">
                        <span>Tiền đặt cọc</span>
                        <span>
                            <% if ("BANK_TRANSFER_FULL".equalsIgnoreCase(method) || "Chuyển khoản".equalsIgnoreCase(method) || "Bank Transfer".equalsIgnoreCase(method)) { %>
                                0đ
                            <% } else { %>
                                <%= currencyFormat.format(order.getDepositAmount() != null ? order.getDepositAmount().doubleValue() : 0) %>đ
                            <% } %>
                        </span>
                    </div>
                    
                    <div class="invoice-total-row" style="border-top: 1px dashed var(--border); padding-top: 16px; margin-top: 16px; font-size: 1.1rem; font-weight: 700;">
                        <span class="invoice-total-label">THÀNH TIỀN: </span>
                        <span class="invoice-total-val">
                            <% if ("BANK_TRANSFER_FULL".equalsIgnoreCase(method) || "Chuyển khoản".equalsIgnoreCase(method) || "Bank Transfer".equalsIgnoreCase(method)) { %>
                                0đ
                            <% } else { %>
                                <%= currencyFormat.format(order.getRemainingCodBalance() != null ? order.getRemainingCodBalance().doubleValue() : 0) %>đ
                            <% } %>
                        </span>
                    </div>
                    
                    <% 
                        StringBuilder jsonBuilder = new StringBuilder();
                        jsonBuilder.append("[");
                        if (order.getItems() != null) {
                            for (int idx = 0; idx < order.getItems().size(); idx++) {
                                OrderItem item = order.getItems().get(idx);
                                if (idx > 0) jsonBuilder.append(",");
                                jsonBuilder.append("{");
                                
                                String tplId = item.getTemplateId() != null ? item.getTemplateId() : "";
                                String varName = item.getVariationName() != null ? item.getVariationName() : "Tiêu chuẩn";
                                double price = item.getCurrentPrice() != null ? item.getCurrentPrice().doubleValue() : 0.0;
                                int qty = item.getQuantity();
                                String name = item.getItemName() != null ? item.getItemName().replace("\"", "\\\"") : "";
                                String image = item.getItemImage() != null ? item.getItemImage().replace("\\", "/") : "assets/images/default-cake.png";
                                
                                jsonBuilder.append("\"templateId\":\"").append(tplId).append("\",");
                                jsonBuilder.append("\"variationName\":\"").append(varName).append("\",");
                                jsonBuilder.append("\"price\":").append(price).append(",");
                                jsonBuilder.append("\"qty\":").append(qty).append(",");
                                jsonBuilder.append("\"name\":\"").append(name).append("\",");
                                jsonBuilder.append("\"image\":\"").append(image).append("\"");
                                
                                jsonBuilder.append("}");
                            }
                        }
                        jsonBuilder.append("]");
                        String escapedJson = jsonBuilder.toString().replace("'", "\\'").replace("\"", "&quot;");
                    %>
                    <% if (dbStatus != null && (dbStatus.equalsIgnoreCase("Completed") || dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled"))) { %>
                        <div class="reorder-actions-row no-print" style="display: flex; gap: 10px; width: 100%;">
                            <button class="btn-reorder" style="flex: 1;" onclick="reorderOrder('<%= order.getOrderNo() %>')">
                                <span class="material-symbols-outlined">shopping_bag</span>
                                Đặt lại
                            </button>
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
    <jsp:include page="/common/footer.jsp" />
    <jsp:include page="/common/scripts.jsp" />
    
    <script>
        function confirmCancelOrder() {
            if (confirm("Bạn có chắc chắn muốn hủy đơn hàng này không?")) {
                document.getElementById('cancelOrderForm').submit();
            }
        }

        function reorderOrder(orderNo) {
            if (!orderNo) return;
            const ctxPath = '<%= request.getContextPath() %>';
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = ctxPath + '/cart';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'reorderToCheckout';
            form.appendChild(actionInput);
            
            const orderNoInput = document.createElement('input');
            orderNoInput.type = 'hidden';
            orderNoInput.name = 'orderNo';
            orderNoInput.value = orderNo;
            form.appendChild(orderNoInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>

    </c:when>
    <c:otherwise>

<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="${userRole eq 'SHIPPER' ? 'CakeZone Shipper' : 'CakeZone Admin'} - Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}" />
    </jsp:include>
    <!-- Order Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
</head>
<body>

    <div class="no-print">
    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>
    </div>

    <div class="main-panel">
        <!-- Top Header -->
        <jsp:include page="/common/top-header.jsp">
            <jsp:param name="parentMenu" value="${userRole eq 'SHIPPER' ? 'Đơn hàng được phân công' : 'Quản lý đơn hàng'}" />
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/${userRole eq 'SHIPPER' ? 'shipper' : 'admin'}/orders${userRole eq 'SHIPPER' ? '?action=list' : ''}" />
            <jsp:param name="activeMenu" value="Chi tiết đơn hàng" />
        </jsp:include>

        <div class="content-container">
            <a href="${pageContext.request.contextPath}/${userRole eq 'SHIPPER' ? 'shipper' : 'admin'}/orders" class="btn-back">
                <i class="fa-solid fa-arrow-left-long"></i> Quay lại danh sách đơn hàng
            </a>

            <!-- Popups notification standard -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="admin-success-banner">
                    <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="admin-error-banner">
                    <i class="fa-solid fa-circle-exclamation me-2"></i> ${sessionScope.errorMessage}
                </div>
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}</h1>
                </div>
                <div>
                    <c:choose>
                        <c:when test="${order.orderStatus eq 'PAID'}">
                            <span class="status-badge status-paid" style="background-color: #d1fae5; color: #065f46;">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Processing'}">
                            <span class="status-badge status-processing">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Waiting_Delivery'}">
                            <span class="status-badge status-delivering">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Delivering'}">
                            <span class="status-badge status-delivering">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Completed'}">
                            <span class="status-badge status-completed">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Cancelled'}">
                            <span class="status-badge status-cancelled">${order.orderStatusVietnamese}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge status-pending">${order.orderStatusVietnamese}</span>
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
                                    String tplId     = oi.getTemplateId();
                                    String itemLink  = "";
                                    if (tplId != null && !tplId.trim().isEmpty()) {
                                        itemLink = ctxPath + "/product-detail?id=" + tplId.trim();
                                    }
                        %>
                            <div class="order-item-row">
                                <% if (itemLink != null && !itemLink.isEmpty()) { %>
                                    <a href="<%= itemLink %>" title="Xem chi tiết sản phẩm">
                                        <img src="<%= resolvedImg %>" data-template-image="<%= resolvedTemplateImg %>" alt="<%= itemName %>" class="item-img item-img-clickable"
                                             onerror="this.src = this.getAttribute('data-template-image') || '<%= defaultImg %>'; this.onerror = function() { this.src = '<%= defaultImg %>'; };">
                                    </a>
                                <% } else { %>
                                    <img src="<%= resolvedImg %>" data-template-image="<%= resolvedTemplateImg %>" alt="<%= itemName %>" class="item-img"
                                         onerror="this.src = this.getAttribute('data-template-image') || '<%= defaultImg %>'; this.onerror = function() { this.src = '<%= defaultImg %>'; };">
                                <% } %>
                                <div class="item-details">
                                    <% if (itemLink != null && !itemLink.isEmpty()) { %>
                                        <div class="item-name"><a href="<%= itemLink %>" class="item-name-link" title="Xem chi tiết sản phẩm"><%= itemName %></a></div>
                                    <% } else { %>
                                        <div class="item-name"><%= itemName %></div>
                                    <% } %>
                                    <div class="item-meta">Phân loại: <span><%= catName %></span></div>
                                    <div class="item-meta">Kích cỡ/Tùy chọn: <span><%= varName %></span></div>
                                    <% if (greeting != null && !greeting.trim().isEmpty()) { %>
                                        <div class="item-meta mt-1 mb-1" style="font-size: 12px; color: #7e22ce; background-color: #f3e8ff; border: 1px solid #e9d5ff; padding: 4px 10px; border-radius: 8px; display: inline-block;">
                                            <i class="fa-solid fa-pen-nib me-1"></i> Thông điệp trang trí: <strong style="color: #6b21a8;"><%= greeting %></strong>
                                        </div>
                                    <% } %>
                                    <% 
                                        String displayCakeId = "";
                                        if (tplId != null && !tplId.trim().isEmpty()) {
                                            displayCakeId = tplId;
                                        } else if (ccId != null && !ccId.trim().isEmpty()) {
                                            displayCakeId = ccId;
                                        }
                                        if (!displayCakeId.isEmpty()) {
                                    %>
                                         <div class="item-meta" style="font-size: 11px;">
                                             Mã bánh: <span><%= displayCakeId %></span>
                                         </div>
                                     <% } %>
                                </div>
                                <div class="item-price-qty">
                                    <div class="item-price font-mono"><%= czFmt.format(price) %>đ</div>
                                    <div class="item-qty">Số lượng: x<%= qty %></div>
                                    <div class="item-qty fw-bold item-qty-total">
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
                        <%
                            Order curOrder = (Order) request.getAttribute("order");
                            com.bakeryzone.model.Customer curCust = (com.bakeryzone.model.Customer) request.getAttribute("customer");
                            
                            String rawAddr = curOrder != null ? curOrder.getDeliveryAddress() : "";
                            String displayAddr = rawAddr;
                            String recName = curOrder != null ? curOrder.getReceiverName() : "";
                            String recPhone = curOrder != null ? curOrder.getReceiverPhone() : "";

                            if (rawAddr != null && rawAddr.contains("|")) {
                                String[] parts = rawAddr.split("\\|");
                                if (parts.length >= 3) {
                                    recName = parts[0].trim();
                                    recPhone = parts[1].trim();
                                    StringBuilder sb = new StringBuilder();
                                    for (int i = 2; i < parts.length; i++) {
                                        if (i > 2) sb.append(" | ");
                                        sb.append(parts[i].trim());
                                    }
                                    displayAddr = sb.toString();
                                }
                            }

                            if (recName == null || recName.trim().isEmpty()) {
                                recName = (curCust != null && curCust.getFullName() != null) ? curCust.getFullName() : "Khách vãng lai";
                                recPhone = (curCust != null && curCust.getPhone() != null) ? curCust.getPhone() : "Không có";
                            }
                            request.setAttribute("googleMapsQueryAddress", displayAddr);
                        %>
                        <div class="info-row">
                            <div class="info-label">Khách hàng đặt:</div>
                            <div class="info-value"><%= (curCust != null && curCust.getFullName() != null) ? curCust.getFullName() : "Khách vãng lai" %></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Người nhận:</div>
                            <div class="info-value"><%= recName %></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">SĐT người nhận:</div>
                            <div class="info-value">
                                <a href="tel:<%= recPhone %>" style="color: var(--cz-primary); font-weight: bold; text-decoration: none;">
                                    <i class="fa-solid fa-phone me-1"></i> <%= recPhone %> (Nhấp để gọi)
                                </a>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Địa chỉ giao hàng:</div>
                            <div class="info-value">
                                <c:url var="googleMapsUrl" value="https://www.google.com/maps/search/">
                                    <c:param name="api" value="1" />
                                    <c:param name="query" value="${googleMapsQueryAddress}" />
                                </c:url>
                                <a href="${googleMapsUrl}" target="_blank" style="color: #0d6efd; font-weight: 500; text-decoration: none;">
                                    <i class="fa-solid fa-map-location-dot me-1"></i> <%= displayAddr %> (Xem trên Google Maps)
                                </a>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Giờ giao dự kiến:</div>
                            <div class="info-value delivery-time-highlight">
                                <fmt:formatDate value="${order.deliveryWindowStart}" pattern="dd/MM/yyyy HH:mm" />
                                -
                                <fmt:formatDate value="${order.deliveryWindowEnd}" pattern="HH:mm" />
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Ghi chú của khách:</div>
                            <div class="info-value text-danger">
                                <c:out value="${not empty order.customerNote ? order.customerNote : 'Không có ghi chú'}" />
                            </div>
                        </div>
                        <c:if test="${not empty order.shipperNote}">
                            <div style="background-color: #fff5f5; border: 1px solid #feb2b2; border-radius: 8px; padding: 15px; margin-top: 15px; display: flex; flex-direction: column; gap: 6px;">
                                <div style="color: #c53030; font-size: 13px; font-weight: 700; display: flex; align-items: center; gap: 6px;">
                                    <i class="fa-solid fa-circle-exclamation"></i> LÝ DO GIAO HÀNG THẤT BẠI (Từ Shipper):
                                </div>
                                <div style="color: #9b2c2c; font-size: 14px; font-weight: 600; line-height: 1.5; word-break: break-word;">
                                    <c:out value="${order.shipperNote}" />
                                </div>
                            </div>
                        </c:if>
                    </div>

                    <!-- Bằng chứng giao hàng (Shipper tải lên trực tiếp) -->
                    <div class="cz-card no-print">
                        <div class="cz-card-title" style="margin-bottom: 15px;">
                            <i class="fa-solid fa-camera" style="color: var(--cz-primary);"></i> Chụp ảnh minh chứng giao hàng
                        </div>
                        <div class="row" style="padding: 10px 20px;">
                            <!-- 1. Minh chứng lấy bánh tại tiệm -->
                            <div class="col-md-6 text-center" style="border-right: 1px dashed #ddd; padding: 15px;">
                                <h6 class="proof-placeholder-title">1. Ảnh lấy bánh tại tiệm (Pickup)</h6>
                                <div id="pickup-preview-container" class="proof-placeholder-box">
                                    <c:choose>
                                        <c:when test="${not empty pickupPhoto}">
                                            <img src="${pageContext.request.contextPath}/${pickupPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã có ảnh lấy bánh
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image proof-placeholder-icon"></i>
                                            <span class="proof-placeholder-text">Chưa chụp ảnh lấy bánh.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${userRole eq 'SHIPPER'}">
                                    <input type="file" id="pickup-file-input" accept="image/*" capture="camera" style="display: none;" onchange="uploadEvidence(this, 'pickup')">
                                <button type="button" class="btn" style="background-color: var(--cz-primary); color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="openWebRTCCamera('pickup')">
                                    <i class="fa-solid fa-camera"></i> Chụp ảnh lấy bánh
                                </button>
                                </c:if>
                            </div>
                            
                            <!-- 2. Minh chứng giao bánh cho khách -->
                            <div class="col-md-6 text-center" style="padding: 15px;">
                                <h6 class="proof-placeholder-title">2. Ảnh bàn giao cho khách (Delivery)</h6>
                                <div id="delivery-preview-container" class="proof-placeholder-box">
                                    <c:choose>
                                        <c:when test="${not empty deliveryPhoto}">
                                            <img src="${pageContext.request.contextPath}/${deliveryPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã có ảnh giao bánh
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image proof-placeholder-icon"></i>
                                            <span class="proof-placeholder-text">Chưa chụp ảnh giao bánh.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${userRole eq 'SHIPPER'}">
                                <input type="file" id="delivery-file-input" accept="image/*" capture="camera" style="display: none;" onchange="uploadEvidence(this, 'delivery')" ${empty pickupPhoto ? 'disabled' : ''}>
                                <button type="button" class="btn" id="btn-delivery-upload" style="background-color: ${empty pickupPhoto ? '#aaa' : 'var(--cz-primary)'}; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="${empty pickupPhoto ? "showToast('Bạn cần chụp ảnh lấy bánh tại tiệm trước!', 'error')" : "openWebRTCCamera('delivery')"}" ${empty pickupPhoto ? 'disabled' : ''}>
                                    <i class="fa-solid fa-camera"></i> Chụp ảnh giao bánh
                                </button>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div>
                    <!-- Status Management -->
                    
                    <div class="cz-card no-print">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-arrows-spin" style="color: var(--cz-primary);"></i> Xử lý trạng thái đơn
                        </div>
                        <c:choose>
                            <c:when test="${userRole eq 'SHIPPER'}">

                        <c:choose>
                            <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao' || order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Canceled' || order.orderStatus eq 'Đã hủy'}">
                                <div style="padding: 20px; text-align: center; color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 6px; font-weight: bold;">
                                    <i class="fa-solid fa-lock" style="font-size: 24px; margin-bottom: 8px; display: block; color: #721c24;"></i>
                                    Đơn hàng đã hoàn thành hoặc đã hủy. Không thể thay đổi trạng thái nữa.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/shipper/orders" method="POST" class="status-form" onsubmit="return validateStatusChange()">
                                    <input type="hidden" name="action" value="update-status">
                                    <input type="hidden" name="orderNo" value="${order.orderNo}">
                                    
                                    <select name="status" id="shipper-status-select" class="status-select" style="padding: 12px; width: 100%; border-radius: 6px; border: 1px solid #ccc; font-weight: 500; font-size: 14.5px; margin-bottom: 15px;">
                                        <c:if test="${order.orderStatus eq 'PAID'}">
                                            <option value="PAID" selected disabled>Đã thanh toán (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Processing'}">
                                            <option value="Processing" selected disabled>Đang làm bánh (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Waiting_Delivery'}">
                                            <option value="Waiting_Delivery" selected disabled><%= com.bakeryzone.model.OrderStatus.Waiting_Delivery.getDescription() %> (Chỉ đọc)</option>
                                        </c:if>
                                        <option value="Delivering" ${order.orderStatus eq 'Delivering' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Delivering.getDescription() %></option>
                                        <option value="Completed" ${order.orderStatus eq 'Completed' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Completed.getDescription() %></option>
                                        <option value="Cancelled" ${order.orderStatus eq 'Cancelled' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Cancelled.getDescription() %></option>
                                    </select>
                                    
                                    <div id="cancel-reason-container" style="display: none; margin-bottom: 15px;">
                                        <label for="shipper-note-input" style="font-weight: 600; font-size: 13px; margin-bottom: 6px; display: block; color: #b91c1c;">Lý do hủy / Giao thất bại (*):</label>
                                        <textarea name="shipperNote" id="shipper-note-input" rows="3" style="width: 100%; border-radius: 6px; padding: 10px; border: 1px solid #f8b4b4; font-size: 13.5px; box-sizing: border-box;" placeholder="Nhập lý do giao hàng thất bại (ví dụ: Khách hẹn hôm khác, Không liên lạc được...)"></textarea>
                                    </div>

                                    <button type="submit" class="btn-update-status" style="width: 100%; padding: 12px; font-weight: bold;">
                                        Cập nhật trạng thái
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                            </c:when>
                            <c:otherwise>
                            
                        <c:choose>
                            <c:when test="${order.orderStatus eq 'Waiting_Payment' || order.orderStatus eq 'WAITING_PAYMENT'}">
                                <div style="padding: 20px; text-align: center; color: #856404; background-color: #fff3cd; border: 1px solid #ffeeba; border-radius: 6px; font-weight: bold;">
                                    <i class="fa-solid fa-hourglass-half" style="font-size: 24px; margin-bottom: 8px; display: block; color: #856404;"></i>
                                    Đơn hàng đang chờ thanh toán.<br>Hệ thống sẽ tự động cập nhật khi khách thanh toán xong.
                                </div>
                            </c:when>
                            <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Cancelled'}">
                                <div style="padding: 20px; text-align: center; color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 6px; font-weight: bold;">
                                    <i class="fa-solid fa-lock" style="font-size: 24px; margin-bottom: 8px; display: block; color: #721c24;"></i>
                                    Đơn hàng đã hoàn thành hoặc đã hủy.<br>Không thể thay đổi trạng thái nữa.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/admin/orders" method="POST" class="status-form">
                                    <input type="hidden" name="action" value="update-status">
                                    <input type="hidden" name="orderNo" value="${order.orderNo}">

                                    <%-- Xác định level hiện tại --%>
                                    <c:set var="statusLevel" value="0" />
                                    <c:if test="${order.orderStatus eq 'PAID'}"><c:set var="statusLevel" value="1" /></c:if>
                                    <c:if test="${order.orderStatus eq 'Processing'}"><c:set var="statusLevel" value="2" /></c:if>
                                    <c:if test="${order.orderStatus eq 'Waiting_Delivery'}"><c:set var="statusLevel" value="3" /></c:if>
                                    <c:if test="${order.orderStatus eq 'Delivering'}"><c:set var="statusLevel" value="4" /></c:if>

                                    <%-- Xác định role hiện tại --%>
                                    <c:set var="isStaff" value="${sessionScope.user.roleId eq 'STAFF'}" />

                                    <select name="status" class="status-select" style="padding: 10px; width: 100%; border-radius: 6px; border: 1px solid #ccc; font-weight: 500; font-size: 14.5px;">
                                        <%-- PAID: chỉ chọn nếu đang ở PAID --%>
                                        <option value="PAID"
                                            ${statusLevel == 1 ? 'selected' : ''}
                                            ${statusLevel > 1 ? 'disabled' : ''}><%= com.bakeryzone.model.OrderStatus.PAID.getDescription() %></option>

                                        <%-- Processing: PAID → Processing --%>
                                        <option value="Processing"
                                            ${statusLevel == 2 ? 'selected' : ''}
                                            ${statusLevel > 2 ? 'disabled' : ''}><%= com.bakeryzone.model.OrderStatus.Processing.getDescription() %></option>

                                        <%-- Waiting_Delivery: Processing → Waiting_Delivery --%>
                                        <option value="Waiting_Delivery"
                                            ${statusLevel == 3 ? 'selected' : ''}
                                            ${statusLevel > 3 ? 'disabled' : ''}><%= com.bakeryzone.model.OrderStatus.Waiting_Delivery.getDescription() %></option>

                                        <%-- Delivering: chỉ Admin được phép từ Waiting_Delivery trở lên --%>
                                        <c:if test="${!isStaff}">
                                            <option value="Delivering"
                                                ${statusLevel == 4 ? 'selected' : ''}
                                                ${statusLevel > 4 ? 'disabled' : ''}><%= com.bakeryzone.model.OrderStatus.Delivering.getDescription() %></option>

                                            <option value="Completed"><%= com.bakeryzone.model.OrderStatus.Completed.getDescription() %></option>
                                        </c:if>

                                        <%-- Cancelled: luôn hiển thị (Admin & Staff đều hủy được từ PAID/Processing) --%>
                                        <c:if test="${statusLevel <= 2}">
                                            <option value="Cancelled"><%= com.bakeryzone.model.OrderStatus.Cancelled.getDescription() %></option>
                                        </c:if>
                                    </select>

                                    <button type="submit" class="btn btn-update-status mt-3 w-100" style="padding: 10px; border-radius: 8px; font-weight: bold;">
                                        <i class="fa-solid fa-floppy-disk me-1"></i> Cập nhật trạng thái
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                            </c:otherwise>
                        </c:choose>
                    </div>


                    <!-- Payment Summary -->
                    <%
                        int calcDepPercent = 0;
                        double calcDiscountVal = 0;
                        com.bakeryzone.model.Order orderObj = (com.bakeryzone.model.Order) request.getAttribute("order");
                        if (orderObj != null) {
                            double totalCostVal = orderObj.getTotalCost() != null ? orderObj.getTotalCost().doubleValue() : 0;
                            double depositAmtVal = orderObj.getDepositAmount() != null ? orderObj.getDepositAmount().doubleValue() : 0;
                            if (totalCostVal > 0) {
                                calcDepPercent = (int) Math.round((depositAmtVal * 100) / totalCostVal);
                                if (calcDepPercent > 100) {
                                    calcDepPercent = 100;
                                }
                            }
                            
                            if (orderObj.getDiscountAmount() != null && orderObj.getDiscountAmount().doubleValue() > 0) {
                                calcDiscountVal = orderObj.getDiscountAmount().doubleValue();
                            } else if (orderObj.getAppliedVoucherCode() != null && !orderObj.getAppliedVoucherCode().trim().isEmpty()) {
                                double sub = 0;
                                if (orderObj.getItems() != null) {
                                    for (com.bakeryzone.model.OrderItem item : orderObj.getItems()) {
                                        double p = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().doubleValue() : 0;
                                        sub += p * item.getQuantity();
                                    }
                                }
                                double ship = orderObj.getShippingFee() != null ? orderObj.getShippingFee().doubleValue() : 0;
                                if (sub + ship > totalCostVal && totalCostVal > 0) {
                                    calcDiscountVal = (sub + ship) - totalCostVal;
                                }
                            }
                        }
                        pageContext.setAttribute("calcDepPercent", calcDepPercent);
                        pageContext.setAttribute("calcDiscountVal", calcDiscountVal);
                    %>
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
                                <fmt:formatNumber value="${not empty order.shippingFee ? order.shippingFee : 0}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                        <div class="cost-row" style="color: ${calcDiscountVal > 0 ? '#2b8a3e' : 'inherit'};">
                            <span>Voucher giảm giá <c:if test="${not empty order.appliedVoucherCode}">(${order.appliedVoucherCode})</c:if>:</span>
                            <span class="font-mono">
                                <c:choose>
                                    <c:when test="${calcDiscountVal > 0}">
                                        -<fmt:formatNumber value="${calcDiscountVal}" type="number" pattern="#,##0"/>đ
                                    </c:when>
                                    <c:otherwise>0đ</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <c:set var="calcTotal" value="${subtot + (not empty order.shippingFee ? order.shippingFee : 0) - calcDiscountVal}" />
                        <div class="cost-row" style="font-weight: 700; border-top: 1px dashed #ddd; border-bottom: 1px dashed #ddd; padding: 6px 0; margin: 6px 0;">
                            <span>Tổng cộng đơn hàng:</span>
                            <span class="font-mono" style="font-size: 16px;">
                                <fmt:formatNumber value="${calcTotal > 0 ? calcTotal : (not empty order.totalCost ? order.totalCost : 0)}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                        <div class="cost-row">
                            <span>Phương thức thanh toán:</span>
                            <span style="font-weight: 500;">
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'BANK_TRANSFER_FULL' || order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        Chuyển khoản
                                    </c:when>
                                    <c:otherwise>
                                        COD (Nhận hàng)
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cost-row">
                            <span>
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'BANK_TRANSFER_FULL' || order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        Tiền đặt cọc (0%):
                                    </c:when>
                                    <c:otherwise>
                                        Tiền đặt cọc (${calcDepPercent}%):
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <span class="font-mono">
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'BANK_TRANSFER_FULL' || order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        0đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${not empty order.depositAmount ? order.depositAmount : 0}" type="number" pattern="#,##0"/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cost-row total" style="background-color: #fdf2f2; border: 1px dashed #f8b4b4; padding: 10px; border-radius: 6px; margin-top: 15px;">
                            <span style="color: #9b1c1c; font-weight: 800;">THÀNH TIỀN:</span>
                            <span class="font-mono" style="color: #9b1c1c; font-size: 18px; font-weight: 800;">
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'BANK_TRANSFER_FULL' || order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        0đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${not empty order.remainingCodBalance ? order.remainingCodBalance : 0}" type="number" pattern="#,##0"/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <!-- Print Invoice Button - below payment summary -->
                        <button class="no-print btn-pdf" onclick="window.print()" style="width: 100%; margin-top: 20px; display: flex; align-items: center; justify-content: center; gap: 10px; padding: 14px; background: var(--cz-primary); color: white; border: none; border-radius: 8px; font-size: 15px; font-weight: 700; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.15);">
                            <i class="fa-solid fa-file-arrow-down"></i> Tải hóa đơn (PDF)
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <c:if test="${userRole eq 'SHIPPER'}">
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

    <script>
        function showToast(message, type = 'success') {
            const isSuccess = (type === 'success');
            Toastify({
                text: message,
                duration: 3500,
                close: true,
                gravity: "top",
                position: "right",
                style: {
                    background: isSuccess 
                        ? "linear-gradient(to right, #00b09b, #96c93d)" 
                        : "linear-gradient(to right, #ff5f6d, #ffc371)",
                    color: "#ffffff",
                    borderRadius: "8px",
                    fontWeight: "600",
                    fontSize: "14px",
                    boxShadow: "0 4px 12px rgba(0,0,0,0.15)"
                },
                stopOnFocus: true
            }).showToast();
        }

        function uploadEvidence(inputElement, type) {
            const file = inputElement.files[0];
            if (!file) return;

            // Kiểm tra kích thước file (giới hạn 10MB)
            if (file.size > 10 * 1024 * 1024) {
                showToast("⚠️ Kích thước ảnh quá lớn, vui lòng chọn ảnh dưới 10MB!", "error");
                return;
            }

            // Hiển thị trạng thái đang tải lên
            const previewContainer = document.getElementById(type + '-preview-container');
            const originalHTML = previewContainer.innerHTML;
            previewContainer.innerHTML = `
                <div class="spinner-border text-primary" role="status" style="width: 2rem; height: 2rem; margin-bottom: 8px;">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <span style="font-size: 12px; color: #555; display: block;">Đang tải lên ảnh...</span>
            `;

            // Chuẩn bị dữ liệu FormData gửi lên Servlet
            const formData = new FormData();
            formData.append("file", file);
            formData.append("tripId", "${order.tripId}");
            formData.append("orderNo", "${order.orderNo}");
            formData.append("type", type);

            // Gửi Fetch POST lên servlet
            fetch("${pageContext.request.contextPath}/shipper/orders", {
                method: "POST",
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast("🎉 " + data.message, "success");
                    // Tải lại trang để đồng bộ hoàn toàn trạng thái mới từ database
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                } else {
                    showToast("❌ Lỗi: " + data.message, "error");
                    previewContainer.innerHTML = originalHTML;
                }
            })
            .catch(error => {
                console.error("Lỗi upload minh chứng:", error);
                showToast("❌ Đã xảy ra lỗi kết nối khi tải ảnh lên!", "error");
                previewContainer.innerHTML = originalHTML;
            });
        }

        function validateStatusChange() {
            const statusSelect = document.getElementById('shipper-status-select');
            const selectedStatus = statusSelect.value;
            
            // Ràng buộc ảnh minh chứng với từng trạng thái
            if (selectedStatus === 'Delivering') {
                const hasPickupPhoto = "${not empty pickupPhoto}" === "true";
                if (!hasPickupPhoto) {
                    showToast('⚠️ Bạn phải chụp ảnh lấy bánh thành công tại tiệm trước khi cập nhật đơn hàng thành "Đang giao hàng"!', 'error');
                    return false;
                }
            }
            
            if (selectedStatus === 'Completed') {
                const hasDeliveryPhoto = "${not empty deliveryPhoto}" === "true";
                if (!hasDeliveryPhoto) {
                    showToast('⚠️ Bạn phải chụp ảnh giao bánh thành công cho khách trước khi cập nhật đơn hàng thành "Hoàn thành"!', 'error');
                    return false;
                }
            }
            
            if (selectedStatus === 'Cancelled') {
                const reasonInput = document.getElementById('shipper-note-input');
                if (!reasonInput || !reasonInput.value.trim()) {
                    showToast('⚠️ Bạn phải nhập lý do hủy / giao hàng thất bại!', 'error');
                    if (reasonInput) reasonInput.focus();
                    return false;
                }
            }
            
            return confirm('Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng này?');
        }

        document.addEventListener('DOMContentLoaded', function() {
            <c:if test="${not empty sessionScope.successMessage}">
                showToast("${sessionScope.successMessage}", "success");
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                showToast("${sessionScope.errorMessage}", "error");
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            // Toggle hiển thị lý do hủy đơn
            const statusSelect = document.getElementById('shipper-status-select');
            const cancelReasonContainer = document.getElementById('cancel-reason-container');
            
            if (statusSelect && cancelReasonContainer) {
                statusSelect.addEventListener('change', function() {
                    if (this.value === 'Cancelled') {
                        cancelReasonContainer.style.display = 'block';
                    } else {
                        cancelReasonContainer.style.display = 'none';
                    }
                });
                
                // Kiểm tra trạng thái lúc khởi tạo
                if (statusSelect.value === 'Cancelled') {
                    cancelReasonContainer.style.display = 'block';
                }
            }
        });

        // WebRTC Live Camera controller
        let cameraStream = null;
        let currentPhotoType = null;

        function openWebRTCCamera(type) {
            currentPhotoType = type;
            
            // Check WebRTC compatibility
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                console.warn("WebRTC is not supported. Falling back to device input file.");
                document.getElementById(type + '-file-input').click();
                return;
            }
            
            const cameraModalEl = document.getElementById('cameraModal');
            const cameraModal = new bootstrap.Modal(cameraModalEl);
            cameraModal.show();
            
            startCamera();
        }

        function startCamera() {
            // Reset modal ui state
            document.getElementById('camera-video').style.display = 'block';
            document.getElementById('captured-preview').style.display = 'none';
            
            document.getElementById('btn-cancel-capture').style.display = 'inline-block';
            document.getElementById('btn-capture').style.display = 'inline-flex';
            document.getElementById('btn-retake').style.display = 'none';
            document.getElementById('btn-confirm-upload').style.display = 'none';

            if (cameraStream) {
                stopCamera();
            }

            const constraints = {
                video: {
                    facingMode: 'environment', // standard back camera for phones
                    width: { ideal: 1280 },
                    height: { ideal: 720 }
                },
                audio: false
            };

            navigator.mediaDevices.getUserMedia(constraints)
                .then(function(stream) {
                    cameraStream = stream;
                    const video = document.getElementById('camera-video');
                    video.srcObject = stream;
                    video.play();
                })
                .catch(function(err) {
                    console.error("Camera access failed:", err);
                    showToast("⚠️ Lỗi khởi động camera hoặc chưa cấp quyền truy cập. Hệ thống sẽ mở bộ chọn tệp.", "error");
                    
                    // Close Modal
                    const modalEl = document.getElementById('cameraModal');
                    const modalInstance = bootstrap.Modal.getInstance(modalEl);
                    if (modalInstance) modalInstance.hide();
                    
                    // Fallback
                    document.getElementById(currentPhotoType + '-file-input').click();
                });
        }

        function capturePhoto() {
            const video = document.getElementById('camera-video');
            const canvas = document.getElementById('camera-canvas');
            const preview = document.getElementById('captured-preview');
            
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            
            const context = canvas.getContext('2d');
            context.drawImage(video, 0, 0, canvas.width, canvas.height);
            
            const dataUrl = canvas.toDataURL('image/jpeg', 0.85);
            preview.src = dataUrl;
            
            video.style.display = 'none';
            preview.style.display = 'block';
            
            document.getElementById('btn-cancel-capture').style.display = 'none';
            document.getElementById('btn-capture').style.display = 'none';
            document.getElementById('btn-retake').style.display = 'inline-block';
            document.getElementById('btn-confirm-upload').style.display = 'inline-block';
            
            video.pause();
        }

        function stopCamera() {
            if (cameraStream) {
                cameraStream.getTracks().forEach(track => track.stop());
                cameraStream = null;
            }
        }

        function confirmAndUpload() {
            const canvas = document.getElementById('camera-canvas');
            canvas.toBlob(function(blob) {
                if (!blob) {
                    showToast("Lỗi tạo ảnh từ Camera, vui lòng chụp lại!", "error");
                    return;
                }
                
                stopCamera();
                
                const modalEl = document.getElementById('cameraModal');
                const modalInstance = bootstrap.Modal.getInstance(modalEl);
                if (modalInstance) modalInstance.hide();
                
                uploadBlobEvidence(blob, currentPhotoType);
            }, 'image/jpeg', 0.85);
        }

        function uploadBlobEvidence(blob, type) {
            const previewContainer = document.getElementById(type + '-preview-container');
            const originalHTML = previewContainer.innerHTML;
            previewContainer.innerHTML = `
                <div class="spinner-border text-primary" role="status" style="width: 2rem; height: 2rem; margin-bottom: 8px;">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <span style="font-size: 12px; color: #555; display: block;">Đang tải lên ảnh...</span>
            `;

            const file = new File([blob], type + "_evidence_" + Date.now() + ".jpg", { type: "image/jpeg" });
            const formData = new FormData();
            formData.append("file", file);
            formData.append("tripId", "${order.tripId}");
            formData.append("orderNo", "${order.orderNo}");
            formData.append("type", type);

            fetch("${pageContext.request.contextPath}/shipper/orders", {
                method: "POST",
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast("🎉 " + data.message, "success");
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                } else {
                    showToast("❌ Lỗi: " + data.message, "error");
                    previewContainer.innerHTML = originalHTML;
                }
            })
            .catch(error => {
                console.error("Lỗi upload minh chứng:", error);
                showToast("❌ Đã xảy ra lỗi kết nối khi tải ảnh lên!", "error");
                previewContainer.innerHTML = originalHTML;
            });
        }
    </script>

    <!-- Camera WebRTC Modal -->
    <div class="modal fade" id="cameraModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 12px; overflow: hidden; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.25);">
                <div class="modal-header" style="background-color: var(--cz-dark-bg); color: white; border: none; padding: 16px 20px;">
                    <h5 class="modal-title" id="cameraModalLabel" style="font-weight: 700; font-size: 16px; margin: 0; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-camera"></i> Máy ảnh giao nhận
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close" onclick="stopCamera()"></button>
                </div>
                <div class="modal-body text-center" style="background-color: #f8f6f4; padding: 20px;">
                    <!-- Video Stream Container -->
                    <div id="video-container" style="position: relative; width: 100%; aspect-ratio: 4/3; background: #000; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
                        <video id="camera-video" autoplay playsinline style="width: 100%; height: 100%; object-fit: cover;"></video>
                        <!-- Captured Image Preview -->
                        <img id="captured-preview" style="display: none; width: 100%; height: 100%; object-fit: cover;" />
                    </div>
                    <canvas id="camera-canvas" style="display: none;"></canvas>
                </div>
                <div class="modal-footer" style="border: none; background-color: #f8f6f4; padding: 15px 20px; display: flex; justify-content: center; gap: 10px;">
                    <button type="button" class="btn btn-cz-outline" id="btn-cancel-capture" data-bs-dismiss="modal" onclick="stopCamera()" style="border-radius: 8px; font-weight: bold; border: 1px solid #ddd; background: white; padding: 10px 20px; font-size: 14px;">Hủy</button>
                    <button type="button" class="btn" id="btn-capture" onclick="capturePhoto()" style="background-color: var(--cz-primary); color: white; border: none; border-radius: 8px; font-weight: bold; padding: 10px 25px; font-size: 14px; display: inline-flex; align-items: center; gap: 6px;">
                        <i class="fa-solid fa-circle-dot"></i> Chụp ảnh
                    </button>

                    <button type="button" class="btn btn-cz-outline" id="btn-retake" onclick="startCamera()" style="display: none; border-radius: 8px; font-weight: bold; border: 1px solid #ddd; background: white; padding: 10px 20px; font-size: 14px;">Chụp lại</button>
                    <button type="button" class="btn btn-success" id="btn-confirm-upload" onclick="confirmAndUpload()" style="display: none; border-radius: 8px; font-weight: bold; padding: 10px 25px; font-size: 14px;">Xác nhận & Tải lên</button>
                </div>
            </div>
        </div>
    </div>
    </c:if>
</body>
</html>

    </c:otherwise>
</c:choose>
