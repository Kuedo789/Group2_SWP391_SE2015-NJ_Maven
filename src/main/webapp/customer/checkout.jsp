<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.bakeryzone.model.DeliveryAddress" %>
<%@ page import="com.bakeryzone.model.User" %>

<%
    List<DeliveryAddress> addressList = (List<DeliveryAddress>) request.getAttribute("addressList");
    User currentUser = (User) session.getAttribute("user");
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <style>
        :root {
            --primary-dark: #1b3322;
            --primary-light: #2d5037;
            --accent-gold: #c5a880;
            --text-dark: #111111;
            --text-muted: #666666;
            --border-color: #e2e2e2;
            --bg-light: #faf9f6;
            --radius-lg: 24px;
            --radius-md: 16px;
            --radius-sm: 8px;
            --font-body: "Be Vietnam Pro", Arial, sans-serif;
            --font-headings: "Playfair Display", serif;
        }

        body {
            font-family: var(--font-body);
            background-color: #fdfdfc;
            color: var(--text-dark);
            margin: 0;
            padding: 0;
        }

        h1, h2, h3, .card-title, .summary-header, .total-price {
            font-family: var(--font-headings);
        }

        .checkout-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 120px 24px 80px; /* Clear fixed navbar */
        }

        .checkout-title-section {
            margin-bottom: 32px;
        }

        .checkout-title-section h1 {
            font-size: 38px;
            font-weight: 800;
            color: var(--primary-dark);
            margin: 0 0 8px 0;
            letter-spacing: -0.5px;
        }

        .checkout-title-section p {
            color: var(--text-muted);
            margin: 0;
            font-size: 16px;
        }

        .checkout-layout {
            display: grid;
            grid-template-columns: 1.3fr 1fr;
            gap: 40px;
            align-items: start;
        }

        .checkout-left-col {
            display: flex;
            flex-direction: column;
            gap: 32px;
        }

        /* Card Section Styles */
        .checkout-card {
            background: white;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            padding: 32px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .card-title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 22px;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 0;
        }

        .card-title i {
            color: var(--accent-gold);
        }

        .btn-add-address {
            background-color: #f3f8f1;
            color: var(--primary-dark);
            text-decoration: none;
            font-weight: 700;
            font-size: 13px;
            padding: 8px 16px;
            border-radius: 999px;
            transition: all 0.2s ease;
            border: 1px solid rgba(63, 95, 54, 0.15);
        }

        .btn-add-address:hover {
            background-color: var(--primary-dark);
            color: white;
            box-shadow: 0 4px 10px rgba(63, 95, 54, 0.15);
        }

        /* Address List Styling */
        .address-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .address-card-option {
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 20px;
            display: flex;
            gap: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
            background-color: white;
        }

        .address-card-option:hover {
            border-color: var(--primary-light);
            background-color: #fafbf9;
        }

        .address-card-option.active {
            border-color: var(--primary-dark);
            border-width: 2px;
            padding: 19px; /* Adjust padding to offset border width */
            background-color: #f6f8f5;
        }

        .address-radio {
            margin-top: 4px;
            accent-color: var(--primary-dark);
            width: 18px;
            height: 18px;
        }

        .address-details {
            flex: 1;
        }

        .address-name-tag {
            font-weight: 700;
            font-size: 16px;
            color: var(--text-dark);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .default-badge {
            background-color: #e2ede5;
            color: var(--primary-dark);
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 4px;
            font-weight: 600;
        }

        .address-text {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.5;
            margin-bottom: 6px;
        }

        /* Time Slot Selector */
        .time-slots-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(135px, 1fr));
            gap: 12px;
            margin-bottom: 24px;
        }

        .time-slot-pill {
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            padding: 16px 6px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s ease;
            background-color: white;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .time-slot-pill:hover:not(.disabled) {
            border-color: var(--primary-light);
            background-color: #fbfbfa;
        }

        .time-slot-pill.active {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
            color: white;
        }

        .time-slot-pill.active .slot-status {
            color: #b0cbb6;
        }

        .time-slot-pill.disabled {
            background-color: #f5f5f5;
            color: #cccccc;
            cursor: not-allowed;
            border-color: #e0e0e0;
        }

        .slot-time {
            font-weight: 700;
            font-size: 13px;
        }

        .slot-status {
            font-size: 11px;
            font-weight: 500;
            color: var(--text-muted);
        }

        .time-slot-pill.disabled .slot-status {
            color: #cccccc;
        }

        /* Banners */
        .banner-info {
            background-color: #f6f8f5;
            border: 1px solid #e2ece5;
            border-radius: var(--radius-md);
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 14px;
            font-weight: 600;
            color: var(--primary-dark);
            transition: all 0.3s ease;
        }

        .banner-info i {
            font-size: 16px;
        }

        /* Products List Styling */
        .product-checkout-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .product-item-row {
            display: grid;
            grid-template-columns: 1fr auto;
            align-items: center;
            gap: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .product-item-row:last-child {
            padding-bottom: 0;
            border-bottom: none;
        }

        .product-item-left {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .product-img {
            width: 72px;
            height: 72px;
            border-radius: var(--radius-md);
            object-fit: cover;
            background-color: #f2f2f2;
        }

        .product-details-text {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .product-title {
            font-weight: 700;
            font-size: 16px;
            color: var(--text-dark);
        }

        .product-desc {
            font-size: 13px;
            color: var(--text-muted);
        }

        .product-item-right-actions {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .product-price {
            font-weight: 700;
            font-size: 16px;
            color: var(--text-dark);
            min-width: 90px;
            text-align: right;
        }

        .qty-adjust-box {
            display: flex;
            align-items: center;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-sm);
            background-color: #fdfdfd;
            height: 36px;
            overflow: hidden;
        }

        .btn-qty {
            border: none;
            background: none;
            width: 32px;
            height: 100%;
            cursor: pointer;
            font-weight: 700;
            font-size: 16px;
            color: var(--text-dark);
            transition: background 0.2s;
        }

        .btn-qty:hover {
            background-color: #f0f0f0;
        }

        .qty-display {
            padding: 0 10px;
            font-weight: 600;
            font-size: 14px;
            color: var(--text-dark);
            min-width: 20px;
            text-align: center;
        }

        .btn-delete-item {
            background: none;
            border: none;
            color: #d90429;
            cursor: pointer;
            font-size: 16px;
            padding: 8px;
            transition: color 0.2s;
        }

        .btn-delete-item:hover {
            color: #ef233c;
        }

        /* Right Summary Sidebar Styling */
        .summary-sidebar {
            background-color: var(--primary-dark);
            border-radius: var(--radius-lg);
            padding: 40px 32px;
            color: white;
            box-shadow: 0 10px 40px rgba(27, 51, 34, 0.15);
        }

        .summary-header {
            font-size: 24px;
            font-weight: 800;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            padding-bottom: 24px;
            margin-bottom: 24px;
            letter-spacing: -0.5px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            font-size: 15px;
            margin-bottom: 18px;
            color: rgba(255, 255, 255, 0.85);
        }

        .summary-row-label {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .summary-sub-label {
            font-size: 11px;
            color: rgba(255, 255, 255, 0.5);
        }

        .summary-row.total {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            padding-top: 24px;
            margin-top: 24px;
            margin-bottom: 28px;
            font-size: 18px;
            font-weight: 700;
            color: white;
            align-items: flex-end;
        }

        .total-price-wrap {
            text-align: right;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .total-price {
            font-size: 34px;
            font-weight: 800;
            line-height: 1;
        }

        .banner-kitchen-verify {
            background-color: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: var(--radius-md);
            padding: 16px;
            display: flex;
            gap: 12px;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.8);
            line-height: 1.4;
            margin-bottom: 32px;
        }

        .banner-kitchen-verify i {
            color: var(--accent-gold);
            font-size: 16px;
            margin-top: 2px;
        }

        .btn-place-order {
            background: linear-gradient(135deg, var(--accent-gold, #c5a880) 0%, #d4bc9c 100%);
            color: var(--primary-dark);
            border: none;
            border-radius: var(--radius-md);
            width: 100%;
            padding: 18px;
            font-weight: 800;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
            transition: all 0.25s ease;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        .btn-place-order:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(197, 168, 128, 0.4);
            filter: brightness(1.05);
        }

        .btn-place-order:disabled {
            background-color: rgba(255, 255, 255, 0.3);
            color: rgba(255, 255, 255, 0.6);
            cursor: not-allowed;
            box-shadow: none;
        }

        .terms-text {
            text-align: center;
            font-size: 11px;
            color: rgba(255, 255, 255, 0.4);
            margin-top: 16px;
            line-height: 1.4;
        }

        /* Trust Badges below summary */
        .trust-badges {
            display: flex;
            justify-content: space-around;
            margin-top: 24px;
            font-size: 11px;
            font-weight: 700;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .trust-badge-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }

        .trust-badge-item i {
            font-size: 18px;
            color: var(--primary-light);
        }

        /* Empty state styling */
        .empty-address-msg, .empty-cart-state {
            text-align: center;
            padding: 40px 16px;
            color: var(--text-muted);
            border: 1px dashed var(--border-color);
            border-radius: var(--radius-md);
        }

        .empty-address-msg i, .empty-cart-state i {
            font-size: 40px;
            color: #ddd;
            margin-bottom: 16px;
        }

        @media (max-width: 992px) {
            .checkout-layout {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

    <!-- Navbar -->
    <jsp:include page="../common/navbar.jsp" />

    <main class="checkout-container">

        <div class="checkout-title-section">
            <h1>Hoàn tất đặt hàng</h1>
            <p>Vui lòng kiểm tra lại thông tin và sản phẩm trước khi thanh toán.</p>
        </div>

        <form id="checkoutForm" action="${pageContext.request.contextPath}/checkout" method="POST">
            <input type="hidden" name="cartData" id="cartDataInput">
            <input type="hidden" name="addressId" id="selectedAddressIdInput">
            <input type="hidden" name="timeSlot" id="selectedTimeSlotInput">

            <div class="checkout-layout">

                <!-- Left Column -->
                <div class="checkout-left-col">

                    <!-- Delivery Address Card -->
                    <div class="checkout-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fa fa-map-marker-alt"></i> Địa chỉ giao hàng
                            </h2>
                            <a href="${pageContext.request.contextPath}/delivery-address?source=checkout" class="btn-add-address" style="text-decoration: none; font-size: 14px; font-weight: 700; color: var(--primary-dark); display: flex; align-items: center; gap: 6px;">
                                <i class="fa fa-edit"></i> Thay đổi
                            </a>
                        </div>

                        <!-- Display currently selected address directly -->
                        <div id="selectedAddressWrapper" style="margin-bottom: 0;">
                            <% 
                                if (addressList == null || addressList.isEmpty()) {
                            %>
                                <div class="empty-address-msg" style="text-align: center; padding: 30px 16px; border: 1px dashed var(--border-color); border-radius: var(--radius-md);">
                                    <i class="fa fa-map-marked-alt" style="font-size: 40px; color: #ddd; margin-bottom: 16px;"></i>
                                    <p style="color: var(--text-muted); margin-bottom: 16px;">Bạn chưa lưu địa chỉ giao hàng nào.</p>
                                    <a href="${pageContext.request.contextPath}/delivery-address?action=add&source=checkout" style="display: inline-flex; align-items: center; justify-content: center; border-radius: 999px; height: 44px; padding: 0 24px; font-weight: 700; font-size: 14px; background: var(--primary-dark); color: white; text-decoration: none;">Thêm địa chỉ giao hàng</a>
                                </div>
                            <% 
                                } else {
                                    String selectedParam = request.getParameter("selectedAddressId");
                                    DeliveryAddress selectedAddr = addressList.get(0);
                                    
                                    boolean foundParam = false;
                                    if (selectedParam != null && !selectedParam.isEmpty()) {
                                        for (DeliveryAddress addr : addressList) {
                                            if (String.valueOf(addr.getAddressId()).equals(selectedParam)) {
                                                selectedAddr = addr;
                                                foundParam = true;
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!foundParam) {
                                        for (DeliveryAddress addr : addressList) {
                                            if (addr.isDefault()) {
                                                selectedAddr = addr;
                                                break;
                                            }
                                        }
                                    }
                            %>
                                <div class="address-card-option active" 
                                     id="finalSelectedAddressCard"
                                     data-address-id="<%= selectedAddr.getAddressId() %>"
                                     data-lat="<%= selectedAddr.getLatitude() %>"
                                     data-lng="<%= selectedAddr.getLongitude() %>"
                                     style="border: 2px solid var(--primary-dark); background-color: #f6f8f5; padding: 16px; border-radius: var(--radius-md); margin-bottom: 0; display: block; cursor: default;">
                                    
                                    <div class="address-details" style="display: flex; flex-direction: column; gap: 4px;">
                                        <div class="address-name-tag" style="font-weight: 700; font-size: 16px; color: var(--text-dark); display: flex; align-items: center; gap: 8px;">
                                            <%= selectedAddr.getReceiverName() %>
                                            <% if (selectedAddr.isDefault()) { %>
                                                <span class="default-badge" style="font-size: 11px; font-weight: 600; color: var(--primary-dark); background-color: #e2ece5; padding: 2px 8px; border-radius: 4px;">Mặc định</span>
                                            <% } %>
                                        </div>
                                        <div class="address-text" style="font-size: 14px; color: var(--text-muted); line-height: 1.5; margin-bottom: 6px;">
                                            <%= selectedAddr.getAddressDetail() %>
                                        </div>
                                        <div class="address-text" style="font-weight: 600; font-size: 14px; color: var(--text-muted);">
                                            SĐT: <%= selectedAddr.getReceiverPhone() %>
                                        </div>
                                    </div>
                                </div>
                            <% 
                                }
                            %>
                        </div>
                    </div>

                    <!-- Delivery Time Slots Card -->
                    <div class="checkout-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fa fa-clock"></i> Thời gian giao hàng
                            </h2>
                        </div>

                        <!-- Date selection -->
                        <div style="margin-bottom: 24px; display: flex; flex-direction: column; gap: 8px;">
                            <label for="deliveryDate" style="font-weight: 700; font-size: 14px; color: var(--text-dark);">Chọn ngày giao hàng: <span style="color:#d62828;">*</span></label>
                            <input type="date" id="deliveryDate" name="deliveryDate" style="width: 100%; height: 48px; padding: 0 16px; border: 1px solid var(--border-color); border-radius: var(--radius-md); font-family: var(--font-body); font-size: 15px; outline: none; box-sizing: border-box;" required>
                        </div>

                        <div style="font-weight: 700; font-size: 14px; color: var(--text-dark); margin-bottom: 12px;">Chọn khung giờ: <span style="color:#d62828;">*</span></div>

                        <div class="time-slots-grid">
                            <div class="time-slot-pill" data-slot="08:00 - 09:00" onclick="selectTimeSlot('08:00 - 09:00', this)">
                                <span class="slot-time">08:00 - 09:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill active" data-slot="09:00 - 10:00" onclick="selectTimeSlot('09:00 - 10:00', this)">
                                <span class="slot-time">09:00 - 10:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="10:00 - 11:00" onclick="selectTimeSlot('10:00 - 11:00', this)">
                                <span class="slot-time">10:00 - 11:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="11:00 - 12:00" onclick="selectTimeSlot('11:00 - 12:00', this)">
                                <span class="slot-time">11:00 - 12:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="12:00 - 13:00" onclick="selectTimeSlot('12:00 - 13:00', this)">
                                <span class="slot-time">12:00 - 13:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="13:00 - 14:00" onclick="selectTimeSlot('13:00 - 14:00', this)">
                                <span class="slot-time">13:00 - 14:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="14:00 - 15:00" onclick="selectTimeSlot('14:00 - 15:00', this)">
                                <span class="slot-time">14:00 - 15:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="15:00 - 16:00" onclick="selectTimeSlot('15:00 - 16:00', this)">
                                <span class="slot-time">15:00 - 16:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="16:00 - 17:00" onclick="selectTimeSlot('16:00 - 17:00', this)">
                                <span class="slot-time">16:00 - 17:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                            <div class="time-slot-pill" data-slot="17:00 - 18:00" onclick="selectTimeSlot('17:00 - 18:00', this)">
                                <span class="slot-time">17:00 - 18:00</span>
                                <span class="slot-status">Còn chỗ</span>
                            </div>
                        </div>

                        <div class="banner-info" id="slotConfirmationBanner">
                            <i class="fa fa-check-circle"></i> 
                            <span>Đã xác nhận năng lực sản xuất & giao hàng cho khung giờ 09:00 - 10:00</span>
                        </div>
                    </div>

                    <!-- Products in Cart Card -->
                    <div class="checkout-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fa fa-shopping-bag"></i> Sản phẩm trong giỏ
                            </h2>
                        </div>

                        <div class="product-checkout-list" id="checkoutProductList">
                            <!-- Populated by JavaScript -->
                        </div>
                    </div>

                </div>

                <!-- Right Column Summary -->
                <div>
                    <div class="summary-sidebar">
                        <div class="summary-header">Tổng cộng thanh toán</div>
                        
                        <div class="summary-row">
                            <span>Tổng tiền sản phẩm</span>
                            <span id="productTotalSum">0đ</span>
                        </div>

                        <div class="summary-row">
                            <div class="summary-row-label">
                                <span>Phí giao hàng</span>
                                <span class="summary-sub-label">Tính dựa trên tọa độ khoảng cách (5.000đ/km)</span>
                            </div>
                            <span id="shippingFeeSum">0đ</span>
                        </div>

                        <div class="summary-row total">
                            <span>Tổng cộng</span>
                            <div class="total-price-wrap">
                                <span class="total-price" id="finalTotalSum">0đ</span>
                            </div>
                        </div>

                        <div class="banner-kitchen-verify">
                            <i class="fa fa-utensils"></i>
                            <span>Bếp đã xác nhận đủ năng lực sản xuất cho các sản phẩm và khung giờ được chọn.</span>
                        </div>

                        <button type="submit" class="btn-place-order" id="btnPlaceOrder">
                            Đặt hàng ngay <i class="fa fa-arrow-right"></i>
                        </button>

                        <div class="terms-text">
                            Bằng việc đặt hàng, bạn đồng ý với Điều khoản sử dụng của BakeryZone.
                        </div>
                    </div>

                    <!-- Trust Indicators -->
                    <div class="trust-badges">
                        <div class="trust-badge-item">
                            <i class="fa fa-shield-alt"></i>
                            <span>Bảo mật</span>
                        </div>
                        <div class="trust-badge-item">
                            <i class="fa fa-seedling"></i>
                            <span>Hữu cơ</span>
                        </div>
                        <div class="trust-badge-item">
                            <i class="fa fa-shipping-fast"></i>
                            <span>Giao nhanh</span>
                        </div>
                    </div>
                </div>

            </div>
        </form>

    </main>

    <!-- Footer & Scripts -->
    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

    <script>
        // Store coordinates (will shift dynamically based on customer's city)
        let shopLat = 10.7769; // HCMC D1/Thao Dien default
        let shopLng = 106.7009;

        // (no mock cart - always use real localStorage data)

        let currentCart = [];
        let selectedAddressId = null;
        let selectedTimeSlot = "09:00 - 10:00"; // default selected
        let currentShippingFee = 0;

        document.addEventListener("DOMContentLoaded", function () {
            // Dọn dẹp dữ liệu mock cũ nếu tồn tại trong localStorage
            try {
                const rawCart = localStorage.getItem("cart");
                if (rawCart) {
                    const parsed = JSON.parse(rawCart);
                    if (Array.isArray(parsed)) {
                        // Lọc bỏ các item có id bắt đầu bằng "MOCK-"
                        const cleanCart = parsed.filter(item => item && item.id && !String(item.id).startsWith("MOCK-"));
                        localStorage.setItem("cart", JSON.stringify(cleanCart));
                    }
                }
            } catch(e) {
                // Nếu lỗi parse, xóa hẳn
                localStorage.removeItem("cart");
            }

            // 1. Sync & Render Cart Items
            loadCartItems();

            // 2. Select initial active address and calculate shipping fee
            const activeAddressCard = document.querySelector(".address-card-option.active");
            if (activeAddressCard) {
                const id = activeAddressCard.getAttribute("data-address-id");
                const lat = parseFloat(activeAddressCard.getAttribute("data-lat"));
                const lng = parseFloat(activeAddressCard.getAttribute("data-lng"));
                selectAddress(id, lat, lng, activeAddressCard);
            } else {
                // If no active address but list exists, select first
                const firstAddressCard = document.querySelector(".address-card-option");
                if (firstAddressCard) {
                    const id = firstAddressCard.getAttribute("data-address-id");
                    const lat = parseFloat(firstAddressCard.getAttribute("data-lat"));
                    const lng = parseFloat(firstAddressCard.getAttribute("data-lng"));
                    selectAddress(id, lat, lng, firstAddressCard);
                } else {
                    // No addresses saved, use default demo fee
                    currentShippingFee = 25000;
                    updateSummary();
                }
            }

            // Set initial time slot input
            document.getElementById("selectedTimeSlotInput").value = selectedTimeSlot;

            // Set delivery date picker constraints and default value
            const today = new Date();
            const yyyy = today.getFullYear();
            let mm = today.getMonth() + 1;
            let dd = today.getDate();
            if (dd < 10) dd = '0' + dd;
            if (mm < 10) mm = '0' + mm;
            const minDateStr = yyyy + '-' + mm + '-' + dd;
            
            const deliveryDateInput = document.getElementById("deliveryDate");
            if (deliveryDateInput) {
                deliveryDateInput.min = minDateStr;
                // Default to tomorrow
                const tomorrow = new Date();
                tomorrow.setDate(tomorrow.getDate() + 1);
                const tyyyy = tomorrow.getFullYear();
                let tmm = tomorrow.getMonth() + 1;
                let tdd = tomorrow.getDate();
                if (tdd < 10) tdd = '0' + tdd;
                if (tmm < 10) tmm = '0' + tmm;
                deliveryDateInput.value = tyyyy + '-' + tmm + '-' + tdd;
            }

            // We render the address directly via JSP now, no need to sync display via JS
            // Clear cart upon successful order placement
            document.getElementById("checkoutForm").addEventListener("submit", function() {
                localStorage.removeItem("cart");
            });
        });

        // toggleAddressList function removed as there is no list to toggle

        function loadCartItems() {
            let localCartStr = localStorage.getItem("cart");
            let localCart = null;
            try {
                if (localCartStr) {
                    localCart = JSON.parse(localCartStr);
                }
            } catch(e) {
                console.error("Failed to parse cart localstorage", e);
                localCart = null;
            }

            // Chỉ dùng dữ liệu thực từ localStorage, không fallback mock
            if (Array.isArray(localCart)) {
                currentCart = localCart.filter(item => item && item.id && item.name && item.price != null);
            } else {
                currentCart = [];
            }

            document.getElementById("cartDataInput").value = JSON.stringify(currentCart);
            renderCartList();
        }

        function renderCartList() {
            const listContainer = document.getElementById("checkoutProductList");
            const btnPlaceOrder = document.getElementById("btnPlaceOrder");

            if (!Array.isArray(currentCart) || currentCart.length === 0) {
                listContainer.innerHTML = `
                    <div class="empty-cart-state">
                        <i class="fa fa-shopping-basket"></i>
                        <p>Giỏ hàng của bạn đang trống.</p>
                        <a href="<%= request.getContextPath() %>/products" class="btn btn-primary" style="margin-top:10px; display:inline-block; padding:8px 16px; background:var(--primary-dark); color:white; border-radius:8px; text-decoration:none;">Xem thực đơn</a>
                    </div>
                `;
                if (btnPlaceOrder) btnPlaceOrder.disabled = true;
                updateSummary();
                return;
            }

            if (btnPlaceOrder) btnPlaceOrder.disabled = false;
            listContainer.innerHTML = "";

            currentCart.forEach(item => {
                if (!item) return;
                const imgUrl = (item.image && typeof item.image === "string" && item.image.startsWith("http")) ? item.image : "<%= request.getContextPath() %>/" + (item.image || "assets/images/products/basic.png");
                const priceFormatted = (parseFloat(item.price) || 0).toLocaleString("vi-VN") + "đ";
                
                const itemHtml = `
                    <div class="product-item-row" id="cart-item-${item.id}">
                        <div class="product-item-left">
                            <img src="${imgUrl}" class="product-img" alt="${item.name || ''}" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=120'">
                            <div class="product-details-text">
                                <span class="product-title">${item.name || ''}</span>
                                <span class="product-desc">${item.desc || 'Bánh ngọt thủ công cao cấp'}</span>
                            </div>
                        </div>
                        <div class="product-item-right-actions">
                            <span class="product-price">${priceFormatted}</span>
                            <div class="qty-adjust-box">
                                <button type="button" class="btn-qty" onclick="adjustItemQty('${item.id}', -1)">−</button>
                                <span class="qty-display">${parseInt(item.qty) || 1}</span>
                                <button type="button" class="btn-qty" onclick="adjustItemQty('${item.id}', 1)">+</button>
                            </div>
                            <button type="button" class="btn-delete-item" onclick="deleteItem('${item.id}')" title="Xóa sản phẩm">
                                <i class="fa fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                listContainer.innerHTML += itemHtml;
            });

            updateSummary();
        }

        function adjustItemQty(itemId, change) {
            const item = currentCart.find(x => x && x.id == itemId);
            if (!item) return;

            item.qty = (parseInt(item.qty) || 1) + change;
            if (item.qty <= 0) {
                deleteItem(itemId);
                return;
            }

            localStorage.setItem("cart", JSON.stringify(currentCart));
            document.getElementById("cartDataInput").value = JSON.stringify(currentCart);
            
            // Sync navbar badge
            window.dispatchEvent(new Event("storage"));
            const countEl = document.getElementById("navCartCount");
            if (countEl) {
                let totalQty = 0;
                currentCart.forEach(c => { if (c) totalQty += (parseInt(c.qty) || 1); });
                countEl.innerText = totalQty;
            }

            renderCartList();
        }

        function deleteItem(itemId) {
            currentCart = currentCart.filter(x => x && x.id != itemId);
            localStorage.setItem("cart", JSON.stringify(currentCart));
            document.getElementById("cartDataInput").value = JSON.stringify(currentCart);

            // Sync navbar badge
            window.dispatchEvent(new Event("storage"));
            const countEl = document.getElementById("navCartCount");
            if (countEl) {
                let totalQty = 0;
                currentCart.forEach(c => { if (c) totalQty += (parseInt(c.qty) || 1); });
                countEl.innerText = totalQty;
            }

            renderCartList();
        }

        function selectAddress(id, lat, lng, element) {
            selectedAddressId = id;
            document.getElementById("selectedAddressIdInput").value = id;

            document.querySelectorAll("#addressListContainer .address-card-option").forEach(card => {
                card.classList.remove("active");
                const radio = card.querySelector(".address-radio");
                if (radio) radio.checked = false;
            });

            element.classList.add("active");
            const radio = element.querySelector(".address-radio");
            if (radio) radio.checked = true;

            // Shift shop location to match customer city (Hanoi vs HCMC)
            if (lat > 16.0) {
                shopLat = 21.0278; // Hanoi
                shopLng = 105.8342;
            } else {
                shopLat = 10.7769; // HCMC Thao Dien
                shopLng = 106.7009;
            }

            const distance = getHaversineDistance(shopLat, shopLng, lat, lng) * 1.25;
            const finalDistance = Math.max(1.0, distance);

            currentShippingFee = Math.max(15000, Math.round(finalDistance) * 5000);
            updateSummary();
        }

        function selectTimeSlot(slot, element) {
            if (element.classList.contains("disabled")) return;

            selectedTimeSlot = slot;
            document.getElementById("selectedTimeSlotInput").value = slot;

            document.querySelectorAll(".time-slot-pill").forEach(pill => {
                pill.classList.remove("active");
            });

            element.classList.add("active");

            const banner = document.getElementById("slotConfirmationBanner");
            banner.style.display = "flex";
            banner.innerHTML = `<i class="fa fa-check-circle"></i> <span>Đã xác nhận năng lực sản xuất & giao hàng cho khung giờ ${slot}</span>`;
            
            document.getElementById("btnPlaceOrder").disabled = false;
        }

        function getHaversineDistance(lat1, lon1, lat2, lon2) {
            const R = 6371; // Earth radius in km
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLon = (lon2 - lon1) * Math.PI / 180;
            const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                      Math.sin(dLon/2) * Math.sin(dLon/2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
            return R * c;
        }

        function updateSummary() {
            let productTotal = 0;
            if (Array.isArray(currentCart)) {
                currentCart.forEach(item => {
                    if (item) {
                        const price = parseFloat(item.price) || 0;
                        const qty = parseInt(item.qty) || 1;
                        productTotal += price * qty;
                    }
                });
            }

            const finalTotal = productTotal > 0 ? (productTotal + currentShippingFee) : 0;

            document.getElementById("productTotalSum").innerText = productTotal.toLocaleString("vi-VN") + "đ";
            document.getElementById("shippingFeeSum").innerText = currentShippingFee.toLocaleString("vi-VN") + "đ";
            document.getElementById("finalTotalSum").innerText = finalTotal.toLocaleString("vi-VN") + "đ";
        }
    </script>
</body>
</html>
