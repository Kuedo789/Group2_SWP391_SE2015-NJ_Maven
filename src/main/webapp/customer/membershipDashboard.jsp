<%--
    membershipDashboard.jsp
    Membership Dashboard – shows tier status, progress bar, benefits matrix,
    and point-history sub-tab for the logged-in customer.

    Request attributes expected (set by MembershipController):
      • membership   : UserMembership  – current tier + next tier + spending/points
      • allTiers     : List<MembershipTier> – complete tier list, MEMBER → DIAMOND
      • pointHistory : List<PointHistory>   – up to 20 most-recent transactions
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c"   uri="jakarta.tags.core"      %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"        %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="../common/header.jsp" />
        <title>Hạng thành viên – BakeryZone</title>
        <meta name="description"
              content="Xem hạng thành viên, điểm tích lũy, và lịch sử điểm thưởng của bạn tại BakeryZone.">
        <link rel="stylesheet"
              href="${pageContext.request.contextPath}/assets/css/customer/membership.css">
        <style>
            /* Adjust the 90px value up or down depending on your actual header height */
            .membership-page {
                padding-top: 100px !important;
                margin-top: 0 !important;
            }
        </style>
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="membership-page">

            <%-- ================================================================
                 Page heading
            ================================================================ --%>
            <div class="membership-page-header">
                <h1>Hạng thành viên của bạn</h1>
                <p>Theo dõi chi tiêu, điểm thưởng, và quyền lợi theo từng cấp bậc.</p>
            </div>

            <%-- ================================================================
                 Error banner – shown when DAO fails to load data
            ================================================================ --%>
            <c:if test="${not empty membershipError}">
                <div class="membership-alert" role="alert">
                    ⚠ ${membershipError}
                </div>
            </c:if>

            <%-- ================================================================
                 Main content – only rendered when membership data is available
            ================================================================ --%>
            <c:if test="${not empty membership}">

                <%-- PRG success flash (from RewardsController redemption) --%>
                <c:if test="${not empty successMsg}">
                    <div class="membership-alert membership-alert--success" role="alert">
                        ${successMsg}
                    </div>
                </c:if>

                <%-- ============================================================
                     HERO CARD – tier identity + stats + progress bar
                ============================================================ --%>
                <div class="ms-card">

                    <%-- --- Tier badge + name + description ------------------- --%>
                    <div class="ms-hero">

                        <div class="ms-tier-badge tier-${membership.currentTier.tierName}"
                             title="Hạng ${membership.currentTier.tierName}">
                            <%-- Emoji icon per tier --%>
                            <c:choose>
                                <c:when test="${membership.currentTier.tierName eq 'DIAMOND'}">
                                    <span class="badge-icon">💎</span>
                                </c:when>
                                <c:when test="${membership.currentTier.tierName eq 'GOLD'}">
                                    <span class="badge-icon">🥇</span>
                                </c:when>
                                <c:when test="${membership.currentTier.tierName eq 'SILVER'}">
                                    <span class="badge-icon">🥈</span>
                                </c:when>
                                <c:when test="${membership.currentTier.tierName eq 'BRONZE'}">
                                    <span class="badge-icon">🥉</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-icon">🎖</span>
                                </c:otherwise>
                            </c:choose>
                            <span>${membership.currentTier.tierName}</span>
                        </div>

                        <div class="ms-tier-info">
                            <div class="ms-tier-label">Hạng hiện tại</div>

                            <div class="ms-tier-name
                                 tier-${membership.currentTier.tierName eq 'MEMBER'  ? 'MEMBER'  :
                                        membership.currentTier.tierName eq 'BRONZE'  ? 'BRONZE'  :
                                        membership.currentTier.tierName eq 'SILVER'  ? 'SILVER'  :
                                        membership.currentTier.tierName eq 'GOLD'    ? 'GOLD'    : 'DIAMOND'}">
                                 <c:out value="${membership.currentTier.tierName}" />
                            </div>

                            <c:if test="${not empty membership.currentTier.description}">
                                <p class="ms-tier-desc">${membership.currentTier.description}</p>
                            </c:if>
                        </div>
                    </div>

                    <%-- --- Key stats pills ----------------------------------- --%>
                    <div class="ms-stat-row">
                        <div class="ms-stat-pill">
                            <span class="stat-icon">💰</span>
                            <div>
                                <div class="stat-value">
                                    <fmt:formatNumber value="${membership.totalSpending}"
                                                      type="number" maxFractionDigits="0" />&nbsp;₫
                                </div>
                                <div class="stat-label">Tổng chi tiêu</div>
                            </div>
                        </div>

                        <div class="ms-stat-pill">
                            <span class="stat-icon">⭐</span>
                            <div>
                                <div class="stat-value">
                                    <fmt:formatNumber value="${membership.accumulatedPoints}"
                                                      type="number" maxFractionDigits="0" />
                                </div>
                                <div class="stat-label">Điểm tích lũy</div>
                            </div>
                        </div>

                        <div class="ms-stat-pill">
                            <span class="stat-icon">✖</span>
                            <div>
                                <div class="stat-value">
                                    x${membership.currentTier.pointMultiplier}
                                </div>
                                <div class="stat-label">Hệ số điểm</div>
                            </div>
                        </div>

                        <div class="ms-stat-pill">
                            <span class="stat-icon">🎟</span>
                            <div>
                                <div class="stat-value">
                                    ${membership.currentTier.monthlyVouchers}
                                </div>
                                <div class="stat-label">Voucher / tháng</div>
                            </div>
                        </div>
                    </div>

                    <%-- --- "Đổi thưởng ngay" CTA ----------------------------- --%>
                    <div class="ms-redeem-cta">
                        <a href="${pageContext.request.contextPath}/rewards"
                           class="ms-redeem-btn"
                           title="Đổi điểm thưởng lấy voucher">
                            Đổi thưởng ngay
                        </a>
                    </div>

                    <%-- --- Progress bar toward next tier --------------------- --%>
                    <div class="ms-progress-section">

                        <c:choose>
                            <%-- User IS at the maximum tier --%>
                            <c:when test="${empty membership.nextTier}">
                                <div class="ms-max-tier-msg">
                                    🏆 Bạn đang ở hạng cao nhất – DIAMOND! Cảm ơn vì sự trung thành của bạn.
                                </div>
                            </c:when>

                            <%-- Normal progress toward the next tier --%>
                            <c:otherwise>
                                <div class="ms-progress-header">
                                    <span class="ms-progress-title">
                                        Tiến độ lên hạng
                                        <span class="tier-chip chip-${membership.nextTier.tierName}">
                                            ${membership.nextTier.tierName}
                                        </span>
                                    </span>
                                    <span class="ms-progress-meta">
                                        <strong>
                                            <fmt:formatNumber value="${membership.totalSpending}"
                                                              type="number" maxFractionDigits="0" />&nbsp;₫
                                        </strong>
                                        /
                                        <fmt:formatNumber value="${membership.nextTier.minSpending}"
                                                          type="number" maxFractionDigits="0" />&nbsp;₫
                                    </span>
                                </div>

                                <%-- Progress track --%>
                                <div class="ms-progress-track"
                                     role="progressbar"
                                     aria-valuenow="${membership.totalSpending}"
                                     aria-valuemax="${membership.nextTier.minSpending}"
                                     aria-label="Tiến độ lên hạng ${membership.nextTier.tierName}">
                                    <%--
                                        Dynamic width formula (as specified in the requirement):
                                            (userSpending / nextMilestone) * 100
                                        Clamped server-side by UserMembership.getProgressPercent()
                                        but also bounded by max-width: 100% in CSS.
                                    --%>
                                    <div class="ms-progress-fill"
                                         style="width: ${(membership.totalSpending / membership.nextTier.minSpending) * 100}%">
                                    </div>
                                </div>

                                <div class="ms-progress-labels">
                                    <span>${membership.currentTier.tierName}</span>
                                    <span>${membership.nextTier.tierName}</span>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div><%-- /ms-progress-section --%>

                </div><%-- /ms-card hero --%>

                <%-- ============================================================
                     BOTTOM GRID: Benefits matrix  |  Point history
                ============================================================ --%>
                <div class="ms-bottom-grid">

                    <%-- --------------------------------------------------------
                         LEFT – Tier benefits matrix (all tiers)
                    -------------------------------------------------------- --%>
                    <div class="ms-card">
                        <h2 class="ms-section-title">
                            <span class="title-icon">📊</span>
                            Quyền lợi theo hạng
                        </h2>

                        <div class="ms-benefits-table-wrap">
                            <table class="ms-benefits-table">
                                <thead>
                                    <tr>
                                        <th>Hạng</th>
                                        <th>Chi tiêu tối thiểu</th>
                                        <th>Hệ số điểm</th>
                                        <th>Voucher / tháng</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%--
                                        Placeholder loop over allTiers list.
                                        Highlights the row matching the user's current tier.
                                    --%>
                                    <c:forEach var="tier" items="${allTiers}">
                                        <tr class="${tier.tierId eq membership.currentTierId ? 'active-tier-row' : ''}">
                                            <td>
                                                <span class="tier-chip chip-${tier.tierName}">
                                                    ${tier.tierName}
                                                </span>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${tier.minSpending}"
                                                                  type="number" maxFractionDigits="0" />&nbsp;₫
                                            </td>
                                            <td>x${tier.pointMultiplier}</td>
                                            <td>${tier.monthlyVouchers}</td>
                                        </tr>
                                    </c:forEach>

                                    <%-- Empty state if allTiers is unexpectedly empty --%>
                                    <c:if test="${empty allTiers}">
                                        <tr>
                                            <td colspan="4" class="ms-empty-state">
                                                Không có dữ liệu hạng thành viên.
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div><%-- /benefits card --%>

                    <%-- --------------------------------------------------------
                         RIGHT – Lịch sử điểm (point history feed)
                    -------------------------------------------------------- --%>
                    <div class="ms-card">
                        <h2 class="ms-section-title">
                            <span class="title-icon">🕒</span>
                            Lịch sử điểm
                        </h2>

                        <c:choose>
                            <c:when test="${not empty pointHistory}">
                                <div class="ms-point-list" role="list">
                                    <%--
                                        Placeholder loop over pointHistory list.
                                        Each entry shows: type icon, description, date, ±amount.
                                    --%>
                                    <c:forEach var="ph" items="${pointHistory}">
                                        <div class="ms-point-entry" role="listitem">

                                            <%-- Type dot with EARN / REDEEM / EXPIRE / ADJUST colour --%>
                                            <div class="point-type-dot dot-${ph.changeType}">
                                                <c:choose>
                                                    <c:when test="${ph.changeType eq 'EARN'}">+</c:when>
                                                    <c:when test="${ph.changeType eq 'REDEEM'}">−</c:when>
                                                    <c:when test="${ph.changeType eq 'EXPIRE'}">✕</c:when>
                                                    <c:otherwise>~</c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="point-entry-body">
                                                <div class="point-entry-desc" title="${ph.description}">
                                                    <c:out value="${not empty ph.description ? ph.description : ph.changeType}" />
                                                </div>
                                                <div class="point-entry-date">
                                                    <fmt:formatDate value="${ph.createdAt}"
                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                </div>
                                            </div>

                                            <%-- Amount: prefix + / - based on type --%>
                                            <div class="point-entry-amount
                                                 <c:choose>
                                                     <c:when test="${ph.changeType eq 'EARN'}">amount-earn</c:when>
                                                     <c:when test="${ph.changeType eq 'REDEEM'}">amount-redeem</c:when>
                                                     <c:when test="${ph.changeType eq 'EXPIRE'}">amount-expire</c:when>
                                                     <c:otherwise>amount-adjust</c:otherwise>
                                                 </c:choose>">
                                                <c:choose>
                                                    <c:when test="${ph.changeType eq 'EARN'}">
                                                        +<fmt:formatNumber value="${ph.amount}" type="number" />
                                                    </c:when>
                                                    <c:when test="${ph.changeType eq 'REDEEM' or ph.changeType eq 'EXPIRE'}">
                                                        −<fmt:formatNumber value="${ph.amount}" type="number" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${ph.amount}" type="number" />
                                                    </c:otherwise>
                                                </c:choose>
                                                &nbsp;đ
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>

                            <c:otherwise>
                                <div class="ms-empty-state">
                                    <span class="empty-icon">📭</span>
                                    Bạn chưa có giao dịch điểm nào.
                                </div>
                            </c:otherwise>
                        </c:choose>

                    </div><%-- /point history card --%>

                </div><%-- /ms-bottom-grid --%>

                <%-- ============================================================
                     VOUCHER WALLET – "Kho Voucher của bạn"
                     Shows all un-used, active, in-date vouchers the user has
                     claimed through the rewards exchange.
                ============================================================ --%>
                <div class="ms-card ms-wallet-card">

                    <div class="ms-wallet-header">
                        <h2 class="ms-section-title" style="margin:0;">
                            <span class="title-icon">🎟</span>
                            Kho Voucher của bạn
                        </h2>
                        <a href="${pageContext.request.contextPath}/rewards"
                           class="ms-wallet-link">
                            + Đổi thêm voucher
                        </a>
                    </div>

                    <c:choose>
                        <c:when test="${not empty ownedVouchers}">

                            <div class="ms-wallet-grid">
                                <c:forEach var="uv" items="${ownedVouchers}">
                                    <div class="ms-ticket">

                                        <%-- Left coloured ear --%>
                                        <div class="ms-ticket-ear ms-ticket-ear--left"></div>

                                        <%-- Main ticket body --%>
                                        <div class="ms-ticket-body">

                                            <%-- Discount badge --%>
                                            <div class="ms-ticket-discount">
                                                <c:out value="${uv.discountLabel}" />
                                            </div>

                                            <%-- Title --%>
                                            <div class="ms-ticket-title">
                                                <c:out value="${uv.title}" />
                                            </div>

                                            <%-- Meta: min order --%>
                                            <c:if test="${uv.minOrderValue != null and uv.minOrderValue > 0}">
                                                <div class="ms-ticket-meta">
                                                    🛒 Đơn tối thiểu:
                                                    <fmt:formatNumber value="${uv.minOrderValue}"
                                                                      type="number" maxFractionDigits="0" />&nbsp;₫
                                                </div>
                                            </c:if>

                                            <%-- Expiry --%>
                                            <c:if test="${uv.endDate != null}">
                                                <div class="ms-ticket-meta">
                                                    📅 HSD:
                                                    <fmt:formatDate value="${uv.endDate}" pattern="dd/MM/yyyy" />
                                                </div>
                                            </c:if>
                                        </div>

                                        <%-- Dashed tear-line --%>
                                        <div class="ms-ticket-tear"></div>

                                        <%-- Code stub --%>
                                        <div class="ms-ticket-stub">
                                            <div class="ms-ticket-code-label">Mã voucher</div>
                                            <div class="ms-ticket-code"
                                                 id="vc-${uv.voucherId}"
                                                 title="Nhấn để sao chép"
                                                 onclick="copyCode('${uv.voucherCode}', 'vc-${uv.voucherId}')">
                                                <c:out value="${uv.voucherCode}" />
                                                <span class="ms-copy-icon">📋</span>
                                            </div>
                                        </div>

                                        <%-- Right coloured ear --%>
                                        <div class="ms-ticket-ear ms-ticket-ear--right"></div>

                                    </div><%-- /ms-ticket --%>
                                </c:forEach>
                            </div><%-- /ms-wallet-grid --%>

                        </c:when>

                        <c:otherwise>
                            <div class="ms-wallet-empty">
                                <span class="ms-wallet-empty-icon">🎫</span>
                                <p>Bạn chưa đổi voucher nào.</p>
                                <p class="ms-wallet-empty-sub">
                                    Hãy dùng điểm để đổi thưởng ngay!
                                    <a href="${pageContext.request.contextPath}/rewards">Đổi ngay →</a>
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </div><%-- /ms-wallet-card --%>

            </c:if><%-- /c:if membership not empty --%>

        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script>
            /**
             * Copies the voucher code to the clipboard and gives the user a
             * brief visual "Đã sao chép!" confirmation on the badge element.
             */
            function copyCode(code, elementId) {
                navigator.clipboard.writeText(code).then(function () {
                    var el = document.getElementById(elementId);
                    if (!el) return;
                    var original = el.innerHTML;
                    el.innerHTML = '✅ Đã sao chép!';
                    el.style.background = '#d4edda';
                    el.style.color = '#1e4620';
                    setTimeout(function () {
                        el.innerHTML = original;
                        el.style.background = '';
                        el.style.color = '';
                    }, 1800);
                }).catch(function () {
                    // Fallback for older browsers
                    var ta = document.createElement('textarea');
                    ta.value = code;
                    ta.style.position = 'fixed';
                    ta.style.opacity = '0';
                    document.body.appendChild(ta);
                    ta.select();
                    document.execCommand('copy');
                    document.body.removeChild(ta);
                });
            }
        </script>

    </body>
</html>
