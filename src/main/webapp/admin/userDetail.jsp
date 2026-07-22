<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%-- Khai báo cả 2 phiên bản URI để đảm bảo NetBeans/Tomcat không bao giờ bị báo đỏ sọc --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone - Account Manager Form" />
        </jsp:include>

        <style>
            :root {
                --cz-primary: #3f5f36;
                --cz-primary-hover: #2f4728;
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
                height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
                display: flex;
                flex-direction: column;
                padding: 20px 0;
                z-index: 100;
                overflow-y: auto;
            }

            .sidebar::-webkit-scrollbar {
                width: 6px;
            }
            .sidebar::-webkit-scrollbar-track {
                background: transparent;
            }
            .sidebar::-webkit-scrollbar-thumb {
                background: rgba(255, 255, 255, 0.25);
                border-radius: 4px;
            }
            .sidebar::-webkit-scrollbar-thumb:hover {
                background: rgba(255, 255, 255, 0.45);
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

            .sidebar-banner h6 {
                color: #fff;
                font-size: 14px;
                margin-bottom: 6px;
            }
            .sidebar-banner p {
                color: #999;
                font-size: 11px;
                margin-bottom: 0;
            }

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
                width: 100%;
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
                box-shadow: 0 0 0 3px rgba(63, 95, 54, 0.15);
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
        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="users" />
        </jsp:include>
        <div class="main-panel">

            <!-- Top Header -->
            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="System" />
                <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/admin/staff?action=list" />
                <jsp:param name="activeMenu" value="${USER_DATA.staffId != null ? 'Cập nhật tài khoản' : 'Thêm tài khoản mới'}" />
            </jsp:include>

            <div class="content-container">
                <div class="form-card">

                    <h1 class="page-title text-uppercase">
                        <c:if test="${USER_DATA.staffId != null}">Cập nhật tài khoản</c:if>
                        <c:if test="${USER_DATA.staffId == null}">Thêm tài khoản mới</c:if>
                        </h1>
                        <p class="page-subtitle">Nhập thông tin chi tiết cho nhân sự và phân quyền hệ thống Bakery</p>

                    <c:if test="${ERROR_MSG != null}">
                        <div class="alert alert-danger font-weight-bold mb-4" style="border-radius: 8px;">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>${ERROR_MSG}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/admin/staff" method="POST">
                        <input type="hidden" name="action" value="${not empty param.action ? param.action : (USER_DATA.staffId != null ? 'edit' : 'add')}">
                        <input type="hidden" name="isEdit" value="${USER_DATA.staffId != null ? 'true' : 'false'}">
                        <input type="hidden" name="userId" value="${USER_DATA.staffId}">

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
                                <input type="email" name="email" value="${USER_DATA.user.email}" class="form-control" placeholder="username@gmail.com" required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Chức vụ hệ thống <span class="text-danger">*</span></label>
                                <select name="roleId" id="roleSelect" class="form-select" onchange="toggleManagedZone()">
                                    <option value="SHIPPER" ${USER_DATA.user.roleId == 'SHIPPER' ? 'selected' : ''}>Người giao hàng</option>
                                    <option value="STAFF" ${USER_DATA.user.roleId == 'STAFF' ? 'selected' : ''}>Nhân viên</option>
                                    <option value="ADMIN" ${USER_DATA.user.roleId == 'ADMIN' ? 'selected' : ''}>Quản lý</option>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Trạng thái tài khoản <span class="text-danger">*</span></label>
                                <select name="accountStatus" class="form-select">
                                    <option value="Active" ${USER_DATA.user.accountStatus == 'Active' ? 'selected' : ''}>Active (Đang hoạt động)</option>
                                    <option value="Deactive" ${USER_DATA.user.accountStatus == 'Deactive' ? 'selected' : ''}>Deactive (Đã khóa)</option>
                                </select>
                            </div>

                            <div class="col-md-6" id="managedZoneGroup" style="display: none;">
                                <label class="form-label">Khu vực quản lý (Giao hàng) <span class="text-muted">(Dành cho Shipper)</span></label>
                                <c:set var="mZone" value="${empty USER_DATA.managedZone ? 'Toàn thành phố' : USER_DATA.managedZone}" />
                                <select name="managedZone" class="form-select">
                                    <option value="Toàn thành phố" ${mZone == 'Toàn thành phố' ? 'selected' : ''}>Toàn thành phố (Tất cả khu vực)</option>
                                    <option value="Đống Đa" ${mZone == 'Đống Đa' ? 'selected' : ''}>Đống Đa</option>
                                    <option value="Cầu Giấy" ${mZone == 'Cầu Giấy' ? 'selected' : ''}>Cầu Giấy</option>
                                    <option value="Thanh Xuân" ${mZone == 'Thanh Xuân' ? 'selected' : ''}>Thanh Xuân</option>
                                    <option value="Hoàn Kiếm" ${mZone == 'Hoàn Kiếm' ? 'selected' : ''}>Hoàn Kiếm</option>
                                    <option value="Hai Bà Trưng" ${mZone == 'Hai Bà Trưng' ? 'selected' : ''}>Hai Bà Trưng</option>
                                    <option value="Ba Đình" ${mZone == 'Ba Đình' ? 'selected' : ''}>Ba Đình</option>
                                    <option value="Nam Từ Liêm" ${mZone == 'Nam Từ Liêm' ? 'selected' : ''}>Nam Từ Liêm</option>
                                    <option value="Bắc Từ Liêm" ${mZone == 'Bắc Từ Liêm' ? 'selected' : ''}>Bắc Từ Liêm</option>
                                </select>
                            </div>

                            <div class="col-12 d-flex justify-content-end gap-3 mt-5">
                                <a href="${pageContext.request.contextPath}/admin/staff?action=list" class="btn-cz-secondary">
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
            function toggleManagedZone() {
                let roleSelect = document.getElementById("roleSelect");
                let zoneGroup = document.getElementById("managedZoneGroup");
                if (roleSelect && zoneGroup) {
                    if (roleSelect.value === "SHIPPER") {
                        zoneGroup.style.display = "block";
                    } else {
                        zoneGroup.style.display = "none";
                    }
                }
            }

            // Tự động kiểm tra hiển thị khi trang load xong (phục vụ mode Edit hoặc giữ state)
            document.addEventListener("DOMContentLoaded", function() {
                toggleManagedZone();
            });

            function validateForm() {
                let fullName = document.getElementsByName("fullName")[0].value.trim();
                let email = document.getElementsByName("email")[0].value.trim();
                let phone = document.getElementsByName("phone")[0].value.trim();

                if (fullName.length < 2) {
                    alert("Họ và tên phải có ít nhất 2 ký tự!");
                    return false;
                }

                let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                if (!emailRegex.test(email)) {
                    alert("Email không đúng định dạng (Ví dụ: example@gmail.com)!");
                    return false;
                }

                let phoneRegex = /^(0)[35789][0-9]{8}$/;
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

