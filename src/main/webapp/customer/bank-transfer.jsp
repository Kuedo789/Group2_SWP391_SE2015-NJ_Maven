<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String orderNo = (String) request.getAttribute("orderNo");
    Long totalAmount = (Long) request.getAttribute("totalAmount");
    if (orderNo == null) {
        response.sendRedirect(request.getContextPath() + "/home");
        return;
    }
    long total = (totalAmount != null) ? totalAmount : 0L;

    // Bank info (customize as needed)
    String bankId     = "970423";   // TPBank BIN
    String bankShort  = "TPB";
    String accountNo  = "25102005858";
    String accountName = "NGUYEN VAN HUNG";
    String transferContent = orderNo;

    // VietQR URL via SePay
    // TODO: Update bankId and accountNo to your real SePay registered account
    String qrUrl = "https://qr.sepay.vn/img?bank=" + bankShort + "&acc=" + accountNo
                 + "&amount=" + total
                 + "&des=" + java.net.URLEncoder.encode(transferContent, "UTF-8");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Thanh toán chuyển khoản - BakeryZone</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/bank-transfer.css">
</head>
<body>
    <jsp:include page="../common/navbar.jsp" />

    <main class="bank-transfer-page">
        <div class="bt-container">

            <!-- Header -->
            <div class="bt-header">
                <div class="bt-badge">
                    <i class="fa fa-check-circle"></i> Đơn hàng đã được đặt thành công
                </div>
                <h1 class="bt-title">Thanh toán chuyển khoản</h1>
                <p class="bt-subtitle">
                    Đơn hàng của bạn đã được ghi nhận. Vui lòng chuyển khoản để hoàn tất thanh toán.
                </p>
            </div>

            <!-- Countdown timer (15 minutes) -->
            <div class="countdown-banner">
                <div class="countdown-icon">
                    <i class="fa fa-hourglass-half"></i>
                </div>
                <div class="countdown-text">
                    <div class="countdown-label">Thời gian thanh toán còn lại</div>
                    <div class="countdown-timer" id="countdownTimer">15:00</div>
                </div>
                <div style="font-size: 13px; color: #888; text-align: right; max-width: 200px; line-height: 1.4;">
                    Đơn hàng sẽ tự động xác nhận sau khi chúng tôi nhận được thanh toán.
                </div>
            </div>

            <!-- Warning -->
            <div class="warning-banner">
                <i class="fa fa-exclamation-triangle"></i>
                <div>
                    <strong>Quan trọng:</strong> Vui lòng nhập <strong>đúng nội dung chuyển khoản</strong> là mã đơn hàng
                    <strong><%= orderNo %></strong> để chúng tôi xác nhận thanh toán nhanh nhất.
                    Sai nội dung có thể gây chậm trễ trong xử lý đơn.
                </div>
            </div>

            <!-- Main grid -->
            <div class="bt-grid">

                <!-- QR Code Card -->
                <div class="bt-card qr-card">
                    <div class="bt-card-title">
                        <i class="fa fa-qrcode"></i>
                        Quét mã QR để thanh toán
                    </div>

                    <div class="qr-wrapper">
                        <img src="<%= qrUrl %>"
                             alt="QR Code chuyển khoản <%= orderNo %>"
                             onerror="this.src='https://qr.sepay.vn/img?bank=<%= bankShort %>&acc=<%= accountNo %>&amount=<%= total %>&des=<%= java.net.URLEncoder.encode(transferContent, "UTF-8") %>'">
                    </div>

                    <div class="qr-note">
                        Dùng app ngân hàng, ví điện tử để quét QR
                    </div>
                    <div class="qr-apps">
                        <span class="qr-app-badge">VCB Digibank</span>
                        <span class="qr-app-badge">MoMo</span>
                        <span class="qr-app-badge">ZaloPay</span>
                        <span class="qr-app-badge">VNPay</span>
                    </div>
                </div>

                <!-- Bank Info Card -->
                <div class="bt-card">
                    <div class="bt-card-title">
                        <i class="fa fa-university"></i>
                        Thông tin tài khoản ngân hàng
                    </div>

                    <div class="bank-info-row">

                        <!-- Order No -->
                        <div class="bi-item">
                            <span class="bi-label">Mã đơn hàng</span>
                            <span class="bi-value" id="val-orderNo"><%= orderNo %></span>
                            <button class="bi-copy-btn" onclick="copyValue('val-orderNo', this)" title="Copy">
                                <i class="fa fa-copy"></i> Copy
                            </button>
                        </div>

                        <!-- Bank name -->
                        <div class="bi-item">
                            <span class="bi-label">Ngân hàng</span>
                            <span class="bi-value"><%= bankShort %> – Techcombank</span>
                        </div>

                        <!-- Account number -->
                        <div class="bi-item">
                            <span class="bi-label">Số tài khoản</span>
                            <span class="bi-value" id="val-accNo"><%= accountNo %></span>
                            <button class="bi-copy-btn" onclick="copyValue('val-accNo', this)" title="Copy">
                                <i class="fa fa-copy"></i> Copy
                            </button>
                        </div>

                        <!-- Account name -->
                        <div class="bi-item">
                            <span class="bi-label">Chủ tài khoản</span>
                            <span class="bi-value" style="font-size: 14px;"><%= accountName %></span>
                        </div>

                        <!-- Amount -->
                        <div class="bi-item amount-highlight">
                            <span class="bi-label">Số tiền cần chuyển</span>
                            <span class="bi-value" id="val-amount"><fmt:formatNumber value="<%= total %>" pattern="#,##0"/>đ</span>
                            <button class="bi-copy-btn" onclick="copyValue('val-amount-raw', this)" title="Copy">
                                <i class="fa fa-copy"></i> Copy
                            </button>
                            <span id="val-amount-raw" style="display:none;"><%= total %></span>
                        </div>

                        <!-- Transfer content -->
                        <div class="bi-item">
                            <span class="bi-label">Nội dung chuyển khoản</span>
                            <span class="bi-value" id="val-content" style="font-size:15px; color: #c0392b;"><%= orderNo %></span>
                            <button class="bi-copy-btn" onclick="copyValue('val-content', this)" title="Copy">
                                <i class="fa fa-copy"></i> Copy
                            </button>
                        </div>

                    </div>
                </div>

                <!-- Steps card -->
                <div class="bt-card steps-card">
                    <div class="bt-card-title">
                        <i class="fa fa-list-ol"></i>
                        Hướng dẫn thanh toán
                    </div>
                    <div class="steps-list">
                        <div class="step-item">
                            <div class="step-number">1</div>
                            <div class="step-text">
                                <strong>Mở ứng dụng ngân hàng</strong>
                                Dùng app ngân hàng hoặc ví điện tử (MoMo, ZaloPay, VNPay,...)
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-number">2</div>
                            <div class="step-text">
                                <strong>Quét QR hoặc nhập thủ công</strong>
                                Dùng chức năng "Quét QR" hoặc nhập số tài khoản bên trái
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-number">3</div>
                            <div class="step-text">
                                <strong>Nhập đúng nội dung</strong>
                                Nội dung chuyển khoản: <strong style="color:#c0392b;"><%= orderNo %></strong>
                            </div>
                        </div>
                        <div class="step-item">
                            <div class="step-number">4</div>
                            <div class="step-text">
                                <strong>Xác nhận và hoàn tất</strong>
                                Chúng tôi sẽ xác nhận đơn hàng trong vòng 15–30 phút
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- /bt-grid -->

            <!-- Action buttons -->
            <div class="bt-actions">
                <a href="${pageContext.request.contextPath}/checkout" class="btn-outline-neutral">
                    <i class="fa fa-arrow-left"></i> Quay lại đơn hàng
                </a>
                <a href="${pageContext.request.contextPath}/home" class="btn-primary-green" onclick="localStorage.removeItem('cart'); localStorage.removeItem('checkout_state');">
                    <i class="fa fa-home"></i> Về trang chủ
                </a>
            </div>

        </div><!-- /bt-container -->
    </main>

    <!-- Toast notification -->
    <div class="copy-toast" id="copyToast">
        <i class="fa fa-check-circle"></i>
        <span id="copyToastMsg">Đã copy!</span>
    </div>

    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />

    <script>
        // Giữ lại giỏ hàng để có thể quay lại sửa đổi cho đến khi thanh toán xong hoặc quay về trang chủ.

        // ── Countdown timer (15 min = 900 sec) ───────────────────────
        let remainingSeconds = 900;
        const timerEl = document.getElementById("countdownTimer");

        function updateTimer() {
            const m = Math.floor(remainingSeconds / 60);
            const s = remainingSeconds % 60;
            timerEl.textContent = String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
            if (remainingSeconds <= 60) {
                timerEl.style.color = '#c0392b';
            }
            if (remainingSeconds > 0) {
                remainingSeconds--;
                setTimeout(updateTimer, 1000);
            } else {
                timerEl.textContent = "00:00";
                timerEl.style.color = '#c0392b';
            }
        }
        updateTimer();

        // ── Copy to clipboard ─────────────────────────────────────────
        function copyValue(elementId, btn) {
            const el = document.getElementById(elementId);
            if (!el) return;
            const text = el.textContent.trim();
            navigator.clipboard.writeText(text).then(() => {
                showToast("Đã copy: " + text.substring(0, 30) + (text.length > 30 ? '...' : ''));
                if (btn) {
                    btn.classList.add('copied');
                    btn.innerHTML = '<i class="fa fa-check"></i> Copied!';
                    setTimeout(() => {
                        btn.classList.remove('copied');
                        btn.innerHTML = '<i class="fa fa-copy"></i> Copy';
                    }, 2000);
                }
            }).catch(() => {
                // Fallback for older browsers
                const textarea = document.createElement('textarea');
                textarea.value = text;
                document.body.appendChild(textarea);
                textarea.select();
                document.execCommand('copy');
                document.body.removeChild(textarea);
                showToast("Đã copy!");
            });
        }

        function showToast(msg) {
            const toast = document.getElementById("copyToast");
            document.getElementById("copyToastMsg").textContent = msg;
            toast.classList.add("show");
            setTimeout(() => toast.classList.remove("show"), 2500);
        }

        // ── Auto-polling for payment confirmation via SePay Webhook ──
        // The order already exists in Pending status, so its items no longer
        // belong in the browser-side checkout cart while payment is awaited.
        localStorage.removeItem("cart");
        localStorage.removeItem("checkout_state");
        sessionStorage.removeItem("selectedCartItems");
        window.dispatchEvent(new Event("storage"));

        let pollingInterval = setInterval(checkOrderStatus, 3000); // Check every 3 seconds

        function checkOrderStatus() {
            const orderNo = '<%= orderNo %>';
            if (!orderNo) return;
            
            fetch(`${pageContext.request.contextPath}/api/order/status?orderNo=${orderNo}`)
                .then(response => response.json())
                .then(data => {
                    if (data && (data.status === 'PAID' || data.status === 'Confirmed' || data.status === 'Processing')) {
                        clearInterval(pollingInterval);
                        // Show success feedback
                        document.querySelector('.bt-badge').innerHTML = '<i class="fa fa-check-circle"></i> Đã nhận được thanh toán';
                        document.querySelector('.bt-badge').style.background = '#4caf50';
                        document.querySelector('.bt-badge').style.color = 'white';
                        
                        // Redirect to success page after a short delay
                        setTimeout(() => {
                            window.location.href = '${pageContext.request.contextPath}/order-success?orderNo=' + orderNo;
                        }, 1500);
                    }
                })
                .catch(err => console.error("Error polling order status:", err));
        }

    </script>
</body>
</html>

