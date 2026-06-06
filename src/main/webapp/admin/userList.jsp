<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Khai báo cả 2 phiên bản URI để đảm bảo NetBeans không bao giờ bị báo đỏ sọc --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8">
        <title>CakeZone - Admin User Management</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.10.0/css/all.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.4.1/font/bootstrap-icons.css" rel="stylesheet">

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
            .border-cake {
                border: 2px solid #F15B22 !important;
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
            <h1 class="display-4 text-uppercase text-white m-0">User Management</h1>
        </div>

        <div class="container-fluid contact position-relative px-5" style="margin-top: 50px;">
            <div class="container">

                <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                    <div>
                        <h1 class="text-uppercase mb-0 font-weight-bold">Danh sách người dùng</h1>
                        <p class="text-muted mb-0">Hệ thống quản lý Admin, Staff, Shipper và Customer</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/userDetail?action=add" class="btn btn-cake-primary py-3 px-4 text-uppercase font-weight-bold">
                        <i class="fa fa-plus me-2"></i>Thêm tài khoản mới
                    </a>
                </div>

                <div class="bg-cake-dark p-4 mb-5" style="border-radius: 8px;">
                    <form action="${pageContext.request.contextPath}/userList" method="GET">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-4">
                                <label class="form-label text-white font-weight-bold">Từ khóa tìm kiếm:</label>
                                <input type="text" name="searchKeyword" value="${param.searchKeyword}" class="form-control bg-light border-0 px-4" placeholder="Nhập tên hoặc email..." style="height: 45px;">
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
                            <div class="col-md-2">
                                <label class="form-label text-white font-weight-bold">Trạng thái:</label>
                                <select name="filterStatus" class="form-select bg-light border-0 px-3" style="height: 45px; width: 100%;">
                                    <option value="">-- Tất cả --</option>
                                    <option value="Active" ${param.filterStatus == 'Active' ? 'selected' : ''}>Active</option>
                                    <option value="Deactive" ${param.filterStatus == 'Deactive' ? 'selected' : ''}>Deactive</option>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex gap-2">
                                <button type="submit" class="btn btn-cake-primary flex-grow-1 font-weight-bold text-uppercase" style="height: 45px;">Lọc kết quả</button>
                                <a href="${pageContext.request.contextPath}/userList" class="btn btn-secondary flex-grow-1 font-weight-bold text-uppercase d-flex align-items-center justify-content-center text-white" style="height: 45px; background: #555; border: none; text-decoration: none;">Xóa bộ lọc</a>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="row justify-content-center">
                    <div class="col-12">
                        <div class="table-responsive shadow-sm border-cake" style="border-radius: 8px; overflow: hidden;">
                            <table class="table table-striped table-hover mb-0" style="background-color: #FFF; font-size: 16px;">
                                <thead class="bg-cake-dark text-white text-uppercase text-center">
                                    <tr>
                                        <th style="padding: 15px; width: 80px;">STT</th>
                                        <th style="padding: 15px; text-align: left;">Họ và Tên</th>
                                        <th style="padding: 15px; text-align: left;">Email đăng nhập</th>
                                        <th style="padding: 15px; padding-left: 30px; width: 180px; text-align: left;">Số điện thoại</th>
                                        <th style="padding: 15px; width: 160px;">Chức vụ</th>
                                        <th style="padding: 15px; width: 140px;">Trạng thái</th>
                                        <th style="padding: 15px; width: 180px;">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody class="text-dark">
                                    <c:catch var="ex">
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
                                                    <span class="badge ${u.accountStatus == 'Active' ? 'bg-success' : 'bg-secondary'} px-2 py-2 text-uppercase">
                                                        ${u.accountStatus}
                                                    </span>
                                                </td>
                                                <td class="text-center" style="padding: 15px;">
                                                    <div class="d-inline-flex gap-2">
                                                        <a href="${pageContext.request.contextPath}/userDetail?action=edit&id=${u.userId}" class="btn btn-sm btn-outline-warning font-weight-bold px-3 py-2 text-dark" style="border-width: 2px;">Sửa</a>
                                                        <a href="${pageContext.request.contextPath}/userDetail?action=delete&id=${u.userId}" class="btn btn-sm btn-outline-danger font-weight-bold px-3 py-2" style="border-width: 2px;" onclick="return confirm('Bạn có chắc muốn xóa tài khoản này không?')">Xóa</a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:catch>

                                    <%-- Cơ chế dự phòng nếu môi trường dính cache JSTL cũ --%>
                                    <c:if test="${ex != null}">
                                        <c_old:forEach var="u" items="${USERS}" varStatus="loop">
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
                                                    <span class="badge ${u.accountStatus == 'Active' ? 'bg-success' : 'bg-secondary'} px-2 py-2 text-uppercase">
                                                        ${u.accountStatus}
                                                    </span>
                                                </td>
                                                <td class="text-center" style="padding: 15px;">
                                                    <div class="d-inline-flex gap-2">
                                                        <a href="${pageContext.request.contextPath}/userDetail?action=edit&id=${u.userId}" class="btn btn-sm btn-outline-warning font-weight-bold px-3 py-2 text-dark" style="border-width: 2px;">Sửa</a>
                                                        <a href="${pageContext.request.contextPath}/userDetail?action=delete&id=${u.userId}" class="btn btn-sm btn-outline-danger font-weight-bold px-3 py-2" style="border-width: 2px;" onclick="return confirm('Bạn có chắc muốn xóa tài khoản này không?')">Xóa</a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c_old:forEach>
                                    </c:if>

                                    <c:if test="${empty USERS}">
                                        <tr>
                                            <td colspan="7" class="text-center py-5 text-muted font-italic">
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

        <script src="https://code.jquery.com/jquery-3.4.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>