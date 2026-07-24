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

            /* ── Voucher wallet filter pills (mirrors admin voucher page style) ── */
            .wallet-filter-bar {
                display: flex;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
                margin: 18px 0 14px;
                padding-bottom: 16px;
                border-bottom: 1px solid var(--border, #eee5dc);
            }
            .pill-tab {
                padding: 7px 18px;
                border-radius: 50px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                border: 1.5px solid var(--border, #eee5dc);
                color: var(--text, #241d18);
                background: #fff;
                transition: background 0.18s, color 0.18s, border-color 0.18s;
                white-space: nowrap;
            }
            .pill-tab:hover  { background: #f8f6f4; }
            .pill-tab.active { background: var(--primary, #345f3d); color: #fff; border-color: var(--primary, #345f3d); }

            /* ── Wallet search bar ─────────────────────────────────────────── */
            .wallet-search-form {
                display: flex;
                gap: 8px;
                align-items: center;
                margin-left: auto;       /* push to the right of the pills */
                flex-shrink: 0;
            }
            .wallet-search-input {
                padding: 7px 14px;
                border: 1.5px solid var(--border, #eee5dc);
                border-radius: 50px;
                font-size: 13px;
                outline: none;
                background: #fff;
                color: var(--text, #241d18);
                width: 210px;
                transition: border-color 0.18s;
            }
            .wallet-search-input:focus { border-color: var(--primary, #345f3d); }
            .wallet-search-btn {
                padding: 7px 16px;
                border-radius: 50px;
                font-size: 13px;
                font-weight: 600;
                border: none;
                background: var(--primary, #345f3d);
                color: #fff;
                cursor: pointer;
                transition: opacity 0.18s;
            }
            .wallet-search-btn:hover { opacity: 0.88; }
            .wallet-clear-link {
                font-size: 12px;
                color: var(--text-muted, #756b64);
                text-decoration: none;
                white-space: nowrap;
            }
            .wallet-clear-link:hover { text-decoration: underline; }

            /* ── Wallet loading spinner ───────────────────────────────────────── */
            #wallet-list-area {
                min-height: 80px;
                position: relative;
                transition: opacity 0.18s;
            }
            #wallet-list-area.wallet-loading {
                opacity: 0.45;
                pointer-events: none;
            }
            .wallet-spinner {
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 40px 0;
            }
            .wallet-spinner::after {
                content: '';
                width: 32px; height: 32px;
                border: 3px solid var(--border, #eee5dc);
                border-top-color: var(--primary, #345f3d);
                border-radius: 50%;
                animation: wallet-spin 0.7s linear infinite;
            }
            @keyframes wallet-spin { to { transform: rotate(360deg); } }

            /* Pagination styling reused from /admin/reviews. */
            .pagination-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 16px;
                margin-top: 20px;
                padding: 20px 0 0;
                border-top: 1px solid var(--border, #eee5dc);
                background-color: #fff;
            }
            .pagination-text {
                color: var(--text-muted, #756b64);
                font-size: 13px;
            }
            .pagination-nav {
                display: flex;
                gap: 5px;
                margin: 0;
                padding: 0;
                list-style: none;
            }
            .page-num-item a {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: 6px;
                border: 1px solid var(--border, #eee5dc);
                font-size: 13px;
                font-weight: 600;
                color: #555;
                text-decoration: none;
            }
            .page-num-item a:hover {
                border-color: var(--primary, #345f3d);
                color: var(--primary, #345f3d);
            }
            .page-num-item.active a {
                background-color: var(--primary, #345f3d);
                border-color: var(--primary, #345f3d);
                color: #fff;
            }
            @media (max-width: 600px) {
                .pagination-area {
                    align-items: flex-start;
                    flex-direction: column;
                }
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
                                        </tr>
                                    </c:forEach>

                                    <%-- Empty state if allTiers is unexpectedly empty --%>
                                    <c:if test="${empty allTiers}">
                                        <tr>
                                            <td colspan="3" class="ms-empty-state">
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

                    <%-- ── Wallet filter pills + search bar ── --%>
                    <div class="wallet-filter-bar">

                        <%-- Tất cả --%>
                        <button type="button" id="pill-all"
                                class="pill-tab ${walletScope == 'all' ? 'active' : ''}"
                                onclick="fetchWallet('all', document.getElementById('wallet-search-input').value)">
                            Tất cả
                        </button>

                        <%-- Toàn đơn --%>
                        <button type="button" id="pill-ORDER"
                                class="pill-tab ${walletScope == 'ORDER' ? 'active' : ''}"
                                onclick="fetchWallet('ORDER', document.getElementById('wallet-search-input').value)">
                            Toàn đơn
                        </button>

                        <%-- Freeship --%>
                        <button type="button" id="pill-SHIPPING"
                                class="pill-tab ${walletScope == 'SHIPPING' ? 'active' : ''}"
                                onclick="fetchWallet('SHIPPING', document.getElementById('wallet-search-input').value)">
                            Freeship
                        </button>

                        <%-- Search form: submit is intercepted by JS – no page reload --%>
                        <form id="wallet-search-form" class="wallet-search-form"
                              onsubmit="return false;">
                            <input type="text" id="wallet-search-input"
                                   class="wallet-search-input"
                                   value="${walletSearch}"
                                   placeholder="Tìm mã hoặc tên voucher..."
                                   oninput="onWalletSearchInput(this.value)">
                            <button type="button" class="wallet-search-btn"
                                    onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value)">
                                <i class="fa-solid fa-magnifying-glass"></i>
                            </button>
                            <%-- Clear button: shown/hidden by JS --%>
                            <a href="#" id="wallet-clear-btn"
                               class="wallet-clear-link"
                               style="${not empty walletSearch ? '' : 'display:none;'}"
                               onclick="clearWalletSearch(); return false;">
                                <i class="fa-solid fa-xmark"></i> Xóa
                            </a>
                        </form>

                    </div><%-- /wallet-filter-bar --%>

                    <%-- The voucher list is replaced in-place by AJAX without a full reload --%>
                    <div id="wallet-list-area">
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
                                <c:choose>
                                    <c:when test="${not empty walletSearch}">
                                        <p>Không tìm thấy voucher khớp với từ khóa “${walletSearch}”.</p>
                                    </c:when>
                                    <c:when test="${walletScope == 'ORDER'}">
                                        <p>Bạn chưa có voucher toàn đơn nào.</p>
                                    </c:when>
                                    <c:when test="${walletScope == 'SHIPPING'}">
                                        <p>Bạn chưa có voucher freeship nào.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p>Bạn chưa đổi voucher nào.</p>
                                    </c:otherwise>
                                </c:choose>
                                <p class="ms-wallet-empty-sub">
                                    Hãy dùng điểm để đổi thưởng ngay!
                                    <a href="${pageContext.request.contextPath}/rewards">Đổi ngay →</a>
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <jsp:include page="walletPagination.jsp" />
                    </div><%-- /wallet-list-area --%>

                </div><%-- /ms-wallet-card --%>

            </c:if><%-- /c:if membership not empty --%>

        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script>
            /* ================================================================
             *  Wallet AJAX filter/search
             *  Replaces #wallet-list-area content without reloading the page.
             * ================================================================ */

            // Server-rendered initial state baked in on first load
            var currentScope  = '${walletScope}';
            var searchDebounceTimer = null;

            /**
             * Fetches the wallet fragment from the server via AJAX and injects
             * it into #wallet-list-area.
             *
             * @param {string} scope   - 'all' | 'ORDER' | 'SHIPPING'
             * @param {string} keyword - current search term (may be empty)
             */
            function fetchWallet(scope, keyword, page) {
                if (!scope) scope = 'all';
                if (!keyword) keyword = '';
                if (!page || page < 1) page = 1;

                currentScope = scope;

                var listArea = document.getElementById('wallet-list-area');
                var clearBtn = document.getElementById('wallet-clear-btn');

                // Highlight active pill
                document.querySelectorAll('.pill-tab').forEach(function(btn) {
                    var pillId = btn.id.replace('pill-', '');
                    btn.classList.toggle('active', pillId === scope);
                    btn.disabled = true;   // briefly disable all pills during fetch
                });

                // Show/hide the clear button based on whether there is a keyword
                if (clearBtn) {
                    clearBtn.style.display = keyword.trim() ? '' : 'none';
                }

                // Dim the list area (opacity fade acts as a lightweight loading cue)
                listArea.classList.add('wallet-loading');

                // Build URL
                var url = '${pageContext.request.contextPath}/membership'
                        + '?scope=' + encodeURIComponent(scope)
                        + '&search=' + encodeURIComponent(keyword.trim())
                        + '&page=' + encodeURIComponent(page);

                fetch(url, {
                    method: 'GET',
                    headers: { 'X-Requested-With': 'XMLHttpRequest' }
                })
                .then(function(res) {
                    if (!res.ok) throw new Error('Network response was not ok');
                    return res.text();
                })
                .then(function(html) {
                    listArea.innerHTML = html;
                    listArea.classList.remove('wallet-loading');
                    // Re-enable all pills
                    document.querySelectorAll('.pill-tab').forEach(function(btn) {
                        btn.disabled = false;
                    });
                })
                .catch(function(err) {
                    console.error('Wallet fetch failed:', err);
                    listArea.classList.remove('wallet-loading');
                    document.querySelectorAll('.pill-tab').forEach(function(btn) {
                        btn.disabled = false;
                    });
                });
            }

            /**
             * Debounced handler for the search input.
             * Waits 380ms after the user stops typing before firing the request.
             */
            function onWalletSearchInput(value) {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(function() {
                    fetchWallet(currentScope, value);
                }, 380);

                // Show/hide the clear button in real time
                var clearBtn = document.getElementById('wallet-clear-btn');
                if (clearBtn) clearBtn.style.display = value.trim() ? '' : 'none';
            }

            /**
             * Clears the search input and reloads the wallet with the current scope.
             */
            function clearWalletSearch() {
                var input = document.getElementById('wallet-search-input');
                if (input) { input.value = ''; input.focus(); }
                fetchWallet(currentScope, '');
            }

            /* ================================================================
             *  Copy-to-clipboard helper (unchanged behaviour)
             * ================================================================ */
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
