<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.Order" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendRedirect(request.getContextPath() + "/OrderList");
        return;
    }
    
    String orderNoDisplay = order.getOrderNo().replace("ORD_", "#");

    // Format delivery time
    String deliveryTimeDisplay = "Chưa cập nhật";
    if (order.getDeliveryWindowStart() != null && order.getDeliveryWindowEnd() != null) {
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        String startTime = timeFormat.format(order.getDeliveryWindowStart());
        String endTime = timeFormat.format(order.getDeliveryWindowEnd());
        String dateStr = dateFormat.format(order.getDeliveryWindowStart());
        deliveryTimeDisplay = startTime + " - " + endTime + " ngày " + dateStr;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Đặt hàng thành công - BakeryZone</title>
    <style>
        .order-success-page {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 80vh;
            background: linear-gradient(to bottom, #ffffff, #faf9f6);
            padding: 40px 20px;
            font-family: 'Inter', sans-serif;
            text-align: center;
        }

        .success-icon {
            margin-bottom: 24px;
        }

        .success-title {
            font-family: 'Playfair Display', serif;
            font-size: 36px;
            color: #1f3322;
            margin-bottom: 16px;
            font-weight: 700;
        }

        .success-desc {
            font-size: 16px;
            color: #666;
            max-width: 500px;
            line-height: 1.6;
            margin-bottom: 40px;
        }

        .order-info-card {
            background-color: #fff;
            border-radius: 24px;
            padding: 32px 48px;
            display: flex;
            gap: 48px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            margin-bottom: 48px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .info-block {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            text-align: left;
        }

        .info-label {
            font-size: 12px;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 1px;
            color: #333;
            margin-bottom: 12px;
        }

        .info-value {
            font-family: 'Playfair Display', serif;
            font-size: 32px;
            font-weight: 600;
            color: #1f3322;
        }

        .info-value-time {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            color: #333;
        }

        .info-value-time .material-symbols-outlined {
            font-size: 20px;
            color: #333;
        }

        .divider {
            width: 1px;
            background-color: #eaeaea;
            height: auto;
        }

        .btn-copy {
            background: none;
            border: none;
            color: #2b4c34;
            cursor: pointer;
            margin-left: 8px;
            padding: 4px;
            border-radius: 4px;
            transition: background 0.2s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn-copy:hover {
            background-color: #e8f4e1;
        }

        .action-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-success {
            background-color: #2b4c34;
            color: #fff;
            border: none;
            border-radius: 30px;
            padding: 14px 40px;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-success:hover {
            background-color: #1f3322;
            color: #fff;
        }

        .btn-outline-success {
            background-color: #fff;
            color: #333;
            border: 1px solid #ddd;
            border-radius: 30px;
            padding: 14px 40px;
            font-size: 15px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-outline-success:hover {
            border-color: #999;
            color: #111;
        }

        @media (max-width: 600px) {
            .order-info-card {
                flex-direction: column;
                gap: 24px;
                padding: 24px;
            }
            .divider {
                width: 100%;
                height: 1px;
            }
            .info-block {
                align-items: center;
                text-align: center;
            }
            .action-buttons {
                flex-direction: column;
                width: 100%;
                max-width: 300px;
            }
            .btn-success, .btn-outline-success {
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/navbar.jsp" />

    <main class="order-success-page">
        <div class="success-icon">
            <svg width="120" height="120" viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg">
                <!-- Star -->
                <path d="M60 25L63 35H73L65 41L68 51L60 45L52 51L55 41L47 35H57L60 25Z" fill="#a8d08d" stroke="#365e2e" stroke-width="4" stroke-linejoin="round"/>
                <!-- Cake Top -->
                <ellipse cx="60" cy="55" rx="30" ry="10" fill="#e8f4e1" stroke="#365e2e" stroke-width="4"/>
                <!-- Cake Body -->
                <path d="M30 55V80C30 85.5228 43.4315 90 60 90C76.5685 90 90 85.5228 90 80V55" fill="#e8f4e1" stroke="#365e2e" stroke-width="4"/>
                <!-- Cake details curve -->
                <path d="M30 65C30 65 40 75 60 75C80 75 90 65 90 65" stroke="#365e2e" stroke-width="4" stroke-linecap="round"/>
                <!-- Small dots -->
                <circle cx="45" cy="62" r="2.5" fill="#365e2e"/>
                <circle cx="75" cy="62" r="2.5" fill="#365e2e"/>
                <circle cx="60" cy="65" r="2.5" fill="#365e2e"/>
                <!-- Base plates -->
                <path d="M40 96H80" stroke="#365e2e" stroke-width="4" stroke-linecap="round"/>
                <path d="M45 104H75" stroke="#365e2e" stroke-width="4" stroke-linecap="round"/>
                <!-- Plus signs floating -->
                <path d="M30 25H36M33 22V28" stroke="#365e2e" stroke-width="3" stroke-linecap="round"/>
                <path d="M85 30H91M88 27V33" stroke="#365e2e" stroke-width="3" stroke-linecap="round"/>
            </svg>
        </div>

        <h1 class="success-title">Đặt hàng thành công!</h1>
        <p class="success-desc">
            Cảm ơn bạn đã tin tưởng Tiệm Bánh Thủ Công. Đơn hàng của bạn đang được<br/>
            chúng mình chuẩn bị rồi nhé! Một chút ngọt ngào sẽ sớm gõ cửa nhà bạn.
        </p>

        <div class="order-info-card">
            <div class="info-block">
                <div class="info-label">MÃ ĐƠN HÀNG</div>
                <div class="info-value" style="display: flex; align-items: center;">
                    <span id="orderNoText"><%= orderNoDisplay %></span>
                    <button class="btn-copy" onclick="copyOrderNo()" title="Copy mã đơn hàng">
                        <span class="material-symbols-outlined" style="font-size: 24px;">content_copy</span>
                    </button>
                </div>
            </div>
            
            <div class="divider"></div>
            
            <div class="info-block">
                <div class="info-label">GIAO HÀNG DỰ KIẾN</div>
                <div class="info-value-time">
                    <span class="material-symbols-outlined">schedule</span>
                    <%= deliveryTimeDisplay %>
                </div>
            </div>
        </div>

        <div class="action-buttons">
            <a href="<%= request.getContextPath() %>/OrderList" class="btn-success">Xem đơn hàng</a>
            <a href="<%= request.getContextPath() %>/home" class="btn-outline-success">Về trang chủ</a>
        </div>
    </main>

    <jsp:include page="../common/footer.jsp" />
    <jsp:include page="../common/scripts.jsp" />
    
    <script>
        function copyOrderNo() {
            var textToCopy = "<%= order.getOrderNo() %>";
            navigator.clipboard.writeText(textToCopy).then(function() {
                alert("Đã copy mã đơn hàng: " + textToCopy);
            }, function(err) {
                console.error('Không thể copy', err);
            });
        }
    </script>
</body>
</html>
