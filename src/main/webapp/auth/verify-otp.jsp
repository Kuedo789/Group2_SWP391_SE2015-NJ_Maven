<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");

    String contextPath = request.getContextPath();

    /*
        otpType có 2 giá trị:
        - register: xác thực đăng ký
        - forgot: xác thực quên mật khẩu
    */
    String otpType = (String) request.getAttribute("otpType");

    boolean forgotFlow = "forgot".equals(otpType);

    String pageLabel = forgotFlow ? "KHÔI PHỤC MẬT KHẨU" : "XÁC THỰC TÀI KHOẢN";

    String pageTitle = "Xác nhận mã OTP";

    String pageDesc = forgotFlow
            ? "Nhập mã OTP đã được gửi đến email của bạn để hoàn tất đặt lại mật khẩu."
            : "Nhập mã OTP đã được gửi đến email của bạn để hoàn tất đăng ký tài khoản.";

    String formAction = forgotFlow
            ? contextPath + "/verify-forgot-otp"
            : contextPath + "/verify-otp";

    String resendAction = forgotFlow
            ? contextPath + "/verify-forgot-otp?action=resend"
            : contextPath + "/verify-otp?action=resend";

    String backHref = forgotFlow
            ? contextPath + "/auth/forgot-password.jsp"
            : contextPath + "/auth/register.jsp";

    String backText = forgotFlow
            ? "Quay lại quên mật khẩu"
            : "Quay lại đăng ký";
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

            <div class="auth-card otp-card">

                <!-- LEFT -->
                <div class="auth-visual otp-visual">

                    <div class="auth-badge">
                        <span class="material-symbols-outlined">
                            <%= forgotFlow ? "lock_reset" : "verified_user" %>
                        </span>
                        <%= pageLabel %>
                    </div>

                    <h1>
                        <%= forgotFlow
                                ? "Xác thực email để đặt lại mật khẩu"
                                : "Xác thực email để bắt đầu đặt bánh" %>
                    </h1>

                    <p>
                        Mã OTP giúp chúng tôi xác nhận đúng email của bạn.
                        Vui lòng kiểm tra hộp thư đến hoặc thư rác nếu chưa thấy mã.
                    </p>

                    <div class="auth-benefits">

                        <div>
                            <span class="material-symbols-outlined">mail</span>
                            Mã xác nhận được gửi qua email
                        </div>

                        <div>
                            <span class="material-symbols-outlined">timer</span>
                            Mã có hiệu lực trong thời gian giới hạn
                        </div>

                        <div>
                            <span class="material-symbols-outlined">shield</span>
                            Bảo vệ tài khoản an toàn hơn
                        </div>

                    </div>

                </div>

                <!-- RIGHT -->
                <div class="auth-form-wrap">

                    <div class="auth-form-header">
                        <span class="auth-label"><%= pageLabel %></span>
                        <h2><%= pageTitle %></h2>
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

                    <form action="<%= formAction %>" method="post" class="auth-form">

                        <div class="otp-intro">
                            <span class="material-symbols-outlined">mark_email_read</span>
                            <p><%= pageDesc %></p>
                        </div>

                        <div class="form-group">

                            <label for="otp">Mã OTP</label>

                            <div class="input-wrap otp-input-wrap">
                                <span class="material-symbols-outlined">pin</span>

                                <input
                                    type="text"
                                    id="otp"
                                    name="otp"
                                    class="otp-input"
                                    placeholder="Nhập mã OTP"
                                    maxlength="6"
                                    inputmode="numeric"
                                    autocomplete="one-time-code"
                                    required>
                            </div>

                        </div>

                        <button type="submit" class="btn btn-primary auth-submit">
                            Xác nhận OTP
                        </button>

                        <div class="auth-note">
                            Không nhận được mã?
                            <a href="<%= resendAction %>" class="otp-link">
                                Gửi lại OTP
                            </a>
                        </div>

                        <div class="auth-switch otp-back-wrap">
                            <a href="<%= backHref %>">
                                <span class="material-symbols-outlined otp-back-icon">arrow_back</span>
                                <span><%= backText %></span>
                            </a>
                        </div>

                        <div class="auth-switch">
                            Đã có tài khoản?
                            <a href="<%= contextPath %>/auth/login.jsp">Đăng nhập</a>
                        </div>

                    </form>

                </div>

            </div>

        </section>

    </main>

    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

    <script>
        const otpInput = document.getElementById("otp");

        if (otpInput) {
            otpInput.addEventListener("input", function () {
                this.value = this.value.replace(/[^0-9]/g, "");
            });
        }
    </script>

</body>
</html>