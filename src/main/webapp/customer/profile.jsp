<%-- 
    Document   : profile
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <style>
            /* ===== PROFILE PAGE ===== */

            .profile-page {
                max-width: 1180px;
                margin: 0 auto;
                padding: 110px 32px 90px;
            }

            .profile-card {
                background-color: var(--white);
                border-radius: 22px;
                padding: 48px 54px;
                box-shadow: var(--shadow);
            }

            .profile-title {
                display: flex;
                align-items: center;
                gap: 18px;
                margin-bottom: 34px;
                color: var(--text);
            }

            .profile-title i {
                font-size: 34px;
                color: var(--primary);
            }

            .profile-title h1 {
                margin: 0;
                font-size: 34px;
                font-weight: 800;
            }

            .profile-form {
                width: 100%;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                color: var(--text);
                font-size: 16px;
                font-weight: 700;
            }

            .required {
                color: #d62828;
            }

            .form-control {
                width: 100%;
                height: 56px;
                border: 1px solid var(--border);
                border-radius: 10px;
                background-color: var(--white);
                color: var(--text);
                font-size: 16px;
                padding: 0 16px;
                outline: none;
                box-sizing: border-box;
            }

            .form-control:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(21, 92, 46, 0.1);
            }

            .form-control[readonly] {
                background-color: #f7f5ef;
                color: var(--text-muted);
                cursor: not-allowed;
            }

            .form-note {
                margin-top: 8px;
                color: var(--text-muted);
                font-size: 14px;
            }

            .alert {
                margin-bottom: 28px;
                padding: 12px 16px;
                border-radius: 10px;
                font-weight: 600;
            }

            .profile-error {
                color: #d62828;
                background-color: #fff0f0;
                border: 1px solid #f5b5b5;
            }

            .profile-success {
                color: #155c2e;
                background-color: #eefaf1;
                border: 1px solid #b8e6c4;
            }

            .change-password-toggle {
                width: fit-content;
                padding: 10px 18px;
                border: none;
                border-radius: 10px;
                background-color: var(--primary);
                color: white;
                font-weight: 600;
                cursor: pointer;
            }

            .change-password-toggle:hover {
                opacity: 0.9;
            }

            .password-box {
                margin-top: 18px;
                padding: 18px;
                border: 1px solid #ead8c7;
                border-radius: 14px;
                background-color: #fffaf5;
            }

            .profile-actions {
                display: flex;
                justify-content: flex-end;
                gap: 14px;
                margin-top: 18px;
            }

            .btn-cancel,
            .btn-update {
                min-width: 140px;
                height: 52px;
                border: none;
                border-radius: 9px;
                color: white;
                font-size: 16px;
                font-weight: 700;
                cursor: pointer;
            }

            .btn-cancel {
                background-color: #6c757d;
            }

            .btn-update {
                background-color: var(--primary);
            }

            .btn-cancel:hover {
                background-color: #5c636a;
            }

            .btn-update:hover {
                background-color: #104823;
            }

            .btn-update i {
                margin-right: 8px;
            }

            @media (max-width: 768px) {
                .profile-page {
                    padding: 32px 18px 70px;
                }

                .profile-card {
                    padding: 32px 24px;
                }

                .profile-title h1 {
                    font-size: 28px;
                }

                .form-row {
                    grid-template-columns: 1fr;
                    gap: 0;
                }

                .profile-actions {
                    flex-direction: column;
                }

                .btn-cancel,
                .btn-update {
                    width: 100%;
                }
            }

            .show-password-row {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-top: -6px;
                color: var(--text);
                font-size: 15px;
                font-weight: 500;
                cursor: pointer;
            }

            .show-password-row input {
                cursor: pointer;
            }

            .address-profile-box {
                margin-top: 10px;
                margin-bottom: 24px;
                padding: 18px;
                border: 1px solid #ead8c7;
                border-radius: 14px;
                background-color: #fffaf5;
            }

            .address-profile-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 16px;
            }

            .address-profile-title h3 {
                margin: 0 0 6px;
                color: var(--text);
                font-size: 20px;
                font-weight: 800;
            }

            .address-profile-title p {
                margin: 0;
                color: var(--text-muted);
                font-size: 15px;
            }

            .btn-address-manage {
                min-width: 170px;
                height: 46px;
                border-radius: 9px;
                background-color: var(--primary);
                color: white;
                text-decoration: none;
                font-weight: 700;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .btn-address-manage:hover {
                color: white;
                opacity: 0.9;
            }

            @media (max-width: 768px) {
                .address-profile-header {
                    flex-direction: column;
                    align-items: flex-start;
                }

                .btn-address-manage {
                    width: 100%;
                }
            }

        </style>
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="profile-page">
            <div class="profile-card">

                <div class="profile-title">
                    <i class="fa fa-user-edit"></i>
                    <h1>Thông tin cá nhân</h1>
                </div>

                <% if (request.getAttribute("successMessage") != null) { %>
                <div class="alert profile-success">
                    ✓ <%= request.getAttribute("successMessage") %>
                </div>
                <% } %>

                <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert profile-error">
                    <%= request.getAttribute("errorMessage") %>
                </div>
                <% } %>

                <form id="profileForm"
                      class="profile-form"
                      action="${pageContext.request.contextPath}/profile"
                      method="post">

                    <!-- Dùng để reset về thông tin gốc khi bấm Hủy -->
                    <input type="hidden" id="originalFullName" value="${sessionScope.user.fullName}">
                    <input type="hidden" id="originalPhone" value="${sessionScope.user.phone}">

                    <!-- Giữ address cũ để servlet không update address thành null -->
                    <input type="hidden" name="address" value="${sessionScope.user.defaultAddress}">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Họ và tên <span class="required">*</span></label>
                            <input type="text"
                                   name="fullName"
                                   class="form-control"
                                   value="${requestScope.inputFullName != null ? requestScope.inputFullName : sessionScope.user.fullName}"
                                   maxlength="30"
                                   placeholder="Nhập họ và tên của bạn">
                        </div>

                        <div class="form-group">
                            <label>Số điện thoại <span class="required">*</span></label>
                            <input type="text"
                                   name="phone"
                                   class="form-control"
                                   value="${requestScope.inputPhone != null ? requestScope.inputPhone : sessionScope.user.phone}"
                                   maxlength="10"
                                   placeholder="Nhập số điện thoại">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email"
                               name="email"
                               class="form-control"
                               value="${sessionScope.user.email}"
                               readonly>
                        <div class="form-note">Email dùng để đăng nhập và không thể thay đổi tại đây.</div>
                    </div>

                    <div class="address-profile-box">
                        <div class="address-profile-header">
                            <div class="address-profile-title">
                                <h3>Địa chỉ giao hàng</h3>
                                <p>${sessionScope.user.defaultAddress != null ? sessionScope.user.defaultAddress : 'Chưa thiết lập địa chỉ mặc định. Vui lòng thêm địa chỉ.'}</p>
                            </div>

                            <a href="${pageContext.request.contextPath}/delivery-address"
                               class="btn-address-manage">
                                Quản lý địa chỉ
                            </a>
                        </div>
                    </div>           

                    <div class="form-group">
                        <label>Mật khẩu</label>

                        <button type="button"
                                class="change-password-toggle"
                                onclick="togglePasswordBox()">
                            Đổi mật khẩu
                        </button>

                        <div id="passwordBox"
                             class="password-box"
                             style="display: <%= request.getAttribute("showPasswordBox") != null ? "block" : "none" %>;">

                            <div class="form-group">
                                <label>Mật khẩu hiện tại</label>
                                <input type="password"
                                       id="currentPassword"
                                       name="currentPassword"
                                       class="form-control"
                                       value="${requestScope.inputCurrentPassword != null ? requestScope.inputCurrentPassword : ''}"
                                       placeholder="Nhập mật khẩu hiện tại">
                            </div>

                            <div class="form-group">
                                <label>Mật khẩu mới</label>
                                <input type="password"
                                       id="newPassword"
                                       name="newPassword"
                                       class="form-control"
                                       maxlength="20"
                                       value="${requestScope.inputNewPassword != null ? requestScope.inputNewPassword : ''}"
                                       placeholder="Nhập mật khẩu mới">
                            </div>

                            <div class="form-group">
                                <label>Xác nhận mật khẩu mới</label>
                                <input type="password"
                                       id="confirmPassword"
                                       name="confirmPassword"
                                       class="form-control"
                                       maxlength="20"
                                       value="${requestScope.inputConfirmPassword != null ? requestScope.inputConfirmPassword : ''}"
                                       placeholder="Nhập lại mật khẩu mới">
                            </div>

                            <label class="show-password-row">
                                <input type="checkbox" id="showPassword" onchange="toggleAllPasswords()">
                                Hiển thị mật khẩu
                            </label>           

                        </div>
                    </div>

                    <div class="profile-actions">
                        <button type="button"
                                class="btn-cancel"
                                onclick="resetProfileForm()">
                            Hủy
                        </button>

                        <button type="submit" class="btn-update">
                            <i class="fa fa-save"></i>
                            Cập nhật
                        </button>
                    </div>

                </form>

            </div>
        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script>
            function togglePasswordBox() {
                const box = document.getElementById("passwordBox");
                box.style.display = box.style.display === "none" ? "block" : "none";
            }

            function toggleAllPasswords() {
                const type = document.getElementById("showPassword").checked ? "text" : "password";

                document.getElementById("currentPassword").type = type;
                document.getElementById("newPassword").type = type;
                document.getElementById("confirmPassword").type = type;
            }

            function resetProfileForm() {
                document.querySelector('input[name="fullName"]').value =
                        document.getElementById("originalFullName").value;

                document.querySelector('input[name="phone"]').value =
                        document.getElementById("originalPhone").value;

                document.getElementById("currentPassword").value = "";
                document.getElementById("newPassword").value = "";
                document.getElementById("confirmPassword").value = "";

                document.getElementById("currentPassword").type = "password";
                document.getElementById("newPassword").type = "password";
                document.getElementById("confirmPassword").type = "password";

                document.getElementById("showPassword").checked = false;
                document.getElementById("passwordBox").style.display = "none";
            }
        </script>

    </body>
</html>