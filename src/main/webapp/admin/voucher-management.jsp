<%--
    Document   : voucher-management
    Created on : Jul 9, 2026
    Author     : thais / antigravity
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin – Quản lý Voucher" />
        </jsp:include>
        <style>
            /* ── Metric cards ───────────────────────────────────────────── */
            .stat-cards {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 20px;
                margin-bottom: 28px;
            }

            .stat-card {
                background: var(--surface-white);
                border: 1px solid var(--border-soft);
                border-radius: 16px;
                padding: 24px 28px;
                display: flex;
                align-items: center;
                gap: 18px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.04);
                transition: transform 0.2s, box-shadow 0.2s;
            }
            .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 24px rgba(0,0,0,0.08); }

            .stat-icon {
                width: 52px;
                height: 52px;
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 22px;
                flex-shrink: 0;
            }
            .stat-icon.green  { background: #dcfce7; color: #16a34a; }
            .stat-icon.blue   { background: #dbeafe; color: #2563eb; }
            .stat-icon.orange { background: #ffedd5; color: #ea580c; }

            .stat-label  { font-size: 13px; color: var(--text-muted); font-weight: 500; margin-bottom: 4px; }
            .stat-value  { font-size: 28px; font-weight: 700; color: var(--text-dark); }

            /* ── Status pill tabs ────────────────────────────────────────── */
            .pill-tabs {
                display: flex;
                gap: 8px;
                margin-bottom: 20px;
                flex-wrap: wrap;
            }
            .pill-tab {
                padding: 7px 18px;
                border-radius: 50px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                border: 1.5px solid var(--border-soft);
                color: var(--text-dark);
                background: var(--surface-white);
                transition: all 0.2s;
            }
            .pill-tab:hover  { background: #f1f5f9; }
            .pill-tab.active { background: var(--primary-green, #22c55e); color: #fff; border-color: var(--primary-green, #22c55e); }

            /* ── Badge colours ───────────────────────────────────────────── */
            .badge-active   { background: #dcfce7; color: #15803d; }
            .badge-expired  { background: #f1f5f9; color: #64748b; }
            .badge-inactive { background: #ffedd5; color: #c2410c; }

            /* ── Discount type chips ─────────────────────────────────────── */
            .chip-percent { background: #dbeafe; color: #1d4ed8; }
            .chip-fixed   { background: #fef9c3; color: #854d0e; }

            /* ── Filter tabs container ───────────────────────────────────── */
            .filter-tabs-container {
                display: flex;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
                margin: 20px 0 16px;
                padding-bottom: 16px;
                border-bottom: 1px solid var(--border-soft);
            }

            /* Pagination Design */
            .pagination-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px 25px;
                border-top: 1px solid var(--border-soft);
                background-color: #fff;
            }
            .pagination-text {
                font-size: 13px;
                color: var(--text-muted);
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
                border: 1px solid var(--border-soft);
                font-size: 13px;
                font-weight: 600;
                color: #555;
                text-decoration: none;
                transition: all 0.2s;
            }
            .page-num-item a:hover {
                background-color: #fafafa;
                border-color: #ccc;
            }
            .page-num-item.active a {
                background-color: var(--primary-green, #22c55e);
                border-color: var(--primary-green, #22c55e);
                color: #fff;
            }
            .page-num-item.disabled a {
                opacity: 0.5;
                pointer-events: none;
                background-color: #f8f6f4;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="vouchers" />
        </jsp:include>

        <div class="main-panel">

            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu"  value="Khuyến mãi" />
                <jsp:param name="activeMenu"  value="Quản lý Voucher" />
            </jsp:include>

            <div class="content">

                <!-- ── Page Header ───────────────────────────────────────── -->
                <div class="page-header">
                    <div class="page-title">
                        <h2>Quản lý Voucher</h2>
                        <p>Tạo, theo dõi và quản lý toàn bộ mã giảm giá của cửa hàng.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/vouchers?action=add"
                       class="btn-primary" style="text-decoration: none;">
                        <i class="fa-solid fa-plus"></i> Thêm Voucher mới
                    </a>
                </div>

                <!-- ── Flash messages ─────────────────────────────────────── -->
                <c:if test="${not empty success}">
                    <div style="background:#dcfce7;color:#166534;padding:12px 20px;border-radius:8px;margin-bottom:20px;border:1px solid #bbf7d0;">
                        <i class="fa-solid fa-circle-check"></i>
                        <c:choose>
                            <c:when test="${success == 'created'}">Voucher mới đã được tạo thành công!</c:when>
                            <c:when test="${success == 'deleted'}">Voucher đã bị xóa thành công.</c:when>
                            <c:when test="${success == 'deactivated'}">Voucher đã được vô hiệu hóa</c:when>
                            <c:when test="${success == 'activated'}">Voucher đã được kích hoạt lại.</c:when>
                            <c:otherwise>Thao tác thành công!</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <c:if test="${not empty error}">
                    <div style="background:#fee2e2;color:#991b1b;padding:12px 20px;border-radius:8px;margin-bottom:20px;border:1px solid #fecaca;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <strong>Lỗi:</strong>
                        <c:choose>
                            <c:when test="${error == 'delete_failed'}">Không thể xóa voucher này. Có thể đã được gán cho người dùng.</c:when>
                            <c:when test="${error == 'toggle_failed'}">Không thể cập nhật trạng thái voucher. Vui lòng thử lại.</c:when>
                            <c:when test="${error == 'invalid_id'}">ID voucher không hợp lệ.</c:when>
                            <c:otherwise>Đã xảy ra lỗi. Vui lòng thử lại.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <!-- ── Metric Cards ───────────────────────────────────────── -->
                <div class="stat-cards">
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fa-solid fa-ticket"></i></div>
                        <div>
                            <div class="stat-label">Tổng số voucher</div>
                            <div class="stat-value">${totalVouchers != null ? totalVouchers : 0}</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon green"><i class="fa-solid fa-circle-check"></i></div>
                        <div>
                            <div class="stat-label">Đang hoạt động</div>
                            <div class="stat-value">${activeVouchers != null ? activeVouchers : 0}</div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fa-solid fa-clock-rotate-left"></i></div>
                        <div>
                            <div class="stat-label">Hết hạn / Vô hiệu</div>
                            <div class="stat-value">${expiredVouchers != null ? expiredVouchers : 0}</div>
                        </div>
                    </div>
                </div>

                <!-- ── Table Card ─────────────────────────────────────────── -->
                <div class="table-card">

                    <!-- Status pill tabs ──────────────────────────────── -->
                    <div class="filter-tabs-container">
                        <a href="${pageContext.request.contextPath}/admin/vouchers?status=all&search=${searchQuery}"
                           class="pill-tab ${statusFilter == 'all' || empty statusFilter ? 'active' : ''}">
                            Tất cả
                            <c:if test="${statusFilter == 'all' || empty statusFilter}">
                                <span style="margin-left:5px;background:rgba(255,255,255,0.3);padding:1px 7px;border-radius:20px;font-size:11px;">${totalRecords}</span>
                            </c:if>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/vouchers?status=ACTIVE&search=${searchQuery}"
                           class="pill-tab ${statusFilter == 'ACTIVE' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:${statusFilter == 'ACTIVE' ? '#fff' : '#16a34a'};"></i>
                            Đang hoạt động
                            <c:if test="${statusFilter == 'ACTIVE'}">
                                <span style="margin-left:5px;background:rgba(255,255,255,0.3);padding:1px 7px;border-radius:20px;font-size:11px;">${totalRecords}</span>
                            </c:if>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/vouchers?status=EXPIRED&search=${searchQuery}"
                           class="pill-tab ${statusFilter == 'EXPIRED' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:${statusFilter == 'EXPIRED' ? '#fff' : '#64748b'};"></i>
                            Hết hạn
                            <c:if test="${statusFilter == 'EXPIRED'}">
                                <span style="margin-left:5px;background:rgba(255,255,255,0.3);padding:1px 7px;border-radius:20px;font-size:11px;">${totalRecords}</span>
                            </c:if>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/vouchers?status=INACTIVE&search=${searchQuery}"
                           class="pill-tab ${statusFilter == 'INACTIVE' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:${statusFilter == 'INACTIVE' ? '#fff' : '#ea580c'};"></i>
                            Vô hiệu hóa
                            <c:if test="${statusFilter == 'INACTIVE'}">
                                <span style="margin-left:5px;background:rgba(255,255,255,0.3);padding:1px 7px;border-radius:20px;font-size:11px;">${totalRecords}</span>
                            </c:if>
                        </a>
                    </div>

                    <!-- Search bar -->
                    <div class="table-controls">
                        <form action="${pageContext.request.contextPath}/admin/vouchers" method="GET"
                              style="display:flex;gap:12px;width:100%;align-items:center;">
                            <input type="hidden" name="status" value="${statusFilter}">
                            <div class="search-bar" style="flex-grow:1;max-width:420px;">
                                <i class="fa-solid fa-magnifying-glass" style="color:#a0a0a0;"></i>
                                <input type="text" name="search" value="${searchQuery}"
                                       placeholder="Tìm theo mã hoặc tên voucher...">
                            </div>
                            <button type="submit" class="btn-primary" style="padding:10px 20px;">Tìm kiếm</button>
                            <c:if test="${not empty searchQuery}">
                                <a href="${pageContext.request.contextPath}/admin/vouchers?status=${statusFilter}"
                                   style="font-size:13px;color:var(--text-muted);text-decoration:none;">
                                    <i class="fa-solid fa-xmark"></i> Xóa lọc
                                </a>
                            </c:if>
                        </form>
                    </div>

                    <!-- Data Table -->
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Mã Voucher</th>
                                <th>Tên / Tiêu đề</th>
                                <th>Loại giảm</th>
                                <th>Giá trị</th>
                                <th>Đơn tối thiểu</th>
                                <th>Ngày hết hạn</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty vouchers}">
                                    <tr>
                                        <td colspan="9" style="text-align:center;padding:40px;color:var(--text-muted);">
                                            <i class="fa-solid fa-ticket" style="font-size:32px;margin-bottom:12px;display:block;opacity:0.3;"></i>
                                            Không tìm thấy voucher nào.
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="v" items="${vouchers}" varStatus="loop">

                                        <tr>
                                            <td style="color:var(--text-muted);font-size:13px;">${loop.index + 1}</td>

                                            <td>
                                                <code style="background:#f1f5f9;padding:3px 8px;border-radius:6px;font-size:12px;font-weight:600;letter-spacing:0.5px;">
                                                    ${v.voucherCode}
                                                </code>
                                            </td>

                                            <td style="max-width:180px;">
                                                <div style="font-weight:600;font-size:14px;">${v.title}</div>
                                                <c:if test="${v.usageLimit > 0}">
                                                    <small style="color:var(--text-muted);">
                                                        <i class="fa-solid fa-users" style="font-size:10px;"></i>
                                                        Giới hạn ${v.usageLimit} lượt
                                                    </small>
                                                </c:if>
                                            </td>

                                            <td>
                                                <c:choose>
                                                    <c:when test="${v.discountType == 'PERCENT'}">
                                                        <span class="badge chip-percent">Phần trăm (%)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge chip-fixed">Giảm tiền mặt</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <td style="font-weight:700;color:var(--text-dark);">
                                                <c:choose>
                                                    <c:when test="${v.discountType == 'PERCENT'}">
                                                        ${v.discountValue}%
                                                        <c:if test="${v.maxDiscountAmount != null}">
                                                            <br><small style="font-weight:400;color:var(--text-muted);">
                                                                Tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" type="number" groupingUsed="true"/>₫
                                                            </small>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${v.discountValue}" type="number" groupingUsed="true"/>₫
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <td>
                                                <c:choose>
                                                    <c:when test="${v.minOrderValue != null && v.minOrderValue > 0}">
                                                        <fmt:formatNumber value="${v.minOrderValue}" type="number" groupingUsed="true"/>₫
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span style="color:var(--text-muted);font-size:12px;">Không giới hạn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <td>
                                                <c:if test="${v.startDate != null}">
                                                    <small style="color:var(--text-muted);">
                                                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy"/>
                                                    </small>
                                                    <br>
                                                </c:if>
                                                <c:if test="${v.endDate != null}">
                                                    <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                                                </c:if>
                                            </td>

                                            <td>
                                                <%-- 
                                                  Use a scriptlet-computed string stored as a request attribute
                                                  because EL cannot call java.sql.Date.before() reliably across all servers.
                                                  We check: active=true and endDate >= today  => ACTIVE
                                                             active=false                     => INACTIVE (vô hiệu)
                                                             endDate < today                  => EXPIRED
                                                --%>
                                                <c:choose>
                                                    <c:when test="${!v.active}">
                                                        <span class="badge badge-inactive">Vô hiệu hóa</span>
                                                    </c:when>
                                                    <c:when test="${v.active}">
                                                        <%-- We use a JSP fragment to compute expiry since EL can't do date math --%>
                                                        <%
                                                            com.bakeryzone.model.Voucher _vTmp =
                                                                (com.bakeryzone.model.Voucher) pageContext.getAttribute("v");
                                                            boolean _expired = false;
                                                            if (_vTmp != null && _vTmp.getEndDate() != null) {
                                                                _expired = _vTmp.getEndDate().before(new java.util.Date());
                                                            }
                                                            pageContext.setAttribute("isExpiredNow", _expired);
                                                        %>
                                                        <c:choose>
                                                            <c:when test="${isExpiredNow}">
                                                                <span class="badge badge-expired">Hết hạn</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-active">Đang hoạt động</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-expired">Hết hạn</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <td class="action-btns">
                                                <%-- Toggle active/inactive --%>
                                                <c:choose>
                                                    <c:when test="${v.active}">
                                                        <a href="${pageContext.request.contextPath}/admin/vouchers?action=toggle&id=${v.voucherId}&active=false"
                                                           class="btn-icon" title="Vô hiệu hóa"
                                                           style="text-decoration:none;color:#f59e0b;">
                                                            <i class="fa-regular fa-eye-slash"></i>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/admin/vouchers?action=toggle&id=${v.voucherId}&active=true"
                                                           class="btn-icon" title="Kích hoạt lại"
                                                           style="text-decoration:none;color:#10b981;">
                                                            <i class="fa-solid fa-rotate-left"></i>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>

                                                <%-- Delete --%>
                                                <a href="${pageContext.request.contextPath}/admin/vouchers?action=delete&id=${v.voucherId}"
                                                   class="btn-icon" title="Xóa voucher"
                                                   style="text-decoration:none;color:#ef4444;">
                                                    <i class="fa-regular fa-trash-can"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>

                    <!-- ── Pagination widget ──────────────────────────── -->
                    <div class="pagination-area">
                        <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang</span>
                        <ul class="pagination-nav">
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/vouchers?action=list&page=${currentPage - 1}&status=${param.status}&search=${param.search}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/vouchers?action=list&page=${i}&status=${param.status}&search=${param.search}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/vouchers?action=list&page=${currentPage + 1}&status=${param.status}&search=${param.search}">
                                        <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>

                </div><!-- end .table-card -->

            </div><!-- end .content -->
        </div><!-- end .main-panel -->

    </body>
</html>
