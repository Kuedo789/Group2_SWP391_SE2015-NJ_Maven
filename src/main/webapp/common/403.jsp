<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>CakeZone Admin - Từ chối truy cập</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Outfit', sans-serif;
                background-color: #f8f6f4;
                height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .error-card {
                background: #fff;
                padding: 40px;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.05);
                text-align: center;
                max-width: 500px;
            }
            .error-icon {
                color: #dc3545;
                font-size: 64px;
                margin-bottom: 20px;
            }
            .btn-back {
                background-color: #3f5f36;
                color: white;
                border: none;
                padding: 10px 25px;
                border-radius: 6px;
                text-decoration: none;
                font-weight: 600;
                display: inline-block;
                margin-top: 20px;
            }
            .btn-back:hover {
                background-color: #2f4728;
                color: white;
            }
        </style>
    </head>
    <body>
        
      
        <div class="error-card">
            <div class="error-icon">🔒</div>
            <h1 class="fw-bold text-dark" style="font-size: 28px;">Từ chối truy cập (403)</h1>
            <p class="text-secondary mt-3">Tài khoản của bạn hiện tại đã bị Admin giới hạn hoặc hủy kích hoạt quyền hạn đối với tính năng này.</p>
            <button onclick="goBackOrHome()" class="btn btn-primary">
                Quay lại trang trước
            </button>

            <script>
                function goBackOrHome() {

                    if (document.referrer !== "") {
                        window.history.back();
                    } else {
                        window.location.href = "${pageContext.request.contextPath}/admin/orders?action=list";
                    }
                }
            </script>

        </div>
    </body>
</html>