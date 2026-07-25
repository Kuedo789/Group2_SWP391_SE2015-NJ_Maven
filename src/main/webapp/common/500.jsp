<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Lỗi Máy Chủ | BakeryZone</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary: #f26b21;
            --primary-hover: #e05a16;
            --bg-color: #fff9f5;
            --text-main: #2d3748;
            --text-muted: #718096;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            overflow: hidden;
        }

        .error-container {
            text-align: center;
            max-width: 600px;
            padding: 40px;
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 40px rgba(242, 107, 33, 0.08);
            position: relative;
            z-index: 10;
        }

        .error-icon {
            font-size: 80px;
            color: var(--primary);
            margin-bottom: 24px;
            animation: float 3s ease-in-out infinite;
        }

        .error-code {
            font-size: 120px;
            font-weight: 800;
            line-height: 1;
            color: var(--text-main);
            margin-bottom: 10px;
            background: linear-gradient(135deg, var(--text-main) 0%, var(--primary) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .error-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 16px;
        }

        .error-message {
            font-size: 16px;
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 32px;
        }

        .btn-home {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background-color: var(--primary);
            color: white;
            text-decoration: none;
            padding: 14px 28px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(242, 107, 33, 0.3);
        }

        .btn-home:hover {
            background-color: var(--primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(242, 107, 33, 0.4);
        }

        /* Decorative background elements */
        .blob {
            position: absolute;
            background: rgba(242, 107, 33, 0.1);
            border-radius: 50%;
            z-index: 1;
            filter: blur(40px);
        }

        .blob-1 {
            width: 300px;
            height: 300px;
            top: -100px;
            left: -100px;
        }

        .blob-2 {
            width: 400px;
            height: 400px;
            bottom: -150px;
            right: -100px;
            background: rgba(242, 107, 33, 0.05);
        }

        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }
        
        .exception-toggle {
            margin-top: 25px;
            font-size: 13px;
            color: var(--text-muted);
            cursor: pointer;
            text-decoration: underline;
        }
        
        .exception-details {
            display: none;
            margin-top: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            text-align: left;
            font-family: monospace;
            font-size: 12px;
            color: #d9534f;
            max-height: 150px;
            overflow-y: auto;
            border: 1px solid #eee;
        }
    </style>
</head>
<body>
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>

    <div class="error-container">
        <i class="fa-solid fa-cake-candles error-icon"></i>
        <div class="error-code">500</div>
        <h1 class="error-title">Ôi hỏng! Lò nướng đang gặp sự cố.</h1>
        <p class="error-message">
            Có vẻ như máy chủ của tiệm bánh BakeryZone vừa gặp phải một sự cố nhỏ trong quá trình xử lý yêu cầu của bạn. Đội ngũ thợ bánh (Dev) đã được thông báo và đang tiến hành sửa chữa!
        </p>
        <a href="${pageContext.request.contextPath}/home" class="btn-home">
            <i class="fa-solid fa-house"></i> Quay về Trang chủ
        </a>
        
        <%-- Exception Details Section (Only visible if exception exists, typically useful for Devs) --%>
        <% if (exception != null) { %>
            <div class="exception-toggle" onclick="document.getElementById('exc-detail').style.display = 'block'; this.style.display='none';">
                Xem chi tiết lỗi (Dành cho nhà phát triển)
            </div>
            <div class="exception-details" id="exc-detail">
                <strong>Exception:</strong> <%= exception.getMessage() %><br><br>
                <%
                    for (StackTraceElement elem : exception.getStackTrace()) {
                        out.println(elem.toString() + "<br>");
                    }
                %>
            </div>
        <% } %>
    </div>
</body>
</html>
