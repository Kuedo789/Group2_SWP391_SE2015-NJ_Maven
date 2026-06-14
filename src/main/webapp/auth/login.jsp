<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="../common/header.jsp" />
        <title>Đăng nhập - BakeryZone</title>
    </head>

    <body>
        <jsp:include page="../common/navbar.jsp" />

        <main class="auth-main">
            <section class="auth-section">
                <div class="auth-card login-card">

                    <div class="auth-visual">
                        <div class="auth-badge">
                            <span class="material-symbols-outlined">bakery_dining</span>
                            BakeryZone
                        </div>

                        <h1>Chào mừng bạn quay lại</h1>

                        <p>
                            Đăng nhập để tiếp tục đặt bánh, theo dõi đơn hàng và lưu lại những mẫu bánh yêu thích của bạn.
                        </p>

                        <div class="auth-benefits">
                            <div>
                                <span class="material-symbols-outlined">verified</span>
                                Tài khoản bảo mật bằng OTP
                            </div>
                            <div>
                                <span class="material-symbols-outlined">local_shipping</span>
                                Theo dõi đơn hàng dễ dàng
                            </div>
                            <div>
                                <span class="material-symbols-outlined">cake</span>
                                Lưu thông tin đặt bánh nhanh hơn
                            </div>
                        </div>
                    </div>

                    <div class="auth-form-wrap">
                        <div class="auth-form-header">
                            <span class="auth-label">Đăng nhập</span>
                            <h2>Vào tài khoản</h2>
                        </div>

                        <% if (request.getAttribute("error") != null) { %>
                        <div class="auth-message auth-error">
                            <span class="material-symbols-outlined">error</span>

                            <% if (request.getAttribute("unverifiedAccount") != null) { %>
                            <a href="<%= request.getContextPath() %>/verify-otp?action=resend"
                               style="color: inherit; text-decoration: underline; font-weight: 700;">
                                <%= request.getAttribute("error") %> Vui lòng bấm vào đây để xác thực.
                            </a>
                            <% } else { %>
                            <span><%= request.getAttribute("error") %></span>
                            <% } %>
                        </div>
                        <% } %>

                        <form class="auth-form" action="${pageContext.request.contextPath}/login" method="post">

                            <div class="form-group">
                                <label for="email">Email</label>
                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">mail</span>
                                    <input
                                        type="email"
                                        id="email"
                                        name="email"
                                        placeholder="Nhập email của bạn"
                                        value="${accountInput != null ? accountInput : ''}"
                                        required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="password">Mật khẩu</label>
                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">lock</span>
                                    <input
                                        type="password"
                                        id="password"
                                        name="password"
                                        placeholder="Nhập mật khẩu"
                                        required>
                                    <span
                                        class="material-symbols-outlined toggle-password"
                                        data-target="password">visibility</span>
                                </div>

                                <a class="forgot-link forgot-under-input"
                                   href="${pageContext.request.contextPath}/forgot-password">
                                    Quên mật khẩu?
                                </a>
                            </div>

                            <button type="submit" class="btn btn-primary auth-submit">
                                Đăng nhập
                            </button>

                            <p class="auth-switch">
                                Chưa có tài khoản?
                                <a href="${pageContext.request.contextPath}/register">
                                    Đăng ký ngay
                                </a>
                            </p>

                        </form>
                    </div>

                </div>
            </section>
        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>
    </body>
</html>