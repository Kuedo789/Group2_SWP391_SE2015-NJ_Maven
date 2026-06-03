<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>CakeZone - Admin User Management</title>
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
                    <h1 class="display-4 text-uppercase text-white">User Management</h1>
                </div>
            </div>
        </div>
        <div class="container-fluid contact position-relative px-5" style="margin-top: 50px;">
            <div class="container">

                <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                    <div>
                        <h1 class="text-uppercase mb-0">Danh sách người dùng</h1>
                        <p class="text-muted mb-0">Hệ thống quản lý Admin, Staff, Shipper và Customer</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/userDetail?action=add" class="btn btn-primary py-3 px-4 text-uppercase font-weight-bold">
                        <i class="fa fa-plus me-2"></i>Thêm tài khoản mới
                    </a>
                </div>

                <div class="bg-dark p-4 border-inner mb-5">
                    <form action="${pageContext.request.contextPath}/userList" method="GET">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-5">
                                <label class="form-label text-white font-weight-bold">Từ khóa tìm kiếm:</label>
                                <input type="text" name="searchKeyword" value="${param.searchKeyword}" class="form-control bg-light border-0 px-4" placeholder="Nhập tên hoặc email người dùng..." style="height: 45px;">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label text-white font-weight-bold">Chức vụ (Role):</label>
                                <select name="filterRoleId" class="form-select bg-light border-0 px-3" style="height: 45px; width: 100%;">
                                    <option value="">-- Tất cả chức vụ --</option>
                                    <option value="ADMIN" ${param.filterRoleId == 'ADMIN' ? 'selected' : ''}>Admin</option>
                                    <option value="STAFF" ${param.filterRoleId == 'STAFF' ? 'selected' : ''}>Staff</option>
                                    <option value="SHIPPER" ${param.filterRoleId == 'SHIPPER' ? 'selected' : ''}>Shipper</option>
                                    <option value="CUSTOMER" ${param.filterRoleId == 'CUSTOMER' ? 'selected' : ''}>Customer</option>
                                </select>
                            </div>
                            <div class="col-md-4 d-flex gap-2">
                                <button type="submit" class="btn btn-primary flex-grow-1 font-weight-bold text-uppercase" style="height: 45px;">Lọc kết quả</button>
                                <a href="user-list" class="btn btn-secondary flex-grow-1 font-weight-bold text-uppercase d-flex align-items-center justify-content-center text-white" style="height: 45px; background: #555; border: none;">Xóa bộ lọc</a>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12">
                        <div class="table-responsive shadow-sm" style="border: 2px solid #F15B22;">
                            <table class="table table-striped table-hover mb-0" style="background-color: #FFF; font-size: 16px;">
                                <thead class="bg-dark text-white text-uppercase text-center">
                                    <tr>
                                        <th style="padding: 15px; width: 80px;">STT</th>
                                        <th style="padding: 15px; text-align: left;">Họ và Tên</th>
                                        <th style="padding: 15px; text-align: left;">Email đăng nhập</th>
                                        <th style="padding: 15px; padding-left: 30px; width: 180px; text-align: left;">Số điện thoại</th>
                                        <th style="padding: 15px; width: 160px;">Chức vụ</th>
                                        <th style="padding: 15px; width: 180px;">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody class="text-dark">
                                    <c:forEach var="u" items="${USERS}" varStatus="loop">
                                        <tr class="align-middle">
                                            <td class="text-center font-weight-bold text-muted" style="padding: 15px;">${loop.index + 1}</td>
                                            <td class="font-weight-bold text-dark" style="padding: 15px;">${u.fullName}</td>
                                            <td style="padding: 15px;">${u.email}</td>
                                           <td class="text-primary font-weight-bold" style="padding: 15px; padding-left: 30px; text-align: left;">${u.phone}</td>
                                            <td class="text-center" style="padding: 15px;">
                                                <span class="badge ${u.roleId == 'ADMIN' ? 'bg-danger' : 'bg-warning text-dark'} px-2 py-2 text-uppercase">
                                                    ${u.roleId}
                                                </span>
                                            </td>
                                            <td class="text-center" style="padding: 15px;">
                                                <div class="d-inline-flex gap-2">
                                                    <a href="${pageContext.request.contextPath}/userDetail?action=edit&id=${u.userId}" class="btn btn-sm btn-outline-warning font-weight-bold px-3 py-2 text-dark" style="border-width: 2px;">Sửa</a>
                                                    <a href=""${pageContext.request.contextPath}/userDetail?action=delete&id=${u.userId}" class="btn btn-sm btn-outline-danger font-weight-bold px-3 py-2" style="border-width: 2px;" onclick="return confirm('Bạn có chắc muốn xóa tài khoản này không?')">Xóa</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty USERS}">
                                        <tr>
                                            <td colspan="6" class="text-center py-5 text-muted font-italic">
                                                <i class="fa fa-search fs-3 mb-2 d-block"></i>Không tìm thấy dữ liệu!
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>

    </body>
</html>