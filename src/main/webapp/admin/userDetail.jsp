<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <title>CakeZone - Account Manager Form</title>
    <meta content="width=device-width, initial-scale=1.0" name="viewport">

    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --cz-primary: #F28123;
            --cz-primary-hover: #e06f14;
            --cz-dark-bg: #111010;
            --cz-sidebar-active: #232222;
            --cz-text-muted: #888888;
            --cz-border-color: #f1ede8;
            --cz-light-bg: #f8f6f4;
            --cz-card-bg: #ffffff;
        }

        body {
            font-family: 'Outfit', sans-serif;
            background-color: var(--cz-light-bg);
            color: #333;
            overflow-x: hidden;
            margin: 0;
        }

        /* Sidebar Styling giống hệt trang danh sách */
        .sidebar {
            width: 260px;
            background-color: var(--cz-dark-bg);
            min-height: 100vh;
            position: fixed;
            top: 0; left: 0;
            display: flex;
            flex-direction: column;
            padding: 20px 0;
            z-index: 100;
        }

        .sidebar-brand {
            padding: 0 25px 25px 25px;
            display: flex;
            align-items: center;
            border-bottom: 1px solid #2d2b2b;
        }

        .sidebar-brand i {
            color: var(--cz-primary);
            font-size: 24px;
            margin-right: 10px;
        }

        .sidebar-brand span {
            color: #fff;
            font-size: 20px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .sidebar-brand span span {
            color: var(--cz-primary);
        }

        .nav-section-title {
            color: var(--cz-text-muted);
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 20px 25px 8px 25px;
        }

        .sidebar-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .menu-item a {
            display: flex;
            align-items: center;
            padding: 11px 25px;
            color: #b5b5b5;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .menu-item a:hover {
            color: #fff;
            background-color: var(--cz-sidebar-active);
        }

        .menu-item.active a {
            color: var(--cz-primary);
            background-color: var(--cz-sidebar-active);
            border-left: 3px solid var(--cz-primary);
            font-weight: 600;
        }

        .menu-item a i {
            width: 20px;
            font-size: 16px;
            margin-right: 12px;
        }

        .sidebar-banner {
            margin: auto 20px 20px 20px;
            background: linear-gradient(135deg, #232222, #181717);
            border-radius: 12px;
            padding: 20px;
            border: 1px dashed var(--cz-primary);
            text-align: center;
        }

        .sidebar-banner i.cake-icon {
            font-size: 40px;
            color: var(--cz-primary);
            margin-bottom: 10px;
            display: inline-block;
        }

        .sidebar-banner h6 { color: #fff; font-size: 14px; margin-bottom: 6px; }
        .sidebar-banner p { color: #999; font-size: 11px; margin-bottom: 0; }

        /* Main Panel & Container trải rộng */
        .main-panel {
            margin-left: 260px;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .top-header {
            height: 70px;
            background-color: #fff;
            border-bottom: 1px solid var(--cz-border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 35px;
            position: sticky;
            top: 0;
            z-index: 90;
        }

        .breadcrumbs { font-size: 13px; color: var(--cz-text-muted); }
        .breadcrumbs a { color: var(--cz-text-muted); text-decoration: none; }
        .breadcrumbs span { margin: 0 6px; }

        .content-container {
            padding: 35px;
            flex: 1;
        }

        /* Form Card Trải Rộng Toàn Bộ Màn Hình */
        .form-card {
            background-color: var(--cz-card-bg);
            border-radius: 12px;
            padding: 35px;
            border: 1px solid var(--cz-border-color);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            width: 100%; /* Ép chiếm trọn chiều rộng vùng chứa */
        }

        .page-title {
            font-size: 26px;
            font-weight: 700;
            color: #111;
            margin-bottom: 4px;
        }

        .page-subtitle {
            font-size: 13.5px;
            color: var(--cz-text-muted);
            margin-bottom: 25px;
        }

        .form-label {
            font-size: 14px;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        /* Custom Input & Select đồng bộ phong cách mượt mà */
        .form-control, .form-select {
            height: 48px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            font-size: 14px;
            padding: 10px 15px;
            background-color: #fff;
            transition: all 0.2s;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--cz-primary);
            box-shadow: 0 0 0 3px rgba(242, 129, 35, 0.1);
            background-color: #fff;
        }

        .btn-cz-primary {
            background-color: var(--cz-primary);
            color: #fff;
            font-weight: 600;
            font-size: 14.5px;
            padding: 12px 25px;
            border-radius: 8px;
            border: none;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-cz-primary:hover {
            background-color: var(--cz-primary-hover);
            color: #fff;
            transform: translateY(-1px);
            box-shadow: 0 4px 10px rgba(242, 129, 35, 0.25);
        }

        .btn-cz-secondary {
            background-color: #f5f5f5;
            color: #555;
            font-weight: 600;
            font-size: 14.5px;
            padding: 12px 25px;
            border-radius: 8px;
            border: 1px solid var(--cz-border-color);
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-cz-secondary:hover {
            background-color: #e5e5e5;
            color: #333;
        }
    </style>
</head>

<body>

    <div class="sidebar">
        <div class="sidebar-brand">
            <i class="fa-solid fa-cake-candles"></i>
            <span>Cake<span>Zone</span> Admin</span>
        </div>
        
        <div class="nav-section-title">Hệ thống chính</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-gauge"></i> Bảng điều khiển</a>
            </li>
        </ul>

        <div class="nav-section-title">Quản lý</div>
        <ul class="sidebar-menu">
            <li class="menu-item">
                <a href="#"><i class="fa-solid fa-receipt"></i> Đơn hàng</a>
            </li>
            <li class="menu-item">
                <a href="${pageContext.request.contextPath}/admin/products"><i class="fa-solid fa-cookie-bite"></i> Sản phẩm</a>
            </li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-users"></i> Khách hàng</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-percent"></i> Khuyến mãi</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-warehouse"></i> Kho hàng</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-truck-ramp-box"></i> Giao hàng</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-star-half-stroke"></i> Đánh giá</a></li>
        </ul>

        <div class="nav-section-title">Hệ thống</div>
        <ul class="sidebar-menu">
            <li class="menu-item active">
                <a href="${pageContext.request.contextPath}/userList"><i class="fa-solid fa-user-gear"></i> Tài khoản</a>
            </li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-shield-halved"></i> Vai trò & Quyền hạn</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-sliders"></i> Cài đặt chung</a></li>
            <li class="menu-item"><a href="#"><i class="fa-solid fa-clock-rotate-left"></i> Nhật ký hoạt động</a></li>
        </ul>

        <div class="sidebar-banner">
            <i class="fa-solid fa-cake-candles cake-icon"></i>
            <h6>Phát triển tiệm bánh</h6>
            <p>Tạo ra những chiếc bánh đẹp và trao gửi hạnh phúc!</p>
        </div>
    </div>

    <div class="main-panel">
        
        <div class="top-header">
            <div class="header-left">
                <div class="breadcrumbs">
                    <a href="#">Dashboard</a>
                    <span>&gt;</span>
                    <a href="${pageContext.request.contextPath}/userList">System</a>
                    <span>&gt;</span>
                    <a href="#" class="active text-dark font-weight-bold">
                        <c:if test="${USER_DATA.userId != null}">Cập nhật tài khoản</c:if>
                        <c:if test="${USER_DATA.userId == null}">Thêm tài khoản mới</c:if>
                    </a>
                </div>
            </div>
            
            <div class="header-right">
                <div class="profile-section d-flex align-items-center gap-3">
                    <span class="fw-bold" style="font-size: 14px;">Hoàng Anh</span>
                    <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="rounded-circle" width="35" height="35">
                </div>
            </div>
        </div>

        <div class="content-container">
            <div class="form-card">
                
                <h1 class="page-title text-uppercase">
                    <c:if test="${USER_DATA.userId != null}">Cập nhật tài khoản</c:if>
                    <c:if test="${USER_DATA.userId == null}">Thêm tài khoản mới</c:if>
                </h1>
                <p class="page-subtitle">Nhập thông tin chi tiết cho nhân sự và phân quyền hệ thống Bakery</p>

                <c:if test="${ERROR_MSG != null}">
                    <div class="alert alert-danger font-weight-bold mb-4" style="border-radius: 8px;">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i>${ERROR_MSG}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/userDetail" method="POST">
                    <input type="hidden" name="action" value="${param.action}">
                    <input type="hidden" name="userId" value="${USER_DATA.userId}">

                    <div class="row g-4">
                        <div class="col-md-6">
                            <label class="form-label">Họ và Tên người dùng <span class="text-danger">*</span></label>
                            <input type="text" name="fullName" value="${USER_DATA.fullName}" class="form-control" placeholder="Nhập đầy đủ họ và tên..." required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Số điện thoại liên lạc <span class="text-danger">*</span></label>
                            <input type="text" name="phone" value="${USER_DATA.phone}" class="form-control" placeholder="Nhập số điện thoại..." required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Email đăng nhập hệ thống <span class="text-danger">*</span></label>
                            <input type="email" name="email" value="${USER_DATA.email}" class="form-control" placeholder="username@gmail.com" required
                                   ${param.action == 'edit' ? 'readonly style="background-color: #f1ede8; cursor: not-allowed;"' : ''}>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Mật khẩu tài khoản <span class="text-danger">*</span></label>
                            <input type="password" name="password" class="form-control" placeholder="${param.action == 'edit' ? 'Để trống nếu không muốn đổi...' : 'Tạo mật khẩu...'}" ${param.action == 'edit' ? '' : 'required'}>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Chức vụ hệ thống <span class="text-danger">*</span></label>
                            <select name="roleId" class="form-select">
                                <option value="CUSTOMER" ${USER_DATA.roleId == 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
                                <option value="SHIPPER" ${USER_DATA.roleId == 'SHIPPER' ? 'selected' : ''}>Người giao hàng</option>
                                <option value="STAFF" ${USER_DATA.roleId == 'STAFF' ? 'selected' : ''}>Nhân viên</option>
                                <option value="ADMIN" ${USER_DATA.roleId == 'ADMIN' ? 'selected' : ''}>Quản lý</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Trạng thái tài khoản <span class="text-danger">*</span></label>
                            <select name="accountStatus" class="form-select">
                                <option value="Active" ${USER_DATA.accountStatus == 'Active' ? 'selected' : ''}>Active (Đang hoạt động)</option>
                                <option value="Deactive" ${USER_DATA.accountStatus == 'Deactive' ? 'selected' : ''}>Deactive (Vô hiệu hóa)</option>
                            </select>
                        </div>

                        <div class="col-12 d-flex justify-content-end gap-3 mt-5">
                            <a href="${pageContext.request.contextPath}/userList" class="btn-cz-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Trở về danh sách
                            </a>
                            <button class="btn-cz-primary" type="submit">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu thông tin tài khoản
                            </button>
                        </div>
                    </div>
                </form>

            </div>
        </div>
    </div>

    <script>
        function validateForm() {
            let fullName = document.getElementsByName("fullName")[0].value.trim();
            let email = document.getElementsByName("email")[0].value.trim();
            let phone = document.getElementsByName("phone")[0].value.trim();
            let password = document.getElementsByName("password")[0].value;
            let action = document.getElementsByName("action")[0].value;

            if (fullName.length < 2) {
                alert("Họ và tên phải có ít nhất 2 ký tự!");
                return false;
            }

            let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            if (!emailRegex.test(email)) {
                alert("Email không đúng định dạng (Ví dụ: example@gmail.com)!");
                return false;
            }

            if (action !== "edit" && password.length < 6) {
                alert("Mật khẩu tạo mới phải từ 6 ký tự trở lên!");
                return false;
            }

            let phoneRegex = /^(0)[3|5|7|8|9][0-9]{8}$/;
            if (!phoneRegex.test(phone)) {
                alert("Số điện thoại không hợp lệ! Phải gồm 10 chữ số và bắt đầu bằng đầu số VN (03, 05, 07, 08, 09)!");
                return false;
            }

            return true;
        }

        document.querySelector("form").removeAttribute("onsubmit");
        document.querySelector("form").setAttribute("onsubmit", "return validateForm()");
    </script>
</body>
</html>