<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">

<head>
    <jsp:include page="../common/header.jsp" />
</head>

<body>

<jsp:include page="../common/navbar.jsp" />

<main class="main auth-main">

    <section class="auth-section">

        <div class="auth-card reset-card">

            <!-- LEFT -->
            <div class="auth-visual reset-visual">

                <div class="auth-badge">
                    <span class="material-symbols-outlined">password</span>
                    ĐẶT LẠI MẬT KHẨU
                </div>

                <h1>Tạo mật khẩu mới cho tài khoản của bạn</h1>

                <p>
                    Vui lòng nhập mật khẩu mới. Sau khi đổi mật khẩu thành công,
                    bạn có thể đăng nhập lại bằng mật khẩu mới.
                </p>

                <div class="auth-benefits">

                    <div>
                        <span class="material-symbols-outlined">lock</span>
                        Mật khẩu mới giúp bảo vệ tài khoản
                    </div>

                    <div>
                        <span class="material-symbols-outlined">verified</span>
                        Chỉ đổi mật khẩu sau khi xác thực OTP
                    </div>

                    <div>
                        <span class="material-symbols-outlined">login</span>
                        Đăng nhập lại sau khi đặt lại mật khẩu
                    </div>

                </div>

            </div>

            <!-- RIGHT -->
            <div class="auth-form-wrap">

                <div class="auth-form-header">
                    <span class="auth-label">Mật khẩu mới</span>
                    <h2>Đặt lại mật khẩu</h2>
                </div>

                <% if (error != null) { %>
                    <div class="auth-message auth-error">
                        <span class="material-symbols-outlined">error</span>
                        <%= error %>
                    </div>
                <% } %>

                <% if (message != null) { %>
                    <div class="auth-message auth-success">
                        <span class="material-symbols-outlined">check_circle</span>
                        <%= message %>
                    </div>
                <% } %>

                <form action="<%= contextPath %>/reset-password" method="post" class="auth-form">

                    <div class="form-group">
                        <label for="newPassword">Mật khẩu mới</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">lock</span>

                            <input type="password"
                                   id="newPassword"
                                   name="newPassword"
                                   placeholder="Nhập mật khẩu mới"
                                   minlength="6"
                                   maxlength="20"
                                   pattern="^\S+$"
                                   title="Mật khẩu phải từ 6 đến 20 ký tự và không được chứa khoảng trắng"
                                   required>

                            <span class="material-symbols-outlined toggle-password"
                                  data-target="newPassword">
                                visibility
                            </span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Xác nhận mật khẩu</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">lock_reset</span>

                            <input type="password"
                                   id="confirmPassword"
                                   name="confirmPassword"
                                   placeholder="Nhập lại mật khẩu mới"
                                   minlength="6"
                                   maxlength="20"
                                   pattern="^\S+$"
                                   title="Mật khẩu xác nhận không được chứa khoảng trắng"
                                   required>

                            <span class="material-symbols-outlined toggle-password"
                                  data-target="confirmPassword">
                                visibility
                            </span>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary auth-submit">
                        Đặt lại mật khẩu
                    </button>

                    <div class="auth-switch">
                        Đã nhớ mật khẩu?
                        <a href="<%= contextPath %>/login">Đăng nhập</a>
                    </div>

                </form>

            </div>

        </div>

    </section>

</main>

<jsp:include page="../common/footer.jsp" />
<jsp:include page="../common/scripts.jsp" />

<script src="<%= contextPath %>/assets/js/password-toggle.js"></script>

</body>
</html>