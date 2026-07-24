<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="com.bakeryzone.model.OrderItem" %>
<%@ page import="com.bakeryzone.model.User" %>

<c:set var="userRole" value="${sessionScope.user.roleId}" />

<c:choose>
    <c:when test="${userRole eq 'CUSTOMER'}">
<%
    String currentStatus = (String) request.getAttribute("status");
    if (currentStatus == null) {
        currentStatus = "all";
    }

    String startDateVal = request.getAttribute("startDate") != null ? request.getAttribute("startDate").toString() : "";
    String endDateVal = request.getAttribute("endDate") != null ? request.getAttribute("endDate").toString() : "";
    String searchVal = request.getAttribute("search") != null ? request.getAttribute("search").toString() : "";
    String sortVal = request.getAttribute("sort") != null ? request.getAttribute("sort").toString() : "date_desc";

    String searchParams = !searchVal.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchVal, "UTF-8") : "";
    String sortParams = "&sort=" + sortVal;
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
    <jsp:include page="/common/header.jsp" />
    <title>Đơn hàng của tôi - ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}</title>
</head>
<body>
    <!-- Navigation Bar -->
    <jsp:include page="/common/navbar.jsp" />

    <main class="orders-page">
        <!-- Header Section -->
        <section class="orders-title">
            <h1>Đơn hàng của tôi</h1>
            <p>Theo dõi trạng thái và quản lý lịch sử những chiếc bánh ngọt ngào bạn đã đặt tại ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}.</p>
        </section>

        <%-- Success banner after placing an order --%>
        <%
            String msgParam   = request.getParameter("msg");
            String orderNoParam = request.getParameter("orderNo");
            boolean orderSuccess = "order_success".equals(msgParam);
        %>
        <% if (orderSuccess) { %>
        <div id="orderSuccessBanner" class="cz-banner-success">
            <span class="material-symbols-outlined banner-icon">check_circle</span>
            <div>
                <div class="banner-title">Đặt hàng thành công! 🎂</div>
                <div class="banner-desc">
                    Đơn hàng <strong><%= orderNoParam != null ? orderNoParam : "" %></strong>
                    đã được tạo và đang chờ bếp xác nhận. Chúng tôi sẽ liên hệ sớm nhất!
                </div>
            </div>
            <button onclick="document.getElementById('orderSuccessBanner').style.display='none'" class="banner-close">&times;</button>
        </div>
        <% } %>

        <%-- Error banner if date filtering is invalid --%>
        <c:if test="${not empty errorMessage}">
            <div id="orderErrorBanner" class="cz-banner-error">
                <span class="material-symbols-outlined banner-icon">error</span>
                <div class="banner-desc">
                    <c:out value="${errorMessage}" />
                </div>
                <button onclick="document.getElementById('orderErrorBanner').style.display='none'" class="banner-close">&times;</button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <!-- Filters Section -->
        <section class="orders-filter" style="display: flex; gap: 12px; justify-content: flex-start; margin-bottom: 25px; flex-wrap: wrap;">
            <a href="<%= request.getContextPath() %>/OrderList?status=all<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "all".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Tất cả (<%= request.getAttribute("countAll") != null ? request.getAttribute("countAll") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=paid<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "paid".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;"><%= com.bakeryzone.model.OrderStatus.PAID.getDescription() %> (<%= request.getAttribute("countPaid") != null ? request.getAttribute("countPaid") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=processing<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "processing".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;"><%= com.bakeryzone.model.OrderStatus.Processing.getDescription() %> (<%= request.getAttribute("countProcessing") != null ? request.getAttribute("countProcessing") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=shipping<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "shipping".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;"><%= com.bakeryzone.model.OrderStatus.Delivering.getDescription() %> (<%= request.getAttribute("countShipping") != null ? request.getAttribute("countShipping") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=completed<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "completed".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;"><%= com.bakeryzone.model.OrderStatus.Completed.getDescription() %> (<%= request.getAttribute("countCompleted") != null ? request.getAttribute("countCompleted") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=cancelled<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "cancelled".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;"><%= com.bakeryzone.model.OrderStatus.Cancelled.getDescription() %> (<%= request.getAttribute("countCancelled") != null ? request.getAttribute("countCancelled") : 0 %>)</a>
        </section>


        <!-- Date Range, Search & Sort Filter Card -->
        <section class="my-orders-filter-card">
            <form id="dateFilterForm" class="my-orders-filter-form" action="<%= request.getContextPath() %>/OrderList" method="GET">
                <input type="hidden" name="status" value="<%= currentStatus %>" />
                <input type="hidden" name="sort" value="<%= sortVal %>" />
                
                <div class="filter-inputs-row">
                    <div class="filter-field-group">
                        <span class="filter-field-label">Tìm kiếm:</span>
                        <div class="pill-control-wrap">
                            <span class="material-symbols-outlined pill-search-icon">search</span>
                            <input type="text" name="search" class="pill-search-input" value="<c:out value='${search}'/>" placeholder="Mã đơn hàng, sản phẩm, ..." />
                        </div>
                    </div>

                    <div class="filter-field-group">
                        <span class="filter-field-label">Từ ngày:</span>
                        <div class="pill-control-wrap">
                            <input type="date" id="startDate" name="startDate" class="pill-date-input" value="<%= request.getAttribute("startDate") != null ? request.getAttribute("startDate") : "" %>" />
                        </div>
                    </div>

                    <div class="filter-field-group">
                        <span class="filter-field-label">Đến ngày:</span>
                        <div class="pill-control-wrap">
                            <input type="date" id="endDate" name="endDate" class="pill-date-input" value="<%= request.getAttribute("endDate") != null ? request.getAttribute("endDate") : "" %>" />
                        </div>
                    </div>
                </div>

                <div class="filter-actions-row">
                    <div class="quick-filters-box">
                        <span class="quick-filters-label">Lọc nhanh:</span>
                        <button type="button" id="btn-7days" class="pill-btn-outline" onclick="setQuickFilter(7)">7 ngày</button>
                        <button type="button" id="btn-30days" class="pill-btn-outline" onclick="setQuickFilter(30)">30 ngày</button>
                    </div>

                    <div class="right-action-buttons">
                        <a href="<%= request.getContextPath() %>/OrderList" class="pill-btn-outline">Làm mới</a>
                        <button type="submit" class="pill-btn-submit">Lọc kết quả</button>
                    </div>
                </div>
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
                <a href="<%= request.getContextPath() %>/home" class="btn btn-primary" style="margin-top: 20px; text-decoration: none;">Đặt bánh ngay</a>
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
                        displayStatus = order.getOrderStatusForCustomer(); // Lấy tên tiếng việt (ẩn Waiting_Delivery)
                        if (dbStatus.equals("PAID")) {
                            dataStatus = "paid";
                            badgeClass = "status-confirmed\" style=\"background-color: #d1fae5; color: #065f46;";
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
                                                <button class="btn btn-outline" style="padding: 4px 10px; font-size: 11px; height: auto; display: inline-block; min-width: auto; width: auto;" onclick="event.stopPropagation(); window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review'">Xem đánh giá</button>
                                            <% } else { %>
                                                <button class="btn btn-primary" style="padding: 4px 10px; font-size: 11px; height: auto; display: inline-block; min-width: auto; width: auto; background: var(--primary); color: white; border: none; border-radius: var(--radius-sm);" onclick="event.stopPropagation(); window.location.href='<%= request.getContextPath() %>/product-detail?id=<%= itemTemplateId %>&tab=review&customCakeId=<%= itemCustomCakeId %>'">Đánh giá</button>
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
                    <div class="order-total" style="display: flex; flex-direction: column; align-items: flex-start; justify-content: center; gap: 2px; flex: 1;">
                        <div style="display: flex; align-items: baseline; gap: 8px;">
                            <span style="font-size: 14px; font-weight: 500;">Thành tiền:</span>
                            <strong style="color: #9b1c1c; font-size: 18px;"><%= currencyFormat.format(order.getRemainingCodBalance() != null ? order.getRemainingCodBalance().doubleValue() : (order.getTotalCost() != null ? order.getTotalCost().doubleValue() : 0)) %>đ</strong>
                        </div>
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
                                String image = (item.getItemImage() != null && !item.getItemImage().isEmpty())
                                         ? item.getItemImage().replace("\\", "/")
                                         : (item.getTemplateImage() != null && !item.getTemplateImage().isEmpty()
                                             ? item.getTemplateImage().replace("\\", "/")
                                             : "assets/images/default-cake.png");
                                
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
                    <div class="order-actions">
                        <button class="btn btn-outline" style="min-width: 44px; padding: 0 12px; display: inline-flex; align-items: center; justify-content: center;" onclick="addOrderToCart('<%= order.getOrderNo() %>')" title="Thêm vào giỏ hàng">
                            <span class="material-symbols-outlined" style="font-size: 20px;">add_shopping_cart</span>
                        </button>
                        
                        <% if ("completed".equals(dataStatus)) { %>
                            <button class="btn" onclick="reorderOrder('<%= order.getOrderNo() %>')" style="background-color: #2e7d32; color: white; border: none; font-weight: 700; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#1b5e20'" onmouseout="this.style.backgroundColor='#2e7d32'">Đặt lại</button>
                        <% } else if ("cancelled".equals(dataStatus)) { %>
                            <button class="btn" onclick="reorderOrder('<%= order.getOrderNo() %>')" style="background-color: #2e7d32; color: white; border: none; font-weight: 700; transition: all 0.2s;" onmouseover="this.style.backgroundColor='#1b5e20'" onmouseout="this.style.backgroundColor='#2e7d32'">Đặt lại</button>
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
            String searchParam = !searchVal.isEmpty() ? "&search=" + java.net.URLEncoder.encode(searchVal, "UTF-8") : "";
            String sortParam = "&sort=" + sortVal;
            String statusParam = "&status=" + currentStatus;
            
            if (totalPages > 0) {
                // Windowed pagination: hiển thị tối đa 7 số trang quanh trang hiện tại
                int windowSize = 7;
                int half = windowSize / 2;
                int winStart = Math.max(1, currentPage - half);
                int winEnd = Math.min(totalPages, winStart + windowSize - 1);
                if (winEnd - winStart + 1 < windowSize) {
                    winStart = Math.max(1, winEnd - windowSize + 1);
                }
        %>
            <div class="pagination" style="display: flex; justify-content: center; align-items: center; gap: 10px; margin-top: 40px; margin-bottom: 40px;">
                <%-- Nút Trước --%>
                <% if (currentPage > 1) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= currentPage - 1 %><%= statusParam %><%= startDateParam %><%= endDateParam %><%= searchParam %><%= sortParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">Trước</a>
                <% } else { %>
                    <button class="btn btn-outline" style="padding: 8px 16px; border-radius: var(--radius-sm); opacity: 0.5; cursor: not-allowed;" disabled>Trước</button>
                <% } %>

                <%-- Ellipsis đầu nếu cần --%>
                <% if (winStart > 1) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=1<%= statusParam %><%= startDateParam %><%= endDateParam %><%= searchParam %><%= sortParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">1</a>
                    <% if (winStart > 2) { %><span style="padding: 0 4px; color: #999;">...</span><% } %>
                <% } %>

                <%-- Số trang trong cửa sổ --%>
                <% for (int i = winStart; i <= winEnd; i++) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= i %><%= statusParam %><%= startDateParam %><%= endDateParam %><%= searchParam %><%= sortParam %>" class="btn <%= i == currentPage ? "btn-primary" : "btn-outline" %>" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);"><%= i %></a>
                <% } %>

                <%-- Ellipsis cuối nếu cần --%>
                <% if (winEnd < totalPages) { %>
                    <% if (winEnd < totalPages - 1) { %><span style="padding: 0 4px; color: #999;">...</span><% } %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= totalPages %><%= statusParam %><%= startDateParam %><%= endDateParam %><%= searchParam %><%= sortParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);"><%= totalPages %></a>
                <% } %>

                <%-- Nút Sau --%>
                <% if (currentPage < totalPages) { %>
                    <a href="<%= request.getContextPath() %>/OrderList?page=<%= currentPage + 1 %><%= statusParam %><%= startDateParam %><%= endDateParam %><%= searchParam %><%= sortParam %>" class="btn btn-outline" style="text-decoration: none; padding: 8px 16px; border-radius: var(--radius-sm);">Sau</a>
                <% } else { %>
                    <button class="btn btn-outline" style="padding: 8px 16px; border-radius: var(--radius-sm); opacity: 0.5; cursor: not-allowed;" disabled>Sau</button>
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
    <jsp:include page="/common/footer.jsp" />
    <jsp:include page="/common/scripts.jsp" />

    <!-- Client side script for interaction, status filters are handled server side -->
    <script>
        function setQuickFilter(days) {
            const end = new Date();
            const start = new Date();
            start.setDate(end.getDate() - days);
            
            const formatDate = (date) => {
                const yyyy = date.getFullYear();
                const mm = String(date.getMonth() + 1).padStart(2, '0');
                const dd = String(date.getDate()).padStart(2, '0');
                return yyyy + '-' + mm + '-' + dd;
            };
            
            document.getElementById('startDate').value = formatDate(start);
            document.getElementById('endDate').value = formatDate(end);
            document.getElementById('dateFilterForm').submit();
        }

        document.addEventListener("DOMContentLoaded", function() {
            // Date Filter Frontend Validation
            const dateFilterForm = document.getElementById('dateFilterForm');
            if (dateFilterForm) {
                dateFilterForm.addEventListener('submit', function(e) {
                    const startVal = document.getElementById('startDate').value;
                    const endVal = document.getElementById('endDate').value;
                    if (startVal && endVal) {
                        const start = new Date(startVal);
                        const end = new Date(endVal);
                        if (start > end) {
                            e.preventDefault();
                            alert("Ngày bắt đầu không được lớn hơn Ngày kết thúc!");
                            return false;
                        }
                    }
                });
            }

            const startVal = document.getElementById('startDate').value;
            const endVal = document.getElementById('endDate').value;
            if (startVal && endVal) {
                const start = new Date(startVal);
                const end = new Date(endVal);
                start.setHours(0,0,0,0);
                end.setHours(0,0,0,0);
                
                const today = new Date();
                today.setHours(0,0,0,0);
                
                if (end.getTime() === today.getTime()) {
                    const diffTime = Math.abs(end - start);
                    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                    
                    if (diffDays === 7) {
                        const btn = document.getElementById('btn-7days');
                        if (btn) btn.classList.add('active-filter');
                    } else if (diffDays === 30) {
                        const btn = document.getElementById('btn-30days');
                        if (btn) btn.classList.add('active-filter');
                    }
                }
            }
        });

        function addOrderToCart(orderNo) {
            if (!orderNo) return;
            const ctxPath = '<%= request.getContextPath() %>';
            const params = new URLSearchParams();
            params.append("action", "reorderToCart");
            params.append("orderNo", orderNo);

            fetch(ctxPath + "/cart", {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params.toString()
            }).then(res => res.json()).then(data => {
                if (data && data.success) {
                    const countEl = document.getElementById("navCartCount");
                    if (countEl && data.cartCount !== undefined) countEl.innerText = data.cartCount;
                    
                    if (typeof showFloatingAlert === 'function') {
                        showFloatingAlert(data.message || "Đã thêm sản phẩm vào giỏ hàng!", "success");
                    } else {
                        alert(data.message || "Đã thêm sản phẩm vào giỏ hàng!");
                    }
                } else {
                    if (typeof showFloatingAlert === 'function') {
                        showFloatingAlert(data.message || "Có lỗi xảy ra khi thêm vào giỏ hàng!", "danger");
                    } else {
                        alert(data.message || "Có lỗi xảy ra khi thêm vào giỏ hàng!");
                    }
                }
            }).catch(e => console.error(e));
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

  <!-- ADMIN, STAFF,SHIPPER -->

</html>
    </c:when>
    <c:otherwise>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="${userRole eq 'SHIPPER' ? 'CakeZone Shipper - Đơn hàng được phân công' : 'CakeZone Admin - Quản lý đơn hàng'}" />
    </jsp:include>
    <link href="${pageContext.request.contextPath}/assets/css/all/order.css" rel="stylesheet">
</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="orders" />
    </jsp:include>

    <div class="main-panel">
        <!-- Top Header -->
        <jsp:include page="/common/top-header.jsp">
            <jsp:param name="activeMenu" value="${userRole eq 'SHIPPER' ? 'Đơn hàng được phân công' : 'Quản lý đơn hàng'}" />
        </jsp:include>

        <div class="content-container">
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">${userRole eq 'SHIPPER' ? 'Đơn hàng được phân công' : 'Quản lý đơn hàng'}</h1>
                    <c:choose>
                        <c:when test="${userRole eq 'SHIPPER'}">
                            <p class="page-subtitle" style="display: flex; align-items: center; gap: 8px; margin-top: 5px;">
                                Khu vực giao hàng phụ trách của bạn: 
                                <span class="badge" style="font-size: 13px; padding: 5px 10px; border-radius: 4px; font-weight: 700; background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; display: inline-flex; align-items: center; gap: 4px;">
                                    <i class="fa-solid fa-location-dot"></i> <c:out value="${not empty managedZone ? managedZone : 'Toàn thành phố'}" />
                                </span>
                            </p>
                        </c:when>
                        <c:otherwise>
                            <p class="page-subtitle">Hệ thống theo dõi đơn đặt bánh, cập nhật trạng thái chế biến và giao hàng</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <c:if test="${userRole eq 'SHIPPER'}">
                <div class="cz-card" style="margin-bottom: 20px; border-left: 5px solid var(--cz-primary); padding: 20px; background: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
                    <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <div style="background-color: #f5f3f0; padding: 10px; border-radius: 8px; color: var(--cz-primary);">
                                <i class="fa-solid fa-truck-ramp-box" style="font-size: 24px; color: var(--cz-primary);"></i>
                            </div>
                            <div>
                                <h5 style="margin: 0; font-weight: 700; color: #333;">Trạng thái hoạt động & Khu vực làm việc</h5>
                                <p style="margin: 0; font-size: 13px; color: #666;">
                                    Cập nhật trạng thái trực tuyến và khu vực giao hàng của bạn để nhận đơn tự động
                                </p>
                            </div>
                        </div>
                        
                        <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-weight: 600; font-size: 14px;">Trạng thái:</span>
                                <div class="form-check form-switch" style="padding-left: 2.5em; margin: 0; display: inline-block;">
                                    <input class="form-check-input" type="checkbox" role="switch" id="shipper-active-switch" style="width: 2.5em; height: 1.25em; cursor: pointer;" ${isActiveStaff ? 'checked' : ''}>
                                    <label class="form-check-label fw-bold" for="shipper-active-switch" id="shipper-status-label" style="cursor: pointer; margin-left: 5px; font-size: 13.5px; color: ${isActiveStaff ? '#166534' : '#991b1b'};">
                                        ${isActiveStaff ? 'Trực tuyến (Online)' : 'Ngoại tuyến (Offline)'}
                                    </label>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="font-weight: 600; font-size: 14px;">Khu vực:</span>
                                <select id="shipper-zone-select" class="filter-select" style="padding: 6px 12px; border-radius: 6px; font-size: 13.5px; width: 180px; border: 1px solid #ccc;" ${not isActiveStaff ? 'disabled' : ''}>
                                    <option value="Zone 1" ${managedZone eq 'Zone 1' ? 'selected' : ''}>Zone 1</option>
                                    <option value="Zone 2" ${managedZone eq 'Zone 2' ? 'selected' : ''}>Zone 2</option>
                                    <option value="Zone 3" ${managedZone eq 'Zone 3' ? 'selected' : ''}>Zone 3</option>
                                    <option value="Zone 4" ${managedZone eq 'Zone 4' ? 'selected' : ''}>Zone 4</option>
                                    <option value="Zone 5" ${managedZone eq 'Zone 5' ? 'selected' : ''}>Zone 5</option>
                                    <option value="Zone 6" ${managedZone eq 'Zone 6' ? 'selected' : ''}>Zone 6</option>
                                    <option value="Toàn thành phố" ${managedZone eq 'Toàn thành phố' ? 'selected' : ''}>Toàn thành phố</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:set var="formAction" value="${pageContext.request.contextPath}/${userRole eq 'SHIPPER' ? 'shipper' : 'admin'}/orders" />
            <div class="filter-card">
                <form class="filter-form" action="${formAction}" method="GET" style="display: flex; flex-direction: column; gap: 15px; align-items: stretch;">
                    <input type="hidden" name="action" value="list">
                    
                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap; width: 100%;">
                        <div class="search-wrapper" style="flex: 1; min-width: 280px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" class="search-input" name="search" value="<c:out value='${search}'/>" placeholder="Tìm theo mã đơn, tên hoặc SĐT khách...">
                        </div>

                        <select class="filter-select" name="status" onchange="this.form.submit()">
                            <option value="all" ${empty status || status eq 'all' ? 'selected' : ''}>Tất cả trạng thái</option>
                            <c:if test="${userRole ne 'SHIPPER'}">
                                <option value="Waiting_Payment" ${status eq 'Waiting_Payment' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Waiting_Payment.getDescription() %></option>
                                <option value="PAID" ${status eq 'PAID' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.PAID.getDescription() %></option>
                                <option value="Processing" ${status eq 'Processing' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Processing.getDescription() %></option>
                                <option value="Waiting_Delivery" ${status eq 'Waiting_Delivery' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Waiting_Delivery.getDescription() %></option>
                            </c:if>
                            <option value="Delivering" ${status eq 'Delivering' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Delivering.getDescription() %></option>
                            <option value="Completed" ${status eq 'Completed' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Completed.getDescription() %></option>
                            <option value="Cancelled" ${status eq 'Cancelled' ? 'selected' : ''}><%= com.bakeryzone.model.OrderStatus.Cancelled.getDescription() %></option>
                        </select>

                        <select class="filter-select" name="cakeType" onchange="this.form.submit()">
                            <option value="all" ${empty cakeType || cakeType eq 'all' ? 'selected' : ''}>Tất cả loại bánh</option>
                            <option value="template" ${cakeType eq 'template' ? 'selected' : ''}>Bánh có sẵn</option>
                            <option value="custom" ${cakeType eq 'custom' ? 'selected' : ''}>Bánh thiết kế</option>
                        </select>

                        <select class="filter-select" name="sort" onchange="this.form.submit()">
                            <option value="date_desc" ${empty sort || sort eq 'date_desc' ? 'selected' : ''}>Mới nhất xếp trước</option>
                            <option value="date_asc" ${sort eq 'date_asc' ? 'selected' : ''}>Cũ nhất xếp trước</option>
                            <option value="price_desc" ${sort eq 'price_desc' ? 'selected' : ''}>Tổng tiền giảm dần</option>
                            <option value="price_asc" ${sort eq 'price_asc' ? 'selected' : ''}>Tổng tiền tăng dần</option>
                        </select>
                    </div>

                    <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap; width: 100%;">
                        <div class="date-container">
                            <span class="date-label">Từ:</span>
                            <input type="date" class="filter-date" name="startDate" value="${startDate}">
                        </div>

                        <div class="date-container">
                            <span class="date-label">Đến:</span>
                            <input type="date" class="filter-date" name="endDate" value="${endDate}">
                        </div>

                        <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                        <a href="${formAction}?action=list" class="btn-clear-filter text-center">Làm mới</a>
                    </div>
                </form>
            </div>

            <div class="table-card">
                <table class="cz-table">
                    <thead>
                        <tr>
                            <th style="width: 10%;">Mã đơn</th>
                            <th style="width: 22%;">Khách hàng</th>
                            <th style="width: 15%; text-align: center;">Thời gian đặt</th>
                            <th style="width: 13%; text-align: center;">Kiểu bánh</th>
                            <c:if test="${userRole eq 'SHIPPER'}">
                                <th style="width: 12%; text-align: right;">Tiền cọc</th>
                            </c:if>
                            <th style="width: 12%; text-align: right;">Tổng cộng</th>
                            <th style="width: 10%; text-align: center;">Trạng thái</th>
                            <th style="width: 8%; text-align: center;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty orders}">
                                <c:forEach items="${orders}" var="o">
                                    <tr class="clickable-row" onclick="window.location.href='${formAction}?action=detail&orderNo=${o.orderNo}'">
                                        <td class="fw-bold" style="color: var(--cz-primary);">
                                            #${o.orderNo.replace("ORD_", "")}
                                        </td>
                                        <td>
                                            <div class="fw-bold"><c:out value="${not empty o.customerName ? o.customerName : 'Khách vãng lai'}" /></div>
                                            <div class="text-muted" style="font-size: 11px; margin-bottom: 4px;">ID: ${o.customerId}</div>
                                            <c:if test="${userRole eq 'SHIPPER'}">
                                                <div style="font-size: 11px; color: #555; background-color: #f3f4f6; border: 1px solid #e5e7eb; padding: 2px 6px; border-radius: 4px; display: inline-block; max-width: 280px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${o.deliveryAddress}">
                                                    <i class="fa-solid fa-map-location-dot" style="color: #6b7280;"></i> <c:out value="${o.deliveryAddress}" />
                                                </div>
                                            </c:if>
                                        </td>
                                        <td style="text-align: center;">
                                            <fmt:formatDate value="${o.orderTime}" pattern="dd/MM/yyyy HH:mm" />
                                        </td>
                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.cakeTypeLabel eq 'Hỗn hợp'}">
                                                    <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
                                                        <span class="badge" style="background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-weight: 700; padding: 3px 8px; border-radius: 8px; font-size: 11px; width: fit-content;">
                                                            <i class="fa-solid fa-store me-1"></i>Có sẵn
                                                        </span>
                                                        <span class="badge" style="background-color: #f3e8ff; color: #7e22ce; border: 1px solid #e9d5ff; font-weight: 700; padding: 3px 8px; border-radius: 8px; font-size: 11px; width: fit-content;">
                                                            <i class="fa-solid fa-wand-magic-sparkles me-1"></i>Thiết kế
                                                        </span>
                                                    </div>
                                                </c:when>
                                                <c:when test="${o.cakeTypeLabel eq 'Thiết kế' || o.customCake}">
                                                    <span class="badge" style="background-color: #f3e8ff; color: #7e22ce; border: 1px solid #e9d5ff; font-weight: 700; padding: 4px 10px; border-radius: 8px; font-size: 11.5px;">
                                                        <i class="fa-solid fa-wand-magic-sparkles me-1"></i>Thiết kế
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge" style="background-color: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; font-weight: 700; padding: 4px 10px; border-radius: 8px; font-size: 11.5px;">
                                                        <i class="fa-solid fa-store me-1"></i>Có sẵn
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <c:if test="${userRole eq 'SHIPPER'}">
                                            <td style="text-align: right;" class="font-monospace admin-order-deposit">
                                                <fmt:formatNumber value="${o.depositAmount}" type="number" pattern="#,##0"/>đ
                                            </td>
                                        </c:if>
                                        <td style="text-align: right;" class="fw-bold font-monospace admin-order-total" title="Số tiền thu cuối (sau cọc/giảm giá)">
                                            <c:choose>
                                                <c:when test="${not empty o.remainingCodBalance}">
                                                    <fmt:formatNumber value="${o.remainingCodBalance}" type="number" pattern="#,##0"/>đ
                                                </c:when>
                                                <c:when test="${not empty o.totalCost}">
                                                    <fmt:formatNumber value="${o.totalCost}" type="number" pattern="#,##0"/>đ
                                                </c:when>
                                                <c:otherwise>0đ</c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td style="text-align: center;">
                                            <c:choose>
                                                <c:when test="${o.orderStatus eq 'Waiting_Payment' || o.orderStatus eq 'WAITING_PAYMENT'}">
                                                    <span class="status-badge status-pending" style="background-color: #fef08a; color: #854d0e;">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'PAID'}">
                                                    <span class="status-badge status-confirmed" style="background-color: #d1fae5; color: #065f46;">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Processing'}">
                                                    <span class="status-badge status-processing">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Waiting_Delivery'}">
                                                    <span class="status-badge status-pending" style="background-color: #fef08a; color: #854d0e;">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Delivering'}">
                                                    <span class="status-badge status-delivering">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Completed'}">
                                                    <span class="status-badge status-completed">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:when test="${o.orderStatus eq 'Cancelled'}">
                                                    <span class="status-badge status-cancelled">${o.orderStatusVietnamese}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-badge status-pending">${o.orderStatus}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: center;" onclick="event.stopPropagation();">
                                            <a href="${formAction}?action=detail&orderNo=${o.orderNo}" class="btn-action-detail" title="Chi tiết đơn hàng">
                                                Chi tiết <i class="fa-solid fa-angle-right"></i>
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="${userRole eq 'SHIPPER' ? '8' : '7'}" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open d-block fs-3 mb-3" style="color: #ccc;"></i>
                                        Không tìm thấy đơn hàng nào phù hợp với bộ lọc.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <div class="pagination-area">
                    <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang (${totalRecords} đơn hàng)</span>
                    <ul class="pagination-nav">
                        <c:if test="${currentPage > 1}">
                            <li class="page-num-item">
                                <a href="${formAction}?action=list&page=${currentPage - 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
                                    <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                <a href="${formAction}?action=list&page=${i}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">${i}</a>
                            </li>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <li class="page-num-item">
                                <a href="${formAction}?action=list&page=${currentPage + 1}&search=${search}&status=${status}&startDate=${startDate}&endDate=${endDate}&sort=${sort}">
                                    <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                </a>
                            </li>
                        </c:if>
                    </ul>
                </div>   
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const filterForm = document.querySelector('.filter-form');
            if (filterForm) {
                filterForm.addEventListener('submit', function(e) {
                    const startInput = filterForm.querySelector('input[name="startDate"]');
                    const endInput = filterForm.querySelector('input[name="endDate"]');
                    if (startInput && endInput) {
                        const startVal = startInput.value;
                        const endVal = endInput.value;
                        if (startVal && endVal) {
                            const start = new Date(startVal);
                            const end = new Date(endVal);
                            if (start > end) {
                                e.preventDefault();
                                alert("Ngày bắt đầu không được lớn hơn Ngày kết thúc!");
                                return false;
                            }
                        }
                    }
                });
            }
        });
    </script>
    <c:if test="${userRole eq 'SHIPPER'}">
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const activeSwitch = document.getElementById('shipper-active-switch');
                const zoneSelect = document.getElementById('shipper-zone-select');
                const statusLabel = document.getElementById('shipper-status-label');

                if (activeSwitch && zoneSelect && statusLabel) {
                    function updateShipperStatusZone() {
                        const isActive = activeSwitch.checked;
                        const workingZoneId = zoneSelect.value;
                        activeSwitch.disabled = true;
                        zoneSelect.disabled = true;

                        const payload = {
                            isActive: isActive,
                            workingZoneId: workingZoneId
                        };

                        fetch('${pageContext.request.contextPath}/api/v1/shipper/status-zone', {
                            method: 'PATCH',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify(payload)
                        })
                        .then(res => {
                            if (!res.ok) {
                                return res.json().then(err => { throw new Error(err.message || 'Server error'); });
                            }
                            return res.json();
                        })
                        .then(data => {
                            if (data.success) {
                                if (isActive) {
                                    statusLabel.innerText = 'Trực tuyến (Online)';
                                    statusLabel.style.color = '#166534';
                                    zoneSelect.disabled = false;
                                } else {
                                    statusLabel.innerText = 'Ngoại tuyến (Offline)';
                                    statusLabel.style.color = '#991b1b';
                                    zoneSelect.disabled = true;
                                }
                                alert("Cập nhật trạng thái hoạt động thành công!");
                                window.location.reload();
                            } else {
                                alert("Lỗi: " + data.message);
                                window.location.reload();
                            }
                        })
                        .catch(err => {
                            console.error("Error updating shipper status/zone:", err);
                            alert("Lỗi kết nối hoặc phân quyền: " + err.message);
                            window.location.reload();
                        })
                        .finally(() => {
                            activeSwitch.disabled = false;
                        });
                    }
                    activeSwitch.addEventListener('change', updateShipperStatusZone);
                    zoneSelect.addEventListener('change', updateShipperStatusZone);
                }
            });
        </script>
    </c:if>
</body>
</html>
    </c:otherwise>
</c:choose>
