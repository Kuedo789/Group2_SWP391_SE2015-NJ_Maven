<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
    <head>
        <title>BakeryZone | Giỏ hàng</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/cart.css">
    </head>
    <body>

        <div class="cart-container">
            <h1 class="cart-header">Giỏ hàng của bạn</h1>

            <form action="${pageContext.request.contextPath}/cart" method="POST" id="cartForm">
                <div class="cart-layout">

                    <div>
                        <div class="cart-items-wrapper">
                            <c:forEach var="item" items="${cartItems}">
                                <%-- Fixed: Changed item.isActive to item.active --%>
                                <div class="item-card ${item.active ? '' : 'disabled-item'}">
                                    <img src="${item.imageUrl}" alt="${item.name}" class="item-img">

                                    <div class="item-info">
                                        <div class="item-title">${item.name}</div>
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

                        <div class="summary-row">
                            <span>Tạm tính</span>
                            <span><fmt:formatNumber value="${cartSubtotal}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                        </div>
                        <div class="summary-row">
                            <span>Phí vận chuyển</span>
                            <span>30.000₫</span>
                        </div>
                        <div class="summary-row" style="color: #d9534f;">
                            <span>Giảm giá</span>
                            <span>-0₫</span>
                        </div>

                        <div class="summary-row total">
                            <span>Tổng cộng</span>
                            <span class="price"><fmt:formatNumber value="${cartSubtotal + 30000}" type="currency" currencySymbol="₫" maxFractionDigits="0"/></span>
                        </div>

                        <div class="voucher-group">
                            <input type="text" placeholder="Nhập mã voucher" class="voucher-input" name="voucherCode">
                            <button type="button" class="voucher-btn">Áp dụng</button>
                        </div>

                        <button type="submit" name="action" value="checkout" class="checkout-btn" ${empty cartItems ? 'disabled' : ''}>Thanh toán ngay</button>

                        <div style="text-align: center; margin-top: 16px; font-size: 11px; color: var(--text-muted);">
                            Bảo mật thanh toán 100%. CakeZone cam kết mang đến những trải nghiệm tuyệt vời nhất cho bạn.
                        </div>
                    </div>

                </div>
            </form>
        </div>

    </body>
</html>