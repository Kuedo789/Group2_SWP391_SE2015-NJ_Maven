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
                        <span class="material-symbols-outlined">lock_reset</span>
                        ĐẶT LẠI MẬT KHẨU
                    </div>

                    <h1>Tạo mật khẩu mới cho tài khoản của bạn</h1>

                    <p>
                        Mật khẩu mới sẽ được dùng cho những lần đăng nhập tiếp theo.
                        Hãy chọn mật khẩu dễ nhớ với bạn nhưng khó đoán với người khác.
                    </p>

                    <div class="auth-benefits">

                        <div>
                            <span class="material-symbols-outlined">verified_user</span>
                            Tài khoản đã được xác thực OTP
                        </div>

                        <div>
                            <span class="material-symbols-outlined">lock</span>
                            Bảo vệ thông tin đăng nhập
                        </div>

                        <div>
                            <span class="material-symbols-outlined">key</span>
                            Sử dụng mật khẩu mới sau khi hoàn tất
                        </div>

                    </div>

                </div>

                <!-- RIGHT -->
                <div class="auth-form-wrap">

                    <div class="auth-form-header">
                        <span class="auth-label">Khôi phục mật khẩu</span>
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
                            <label for="password">Mật khẩu mới</label>

                            <div class="input-wrap">
                                <span class="material-symbols-outlined">lock</span>

                                <input
                                    type="password"
                                    id="password"
                                    name="password"
                                    placeholder="Nhập mật khẩu mới"
                                    required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="confirmPassword">Xác nhận mật khẩu</label>

                            <div class="input-wrap">
                                <span class="material-symbols-outlined">lock_reset</span>

                                <input
                                    type="password"
                                    id="confirmPassword"
                                    name="confirmPassword"
                                    placeholder="Nhập lại mật khẩu mới"
                                    required>
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary auth-submit">
                            Đặt lại mật khẩu
                        </button>

                        <div class="auth-switch reset-back-wrap">
                            <a href="<%= contextPath %>/auth/verify-otp.jsp">
                                <span class="material-symbols-outlined reset-back-icon">arrow_back</span>
                                <span>Quay lại nhập OTP</span>
                            </a>
                        </div>

                        <div class="auth-switch">
                            Nhớ mật khẩu?
                            <a href="<%= contextPath %>/auth/login.jsp">Đăng nhập</a>
                        </div>

                    </form>

                </div>

            </div>

        </section>

    </main>

    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

</body>
</html>