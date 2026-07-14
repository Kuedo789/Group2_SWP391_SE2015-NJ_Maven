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
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:wght@600;700&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        .bank-transfer-page {
            min-height: 100vh;
            background: linear-gradient(135deg, #f0f7f4 0%, #faf9f6 50%, #f0f4f0 100%);
            padding: 48px 20px;
            font-family: 'Inter', sans-serif;
        }

        .bt-container {
            max-width: 900px;
            margin: 0 auto;
        }

        /* Page Title */
        .bt-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .bt-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
            border-radius: 999px;
            padding: 6px 18px;
            font-size: 13px;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
        }

        .bt-badge i {
            font-size: 14px;
        }

        .bt-title {
            font-family: 'Playfair Display', serif;
            font-size: clamp(28px, 5vw, 40px);
            color: #1a3325;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .bt-subtitle {
            font-size: 16px;
            color: #666;
            line-height: 1.6;
            max-width: 520px;
            margin: 0 auto;
        }

        /* Main grid layout */
        .bt-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 24px;
        }

        @media (max-width: 700px) {
            .bt-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Cards */
        .bt-card {
            background: #fff;
            border-radius: 20px;
            padding: 28px;
            box-shadow: 0 2px 24px rgba(0,0,0,0.06);
        }

        .bt-card-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: #888;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .bt-card-title i {
            font-size: 15px;
            color: #2b5c3a;
        }

        /* QR Card */
        .qr-card {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 16px;
        }

        .qr-wrapper {
            background: #fff;
            border: 2px solid #e8f5e9;
            border-radius: 16px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .qr-wrapper:hover {
            border-color: #4caf50;
            box-shadow: 0 4px 20px rgba(76,175,80,0.15);
        }

        .qr-wrapper img {
            width: 200px;
            height: 200px;
            display: block;
        }

        .qr-note {
            font-size: 13px;
            color: #888;
            text-align: center;
            line-height: 1.5;
        }

        .qr-apps {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .qr-app-badge {
            background: #f5f5f5;
            border-radius: 8px;
            padding: 5px 12px;
            font-size: 12px;
            font-weight: 600;
            color: #555;
        }

        /* Bank info */
        .bank-info-row {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .bi-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
            padding: 14px 16px;
            background: #f9fafb;
            border-radius: 12px;
            border: 1px solid #eee;
            transition: border-color 0.2s;
            position: relative;
        }

        .bi-item:hover {
            border-color: #c8e6c9;
        }

        .bi-label {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #aaa;
        }

        .bi-value {
            font-size: 17px;
            font-weight: 700;
            color: #1a3325;
            letter-spacing: 0.5px;
        }

        .bi-copy-btn {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: 1px solid #ddd;
            border-radius: 8px;
            cursor: pointer;
            padding: 5px 10px;
            font-size: 12px;
            color: #666;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .bi-copy-btn:hover {
            border-color: #4caf50;
            color: #2e7d32;
            background: #f0fff0;
        }

        .bi-copy-btn.copied {
            border-color: #4caf50;
            color: #2e7d32;
            background: #e8f5e9;
        }

        /* Amount highlight */
        .amount-highlight {
            background: linear-gradient(135deg, #1a3325, #2b5c3a);
            color: #fff;
            border-radius: 12px;
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .amount-highlight .bi-label {
            color: rgba(255,255,255,0.7);
        }

        .amount-highlight .bi-value {
            color: #fff;
            font-size: 22px;
        }

        .amount-highlight .bi-copy-btn {
            border-color: rgba(255,255,255,0.3);
            color: rgba(255,255,255,0.8);
        }

        .amount-highlight .bi-copy-btn:hover {
            border-color: #fff;
            color: #fff;
            background: rgba(255,255,255,0.1);
        }

        /* Steps card */
        .steps-card {
            grid-column: 1 / -1;
        }

        .steps-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 16px;
            margin-top: 4px;
        }

        .step-item {
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-start;
        }

        .step-number {
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #1a3325, #2b5c3a);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 15px;
            font-weight: 700;
            flex-shrink: 0;
        }

        .step-text {
            font-size: 14px;
            color: #444;
            line-height: 1.5;
        }

        .step-text strong {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #1a3325;
            margin-bottom: 3px;
        }

        /* Warning banner */
        .warning-banner {
            background: #fff8e1;
            border: 1px solid #ffe082;
            border-radius: 12px;
            padding: 14px 18px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 13px;
            color: #5d4037;
            line-height: 1.6;
            margin-bottom: 24px;
        }

        .warning-banner i {
            font-size: 18px;
            color: #f59e0b;
            flex-shrink: 0;
            margin-top: 1px;
        }

        /* Action buttons */
        .bt-actions {
            display: flex;
            gap: 14px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-primary-green {
            background: linear-gradient(135deg, #2b5c3a, #1a3325);
            color: #fff;
            border: none;
            border-radius: 50px;
            padding: 15px 40px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(43,92,58,0.3);
        }

        .btn-primary-green:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(43,92,58,0.4);
            color: #fff;
        }

        .btn-outline-neutral {
            background: #fff;
            color: #333;
            border: 1.5px solid #ddd;
            border-radius: 50px;
            padding: 15px 40px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-outline-neutral:hover {
            border-color: #2b5c3a;
            color: #2b5c3a;
        }

        /* Countdown */
        .countdown-banner {
            background: #fff;
            border-radius: 16px;
            padding: 18px 24px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            margin-bottom: 24px;
        }

        .countdown-icon {
            width: 48px;
            height: 48px;
            background: #fff3e0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .countdown-icon i {
            font-size: 22px;
            color: #e65100;
        }

        .countdown-text {
            flex: 1;
        }

        .countdown-label {
            font-size: 13px;
            color: #888;
            margin-bottom: 2px;
        }

        .countdown-timer {
            font-size: 24px;
            font-weight: 800;
            color: #e65100;
            letter-spacing: 1px;
            font-variant-numeric: tabular-nums;
        }

        /* Order badge */
        .order-no-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #e8f5e9;
            color: #2b5c3a;
            border: 1px solid #c8e6c9;
            border-radius: 999px;
            padding: 4px 14px;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        /* Toast */
        .copy-toast {
            position: fixed;
            bottom: 30px;
            left: 50%;
            transform: translateX(-50%) translateY(100px);
            background: #1a3325;
            color: #fff;
            border-radius: 50px;
            padding: 12px 24px;
            font-size: 14px;
            font-weight: 600;
            z-index: 9999;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            box-shadow: 0 8px 30px rgba(0,0,0,0.2);
        }

        .copy-toast.show {
            transform: translateX(-50%) translateY(0);
        }
    </style>
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
                <a href="${pageContext.request.contextPath}/order-success?orderNo=<%= orderNo %>" class="btn-primary-green" style="padding: 15px 40px; font-size: 16px; border-radius: 50px;">
                    <i class="fa fa-check-circle"></i> Tôi đã chuyển khoản xong
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
        // Clear cart since order is placed
        localStorage.removeItem("cart");

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
