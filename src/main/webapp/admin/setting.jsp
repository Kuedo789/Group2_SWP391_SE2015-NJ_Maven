<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Cài đặt hệ thống" />
    </jsp:include>

</head>
<body>

    <jsp:include page="/common/sidebar.jsp">
        <jsp:param name="activeMenu" value="settings" />
    </jsp:include>

    <div class="main-panel">
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="activeMenu" value="Cài đặt hệ thống" />
        </jsp:include>

        <div class="content-container">
            
            <div style="margin-bottom: 30px;">
                <h1 style="font-family: 'Playfair Display', serif; font-size: 32px; font-weight: 700; color: #2c3e2b; margin: 0;">Cài đặt hệ thống</h1>
            </div>

            <form action="${pageContext.request.contextPath}/admin/settings" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="activeTab" id="activeTabInput" value="general" />
                
                <div class="settings-tabs">
                    <button type="button" class="tab-btn active" onclick="switchTab('general')">Cài đặt chung</button>
                    <button type="button" class="tab-btn" onclick="switchTab('order-delivery')">Đặt hàng & Giao hàng</button>
                    <button type="button" class="tab-btn" onclick="switchTab('email-otp')">Email & OTP</button>
                    <button type="button" class="tab-btn" onclick="switchTab('theme-interface')">Giao diện & Banner</button>
                </div>

                <!-- Tab 1: Cài đặt chung -->
                <div id="tab-general" class="tab-content active-tab-content">
                    <div class="settings-card">
                        <div class="settings-card-header">Cài đặt chung</div>
                        <div class="settings-card-body">
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label>Tên tiệm bánh</label>
                                    <input type="text" name="bakeryName" value="${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}" class="settings-input" required maxlength="10" />
                                </div>
                            </div>
                            <div class="form-row form-cols-2">
                                <div class="form-group">
                                    <label>Hotline hỗ trợ</label>
                                    <input type="text" name="hotline" value="${not empty settings.hotline ? settings.hotline : '0901234567'}" class="settings-input" required pattern="^0[0-9]{9}$" title="Số điện thoại phải bắt đầu bằng 0 và có đúng 10 chữ số" />
                                </div>
                                <div class="form-group">
                                    <label>Email hỗ trợ</label>
                                    <input type="email" name="email" value="${not empty settings.email ? settings.email : 'support@bakeryzone.vn'}" class="settings-input" required />
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label>Địa chỉ tiệm bánh</label>
                                    <input type="text" name="address" value="${not empty settings.address ? settings.address : '123 Đường Sourdough, TP. Hồ Chí Minh'}" class="settings-input" required />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab 2: Đặt hàng & Giao hàng -->
                <div id="tab-order-delivery" class="tab-content">
                    <div class="settings-card">
                        <div class="settings-card-header">Quy tắc đặt hàng & Giao hàng</div>
                        <div class="settings-card-body">
                            <div class="form-row form-cols-3">
                                <div class="form-group">
                                    <label>Tỷ lệ đặt cọc bánh thiết kế (%)</label>
                                    <input type="number" name="depositPercent" value="${not empty settings.depositPercent ? settings.depositPercent : '30'}" class="settings-input" required min="0" max="100" />
                                </div>
                                <div class="form-group">
                                    <label>Đơn giá ship/km</label>
                                    <input type="number" name="shippingRate" value="${not empty settings.shippingRate ? settings.shippingRate : '5000'}" class="settings-input" required min="0" step="any" />
                                </div>

                            </div>
                            <div class="form-row form-cols-2">
                                <div class="form-group">
                                    <label>Giờ mở cửa</label>
                                    <div class="input-icon-wrapper">
                                        <input type="text" name="openingTime" value="${not empty settings.openingTime ? settings.openingTime : '07:00 AM'}" class="settings-input" required />
                                        <i class="fa-regular fa-clock input-icon"></i>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Giờ đóng cửa</label>
                                    <div class="input-icon-wrapper">
                                        <input type="text" name="closingTime" value="${not empty settings.closingTime ? settings.closingTime : '09:00 PM'}" class="settings-input" required />
                                        <i class="fa-regular fa-clock input-icon"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab 3: Email & OTP -->
                <div id="tab-email-otp" class="tab-content">
                    <div class="settings-card">
                        <div class="settings-card-header">Cấu hình Hệ thống Email & OTP</div>
                        <div class="settings-card-body">
                            <div class="form-row form-cols-2">
                                <div class="form-group">
                                    <label>Email gửi hệ thống</label>
                                    <input type="email" name="systemEmail" value="${not empty settings.systemEmail ? settings.systemEmail : 'system@bakeryzone.vn'}" class="settings-input" required />
                                </div>
                                <div class="form-group">
                                    <label>Mật khẩu ứng dụng</label>
                                    <div class="password-wrapper">
                                        <input type="password" id="appPassword" name="appPassword" value="${not empty settings.appPassword ? settings.appPassword : 'app_password_secret'}" class="settings-input" required />
                                        <i class="fa-regular fa-eye password-toggle" onclick="togglePasswordVisibility()"></i>
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group half-width">
                                    <label>Thời gian hiệu lực OTP (phút)</label>
                                    <input type="number" name="otpExpiry" value="${not empty settings.otpExpiry ? settings.otpExpiry : '5'}" class="settings-input" required min="1" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab 4: Giao diện & Banner -->
                <div id="tab-theme-interface" class="tab-content">
                    <div class="settings-card">
                        <div class="settings-card-header">Cấu hình Giao diện</div>
                        <div class="settings-card-body">
                            <div class="form-row" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px;">
                                <div class="form-group">
                                    <label>Banner 1 (Tải tệp lên)</label>
                                    <div class="file-upload-wrapper">
                                        <label class="btn-file-upload">
                                            Choose File
                                            <input type="file" name="banner1" onchange="updateFileName(this)" />
                                        </label>
                                        <span class="file-name-display">
                                            <c:choose>
                                                <c:when test="${not empty settings.banner1}">
                                                    ${settings.banner1.substring(settings.banner1.lastIndexOf('/') + 1)}
                                                </c:when>
                                                <c:otherwise>hero-1.jpg</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="banner-preview-wrap" style="margin-top: 8px;">
                                        <img src="${pageContext.request.contextPath}/${not empty settings.banner1 ? settings.banner1 : 'assets/images/hero/hero-1.jpg'}" 
                                             alt="Banner 1" 
                                             style="width: 100%; aspect-ratio: 1180 / 560; object-fit: cover; border-radius: 6px; border: 1px solid var(--cz-border-color);
                                                    object-position: center ${not empty settings.banner1Align ? settings.banner1Align : '50'}%;" />
                                    </div>
                                    <div style="margin-top: 8px; display: flex; flex-direction: column; gap: 4px;">
                                        <div style="display: flex; justify-content: space-between; align-items: center;">
                                            <span style="font-size: 11px; font-weight: 500; color: var(--text-muted);">Căn dọc: <span id="banner1AlignVal" style="font-weight: 700;">${not empty settings.banner1Align ? settings.banner1Align : '50'}%</span></span>
                                        </div>
                                        <input type="range" name="banner1Align" min="0" max="100" 
                                               value="${not empty settings.banner1Align ? settings.banner1Align : '50'}" 
                                               oninput="updateBannerPosition(this, 1)" 
                                               style="width: 100%; accent-color: var(--cz-primary); height: 6px; border-radius: 4px; outline: none; background: #e5e7eb; cursor: pointer;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Banner 2 (Tải tệp lên)</label>
                                    <div class="file-upload-wrapper">
                                        <label class="btn-file-upload">
                                            Choose File
                                            <input type="file" name="banner2" onchange="updateFileName(this)" />
                                        </label>
                                        <span class="file-name-display">
                                            <c:choose>
                                                <c:when test="${not empty settings.banner2}">
                                                    ${settings.banner2.substring(settings.banner2.lastIndexOf('/') + 1)}
                                                </c:when>
                                                <c:otherwise>hero-2.jpg</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="banner-preview-wrap" style="margin-top: 8px;">
                                        <img src="${pageContext.request.contextPath}/${not empty settings.banner2 ? settings.banner2 : 'assets/images/hero/hero-2.jpg'}" 
                                             alt="Banner 2" 
                                             style="width: 100%; aspect-ratio: 1180 / 560; object-fit: cover; border-radius: 6px; border: 1px solid var(--cz-border-color);
                                                    object-position: center ${not empty settings.banner2Align ? settings.banner2Align : '50'}%;" />
                                    </div>
                                    <div style="margin-top: 8px; display: flex; flex-direction: column; gap: 4px;">
                                        <div style="display: flex; justify-content: space-between; align-items: center;">
                                            <span style="font-size: 11px; font-weight: 500; color: var(--text-muted);">Căn dọc: <span id="banner2AlignVal" style="font-weight: 700;">${not empty settings.banner2Align ? settings.banner2Align : '50'}%</span></span>
                                        </div>
                                        <input type="range" name="banner2Align" min="0" max="100" 
                                               value="${not empty settings.banner2Align ? settings.banner2Align : '50'}" 
                                               oninput="updateBannerPosition(this, 2)" 
                                               style="width: 100%; accent-color: var(--cz-primary); height: 6px; border-radius: 4px; outline: none; background: #e5e7eb; cursor: pointer;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Banner 3 (Tải tệp lên)</label>
                                    <div class="file-upload-wrapper">
                                        <label class="btn-file-upload">
                                            Choose File
                                            <input type="file" name="banner3" onchange="updateFileName(this)" />
                                        </label>
                                        <span class="file-name-display">
                                            <c:choose>
                                                <c:when test="${not empty settings.banner3}">
                                                    ${settings.banner3.substring(settings.banner3.lastIndexOf('/') + 1)}
                                                </c:when>
                                                <c:otherwise>hero-3.jpg</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="banner-preview-wrap" style="margin-top: 8px;">
                                        <img src="${pageContext.request.contextPath}/${not empty settings.banner3 ? settings.banner3 : 'assets/images/hero/hero-3.jpg'}" 
                                             alt="Banner 3" 
                                             style="width: 100%; aspect-ratio: 1180 / 560; object-fit: cover; border-radius: 6px; border: 1px solid var(--cz-border-color);
                                                    object-position: center ${not empty settings.banner3Align ? settings.banner3Align : '50'}%;" />
                                    </div>
                                    <div style="margin-top: 8px; display: flex; flex-direction: column; gap: 4px;">
                                        <div style="display: flex; justify-content: space-between; align-items: center;">
                                            <span style="font-size: 11px; font-weight: 500; color: var(--text-muted);">Căn dọc: <span id="banner3AlignVal" style="font-weight: 700;">${not empty settings.banner3Align ? settings.banner3Align : '50'}%</span></span>
                                        </div>
                                        <input type="range" name="banner3Align" min="0" max="100" 
                                               value="${not empty settings.banner3Align ? settings.banner3Align : '50'}" 
                                               oninput="updateBannerPosition(this, 3)" 
                                               style="width: 100%; accent-color: var(--cz-primary); height: 6px; border-radius: 4px; outline: none; background: #e5e7eb; cursor: pointer;" />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Banner 4 (Tải tệp lên)</label>
                                    <div class="file-upload-wrapper">
                                        <label class="btn-file-upload">
                                            Choose File
                                            <input type="file" name="banner4" onchange="updateFileName(this)" />
                                        </label>
                                        <span class="file-name-display">
                                            <c:choose>
                                                <c:when test="${not empty settings.banner4}">
                                                    ${settings.banner4.substring(settings.banner4.lastIndexOf('/') + 1)}
                                                </c:when>
                                                <c:otherwise>hero-4.jpg</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </div>
                                    <div class="banner-preview-wrap" style="margin-top: 8px;">
                                        <img src="${pageContext.request.contextPath}/${not empty settings.banner4 ? settings.banner4 : 'assets/images/hero/hero-4.jpg'}" 
                                             alt="Banner 4" 
                                             style="width: 100%; aspect-ratio: 1180 / 560; object-fit: cover; border-radius: 6px; border: 1px solid var(--cz-border-color);
                                                    object-position: center ${not empty settings.banner4Align ? settings.banner4Align : '50'}%;" />
                                    </div>
                                    <div style="margin-top: 8px; display: flex; flex-direction: column; gap: 4px;">
                                        <div style="display: flex; justify-content: space-between; align-items: center;">
                                            <span style="font-size: 11px; font-weight: 500; color: var(--text-muted);">Căn dọc: <span id="banner4AlignVal" style="font-weight: 700;">${not empty settings.banner4Align ? settings.banner4Align : '50'}%</span></span>
                                        </div>
                                        <input type="range" name="banner4Align" min="0" max="100" 
                                               value="${not empty settings.banner4Align ? settings.banner4Align : '50'}" 
                                               oninput="updateBannerPosition(this, 4)" 
                                               style="width: 100%; accent-color: var(--cz-primary); height: 6px; border-radius: 4px; outline: none; background: #e5e7eb; cursor: pointer;" />
                                    </div>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label>Tiêu đề ảnh Banner trang chủ</label>
                                    <input type="text" name="heroTitle" value="${not empty settings.heroTitle ? settings.heroTitle : ''}" class="settings-input" placeholder="Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc" />
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group full-width">
                                    <label>Mô tả phụ ảnh Banner trang chủ</label>
                                    <textarea name="heroSubtitle" class="settings-textarea" placeholder="Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng được làm thủ công từ nguyên liệu tự nhiên...">${not empty settings.heroSubtitle ? settings.heroSubtitle : ''}</textarea>
                                </div>
                            </div>
                            <div class="form-row" style="margin-top: 15px; display: flex; justify-content: space-between; align-items: center;">
                                <span style="font-size: 14px; font-weight: 500; color: var(--text-dark);">Giao diện sáng/ tối</span>
                                <label class="switch-toggle">
                                    <input type="checkbox" name="darkMode" ${settings.darkMode ? 'checked' : ''} />
                                    <span class="switch-slider"></span>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bottom Actions -->
                <div class="form-actions" style="display: flex; justify-content: flex-end; gap: 15px; margin-top: 30px; margin-bottom: 50px;">
                    <button type="button" id="btnResetDefaults" class="btn-cancel" style="background-color: #f0f7f0; color: #2e5a2e; border: 1px solid #c2e5c2;">Đặt về mặc định</button>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn-cancel" style="background-color: #fff0f0; color: #b73a3a; border: 1px solid #f5c2c2; display: inline-flex; align-items: center; justify-content: center; text-decoration: none;">Hủy bỏ</a>
                    <button type="submit" class="btn-save">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        // ==============================
        // 2. Hiện/ẩn mật khẩu ứng dụng
        // ==============================
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById("appPassword");
            const toggleIcon = document.querySelector(".password-toggle");
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            } else {
                passwordInput.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            }
        }

        // ==============================
        // 3. Hiển thị tên file banner
        // ==============================
        function updateFileName(input) {
            const wrapper = input.closest(".file-upload-wrapper");
            const display = wrapper.querySelector(".file-name-display");
            display.textContent = input.files.length > 0 ? input.files[0].name : "No file chosen";

            // Live image preview
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewImg = input.closest(".form-group").querySelector("img");
                    if (previewImg) {
                        previewImg.src = e.target.result;
                    }
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        // ==============================
        // 3.5. Cập nhật vị trí ảnh xem trước động
        // ==============================
        function updateBannerPosition(slider, index) {
            const percentage = slider.value + "%";
            const valSpan = document.getElementById("banner" + index + "AlignVal");
            if (valSpan) valSpan.textContent = percentage;
            
            const previewImg = slider.closest(".form-group").querySelector("img");
            if (previewImg) {
                previewImg.style.objectPosition = "center " + percentage;
            }
        }

        // ==============================
        // 4. Dark Mode Live Toggle
        // ==============================
        const darkModeToggle = document.querySelector('input[name="darkMode"]');
        if (darkModeToggle) {
            darkModeToggle.addEventListener('change', function() {
                if (this.checked) {
                    document.documentElement.classList.add('dark-theme');
                } else {
                    document.documentElement.classList.remove('dark-theme');
                }
            });
        }

        // ==============================
        // 5. Validate inline từng trường
        // ==============================
        function showError(input, message) {
            clearError(input);
            input.style.borderColor = '#dc3545';
            const errEl = document.createElement('div');
            errEl.className = 'field-error-msg';
            errEl.style.cssText = 'color:#dc3545;font-size:12px;margin-top:5px;display:flex;align-items:center;gap:5px;';
            errEl.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> ' + message;
            input.parentNode.appendChild(errEl);
        }

        function clearError(input) {
            input.style.borderColor = '';
            const existing = input.parentNode.querySelector('.field-error-msg');
            if (existing) existing.remove();
        }

        function showSuccess(input) {
            clearError(input);
            input.style.borderColor = '#28a745';
        }

        function validateBakeryName() {
            const input = document.querySelector('input[name="bakeryName"]');
            const val = input.value.trim();
            if (!val) { showError(input, 'Tên tiệm bánh không được để trống.'); return false; }
            if (val.length > 10) { showError(input, 'Tên tiệm bánh không được vượt quá 10 ký tự.'); return false; }
            showSuccess(input); return true;
        }

        function validateHotline() {
            const input = document.querySelector('input[name="hotline"]');
            const val = input.value.trim();
            if (!val) { showError(input, 'Hotline không được để trống.'); return false; }
            if (!/^0[0-9]{9}$/.test(val)) { showError(input, 'Hotline phải bắt đầu bằng số 0 và có đúng 10 chữ số liền (không dấu cách).'); return false; }
            const digits = val.substring(1);
            if (/^(.)\1{8}$/.test(digits)) { showError(input, 'Hotline không hợp lệ (không được trùng lặp liên tiếp các chữ số).'); return false; }
            showSuccess(input); return true;
        }

        function validateEmail(name, label) {
            const input = document.querySelector('input[name="' + name + '"]');
            const val = input.value.trim();
            if (!val) { showError(input, label + ' không được để trống.'); return false; }
            if (!/^[A-Za-z0-9+_.-]+@[A-Za-z]+\.[A-Za-z.]+$/.test(val)) {
                showError(input, label + ' không hợp lệ. Tên miền sau @ chỉ được chứa chữ cái (vd: @gmail.com).'); return false;
            }
            showSuccess(input); return true;
        }

        function validateNumber(name, label, min, max, isDecimal) {
            const input = document.querySelector('input[name="' + name + '"]');
            const val = input.value.trim();
            if (!val) { showError(input, label + ' không được để trống.'); return false; }
            const num = isDecimal ? parseFloat(val) : parseInt(val, 10);
            if (isNaN(num)) { showError(input, label + ' phải là một số hợp lệ.'); return false; }
            if (min !== null && num < min) { showError(input, label + ' phải lớn hơn hoặc bằng ' + min + '.'); return false; }
            if (max !== null && num > max) { showError(input, label + ' phải nhỏ hơn hoặc bằng ' + max + '.'); return false; }
            showSuccess(input); return true;
        }

        function validatePassword() {
            const input = document.getElementById('appPassword');
            const val = input.value.trim();
            if (!val) { showError(input, 'Mật khẩu ứng dụng không được để trống.'); return false; }
            showSuccess(input); return true;
        }

        // Gắn sự kiện blur để validate ngay khi rời khỏi trường
        document.querySelector('input[name="bakeryName"]').addEventListener('blur', validateBakeryName);
        document.querySelector('input[name="hotline"]').addEventListener('blur', validateHotline);
        document.querySelector('input[name="email"]').addEventListener('blur', () => validateEmail('email', 'Email hỗ trợ'));
        document.querySelector('input[name="systemEmail"]').addEventListener('blur', () => validateEmail('systemEmail', 'Email gửi hệ thống'));
        document.querySelector('input[name="depositPercent"]').addEventListener('blur', () => validateNumber('depositPercent', 'Phần trăm đặt cọc', 0, 100, false));
        document.querySelector('input[name="shippingRate"]').addEventListener('blur', () => validateNumber('shippingRate', 'Đơn giá ship', 0, null, true));

        document.querySelector('input[name="otpExpiry"]').addEventListener('blur', () => validateNumber('otpExpiry', 'Thời gian OTP', 1, null, false));
        document.getElementById('appPassword').addEventListener('blur', validatePassword);

        // ==============================
        // 6. Nút "Đặt về mặc định"
        // ==============================
        var isResetSubmit = false;
        document.getElementById('btnResetDefaults').addEventListener('click', function() {
            if (!confirm('Bạn có chắc chắn muốn đặt lại tất cả cài đặt hệ thống về mặc định không?')) return;
            isResetSubmit = true;
            // Thêm hidden input resetDefaults=true rồi submit
            var hiddenInput = document.createElement('input');
            hiddenInput.type = 'hidden';
            hiddenInput.name = 'resetDefaults';
            hiddenInput.value = 'true';
            document.querySelector('form').appendChild(hiddenInput);
            document.querySelector('form').submit();
        });

        // Validate toàn bộ trước khi submit (chỉ khi bấm Lưu, không phải Reset)
        document.querySelector('form').addEventListener('submit', function(e) {
            // Bỏ qua validate nếu đang reset về mặc định
            if (isResetSubmit) return;

            const isValid =
                validateBakeryName() &
                validateHotline() &
                validateEmail('email', 'Email hỗ trợ') &
                validateEmail('systemEmail', 'Email gửi hệ thống') &
                validateNumber('depositPercent', 'Phần trăm đặt cọc', 0, 100, false) &
                validateNumber('shippingRate', 'Đơn giá ship', 0, null, true) &

                validateNumber('otpExpiry', 'Thời gian OTP', 1, null, false) &
                validatePassword();

            if (!isValid) {
                e.preventDefault();
                const firstError = document.querySelector('.field-error-msg');
                if (firstError) {
                    const tabContent = firstError.closest('.tab-content');
                    if (tabContent) {
                        const tabId = tabContent.id.replace('tab-', '');
                        switchTab(tabId);
                    }
                    setTimeout(() => {
                        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }, 100);
                }
                showFloatingAlert("⚠️ Vui lòng kiểm tra lại thông tin nhập. Có trường chưa hợp lệ!", 'error');
            }
        });

        // Tab Switching Logic
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(el => {
                el.style.display = 'none';
                el.classList.remove('active-tab-content');
            });
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });

            const activeContent = document.getElementById('tab-' + tabId);
            if (activeContent) {
                activeContent.style.display = 'block';
                activeContent.classList.add('active-tab-content');
            }

            const activeBtn = document.querySelector(`[onclick="switchTab('${tabId}')"]`);
            if (activeBtn) {
                activeBtn.classList.add('active');
            }

            const activeTabInput = document.getElementById('activeTabInput');
            if (activeTabInput) {
                activeTabInput.value = tabId;
            }
        }

        // Initialize default tab
        const urlParams = new URLSearchParams(window.location.search);
        const activeTabParam = urlParams.get('activeTab') || '${param.activeTab}';
        if (activeTabParam && ['general', 'order-delivery', 'email-otp', 'theme-interface'].includes(activeTabParam)) {
            switchTab(activeTabParam);
        } else {
            switchTab('general');
        }
    </script>
</body>
</html>

