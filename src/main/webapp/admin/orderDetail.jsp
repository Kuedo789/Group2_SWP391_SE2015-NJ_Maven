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
                                <h6 style="font-weight: 600; color: #555; margin-bottom: 12px;">1. Ảnh lấy bánh tại tiệm (Pickup)</h6>
                                <div style="margin-bottom: 10px; min-height: 180px; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #fafafa; border: 1px dashed #ccc; border-radius: 8px; padding: 10px;">
                                    <c:choose>
                                        <c:when test="${not empty pickupPhoto}">
                                            <img src="${pageContext.request.contextPath}/${pickupPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã chụp lúc lấy hàng
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image" style="font-size: 40px; color: #ccc; margin-bottom: 8px;"></i>
                                            <span style="font-size: 12px; color: #888;">Shipper chưa chụp ảnh lấy bánh.</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            
                            <!-- 2. Minh chứng giao bánh cho khách -->
                            <div class="col-md-6 text-center" style="padding: 15px;">
                                <h6 style="font-weight: 600; color: #555; margin-bottom: 12px;">2. Ảnh bàn giao cho khách (Delivery)</h6>
                                <div style="margin-bottom: 10px; min-height: 180px; display: flex; flex-direction: column; align-items: center; justify-content: center; background: #fafafa; border: 1px dashed #ccc; border-radius: 8px; padding: 10px;">
                                    <c:choose>
                                        <c:when test="${not empty deliveryPhoto}">
                                            <img src="${pageContext.request.contextPath}/${deliveryPhoto}" style="max-width: 100%; max-height: 150px; border-radius: 6px; object-fit: contain; box-shadow: 0 1px 5px rgba(0,0,0,0.1);" />
                                            <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                                                <i class="fa-solid fa-circle-check"></i> Đã chụp lúc giao xong
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-image" style="font-size: 40px; color: #ccc; margin-bottom: 8px;"></i>
                                            <span style="font-size: 12px; color: #888;">Shipper chưa chụp ảnh giao bánh.</span>
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
                    <%
                        int calcDepPercent = 30;
                        com.bakeryzone.model.Order orderObj = (com.bakeryzone.model.Order) request.getAttribute("order");
                        if (orderObj != null) {
                            double totalCostVal = orderObj.getTotalCost() != null ? orderObj.getTotalCost().doubleValue() : 0;
                            double depositAmtVal = orderObj.getDepositAmount() != null ? orderObj.getDepositAmount().doubleValue() : 0;
                            if (totalCostVal > 0) {
                                calcDepPercent = (int) Math.round((depositAmtVal * 100) / totalCostVal);
                            }
                        }
                        pageContext.setAttribute("calcDepPercent", calcDepPercent);
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
                            <span>
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        Tiền đặt cọc (0%):
                                    </c:when>
                                    <c:otherwise>
                                        Tiền đặt cọc (${calcDepPercent}%):
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <span class="font-mono">
                                <c:choose>
                                    <c:when test="${order.paymentMethod eq 'Bank Transfer' || order.paymentMethod eq 'Chuyển khoản'}">
                                        0đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${not empty order.depositAmount ? order.depositAmount : 0}" type="number" pattern="#,##0"/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="cost-row total">
                            <span>SỐ TIỀN CẦN THU:</span>
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

</body>
</html>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
