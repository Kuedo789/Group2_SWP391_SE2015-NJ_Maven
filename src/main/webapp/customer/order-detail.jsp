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
        if (dbStatus.equalsIgnoreCase("Pending")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Chờ thanh toán";
        } else if (dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equalsIgnoreCase("PAID")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Chờ xác nhận";
        } else if (dbStatus.equalsIgnoreCase("Processing") || dbStatus.equals("Đang làm bánh")) {
            dataStatus = "processing";
            badgeClass = "status-processing";
            displayStatus = "Đang làm bánh";
        } else if (dbStatus.equalsIgnoreCase("Ready") || dbStatus.equals("Chờ vận chuyển") || dbStatus.equals("Sẵn sàng giao")) {
            dataStatus = "shipping";
            badgeClass = "status-shipping";
            displayStatus = "Chờ vận chuyển";
        } else if (dbStatus.equalsIgnoreCase("Delivering") || dbStatus.equals("Đang vận chuyển") || dbStatus.equals("Đang giao hàng")) {
            dataStatus = "shipping";
            badgeClass = "status-shipping";
            displayStatus = "Đang giao hàng";
        } else if (dbStatus.equalsIgnoreCase("Completed") || dbStatus.equals("Hoàn thành")) {
            dataStatus = "completed";
            badgeClass = "status-completed";
            displayStatus = "Hoàn thành";
        } else if (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled") || dbStatus.equals("Đã hủy")) {
            dataStatus = "cancelled";
            badgeClass = "status-cancelled";
            displayStatus = "Đã hủy";
        }
    }

    // Timeline steps activation logic
    boolean step1Active = true; // Đã nhận đơn
    boolean step2Active = false; // Đang làm bánh
    boolean step3Active = false; // Đang giao
    boolean step4Active = false; // Hoàn thành

    if (dbStatus != null) {
        if (dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equalsIgnoreCase("Processing")) {
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
    <jsp:include page="../common/header.jsp" />
    <title>Chi tiết đơn hàng #<%= order.getOrderNo().replace("ORD_", "") %> - ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}</title>
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
                <h1>Chi tiết đơn hàng #<span class="order-no-display"><%= order.getOrderNo().replace("ORD_", "") %></span></h1>
                <div class="order-meta-info">
                    <span class="status-badge <%= badgeClass %>"><%= displayStatus %></span>
                    <span>•</span>
                    <span>Đặt lúc: <%= orderTimeStr %></span>
                </div>
            </div>
            
            <div class="order-header-actions">
                <%
                    java.util.Map<String, Object> settingsMap = (java.util.Map<String, Object>) application.getAttribute("settings");
                    String supportHotline = (settingsMap != null && settingsMap.get("hotline") != null) ? (String) settingsMap.get("hotline") : "0901234567";
                    String supportName = (settingsMap != null && settingsMap.get("bakeryName") != null) ? (String) settingsMap.get("bakeryName") : "BakeryZone";
                %>
                
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
                        <span class="step-text">Đã nhận đơn</span>
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
                                            <div style="margin-top: 10px;">
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
                                double price = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().doubleValue() : 0.0;
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
                        <div class="reorder-actions-row" style="display: flex; gap: 10px; width: 100%;">
                            <button class="btn-reorder" style="flex: 1;" onclick="reorderOrder(<%= escapedJson %>)">
                                <span class="material-symbols-outlined">shopping_bag</span>
                                Mua lại
                            </button>
                            <% if (!firstTplId.isEmpty() && dbStatus.equalsIgnoreCase("Completed")) { %>
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

        function reorderOrder(items) {
            if (!Array.isArray(items) || items.length === 0) return;
            
            const cartItems = items.map(item => {
                let cartItemId = "";
                let templateId = item.templateId;
                
                if (templateId && templateId.trim() !== "") {
                    let variantIndex = "0";
                    if (item.variationName.includes("20cm")) {
                        variantIndex = "1";
                    } else if (item.variationName.includes("24cm")) {
                        variantIndex = "2";
                    }
                    cartItemId = templateId.trim() + "_" + variantIndex;
                } else {
                    cartItemId = "CAKE_ITEM_" + Math.random().toString(36).substring(7);
                    templateId = "";
                }
                
                let finalName = item.name;
                let finalDesc = "Bánh ngọt thủ công cao cấp";
                
                let resolvedImg = item.image;
                const ctx = '<%= request.getContextPath() %>';
                if (ctx && resolvedImg.startsWith(ctx)) {
                    resolvedImg = resolvedImg.substring(ctx.length);
                }
                if (resolvedImg.startsWith("/")) {
                    resolvedImg = resolvedImg.substring(1);
                }
                
                return {
                    id: cartItemId,
                    templateId: templateId,
                    name: finalName,
                    desc: finalDesc,
                    price: item.price,
                    qty: item.qty,
                    image: resolvedImg
                };
            });
            
            localStorage.setItem("cart", JSON.stringify(cartItems));
            window.location.href = '<%= request.getContextPath() %>/checkout';
        }
    </script>
</body>
</html>
