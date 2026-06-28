<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
        <% } %>

        <%-- Error banner if date filtering is invalid --%>
        <c:if test="${not empty errorMessage}">
            <div id="orderErrorBanner" style="
                background: #f8d7da;
                color: #842029;
                border: 1px solid #f5c2c7;
                border-radius: 16px;
                padding: 16px 24px;
                margin: 0 0 28px 0;
                display: flex;
                align-items: center;
                gap: 16px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.02);
                animation: slideDown 0.4s ease;">
                <span class="material-symbols-outlined" style="font-size: 28px; color: #842029; flex-shrink: 0;">error</span>
                <div style="font-weight: 600; font-size: 14px;">
                    <c:out value="${errorMessage}" />
                </div>
                <button onclick="document.getElementById('orderErrorBanner').style.display='none'"
                        style="margin-left:auto; background:none; border:none; color:#842029; font-size:22px; cursor:pointer; line-height:1;">&times;</button>
            </div>
            <c:remove var="errorMessage" scope="session" />
        </c:if>

        <!-- Filters Section -->
        <section class="orders-filter" style="display: flex; gap: 12px; justify-content: flex-start; margin-bottom: 25px; flex-wrap: wrap;">
            <a href="<%= request.getContextPath() %>/OrderList?status=all<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "all".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Tất cả (<%= request.getAttribute("countAll") != null ? request.getAttribute("countAll") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=processing<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "processing".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đang xử lý (<%= request.getAttribute("countProcessing") != null ? request.getAttribute("countProcessing") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=shipping<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "shipping".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đang giao (<%= request.getAttribute("countShipping") != null ? request.getAttribute("countShipping") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=completed<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "completed".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hoàn thành (<%= request.getAttribute("countCompleted") != null ? request.getAttribute("countCompleted") : 0 %>)</a>
            <a href="<%= request.getContextPath() %>/OrderList?status=cancelled<%= dateParams %><%= searchParams %><%= sortParams %>" class="filter-btn <%= "cancelled".equals(currentStatus) ? "active" : "" %>" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Đã hủy (<%= request.getAttribute("countCancelled") != null ? request.getAttribute("countCancelled") : 0 %>)</a>
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
                    <div class="order-total">
                        <span>Tổng thanh toán:</span>
                        <strong><%= formattedTotal %></strong>
                    </div>
                    <div class="order-actions">
                        <button class="btn btn-outline" style="min-width: 44px; padding: 0 12px; display: inline-flex; align-items: center; justify-content: center;" onclick="alert('Đã thêm tất cả sản phẩm trong đơn vào giỏ hàng của bạn!');" title="Thêm vào giỏ hàng">
                            <span class="material-symbols-outlined" style="font-size: 20px;">add_shopping_cart</span>
                        </button>
                        
                        <% if ("completed".equals(dataStatus)) { %>
                            <button class="btn btn-outline" onclick="alert('Đã thêm tất cả sản phẩm trong đơn vào giỏ hàng của bạn!');">Đặt lại</button>
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
    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

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
    </script>
</body>
</html>