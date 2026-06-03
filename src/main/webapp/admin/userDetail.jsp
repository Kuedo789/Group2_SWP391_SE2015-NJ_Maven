<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>CakeZone - Account Manager Form</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <link href="img/favicon.ico" rel="icon">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">
        <link href="lib/owlcarousel/assets/owl.carousel.min.css" rel="stylesheet">
        <link href="css/bootstrap.min.css" rel="stylesheet">
        <link href="css/style.css" rel="stylesheet">
    </head>

    <body>

        <div class="container-fluid bg-dark bg-img p-5 mb-5">
            <div class="row">
                <div class="col-12 text-center">
                    <h1 class="display-4 text-uppercase text-white">
                        <c:if test="${USER_DATA != null}">Update Account</c:if>
                        <c:if test="${USER_DATA == null}">Create Account</c:if>
                        </h1>
                        <a href="${pageContext.request.contextPath}/userList" class="text-primary font-weight-bold">← Back to List</a>
                </div>
            </div>
        </div>
        <div class="container-fluid contact position-relative px-5" style="margin-top: 20px;">
            <div class="container">

                <div class="row justify-content-center">
                    <div class="col-lg-7">
                        <div class="text-center position-relative mb-5 mx-auto" style="max-width: 600px;">
                            <h4 class="text-primary text-uppercase" style="letter-spacing: 2px;">Account Details</h4>
                            <h1 class="display-5 text-uppercase">
                                <c:if test="${USER_DATA != null}">Cập Nhật Tài Khoản</c:if>
                                <c:if test="${USER_DATA == null}">Thêm Tài Khoản Mới</c:if>
                                </h1>
                            </div>

                            <form action="${pageContext.request.contextPath}/userDetail" method="POST">

                            <input type="hidden" name="action" value="${param.action}">
                            <input type="hidden" name="userId" value="${USER_DATA.userId}">

                            <div class="row g-3">
                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark">Họ và Tên người dùng:</label>
                                    <input type="text" name="fullName" value="${USER_DATA.fullName}" required class="form-control bg-light border-0 px-4" placeholder="Nhập đầy đủ họ và tên..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark">Email đăng nhập hệ thống:</label>
                                    <input type="email" name="email" value="${USER_DATA.email}" required class="form-control bg-light border-0 px-4" placeholder="username@gmail.com" style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark">Mật khẩu tài khoản:</label>
                                    <input type="password" name="password" value="${USER_DATA.password}" required class="form-control bg-light border-0 px-4" placeholder="Nhập mật khẩu..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark">Số điện thoại liên lạc:</label>
                                    <input type="text" name="phone" value="${USER_DATA.phone}" required pattern="[0-9]+" oninvalid="this.setCustomValidity('Hãy nhập số')" 
                                           oninput="this.setCustomValidity('')" class="form-control bg-light border-0 px-4" placeholder="Nhập số điện thoại..." style="height: 55px;">
                                </div>

                                <div class="col-sm-12">
                                    <label class="form-label font-weight-bold text-dark">Chức vụ hệ thống (Role_ID):</label>
                                    <select name="roleId" class="form-select bg-light border-0 px-4" style="height: 55px; width: 100%;">
                                        <option value="ADMIN" ${USER_DATA.roleId == 'ADMIN' ? 'selected' : ''}>Admin</option>
                                        <option value="STAFF" ${USER_DATA.roleId == 'STAFF' ? 'selected' : ''}>Staff</option>
                                        <option value="SHIPPER" ${USER_DATA.roleId == 'SHIPPER' ? 'selected' : ''}>Shipper</option>
                                        <option value="CUSTOMER" ${USER_DATA.roleId == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                                    </select>
                                </div>

                                <div class="col-sm-12 mt-4">
                                    <button class="btn btn-primary w-100 py-3 text-uppercase font-weight-bold" type="submit">Lưu thông tin tài khoản</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>


    </body>
</html>
