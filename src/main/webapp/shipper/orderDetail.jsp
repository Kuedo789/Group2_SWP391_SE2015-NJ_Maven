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
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/shipper/orders" />
            <jsp:param name="activeMenu" value="Chi tiết giao hàng" />
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

                    <!-- Bằng chứng giao hàng (Shipper tải lên) -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-camera" style="color: var(--cz-primary);"></i> Tải ảnh bằng chứng giao hàng (Bắt buộc khi hoàn thành)
                        </div>
                        <div class="shipper-proof-box" style="text-align: center; padding: 20px;">
                            <div id="proof-preview-container" style="margin-bottom: 15px;">
                                <i class="fa-regular fa-image" style="font-size: 48px; color: #ccc; display: block; margin-bottom: 8px;"></i>
                                <span style="font-size: 13px; color: #888;">Chưa tải lên ảnh bằng chứng giao hàng thực tế.</span>
                            </div>
                            <input type="file" id="proof-file-input" accept="image/*" style="display: none;" onchange="previewAndSaveProof(event)">
                            <button type="button" class="btn" style="background-color: var(--cz-primary); color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; display: inline-flex; align-items: center; gap: 8px;" onclick="document.getElementById('proof-file-input').click()">
                                <i class="fa-solid fa-cloud-arrow-up"></i> Tải ảnh / Chụp hình bằng chứng
                            </button>
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
                            <c:when test="${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao' || order.orderStatus eq 'Cancelled' || order.orderStatus eq 'Đã hủy'}">
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
                                        <c:if test="${order.orderStatus eq 'Pending' || order.orderStatus eq 'Chờ xác nhận'}">
                                            <option value="Pending" selected disabled>Chờ xác nhận (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Confirmed' || order.orderStatus eq 'Đã xác nhận'}">
                                            <option value="Confirmed" selected disabled>Đã xác nhận (Chỉ đọc)</option>
                                        </c:if>
                                        <c:if test="${order.orderStatus eq 'Processing' || order.orderStatus eq 'Đang xử lý'}">
                                            <option value="Processing" selected disabled>Đang xử lý (Chỉ đọc)</option>
                                        </c:if>
                                        <option value="Delivering" ${order.orderStatus eq 'Delivering' || order.orderStatus eq 'Đang giao hàng' || order.orderStatus eq 'Đang giao' ? 'selected' : ''}>Đang giao hàng</option>
                                        <option value="Completed" ${order.orderStatus eq 'Completed' || order.orderStatus eq 'Hoàn thành' || order.orderStatus eq 'Đã giao' ? 'selected' : ''}>Hoàn thành đơn hàng</option>
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
                            <span>Tiền cọc:</span>
                            <span class="font-mono">
                                <fmt:formatNumber value="${not empty order.depositAmount ? order.depositAmount : 0}" type="number" pattern="#,##0"/>đ
                            </span>
                         </div>
                        <div class="cost-row total" style="background-color: #fdf2f2; border: 1px dashed #f8b4b4; padding: 10px; border-radius: 6px; margin-top: 15px;">
                            <span style="color: #9b1c1c; font-weight: 800;">TIỀN THU HỘ (COD):</span>
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
        function previewAndSaveProof(event) {
            const file = event.target.files[0];
            if (!file) return;
            
            const reader = new FileReader();
            reader.onload = function(e) {
                const base64Data = e.target.result;
                localStorage.setItem('proof_of_delivery_' + '${order.orderNo}', base64Data);
                renderProof(base64Data);
            };
            reader.readAsDataURL(file);
        }

        function renderProof(base64Data) {
            const container = document.getElementById('proof-preview-container');
            if (container) {
                container.innerHTML = `
                    <img src="${base64Data}" style="max-width: 100%; max-height: 250px; border-radius: 8px; object-fit: contain; box-shadow: 0 2px 8px rgba(0,0,0,0.15);" />
                    <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                        <i class="fa-solid fa-circle-check"></i> Đã đính kèm ảnh bằng chứng giao hàng!
                    </div>
                `;
            }
        }

        function validateStatusChange() {
            const statusSelect = document.getElementById('shipper-status-select');
            const selectedStatus = statusSelect.value;
            
            if (selectedStatus === 'Completed') {
                const savedProof = localStorage.getItem('proof_of_delivery_' + '${order.orderNo}');
                if (!savedProof) {
                    alert('⚠️ LỖI: Bạn phải tải lên hoặc chụp ảnh bằng chứng giao hàng trước khi chuyển trạng thái đơn sang "Hoàn thành"!');
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
            const savedProof = localStorage.getItem('proof_of_delivery_' + '${order.orderNo}');
            if (savedProof) {
                renderProof(savedProof);
            }
            
            // Toggle lý do hủy
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
                
                // Initial check
                if (statusSelect.value === 'Cancelled') {
                    cancelReasonContainer.style.display = 'block';
                }
            }
        });
    </script>
</body>
</html>
