<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>CakeZone - Account Manager Form</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">

        <style>
            body {
                background-color: #fdfbf7;
                color: #333;
            }
            .bg-cake-dark {
                background-color: #2b2b2b !important;
            }
            .text-cake-orange {
                color: #F15B22 !important;
            }
            .btn-cake-primary {
                background-color: #F15B22 !important;
                color: white !important;
                border: none;
            }
            .btn-cake-primary:hover {
                background-color: #d44917 !important;
            }
        </style>
    </head>

    <body>

        <div class="container-fluid bg-cake-dark p-5 mb-5 text-center">
            <h1 class="display-4 text-uppercase text-white m-0">
                <c:if test="${USER_DATA != null}">Update Account</c:if>
                <c:if test="${USER_DATA == null}">Create Account</c:if>
                </h1>
                <a href="${pageContext.request.contextPath}/userList" class="text-cake-orange font-weight-bold" style="text-decoration: none;">← Back to List</a>
        </div>

        <div class="container-fluid contact position-relative px-5" style="margin-top: 20px;">
            <div class="container">

                <div class="row justify-content-center">
                    <div class="col-lg-7 bg-white p-5 shadow-sm" style="border-radius: 8px; border: 1px solid #eae5d9;">
                        <div class="text-center position-relative mb-5 mx-auto" style="max-width: 600px;">
                            <h4 class="text-cake-orange text-uppercase" style="letter-spacing: 2px;">Account Details</h4>
                            <h1 class="display-5 text-uppercase font-weight-bold text-dark">
                                <c:if test="${USER_DATA != null}">Cập Nhật Tài Khoản</c:if>
                                <c:if test="${USER_DATA == null}">Thêm Tài Khoản Mới</c:if>
                                </h1>
                            </div>

                            <form action="${pageContext.request.contextPath}/userDetail" method="POST">
                            <c:if test="${ERROR_MSG != null}">
                                <div class="alert alert-danger text-center font-weight-bold mb-4" style="border-radius: 8px;">
                                    <i class="fa fa-exclamation-triangle me-2"></i>${ERROR_MSG}
                                </div>
                            </c:if>
                            <input type="hidden" name="action" value="${param.action}">
                            <input type="hidden" name="userId" value="${USER_DATA.userId}">

                            <div class="row g-3">
                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark fw-bold">Họ và Tên người dùng:</label>
                                    <input type="text" name="fullName" value="${USER_DATA.fullName}" required class="form-control bg-light border-0 px-4" placeholder="Nhập đầy đủ họ và tên..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark fw-bold">Email đăng nhập hệ thống:</label>
                                    <input type="email" name="email" value="${USER_DATA.email}" required class="form-control bg-light border-0 px-4" placeholder="username@gmail.com" style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark fw-bold">Mật khẩu tài khoản:</label>
                                    <input type="password" name="password" value="${USER_DATA.password}" required class="form-control bg-light border-0 px-4" placeholder="Nhập mật khẩu..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark fw-bold">Số điện thoại liên lạc:</label>
                                    <input type="text" name="phone" value="${USER_DATA.phone}" required pattern="[0-9]+" oninvalid="this.setCustomValidity('Hãy nhập số')" oninput="this.setCustomValidity('')" class="form-control bg-light border-0 px-4" placeholder="Nhập số điện thoại..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark fw-bold">Chức vụ hệ thống (Role_ID):</label>
                                    <select name="roleId" class="form-select bg-light border-0 px-4" style="height: 55px; width: 100%;">
                                        <option value="ADMIN" ${USER_DATA.roleId == 'ADMIN' ? 'selected' : ''}>Admin</option>
                                        <option value="STAFF" ${USER_DATA.roleId == 'STAFF' ? 'selected' : ''}>Staff</option>
                                        <option value="SHIPPER" ${USER_DATA.roleId == 'SHIPPER' ? 'selected' : ''}>Shipper</option>
                                        <option value="CUSTOMER" ${USER_DATA.roleId == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                                    </select>
                                </div>

                                <c:if test="${USER_DATA != null}">
                                    <div class="col-sm-12">
                                        <label class="form-label font-weight-bold text-dark fw-bold">Trạng thái tài khoản:</label>
                                        <select name="accountStatus" class="form-select bg-light border-0 px-4" style="height: 55px; width: 100%;">
                                            <option value="Active" ${USER_DATA.accountStatus == 'Active' ? 'selected' : ''}>Active (Đang hoạt động)</option>
                                            <option value="Deactive" ${USER_DATA.accountStatus == 'Deactive' ? 'selected' : ''}>Deactive (Vô hiệu hóa)</option>
                                        </select>
                                    </div>
                                </c:if>

                                <div class="col-sm-12 mt-4">
                                    <button class="btn btn-cake-primary w-100 py-3 text-uppercase font-weight-bold" type="submit">Lưu thông tin tài khoản</button>
                                </div>
                            </div>
                        </form>
                    </div>
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

                // 1. Kiểm tra họ tên
                if (fullName.length < 2) {
                    alert("Họ và tên phải có ít nhất 2 ký tự!");
                    return false;
                }

                // 2. Kiểm tra định dạng Email
                let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                if (!emailRegex.test(email)) {
                    alert("Email không đúng định dạng (Ví dụ: example@gmail.com)!");
                    return false;
                }

                // 3. Kiểm tra độ dài mật khẩu khi thêm mới
                if (action !== "edit" && password.length < 6) {
                    alert("Mật khẩu tạo mới phải từ 6 ký tự trở lên!");
                    return false;
                }

                // 4. Kiểm tra số điện thoại Việt Nam chuẩn (10 số, bắt đầu bằng số 0)
                let phoneRegex = /^(0)[3|5|7|8|9][0-9]{8}$/;
                if (!phoneRegex.test(phone)) {
                    alert("Số điện thoại không hợp lệ! Phải gồm 10 chữ số và bắt đầu bằng đầu số VN (03, 05, 07, 08, 09)!");
                    return false;
                }

                return true;
            }

            // Gắn sự kiện validate vào thẻ form khi submit
            document.querySelector("form").removeAttribute("onsubmit");
            document.querySelector("form").setAttribute("onsubmit", "return validateForm()");
        </script>
    </body>
</html>
