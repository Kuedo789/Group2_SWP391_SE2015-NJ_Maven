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
                                        <div class="item-card ${item.active ? '' : 'disabled-item'}">
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
                                <c:if test="${param.voucherApplied == 'true'}">
                                    <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-check-circle"></i> Voucher <strong>${appliedVoucherCode}</strong> đã được áp dụng thành công!
                                    </div>
                                </c:if>
                                <c:if test="${not empty param.voucherError}">
                                    <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-exclamation-circle"></i> 
                                        <c:choose>
                                            <c:when test="${param.voucherError == 'notFound'}">Mã voucher không hợp lệ hoặc bạn không sở hữu mã này.</c:when>
                                            <c:when test="${param.voucherError == 'minOrder'}">Đơn hàng chưa đạt giá trị tối thiểu để sử dụng voucher.</c:when>
                                            <c:when test="${param.voucherError == 'empty'}">Vui lòng nhập mã voucher.</c:when>
                                            <c:otherwise>${param.voucherError}</c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:if>
                                <c:if test="${not empty requestScope.voucherError}">
                                    <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 14px;">
                                        <i class="fa fa-exclamation-circle"></i> ${requestScope.voucherError}
                                    </div>
                                </c:if>

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
                                    <span>
                                        <c:choose>
                                            <c:when test="${not empty appliedDiscount}">
                                                -<fmt:formatNumber value="${appliedDiscount}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                            </c:when>
                                            <c:otherwise>-0₫</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="summary-row total">
                                    <span>Tổng cộng</span>
                                    <span class="price">
                                        <c:set var="totalValue" value="${cartSubtotal + 30000}" />
                                        <c:if test="${not empty appliedDiscount}">
                                            <c:set var="totalValue" value="${totalValue - appliedDiscount}" />
                                        </c:if>
                                        <c:if test="${totalValue < 0}"><c:set var="totalValue" value="0" /></c:if>
                                        <fmt:formatNumber value="${totalValue}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </span>
                                </div>

                                <div class="voucher-group">
                                    <c:choose>
                                        <c:when test="${not empty appliedVoucherCode}">
                                            <div style="display: flex; justify-content: space-between; align-items: center; width: 100%; padding: 8px 12px; background: #f3f7f2; border: 1px dashed var(--primary); border-radius: 8px;">
                                                <span style="font-weight: 600; color: var(--primary);">${appliedVoucherCode}</span>
                                                <button type="submit" name="action" value="removeVoucher" style="background: none; border: none; color: #d9534f; cursor: pointer; font-size: 13px; font-weight: 600;">✕ Bỏ</button>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="text" placeholder="Nhập mã voucher" class="voucher-input" name="voucherCode">
                                            <button type="submit" name="action" value="applyVoucher" class="voucher-btn">Áp dụng</button>
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

    </body>
</html>