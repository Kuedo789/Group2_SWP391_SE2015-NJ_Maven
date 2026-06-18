<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="com.bakeryzone.model.User" %>
<%
    String currentStatus = (String) request.getAttribute("status");
    if (currentStatus == null) {
        currentStatus = "all";
    }

    String startDateVal = request.getAttribute("startDate") != null ? request.getAttribute("startDate").toString() : "";
    String endDateVal = request.getAttribute("endDate") != null ? request.getAttribute("endDate").toString() : "";

    String dateParams = "";
    if (!startDateVal.isEmpty()) {
        dateParams += "&startDate=" + startDateVal;
    }
    if (!endDateVal.isEmpty()) {
        dateParams += "&endDate=" + endDateVal;
    }
%>
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

        <%-- Success banner after placing an order --%>
        <%
            String msgParam   = request.getParameter("msg");
            String orderNoParam = request.getParameter("orderNo");
            boolean orderSuccess = "order_success".equals(msgParam);
        %>
        <% if (orderSuccess) { %>
        <div id="orderSuccessBanner" style="
            background: linear-gradient(135deg, #1b3322 0%, #2d5037 100%);
            color: white;
            border-radius: 16px;
            padding: 24px 32px;
            margin: 0 0 28px 0;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 8px 30px rgba(27,51,34,0.18);
            animation: slideDown 0.4s ease;">
            <span class="material-symbols-outlined" style="font-size: 40px; color: #c5a880; flex-shrink: 0;">check_circle</span>
            <div>
                <div style="font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; margin-bottom: 4px;">Đặt hàng thành công! 🎂</div>
                <div style="font-size: 14px; color: rgba(255,255,255,0.8);">
                    Đơn hàng <strong style="color:#c5a880;"><%= orderNoParam != null ? orderNoParam : "" %></strong>
                    đã được tạo và đang chờ bếp xác nhận. Chúng tôi sẽ liên hệ sớm nhất!
                </div>
            </div>
            <button onclick="document.getElementById('orderSuccessBanner').style.display='none'"
                    style="margin-left:auto; background:none; border:none; color:rgba(255,255,255,0.6); font-size:22px; cursor:pointer; line-height:1;">&times;</button>
        </div>
        <style>@keyframes slideDown { from { opacity:0; transform:translateY(-16px); } to { opacity:1; transform:translateY(0); } }</style>
        <% } %>

        <!-- Filters Section -->
        <section class="orders-filter" style="display: flex; gap: 10px; justify-content: center; margin-bottom: 25px;">
            <a href="<%= request.getContextPath() %>/OrderList?status=all<%= dateParams %>" class="filter-btn <%= "all".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Tất cả</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=processing<%= dateParams %>" class="filter-btn <%= "processing".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đang xử lý</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=shipping<%= dateParams %>" class="filter-btn <%= "shipping".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đang giao</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=completed<%= dateParams %>" class="filter-btn <%= "completed".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hoàn thành</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=cancelled<%= dateParams %>" class="filter-btn <%= "cancelled".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đã hủy</a>
        </section>

        <!-- Date Range Filter -->
        <section class="date-filter" style="margin: 20px auto; max-width: 900px; display: flex; gap: 15px; align-items: center; justify-content: center; background: var(--card); padding: 15px; border-radius: var(--radius-md); border: 1px solid var(--border);">
            <form action="<%= request.getContextPath() %>/OrderList" method="GET" style="display: flex; gap: 15px; align-items: center; flex-wrap: wrap; justify-content: center;">
                <input type="hidden" name="status" value="<%= currentStatus %>" />
                <label for="startDate" style="font-weight: 600; font-size: 14px;">Từ ngày:</label>
                <input type="date" id="startDate" name="startDate" value="<%= request.getAttribute("startDate") != null ? request.getAttribute("startDate") : "" %>" style="padding: 8px 12px; border: 1px solid var(--border); border-radius: var(--radius-sm); font-family: inherit; background: var(--bg-soft); color: var(--text);" />
                
                <label for="endDate" style="font-weight: 600; font-size: 14px;">Đến ngày:</label>
                <input type="date" id="endDate" name="endDate" value="<%= request.getAttribute("endDate") != null ? request.getAttribute("endDate") : "" %>" style="padding: 8px 12px; border: 1px solid var(--border); border-radius: var(--radius-sm); font-family: inherit; background: var(--bg-soft); color: var(--text);" />
                
                <button type="submit" class="btn btn-primary" style="padding: 8px 20px; border-radius: var(--radius-sm);">Lọc</button>
                <% if ((request.getAttribute("startDate") != null && !request.getAttribute("startDate").toString().isEmpty()) || (request.getAttribute("endDate") != null && !request.getAttribute("endDate").toString().isEmpty())) { %>
                    <a href="<%= request.getContextPath() %>/OrderList" class="btn btn-outline" style="padding: 8px 20px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; height: 38px; border-radius: var(--radius-sm);">Xóa bộ lọc</a>
                <% } %>
            </form>
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
                        // English keys
                        if (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equals("Chờ xác nhận")) {
                            dataStatus = "processing";
                            badgeClass = "status-processing";
                            displayStatus = "Chờ xác nhận";
                        } else if (dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equals("Đã xác nhận")) {
                            dataStatus = "processing";
                            badgeClass = "status-processing";
                            displayStatus = "Đã xác nhận";
                        } else if (dbStatus.equalsIgnoreCase("Processing") || dbStatus.equals("Đang xử lý")) {
                            dataStatus = "processing";
                            badgeClass = "status-processing";
                            displayStatus = "Đang xử lý";
                        } else if (dbStatus.equalsIgnoreCase("Delivering")
                                || dbStatus.equals("Đang giao hàng")
                                || dbStatus.equals("Đang giao")) {
                            dataStatus = "shipping";
                            badgeClass = "status-shipping";
                            displayStatus = "Đang giao hàng";
                        } else if (dbStatus.equalsIgnoreCase("Completed")
                                || dbStatus.equals("Hoàn thành")
                                || dbStatus.equals("Đã giao")) {
                            dataStatus = "completed";
                            badgeClass = "status-completed";
                            displayStatus = "Hoàn thành";
                        } else if (dbStatus.equalsIgnoreCase("Cancelled")
                                || dbStatus.equalsIgnoreCase("Canceled")
                                || dbStatus.equals("Đã hủy")) {
                            dataStatus = "cancelled";
                            badgeClass = "status-cancelled";
                            displayStatus = "Đã hủy";
                        }
                    }

                    int totalQty = 0;
                    StringBuilder itemsSummary = new StringBuilder();
                    String firstItemImage = "";
                    String firstItemTemplateImage = "";
                    String firstItemTemplateId = "";
                    String firstItemCustomCakeId = "";
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
                                
                                String tplImg = item.getTemplateImage();
                                if (tplImg != null && !tplImg.trim().isEmpty()) {
                                    if (!tplImg.startsWith("http") && !tplImg.startsWith("https")) {
                                        if (!tplImg.startsWith("/")) {
                                            firstItemTemplateImage = request.getContextPath() + "/" + tplImg;
                                        } else {
                                            firstItemTemplateImage = request.getContextPath() + tplImg;
                                        }
                                    } else {
                                        firstItemTemplateImage = tplImg;
                                    }
                                }
                                firstItemTemplateId = item.getTemplateId() != null ? item.getTemplateId() : "";
                                firstItemCustomCakeId = item.getCustomCakeId() != null ? item.getCustomCakeId() : "";
                            }
                        }
                    } else {
                        itemsSummary.append("Sản phẩm tùy chỉnh");
                        firstItemImage = request.getContextPath() + "/assets/images/default-cake.png";
                    }

                    User currentUser = (User) session.getAttribute("user");
                    com.bakeryzone.dao.ReviewDAO reviewDAO = new com.bakeryzone.dao.ReviewDAO();
                    boolean hasReviewed = false;
                    if (currentUser != null && firstItemTemplateId != null && !firstItemTemplateId.isEmpty()) {
                        hasReviewed = reviewDAO.hasReviewed(currentUser.getUserId(), firstItemTemplateId);
                    }

                    String formattedDate = order.getOrderTime() != null ? dateFormat.format(order.getOrderTime()) : "";
                    String formattedTotal = order.getTotalCost() != null ? currencyFormat.format(order.getTotalCost()) + "đ" : "0đ";
        %>
            <!-- Order Card -->
            <div class="order-card" data-status="<%= dataStatus %>" <%= "cancelled".equals(dataStatus) ? "style=\"opacity: 0.75;\"" : "" %>>
                <div class="order-card-header">
                    <div class="order-info">
                        <span class="order-code" style="cursor: pointer;" onclick="window.location.href='<%= request.getContextPath() %>/OrderDetail?orderNo=<%= order.getOrderNo() %>'">Mã đơn: #<%= order.getOrderNo().replace("ORD_", "") %></span>
                        <span class="order-date">Ngày đặt: <%= formattedDate %></span>
                    </div>
                    <span class="status-badge <%= badgeClass %>"><%= displayStatus %></span>
                </div>
                <div class="order-card-body" style="cursor: pointer; display: flex; flex-direction: column; gap: 15px;" onclick="window.location.href='<%= request.getContextPath() %>/OrderDetail?orderNo=<%= order.getOrderNo() %>'">
                    <% 
                    if (items != null && !items.isEmpty()) {
                        for (OrderItem item : items) {
                            String itemImage = "";
                            String imgPath = item.getItemImage();
                            if (imgPath == null || imgPath.trim().isEmpty()) {
                                itemImage = request.getContextPath() + "/assets/images/default-cake.png";
                            } else if (!imgPath.startsWith("http") && !imgPath.startsWith("https")) {
                                if (!imgPath.startsWith("/")) {
                                    itemImage = request.getContextPath() + "/" + imgPath;
                                } else {
                                    itemImage = request.getContextPath() + imgPath;
                                }
                            } else {
                                itemImage = imgPath;
                            }

                            String tplImg = item.getTemplateImage();
                            String itemTemplateImage = "";
                            if (tplImg != null && !tplImg.trim().isEmpty()) {
                                if (!tplImg.startsWith("http") && !tplImg.startsWith("https")) {
                                    if (!tplImg.startsWith("/")) {
                                        itemTemplateImage = request.getContextPath() + "/" + tplImg;
                                    } else {
                                        itemTemplateImage = request.getContextPath() + tplImg;
                                    }
                                } else {
                                    itemTemplateImage = tplImg;
                                }
                            }
                    %>
                            <%
                                String itemTemplateId = item.getTemplateId() != null ? item.getTemplateId() : "";
                                String itemCustomCakeId = item.getCustomCakeId() != null ? item.getCustomCakeId() : "";
                                boolean itemReviewed = false;
                                if (currentUser != null && !itemTemplateId.isEmpty()) {
                                    itemReviewed = reviewDAO.hasReviewed(currentUser.getUserId(), itemTemplateId);
                                }
                            %>
                            <div class="order-item-row" style="display: flex; gap: 15px; align-items: center; width: 100%;">
                                <img class="order-item-img" <%= "cancelled".equals(dataStatus) ? "style=\"filter: grayscale(100%);\"" : "" %> alt="<%= item.getItemName() %>" src="<%= itemImage %>" data-template-image="<%= itemTemplateImage %>" onerror="this.src = this.getAttribute('data-template-image') || '<%= request.getContextPath() %>/assets/images/default-cake.png'; this.onerror = function() { this.src = '<%= request.getContextPath() %>/assets/images/default-cake.png'; };" style="width: 70px; height: 70px; border-radius: var(--radius-sm); object-fit: cover; border: 1px solid var(--border);"/>
                                <div class="order-item-details" style="flex: 1;">
                                    <div class="order-item-names" style="font-weight: 600; color: var(--text);"><%= item.getItemName() %></div>
                                    <div class="order-item-version" style="font-size: 13px; color: var(--muted); margin: 3px 0;">Phiên bản: <%= item.getVariationName() != null ? item.getVariationName() : "Sản phẩm" %></div>
                                    <div class="order-item-qty" style="font-size: 13px; color: var(--muted);">Số lượng: x<%= item.getQuantity() %></div>
                                    <% if ("completed".equals(dataStatus) && !itemTemplateId.isEmpty()) { %>
                                        <div style="margin-top: 5px;">
                                            <% if (itemReviewed) { %>
                                                <button class="btn btn-outline" style="padding: 4px 10px; font-size: 11px; height: auto; display: inline-block; min-width: auto; width: auto;" onclick="window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review'">Xem đánh giá</button>
                                            <% } else { %>
                                                <button class="btn btn-primary" style="padding: 4px 10px; font-size: 11px; height: auto; display: inline-block; min-width: auto; width: auto; background: var(--primary); color: white; border: none; border-radius: var(--radius-sm);" onclick="window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review&customCakeId=<%= itemCustomCakeId %>'">Đánh giá</button>
                                            <% } %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                    <%
                        }
                    } else {
                    %>
                        <div class="order-item-row" style="display: flex; gap: 15px; align-items: center; width: 100%;">
                            <img class="order-item-img" alt="Default cake" src="<%= request.getContextPath() %>/assets/images/default-cake.png" style="width: 70px; height: 70px; border-radius: var(--radius-sm); object-fit: cover; border: 1px solid var(--border);"/>
                            <div class="order-item-details" style="flex: 1;">
                                <div class="order-item-names" style="font-weight: 600; color: var(--text);">Sản phẩm tùy chỉnh</div>
                            </div>
                        </div>
                    <%
                    }
                    %>
                </div>
                <div class="order-card-footer">
                    <div class="order-total">
                        <span>Tổng thanh toán:</span>
                        <strong><%= formattedTotal %></strong>
                    </div>
                    <div class="order-actions">
                        <button class="btn btn-outline" style="min-width: 44px; padding: 0 12px; display: inline-flex; align-items: center; justify-content: center;" onclick="alert('Đã thêm tất cả sản phẩm trong đơn vào giỏ hàng của bạn!');" title="Thêm vào giỏ hàng">
                            <span class="material-symbols-outlined" style="font-size: 20px;">add_shopping_cart</span>
                        </button>
                        
                        <% if ("completed".equals(dataStatus)) { %>
                            <button class="btn btn-outline" style="cursor: default; opacity: 0.7;" disabled>Đã hoàn thành</button>
                        <% } else if ("cancelled".equals(dataStatus)) { %>
                            <button class="btn btn-outline" onclick="alert('Đã thêm tất cả sản phẩm trong đơn vào giỏ hàng của bạn!');">Đặt lại</button>
                        <% } else { %>
                            <button class="btn btn-primary" onclick="window.location.href='<%= request.getContextPath() %>/OrderDetail?orderNo=<%= order.getOrderNo() %>'">Xem tiến độ</button>
                        <% } %>
                    </div>
                </div>
            </div>
        <%
                }
            }
        %>
        </section>

        <!-- Pagination Section -->
        <%
            Object curPageObj = request.getAttribute("currentPage");
            Object totPagesObj = request.getAttribute("totalPages");
            int currentPage = curPageObj != null ? (Integer) curPageObj : 1;
            int totalPages = totPagesObj != null ? (Integer) totPagesObj : 1;
            
            String startDateParam = "";
            if (request.getAttribute("startDate") != null && !request.getAttribute("startDate").toString().isEmpty()) {
                startDateParam = "&startDate=" + request.getAttribute("startDate");
            }
            String endDateParam = "";
            if (request.getAttribute("endDate") != null && !request.getAttribute("endDate").toString().isEmpty()) {
                endDateParam = "&endDate=" + request.getAttribute("endDate");
            }
            String statusParam = "&status=" + currentStatus;
            
            if (totalPages > 1) {
        %>
            <div class="pagination" style="display: flex; justify-content: center; align-items: center; gap: 10px; margin-top: 40px; margin-bottom: 40px;">
                <% if (currentPage > 1) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= currentPage - 1 %><%= statusParam %><%= startDateParam %><%= endDateParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">Trước</a>
                <% } %>
                
                <% for (int i = 1; i <= totalPages; i++) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= i %><%= statusParam %><%= startDateParam %><%= endDateParam %>" class="btn <%= i == currentPage ? "btn-primary" : "btn-outline" %>" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);"><%= i %></a>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= currentPage + 1 %><%= statusParam %><%= startDateParam %><%= endDateParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">Sau</a>
                <% } %>
            </div>
        <% } %>

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

    <!-- Client side script for interaction, status filters are handled server side -->
    <script>
        // No client-side show/hide is needed since list is filtered server-side
    </script>
</body>
</html>