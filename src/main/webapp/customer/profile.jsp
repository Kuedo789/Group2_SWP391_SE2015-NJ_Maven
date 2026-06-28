<%-- 
    Document   : profile
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/profile.css">
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="profile-page">
            <div class="profile-card">

                <div class="profile-title">
                    <i class="fa fa-user-edit"></i>
                    <h1>Thông tin cá nhân</h1>
                </div>

                <c:if test="${not empty successMessage}">
                <div class="alert profile-success">
                    ✓ ${successMessage}
                </div>
                </c:if>

                <div id="errorBox" class="alert profile-error" style="display: ${not empty errorMessage ? 'block' : 'none'};">
                    ${errorMessage}
                </div>

                <form id="profileForm"
                      class="profile-form"
                      action="${pageContext.request.contextPath}/profile"
                      method="post">



                    <div class="form-row">
                        <div class="form-group">
                            <label>Họ và tên <span class="required">*</span></label>
                            <input type="text"
                                   name="fullName"
                                   class="form-control"
                                   value="${not empty param.fullName ? param.fullName : sessionScope.user.fullName}"
                                   maxlength="30"
                                   placeholder="Nhập họ và tên của bạn">
                        </div>

                        <div class="form-group">
                            <label>Số điện thoại <span class="required">*</span></label>
                            <input type="text"
                                   name="phone"
                                   class="form-control"
                                   value="${not empty param.phone ? param.phone : sessionScope.user.phone}"
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
                                <p>${not empty sessionScope.user.defaultAddress ? sessionScope.user.defaultAddress : 'Chưa thiết lập địa chỉ mặc định. Vui lòng thêm địa chỉ.'}</p>
                            </div>

                            <a href="${pageContext.request.contextPath}/delivery-address?action=profile"
                               class="btn-address-manage">
                                Đổi địa chỉ &rsaquo;
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
                             style="display: ${not empty showPasswordBox ? 'block' : 'none'};">

                            <div class="form-group">
                                <label>Mật khẩu hiện tại</label>
                                <input type="password"
                                       id="currentPassword"
                                       name="currentPassword"
                                       class="form-control"
                                       value="${param.currentPassword}"
                                       placeholder="Nhập mật khẩu hiện tại">
                            </div>

                            <div class="form-group">
                                <label>Mật khẩu mới</label>
                                <input type="password"
                                       id="newPassword"
                                       name="newPassword"
                                       class="form-control"
                                       maxlength="20"
                                       value="${param.newPassword}"
                                       placeholder="Nhập mật khẩu mới">
                            </div>

                            <div class="form-group">
                                <label>Xác nhận mật khẩu mới</label>
                                <input type="password"
                                       id="confirmPassword"
                                       name="confirmPassword"
                                       class="form-control"
                                       maxlength="20"
                                       value="${param.confirmPassword}"
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
                document.getElementById('profileForm').reset();
                document.getElementById("passwordBox").style.display = "none";
                document.getElementById("showPassword").checked = false;
                toggleAllPasswords();
                
                const errorBox = document.getElementById("errorBox");
                if (errorBox) {
                    errorBox.style.display = "none";
                    errorBox.innerHTML = "";
                }
            }

            document.getElementById('profileForm').addEventListener('submit', function(e) {
                const errorBox = document.getElementById("errorBox");
                const showError = (msg) => {
                    errorBox.innerHTML = msg;
                    errorBox.style.display = 'block';
                    e.preventDefault();
                    errorBox.scrollIntoView({ behavior: 'smooth', block: 'center' });
                };

                const fullName = document.querySelector('input[name="fullName"]').value.trim();
                const phone = document.querySelector('input[name="phone"]').value.trim();
                
                const currentPassword = document.getElementById('currentPassword').value.trim();
                const newPassword = document.getElementById('newPassword').value.trim();
                const confirmPassword = document.getElementById('confirmPassword').value.trim();

                // 1. Validate họ tên
                if (!fullName) {
                    return showError("Vui lòng nhập họ và tên.");
                }
                if (fullName.length > 30) {
                    return showError("Họ và tên không được quá 30 ký tự.");
                }
                if (fullName.includes("  ")) {
                    return showError("Họ và tên không được có quá 1 khoảng trắng liên tiếp.");
                }
                const nameRegex = /^[\p{L}]+( [\p{L}]+)*$/u;
                if (!nameRegex.test(fullName)) {
                    return showError("Họ và tên không được chứa số hoặc ký tự đặc biệt.");
                }

                // 2. Validate số điện thoại
                if (!phone) {
                    return showError("Vui lòng nhập số điện thoại.");
                }
                const phoneRegex = /^0(3|5|7|8|9)\d{8}$/;
                if (!phoneRegex.test(phone)) {
                    return showError("Số điện thoại không hợp lệ. Số điện thoại Việt Nam phải bắt đầu bằng 03, 05, 07, 08 hoặc 09 và có đúng 10 chữ số.");
                }

                // 3. Validate đổi mật khẩu
                const wantChangePassword = currentPassword || newPassword || confirmPassword;
                if (wantChangePassword) {
                    if (!currentPassword) {
                        return showError("Vui lòng nhập mật khẩu hiện tại.");
                    }
                    if (!newPassword) {
                        return showError("Vui lòng nhập mật khẩu mới.");
                    }
                    if (newPassword.length < 6 || newPassword.length > 20) {
                        return showError("Mật khẩu mới phải từ 6 đến 20 ký tự.");
                    }
                    if (newPassword === currentPassword) {
                        return showError("Mật khẩu mới không được trùng với mật khẩu hiện tại.");
                    }
                    if (!confirmPassword) {
                        return showError("Vui lòng xác nhận mật khẩu mới.");
                    }
                    if (confirmPassword.length > 20) {
                        return showError("Xác nhận mật khẩu mới không được quá 20 ký tự.");
                    }
                    if (newPassword !== confirmPassword) {
                        return showError("Xác nhận mật khẩu mới không khớp.");
                    }
                }
            });
        </script>

    </body>
</html>