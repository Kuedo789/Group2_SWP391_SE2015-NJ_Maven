<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%-- Khai báo cả 2 phiên bản URI để đảm bảo NetBeans/Tomcat không bao giờ bị báo đỏ sọc --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone - Customer Manager Form" />
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

            /* CSS Sidebar */
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
                color: var(--cz-primary) !important;
                background-color: var(--cz-sidebar-active);
                border-left: 3px solid var(--cz-primary);
                font-weight: 600;
            }
            .menu-item a i {
                display: inline-block;
                width: 20px;
                font-size: 16px;
                margin-right: 12px;
                text-align: center;
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

            /* Main Panel */
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

            /* Form Card */
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
                box-shadow: 0 4px 10px rgba(63, 95, 54, 0.25);
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
            <jsp:param name="activeMenu" value="customers" />
        </jsp:include>

        <div class="main-panel">
            <c:set var="cusId" value="${CUSTOMER_DATA.customerId}" />
            <!-- Top Header -->
            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="Customer System" />
                <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/admin/customer?action=list" />
                <jsp:param name="activeMenu" value="${cusId != null ? 'Cập nhật thông tin khách hàng' : 'Thêm khách hàng mới'}" />
            </jsp:include>

            <div class="content-container">
                <div class="form-card">

                    <h1 class="page-title text-uppercase">
                        <c:if test="${cusId != null}">Cập nhật thông tin khách hàng</c:if>
                        <c:if test="${cusId == null}">Thêm khách hàng mới</c:if>
                        </h1>
                        <p class="page-subtitle">Nhập thông tin chi tiết cho tài khoản khách hàng hệ thống Bakery</p>

                    <c:if test="${ERROR_MSG != null}">
                        <div class="alert alert-danger font-weight-bold mb-4" style="border-radius: 8px;">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>${ERROR_MSG}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/admin/customer" method="POST">  
                        <input type="hidden" name="action" value="${not empty param.action ? param.action : (CUSTOMER_DATA.customerId != null ? 'edit' : 'add')}">
                        <input type="hidden" name="isEdit" value="${CUSTOMER_DATA != null ? 'true' : 'false'}">                      
                        <input type="hidden" name="customerId" value="${cusId}">

                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label">Họ và Tên khách hàng <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" value="${CUSTOMER_DATA.fullName}" class="form-control" placeholder="Nhập đầy đủ họ và tên khách hàng..." required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Số điện thoại liên lạc <span class="text-danger">*</span></label>
                                <input type="text" name="phone" value="${CUSTOMER_DATA.phone}" class="form-control" placeholder="Nhập số điện thoại..." required>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label">Email đăng nhập <span class="text-danger">*</span></label>
                                <input type="email" name="email" value="${CUSTOMER_DATA.user.email}" class="form-control" placeholder="username@gmail.com" required>
                            </div>
                            <%--
                                                  <div class="col-md-6">
                                                      <label class="form-label">Mật khẩu tài khoản <span class="text-danger">*</span></label>
                                                      <input type="password" name="password" class="form-control" autocomplete="new-password" placeholder="${param.action == 'edit' ? 'Để trống nếu không muốn đổi...' : 'Tạo mật khẩu...'}" ${param.action == 'edit' ? '' : 'required'}>
                                                  </div>
                            --%>
                            <div class="col-12">
                                <label class="form-label">Địa chỉ mặc định</label>
                                <input type="text" name="defaultAddress" value="${CUSTOMER_DATA.defaultAddress}" class="form-control" placeholder="Nhập địa chỉ chi tiết (Ví dụ: Số 12 Nguyễn Trãi, Hà Nội)...">
                            </div>  

                            <div class="col-md-6">
                                <label class="form-label">Trạng thái tài khoản <span class="text-danger">*</span></label>
                                <c:set var="statusKey" value="${CUSTOMER_DATA.user.accountStatus}" />
                                <select name="accountStatus" class="form-select">
                                    <option value="Active" ${statusKey == 'Active' ? 'selected' : ''}>Active (Đang hoạt động)</option>
                                    <option value="Deactive" ${statusKey == 'Deactive' ? 'selected' : ''}>Deactive (Vô hiệu hóa)</option>
                                </select>
                            </div>


                            <div class="col-12 d-flex justify-content-end gap-3 mt-5">
                                <a href="${pageContext.request.contextPath}/admin/customer?action=list" class="btn-cz-secondary">
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
                let defaultAddress = document.getElementsByName("defaultAddress")[0].value.trim();


                if (fullName.length < 2) {
                    alert("Họ và tên khách hàng phải có ít nhất 2 ký tự!");
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
                if (defaultAddress.length > 100) {
                    alert("Địa chỉ mặc định không được vượt quá 100 ký tự!");
                    return false;
                }
                return true;
            }

            document.querySelector("form").removeAttribute("onsubmit");
            document.querySelector("form").setAttribute("onsubmit", "return validateForm()");
        </script>
    </body>
</html>
