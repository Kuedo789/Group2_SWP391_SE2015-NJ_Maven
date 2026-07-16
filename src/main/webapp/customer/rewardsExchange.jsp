<%--
    rewardsExchange.jsp
    Rewards Exchange Marketplace – lets the logged-in customer browse active
    vouchers and spend their accumulated points to redeem them.

    Request attributes expected (set by RewardsController GET):
      • availableRewards : List<Voucher> – active, in-date vouchers
      • userPoints       : int           – current accumulated-point balance
      • successMsg       : String        – (optional) PRG flash success message
      • errorMsg         : String        – (optional) PRG flash error message
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"   uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"  %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Đổi thưởng – BakeryZone</title>
    <meta name="description"
          content="Sử dụng điểm tích lũy của bạn để đổi voucher giảm giá hấp dẫn tại BakeryZone.">
    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/assets/css/customer/rewardsExchange.css">
</head>

<body>

<jsp:include page="../common/navbar.jsp" />

<main class="rewards-page">

    <%-- ================================================================
         Back navigation
    ================================================================ --%>
    <a href="${pageContext.request.contextPath}/membership" class="rw-back-link">
        ← Quay lại hạng thành viên
    </a>

    <%-- ================================================================
         Page heading
    ================================================================ --%>
    <div class="rw-page-header">
        <h1>🎁 Đổi Thưởng</h1>
        <p>Dùng điểm tích lũy để đổi lấy những voucher giảm giá đặc biệt dành riêng cho bạn.</p>
    </div>

    <%-- ================================================================
         Flash messages (PRG pattern – set by RewardsController POST)
    ================================================================ --%>
    <c:if test="${not empty successMsg}">
        <div class="rw-alert rw-alert-success" role="alert">
            <span>✅</span>
            <span>${successMsg}</span>
        </div>
    </c:if>

    <c:if test="${not empty errorMsg}">
        <div class="rw-alert rw-alert-error" role="alert">
            <span>⚠️</span>
            <span>${errorMsg}</span>
        </div>
    </c:if>

    <%-- ================================================================
         Points summary hero strip
    ================================================================ --%>
    <div class="rw-points-strip" aria-label="Số điểm hiện có">
        <div class="rw-points-strip-left">
            <div class="rw-points-icon">⭐</div>
            <div>
                <div class="rw-points-label">Điểm tích lũy hiện có</div>
                <div class="rw-points-value">
                    <fmt:formatNumber value="${userPoints}" type="number" maxFractionDigits="0" />
                    <span class="rw-points-unit">điểm</span>
                </div>
            </div>
        </div>
        <p class="rw-points-strip-note">
            Tiêu dùng để nhận điểm. Đổi điểm lấy voucher ngay bên dưới.
        </p>
    </div>

    <%-- ================================================================
         Voucher grid
    ================================================================ --%>
    <h2 class="rw-section-title">
        <span>🏷</span> Voucher khả dụng
    </h2>

    <c:choose>
        <c:when test="${not empty availableRewards}">
            <div class="rw-grid">

                <%--
                    Loop over each active voucher and render it as a coupon tile.
                    JSTL automatically greys out + disables the button if the user
                    does not have enough accumulated points (userPoints < voucher.pointCost).
                --%>
                <c:forEach var="v" items="${availableRewards}">

                    <%-- Determine whether the user can afford this voucher --%>
                    <c:set var="canAfford" value="${userPoints >= v.pointCost}" />

                    <div class="rw-card ${canAfford ? '' : 'rw-card--disabled'}"
                         id="reward-card-${v.voucherId}">

                        <%-- Top coloured stripe --%>
                        <div class="rw-card-stripe"></div>

                        <%-- "Không đủ điểm" badge overlay --%>
                        <c:if test="${not canAfford}">
                            <span class="rw-insufficient-tag">Không đủ điểm</span>
                        </c:if>

                        <%-- Card body: discount badge + title + meta --%>
                        <div class="rw-card-body">

                            <%-- Discount summary badge --%>
                            <div class="rw-discount-badge">
                                🎫&nbsp;<c:out value="${v.discountLabel}" />
                            </div>

                            <%-- Voucher title --%>
                            <h3 class="rw-voucher-title">
                                <c:out value="${v.title}" />
                            </h3>

                            <%-- Meta rows --%>
                            <div class="rw-voucher-meta">

                                <c:if test="${v.minOrderValue != null and v.minOrderValue > 0}">
                                    <div class="rw-voucher-meta-row">
                                        <span class="meta-icon">🛒</span>
                                        <span>
                                            Đơn tối thiểu:
                                            <strong>
                                                <fmt:formatNumber value="${v.minOrderValue}"
                                                                  type="number" maxFractionDigits="0" />&nbsp;₫
                                            </strong>
                                        </span>
                                    </div>
                                </c:if>

                                <c:if test="${v.endDate != null}">
                                    <div class="rw-voucher-meta-row">
                                        <span class="meta-icon">📅</span>
                                        <span>
                                            Hết hạn:
                                            <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy" />
                                        </span>
                                    </div>
                                </c:if>

                                <div class="rw-voucher-meta-row">
                                    <span class="meta-icon">🔖</span>
                                    <span>Mã: <strong><c:out value="${v.voucherCode}" /></strong></span>
                                </div>

                            </div>
                        </div><%-- /rw-card-body --%>

                        <%-- Dashed coupon-style divider --%>
                        <hr class="rw-card-divider">

                        <%-- Card footer: cost + redeem button --%>
                        <div class="rw-card-footer">

                            <div class="rw-card-cost">
                                <span class="rw-cost-label">Chi phí đổi thưởng</span>
                                <span class="rw-cost-value">
                                    <fmt:formatNumber value="${v.pointCost}"
                                                      type="number" maxFractionDigits="0" />
                                    <span class="cost-unit">điểm</span>
                                </span>
                            </div>

                            <%--
                                Redeem button logic:
                                  • canAfford = true  → enabled POST form submit
                                  • canAfford = false → disabled button, no action
                            --%>
                            <c:choose>
                                <c:when test="${canAfford}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/rewards"
                                          id="redeemForm-${v.voucherId}"
                                          onsubmit="return confirmRedeem(${v.voucherId}, ${v.pointCost})">
                                        <input type="hidden" name="voucherId" value="${v.voucherId}">
                                        <button type="submit"
                                                class="rw-redeem-btn"
                                                id="redeem-btn-${v.voucherId}"
                                                title="Đổi bằng ${v.pointCost} điểm">
                                            ✨ Đổi bằng
                                            <fmt:formatNumber value="${v.pointCost}"
                                                              type="number" maxFractionDigits="0" />
                                            Điểm
                                        </button>
                                    </form>
                                </c:when>

                                <c:otherwise>
                                    <button type="button"
                                            class="rw-redeem-btn rw-redeem-btn--disabled"
                                            disabled
                                            title="Bạn cần thêm ${v.pointCost - userPoints} điểm nữa">
                                        Cần thêm
                                        <fmt:formatNumber value="${v.pointCost - userPoints}"
                                                          type="number" maxFractionDigits="0" />
                                        điểm
                                    </button>
                                </c:otherwise>
                            </c:choose>

                        </div><%-- /rw-card-footer --%>

                    </div><%-- /rw-card --%>

                </c:forEach>

            </div><%-- /rw-grid --%>
        </c:when>

        <%-- Empty state --%>
        <c:otherwise>
            <div class="rw-empty-state">
                <span class="empty-icon">🎫</span>
                <p>Hiện chưa có phần thưởng nào khả dụng. Hãy quay lại sau nhé!</p>
            </div>
        </c:otherwise>
    </c:choose>

</main>

<jsp:include page="../common/footer.jsp" />
<jsp:include page="../common/scripts.jsp" />

<script>
    /**
     * Confirm dialog before submitting a redemption form.
     * Returns false to cancel, true to allow form submission.
     */
    function confirmRedeem(voucherId, pointCost) {
        const formatter = new Intl.NumberFormat('vi-VN');
        return window.confirm(
            'Xác nhận đổi thưởng?\n\n' +
            'Bạn sẽ tiêu ' + formatter.format(pointCost) + ' điểm để nhận voucher này.\n' +
            'Hành động này không thể hoàn tác.'
        );
    }
</script>

</body>
</html>
