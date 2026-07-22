<%--
    Document   : tier-config
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
            <jsp:param name="title" value="CakeZone Admin – Cấu hình Hạng Thành Viên" />
        </jsp:include>
        <style>
            /* ── Section headers ────────────────────────────────────────── */
            .section-title {
                font-size: 16px;
                font-weight: 700;
                color: var(--text-dark);
                margin-bottom: 16px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .section-title i {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 14px;
            }

            /* ── Tier rule cards ─────────────────────────────────────────── */
            .tier-cards-grid {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 20px;
                margin-bottom: 32px;
            }

            .tier-rule-card {
                border-radius: 16px;
                padding: 24px;
                position: relative;
                overflow: hidden;
                border: 2px solid transparent;
                transition: transform 0.2s, box-shadow 0.2s;
            }
            .tier-rule-card:hover { transform: translateY(-3px); box-shadow: 0 8px 28px rgba(0,0,0,0.10); }

            .tier-rule-card.standard {
                background: #f8fafc;
                border-color: #e2e8f0;
            }
            .tier-rule-card.bronze {
                background: linear-gradient(145deg, #fffbeb, #fef3c7);
                border-color: #fcd34d;
            }
            .tier-rule-card.silver {
                background: linear-gradient(145deg, #f8fafc, #f1f5f9);
                border-color: #cbd5e1;
            }
            .tier-rule-card.gold {
                background: linear-gradient(145deg, #fffbeb, #fef9c3);
                border-color: #f59e0b;
                box-shadow: 0 4px 20px rgba(245, 158, 11, 0.15);
            }

            .tier-badge-large {
                display: inline-flex;
                align-items: center;
                gap: 7px;
                padding: 5px 14px;
                border-radius: 20px;
                font-size: 13px;
                font-weight: 700;
                margin-bottom: 16px;
            }
            .tier-badge-large.standard { background: #e2e8f0; color: #475569; }
            .tier-badge-large.bronze   { background: linear-gradient(135deg,#fde68a,#d97706); color: #fff; }
            .tier-badge-large.silver   { background: linear-gradient(135deg,#cbd5e1,#94a3b8); color: #fff; }
            .tier-badge-large.gold     { background: linear-gradient(135deg,#fef08a,#f59e0b); color: #78350f; }

            .tier-rule-card .req-label {
                font-size: 11px;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: 0.6px;
                margin-bottom: 4px;
            }
            .tier-rule-card .req-value {
                font-size: 22px;
                font-weight: 800;
                color: var(--text-dark);
                margin-bottom: 8px;
            }
            .tier-rule-card .req-pts {
                font-size: 13px;
                color: var(--text-muted);
                margin-bottom: 20px;
            }
            .tier-rule-card .perk-list {
                list-style: none;
                padding: 0;
                margin: 0 0 20px;
                display: flex;
                flex-direction: column;
                gap: 6px;
            }
            .tier-rule-card .perk-list li {
                font-size: 13px;
                color: var(--text-dark);
                display: flex;
                align-items: center;
                gap: 7px;
            }
            .tier-rule-card .perk-list li i { color: #22c55e; font-size: 11px; }

            .btn-edit-tier {
                width: 100%;
                padding: 9px 0;
                border-radius: 8px;
                border: 1.5px solid var(--border-soft);
                background: var(--surface-white);
                font-size: 13px;
                font-weight: 600;
                color: var(--text-dark);
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                transition: all 0.2s;
            }
            .btn-edit-tier:hover { background: #f1f5f9; border-color: #94a3b8; }

            /* ── Config section card ─────────────────────────────────────── */
            .config-card {
                background: var(--surface-white);
                border: 1px solid var(--border-soft);
                border-radius: 16px;
                overflow: hidden;
                margin-bottom: 24px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.04);
            }
            .config-card-header {
                padding: 20px 28px;
                border-bottom: 1px solid var(--border-soft);
                display: flex;
                align-items: center;
                justify-content: space-between;
                background: #fafafa;
            }
            .config-card-body { padding: 28px; }

            /* ── Voucher-tier assignment table ───────────────────────────── */
            .voucher-assign-table {
                width: 100%;
                border-collapse: collapse;
            }
            .voucher-assign-table th {
                font-size: 12px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                color: var(--text-muted);
                padding: 10px 14px;
                text-align: left;
                border-bottom: 1px solid var(--border-soft);
            }
            .voucher-assign-table td {
                padding: 14px 14px;
                font-size: 14px;
                color: var(--text-dark);
                border-bottom: 1px solid #f8fafc;
                vertical-align: middle;
            }
            .voucher-assign-table tr:last-child td { border-bottom: none; }
            .voucher-assign-table tr:hover td { background: #fafafa; }

            /* ── Toggle switch ───────────────────────────────────────────── */
            .toggle-switch {
                position: relative;
                display: inline-block;
                width: 44px;
                height: 24px;
            }
            .toggle-switch input { opacity: 0; width: 0; height: 0; }
            .toggle-slider {
                position: absolute;
                cursor: pointer;
                top: 0; left: 0; right: 0; bottom: 0;
                background-color: #cbd5e1;
                border-radius: 34px;
                transition: 0.3s;
            }
            .toggle-slider:before {
                position: absolute;
                content: "";
                height: 18px; width: 18px;
                left: 3px; bottom: 3px;
                background-color: white;
                border-radius: 50%;
                transition: 0.3s;
                box-shadow: 0 1px 4px rgba(0,0,0,0.18);
            }
            .toggle-switch input:checked + .toggle-slider { background-color: var(--primary-green, #22c55e); }
            .toggle-switch input:checked + .toggle-slider:before { transform: translateX(20px); }

            /* ── Tier checkbox pills ─────────────────────────────────────── */
            .tier-pill-group {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }
            .tier-pill-check { display: none; }
            .tier-pill-label {
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 12px;
                font-weight: 600;
                cursor: pointer;
                border: 1.5px solid transparent;
                transition: all 0.2s;
                user-select: none;
            }
            .tier-pill-check:checked + .tier-pill-label { box-shadow: 0 0 0 2px var(--primary-green, #22c55e); }

            .pill-standard { background: #e2e8f0; color: #475569; border-color: #e2e8f0; }
            .pill-bronze   { background: linear-gradient(135deg,#fde68a,#d97706); color: #fff; border-color: #d97706; }
            .pill-silver   { background: linear-gradient(135deg,#cbd5e1,#94a3b8); color: #fff; border-color: #94a3b8; }
            .pill-gold     { background: linear-gradient(135deg,#fef08a,#f59e0b); color: #78350f; border-color: #f59e0b; }

            /* ── Points multiplier setting ───────────────────────────────── */
            .multiplier-row {
                display: flex;
                align-items: center;
                gap: 16px;
                padding: 16px 0;
                border-bottom: 1px solid var(--border-soft);
            }
            .multiplier-row:last-child { border-bottom: none; }
            .multiplier-row .tier-label { flex: 0 0 200px; display: flex; align-items: center; gap: 10px; }
            .multiplier-row input[type="number"] {
                width: 90px;
                padding: 8px 12px;
                border-radius: 8px;
                border: 1.5px solid var(--border-soft);
                font-size: 15px;
                font-weight: 700;
                text-align: center;
                outline: none;
                transition: border-color 0.2s;
            }
            .multiplier-row input[type="number"]:focus { border-color: var(--primary-green, #22c55e); }
            .multiplier-row .unit-text { font-size: 13px; color: var(--text-muted); }

            /* ── Form footer ─────────────────────────────────────────────── */
            .form-footer {
                display: flex;
                align-items: center;
                justify-content: flex-end;
                gap: 12px;
                padding-top: 24px;
                border-top: 1px solid var(--border-soft);
                margin-top: 8px;
            }

            /* ── Edit modal (simple inline approach) ─────────────────────── */
            .modal-backdrop {
                display: none;
                position: fixed; inset: 0;
                background: rgba(0,0,0,0.35);
                z-index: 1000;
                align-items: center;
                justify-content: center;
            }
            .modal-backdrop.open { display: flex; }
            .modal-box {
                background: #fff;
                border-radius: 20px;
                padding: 32px;
                width: 460px;
                max-width: 90vw;
                box-shadow: 0 20px 60px rgba(0,0,0,0.18);
                animation: slideUp 0.22s ease;
            }
            @keyframes slideUp {
                from { transform: translateY(30px); opacity: 0; }
                to   { transform: translateY(0);    opacity: 1; }
            }
            .modal-title {
                font-size: 18px;
                font-weight: 700;
                color: var(--text-dark);
                margin-bottom: 24px;
                display: flex;
                align-items: center;
                gap: 10px;
            }
            .modal-field { margin-bottom: 18px; }
            .modal-field label {
                display: block;
                font-size: 13px;
                font-weight: 600;
                color: var(--text-muted);
                margin-bottom: 6px;
            }
            .modal-field input {
                width: 100%;
                padding: 10px 14px;
                border-radius: 10px;
                border: 1.5px solid var(--border-soft);
                font-size: 15px;
                outline: none;
                transition: border-color 0.2s;
                box-sizing: border-box;
            }
            .modal-field input:focus { border-color: var(--primary-green, #22c55e); }

            @media (max-width: 1200px) {
                .tier-cards-grid { grid-template-columns: repeat(2, 1fr); }
            }
            @media (max-width: 640px) {
                .tier-cards-grid { grid-template-columns: 1fr; }
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="tier-config" />
        </jsp:include>

        <div class="main-panel">

            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu"  value="Hạng Thành Viên" />
                <jsp:param name="activeMenu"  value="Cấu hình hạng" />
            </jsp:include>

            <div class="content">

                <!-- ── Page Header ───────────────────────────────────────── -->
                <div class="page-header">
                    <div class="page-title">
                        <h2>Cấu hình Hạng Thành Viên</h2>
                        <p>Thiết lập điều kiện thăng hạng, ưu đãi và voucher dành riêng cho từng hạng thành viên.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/membership"
                       class="btn-primary" style="text-decoration: none; background: #f1f5f9; color: var(--text-dark); border: 1px solid var(--border-soft);">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại Tổng quan
                    </a>
                </div>

                <!-- ── Flash messages ─────────────────────────────────────── -->
                <c:if test="${not empty success}">
                    <div style="background:#dcfce7;color:#166534;padding:12px 20px;border-radius:8px;margin-bottom:20px;border:1px solid #bbf7d0;">
                        <i class="fa-solid fa-circle-check"></i> Cấu hình đã được lưu thành công!
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div style="background:#fee2e2;color:#991b1b;padding:12px 20px;border-radius:8px;margin-bottom:20px;border:1px solid #fecaca;">
                        <i class="fa-solid fa-circle-exclamation"></i> <strong>Lỗi:</strong> Đã xảy ra lỗi khi lưu cấu hình. Vui lòng thử lại.
                    </div>
                </c:if>

                <!-- ══════════════════════════════════════════════════════════
                     SECTION 1 – Tier Rules Cards
                     ══════════════════════════════════════════════════════════ -->
                <div class="section-title" style="margin-bottom:20px; display: flex; justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <i class="fa-solid fa-layer-group" style="background:#dbeafe;color:#2563eb;width:32px;height:32px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:14px;"></i>
                        Quy định Hạng thành viên
                    </div>
                    <button class="btn-primary" onclick="openEditModal(0, '', '', '', '', '')">
                        <i class="fa-solid fa-plus"></i> Thêm hạng mới
                    </button>
                </div>

                <div class="tier-cards-grid">
                    <c:if test="${empty tiers}">
                        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-muted);">
                            Chưa có hạng thành viên nào được định nghĩa.
                        </div>
                    </c:if>
                    
                    <c:forEach var="t" items="${tiers}">
                        
                        <c:set var="tierCode" value="${t.tierName.toLowerCase()}" />
                        <c:if test="${tierCode == 'member' || tierCode == 'thành viên'}"><c:set var="tierCode" value="standard" /></c:if>
                        
                        <c:set var="cardClass" value="standard" />
                        <c:set var="icon" value="fa-user" />
                        <c:choose>
                            <c:when test="${tierCode == 'gold' || tierCode == 'diamond' || tierCode == 'hạng vàng'}"><c:set var="cardClass" value="gold" /><c:set var="icon" value="fa-crown" /></c:when>
                            <c:when test="${tierCode == 'silver' || tierCode == 'hạng bạc'}"><c:set var="cardClass" value="silver" /><c:set var="icon" value="fa-medal" /></c:when>
                            <c:when test="${tierCode == 'bronze' || tierCode == 'hạng đồng'}"><c:set var="cardClass" value="bronze" /><c:set var="icon" value="fa-medal" /></c:when>
                        </c:choose>
                        
                        <div class="tier-rule-card ${cardClass}">
                            <span class="tier-badge-large ${cardClass}"><i class="fa-solid ${icon}"></i> ${t.tierName}</span>
                            <div class="req-label">Chi tiêu tối thiểu</div>
                            <div class="req-value"><fmt:formatNumber value="${t.minSpending}" />₫</div>
                            <div class="req-pts">Hệ số nhân điểm: ${t.pointMultiplier}x</div>
                            <ul class="perk-list">
                                <li><i class="fa-solid fa-check"></i> ${t.monthlyVouchers} voucher/tháng</li>
                                <li><i class="fa-solid fa-check"></i> ${not empty t.description ? t.description : 'Ưu đãi cơ bản'}</li>
                            </ul>
                            <div style="display:flex; gap:8px;">
                                <button class="btn-edit-tier" style="flex:1;" onclick="openEditModal('${t.tierId}', '${t.tierName}', '${t.minSpending}', '${t.pointMultiplier}', '${t.monthlyVouchers}', '${t.description}')">
                                    <i class="fa-regular fa-pen-to-square"></i> Sửa
                                </button>
                                <button class="btn-edit-tier" style="flex:0 0 40px; color:#ef4444; border-color:#fca5a5;" onclick="deleteTier('${t.tierId}')">
                                    <i class="fa-regular fa-trash-can"></i>
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div><!-- end .content -->
        </div><!-- end .main-panel -->

        <!-- ══════════════════════════════════════════════════════════════════
             EDIT TIER MODAL
             ══════════════════════════════════════════════════════════════════ -->
        <div class="modal-backdrop" id="editTierModal">
            <div class="modal-box">
                <div class="modal-title">
                    <i class="fa-solid fa-pen-to-square" style="color:var(--primary-green,#22c55e);"></i>
                    <span id="modal-title-text">Thêm Hạng Mới</span>
                </div>
                <form id="tierForm" action="javascript:void(0);" onsubmit="submitTierForm()">
                    <input type="hidden" name="action" value="saveTier">
                    <input type="hidden" name="tierId" id="modal-tier-id" value="0">

                    <div class="modal-field">
                        <label>Tên Hạng</label>
                        <input type="text" name="tierName" id="modal-tier-name-input" placeholder="VD: Hạng Vàng" required>
                    </div>
                    <div class="modal-field">
                        <label>Chi tiêu tích lũy tối thiểu (₫)</label>
                        <input type="number" name="minSpending" id="modal-min-spend" placeholder="0" min="0" required>
                    </div>
                    <div class="modal-field">
                        <label>Hệ số tích điểm (x)</label>
                        <input type="number" name="pointMultiplier" id="modal-point-mult" placeholder="1.0" min="0" step="0.1" required>
                    </div>
                    <div class="modal-field">
                        <label>Số voucher/tháng</label>
                        <input type="number" name="monthlyVouchers" id="modal-monthly-vouchers" placeholder="0" min="0" required>
                    </div>
                    <div class="modal-field">
                        <label>Mô tả ưu đãi</label>
                        <input type="text" name="description" id="modal-desc" placeholder="VD: Miễn phí vận chuyển">
                    </div>

                    <div class="form-footer" style="border-top:none;padding-top:8px;">
                        <button type="button" onclick="closeEditModal()"
                                class="btn-primary" style="background:#f1f5f9;color:var(--text-dark);border:1px solid var(--border-soft);">
                            Hủy
                        </button>
                        <button type="submit" class="btn-primary" id="btnSaveTier">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openEditModal(tierId, tierName, minSpend, mult, vouchers, desc) {
                document.getElementById('modal-tier-id').value    = tierId;
                document.getElementById('modal-tier-name-input').value = tierName || '';
                document.getElementById('modal-min-spend').value  = minSpend || '0';
                document.getElementById('modal-point-mult').value = mult || '1.0';
                document.getElementById('modal-monthly-vouchers').value = vouchers || '0';
                document.getElementById('modal-desc').value = desc || '';
                
                document.getElementById('modal-title-text').textContent = tierId != '0' ? ('Sửa hạng: ' + tierName) : 'Thêm Hạng Mới';
                document.getElementById('editTierModal').classList.add('open');
            }
            function closeEditModal() {
                document.getElementById('editTierModal').classList.remove('open');
            }
            document.getElementById('editTierModal').addEventListener('click', function(e) {
                if (e.target === this) closeEditModal();
            });

            function submitTierForm() {
                const btn = document.getElementById('btnSaveTier');
                btn.disabled = true;
                btn.textContent = 'Đang lưu...';
                
                const formData = new FormData(document.getElementById('tierForm'));
                
                fetch('${pageContext.request.contextPath}/admin/tier-config', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams(formData)
                })
                .then(res => res.json())
                .then(data => {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi';
                    if (data.status === 'ok') {
                        location.reload();
                    } else {
                        alert(data.message || 'Lỗi lưu cấu hình.');
                    }
                })
                .catch(err => {
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi';
                    alert('Lỗi kết nối.');
                });
            }

            function deleteTier(tierId) {
                if (!confirm('Bạn có chắc chắn muốn xóa hạng này không?')) return;
                
                fetch('${pageContext.request.contextPath}/admin/tier-config', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({
                        action: 'deleteTier',
                        tierId: tierId
                    })
                })
                .then(res => res.json())
                .then(data => {
                    if (data.status === 'ok') {
                        location.reload();
                    } else {
                        alert(data.message || 'Lỗi xóa hạng.');
                    }
                })
                .catch(err => {
                    alert('Lỗi kết nối.');
                });
            }
        </script>

    </body>
</html>
