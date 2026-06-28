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
    <title>${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'} Admin - Chi tiết đơn hàng #${order.orderNo.replace('ORD_', '')}</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

    <!-- Global Admin Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/admin-global.css" rel="stylesheet">
    <!-- Order Specific Style Link -->
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
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
                        <div class="profile-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></div>
                        <div class="profile-role"><c:out value="${not empty sessionScope.user.roleName ? sessionScope.user.roleName : sessionScope.user.roleId}" /></div>
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
                            <div class="info-value delivery-time-highlight">
                                <fmt:formatDate value="${order.deliveryWindowStart}" pattern="dd/MM/yyyy HH:mm" />
                                -
                                <fmt:formatDate value="${order.deliveryWindowEnd}" pattern="HH:mm" />
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

        document.addEventListener('DOMContentLoaded', function() {
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
                } else if (orderStatus.toLowerCase() === 'completed' || orderStatus === 'Hoàn thành' || orderStatus === 'Đã giao') {
                    displayContainer.innerHTML = `
                        <img src="https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=500&auto=format&fit=crop" style="max-width: 100%; max-height: 250px; border-radius: 8px; object-fit: contain; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />
                        <div style="margin-top: 8px; font-size: 12px; color: #555; font-weight: 600;">
                            <i class="fa-solid fa-circle-check"></i> Bằng chứng giao hàng (Shipper đã giao bánh thành công)
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
