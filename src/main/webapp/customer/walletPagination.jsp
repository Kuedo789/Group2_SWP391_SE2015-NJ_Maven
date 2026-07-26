<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Shared pagination for the voucher wallet on /membership. --%>
<c:if test="${walletTotalPages != null && walletTotalPages > 1}">
    <div class="pagination-area">
        <span class="pagination-text">
            Trang số <b><c:out value="${walletCurrentPage}" /></b>
            trên tổng số <b><c:out value="${walletTotalPages}" /></b> trang
        </span>

        <ul class="pagination-nav">
            <c:if test="${walletCurrentPage > 1}">
                <li class="page-num-item">
                    <a href="#"
                       onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${walletCurrentPage - 1}); return false;"
                       aria-label="Trang trước">
                        <i class="fa-solid fa-chevron-left" aria-hidden="true"></i>
                    </a>
                </li>
            </c:if>

            <c:forEach begin="1" end="${walletTotalPages}" var="pageNumber">
                <li class="page-num-item ${walletCurrentPage == pageNumber ? 'active' : ''}">
                    <a href="#"
                       onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${pageNumber}); return false;">
                        <c:out value="${pageNumber}" />
                    </a>
                </li>
            </c:forEach>

            <c:if test="${walletCurrentPage < walletTotalPages}">
                <li class="page-num-item">
                    <a href="#"
                       onclick="fetchWallet(currentScope, document.getElementById('wallet-search-input').value, ${walletCurrentPage + 1}); return false;"
                       aria-label="Trang sau">
                        <i class="fa-solid fa-chevron-right" aria-hidden="true"></i>
                    </a>
                </li>
            </c:if>
        </ul>
    </div>
</c:if>
