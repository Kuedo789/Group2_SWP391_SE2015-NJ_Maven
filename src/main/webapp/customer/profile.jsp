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

                <c:if test="${not empty errorMessage}">
                <div class="alert profile-error">
                    ${errorMessage}
                </div>
                </c:if>

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

                            <a href="${pageContext.request.contextPath}/delivery-address"
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