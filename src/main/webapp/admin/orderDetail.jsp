<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="com.bakeryzone.model.User" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}" />
    </jsp:include>
    <!-- Order Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
    <style>
        .page-title-area .status-badge {
            font-size: 14px;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 30px;
            display: inline-block;
            text-align: center;
            white-space: nowrap;
            text-transform: uppercase;
        }
        .page-title-area .status-badge.status-pending {
            background-color: #fef9c3;
            color: #a16207;
        }
        .page-title-area .status-badge.status-confirmed {
            background-color: #dbeafe;
            color: #1e40af;
        }
        .page-title-area .status-badge.status-processing {
            background-color: #f3e8ff;
            color: #6b21a8;
        }
        .page-title-area .status-badge.status-delivering {
            background-color: #ffedd5;
            color: #9a3412;
        }
        .page-title-area .status-badge.status-completed {
            background-color: #dcfce7;
            color: #166534;
        }
        .page-title-area .status-badge.status-cancelled {
            background-color: #fee2e2;
            color: #991b1b;
        }
        .page-title-area .status-badge.status-paid {
            background-color: #d1fae5;
            color: #065f46;
        }
        .item-name-link {
            color: inherit;
            text-decoration: none;
            transition: color 0.2s ease, text-decoration 0.2s ease;
        }
        .item-name-link:hover {
            color: #e11d48;
            text-decoration: underline;
        }
        .item-img-clickable {
            cursor: pointer;
            transition: transform 0.2s ease, opacity 0.2s ease;
        }
        .item-img-clickable:hover {
            transform: scale(1.05);
            opacity: 0.9;
        }
    </style>
</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <div class="main-panel">
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Quản lý đơn hàng" />
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/admin/orders" />
            <jsp:param name="activeMenu" value="Chi tiết đơn hàng" />
        </jsp:include>

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
                        <c:when test="${order.orderStatus eq 'PAID' || order.orderStatus eq 'Đã chuyển khoản'}">
                            <span class="status-badge status-paid">Đã chuyển khoản</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý'}">
                            <span class="status-badge status-processing">Đang xử lý</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao'}">
                            <span class="status-badge status-delivering">Đang giao hàng</span>
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

                                    User sessionUserObj = (User) session.getAttribute("user");
                                    String userRole = sessionUserObj != null ? sessionUserObj.getRoleId() : "";
                                    boolean canManageProducts = "ADMIN".equalsIgnoreCase(userRole) || "STAFF".equalsIgnoreCase(userRole);

                                    String tplId     = oi.getTemplateId();
                                    String itemLink  = "";
                                    if (tplId != null && !tplId.trim().isEmpty()) {
                                        if (canManageProducts) {
                                            itemLink = ctxPath + "/admin/product?action=detail&id=" + tplId.trim();
                                        } else {
                                            itemLink = ctxPath + "/product-detail?id=" + tplId.trim();
                                        }
                                    } else if (oi.getAccessoryId() != null && !oi.getAccessoryId().trim().isEmpty()) {
                                        if (canManageProducts) {
                                            itemLink = ctxPath + "/admin/product?action=list";
                                        } else {
                                            itemLink = ctxPath + "/products";
                                        }
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
                        %>
                        <div class="info-row">
                            <div class="info-label">Khách hàng đặt:</div>
                            <div class="info-value"><%= (curCust != null && curCust.getFullName() != null) ? curCust.getFullName() : "Khách vãng lai" %></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Người nhận:</div>
                            <div class="info-value"><strong><%= recName %></strong></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">SĐT người nhận:</div>
                            <div class="info-value"><%= recPhone %></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Email tài khoản:</div>
                            <div class="info-value"><c:out value="${not empty customer.user.email ? customer.user.email : 'Không có'}" /></div>
                        </div>
                        <div class="info-row">
                            <div class="info-label">Địa chỉ giao hàng:</div>
                            <div class="info-value"><%= displayAddr %></div>
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
                            <div class="info-value text-danger" style="font-weight: 600;">
                                <c:out value="${not empty order.customerNote ? order.customerNote : 'Không có ghi chú'}" />
                            </div>
                        </div>
                        <c:if test="${not empty order.tripId && order.orderStatus ne 'Pending' && order.orderStatus ne 'Chờ xác nhận'}">
                            <div class="info-row" style="background-color: #f0fdf4; border-radius: 6px; padding: 10px; margin-top: 15px; border-left: 4px solid #16a34a; display: flex; flex-direction: column; gap: 4px;">
                                <div style="display: flex; justify-content: space-between; font-size: 13.5px;">
                                    <span style="color: #15803d; font-weight: 700;"><i class="fa-solid fa-route"></i> Chuyến giao hàng:</span>
                                    <span style="font-family: monospace; font-weight: 700; color: #166534;"><c:out value="${order.tripId}" /></span>
                                </div>
                                <div style="display: flex; justify-content: space-between; font-size: 13.5px; margin-top: 2px;">
                                    <span style="color: #15803d; font-weight: 700;"><i class="fa-solid fa-user-ninja"></i> Shipper phụ trách:</span>
                                    <span style="font-weight: 700; color: #166534;"><c:out value="${not empty order.shipperName ? order.shipperName : 'Chưa gán'}" /></span>
                                </div>
                            </div>
                        </c:if>
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

                    <!-- Bằng chứng giao hàng (Shipper tải lên, Admin chỉ xem) -->
                    <div class="cz-card">
                        <div class="cz-card-title" style="margin-bottom: 15px;">
                            <i class="fa-solid fa-camera" style="color: var(--cz-primary);"></i> Minh chứng hình ảnh (Từ Shipper)
                        </div>
                        <div class="row">
                            <!-- 1. Minh chứng lấy bánh tại tiệm -->
                            <div class="col-md-6 text-center" style="border-right: 1px dashed #ddd; padding: 15px;">
                                <h6 class="proof-placeholder-title">1. Ảnh lấy bánh tại tiệm (Pickup)</h6>
                                <div class="proof-placeholder-box">
                                    <c:choose>
                                        <c:when test="${not empty pickupPhoto}">
                                            <img src="${pageContext.request.contextPath}/${pickupPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã chụp lúc lấy hàng
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image proof-placeholder-icon"></i>
                                            <span class="proof-placeholder-text">Shipper chưa chụp ảnh lấy bánh.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            
                            <!-- 2. Minh chứng giao bánh cho khách -->
                            <div class="col-md-6 text-center" style="padding: 15px;">
                                <h6 class="proof-placeholder-title">2. Ảnh bàn giao cho khách (Delivery)</h6>
                                <div class="proof-placeholder-box">
                                    <c:choose>
                                        <c:when test="${not empty deliveryPhoto}">
                                            <img src="${pageContext.request.contextPath}/${deliveryPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã chụp lúc giao xong
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image proof-placeholder-icon"></i>
                                            <span class="proof-placeholder-text">Shipper chưa chụp ảnh giao bánh.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
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
                            
                        <c:choose>
                            <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao' || order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Canceled' || order.orderStatus eq 'Đã hủy'}">
                                <div style="padding: 20px; text-align: center; color: #721c24; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 6px; font-weight: bold;">
                                    <i class="fa-solid fa-lock" style="font-size: 24px; margin-bottom: 8px; display: block; color: #721c24;"></i>
                                    Đơn hàng đã hoàn thành hoặc đã hủy.<br>Không thể thay đổi trạng thái nữa.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/admin/orders" method="POST" class="status-form">
                                    <input type="hidden" name="action" value="update-status">
                                    <input type="hidden" name="orderNo" value="${order.orderNo}">
                                    
                                    <select name="status" class="status-select" style="padding: 10px; width: 100%; border-radius: 6px; border: 1px solid #ccc; font-weight: 500; font-size: 14.5px;">
                                        <option value="Pending" ${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                                        <option value="Confirmed" ${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Đã xác nhận' ? 'selected' : ''}>Đã xác nhận</option>
                                        <option value="Processing" ${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý' || order.orderStatus eq 'Đang làm bánh' ? 'selected' : ''}>Đang làm bánh</option>
                                        <option value="Delivering" ${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao' ? 'selected' : ''}>Đang giao hàng</option>
                                        <option value="Completed" ${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' ? 'selected' : ''}>Hoàn thành</option>
                                        <option value="Cancelled" ${order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Canceled' || order.orderStatus eq 'Đã hủy' ? 'selected' : ''}>Hủy đơn</option>
                                    </select>
                                    
                                    <button type="submit" class="btn btn-update-status mt-3 w-100" style="padding: 10px; border-radius: 8px; font-weight: bold;">
                                        <i class="fa-solid fa-floppy-disk me-1"></i> Cập nhật trạng thái
                                    </button>
                                </form>
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
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
