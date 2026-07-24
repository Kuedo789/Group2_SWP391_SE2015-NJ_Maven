<%--
    walletFragment.jsp
    Partial fragment: renders ONLY the wallet voucher grid (or empty state).
    Returned by MembershipController when it detects an AJAX request
    (X-Requested-With: XMLHttpRequest header).

    Request attributes expected:
      • ownedVouchers : List<Voucher>
      • walletScope   : String  – "all" | "ORDER" | "SHIPPING"
      • walletSearch  : String  – keyword, may be empty
--%>
<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c"   uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt"  %>

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

        <%-- Pagination for Wallet (Ajax) --%>
        <c:if test="${walletTotalPages != null && walletTotalPages > 1}">
            <div class="pagination-area" style="margin-top: 20px;">
                <span class="pagination-text">
                    Trang số <b>${walletCurrentPage}</b> trên tổng số <b>${walletTotalPages}</b> trang
                </span>
                <ul class="pagination-nav">
                    <c:if test="${walletCurrentPage > 1}">
                        <li class="page-num-item">
                            <a href="#" onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${walletCurrentPage - 1}); return false;" aria-label="Trang trước">
                                <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                            </a>
                        </li>
                    </c:if>

                    <c:forEach begin="1" end="${walletTotalPages}" var="i">
                        <li class="page-num-item ${walletCurrentPage == i ? 'active' : ''}">
                            <a href="#" onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${i}); return false;">${i}</a>
                        </li>
                    </c:forEach>

                    <c:if test="${walletCurrentPage < walletTotalPages}">
                        <li class="page-num-item">
                            <a href="#" onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${walletCurrentPage + 1}); return false;" aria-label="Trang sau">
                                <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                            </a>
                        </li>
                    </c:if>
                </ul>
            </div>
        </c:if>
    </c:when>

    <c:otherwise>
        <div class="ms-wallet-empty">
            <span class="ms-wallet-empty-icon">🎫</span>
            <c:choose>
                <c:when test="${not empty walletSearch}">
                    <p>Không tìm thấy voucher khớp với từ khóa "<c:out value="${walletSearch}"/>".</p>
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
