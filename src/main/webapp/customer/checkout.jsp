<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/checkout.css">
    <style>
        .pm-card {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 16px;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            cursor: pointer;
            background: #fff;
            transition: all 0.2s ease;
            margin-bottom: 12px;
        }
        .pm-card:last-child {
            margin-bottom: 0;
        }
        .pm-card.active {
            border: 2px solid var(--primary-dark);
            background: #f6f8f5;
            padding: 15px;
        }
        .pm-card input[type="radio"] {
            display: none;
        }
        .pm-radio-circle {
            width: 18px;
            height: 18px;
            border: 1px solid #999;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .pm-card.active .pm-radio-circle {
            border: 5px solid var(--primary-dark);
            background: #fff;
        }
        .pm-icon {
            font-size: 18px;
            color: var(--text-dark);
        }
        .pm-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-dark);
            display: block;
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

        <div id="jsErrorBox" class="alert alert-danger" style="display: none; color: #842029; background-color: #f8d7da; border-color: #f5c2c7; padding: 1rem 1rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; max-width: 1200px; margin-left: auto; margin-right: auto;"></div>

        <c:if test="${param.error == 'empty_cart'}">
            <div class="alert alert-danger" style="color: #842029; background-color: #f8d7da; border-color: #f5c2c7; padding: 1rem 1rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; max-width: 1200px; margin-left: auto; margin-right: auto;">
                Không có sản phẩm trong giỏ hàng. Không thể đặt bánh!
            </div>
        </c:if>
        <c:if test="${param.error == 'empty_address'}">
            <div class="alert alert-danger" style="color: #842029; background-color: #f8d7da; border-color: #f5c2c7; padding: 1rem 1rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; max-width: 1200px; margin-left: auto; margin-right: auto;">
                Vui lòng thêm địa chỉ giao hàng trước khi đặt hàng.
            </div>
        </c:if>
        <c:if test="${param.error == 'server_error' || param.error == 'save_failed'}">
            <div class="alert alert-danger" style="color: #842029; background-color: #f8d7da; border-color: #f5c2c7; padding: 1rem 1rem; margin-bottom: 1rem; border: 1px solid transparent; border-radius: .25rem; max-width: 1200px; margin-left: auto; margin-right: auto;">
                Đã có lỗi xảy ra trong quá trình đặt hàng. Vui lòng thử lại sau.
            </div>
        </c:if>

        <form id="checkoutForm" action="${pageContext.request.contextPath}/checkout" method="POST">
            <input type="hidden" name="cartData" id="cartDataInput">
            <input type="hidden" name="addressId" id="selectedAddressIdInput" value="${requestScope.selectedAddress.addressId}">
            <input type="hidden" name="timeSlot" id="selectedTimeSlotInput">
            <input type="hidden" name="shippingFee" id="shippingFeeInput" value="0">

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
                            <c:choose>
                                <c:when test="${empty requestScope.addressList}">
                                    <div class="empty-address-msg" style="text-align: center; padding: 30px 16px; border: 1px dashed var(--border-color); border-radius: var(--radius-md);">
                                        <i class="fa fa-map-marked-alt" style="font-size: 40px; color: #ddd; margin-bottom: 16px;"></i>
                                        <p style="color: var(--text-muted); margin-bottom: 16px;">Bạn chưa lưu địa chỉ giao hàng nào.</p>
                                        <a href="${pageContext.request.contextPath}/delivery-address?action=add&source=checkout" style="display: inline-flex; align-items: center; justify-content: center; border-radius: 999px; height: 44px; padding: 0 24px; font-weight: 700; font-size: 14px; background: var(--primary-dark); color: white; text-decoration: none;">Thêm địa chỉ giao hàng</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="address-card-option active" 
                                         id="finalSelectedAddressCard"
                                         data-address-id="${requestScope.selectedAddress.addressId}"
                                         data-lat="${requestScope.selectedAddress.latitude}"
                                         data-lng="${requestScope.selectedAddress.longitude}"
                                         style="border: 2px solid var(--primary-dark); background-color: #f6f8f5; padding: 16px; border-radius: var(--radius-md); margin-bottom: 0; display: block; cursor: default;">
                                        
                                        <div class="address-details" style="display: flex; flex-direction: column; gap: 4px;">
                                            <div class="address-name-tag" style="font-weight: 700; font-size: 16px; color: var(--text-dark); display: flex; align-items: center; gap: 8px;">
                                                ${requestScope.selectedAddress.receiverName}
                                                <c:if test="${requestScope.selectedAddress.isDefault()}">
                                                    <span class="default-badge" style="font-size: 11px; font-weight: 600; color: var(--primary-dark); background-color: #e2ece5; padding: 2px 8px; border-radius: 4px;">Mặc định</span>
                                                </c:if>
                                            </div>
                                            <div class="address-text" style="font-size: 14px; color: var(--text-muted); line-height: 1.5; margin-bottom: 6px;">
                                                ${requestScope.selectedAddress.addressDetail}
                                            </div>
                                            <div class="address-text" style="font-weight: 600; font-size: 14px; color: var(--text-muted);">
                                                SĐT: ${requestScope.selectedAddress.receiverPhone}
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
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

                        <div class="time-slots-grid" id="timeSlotsGrid">
                            <!-- Populated by JavaScript based on deliveryDate -->
                        </div>

                        <div class="banner-info" id="slotConfirmationBanner" style="display: none;">
                            <i class="fa fa-check-circle"></i> 
                            <span>Vui lòng chọn khung giờ giao hàng</span>
                        </div>
                    </div>

                    <!-- Products in Cart Card -->
                    <div class="checkout-card">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title" style="margin: 0;">
                                <i class="fa fa-shopping-bag"></i> Sản phẩm trong giỏ
                            </h2>
                            <a href="${pageContext.request.contextPath}/products" style="text-decoration: none; font-size: 14px; font-weight: 700; color: var(--primary-dark); display: flex; align-items: center; gap: 6px;">
                                <i class="fa fa-plus"></i> Thêm sản phẩm
                            </a>
                        </div>

                        <div class="product-checkout-list" id="checkoutProductList">
                            <!-- Populated by JavaScript -->
                        </div>
                    </div>

                    <!-- Note Card -->
                    <div class="checkout-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fa fa-sticky-note"></i> Ghi chú đơn hàng
                            </h2>
                        </div>
                        <div style="margin-top: 16px;">
                            <textarea name="note" id="note" rows="3" placeholder="Ví dụ: Giao hàng giờ hành chính, gọi điện trước khi giao..." style="width: 100%; padding: 12px 16px; border: 1px solid var(--border-color); border-radius: var(--radius-md); font-family: var(--font-body); font-size: 15px; outline: none; box-sizing: border-box; resize: vertical;"></textarea>
                        </div>
                    </div>

                    <!-- Payment Methods Card -->
                    <div class="checkout-card">
                        <div class="card-header">
                            <h2 class="card-title">
                                <i class="fa fa-credit-card"></i> Phương thức thanh toán
                            </h2>
                        </div>
                        <div class="payment-methods-wrapper" style="margin-top: 16px;">
                            <label class="pm-card active" onclick="document.querySelectorAll('.pm-card').forEach(c => c.classList.remove('active')); this.classList.add('active');">
                                <input type="radio" name="paymentMethod" value="COD" checked>
                                <div class="pm-radio-circle"></div>
                                <i class="fa fa-truck pm-icon"></i>
                                <span class="pm-title">Thanh toán khi nhận hàng</span>
                            </label>
                            
                            <label class="pm-card" onclick="document.querySelectorAll('.pm-card').forEach(c => c.classList.remove('active')); this.classList.add('active');">
                                <input type="radio" name="paymentMethod" value="BANK_TRANSFER_FULL">
                                <div class="pm-radio-circle"></div>
                                <i class="fa fa-university pm-icon"></i>
                                <span class="pm-title">Chuyển khoản</span>
                            </label>
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
                                <span class="summary-sub-label">Tính dựa trên tọa độ khoảng cách (<fmt:formatNumber value="${not empty settings.shippingRate ? settings.shippingRate : 5000}" pattern="#,##0"/>đ/km)</span>
                            </div>
                            <span id="shippingFeeSum">0đ</span>
                        </div>

                        <c:if test="${requestScope.checkoutDiscount > 0}">
                            <div class="summary-row" style="color: #d9534f;">
                                <div class="summary-row-label">
                                    <span>Giảm giá Voucher</span>
                                    <span class="summary-sub-label">${requestScope.checkoutVoucherCode}</span>
                                </div>
                                <span>- <fmt:formatNumber value="${requestScope.checkoutDiscount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                            </div>
                        </c:if>

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
        let selectedTimeSlot = ""; // no default selected
        let currentShippingFee = 0;
        const checkoutDiscount = parseFloat("${requestScope.checkoutDiscount}") || 0;

        document.addEventListener("DOMContentLoaded", function () {


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
                    // No addresses saved, use 0 fee
                    currentShippingFee = 0;
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
                // Không đặt ngày mặc định để bắt người dùng chọn
                deliveryDateInput.value = "";
                
                deliveryDateInput.addEventListener("change", updateAvailableTimeSlots);
            }

            // We render the address directly via JSP now, no need to sync display via JS
            document.getElementById("checkoutForm").addEventListener("submit", function(e) {
                const jsErrorBox = document.getElementById("jsErrorBox");
                
                if (!Array.isArray(currentCart) || currentCart.length === 0) {
                    e.preventDefault();
                    jsErrorBox.innerText = "Không có sản phẩm trong giỏ hàng. Không thể đặt bánh!";
                    jsErrorBox.style.display = "block";
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                    return;
                }

                const selectedAddressId = document.getElementById("selectedAddressIdInput").value;
                if (!selectedAddressId || selectedAddressId.trim() === "") {
                    e.preventDefault();
                    jsErrorBox.innerText = "Vui lòng thêm địa chỉ giao hàng trước khi đặt hàng.";
                    jsErrorBox.style.display = "block";
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                    return;
                }
                const timeSlot = document.getElementById("selectedTimeSlotInput").value;
                if (!timeSlot || timeSlot.trim() === "") {
                    e.preventDefault();
                    jsErrorBox.innerText = "Vui lòng chọn khung giờ giao hàng hợp lệ.";
                    jsErrorBox.style.display = "block";
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                    return;
                }
                
                jsErrorBox.style.display = "none";
                localStorage.removeItem("cart");
            });

            // Initialize available time slots on load
            updateAvailableTimeSlots();
        });

        function updateAvailableTimeSlots() {
            const dateVal = document.getElementById("deliveryDate").value;
            const btn = document.getElementById("btnPlaceOrder");
            const banner = document.getElementById("slotConfirmationBanner");
            const inputField = document.getElementById("selectedTimeSlotInput");
            const grid = document.getElementById("timeSlotsGrid");

            const standardSlots = [
                "08:00 - 09:00", "09:00 - 10:00", "10:00 - 11:00", "11:00 - 12:00",
                "12:00 - 13:00", "13:00 - 14:00", "14:00 - 15:00", "15:00 - 16:00",
                "16:00 - 17:00", "17:00 - 18:00", "18:00 - 19:00", "19:00 - 20:00",
                "20:00 - 21:00", "21:00 - 22:00"
            ];
            
            grid.innerHTML = ""; // Clear existing

            if (!dateVal) {
                standardSlots.forEach(slot => {
                    grid.innerHTML += `<div class="time-slot-pill disabled"><span class="slot-time">\${slot}</span><span class="slot-status">Vui lòng chọn ngày</span></div>`;
                });
                
                if (btn) btn.disabled = true;
                if (banner) banner.style.display = "none";
                if (inputField) inputField.value = "";
                selectedTimeSlot = "";
                return;
            }
            
            const dateParts = dateVal.split('-');
            const selectedDate = new Date(parseInt(dateParts[0], 10), parseInt(dateParts[1], 10) - 1, parseInt(dateParts[2], 10));
            const today = new Date();
            
            const isToday = selectedDate.getDate() === today.getDate() && 
                            selectedDate.getMonth() === today.getMonth() && 
                            selectedDate.getFullYear() === today.getFullYear();
            
            // Check past date by stripping time
            const pastDateLimit = new Date(today.getFullYear(), today.getMonth(), today.getDate());
            const isPastDate = selectedDate < pastDateLimit;
            const currentHour = today.getHours();
            
            let hasAvailableSlot = false;
            let previouslySelectedValid = false;
            
            standardSlots.forEach(slot => {
                const slotHour = parseInt(slot.substring(0, 2), 10);
                const isDisabled = isPastDate || (isToday && slotHour <= currentHour); // Can't select slots in the past
                
                const pillClass = isDisabled ? "time-slot-pill disabled" : "time-slot-pill";
                const statusTxt = isDisabled ? "Hết chỗ/Quá hạn" : "Còn chỗ";
                const clickAttr = isDisabled ? "" : `onclick="selectTimeSlot('\${slot}', this)"`;
                
                // Keep selected slot if still valid
                const isActive = (!isDisabled && selectedTimeSlot === slot) ? "active" : "";
                if (isActive) previouslySelectedValid = true;
                if (!isDisabled) hasAvailableSlot = true;

                grid.innerHTML += `<div class="\${pillClass} \${isActive}" data-slot="\${slot}" \${clickAttr}>
                    <span class="slot-time">\${slot}</span><span class="slot-status">\${statusTxt}</span></div>`;
            });
            
            if (!previouslySelectedValid) {
                if (btn) btn.disabled = true;
                if (banner) {
                    if (!hasAvailableSlot) {
                        banner.style.display = "flex";
                        banner.innerHTML = `<i class="fa fa-exclamation-circle" style="color:#d62828;"></i> <span style="color:#d62828;">Không còn khung giờ giao hàng trống trong ngày này. Vui lòng chọn ngày khác.</span>`;
                    } else {
                        banner.style.display = "none";
                    }
                }
                if (inputField) inputField.value = "";
                selectedTimeSlot = "";
            } else {
                // Có giờ đang được chọn và nó hợp lệ
                if (btn) btn.disabled = false;
                if (banner) {
                    banner.style.display = "flex";
                    banner.innerHTML = `<i class="fa fa-check-circle"></i> <span>Đã xác nhận năng lực sản xuất & giao hàng cho khung giờ \${selectedTimeSlot}</span>`;
                }
            }
        }

        // toggleAddressList function removed as there is no list to toggle

        function loadCartItems() {
            try {
                const localCartStr = localStorage.getItem("cart");
                const localCart = localCartStr ? JSON.parse(localCartStr) : [];
                currentCart = Array.isArray(localCart) ? localCart.filter(item => item && item.id && item.name && item.price != null && !String(item.id).startsWith("MOCK-")) : [];
            } catch(e) {
                currentCart = [];
            }
            localStorage.setItem("cart", JSON.stringify(currentCart));
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
                        <a href="${pageContext.request.contextPath}/products" class="btn btn-primary" style="margin-top:10px; display:inline-block; padding:8px 16px; background:var(--primary-dark); color:white; border-radius:8px; text-decoration:none;">Xem thực đơn</a>
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
                const imgUrl = (item.image && typeof item.image === "string" && item.image.startsWith("http")) ? item.image : "${pageContext.request.contextPath}/" + (item.image || "assets/images/products/basic.png");
                const priceFormatted = (parseFloat(item.price) || 0).toLocaleString("vi-VN") + "đ";
                
                let cleanName = item.name || '';
                let cleanDesc = item.desc || 'Bánh ngọt thủ công cao cấp';
                
                if (cleanName.startsWith("SIZE_")) {
                    const parts = cleanName.split("_");
                    const size = parts[1] || "16";
                    const layers = parts[3] || "1";
                    cleanName = `Bánh Kem Tùy Chỉnh (${size}cm)`;
                    
                    let flavorStr = [];
                    for(let i = 4; i < parts.length; i++) {
                        let f = parts[i];
                        if(f === 'VANILLA') f = 'Vani';
                        else if (f === 'CHOCO') f = 'Chocolate';
                        else if (f === 'STRAW') f = 'Dâu';
                        else if (f === 'MATCHA') f = 'Trà xanh';
                        flavorStr.push(f);
                    }
                    cleanDesc = `\${layers} Tầng: \${flavorStr.join(', ')}`;
                }

                const itemHtml = `
                    <div class="product-item-row" id="cart-item-\${item.id}">
                        <div class="product-item-left" style="min-width: 0; flex: 1; margin-right: 15px;">
                            <img src="\${imgUrl}" class="product-img" alt="\${cleanName}" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=120'">
                            <div class="product-details-text" style="min-width: 0; overflow: hidden; display: flex; flex-direction: column;">
                                <span class="product-title" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;">\${cleanName}</span>
                                <span class="product-desc" style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;">\${cleanDesc}</span>
                            </div>
                        </div>
                        <div class="product-item-right-actions">
                            <span class="product-price">\${priceFormatted}</span>
                            <div class="qty-adjust-box">
                                <button type="button" class="btn-qty" onclick="adjustItemQty('\${item.id}', -1)">−</button>
                                <span class="qty-display">\${parseInt(item.qty) || 1}</span>
                                <button type="button" class="btn-qty" onclick="adjustItemQty('\${item.id}', 1)">+</button>
                            </div>
                            <button type="button" class="btn-delete-item" onclick="deleteItem('\${item.id}')" title="Xóa sản phẩm">
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
            
            window.dispatchEvent(new Event("storage"));

            renderCartList();
        }

        function deleteItem(itemId) {
            currentCart = currentCart.filter(x => x && x.id != itemId);
            localStorage.setItem("cart", JSON.stringify(currentCart));
            document.getElementById("cartDataInput").value = JSON.stringify(currentCart);

            window.dispatchEvent(new Event("storage"));

            renderCartList();
        }

        function selectAddress(id, lat, lng, element) {
            selectedAddressId = id;
            document.getElementById("selectedAddressIdInput").value = id;

            const cards = document.querySelectorAll("#addressListContainer .address-card-option");
            for (let i = 0; i < cards.length; i++) {
                cards[i].classList.remove("active");
                const radio = cards[i].querySelector(".address-radio");
                if (radio) radio.checked = false;
            }

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

            const shippingRate = parseFloat('${not empty settings.shippingRate ? settings.shippingRate : "5000"}') || 5000;
            const distance = getHaversineDistance(shopLat, shopLng, lat, lng) * 1.25;
            const finalDistance = Math.max(1.0, distance);

            // currentShippingFee = Math.max(shippingRate, Math.ceil(finalDistance) * shippingRate);
            currentShippingFee = 0;
            updateSummary();
        }

        function selectTimeSlot(slot, element) {
            try {
                if (element.classList.contains("disabled")) {
                    alert("Khung giờ này đã quá hạn hoặc hết chỗ, vui lòng chọn giờ khác.");
                    return;
                }

                selectedTimeSlot = slot;
                const inputField = document.getElementById("selectedTimeSlotInput");
                if (inputField) inputField.value = slot;

                const pills = document.querySelectorAll(".time-slot-pill");
                for (let i = 0; i < pills.length; i++) {
                    pills[i].classList.remove("active");
                }

                element.classList.add("active");

                const banner = document.getElementById("slotConfirmationBanner");
                if (banner) {
                    banner.style.display = "flex";
                    banner.innerHTML = `<i class="fa fa-check-circle"></i> <span>Đã xác nhận năng lực sản xuất & giao hàng cho khung giờ ${slot}</span>`;
                }
                
                const btn = document.getElementById("btnPlaceOrder");
                if (btn) btn.disabled = false;
            } catch (e) {
                alert("Đã xảy ra lỗi JS khi chọn giờ: " + e.message);
                console.error(e);
            }
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
            let productTotal = Array.isArray(currentCart) 
                ? currentCart.reduce((sum, item) => sum + (parseFloat(item?.price || 0) * parseInt(item?.qty || 1)), 0) 
                : 0;

            let finalTotal = productTotal > 0 ? (productTotal + currentShippingFee) : 0;
            if (finalTotal > 0) {
                finalTotal = finalTotal - checkoutDiscount;
                if (finalTotal < 0) finalTotal = 0;
            }

            const subtotalEl = document.getElementById("productTotalSum");
            const shippingEl = document.getElementById("shippingFeeSum");
            const totalEl = document.getElementById("finalTotalSum");
            
            if (subtotalEl) subtotalEl.innerText = productTotal.toLocaleString("vi-VN") + "đ";
            if (shippingEl) shippingEl.innerText = currentShippingFee.toLocaleString("vi-VN") + "đ";
            if (totalEl) totalEl.innerText = finalTotal.toLocaleString("vi-VN") + "đ";
            
            const shippingFeeInput = document.getElementById("shippingFeeInput");
            if (shippingFeeInput) shippingFeeInput.value = currentShippingFee;
        }
    </script>
</body>
</html>
