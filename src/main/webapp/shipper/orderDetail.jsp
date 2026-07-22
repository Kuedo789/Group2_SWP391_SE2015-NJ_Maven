<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Shipper - Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}" />
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
        <jsp:include page="/common/top-header.jsp">
            <jsp:param name="parentMenu" value="Đơn hàng được phân công" />
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/shipper/orders?action=list" />
            <jsp:param name="activeMenu" value="Chi tiết đơn hàng" />
        </jsp:include>

        <div class="content-container">
            <a href="${pageContext.request.contextPath}/shipper/orders" class="btn-back">
                <i class="fa-solid fa-arrow-left-long"></i> Quay lại danh sách đơn hàng
            </a>

            <!-- Popups notification standard -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div style="background-color: #d4edda; color: #155724; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #c3e6cb;">
                    <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMessage}
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div style="background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: bold; border: 1px solid #f5c6cb;">
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
                        <c:when test="${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ xác nhận'}">
                            <span class="status-badge status-pending">Chờ xác nhận</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Đã xác nhận'}">
                            <span class="status-badge status-processing">Đang làm bánh</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'PAID' || order.orderStatus eq 'Đã chuyển khoản'}">
                            <span class="status-badge status-confirmed" style="background-color: #d1fae5; color: #065f46;">Đã thanh toán (Duyệt gấp)</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý'}">
                            <span class="status-badge status-processing">Đang làm bánh</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao'}">
                            <span class="status-badge status-delivering">Đang giao hàng</span>
                        </c:when>
                        <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao'}">
                            <span class="status-badge status-completed">Hoàn thành</span>
                        </c:when>
                        <c:otherwise>
                            <span class="status-badge status-cancelled">Đã hủy / Thất bại</span>
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
                            <div class="info-value"><strong><%= recName %></strong></div>
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
                            <div class="info-value text-danger" style="font-weight: 600;">
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
                    <div class="cz-card">
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
                                <input type="file" id="pickup-file-input" accept="image/*" capture="camera" style="display: none;" onchange="uploadEvidence(this, 'pickup')">
                                <button type="button" class="btn" style="background-color: var(--cz-primary); color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="openWebRTCCamera('pickup')">
                                    <i class="fa-solid fa-camera"></i> Chụp ảnh lấy bánh
                                </button>
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
                                <input type="file" id="delivery-file-input" accept="image/*" capture="camera" style="display: none;" onchange="uploadEvidence(this, 'delivery')" ${empty pickupPhoto ? 'disabled' : ''}>
                                <button type="button" class="btn" id="btn-delivery-upload" style="background-color: ${empty pickupPhoto ? '#aaa' : 'var(--cz-primary)'}; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 6px;" onclick="${empty pickupPhoto ? "alert('Bạn cần chụp ảnh lấy bánh tại tiệm trước!')" : "openWebRTCCamera('delivery')"}" ${empty pickupPhoto ? 'disabled' : ''}>
                                    <i class="fa-solid fa-camera"></i> Chụp ảnh giao bánh
                                </button>
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
                                        <c:if test="${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ thanh toán'}">
                                            <option value="Pending" selected disabled>Chờ thanh toán (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Chờ xác nhận' || order.orderStatus eq 'PAID'}">
                                            <option value="Confirmed" selected disabled>Chờ xác nhận (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang làm bánh'}">
                                            <option value="Processing" selected disabled>Đang làm bánh (Chỉ đọc)</option>
                                        </c:if>
                                        <option value="Delivering" ${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao' ? 'selected' : ''}>Đang giao hàng</option>
                                        <option value="Completed" ${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' ? 'selected' : ''}>Hoàn thành đơn hàng</option>
                                        <option value="Cancelled" ${order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Đã hủy' ? 'selected' : ''}>Hủy đơn / Giao thất bại</option>
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
                    </div>

                    <!-- Payment Summary -->
                    <%
                        double calcDiscountValStaff = 0;
                        com.bakeryzone.model.Order orderStaffObj = (com.bakeryzone.model.Order) request.getAttribute("order");
                        if (orderStaffObj != null) {
                            if (orderStaffObj.getDiscountAmount() != null && orderStaffObj.getDiscountAmount().doubleValue() > 0) {
                                calcDiscountValStaff = orderStaffObj.getDiscountAmount().doubleValue();
                            } else if (orderStaffObj.getAppliedVoucherCode() != null && !orderStaffObj.getAppliedVoucherCode().trim().isEmpty()) {
                                double sub = 0;
                                if (orderStaffObj.getItems() != null) {
                                    for (com.bakeryzone.model.OrderItem item : orderStaffObj.getItems()) {
                                        double p = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase().doubleValue() : 0;
                                        sub += p * item.getQuantity();
                                    }
                                }
                                double ship = orderStaffObj.getShippingFee() != null ? orderStaffObj.getShippingFee().doubleValue() : 0;
                                double tot = orderStaffObj.getTotalCost() != null ? orderStaffObj.getTotalCost().doubleValue() : 0;
                                if (sub + ship > tot && tot > 0) {
                                    calcDiscountValStaff = (sub + ship) - tot;
                                }
                            }
                        }
                        pageContext.setAttribute("calcDiscountValStaff", calcDiscountValStaff);
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
                        <div class="cost-row" style="color: ${calcDiscountValStaff > 0 ? '#2b8a3e' : 'inherit'};">
                            <span>Voucher giảm giá <c:if test="${not empty order.appliedVoucherCode}">(${order.appliedVoucherCode})</c:if>:</span>
                            <span class="font-mono">
                                <c:choose>
                                    <c:when test="${calcDiscountValStaff > 0}">
                                        -<fmt:formatNumber value="${calcDiscountValStaff}" type="number" pattern="#,##0"/>đ
                                    </c:when>
                                    <c:otherwise>0đ</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <c:set var="calcTotal" value="${subtot + (not empty order.shippingFee ? order.shippingFee : 0) - calcDiscountValStaff}" />
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
                                    <c:when test="${order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        Chuyển khoản
                                    </c:when>
                                    <c:otherwise>
                                        COD (Nhận hàng)
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cost-row">
                            <span>Tiền cọc:</span>
                            <span class="font-mono">
                                <fmt:formatNumber value="${not empty order.depositAmount ? order.depositAmount : 0}" type="number" pattern="#,##0"/>đ
                            </span>
                         </div>
                        <div class="cost-row total" style="background-color: #fdf2f2; border: 1px dashed #f8b4b4; padding: 10px; border-radius: 6px; margin-top: 15px;">
                            <span style="color: #9b1c1c; font-weight: 800;">THÀNH TIỀN:</span>
                            <span class="font-mono" style="color: #9b1c1c; font-size: 18px; font-weight: 800;">
                                <fmt:formatNumber value="${order.remainingCodBalance}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function uploadEvidence(inputElement, type) {
            const file = inputElement.files[0];
            if (!file) return;

            // Kiểm tra kích thước file (giới hạn 10MB)
            if (file.size > 10 * 1024 * 1024) {
                alert("⚠️ Kích thước ảnh quá lớn, vui lòng chụp/chọn ảnh dưới 10MB!");
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
                    alert("🎉 " + data.message);
                    // Tải lại trang để đồng bộ hoàn toàn trạng thái mới từ database
                    window.location.reload();
                } else {
                    alert("❌ Lỗi: " + data.message);
                    previewContainer.innerHTML = originalHTML;
                }
            })
            .catch(error => {
                console.error("Lỗi upload minh chứng:", error);
                alert("❌ Đã xảy ra lỗi kết nối khi tải ảnh lên!");
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
                    alert('⚠️ LỖI: Bạn phải chụp ảnh lấy bánh thành công tại tiệm trước khi cập nhật đơn hàng thành "Đang giao hàng"!');
                    return false;
                }
            }
            
            if (selectedStatus === 'Completed') {
                const hasDeliveryPhoto = "${not empty deliveryPhoto}" === "true";
                if (!hasDeliveryPhoto) {
                    alert('⚠️ LỖI: Bạn phải chụp ảnh giao bánh thành công cho khách trước khi cập nhật đơn hàng thành "Hoàn thành"!');
                    return false;
                }
            }
            
            if (selectedStatus === 'Cancelled') {
                const reasonInput = document.getElementById('shipper-note-input');
                if (!reasonInput || !reasonInput.value.trim()) {
                    alert('⚠️ LỖI: Bạn phải nhập lý do hủy / giao hàng thất bại!');
                    if (reasonInput) reasonInput.focus();
                    return false;
                }
            }
            
            return confirm('Bạn có chắc chắn muốn cập nhật trạng thái đơn hàng này?');
        }

        document.addEventListener('DOMContentLoaded', function() {
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
                    alert("⚠️ Lỗi khởi động camera hoặc chưa cấp quyền truy cập. Hệ thống sẽ mở bộ chọn tệp.");
                    
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
                    alert("Lỗi tạo ảnh từ Camera, vui lòng chụp lại!");
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
                    alert("🎉 " + data.message);
                    window.location.reload();
                } else {
                    alert("❌ Lỗi: " + data.message);
                    previewContainer.innerHTML = originalHTML;
                }
            })
            .catch(error => {
                console.error("Lỗi upload minh chứng:", error);
                alert("❌ Đã xảy ra lỗi kết nối khi tải ảnh lên!");
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
</body>
</html>
