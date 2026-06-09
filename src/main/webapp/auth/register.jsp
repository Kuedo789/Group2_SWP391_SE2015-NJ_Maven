<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setAttribute("pageTitle", "Đăng ký tài khoản");

    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");

    String fullName = (String) request.getAttribute("fullName");
    String email = (String) request.getAttribute("email");

    if (fullName == null) {
        fullName = "";
    }

    if (email == null) {
        email = "";
    }
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

                <div class="auth-card">

                    <!-- Left Side -->
                    <div class="auth-visual register-visual">

                        <div class="auth-badge">
                            <span class="material-symbols-outlined">cake</span>
                            Thành viên tiệm bánh
                        </div>

                        <h1>Tạo tài khoản để đặt bánh dễ dàng hơn</h1>

                        <p>
                            Đăng ký tài khoản để theo dõi đơn hàng, lưu thông tin giao hàng
                            và nhận các ưu đãi dành riêng cho thành viên.
                        </p>

                        <div class="auth-benefits">

                            <div>
                                <span class="material-symbols-outlined">wand_stars</span>
                                Tự thiết kế chiếc bánh của riêng bạn
                            </div>

                            <div>
                                <span class="material-symbols-outlined">receipt_long</span>
                                Theo dõi lịch sử đơn hàng
                            </div>

                            <div>
                                <span class="material-symbols-outlined">redeem</span>
                                Nhận ưu đãi thành viên
                            </div>

                        </div>

                    </div>

                    <!-- Right Side -->
                    <div class="auth-form-wrap">

                        <div class="auth-form-header">
                            <span class="auth-label">Đăng ký</span>

                            <h2>Tạo tài khoản mới</h2>
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

                        <form action="${pageContext.request.contextPath}/register" method="post" class="auth-form">

                            <div class="form-group">
                                <label for="fullName">Họ và tên</label>

                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">person</span>

                                    <input type="text"
                                           id="fullName"
                                           name="fullName"
                                           value="${fullName}"
                                           placeholder="Nhập họ và tên"
                                           required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="email">Email</label>

                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">alternate_email</span>

                                    <input type="email"
                                           id="email"
                                           name="email"
                                           value="${email}"
                                           placeholder="Nhập email của bạn"
                                           required>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="password">Mật khẩu</label>

                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">lock</span>

                                    <input type="password"
                                           id="password"
                                           name="password"
                                           placeholder="Nhập mật khẩu"
                                           required>

                                    <span class="material-symbols-outlined toggle-password" data-target="password">
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
                                           placeholder="Nhập lại mật khẩu"
                                           required>

                                    <span class="material-symbols-outlined toggle-password" data-target="confirmPassword">
                                        visibility
                                    </span>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary auth-submit">
                                Đăng ký
                            </button>

                            <div class="auth-divider">
                                <span>Hoặc</span>
                            </div>

                            <a href="${pageContext.request.contextPath}/login-google"
                               class="google-auth-btn"
                               aria-label="Tiếp tục với Google">

                                <svg class="google-logo" viewBox="0 0 533.5 544.3" aria-hidden="true">
                                <path fill="#4285F4" d="M533.5 278.4c0-18.5-1.5-37.1-4.7-55.3H272.1v104.6h147c-6.1 33.8-25.7 63.6-54.4 82.9v68h88.1c51.6-47.5 80.7-117.6 80.7-200.2z"/>
                                <path fill="#34A853" d="M272.1 544.3c73.7 0 135.7-24.2 180.9-65.7l-88.1-68c-24.5 16.7-56.1 26.2-92.8 26.2-71.4 0-131.9-48.2-153.5-112.9H27.7v70.1c45.4 90.3 137.8 150.3 244.4 150.3z"/>
                                <path fill="#FBBC05" d="M118.6 323.9c-11.4-33.8-11.4-70.4 0-104.2v-70.1H27.7c-38.8 77.2-38.8 168.4 0 245.6l90.9-71.3z"/>
                                <path fill="#EA4335" d="M272.1 107.7c38.9-.6 76.5 14 104.9 40.6l78.2-78.2C405.6 23.6 339.8-1.7 272.1 0 165.5 0 73.1 60 27.7 150.3l90.9 70.1c21.5-64.9 82.1-112.7 153.5-112.7z"/>
                                </svg>

                                Tiếp tục với Google
                            </a>
                            <div class="auth-switch">
                                Đã có tài khoản?
                                <a href="${pageContext.request.contextPath}/auth/login.jsp">
                                    Đăng nhập
                                </a>
                            </div>

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