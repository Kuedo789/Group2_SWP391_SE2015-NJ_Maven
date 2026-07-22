<%--
    Document   : membership-overview
    Created on : Jul 22, 2026
    Author     : thais / antigravity
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"  prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin – Hạng Thành Viên" />
        </jsp:include>
        <style>
            /* ── Metric cards ───────────────────────────────────────────── */
            .stat-cards {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
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
            .stat-icon.amber  { background: #fef9c3; color: #b45309; }
            .stat-icon.purple { background: #f3e8ff; color: #7c3aed; }

            .stat-label  { font-size: 13px; color: var(--text-muted); font-weight: 500; margin-bottom: 4px; }
            .stat-value  { font-size: 28px; font-weight: 700; color: var(--text-dark); }

            /* ── Tier badge colours ───────────────────────────────────────── */
            .tier-bronze {
                background: linear-gradient(135deg, #fde68a, #d97706);
                color: #fff;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                letter-spacing: 0.3px;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            .tier-silver {
                background: linear-gradient(135deg, #e2e8f0, #94a3b8);
                color: #fff;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                letter-spacing: 0.3px;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            .tier-gold {
                background: linear-gradient(135deg, #fef08a, #f59e0b);
                color: #78350f;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                letter-spacing: 0.3px;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }
            .tier-standard {
                background: #f1f5f9;
                color: #475569;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 700;
                display: inline-flex;
                align-items: center;
                gap: 5px;
            }

            /* ── Filter tabs ─────────────────────────────────────────────── */
            .pill-tabs {
                display: flex;
                gap: 8px;
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

            .filter-tabs-container {
                display: flex;
                align-items: center;
                gap: 10px;
                flex-wrap: wrap;
                margin: 20px 0 16px;
                padding-bottom: 16px;
                border-bottom: 1px solid var(--border-soft);
            }

            /* ── Points bar ──────────────────────────────────────────────── */
            .points-bar-wrap {
                display: flex;
                flex-direction: column;
                gap: 3px;
                min-width: 100px;
            }
            .points-bar-bg {
                height: 6px;
                border-radius: 99px;
                background: #f1f5f9;
                overflow: hidden;
            }
            .points-bar-fill {
                height: 100%;
                border-radius: 99px;
                background: linear-gradient(90deg, #22c55e, #16a34a);
            }
            .points-bar-fill.silver { background: linear-gradient(90deg, #94a3b8, #64748b); }
            .points-bar-fill.gold   { background: linear-gradient(90deg, #f59e0b, #d97706); }

            /* ── Pagination ─────────────────────────────────────────────── */
            .pagination-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px 25px;
                border-top: 1px solid var(--border-soft);
                background-color: #fff;
            }
            .pagination-text { font-size: 13px; color: var(--text-muted); }
            .pagination-nav  { display: flex; gap: 5px; margin: 0; padding: 0; list-style: none; }
            .page-num-item a {
                display: flex; align-items: center; justify-content: center;
                width: 32px; height: 32px; border-radius: 6px;
                border: 1px solid var(--border-soft);
                font-size: 13px; font-weight: 600; color: #555;
                text-decoration: none; transition: all 0.2s;
            }
            .page-num-item a:hover { background-color: #fafafa; border-color: #ccc; }
            .page-num-item.active a { background-color: var(--primary-green, #22c55e); border-color: var(--primary-green, #22c55e); color: #fff; }
            .page-num-item.disabled a { opacity: 0.5; pointer-events: none; background-color: #f8f6f4; }

            /* ── Responsive ─────────────────────────────────────────────── */
            @media (max-width: 1200px) {
                .stat-cards { grid-template-columns: repeat(2, 1fr); }
            }
            @media (max-width: 640px) {
                .stat-cards { grid-template-columns: 1fr; }
            }

            /* ══════════════════════════════════════════════════════════════
               MEMBER DETAIL DRAWER (CSS-only offcanvas, no BS-JS required)
               ══════════════════════════════════════════════════════════════ */
            .drawer-backdrop {
                display: none;
                position: fixed; inset: 0;
                background: rgba(15, 23, 42, 0.45);
                z-index: 1040;
                backdrop-filter: blur(2px);
                -webkit-backdrop-filter: blur(2px);
                animation: fadeInBg 0.22s ease;
            }
            .drawer-backdrop.open { display: block; }
            @keyframes fadeInBg {
                from { opacity: 0; } to { opacity: 1; }
            }

            .member-drawer {
                position: fixed;
                top: 0; right: -520px;
                width: 480px;
                max-width: 96vw;
                height: 100vh;
                background: #fff;
                z-index: 1050;
                display: flex;
                flex-direction: column;
                box-shadow: -8px 0 40px rgba(0,0,0,0.12);
                transition: right 0.32s cubic-bezier(0.4, 0, 0.2, 1);
                border-radius: 20px 0 0 20px;
                /* NOTE: overflow must NOT be hidden here – it breaks native <select> dropdowns and input interactions */
            }
            .member-drawer.open { right: 0; }

            /* ── Drawer Header ── */
            .drawer-header {
                padding: 28px 28px 24px;
                background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
                border-bottom: 1px solid var(--border-soft);
                display: flex;
                align-items: flex-start;
                gap: 16px;
                flex-shrink: 0;
                border-radius: 20px 0 0 0;
                overflow: hidden;
            }
            .drawer-avatar {
                width: 60px; height: 60px;
                border-radius: 50%;
                display: flex; align-items: center; justify-content: center;
                font-size: 22px; font-weight: 800; color: #fff;
                flex-shrink: 0;
                box-shadow: 0 4px 14px rgba(0,0,0,0.15);
            }
            .drawer-name {
                font-size: 18px; font-weight: 800;
                color: var(--text-dark); line-height: 1.2;
                margin-bottom: 6px;
            }
            .drawer-meta {
                font-size: 13px; color: var(--text-muted);
                display: flex; align-items: center; gap: 8px; flex-wrap: wrap;
            }
            .drawer-close {
                margin-left: auto;
                width: 34px; height: 34px;
                border-radius: 50%;
                border: 1.5px solid var(--border-soft);
                background: white;
                display: flex; align-items: center; justify-content: center;
                cursor: pointer; font-size: 16px; color: var(--text-muted);
                transition: all 0.18s; flex-shrink: 0;
            }
            .drawer-close:hover { background: #f1f5f9; color: var(--text-dark); }

            /* ── Drawer Body (scrollable) ── */
            .drawer-body {
                flex: 1;
                overflow-y: auto;
                padding: 24px 28px;
                display: flex;
                flex-direction: column;
                gap: 24px;
            }
            .drawer-body::-webkit-scrollbar { width: 5px; }
            .drawer-body::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 99px; }

            /* ── Stats Grid ── */
            .drawer-stats-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 14px;
            }
            .drawer-stat-cell {
                background: #f8fafc;
                border: 1px solid var(--border-soft);
                border-radius: 14px;
                padding: 16px 18px;
                transition: box-shadow 0.2s;
            }
            .drawer-stat-cell:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.06); }
            .drawer-stat-label {
                font-size: 11px; font-weight: 700;
                text-transform: uppercase; letter-spacing: 0.6px;
                color: var(--text-muted); margin-bottom: 6px;
                display: flex; align-items: center; gap: 6px;
            }
            .drawer-stat-value {
                font-size: 22px; font-weight: 800; color: var(--text-dark);
                line-height: 1;
            }
            .drawer-stat-sub {
                font-size: 11px; color: var(--text-muted); margin-top: 3px;
            }

            /* ── Progress to next tier ── */
            .drawer-section-title {
                font-size: 13px; font-weight: 700;
                text-transform: uppercase; letter-spacing: 0.6px;
                color: var(--text-muted); margin-bottom: 12px;
                display: flex; align-items: center; gap: 8px;
            }
            .tier-progress-bar {
                height: 8px; border-radius: 99px;
                background: #f1f5f9; overflow: hidden;
                margin-bottom: 6px;
            }
            .tier-progress-fill {
                height: 100%; border-radius: 99px;
                background: linear-gradient(90deg, #f59e0b, #d97706);
                transition: width 0.6s ease;
            }
            .tier-progress-labels {
                display: flex; justify-content: space-between;
                font-size: 11px; color: var(--text-muted);
            }

            /* ── History table ── */
            .drawer-history-table {
                width: 100%; border-collapse: collapse;
            }
            .drawer-history-table th {
                font-size: 11px; font-weight: 700;
                text-transform: uppercase; letter-spacing: 0.5px;
                color: var(--text-muted); padding: 0 0 8px;
                border-bottom: 1px solid var(--border-soft);
                text-align: left;
            }
            .drawer-history-table td {
                padding: 10px 0;
                font-size: 13px; color: var(--text-dark);
                border-bottom: 1px solid #f8fafc;
                vertical-align: middle;
            }
            .drawer-history-table tr:last-child td { border-bottom: none; }
            .pts-earned { color: #16a34a; font-weight: 700; }
            .pts-spent  { color: #ef4444; font-weight: 700; }

            /* ── Drawer Footer ── */
            .drawer-footer {
                padding: 20px 28px;
                border-top: 1px solid var(--border-soft);
                background: #fafafa;
                display: flex;
                gap: 10px;
                flex-shrink: 0;
                flex-wrap: wrap;
            }
            .btn-drawer-outline {
                flex: 1;
                padding: 10px 14px;
                border-radius: 10px;
                border: 1.5px solid var(--border-soft);
                background: white;
                font-size: 13px; font-weight: 600;
                color: var(--text-dark);
                cursor: pointer;
                display: flex; align-items: center; justify-content: center; gap: 7px;
                transition: all 0.2s;
                white-space: nowrap;
                text-decoration: none;
            }
            .btn-drawer-outline:hover { background: #f1f5f9; border-color: #94a3b8; }
            .btn-drawer-primary {
                flex: 1;
                padding: 10px 14px;
                border-radius: 10px;
                border: none;
                background: var(--primary-green, #22c55e);
                font-size: 13px; font-weight: 700;
                color: #fff;
                cursor: pointer;
                display: flex; align-items: center; justify-content: center; gap: 7px;
                transition: all 0.2s;
                white-space: nowrap;
                text-decoration: none;
                box-shadow: 0 4px 14px rgba(34,197,94,0.25);
            }
            .btn-drawer-primary:hover { background: #16a34a; box-shadow: 0 6px 20px rgba(34,197,94,0.35); transform: translateY(-1px); }

            /* ── Owned vouchers chips ── */
            .voucher-chips {
                display: flex; gap: 8px; flex-wrap: wrap;
            }
            .voucher-chip {
                background: #f1f5f9;
                border: 1px solid var(--border-soft);
                border-radius: 8px;
                padding: 5px 12px;
                font-size: 12px; font-weight: 600;
                color: var(--text-dark);
                display: flex; align-items: center; gap: 5px;
            }
            .voucher-chip.active-chip { background: #dcfce7; border-color: #bbf7d0; color: #166534; }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="membership-overview" />
        </jsp:include>

        <div class="main-panel">

            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu"  value="Hạng Thành Viên" />
                <jsp:param name="activeMenu"  value="Tổng quan thành viên" />
            </jsp:include>

            <div class="content">

                <!-- ── Page Header ───────────────────────────────────────── -->
                <div class="page-header">
                    <div class="page-title">
                        <h2>Hạng Thành Viên</h2>
                        <p>Theo dõi hạng thành viên và điểm tích lũy của từng khách hàng.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/tier-config"
                       class="btn-primary" style="text-decoration: none;">
                        <i class="fa-solid fa-sliders"></i> Cấu hình hạng
                    </a>
                </div>

                <!-- ── Metric Cards ───────────────────────────────────────── -->
                <div class="stat-cards">
                    <!-- Total members -->
                    <div class="stat-card">
                        <div class="stat-icon blue"><i class="fa-solid fa-users"></i></div>
                        <div>
                            <div class="stat-label">Tổng thành viên</div>
                            <div class="stat-value"><fmt:formatNumber value="${totalMembers != null ? totalMembers : 0}" /></div>
                        </div>
                    </div>
                    <!-- Bronze -->
                    <div class="stat-card">
                        <div class="stat-icon orange"><i class="fa-solid fa-medal"></i></div>
                        <div>
                            <div class="stat-label">Hạng Đồng</div>
                            <div class="stat-value"><fmt:formatNumber value="${bronzeCount != null ? bronzeCount : 0}" /></div>
                        </div>
                    </div>
                    <!-- Silver -->
                    <div class="stat-card">
                        <div class="stat-icon" style="background:#e2e8f0;color:#475569;"><i class="fa-solid fa-medal"></i></div>
                        <div>
                            <div class="stat-label">Hạng Bạc</div>
                            <div class="stat-value"><fmt:formatNumber value="${silverCount != null ? silverCount : 0}" /></div>
                        </div>
                    </div>
                    <!-- Gold -->
                    <div class="stat-card">
                        <div class="stat-icon amber"><i class="fa-solid fa-crown"></i></div>
                        <div>
                            <div class="stat-label">Hạng Vàng</div>
                            <div class="stat-value"><fmt:formatNumber value="${goldCount != null ? goldCount : 0}" /></div>
                        </div>
                    </div>
                </div>

                <!-- ── Table Card ─────────────────────────────────────────── -->
                <div class="table-card">

                    <div class="filter-tabs-container">
                        <a href="${pageContext.request.contextPath}/admin/membership?tier=all&search=${searchQuery}"
                           class="pill-tab ${tierFilter == 'all' ? 'active' : ''}">
                            Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/membership?tier=MEMBER&search=${searchQuery}"
                           class="pill-tab ${tierFilter == 'MEMBER' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:#94a3b8;"></i>
                            Thành viên thường
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/membership?tier=BRONZE&search=${searchQuery}"
                           class="pill-tab ${tierFilter == 'BRONZE' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:#d97706;"></i>
                            Hạng Đồng
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/membership?tier=SILVER&search=${searchQuery}"
                           class="pill-tab ${tierFilter == 'SILVER' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:#64748b;"></i>
                            Hạng Bạc
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/membership?tier=GOLD&search=${searchQuery}"
                           class="pill-tab ${tierFilter == 'GOLD' ? 'active' : ''}">
                            <i class="fa-solid fa-circle" style="font-size:8px;vertical-align:middle;margin-right:4px;color:#f59e0b;"></i>
                            Hạng Vàng
                        </a>
                    </div>

                    <!-- Search bar -->
                    <div class="table-controls">
                        <form action="${pageContext.request.contextPath}/admin/membership" method="GET"
                              style="display:flex;gap:12px;width:100%;align-items:center;">
                            <input type="hidden" name="tier" value="${tierFilter}">
                            <div class="search-bar" style="flex-grow:1;max-width:420px;">
                                <i class="fa-solid fa-magnifying-glass" style="color:#a0a0a0;"></i>
                                <input type="text" name="search" value="${searchQuery}"
                                       placeholder="Tìm theo tên hoặc email khách hàng...">
                            </div>
                            <button type="submit" class="btn-primary" style="padding:10px 20px;">Tìm kiếm</button>
                            <c:if test="${not empty searchQuery}">
                                <a href="${pageContext.request.contextPath}/admin/membership?tier=${tierFilter}"
                                   style="font-size:13px;color:var(--text-muted);text-decoration:none;">
                                    <i class="fa-solid fa-xmark"></i> Xóa lọc
                                </a>
                            </c:if>
                        </form>
                    </div>

                    <!-- Data Table (Placeholder static data) -->
                    <table>
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Khách hàng</th>
                                <th>Email</th>
                                <th>Hạng thành viên</th>
                                <th>Điểm tích lũy</th>
                                <th>Tổng chi tiêu</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty members}">
                                <tr>
                                    <td colspan="7" style="text-align:center;padding:40px 0;color:var(--text-muted);">
                                        <i class="fa-solid fa-users-slash" style="font-size:40px;color:#e2e8f0;margin-bottom:15px;display:block;"></i>
                                        Không tìm thấy thành viên nào.
                                    </td>
                                </tr>
                            </c:if>
                            <c:forEach var="m" items="${members}" varStatus="loop">
                                
                                <c:set var="tierCode" value="${m.tierName.toLowerCase()}" />
                                <c:if test="${tierCode == 'member'}"><c:set var="tierCode" value="standard" /></c:if>
                                
                                <c:set var="tierIcon" value="fa-user" />
                                <c:set var="tierLabel" value="Thành viên" />
                                <c:choose>
                                    <c:when test="${tierCode == 'gold' || tierCode == 'diamond'}"><c:set var="tierIcon" value="fa-crown" /><c:set var="tierLabel" value="Hạng Vàng" /></c:when>
                                    <c:when test="${tierCode == 'silver'}"><c:set var="tierIcon" value="fa-medal" /><c:set var="tierLabel" value="Hạng Bạc" /></c:when>
                                    <c:when test="${tierCode == 'bronze'}"><c:set var="tierIcon" value="fa-medal" /><c:set var="tierLabel" value="Hạng Đồng" /></c:when>
                                </c:choose>
                                
                                <c:set var="avatarGrad" value="linear-gradient(135deg,#bfdbfe,#3b82f6)" />
                                <c:choose>
                                    <c:when test="${tierCode == 'gold' || tierCode == 'diamond'}"><c:set var="avatarGrad" value="linear-gradient(135deg,#f59e0b,#d97706)" /></c:when>
                                    <c:when test="${tierCode == 'silver'}"><c:set var="avatarGrad" value="linear-gradient(135deg,#94a3b8,#64748b)" /></c:when>
                                    <c:when test="${tierCode == 'bronze'}"><c:set var="avatarGrad" value="linear-gradient(135deg,#fde68a,#d97706)" /></c:when>
                                </c:choose>

                                <tr>
                                    <td style="color:var(--text-muted);font-size:13px;">${loop.index + 1 + (currentPage - 1) * 10}</td>
                                    <td>
                                        <div style="display:flex;align-items:center;gap:10px;">
                                            <div style="width:36px;height:36px;border-radius:50%;background:${avatarGrad};display:flex;align-items:center;justify-content:center;color:#fff;font-weight:700;font-size:14px;flex-shrink:0;">${m.fullName.substring(0,1).toUpperCase()}</div>
                                            <div>
                                                <div style="font-weight:600;font-size:14px;">${m.fullName}</div>
                                                <small style="color:var(--text-muted);">ID: ${m.userId}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="color:var(--text-muted);font-size:13px;">${m.email}</td>
                                    <td><span class="tier-${tierCode}"><i class="fa-solid ${tierIcon}" style="font-size:10px;"></i> ${tierLabel}</span></td>
                                    <td>
                                        <div style="font-weight:700;font-size:14px;">
                                            <fmt:formatNumber value="${m.accumulatedPoints}" /> <small style="font-weight:400;color:var(--text-muted);">pts</small>
                                        </div>
                                    </td>
                                    <td style="font-weight:700;"><fmt:formatNumber value="${m.totalSpending}" />₫</td>
                                    <td class="action-btns">
                                        <button class="btn-icon" title="Xem chi tiết thành viên"
                                            onclick="fetchMemberDetail('${m.userId}')"
                                            style="border:none;background:none;color:#3b82f6;cursor:pointer;">
                                            <i class="fa-regular fa-eye"></i>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>

                    <!-- ── Pagination widget ──────────────────────────── -->
                    <div class="pagination-area">
                        <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang (${totalRecords} bản ghi)</span>
                        <ul class="pagination-nav">
                            <c:set var="prevUrl" value="${pageContext.request.contextPath}/admin/membership?page=${currentPage - 1}&tier=${tierFilter}&search=${searchQuery}" />
                            <li class="page-num-item ${currentPage == 1 ? 'disabled' : ''}">
                                <a href="${currentPage == 1 ? '#' : prevUrl}"><i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i></a>
                            </li>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/membership?page=${i}&tier=${tierFilter}&search=${searchQuery}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:set var="nextUrl" value="${pageContext.request.contextPath}/admin/membership?page=${currentPage + 1}&tier=${tierFilter}&search=${searchQuery}" />
                            <li class="page-num-item ${currentPage == totalPages ? 'disabled' : ''}">
                                <a href="${currentPage == totalPages ? '#' : nextUrl}"><i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i></a>
                            </li>
                        </ul>
                    </div>

                </div><!-- end .table-card -->

            </div><!-- end .content -->
        </div><!-- end .main-panel -->

        <!-- ══════════════════════════════════════════════════════════════════
             MEMBER DETAIL SIDE DRAWER
             ══════════════════════════════════════════════════════════════════ -->

        <!-- Backdrop -->
        <div class="drawer-backdrop" id="memberDrawerBackdrop" onclick="closeMemberDrawer()"></div>

        <!-- Drawer panel -->
        <aside class="member-drawer" id="memberDrawer" aria-label="Chi tiết thành viên" role="dialog">

            <!-- Header -->
            <div class="drawer-header">
                <div class="drawer-avatar" id="drawerAvatar"></div>
                <div style="flex:1;min-width:0;">
                    <div class="drawer-name" id="drawerName">–</div>
                    <div class="drawer-meta">
                        <span id="drawerTierBadge"></span>
                        <span style="color:#cbd5e1;">·</span>
                        <span id="drawerMeta"></span>
                    </div>
                </div>
                <button class="drawer-close" onclick="closeMemberDrawer()" aria-label="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <!-- Scrollable body -->
            <div class="drawer-body">

                <!-- ── 4-cell Stats Grid ── -->
                <div class="drawer-stats-grid">
                    <div class="drawer-stat-cell">
                        <div class="drawer-stat-label">
                            <i class="fa-solid fa-star" style="color:#f59e0b;"></i> Điểm hiện tại
                        </div>
                        <div class="drawer-stat-value" id="drawerPoints">–</div>
                        <div class="drawer-stat-sub">điểm tích lũy</div>
                    </div>
                    <div class="drawer-stat-cell">
                        <div class="drawer-stat-label">
                            <i class="fa-solid fa-sack-dollar" style="color:#16a34a;"></i> Tổng chi tiêu
                        </div>
                        <div class="drawer-stat-value" id="drawerSpending" style="font-size:17px;">–</div>
                        <div class="drawer-stat-sub">lifetime spending</div>
                    </div>
                    <div class="drawer-stat-cell">
                        <div class="drawer-stat-label">
                            <i class="fa-solid fa-crown" style="color:#d97706;"></i> Hạng thành viên
                        </div>
                        <div class="drawer-stat-value" id="drawerTierStat" style="font-size:16px;">–</div>
                        <div class="drawer-stat-sub">hạng hiện tại</div>
                    </div>
                    <div class="drawer-stat-cell">
                        <div class="drawer-stat-label">
                            <i class="fa-solid fa-ticket" style="color:#7c3aed;"></i> Voucher sở hữu
                        </div>
                        <div class="drawer-stat-value" id="drawerVoucherCount">–</div>
                        <div class="drawer-stat-sub">mã chưa sử dụng</div>
                    </div>
                </div>

                <!-- ── Progress to next tier ── -->
                <div>
                    <div class="drawer-section-title">
                        <i class="fa-solid fa-arrow-trend-up" style="color:#22c55e;"></i>
                        Tiến trình thăng hạng
                    </div>
                    <div class="tier-progress-bar">
                        <div class="tier-progress-fill" id="drawerProgressFill" style="width:0%;"></div>
                    </div>
                    <div class="tier-progress-labels">
                        <span id="drawerProgressLabel">–</span>
                        <span id="drawerProgressPct" style="font-weight:700;">0%</span>
                    </div>
                </div>

                <!-- ── Owned Vouchers ── -->
                <div id="drawerVouchersSection">
                    <div class="drawer-section-title">
                        <i class="fa-solid fa-tag" style="color:#7c3aed;"></i>
                        Voucher đang sở hữu
                    </div>
                    <div class="voucher-chips" id="drawerVoucherChips"></div>
                </div>

                <!-- ── Recent Point History ── -->
                <div>
                    <div class="drawer-section-title">
                        <i class="fa-solid fa-clock-rotate-left" style="color:#64748b;"></i>
                        Lịch sử điểm gần đây
                    </div>
                    <table class="drawer-history-table">
                        <thead>
                            <tr>
                                <th>Ngày</th>
                                <th>Mô tả giao dịch</th>
                                <th style="text-align:right;">Điểm</th>
                            </tr>
                        </thead>
                        <tbody id="drawerHistoryBody"></tbody>
                    </table>
                </div>

                <!-- Assign Voucher Form (Hidden by default) -->
                <div id="drawerVoucherForm" style="display:none; padding: 20px 0 0 0; border-top: 1px solid var(--border-soft); margin-top: 20px;">
                    <div style="font-weight:700;margin-bottom:12px;font-size:14px;color:var(--text-dark);"><i class="fa-solid fa-ticket" style="color:#22c55e;"></i> Gán Voucher</div>
                    <div style="margin-bottom:12px;">
                        <input type="text" id="assignVoucherInput"
                               placeholder="Nhập mã voucher (VD: VIPCAKE)"
                               style="display:block;width:100%;box-sizing:border-box;padding:10px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;background:#fff;outline:none;">
                    </div>
                    <div style="display:flex;gap:10px;">
                        <button class="btn-drawer-outline" onclick="hideVoucherForm()">Hủy</button>
                        <button class="btn-drawer-primary" onclick="submitAssignVoucher()" id="btnSaveVoucher">Gán</button>
                    </div>
                </div>

                <!-- Tier Upgrade Form (Hidden by default) -->
                <div id="drawerTierForm" style="display:none; padding: 20px 0 0 0; border-top: 1px solid var(--border-soft); margin-top: 20px;">
                    <div style="font-weight:700;margin-bottom:12px;font-size:14px;color:var(--text-dark);"><i class="fa-solid fa-arrow-up" style="color:#22c55e;"></i> Thay đổi hạng thành viên</div>
                    <div style="margin-bottom:12px;">
                        <select id="upgradeTierSelect"
                                style="display:block;width:100%;box-sizing:border-box;padding:10px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;background:#fff;outline:none;-webkit-appearance:auto;appearance:auto;">
                            <option value="">-- Chọn hạng mới --</option>
                            <c:forEach var="t" items="${allTiers}">
                                <option value="${t.tierId}"><c:out value="${t.tierName}" /></option>
                            </c:forEach>
                        </select>
                    </div>
                    <div style="display:flex;gap:10px;">
                        <button class="btn-drawer-outline" onclick="hideTierForm()">Hủy</button>
                        <button class="btn-drawer-primary" onclick="submitTierUpgrade()" id="btnSaveTier">Cập nhật</button>
                    </div>
                </div>

                <!-- Points Adjustment Form (Hidden by default) -->
                <div id="drawerPointsForm" style="display:none; padding: 20px 0 0 0; border-top: 1px solid var(--border-soft); margin-top: 20px;">
                    <div style="font-weight:700;margin-bottom:12px;font-size:14px;color:var(--text-dark);"><i class="fa-solid fa-sliders" style="color:#22c55e;"></i> Điều chỉnh điểm</div>
                    <div style="margin-bottom:10px;">
                        <input type="number" id="adjustPointsAmount"
                               placeholder="Số điểm (0 – 9999)" max="9999" min="0"
                               style="display:block;width:100%;box-sizing:border-box;padding:10px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;background:#fff;outline:none;"
                               oninput="if(this.value>9999)this.value=9999;if(this.value<0)this.value=0;">
                    </div>
                    <div style="margin-bottom:10px;">
                        <select id="adjustPointsReason"
                                style="display:block;width:100%;box-sizing:border-box;padding:10px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;background:#fff;outline:none;-webkit-appearance:auto;appearance:auto;">
                            <option value="">-- Chọn lý do --</option>
                            <option value="Reward Event">Sự kiện tặng thưởng</option>
                            <option value="Promotion">Khuyến mãi</option>
                            <option value="Customer Service">Chăm sóc khách hàng</option>
                            <option value="Manual Correction">Điều chỉnh thủ công</option>
                            <option value="Other">Khác</option>
                        </select>
                    </div>
                    <div style="margin-bottom:12px;">
                        <textarea id="adjustPointsNotes"
                                  placeholder="Ghi chú thêm (tùy chọn)..."
                                  style="display:block;width:100%;box-sizing:border-box;padding:10px 12px;border:1.5px solid #e2e8f0;border-radius:8px;font-size:14px;color:#1e293b;background:#fff;outline:none;resize:none;height:64px;"></textarea>
                    </div>
                    <div style="display:flex;gap:10px;">
                        <button class="btn-drawer-outline" onclick="hidePointsForm()">Hủy</button>
                        <button class="btn-drawer-primary" onclick="submitPointsAdjust()" id="btnSavePoints">Lưu thay đổi</button>
                    </div>
                </div>

            </div><!-- end .drawer-body -->

            <!-- Footer Actions -->
            <div class="drawer-footer" id="drawerFooterButtons">
                <button class="btn-drawer-outline" onclick="showVoucherForm()">
                    <i class="fa-solid fa-ticket"></i> Gán Voucher
                </button>
                <button class="btn-drawer-outline" onclick="showPointsForm()">
                    <i class="fa-solid fa-sliders"></i> Điều chỉnh Điểm
                </button>
                <button class="btn-drawer-primary" onclick="showTierForm()">
                    <i class="fa-solid fa-arrow-up"></i> Thay đổi Hạng
                </button>
            </div>

        </aside><!-- end .member-drawer -->

        <script>
            // ── Tier configuration ──────────────────────────────────────────
            const TIER_CONFIG = {
                standard: { label: 'Thành viên', icon: 'fa-user',  gradient: 'linear-gradient(135deg,#94a3b8,#64748b)', color: '#475569' },
                bronze:   { label: 'Hạng Đồng',  icon: 'fa-medal', gradient: 'linear-gradient(135deg,#fde68a,#d97706)', color: '#92400e' },
                silver:   { label: 'Hạng Bạc',   icon: 'fa-medal', gradient: 'linear-gradient(135deg,#e2e8f0,#94a3b8)', color: '#334155' },
                gold:     { label: 'Hạng Vàng',  icon: 'fa-crown', gradient: 'linear-gradient(135deg,#fef08a,#f59e0b)', color: '#78350f' }
            };

            // ── AJAX fetch member detail ────────────────────────────────────
            function fetchMemberDetail(userId) {
                // Show a loading state or just directly fetch
                fetch('${pageContext.request.contextPath}/admin/membership?action=detail&userId=' + userId)
                    .then(response => response.json())
                    .then(data => {
                        if (data.error) {
                            alert('Không thể tải chi tiết thành viên: ' + data.error);
                        } else {
                            openMemberDrawer(data);
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        alert('Đã xảy ra lỗi khi tải dữ liệu thành viên.');
                    });
            }

            // ── Open drawer with member data ────────────────────────────────
            function openMemberDrawer(m) {
                const tier = TIER_CONFIG[m.tier] || TIER_CONFIG.standard;

                // Avatar
                const av = document.getElementById('drawerAvatar');
                av.textContent = m.initials;
                av.style.background = m.avatarGrad;

                // Name & meta
                currentMemberId = m.id;
                currentMemberTierId = null;
                // find tier ID by matching tier label
                for (const tCode in TIER_CONFIG) {
                    if (TIER_CONFIG[tCode].label === tier.label) {
                        // We need the actual ID. Let's rely on the option tags we printed
                        // Wait, it's easier if we just search allTiers but we don't have it as JS array.
                        // Let's grab it from the options of upgradeTierSelect
                        const opts = document.getElementById('upgradeTierSelect').options;
                        for (let i = 0; i < opts.length; i++) {
                            if (opts[i].text === tier.label) {
                                currentMemberTierId = opts[i].value;
                                break;
                            }
                        }
                        break;
                    }
                }
                
                document.getElementById('drawerName').textContent = m.name;
                document.getElementById('drawerMeta').textContent = m.id + '  ·  ' + m.email;

                // Tier badge
                document.getElementById('drawerTierBadge').innerHTML =
                    '<span style="background:' + tier.gradient + ';color:' + tier.color +
                    ';padding:3px 11px;border-radius:20px;font-size:12px;font-weight:700;display:inline-flex;align-items:center;gap:5px;">'
                    + '<i class="fa-solid ' + tier.icon + '" style="font-size:10px;"></i> ' + tier.label + '</span>';

                // Stats
                document.getElementById('drawerPoints').textContent       = m.points;
                document.getElementById('drawerSpending').textContent     = m.spending;
                document.getElementById('drawerTierStat').textContent     = tier.label;
                document.getElementById('drawerVoucherCount').textContent = m.vouchers;

                // Progress bar
                const fill = document.getElementById('drawerProgressFill');
                fill.style.width = Math.min(m.progressPct, 100) + '%';
                // Colour the bar by tier
                const barColors = {
                    standard: 'linear-gradient(90deg,#94a3b8,#64748b)',
                    bronze:   'linear-gradient(90deg,#fde68a,#d97706)',
                    silver:   'linear-gradient(90deg,#cbd5e1,#94a3b8)',
                    gold:     'linear-gradient(90deg,#fef08a,#f59e0b)'
                };
                fill.style.background = barColors[m.tier] || barColors.standard;
                document.getElementById('drawerProgressLabel').textContent = m.progressLabel;
                document.getElementById('drawerProgressPct').textContent   = Math.min(m.progressPct, 100) + '%';

                // Owned vouchers
                const chipsEl = document.getElementById('drawerVoucherChips');
                const section = document.getElementById('drawerVouchersSection');
                if (m.ownedVouchers && m.ownedVouchers.length > 0) {
                    section.style.display = 'block';
                    chipsEl.innerHTML = m.ownedVouchers.map(function(v) {
                        return '<span class="voucher-chip active-chip"><i class="fa-solid fa-ticket" style="font-size:10px;"></i>' + v + '</span>';
                    }).join('');
                } else {
                    section.style.display = 'block';
                    chipsEl.innerHTML = '<span style="font-size:13px;color:var(--text-muted);">Chưa sở hữu voucher nào.</span>';
                }

                // Point history
                const tbody = document.getElementById('drawerHistoryBody');
                tbody.innerHTML = (m.history || []).map(function(row) {
                    var cls  = row.type === 'earned' ? 'pts-earned' : 'pts-spent';
                    var sign = row.type === 'earned'
                        ? '<i class="fa-solid fa-circle-arrow-up" style="color:#16a34a;font-size:11px;"></i>'
                        : '<i class="fa-solid fa-circle-arrow-down" style="color:#ef4444;font-size:11px;"></i>';
                    return '<tr>'
                        + '<td style="color:var(--text-muted);white-space:nowrap;">' + row.date + '</td>'
                        + '<td>' + sign + ' ' + row.desc + '</td>'
                        + '<td style="text-align:right;" class="' + cls + '">' + row.pts + '</td>'
                        + '</tr>';
                }).join('');

                // Open
                document.getElementById('memberDrawerBackdrop').classList.add('open');
                document.getElementById('memberDrawer').classList.add('open');
                document.body.style.overflow = 'hidden';
            }

            // ── Close drawer ────────────────────────────────────────────────
            function closeMemberDrawer() {
                document.getElementById('memberDrawerBackdrop').classList.remove('open');
                document.getElementById('memberDrawer').classList.remove('open');
                document.body.style.overflow = '';
                hidePointsForm();
            }

            // ── Points Adjustment ───────────────────────────────────────────
            let currentMemberId = null;
            function showPointsForm() {
                document.getElementById('drawerFooterButtons').style.display = 'none';
                document.getElementById('drawerPointsForm').style.display = 'block';
                // scroll to bottom
                document.querySelector('.drawer-body').scrollTop = document.querySelector('.drawer-body').scrollHeight;
            }
            function hidePointsForm() {
                document.getElementById('drawerPointsForm').style.display = 'none';
                document.getElementById('drawerTierForm').style.display = 'none';
                document.getElementById('drawerVoucherForm').style.display = 'none';
                document.getElementById('drawerFooterButtons').style.display = 'flex';
                document.getElementById('adjustPointsAmount').value = '';
                document.getElementById('adjustPointsReason').value = '';
                document.getElementById('adjustPointsNotes').value = '';
            }
            // ── Voucher Assignment ──────────────────────────────────────────
            let currentMemberTierId = null;
            function showVoucherForm() {
                document.getElementById('drawerFooterButtons').style.display = 'none';
                document.getElementById('drawerVoucherForm').style.display = 'block';
                document.querySelector('.drawer-body').scrollTop = document.querySelector('.drawer-body').scrollHeight;
            }
            function hideVoucherForm() {
                document.getElementById('drawerVoucherForm').style.display = 'none';
                document.getElementById('drawerFooterButtons').style.display = 'flex';
                document.getElementById('assignVoucherInput').value = '';
            }
            function submitAssignVoucher() {
                const voucherCode = document.getElementById('assignVoucherInput').value.trim();
                if (!voucherCode) { alert('Vui lòng nhập mã voucher.'); return; }
                if (!currentMemberId) return;

                const btn = document.getElementById('btnSaveVoucher');
                btn.disabled = true;
                btn.textContent = 'Đang gán...';

                fetch('${pageContext.request.contextPath}/admin/membership', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({
                        action: 'assignVoucher',
                        userId: currentMemberId,
                        voucherCode: voucherCode
                    })
                })
                .then(res => res.json())
                .then(data => {
                    btn.disabled = false;
                    btn.textContent = 'Gán';
                    if (data.status === 'ok') {
                        hideVoucherForm();
                        fetchMemberDetail(currentMemberId);
                    } else {
                        alert(data.message || 'Có lỗi xảy ra.');
                    }
                })
                .catch(err => {
                    btn.disabled = false;
                    btn.textContent = 'Gán';
                    alert('Lỗi kết nối.');
                });
            }

            // ── Other Forms ───────────────────────────────────────────────
            function showTierForm() {
                document.getElementById('drawerFooterButtons').style.display = 'none';
                document.getElementById('drawerTierForm').style.display = 'block';
                document.querySelector('.drawer-body').scrollTop = document.querySelector('.drawer-body').scrollHeight;
            }
            function hideTierForm() {
                document.getElementById('drawerTierForm').style.display = 'none';
                document.getElementById('drawerFooterButtons').style.display = 'flex';
                document.getElementById('upgradeTierSelect').value = '';
            }
            function submitPointsAdjust() {
                const amount = document.getElementById('adjustPointsAmount').value;
                const reason = document.getElementById('adjustPointsReason').value;
                const notes = document.getElementById('adjustPointsNotes').value;
                
                if (!amount || isNaN(amount)) { alert('Vui lòng nhập số điểm hợp lệ.'); return; }
                if (!reason) { alert('Vui lòng chọn lý do điều chỉnh.'); return; }
                if (!currentMemberId) return;

                const btn = document.getElementById('btnSavePoints');
                btn.disabled = true;
                btn.textContent = 'Đang lưu...';

                fetch('${pageContext.request.contextPath}/admin/membership', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({
                        action: 'adjustPoints',
                        userId: currentMemberId,
                        amount: amount,
                        reasonType: reason,
                        notes: notes
                    })
                })
                .then(res => res.json())
                .then(data => {
                    btn.disabled = false;
                    btn.textContent = 'Lưu thay đổi';
                    if (data.status === 'ok') {
                        hidePointsForm();
                        // Refresh drawer data
                        fetchMemberDetail(currentMemberId);
                        // Optional: show a quick success toast here
                    } else {
                        alert(data.message || 'Có lỗi xảy ra.');
                    }
                })
                .catch(err => {
                    btn.disabled = false;
                    btn.textContent = 'Lưu thay đổi';
                    alert('Lỗi kết nối.');
                });
            }

            function submitTierUpgrade() {
                const tierId = document.getElementById('upgradeTierSelect').value;
                if (!tierId) { alert('Vui lòng chọn hạng mới.'); return; }
                if (!currentMemberId) return;

                if (!confirm('Bạn có chắc chắn muốn thay đổi hạng thành viên này không?')) return;

                const btn = document.getElementById('btnSaveTier');
                btn.disabled = true;
                btn.textContent = 'Đang lưu...';

                fetch('${pageContext.request.contextPath}/admin/membership', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({
                        action: 'upgradeTier',
                        userId: currentMemberId,
                        tierId: tierId
                    })
                })
                .then(res => res.json())
                .then(data => {
                    btn.disabled = false;
                    btn.textContent = 'Cập nhật';
                    if (data.status === 'ok') {
                        hideTierForm();
                        fetchMemberDetail(currentMemberId);
                    } else {
                        alert(data.message || 'Có lỗi xảy ra.');
                    }
                })
                .catch(err => {
                    btn.disabled = false;
                    btn.textContent = 'Cập nhật';
                    alert('Lỗi kết nối.');
                });
            }

            // Close on Escape key
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeMemberDrawer();
            });
        </script>

    </body>
</html>
