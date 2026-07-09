<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"   uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"  %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Ví Voucher của tôi – BakeryZone</title>
    <meta name="description" content="Danh sách voucher bạn đang sở hữu tại BakeryZone.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/rewardsExchange.css">
    <style>
        .my-vouchers-page {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px;
        }
        .my-voucher-btn {
            display: inline-block;
            background: var(--primary);
            color: #fff;
            padding: 8px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            margin-top: 10px;
        }
        .my-voucher-btn:hover {
            background: var(--primary-dark);
            color: #fff;
        }
    </style>
</head>

<body>

<jsp:include page="../common/navbar.jsp" />

<main class="my-vouchers-page rewards-page">

    <a href="${pageContext.request.contextPath}/profile" class="rw-back-link">
        ← Quay lại trang cá nhân
    </a>

    <div class="rw-page-header">
        <h1>🎟 Ví Voucher của tôi</h1>
        <p>Đây là những voucher bạn đã lưu hoặc đổi được. Hãy sử dụng chúng khi đặt hàng!</p>
    </div>

    <div class="rw-grid">
        <c:choose>
            <c:when test="${not empty voucherList}">
                <c:forEach var="v" items="${voucherList}">
                    <div class="rw-card">
                        <div class="rw-card-header">
                            <div>
                                <h3 class="rw-card-title">${v.title}</h3>
                                <div class="rw-card-code">Mã: <span>${v.voucherCode}</span></div>
                            </div>
                            <div class="rw-discount-badge">${v.discountLabel}</div>
                        </div>

                        <div class="rw-card-body">
                            <div class="rw-detail-row">
                                <span class="rw-detail-label">Đơn tối thiểu:</span>
                                <span class="rw-detail-value">
                                    <fmt:formatNumber value="${v.minOrderValue}" type="number" pattern="#,##0" />đ
                                </span>
                            </div>
                            <c:if test="${not empty v.maxDiscountAmount and v.maxDiscountAmount > 0}">
                                <div class="rw-detail-row">
                                    <span class="rw-detail-label">Giảm tối đa:</span>
                                    <span class="rw-detail-value">
                                        <fmt:formatNumber value="${v.maxDiscountAmount}" type="number" pattern="#,##0" />đ
                                    </span>
                                </div>
                            </c:if>
                            <div class="rw-detail-row">
                                <span class="rw-detail-label">Hạn sử dụng:</span>
                                <span class="rw-detail-value">
                                    <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy" />
                                </span>
                            </div>
                        </div>

                        <div class="rw-card-footer" style="display: flex; justify-content: center;">
                            <a href="${pageContext.request.contextPath}/products" class="my-voucher-btn">Sử dụng ngay</a>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div style="grid-column: 1 / -1; text-align: center; padding: 40px; background: #fff; border-radius: 12px; border: 1px dashed #ddd;">
                    <span style="font-size: 40px; color: #ccc;">🎫</span>
                    <h3 style="margin-top: 16px; color: var(--text);">Bạn chưa có voucher nào</h3>
                    <p style="color: var(--muted); margin-bottom: 20px;">Hãy tích cực mua sắm để tích điểm và đổi voucher nhé!</p>
                    <a href="${pageContext.request.contextPath}/rewards" class="my-voucher-btn">Đi tới trang Đổi thưởng</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</main>

<jsp:include page="../common/footer.jsp" />

</body>
</html>
