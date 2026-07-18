<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- FIXED: Added explicit model class import so Tomcat compiles without errors --%>
<%@ page import="com.bakeryzone.model.User" %>

<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>BakeryZone | Giỏ hàng</title>
        <script>
            (function() {
                var isDarkMode = ${not empty settings.darkMode ? settings.darkMode : 'false'};
                if (isDarkMode) {
                    document.documentElement.classList.add('dark-theme');
                }
            })();
        </script>

        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all/cart.css">
        <style>
            /* Adjust the 90px value up or down depending on your actual header height */
            .cart-container {
                padding-top: 100px !important;
                margin-top: 0 !important;
            }
        </style>
    </head>
    <body>

        <jsp:include page="../common/navbar.jsp" />

        <div class="cart-container">
            <h1 class="cart-header">Giỏ hàng của bạn</h1>
            <c:if test="${not isUnauthenticated && not empty cartItems}">
                <span style="font-size: 18px; color: var(--text-muted, #756b64); font-weight: 400; margin-left: 8px;">
                    (${cartItems.size()} sản phẩm)
                </span>
            </c:if>

            <c:choose>
                <%-- CASE 1: User is not logged in --%>
                <c:when test="${isUnauthenticated}">
                    <style>
                        .unauth-card-wrapper {
                            background-color: #ffffff;
                            border: 1px solid var(--border, #eee5dc);
                            border-radius: var(--radius-lg, 30px);
                            padding: 80px 40px;
                            text-align: center;
                            max-width: 680px;
                            margin: 40px auto;
                            box-shadow: var(--shadow-soft, 0 18px 45px rgba(64, 52, 38, 0.05));
                        }
                        .unauth-icon-circle {
                            width: 90px;
                            height: 90px;
                            background-color: var(--bg-soft, #f3f7f2);
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 24px auto;
                            color: var(--primary, #345f3d);
                        }
                        .unauth-card-wrapper h3 {
                            font-family: "Be Vietnam Pro", Arial, sans-serif;
                            font-size: 24px;
                            font-weight: 600;
                            color: var(--text, #241d18);
                            margin: 0 0 12px 0;
                        }
                        .unauth-card-wrapper p {
                            font-family: "Be Vietnam Pro", Arial, sans-serif;
                            font-size: 15px;
                            color: var(--text-muted, #756b64);
                            margin: 0 0 32px 0;
                            line-height: 1.6;
                        }
                        .unauth-login-btn {
                            display: inline-block;
                            font-family: "Be Vietnam Pro", Arial, sans-serif;
                            padding: 14px 36px;
                            background-color: var(--primary, #345f3d);
                            color: #ffffff !important;
                            text-decoration: none;
                            font-size: 15px;
                            font-weight: 500;
                            border-radius: var(--radius-sm, 14px);
                            box-shadow: 0 4px 12px rgba(52, 95, 61, 0.15);
                            transition: transform 0.2s ease, background-color 0.2s ease;
                        }
                        .unauth-login-btn:hover {
                            background-color: var(--primary-dark, #2f472b);
                            transform: translateY(-2px);
                        }
                    </style>

                    <div class="unauth-card-wrapper">
                        <div class="unauth-icon-circle">
                            <svg xmlns="http://www.w3.org/2000/svg" width="42" height="42" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                            <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                        </div>
                        <h3>Bạn chưa đăng nhập</h3>
                        <p>Vui lòng đăng nhập tài khoản của bạn để có thể xem, thay đổi số lượng <br> và quản lý giỏ hàng bánh ngọt cá nhân.</p>
                        <a href="${pageContext.request.contextPath}/login" class="unauth-login-btn">Đăng nhập ngay</a>
                    </div>
                </c:when>

                <%-- CASE 2: User is logged in, render the operational cart workspace --%>
                <c:otherwise>
                    <form action="${pageContext.request.contextPath}/cart" method="POST" id="cartForm">
                        <div class="cart-layout">

                            <div>
                                <div class="cart-items-wrapper">
                                    <c:forEach var="item" items="${cartItems}">
                                        <%-- Fixed: Changed item.isActive to item.active --%>
                                        <div class="item-card ${item.active ? '' : 'disabled-item'}"
                                             data-id="${item.cartItemId}"
                                             data-price="${item.unitPrice}"
                                             data-qty="${item.quantity}"
                                             data-name="${item.name}"
                                             data-image="${item.imageUrl}">
                                            
                                            <!-- Item Selection Checkbox -->
                                            <input type="checkbox" class="cart-item-checkbox" ${item.active ? '' : 'disabled'} style="margin-right: 15px; width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary);">

                                            <img src="${item.imageUrl}" alt="${item.name}" class="item-img">

                                            <div class="item-info">
                                                <c:choose>
                                                    <c:when test="${fn:startsWith(item.name, 'SIZE_')}">
                                                        <c:set var="parts" value="${fn:split(item.name, '_')}" />
                                                        <c:set var="size" value="${parts[1]}" />
                                                        <c:set var="layers" value="${parts[3]}" />
                                                        <div class="item-title">Bánh Kem Tùy Chỉnh (${size}cm)</div>
                                                        <div class="item-desc" style="margin-top: 4px; margin-bottom: 6px;">
                                                            <strong>${layers} Tầng:</strong> 
                                                            <c:forEach var="i" begin="4" end="${fn:length(parts) - 1}" varStatus="status">
                                                                <c:choose>
                                                                    <c:when test="${parts[i] == 'VANILLA'}">Vani</c:when>
                                                                    <c:when test="${parts[i] == 'CHOCO'}">Chocolate</c:when>
                                                                    <c:when test="${parts[i] == 'STRAW'}">Dâu</c:when>
                                                                    <c:when test="${parts[i] == 'MATCHA'}">Trà xanh</c:when>
                                                                    <c:otherwise>${parts[i]}</c:otherwise>
                                                                </c:choose><c:if test="${!status.last}">, </c:if>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="item-title">${item.name}</div>
                                                    </c:otherwise>
                                                </c:choose>

                                                <div class="item-desc">
                                                    <c:choose>
                                                        <c:when test="${not empty item.greetingText}">
                                                            Greeting: "${item.greetingText}"
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${item.description}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="item-controls">
                                                <div class="qty-pill">
                                                    <%-- Fixed: Changed item.isActive to item.active --%>
                                                    <button type="submit" name="action" value="decrease-${item.cartItemId}" class="qty-btn" ${item.active ? '' : 'disabled'}>-</button>
                                                    <input type="text" class="qty-input" value="${item.quantity}" readonly>
                                                    <%-- Fixed: Changed item.isActive to item.active --%>
                                                    <button type="submit" name="action" value="increase-${item.cartItemId}" class="qty-btn" ${item.active ? '' : 'disabled'}>+</button>
                                                </div>
                                                <div class="item-price">
                                                    <fmt:formatNumber value="${item.unitPrice * item.quantity}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                                </div>
                                            </div>

                                            <button type="submit" name="action" value="remove-${item.cartItemId}" class="remove-btn">
                                                <%-- Fixed: Changed item.isActive to item.active --%>
                                                <c:choose>
                                                    <c:when test="${item.active}">✕</c:when>
                                                    <c:otherwise><span style="font-size:12px;">Khôi phục</span></c:otherwise>
                                                </c:choose>
                                            </button>
                                        </div>
                                    </c:forEach>

                                    <c:if test="${empty cartItems}">
                                        <div style="padding: 40px; text-align: center; color: #888;">Giỏ hàng của bạn đang trống.</div>
                                    </c:if>
                                </div>

                                <a href="${pageContext.request.contextPath}/menu" class="continue-shopping">← Tiếp tục mua sắm các món ngon khác</a>

                                <div class="system-status-footer">
                                    ${footerAggregateStatus} </div>
                            </div>

                            <div class="summary-card">
                                <div class="summary-title">Tóm tắt đơn hàng</div>

                                <!-- Flash messages for voucher -->
                                <c:if test="${param.voucherRemoved == 'true'}">
                                    <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-check-circle"></i> Đã gỡ bỏ mã giảm giá.
                                    </div>
                                </c:if>
                                <c:if test="${not empty sessionScope.voucherError}">
                                    <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-exclamation-circle"></i> ${sessionScope.voucherError}
                                    </div>
                                    <c:remove var="voucherError" scope="session" />
                                </c:if>
                                <c:if test="${not empty sessionScope.appliedVoucherCode}">
                                    <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-check-circle"></i> Đã áp dụng mã <strong>${sessionScope.appliedVoucherCode}</strong> thành công!
                                    </div>
                                </c:if>

                                <div class="summary-row">
                                    <span>Tạm tính</span>
                                    <span id="cartSubtotalDisplay"><fmt:formatNumber value="${cartSubtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                                </div>

                                <div class="summary-row" style="color: #d9534f;">
                                    <span>Giảm giá</span>
                                    <span id="cartDiscountDisplay">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.appliedDiscount}">
                                                -<fmt:formatNumber value="${sessionScope.appliedDiscount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>-0₫</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="summary-row total">
                                    <span>Tổng cộng</span>
                                    <span class="price" id="cartTotalDisplay">
                                        <c:set var="totalValue" value="${cartSubtotal}" />
                                        <c:if test="${not empty sessionScope.appliedDiscount}">
                                            <c:set var="totalValue" value="${totalValue - sessionScope.appliedDiscount}" />
                                        </c:if>
                                        <c:if test="${totalValue < 0}"><c:set var="totalValue" value="0" /></c:if>
                                        <fmt:formatNumber value="${totalValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>

                                <div class="voucher-group" id="cartVoucherGroup">
                                    <c:choose>
                                        <c:when test="${not empty sessionScope.appliedVoucherCode}">
                                            <div style="display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 8px 12px; background: #f3f7f2; border: 1px dashed var(--primary); border-radius: 8px;">
                                                <span style="font-weight: 600; color: var(--primary);">${sessionScope.appliedVoucherCode}</span>
                                                <button type="submit" name="action" value="removeVoucher" style="background: none; border: none; color: #d9534f; cursor: pointer; font-size: 13px; font-weight: 600;">✕ Bỏ</button>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <%-- Frontend validation error message area --%>
                                            <div id="cartVoucherClientError" style="display:none; color:#d9534f; font-size:13px; margin-bottom:6px; display:flex; align-items:center; gap:5px;"></div>
                                            <div style="display:flex; gap:8px;">
                                                <input type="text" id="cartVoucherInput" placeholder="Nhập mã giảm giá" class="voucher-input" name="voucherCode"
                                                       maxlength="50" autocomplete="off" style="text-transform:uppercase;"
                                                       oninput="this.value=this.value.toUpperCase().replace(/[^A-Z0-9]/g,'');">
                                                <button type="button" id="cartVoucherBtn" class="voucher-btn" onclick="submitCartVoucher()">Áp dụng</button>
                                            </div>
                                            <input type="hidden" id="cartVoucherCodeHidden" name="voucherCodeHidden">
                                            <%-- Hidden submit button triggered programmatically after validation --%>
                                            <button type="submit" id="cartVoucherSubmitHidden" name="action" value="applyVoucher" style="display:none;"></button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <button type="submit" name="action" value="checkout" class="checkout-btn" ${empty cartItems ? 'disabled' : ''}>Thanh toán ngay</button>

                                <div style="text-align: center; margin-top: 16px; font-size: 11px; color: var(--text-muted);">
                                    Bảo mật thanh toán 100%. CakeZone cam kết mang đến những trải nghiệm tuyệt vời nhất cho bạn.
                                </div>
                            </div>

                        </div>
                    </form>
                </c:otherwise>
            </c:choose>
        </div>

        <script>

            const shippingFee = 0;

            // Voucher metadata baked in from session at render time
            const voucherDiscountType  = "${not empty sessionScope.voucherDiscountType  ? sessionScope.voucherDiscountType  : ''}";
            const voucherDiscountValue = parseFloat("${not empty sessionScope.voucherDiscountValue ? sessionScope.voucherDiscountValue : 0}") || 0;
            const voucherMaxDiscount   = parseFloat("${not empty sessionScope.voucherMaxDiscount   ? sessionScope.voucherMaxDiscount   : 0}") || 0;
            const hasVoucher = voucherDiscountType !== '' && voucherDiscountValue > 0;

            function computeDiscount(subtotal) {
                if (!hasVoucher) return 0;
                const type = voucherDiscountType.toUpperCase();
                let discount = 0;
                if (type === 'PERCENT' || type === 'PERCENTAGE') {
                    discount = subtotal * (voucherDiscountValue / 100);
                    if (voucherMaxDiscount > 0 && discount > voucherMaxDiscount) {
                        discount = voucherMaxDiscount;
                    }
                } else {
                    // FIXED or FIXED_AMOUNT
                    discount = voucherDiscountValue;
                }
                return Math.min(discount, subtotal); // discount can never exceed subtotal
            }

            function formatCurrency(amount) {
                return amount.toLocaleString('vi-VN') + "₫";
            }

            // ── Cart-page voucher frontend validation ─────────────────────────────
            function submitCartVoucher() {
                const input   = document.getElementById('cartVoucherInput');
                const btn     = document.getElementById('cartVoucherBtn');
                const errBox  = document.getElementById('cartVoucherClientError');

                function showError(msg) {
                    errBox.innerHTML = '<span style="font-size:14px;">&#9888;</span> ' + msg;
                    errBox.style.display = 'flex';
                    input.style.borderColor = '#d9534f';
                    input.focus();
                }

                function clearError() {
                    errBox.style.display = 'none';
                    input.style.borderColor = '';
                }

                clearError();

                const code = input.value.trim().toUpperCase();

                // 1. Empty check
                if (!code) {
                    showError('Vui lòng nhập mã voucher!');
                    return;
                }

                // 2. Format check – only uppercase letters A-Z and digits 0-9
                if (!/^[A-Z0-9]+$/.test(code)) {
                    showError('Mã voucher chỉ được chứa chữ cái và số (không dấu, không khoảng trắng).');
                    return;
                }

                // 3. Length check
                if (code.length > 50) {
                    showError('Mã voucher không được vượt quá 50 ký tự.');
                    return;
                }

                // All client-side checks passed — write canonical code & submit
                input.value = code;
                btn.disabled  = true;
                btn.innerHTML = '&#8987; Đang kiểm tra...';

                // Trigger the hidden submit button (carries name="action" value="applyVoucher")
                document.getElementById('cartVoucherSubmitHidden').click();
            }

            // Allow pressing Enter key inside the voucher input
            document.addEventListener('DOMContentLoaded', function () {
                const voucherInput = document.getElementById('cartVoucherInput');
                if (voucherInput) {
                    voucherInput.addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            e.preventDefault();
                            submitCartVoucher();
                        }
                    });
                }
            });
            // ─────────────────────────────────────────────────────────────────────

            // 2. Dynamic JS Calculation
            function updateSummaryTotals() {
                const checkboxes = document.querySelectorAll('.cart-item-checkbox');
                let subtotal = 0;
                let checkedIds = [];

                checkboxes.forEach(cb => {
                    const card = cb.closest('.item-card');
                    if (cb.checked) {
                        const price = parseFloat(card.getAttribute('data-price')) || 0;
                        const qty = parseInt(card.getAttribute('data-qty')) || 0;
                        subtotal += (price * qty);
                        checkedIds.push(card.getAttribute('data-id'));
                    }
                });

                // Persist selection across page reloads (e.g. when applying voucher or updating quantity)
                sessionStorage.setItem("selectedCartItems", JSON.stringify(checkedIds));

                let discount = computeDiscount(subtotal);

                let finalTotal = 0;
                if (subtotal > 0) {
                    finalTotal = subtotal + shippingFee - discount;
                    if (finalTotal < 0) finalTotal = 0;
                }

                // Update DOM
                document.getElementById('cartSubtotalDisplay').innerText = formatCurrency(subtotal);
                document.getElementById('cartDiscountDisplay').innerText = discount > 0 ? "-" + formatCurrency(discount) : "-0₫";
                document.getElementById('cartTotalDisplay').innerText = formatCurrency(finalTotal);
                
                // Disable checkout button if no items selected
                const checkoutBtn = document.querySelector('.checkout-btn');
                if (checkoutBtn) {
                    checkoutBtn.disabled = (subtotal === 0);
                }
            }

            // Bind change listeners to checkboxes
            document.querySelectorAll('.cart-item-checkbox').forEach(cb => {
                cb.addEventListener('change', updateSummaryTotals);
            });
            
            // Allow clicking the card itself (optional nice UX)
            document.querySelectorAll('.item-card').forEach(card => {
                card.addEventListener('click', function(e) {
                    // Don't trigger if they click a button or input inside the card
                    if (e.target.tagName !== 'BUTTON' && e.target.tagName !== 'INPUT' && !e.target.classList.contains('qty-btn')) {
                        const cb = this.querySelector('.cart-item-checkbox');
                        if (cb && !cb.disabled) {
                            cb.checked = !cb.checked;
                            updateSummaryTotals();
                        }
                    }
                });
            });

            // Restore previous selection on page load, or leave unchecked if first visit
            document.addEventListener("DOMContentLoaded", function() {
                const savedSelection = sessionStorage.getItem("selectedCartItems");
                if (savedSelection) {
                    try {
                        const checkedIds = JSON.parse(savedSelection);
                        document.querySelectorAll('.cart-item-checkbox').forEach(cb => {
                            const cardId = cb.closest('.item-card').getAttribute('data-id');
                            if (checkedIds.includes(cardId) && !cb.disabled) {
                                cb.checked = true;
                            }
                        });
                    } catch (e) {
                        console.warn("Could not parse selected cart items from sessionStorage");
                    }
                }
                
                // Initialize totals based on restored state (or completely unchecked state)
                updateSummaryTotals();
            });

            // 3. Checkout Submission Interceptor
            document.querySelector('.checkout-btn')?.addEventListener('click', function(e) {
                // Determine which button triggered the form. If it's the checkout button:
                const checkboxes = document.querySelectorAll('.cart-item-checkbox');
                let checkoutCart = [];

                checkboxes.forEach(cb => {
                    if (cb.checked) {
                        const card = cb.closest('.item-card');
                        
                        // Map to the format expected by checkout.jsp's localStorage reader
                        const itemObj = {
                            id: card.getAttribute('data-id'),
                            name: card.getAttribute('data-name'),
                            price: parseFloat(card.getAttribute('data-price')),
                            qty: parseInt(card.getAttribute('data-qty')),
                            image: card.getAttribute('data-image')
                        };
                        
                        // Special handling for Custom Cakes: pass the cartItemId as templateId 
                        // so checkout logic knows it's a generated cake template
                        if (itemObj.name && itemObj.name.startsWith("SIZE_")) {
                            itemObj.templateId = card.getAttribute('data-id'); 
                        }
                        
                        checkoutCart.push(itemObj);
                    }
                });

                // Write the filtered array to localStorage before the form submits and redirects
                if (checkoutCart.length > 0) {
                    localStorage.setItem("cart", JSON.stringify(checkoutCart));
                } else {
                    e.preventDefault();
                    alert("Vui lòng chọn ít nhất 1 sản phẩm để thanh toán.");
                }
            });
        </script>
    </body>
</html>