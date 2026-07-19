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
                                            <input type="checkbox" name="selectedCartItems" value="${item.cartItemId}" class="cart-item-checkbox" ${item.active ? '' : 'disabled'} style="margin-right: 15px; width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary);">

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

                                <div class="voucher-group" id="cartVoucherGroup" style="display: flex; flex-direction: column; gap: 8px;">
                                    <div style="display: flex; justify-content: space-between; align-items: center; cursor: pointer; padding: 12px; border: 1px solid var(--border-color); border-radius: 8px; background: #fff;" onclick="openVoucherModal()">
                                        <div style="display: flex; align-items: center; gap: 8px;">
                                            <i class="fa fa-ticket-alt" style="color: var(--primary);"></i>
                                            <span style="font-weight: 600; font-size: 14px; color: var(--text-dark);">Chọn hoặc nhập mã voucher</span>
                                        </div>
                                        <i class="fa fa-chevron-right" style="color: var(--text-muted); font-size: 12px;"></i>
                                    </div>

                                    <%-- Compact Applied Summary --%>
                                    <div id="appliedVouchersSummary" style="display: flex; flex-direction: column; gap: 6px;">
                                        <!-- Rendered by JS -->
                                    </div>
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

        <!-- Voucher Modal -->
        <style>
            .applied-voucher-badge {
                display: flex; align-items: center; justify-content: space-between;
                padding: 6px 12px; background: #f3f7f2; border: 1px dashed var(--primary); border-radius: 6px; font-size: 13px;
            }
            .applied-voucher-badge .badge-label { color: #555; font-weight: 600; }
            .applied-voucher-badge .badge-code { color: var(--primary); font-weight: 700; margin-left: 6px; }
            .applied-voucher-badge .badge-discount { color: #d9534f; font-weight: 700; }
            
            .modal-ticket {
                display: flex; background: #fff; border: 1px solid #eee; border-radius: 8px; overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.04); position: relative; transition: all 0.2s; cursor: pointer;
            }
            .modal-ticket.selected {
                border-color: var(--primary);
                background: #fcfdfc;
            }
            .modal-ticket.disabled {
                opacity: 0.5; filter: grayscale(1); pointer-events: none;
            }
            .modal-ticket-left {
                width: 90px; background: linear-gradient(135deg, #7dbb84, var(--primary)); display: flex; flex-direction: column;
                align-items: center; justify-content: center; padding: 12px 8px; text-align: center; color: white; border-right: 1px dashed rgba(255,255,255,0.5);
            }
            .modal-ticket-right {
                flex: 1; padding: 12px; display: flex; flex-direction: column; justify-content: center; gap: 4px; position: relative;
            }
            .modal-ticket-title { font-size: 14px; font-weight: 700; color: #333; line-height: 1.3; }
            .modal-ticket-desc { font-size: 12px; color: #777; }
            .modal-ticket-date { font-size: 11px; color: #999; margin-top: 4px; }
            .modal-ticket-checkbox {
                position: absolute; right: 12px; top: 50%; transform: translateY(-50%); width: 20px; height: 20px;
                border: 2px solid #ddd; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            }
            .modal-ticket.selected .modal-ticket-checkbox {
                border-color: var(--primary); background: var(--primary);
            }
            .modal-ticket.selected .modal-ticket-checkbox::after {
                content: ''; width: 5px; height: 10px; border: solid white; border-width: 0 2px 2px 0;
                transform: rotate(45deg); margin-bottom: 2px;
            }
        </style>
        <div id="voucherModal" class="voucher-modal-overlay" style="display:none; position: fixed; top:0; left:0; right:0; bottom:0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
            <div class="voucher-modal-content" style="background: #fffdf9; width: 100%; max-width: 480px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.15); display: flex; flex-direction: column; max-height: 90vh;">
                <!-- Header -->
                <div style="padding: 16px 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; background: #fff;">
                    <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-dark);">Chọn BakeryZone Voucher</h3>
                    <button type="button" onclick="closeVoucherModal()" style="background: none; border: none; font-size: 20px; color: #999; cursor: pointer;">&times;</button>
                </div>
                
                <!-- Input Area -->
                <div style="padding: 16px 20px; background: #fff;">
                    <div style="display: flex; gap: 8px;">
                        <input type="text" id="modalVoucherInput" placeholder="Mã Voucher (nếu có)" style="flex: 1; height: 42px; padding: 0 12px; border: 1px solid #ddd; border-radius: 6px; text-transform: uppercase;">
                        <button type="button" onclick="applyManualVoucher()" id="modalVoucherBtn" style="background: var(--primary); color: #fff; border: none; border-radius: 6px; padding: 0 16px; font-weight: 600; cursor: pointer;">ÁP DỤNG</button>
                    </div>
                    <div id="modalVoucherError" style="color: #d9534f; font-size: 13px; margin-top: 6px; display: none;"></div>
                </div>

                <!-- Lists Area -->
                <div style="flex: 1; overflow-y: auto; padding: 0 20px 20px 20px; background: #f9f9f9;">
                    <div id="voucherListsContainer"></div>
                </div>

                <!-- Footer -->
                <div style="padding: 16px 20px; border-top: 1px solid #eee; background: #fff; display: flex; justify-content: flex-end; gap: 12px;">
                    <button type="button" onclick="closeVoucherModal()" style="padding: 10px 20px; border: 1px solid #ddd; background: #fff; border-radius: 6px; font-weight: 600; cursor: pointer;">TRỞ LẠI</button>
                    <button type="button" onclick="confirmVoucherSelection()" style="padding: 10px 20px; border: none; background: var(--primary); color: #fff; border-radius: 6px; font-weight: 600; cursor: pointer;">ĐỒNG Ý</button>
                </div>
            </div>
        </div>
        <script>
            const shippingFee = 0;

            let rawAvailableVouchers = [
                <c:forEach var="v" items="${availableVouchers}" varStatus="loop">
                    {
                        code: "${v.voucherCode}",
                        title: "${v.title}",
                        scope: "${v.voucherScope}",
                        discountType: "${v.discountType}",
                        discountValue: ${v.discountValue},
                        minOrder: ${v.minOrderValue != null ? v.minOrderValue : 0},
                        maxDiscount: ${v.maxDiscountAmount != null ? v.maxDiscountAmount : 0},
                        endDate: "${v.endDate}"
                    }${!loop.last ? ',' : ''}
                </c:forEach>
            ];

            // Deduplicate vouchers by code in case the user owns multiple copies of the same voucher
            // This prevents multiple tickets from being visually selected simultaneously when clicking one
            const availableVouchers = [];
            const seenCodes = new Set();
            for (let v of rawAvailableVouchers) {
                if (!seenCodes.has(v.code)) {
                    seenCodes.add(v.code);
                    availableVouchers.push(v);
                }
            }

            let selectedOrderCode = "${not empty sessionScope.appliedOrderVoucherCode ? sessionScope.appliedOrderVoucherCode : ''}";
            let selectedShippingCode = "${not empty sessionScope.appliedShippingVoucherCode ? sessionScope.appliedShippingVoucherCode : ''}";
            let stagingOrderCode = selectedOrderCode;
            let stagingShippingCode = selectedShippingCode;
            
            let currentSubtotal = 0;
            let isOrderExpanded = false;
            let isShippingExpanded = false;

            function computeDiscount(subtotal) {
                let discount = 0;
                if (selectedOrderCode) {
                    const v = availableVouchers.find(x => x.code === selectedOrderCode);
                    if (v && subtotal >= v.minOrder) {
                        if (v.discountType === 'PERCENT' || v.discountType === 'PERCENTAGE') {
                            let d = subtotal * (v.discountValue / 100);
                            if (v.maxDiscount > 0 && d > v.maxDiscount) d = v.maxDiscount;
                            discount += d;
                        } else {
                            discount += v.discountValue;
                        }
                    }
                }
                return Math.min(discount, subtotal);
            }

            function formatCurrency(amount) {
                return amount.toLocaleString('vi-VN') + "₫";
            }

            function openVoucherModal() {
                stagingOrderCode = selectedOrderCode;
                stagingShippingCode = selectedShippingCode;
                document.getElementById('modalVoucherError').style.display = 'none';
                document.getElementById('voucherModal').style.display = 'flex';
                renderModalLists();
            }

            function closeVoucherModal() {
                document.getElementById('voucherModal').style.display = 'none';
            }

            function toggleVoucherSelection(code, scope) {
                if (scope === 'ORDER') {
                    if (stagingOrderCode === code) stagingOrderCode = '';
                    else stagingOrderCode = code;
                } else if (scope === 'SHIPPING') {
                    if (stagingShippingCode === code) stagingShippingCode = '';
                    else stagingShippingCode = code;
                }
                renderModalLists();
            }

            function applyManualVoucher() {
                const code = document.getElementById('modalVoucherInput').value.trim().toUpperCase();
                const errBox = document.getElementById('modalVoucherError');
                if (!code) return;
                
                const v = availableVouchers.find(x => x.code === code);
                if (!v) {
                    errBox.innerText = 'Voucher không tồn tại hoặc không dành cho bạn.';
                    errBox.style.display = 'block';
                    return;
                }
                if (currentSubtotal < v.minOrder) {
                    errBox.innerText = 'Đơn hàng chưa đạt giá trị tối thiểu: ' + formatCurrency(v.minOrder);
                    errBox.style.display = 'block';
                    return;
                }

                errBox.style.display = 'none';
                toggleVoucherSelection(v.code, v.scope);
            }

            function toggleMoreVouchers(scope) {
                if (scope === 'ORDER') isOrderExpanded = !isOrderExpanded;
                if (scope === 'SHIPPING') isShippingExpanded = !isShippingExpanded;
                renderModalLists();
            }

            function renderModalLists() {
                const container = document.getElementById('voucherListsContainer');
                const shippingVouchers = availableVouchers.filter(v => v.scope === 'SHIPPING');
                const orderVouchers = availableVouchers.filter(v => v.scope === 'ORDER');
                
                let html = '';
                
                if (shippingVouchers.length > 0) {
                    html += `<h4 style="font-size: 14px; font-weight: 700; color: #555; margin: 16px 0 12px 0;">MÃ MIỄN PHÍ VẬN CHUYỂN</h4>
                             <div style="display: flex; flex-direction: column; gap: 12px;">`;
                    const limit = isShippingExpanded ? shippingVouchers.length : Math.min(2, shippingVouchers.length);
                    for (let i = 0; i < limit; i++) {
                        html += buildTicketHtml(shippingVouchers[i], stagingShippingCode);
                    }
                    html += `</div>`;
                    if (shippingVouchers.length > 2) {
                        html += `<div style="text-align: center; margin-top: 12px;">
                                    <button type="button" onclick="toggleMoreVouchers('SHIPPING')" style="background: none; border: none; color: var(--primary); font-size: 13px; font-weight: 600; cursor: pointer;">
                                        \${isShippingExpanded ? 'Thu gọn <i class="fa fa-chevron-up"></i>' : 'Xem thêm <i class="fa fa-chevron-down"></i>'}
                                    </button>
                                 </div>`;
                    }
                }

                if (orderVouchers.length > 0) {
                    html += `<h4 style="font-size: 14px; font-weight: 700; color: #555; margin: 24px 0 12px 0;">MÃ GIẢM GIÁ / HOÀN XU</h4>
                             <div style="display: flex; flex-direction: column; gap: 12px;">`;
                    const limit = isOrderExpanded ? orderVouchers.length : Math.min(2, orderVouchers.length);
                    for (let i = 0; i < limit; i++) {
                        html += buildTicketHtml(orderVouchers[i], stagingOrderCode);
                    }
                    html += `</div>`;
                    if (orderVouchers.length > 2) {
                        html += `<div style="text-align: center; margin-top: 12px;">
                                    <button type="button" onclick="toggleMoreVouchers('ORDER')" style="background: none; border: none; color: var(--primary); font-size: 13px; font-weight: 600; cursor: pointer;">
                                        \${isOrderExpanded ? 'Thu gọn <i class="fa fa-chevron-up"></i>' : 'Xem thêm <i class="fa fa-chevron-down"></i>'}
                                    </button>
                                 </div>`;
                    }
                }
                
                if (html === '') {
                    html = '<div style="text-align:center; color:#999; padding: 30px;">Bạn hiện không có voucher nào.</div>';
                }
                container.innerHTML = html;
            }

            function buildTicketHtml(v, stagingCode) {
                const isSelected = v.code === stagingCode;
                const isValid = currentSubtotal >= v.minOrder;
                const classStr = 'modal-ticket' + (isSelected ? ' selected' : '') + (isValid ? '' : ' disabled');
                
                let discountText = v.discountType === 'PERCENT' || v.discountType === 'PERCENTAGE' 
                    ? v.discountValue + '%' : formatCurrency(v.discountValue);
                
                let descText = `Đơn tối thiểu \${formatCurrency(v.minOrder)}`;
                if (v.maxDiscount > 0) {
                    descText += ` - Giảm tối đa \${formatCurrency(v.maxDiscount)}`;
                }
                
                return `
                    <div class="\${classStr}" onclick="\${isValid ? `toggleVoucherSelection('\${v.code}', '\${v.scope}')` : ''}">
                        <div class="modal-ticket-left">
                            <span style="font-size: 18px; font-weight: 800;">Giảm</span>
                            <span style="font-size: 16px; font-weight: 700;">\${discountText}</span>
                        </div>
                        <div class="modal-ticket-right">
                            <div class="modal-ticket-title">\${v.code}</div>
                            <div class="modal-ticket-desc">\${descText}</div>
                            <div class="modal-ticket-date">HSD: \${v.endDate}</div>
                            <div class="modal-ticket-checkbox"></div>
                        </div>
                    </div>
                `;
            }

            function confirmVoucherSelection() {
                const formData = new URLSearchParams();
                formData.append('action', 'applyVouchersAjax');
                if (stagingOrderCode) formData.append('orderCode', stagingOrderCode);
                if (stagingShippingCode) formData.append('shippingCode', stagingShippingCode);

                fetch('${pageContext.request.contextPath}/cart', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        selectedOrderCode = stagingOrderCode;
                        selectedShippingCode = stagingShippingCode;
                        closeVoucherModal();
                        updateSummaryTotals();
                    } else {
                        document.getElementById('modalVoucherError').innerText = data.error;
                        document.getElementById('modalVoucherError').style.display = 'block';
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Có lỗi xảy ra khi áp dụng voucher.");
                });
            }

            function renderAppliedSummary() {
                const summaryDiv = document.getElementById('appliedVouchersSummary');
                let html = '';
                
                if (selectedOrderCode) {
                    const v = availableVouchers.find(x => x.code === selectedOrderCode);
                    if (v) {
                        let d = 0;
                        if (v.discountType === 'PERCENT' || v.discountType === 'PERCENTAGE') {
                            d = currentSubtotal * (v.discountValue / 100);
                            if (v.maxDiscount > 0 && d > v.maxDiscount) d = v.maxDiscount;
                        } else {
                            d = v.discountValue;
                        }
                        d = Math.min(d, currentSubtotal);
                        
                        html += `
                            <div class="applied-voucher-badge">
                                <div><span class="badge-label">Toàn đơn:</span><span class="badge-code">\${v.code}</span></div>
                                <span class="badge-discount">-\${formatCurrency(d)}</span>
                            </div>
                        `;
                    }
                }
                
                if (selectedShippingCode) {
                    const v = availableVouchers.find(x => x.code === selectedShippingCode);
                    if (v) {
                        html += `
                            <div class="applied-voucher-badge">
                                <div><span class="badge-label">Vận chuyển:</span><span class="badge-code">\${v.code}</span></div>
                                <span style="color:#555;">(Áp dụng khi Thanh toán)</span>
                            </div>
                        `;
                    }
                }
                
                summaryDiv.innerHTML = html;
            }

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
                currentSubtotal = subtotal;

                let discount = computeDiscount(subtotal);

                // Auto-deselect vouchers if subtotal drops below minimums
                if (selectedOrderCode) {
                    const vo = availableVouchers.find(x => x.code === selectedOrderCode);
                    if (vo && subtotal < vo.minOrder) {
                        selectedOrderCode = '';
                        discount = computeDiscount(subtotal);
                    }
                }
                if (selectedShippingCode) {
                    const vs = availableVouchers.find(x => x.code === selectedShippingCode);
                    if (vs && subtotal < vs.minOrder) {
                        selectedShippingCode = '';
                    }
                }
                
                renderAppliedSummary();

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
                // Restore Scroll Position to prevent jump-to-top on form submit
                const savedScroll = sessionStorage.getItem("cartScrollPos");
                if (savedScroll) {
                    window.scrollTo(0, parseInt(savedScroll));
                    sessionStorage.removeItem("cartScrollPos"); // clear after using
                }

                // Save Scroll Position on form submit (quantity update, remove, voucher, etc)
                document.querySelectorAll('form').forEach(form => {
                    form.addEventListener('submit', function() {
                        sessionStorage.setItem("cartScrollPos", window.scrollY);
                    });
                });

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