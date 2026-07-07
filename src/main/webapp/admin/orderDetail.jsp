<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="java.text.DecimalFormat" %>
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
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}" />
    </jsp:include>
    <!-- Order Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
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
                        
                    </div>

                    <!-- Bằng chứng giao hàng (Shipper tải lên, Admin chỉ xem) -->
                    <div class="cz-card">
                        <div class="cz-card-title">
                            <i class="fa-solid fa-camera" style="color: var(--cz-primary);"></i> Bằng chứng giao hàng
                        </div>
                        <div class="shipper-proof-box">
                            <div id="admin-proof-display-container" style="text-align: center; width: 100%;">
                                <i class="fa-regular fa-image proof-icon" style="font-size: 32px; margin-bottom: 8px; display: block;"></i>
                                <span class="proof-empty-text">Shipper chưa tải lên ảnh bằng chứng giao hàng cho đơn này.</span>
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
                                <fmt:formatNumber value="${order.shippingFee}" type="number" pattern="#,##0"/>đ
                            </span>
                        </div>
                        <c:if test="${order.discountAmount > 0}">
                            <div class="cost-row">
                                <span>Giảm giá:</span>
                                <span class="font-mono text-success">
                                    -<fmt:formatNumber value="${order.discountAmount}" type="number" pattern="#,##0"/>đ
                                </span>
                            </div>
                        </c:if>
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
    <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.js"></script>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Hiển thị thông báo Toastify đẹp mắt từ session (có fallback nếu offline/lỗi CDN)
            <c:if test="${not empty sessionScope.successMessage}">
                if (typeof Toastify === 'function') {
                    Toastify({
                        text: "${sessionScope.successMessage}",
                        duration: 4000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        backgroundColor: "linear-gradient(to right, #00b09b, #96c93d)",
                        style: {
                            background: "linear-gradient(to right, #00b09b, #96c93d)"
                        },
                        stopOnFocus: true
                    }).showToast();
                } else {
                    // Fallback alert float box if Toastify fails to load
                    let alertDiv = document.createElement('div');
                    alertDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; padding: 15px 25px; border-radius: 8px; background: linear-gradient(to right, #00b09b, #96c93d); color: white; box-shadow: 0 4px 15px rgba(0,0,0,0.2); font-weight: 500; font-family: "Outfit", sans-serif; display: flex; align-items: center; gap: 10px; transition: opacity 0.5s ease;';
                    alertDiv.innerHTML = '<i class="fa-solid fa-circle-check"></i> <span>${sessionScope.successMessage}</span>';
                    document.body.appendChild(alertDiv);
                    setTimeout(() => { alertDiv.style.opacity = '0'; setTimeout(() => alertDiv.remove(), 500); }, 3500);
                }
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                if (typeof Toastify === 'function') {
                    Toastify({
                        text: "${sessionScope.errorMessage}",
                        duration: 4000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        backgroundColor: "linear-gradient(to right, #ff5f6d, #ffc371)",
                        style: {
                            background: "linear-gradient(to right, #ff5f6d, #ffc371)"
                        },
                        stopOnFocus: true
                    }).showToast();
                } else {
                    // Fallback alert float box if Toastify fails to load
                    let alertDiv = document.createElement('div');
                    alertDiv.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; padding: 15px 25px; border-radius: 8px; background: linear-gradient(to right, #ff5f6d, #ffc371); color: white; box-shadow: 0 4px 15px rgba(0,0,0,0.2); font-weight: 500; font-family: "Outfit", sans-serif; display: flex; align-items: center; gap: 10px; transition: opacity 0.5s ease;';
                    alertDiv.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i> <span>${sessionScope.errorMessage}</span>';
                    document.body.appendChild(alertDiv);
                    setTimeout(() => { alertDiv.style.opacity = '0'; setTimeout(() => alertDiv.remove(), 500); }, 3500);
                }
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            const orderStatus = '${order.orderStatus}';
            const savedProof = localStorage.getItem('proof_of_delivery_' + '${order.orderNo}');
            const displayContainer = document.getElementById('admin-proof-display-container');

            // Load saved proof to admin display container
            if (displayContainer) {
                if (savedProof) {
                    displayContainer.innerHTML = `
                        <img src="${savedProof}" style="max-width: 100%; max-height: 250px; border-radius: 8px; object-fit: contain; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />
                        <div style="margin-top: 8px; font-size: 12px; color: #2e7d32; font-weight: 600;">
                            <i class="fa-solid fa-circle-check"></i> Ảnh bằng chứng thực tế từ Shipper
                        </div>
                    `;
                } else {
                    displayContainer.innerHTML = `
                        <i class="fa-regular fa-image proof-icon" style="font-size: 32px; color: #bbb; margin-bottom: 8px; display: block;"></i>
                        <span class="proof-empty-text">Shipper chưa tải lên ảnh bằng chứng giao hàng cho đơn này.</span>
                    `;
                }
            }
        });
    </script>
</body>
</html>
