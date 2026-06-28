<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    request.setAttribute("pageTitle", "Quên mật khẩu");

    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");

    String email = (String) request.getAttribute("email");

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

                <div class="auth-card forgot-card">

                    <!-- Left Side -->
                    <div class="auth-visual forgot-visual">

                        <div class="auth-badge">
                            <span class="material-symbols-outlined">lock_reset</span>
                            Khôi phục tài khoản
                        </div>

                        <h1>Lấy lại quyền truy cập tài khoản của bạn</h1>

                        <p>
                            Nhập email đã dùng để đăng ký. Chúng tôi sẽ gửi mã xác nhận
                            để bạn có thể đặt lại mật khẩu mới.
                        </p>

                        <div class="auth-benefits">

                            <div>
                                <span class="material-symbols-outlined">mail</span>
                                Nhận mã xác nhận qua email
                            </div>

                            <div>
                                <span class="material-symbols-outlined">shield</span>
                                Bảo vệ tài khoản an toàn
                            </div>

                            <div>
                                <span class="material-symbols-outlined">key</span>
                                Đặt lại mật khẩu nhanh chóng
                            </div>

                        </div>

                    </div>

                    <!-- Right Side -->
                    <div class="auth-form-wrap">

                        <div class="auth-form-header">
                            <span class="auth-label">Quên mật khẩu</span>

                            <h2>Khôi phục mật khẩu</h2>
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

                        <form action="${pageContext.request.contextPath}/forgot-password" method="post" class="auth-form">

                            <div class="form-group">
                                <label for="email">Email tài khoản</label>

                                <div class="input-wrap">
                                    <span class="material-symbols-outlined input-icon">alternate_email</span>

                                    <input type="email"
                                           id="email"
                                           name="email"
                                           value="<%= email %>"
                                           placeholder="Nhập email đã đăng ký"
                                           maxlength="100"
                                           required>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-primary auth-submit">
                                Gửi mã xác nhận
                            </button>

                            <div class="auth-note">
                                Mã xác nhận sẽ được gửi đến email nếu tài khoản tồn tại trong hệ thống.
                            </div>

                            <div class="auth-switch">
                                Đã nhớ mật khẩu?
                                <a href="${pageContext.request.contextPath}/login">
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
    </body>

</html>