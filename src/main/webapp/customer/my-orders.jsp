<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Đơn hàng của tôi - BakeryZone</title>
</head>
<body>
    <!-- Navigation Bar -->
    <jsp:include page="../common/navbar.jsp" />

    <main class="orders-page">
        <!-- Header Section -->
        <section class="orders-title">
            <h1>Đơn hàng của tôi</h1>
            <p>Theo dõi trạng thái và quản lý lịch sử những chiếc bánh ngọt ngào bạn đã đặt tại BakeryZone.</p>
        </section>

        <!-- Filters Section -->
        <section class="orders-filter">
            <button class="filter-btn active" data-filter="all">Tất cả</button>
            <button class="filter-btn" data-filter="processing">Đang xử lý</button>
            <button class="filter-btn" data-filter="shipping">Đang giao</button>
            <button class="filter-btn" data-filter="completed">Hoàn thành</button>
            <button class="filter-btn" data-filter="cancelled">Đã hủy</button>
        </section>

        <!-- Orders List -->
        <section class="orders-list">
        <%
            List<Order> orders = (List<Order>) request.getAttribute("orders");
            if (orders == null) {
                response.sendRedirect(request.getContextPath() + "/OrderList");
                return;
            }
            
            if (orders.isEmpty()) {
        %>
            <div class="no-orders" style="text-align: center; padding: 60px 20px; color: var(--muted); background: var(--card); border-radius: var(--radius-md); border: 1px solid var(--border);">
                <span class="material-symbols-outlined" style="font-size: 64px; margin-bottom: 16px; display: block; color: var(--primary); opacity: 0.7;">shopping_bag</span>
                <h3 style="font-family: 'Playfair Display', serif; font-size: 22px; color: var(--text); margin-bottom: 8px;">Chưa có đơn hàng nào</h3>
                <p>Những chiếc bánh ngọt ngào đang chờ bạn đặt tại tiệm.</p>
                <a href="<%= request.getContextPath() %>/home" class="btn btn-primary" style="margin-top: 20px; display: inline-block; text-decoration: none;">Đặt bánh ngay</a>
            </div>
        <%
            } else {
                java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("dd/MM/yyyy");
                java.text.DecimalFormat currencyFormat = new java.text.DecimalFormat("#,###");
                java.text.DecimalFormatSymbols symbols = new java.text.DecimalFormatSymbols();
                symbols.setGroupingSeparator('.');
                currencyFormat.setDecimalFormatSymbols(symbols);

                for (Order order : orders) {
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
                            displayStatus = "Đang xử lý";
                        } else if (dbStatus.equalsIgnoreCase("Delivering")) {
                            dataStatus = "shipping";
                            badgeClass = "status-shipping";
                            displayStatus = "Đang giao";
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

                    int totalQty = 0;
                    StringBuilder itemsSummary = new StringBuilder();
                    String firstItemImage = "";
                    List<OrderItem> items = order.getItems();
                    
                    if (items != null && !items.isEmpty()) {
                        for (int i = 0; i < items.size(); i++) {
                            OrderItem item = items.get(i);
                            totalQty += item.getQuantity();
                            
                            if (i > 0) {
                                itemsSummary.append(", ");
                            }
                            itemsSummary.append(item.getQuantity()).append("x ").append(item.getItemName());
                            
                            if (i == 0) {
                                String imgPath = item.getItemImage();
                                if (imgPath == null || imgPath.trim().isEmpty()) {
                                    firstItemImage = request.getContextPath() + "/assets/images/default-cake.png";
                                } else if (!imgPath.startsWith("http") && !imgPath.startsWith("https")) {
                                    if (!imgPath.startsWith("/")) {
                                        firstItemImage = request.getContextPath() + "/" + imgPath;
                                    } else {
                                        firstItemImage = request.getContextPath() + imgPath;
                                    }
                                } else {
                                    firstItemImage = imgPath;
                                }
                            }
                        }
                    } else {
                        itemsSummary.append("Sản phẩm tùy chỉnh");
                        firstItemImage = request.getContextPath() + "/assets/images/default-cake.png";
                    }

                    String formattedDate = order.getOrderTime() != null ? dateFormat.format(order.getOrderTime()) : "";
                    String formattedTotal = order.getTotalCost() != null ? currencyFormat.format(order.getTotalCost()) + "đ" : "0đ";
        %>
            <!-- Order Card -->
            <div class="order-card" data-status="<%= dataStatus %>" <%= "cancelled".equals(dataStatus) ? "style=\"opacity: 0.75;\"" : "" %>>
                <div class="order-card-header">
                    <div class="order-info">
                        <span class="order-code">Mã đơn: #<%= order.getOrderNo() %></span>
                        <span class="order-date">Ngày đặt: <%= formattedDate %></span>
                    </div>
                    <span class="status-badge <%= badgeClass %>"><%= displayStatus %></span>
                </div>
                <div class="order-card-body">
                    <img class="order-item-img" <%= "cancelled".equals(dataStatus) ? "style=\"filter: grayscale(100%);\"" : "" %> alt="<%= itemsSummary %>" src="<%= firstItemImage %>" onerror="this.src='<%= request.getContextPath() %>/assets/images/default-cake.png';"/>
                    <div class="order-item-details">
                        <div class="order-item-names"><%= itemsSummary %></div>
                        <div class="order-item-qty">Số lượng: <%= totalQty %> sản phẩm</div>
                    </div>
                </div>
                <div class="order-card-footer">
                    <div class="order-total">
                        <span>Tổng thanh toán:</span>
                        <strong><%= formattedTotal %></strong>
                    </div>
                    <div class="order-actions">
                        <button class="btn btn-outline" onclick="window.location.href='<%= request.getContextPath() %>/OrderDetail?orderNo=<%= order.getOrderNo() %>'">Xem chi tiết</button>
                        <button class="btn btn-primary">Đặt lại</button>
                    </div>
                </div>
            </div>
        <%
                }
            }
        %>
        </section>

        <!-- Help Section (Asymmetric Bento Style) -->
        <section class="help-section">
            <div class="help-banner">
                <div class="help-banner-content">
                    <h2>Bạn cần hỗ trợ?</h2>
                    <p>Chúng tôi luôn sẵn sàng lắng nghe và giải đáp mọi thắc mắc về đơn hàng của bạn.</p>
                    <button class="btn">Liên hệ ngay</button>
                </div>
                <span class="material-symbols-outlined help-banner-icon">cake</span>
            </div>
            
            <div class="shipping-card">
                <div class="shipping-icon-wrap">
                    <span class="material-symbols-outlined">local_shipping</span>
                </div>
                <h3>Chính sách vận chuyển</h3>
                <a href="#">Xem chi tiết</a>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const filterButtons = document.querySelectorAll('.filter-btn');
            const orderCards = document.querySelectorAll('.order-card');

            filterButtons.forEach(btn => {
                btn.addEventListener('click', function() {
                    // Cập nhật trạng thái active cho các nút bộ lọc
                    filterButtons.forEach(b => b.classList.remove('active'));
                    this.classList.add('active');

                    const filterValue = this.getAttribute('data-filter');

                    // Ẩn/hiện đơn hàng dựa trên data-status tương ứng
                    orderCards.forEach(card => {
                        if (filterValue === 'all') {
                            card.style.display = 'flex';
                        } else {
                            if (card.getAttribute('data-status') === filterValue) {
                                card.style.display = 'flex';
                            } else {
                                card.style.display = 'none';
                            }
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>