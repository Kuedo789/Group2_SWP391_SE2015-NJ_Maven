<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>

    voucher-edit.jsp
    Admin edit form for an existing Voucher.
    Layout and style mirrors voucher-add.jsp exactly.

    Request attributes expected (set by VoucherManagementServlet action=edit):
      • editVoucher : Voucher – the record being edited
-%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin – Chỉnh sửa Voucher" />
        </jsp:include>
        <style>
            .form-card {
                background-color: var(--surface-white);
                border-radius: 16px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.04);
                border: 1px solid var(--border-soft);
                padding: 40px;
                max-width: 860px;
                margin: 0 auto;
            }

            .form-section-title {
                font-size: 13px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.8px;
                color: var(--text-muted);
                margin-bottom: 18px;
                padding-bottom: 8px;
                border-bottom: 1px solid var(--border-soft);
            }

            .form-group { margin-bottom: 22px; }

            .form-label {
                display: block;
                font-weight: 600;
                font-size: 14px;
                color: var(--text-dark);
                margin-bottom: 7px;
            }
            .form-label .req { color: #ef4444; }

            .form-control {
                width: 100%;
                padding: 11px 15px;
                border: 1.5px solid var(--border-soft);
                border-radius: 10px;
                font-size: 14px;
                font-family: 'Outfit', 'Inter', sans-serif;
                background-color: var(--bg-cream);
                color: var(--text-dark);
                transition: border-color 0.25s, background 0.25s;
                outline: none;
                box-sizing: border-box;
            }
            .form-control:focus {
                border-color: var(--primary-green, #22c55e);
                background: white;
            }
            .form-control[readonly] {
                background: #f8f9fb;
                color: var(--text-muted);
                cursor: not-allowed;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 18px;
            }
            .form-row-3 {
                display: grid;
                grid-template-columns: 1fr 1fr 1fr;
                gap: 18px;
            }

            .form-hint {
                font-size: 12px;
                color: var(--text-muted);
                margin-top: 5px;
                display: block;
            }

            .form-actions {
                display: flex;
                gap: 14px;
                margin-top: 32px;
                padding-top: 24px;
                border-top: 1px solid var(--border-soft);
                align-items: center;
            }

            .btn-secondary {
                background: white;
                color: var(--text-dark);
                border: 1.5px solid var(--border-soft);
                padding: 12px 24px;
                border-radius: 50px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                transition: all 0.2s;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-secondary:hover { background: #f1f5f9; border-color: #cbd5e1; }

            /* Toggle switch for IsActive */
            .toggle-wrap {
                display: flex;
                align-items: center;
                gap: 12px;
                padding: 12px 16px;
                background: var(--bg-cream);
                border: 1.5px solid var(--border-soft);
                border-radius: 10px;
            }
            .toggle-wrap label { margin: 0; font-weight: 600; font-size: 14px; cursor: pointer; }
            .switch { position: relative; display: inline-block; width: 46px; height: 24px; }
            .switch input { opacity: 0; width: 0; height: 0; }
            .slider {
                position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0;
                background: #cbd5e1; border-radius: 24px; transition: 0.3s;
            }
            .slider:before {
                content: ""; position: absolute; height: 18px; width: 18px;
                left: 3px; bottom: 3px; background: white; border-radius: 50%; transition: 0.3s;
            }
            input:checked + .slider { background: var(--primary-green, #22c55e); }
            input:checked + .slider:before { transform: translateX(22px); }

            /* Voucher code badge */
            .code-badge {
                display: inline-block;
                background: #f1f5f9;
                border: 1.5px solid var(--border-soft);
                border-radius: 8px;
                padding: 10px 15px;
                font-size: 16px;
                font-weight: 700;
                letter-spacing: 1.5px;
                color: var(--text-dark);
                font-family: 'Courier New', monospace;
                width: 100%;
                box-sizing: border-box;
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
                <jsp:param name="parentUrl"   value="${pageContext.request.contextPath}/admin/vouchers" />
                <jsp:param name="parentMenu2" value="Quản lý Voucher" />
                <jsp:param name="parentUrl2"  value="${pageContext.request.contextPath}/admin/vouchers" />
                <jsp:param name="activeMenu"  value="Chỉnh sửa Voucher" />
            </jsp:include>

            <div class="content">
                <div class="page-header">
                    <div class="page-title">
                        <h2>Chỉnh sửa Voucher</h2>
                        <p>Cập nhật thông tin voucher <strong><c:out value="${editVoucher.voucherCode}"/></strong>.</p>
                    </div>
                </div>

                <!-- Error flash -->
                <c:if test="${not empty error}">
                    <div style="background:#fee2e2;color:#991b1b;padding:12px 20px;border-radius:8px;margin-bottom:20px;border:1px solid #fecaca;">
                        <i class="fa-solid fa-circle-exclamation"></i>
                        <c:choose>
                            <c:when test="${error == 'missing_fields'}">Vui lòng điền đầy đủ các trường bắt buộc.</c:when>
                            <c:when test="${error == 'invalid_discount'}">Giá trị giảm giá không hợp lệ.</c:when>
                            <c:when test="${error == 'invalid_dates'}">Định dạng ngày không hợp lệ. Vui lòng chọn lại.</c:when>
                            <c:when test="${error == 'db_error'}">Lỗi cơ sở dữ liệu. Vui lòng thử lại.</c:when>
                            <c:otherwise>Đã xảy ra lỗi. Vui lòng kiểm tra lại thông tin.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <div class="form-card">
                    <form action="${pageContext.request.contextPath}/admin/vouchers"
                          method="POST" id="voucherEditForm">

                        <!-- Hidden fields: form type + PK -->
                        <input type="hidden" name="formAction"  value="update">
                        <input type="hidden" name="voucherId"   value="${editVoucher.voucherId}">

                        <!-- ── Section 1: Identity ────────────────────────── -->
                        <div class="form-section-title">
                            <i class="fa-solid fa-tag"></i> Thông tin cơ bản
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="voucherCode">
                                    Mã Voucher
                                    <span style="font-weight:400;color:var(--text-muted);font-size:12px;">(không thể thay đổi)</span>
                                </label>
                                <%-- Code is the natural key – show as read-only badge --%>
                                <div class="code-badge">
                                    <c:out value="${editVoucher.voucherCode}"/>
                                </div>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="title">
                                    Tên / Mô tả ngắn <span class="req">*</span>
                                </label>
                                <input type="text" id="title" name="title"
                                       class="form-control"
                                       value="<c:out value='${editVoucher.title}'/>"
                                       placeholder="VD: Giảm 20% đơn từ 200.000₫"
                                       required maxlength="100">
                            </div>
                        </div>

                        <!-- ── Section 2: Discount ────────────────────────── -->
                        <div class="form-section-title" style="margin-top:8px;">
                            <i class="fa-solid fa-percent"></i> Cấu hình giảm giá
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="discountType">
                                    Loại giảm giá <span class="req">*</span>
                                </label>
                                <select id="discountType" name="discountType" class="form-control" required>
                                    <option value="PERCENT" ${editVoucher.discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm (%)</option>
                                    <option value="FIXED"   ${editVoucher.discountType == 'FIXED'   ? 'selected' : ''}>Tiền mặt cố định (₫)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="discountValue">
                                    Giá trị giảm <span class="req">*</span>
                                </label>
                                <input type="number" id="discountValue" name="discountValue"
                                       class="form-control"
                                       value="${editVoucher.discountValue}"
                                       placeholder="VD: 20 (cho %) hoặc 50000 (cho ₫)"
                                       required min="0.01" step="0.01">
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group" id="maxDiscountGroup">
                                <label class="form-label" for="maxDiscountAmount">
                                    Giảm tối đa (₫)
                                    <span style="font-weight:400;color:var(--text-muted);font-size:12px;">(chỉ áp dụng khi loại = %)</span>
                                </label>
                                <input type="number" id="maxDiscountAmount" name="maxDiscountAmount"
                                       class="form-control"
                                       value="${editVoucher.maxDiscountAmount}"
                                       placeholder="VD: 100000"
                                       min="0" step="1000">
                                <span class="form-hint">Để trống = không giới hạn số tiền giảm.</span>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="minOrderValue">
                                    Đơn hàng tối thiểu (₫)
                                </label>
                                <input type="number" id="minOrderValue" name="minOrderValue"
                                       class="form-control"
                                       value="${editVoucher.minOrderValue}"
                                       placeholder="VD: 200000"
                                       min="0" step="1000">
                                <span class="form-hint">Nhập 0 hoặc để trống = áp dụng mọi đơn hàng.</span>
                            </div>
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="voucherScope">
                                    Phạm vi áp dụng (Scope) <span class="req">*</span>
                                </label>
                                <select id="voucherScope" name="voucherScope" class="form-control" required>
                                    <option value="ORDER" ${editVoucher.voucherScope == 'ORDER' ? 'selected' : ''}>Toàn đơn (ORDER)</option>
                                    <option value="SHIPPING" ${editVoucher.voucherScope == 'SHIPPING' ? 'selected' : ''}>Freeship (SHIPPING)</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="requiredTier">
                                    Hạng thành viên áp dụng
                                    <span style="font-weight:400;color:var(--text-muted);font-size:12px;">(Required Tier)</span>
                                </label>
                                <select id="requiredTier" name="requiredTier" class="form-control">
                                    <option value="ALL"     ${empty editVoucher.requiredTier || editVoucher.requiredTier == 'ALL'     ? 'selected' : ''}>Tất cả khách hàng (Default)</option>
                                    <option value="BRONZE"  ${editVoucher.requiredTier == 'BRONZE'  ? 'selected' : ''}>Thành viên Đồng</option>
                                    <option value="SILVER"  ${editVoucher.requiredTier == 'SILVER'  ? 'selected' : ''}>Thành viên Bạc</option>
                                    <option value="GOLD"    ${editVoucher.requiredTier == 'GOLD'    ? 'selected' : ''}>Thành viên Vàng</option>
                                    <option value="DIAMOND" ${editVoucher.requiredTier == 'DIAMOND' ? 'selected' : ''}>Thành viên Kim Cương</option>
                                </select>
                                <span class="form-hint">Giới hạn voucher chỉ dành cho khách đạt hạng được chọn trở lên.</span>
                            </div>
                        </div>

                        <!-- ── Section 3: Validity ────────────────────────── -->
                        <div class="form-section-title" style="margin-top:8px;">
                            <i class="fa-regular fa-calendar"></i> Thời hạn &amp; Giới hạn
                        </div>

                        <div class="form-row-3">
                            <div class="form-group">
                                <label class="form-label" for="startDate">
                                    Ngày bắt đầu <span class="req">*</span>
                                </label>
                                <input type="date" id="startDate" name="startDate"
                                       class="form-control" required
                                       value="<fmt:formatDate value='${editVoucher.startDate}' pattern='yyyy-MM-dd'/>">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="endDate">
                                    Ngày kết thúc <span class="req">*</span>
                                </label>
                                <input type="date" id="endDate" name="endDate"
                                       class="form-control" required
                                       value="<fmt:formatDate value='${editVoucher.endDate}' pattern='yyyy-MM-dd'/>">
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="usageLimit">
                                    Giới hạn lượt dùng
                                </label>
                                <input type="number" id="usageLimit" name="usageLimit"
                                       class="form-control"
                                       value="${editVoucher.usageLimit > 0 ? editVoucher.usageLimit : ''}"
                                       placeholder="VD: 100"
                                       min="1" step="1">
                                <span class="form-hint">Để trống = không giới hạn số lượt sử dụng.</span>
                            </div>
                        </div>

                        <!-- ── Section 4: Status ──────────────────────────── -->
                        <div class="form-section-title" style="margin-top:8px;">
                            <i class="fa-solid fa-toggle-on"></i> Trạng thái
                        </div>

                        <div class="form-group">
                            <div class="toggle-wrap">
                                <label class="switch">
                                    <input type="checkbox" id="isActiveToggle" name="isActiveCheckbox"
                                           onchange="document.getElementById('isActiveHidden').value = this.checked ? 'true' : 'false';"
                                           ${editVoucher.active ? 'checked' : ''}>
                                    <span class="slider"></span>
                                </label>
                                <input type="hidden" id="isActiveHidden" name="isActive"
                                       value="${editVoucher.active ? 'true' : 'false'}">
                                <label for="isActiveToggle">
                                    Kích hoạt voucher
                                </label>
                            </div>
                            <span class="form-hint" style="margin-top:8px;">
                                Nếu tắt, voucher sẽ ở trạng thái vô hiệu và khách hàng không thể sử dụng.
                            </span>
                        </div>

                        <!-- ── Actions ────────────────────────────────────── -->
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary" id="submitBtn">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/vouchers" class="btn btn-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Quay lại
                            </a>
                        </div>

                    </form>
                </div>

            </div><!-- .content -->
        </div><!-- .main-panel -->

        <script>
            // ── Show/hide maxDiscount field based on discount type ──────────
            const typeSelect   = document.getElementById('discountType');
            const maxDiscGroup = document.getElementById('maxDiscountGroup');
            const maxDiscInput = document.getElementById('maxDiscountAmount');

            function handleTypeChange() {
                if (typeSelect.value === 'PERCENT') {
                    maxDiscGroup.style.display = 'block';
                } else {
                    maxDiscGroup.style.display = 'none';
                    maxDiscInput.value = '';
                }
            }
            typeSelect.addEventListener('change', handleTypeChange);
            handleTypeChange();   // Run once on load to reflect the pre-filled value

            // ── Ensure end date >= start date ─────────────────────────────────
            const startDateInput = document.getElementById('startDate');
            const endDateInput   = document.getElementById('endDate');

            startDateInput.addEventListener('change', function () {
                if (endDateInput.value && endDateInput.value < this.value) {
                    endDateInput.value = this.value;
                }
                endDateInput.min = this.value;
            });
            if (startDateInput.value) endDateInput.min = startDateInput.value;

            // ── Form validation before submit ─────────────────────────────────
            document.getElementById('voucherEditForm').addEventListener('submit', function (e) {
                const title = document.getElementById('title').value.trim();
                const type  = document.getElementById('discountType').value;
                const val   = parseFloat(document.getElementById('discountValue').value);
                const start = document.getElementById('startDate').value;
                const end   = document.getElementById('endDate').value;

                if (!title || !type) {
                    e.preventDefault();
                    alert('Vui lòng điền đầy đủ các trường bắt buộc (*).');
                    return;
                }
                if (isNaN(val) || val <= 0) {
                    e.preventDefault();
                    alert('Giá trị giảm giá phải là số dương.');
                    return;
                }
                if (type === 'PERCENT' && val > 100) {
                    e.preventDefault();
                    alert('Phần trăm giảm giá không thể vượt quá 100%.');
                    return;
                }
                if (!start || !end) {
                    e.preventDefault();
                    alert('Vui lòng chọn ngày bắt đầu và ngày kết thúc.');
                    return;
                }
                if (end < start) {
                    e.preventDefault();
                    alert('Ngày kết thúc phải sau hoặc bằng ngày bắt đầu.');
                    return;
                }
            });
        </script>

    </body>
</html>
