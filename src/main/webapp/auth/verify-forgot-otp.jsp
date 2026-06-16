<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    String contextPath = request.getContextPath();

    Long otpExpireAtMillis = (Long) session.getAttribute("otpExpireAtMillis");
    long expireAtMillis = otpExpireAtMillis != null ? otpExpireAtMillis : 0L;
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
                    <span class="material-symbols-outlined">lock_reset</span>
                    KHÔI PHỤC MẬT KHẨU
                </div>

                <h1>Xác thực email để đặt lại mật khẩu</h1>

                <p>
                    Nhập mã OTP đã được gửi đến email của bạn.
                    Sau khi xác thực thành công, bạn có thể tạo mật khẩu mới.
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
                        <span class="material-symbols-outlined">key</span>
                        Cho phép đặt lại mật khẩu mới
                    </div>

                </div>

            </div>

            <!-- RIGHT -->
            <div class="auth-form-wrap">

                <div class="auth-form-header">
                    <span class="auth-label">Quên mật khẩu</span>
                    <h2>Xác nhận mã OTP</h2>
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

                <form action="<%= contextPath %>/verify-forgot-otp" method="post" class="auth-form">

                    <div class="otp-intro">
                        <span class="material-symbols-outlined">mark_email_read</span>
                        <p>Nhập mã OTP đã được gửi đến email của bạn để tiếp tục đặt lại mật khẩu.</p>
                    </div>

                    <div class="form-group">
                        <label for="otp">Mã OTP</label>

                        <div class="input-wrap">
                            <span class="material-symbols-outlined input-icon">pin</span>

                            <input type="text"
                                   id="otp"
                                   name="otp"
                                   placeholder="Nhập mã OTP"
                                   maxlength="6"
                                   pattern="[0-9]{6}"
                                   inputmode="numeric"
                                   title="Mã OTP phải gồm đúng 6 chữ số"
                                   required>
                        </div>
                    </div>

                    <div class="otp-timer-box">
                        <span class="material-symbols-outlined">timer</span>
                        <span>Mã OTP hết hạn sau <strong id="otpTimer">--:--</strong></span>
                    </div>

                    <button type="submit" class="btn btn-primary auth-submit" id="submitOtpBtn">
                        Xác nhận OTP
                    </button>

                    <div class="auth-switch">
                        Chưa nhận được mã?
                        <a href="<%= contextPath %>/verify-forgot-otp?action=resend">Gửi lại mã</a>
                    </div>

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

<script>
    const expireAtMillis = <%= expireAtMillis %>;
    const timerEl = document.getElementById("otpTimer");
    const submitBtn = document.getElementById("submitOtpBtn");
    const otpInput = document.getElementById("otp");

    function renderOtpTimer() {
        if (!timerEl) {
            return;
        }

        const remaining = expireAtMillis - Date.now();

        if (!expireAtMillis || remaining <= 0) {
            timerEl.textContent = "00:00";
            timerEl.classList.add("expired");

            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.textContent = "OTP đã hết hạn";
            }

            if (otpInput) {
                otpInput.disabled = true;
            }

            return;
        }

        const totalSeconds = Math.floor(remaining / 1000);
        const minutes = Math.floor(totalSeconds / 60);
        const seconds = totalSeconds % 60;

        timerEl.textContent =
            String(minutes).padStart(2, "0") + ":" + String(seconds).padStart(2, "0");
    }

    renderOtpTimer();
    setInterval(renderOtpTimer, 1000);
</script>

</body>
</html>