<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin - Quản lý đánh giá" />
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

            .main-panel {
                margin-left: 260px;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            .sidebar {
                width: 260px;
                background-color: var(--cz-dark-bg);
                min-height: 100vh;
                position: fixed; /* Bắt buộc phải có để Sidebar ghim chặt bên mép trái */
                top: 0;
                left: 0;
                display: flex;
                flex-direction: column;
                padding: 20px 0;
                z-index: 100; /* Đảm bảo nổi lên trên mọi phần tử khác */
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

            .header-left {
                display: flex;
                align-items: center;
                gap: 15px;
            }

            .sidebar-toggle {
                background: none;
                border: none;
                font-size: 18px;
                color: #555;
                cursor: pointer;
            }



            .header-right {
                display: flex;
                align-items: center;
                gap: 20px;
            }

            .header-icon-btn {
                background: none;
                border: none;
                font-size: 18px;
                color: #555;
                position: relative;
                cursor: pointer;
                transition: color 0.2s;
            }

            .header-icon-btn:hover {
                color: var(--cz-primary);
            }

            .header-icon-btn .badge-dot {
                position: absolute;
                top: -2px;
                right: -2px;
                width: 8px;
                height: 8px;
                background-color: var(--cz-primary);
                border-radius: 50%;
                border: 1px solid #fff;
            }

            .profile-section {
                display: flex;
                align-items: center;
                gap: 10px;
                border-left: 1px solid var(--cz-border-color);
                padding-left: 20px;
            }

            .profile-img {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid var(--cz-border-color);
            }

            .profile-info {
                line-height: 1.2;
            }

            .profile-name {
                font-size: 13.5px;
                font-weight: 600;
                color: #333;
            }

            .profile-role {
                font-size: 10.5px;
                color: var(--cz-text-muted);
                font-weight: 500;
            }

            .content-container {
                padding: 35px;
                flex: 1;
            }

            .page-title-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 25px;
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
            }

            .filter-card {
                background-color: var(--cz-card-bg);
                border-radius: 12px;
                padding: 20px;
                border: 1px solid var(--cz-border-color);
                margin-bottom: 25px;
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02);
            }

            .filter-form {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .filter-select {
                min-width: 170px;
                padding: 10px 15px;
                font-size: 13.5px;
                font-weight: 500;
                border-radius: 8px;
                border: 1px solid var(--cz-border-color);
                background-color: #fff;
                color: #444;
                cursor: pointer;
                outline: none;
            }

            .search-wrapper {
                position: relative;
                flex: 1;
                min-width: 250px;
            }

            .search-input {
                width: 100%;
                padding: 10px 15px 10px 40px;
                font-size: 13.5px;
                border-radius: 8px;
                border: 1px solid var(--cz-border-color);
                outline: none;
            }

            .search-wrapper i {
                position: absolute;
                left: 15px;
                top: 50%;
                transform: translateY(-50%);
                color: #aaa;
                font-size: 14px;
            }

            .btn-filter-action {
                padding: 10px 20px;
                font-size: 13.5px;
                font-weight: 600;
                border-radius: 8px;
                border: 1px solid var(--cz-border-color);
                background-color: #fff;
                color: #444;
                transition: all 0.2s;
            }

            .btn-clear-filter {
                padding: 10px 15px;
                font-size: 13.5px;
                font-weight: 500;
                border-radius: 8px;
                background-color: #555;
                color: #fff;
                text-decoration: none;
            }

            .table-card {
                background-color: var(--cz-card-bg);
                border-radius: 12px;
                border: 1px solid var(--cz-border-color);
                overflow: hidden;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
                margin-bottom: 25px;
            }

            .cz-table {
                width: 100%;
                margin-bottom: 0;
                border-collapse: collapse;
            }

            .cz-table th {
                background-color: #fffaf5;
                color: #666;
                font-size: 11.5px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                padding: 16px 20px;
                border-bottom: 2px solid var(--cz-border-color);
            }

            .cz-table td {
                padding: 16px 20px;
                vertical-align: middle;
                font-size: 14px;
                border-bottom: 1px solid var(--cz-border-color);
            }

            .star-gold {
                color: #ffc107;
                margin-right: 2px;
            }

            .badge-pending {
                background-color: #fff3cd !important;
                color: #856404 !important;
                font-weight: 600;
                padding: 5px 12px;
                border-radius: 30px;
            }
            .badge-approved {
                background-color: #e6f6eb !important;
                color: #28a745 !important;
                font-weight: 600;
                padding: 5px 12px;
                border-radius: 30px;
            }
            .badge-featured {
                background-color: #e8f0fe !important;
                color: #1a73e8 !important;
                font-weight: 700;
                padding: 5px 12px;
                border-radius: 30px;
                border: 1px dashed #1a73e8;
            }
            .badge-secondary {
                background-color: #fcebeb !important;
                color: #dc3545 !important;
                font-weight: 600;
                padding: 5px 12px;
                border-radius: 30px;
            }

            .btn-action-view {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid var(--cz-border-color);
                background-color: #fff;
                color: var(--cz-primary);
                cursor: pointer;
                transition: all 0.2s;
                text-decoration: none;
            }

            .btn-action-view:hover {
                background-color: #f6faf5;
                border-color: var(--cz-primary);
            }

            .pagination-area {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 20px 25px;
                border-top: 1px solid var(--cz-border-color);
                background-color: #fff;
            }

            .pagination-nav {
                display: flex;
                gap: 5px;
                margin: 0;
                padding: 0;
                list-style: none;
            }

            .page-num-item a {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: 6px;
                border: 1px solid var(--cz-border-color);
                font-size: 13px;
                font-weight: 600;
                color: #555;
                text-decoration: none;
            }

            .page-num-item.active a {
                background-color: var(--cz-primary);
                border-color: var(--cz-primary);
                color: #fff;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="reviews" />
        </jsp:include>

        <div class="main-panel">
  

            <!-- Top Header -->
            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="Hệ thống" />
                <jsp:param name="activeMenu" value="Quản lý đánh giá" />
            </jsp:include>


            <div class="content-container">
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Quản lý kiểm duyệt đánh giá</h1>
                        <p class="page-subtitle">Hệ thống phê duyệt phản hồi, xếp hạng sao và quản lý lời chứng thực ngoài trang chủ</p>
                    </div>
                </div>

                <div class="filter-card">
                    <form class="filter-form" action="${pageContext.request.contextPath}/admin/reviews" method="GET">
                        <input type="hidden" name="action" value="list">

                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" class="search-input" name="keyword" value="${keyword}" placeholder="Tìm theo tên khách hàng, mẫu bánh, nội dung bình luận...">
                        </div>

                        <select class="filter-select" name="stars" onchange="this.form.submit()">
                            <option value="" ${empty stars ? 'selected' : ''}>Tất cả mức sao</option>
                            <option value="5" ${stars eq 5 ? 'selected' : ''}>5 Sao ⭐️⭐️⭐️⭐️⭐️</option>
                            <option value="4" ${stars eq 4 ? 'selected' : ''}>4 Sao ⭐️⭐️⭐️⭐️</option>
                            <option value="3" ${stars eq 3 ? 'selected' : ''}>3 Sao ⭐️⭐️⭐️</option>
                            <option value="2" ${stars eq 2 ? 'selected' : ''}>2 Sao ⭐️⭐️</option>
                            <option value="1" ${stars eq 1 ? 'selected' : ''}>1 Sao ⭐️</option>
                        </select>

                        <select class="filter-select" name="status" onchange="this.form.submit()">
                            <option value="" ${empty status ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="Pending" ${status eq 'Pending' ? 'selected' : ''}>Chờ kiểm duyệt</option>
                            <option value="Approved" ${status eq 'Approved' ? 'selected' : ''}>Đã phê duyệt</option>
                            <option value="Featured" ${status eq 'Featured' ? 'selected' : ''}>Nổi bật (Trang chủ)</option>
                            <option value="Rejected" ${status eq 'Rejected' ? 'selected' : ''}>Đã ẩn / Từ chối</option>
                        </select>

                        <button type="submit" class="btn-filter-action"><i class="fa-solid fa-sliders"></i> Lọc</button>
                        <a href="${pageContext.request.contextPath}/admin/reviews?action=list" class="btn-clear-filter text-center">Làm mới</a>
                    </form>
                </div>

                <div class="table-card">
                    <table class="cz-table">
                        <thead>
                            <tr>
                                <th style="width: 60px; text-align: center;">STT</th>
                                <th>Khách hàng</th>
                                <th>Mẫu bánh đánh giá</th>
                                <th style="width: 150px;">Xếp hạng</th>
                                <th>Nội dung bình luận</th>
                                <th style="width: 160px; text-align: center;">Trạng thái</th>
                                <th style="width: 100px; text-align: center;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty reviewList}">
                                    <c:forEach items="${reviewList}" var="r" varStatus="status">
                                        <tr>
                                            <td style="text-align: center;">${(currentPage - 1) * 10 + status.count}</td>
                                            <td class="fw-bold text-dark">${r.customerName}</td>
                                            <td><span class="text-secondary font-monospace">[${r.customCakeId}]</span> ${r.templateName}</td>
                                            <td style="white-space: nowrap; padding-left: 0px;">
                                                <c:forEach begin="1" end="${r.ratingStars}">
                                                    <i class="fa-solid fa-star star-gold"></i>
                                                </c:forEach>
                                                <c:forEach begin="${r.ratingStars + 1}" end="5">
                                                    <i class="fa-regular fa-star text-muted" style="font-size: 13px;"></i>
                                                </c:forEach>
                                            </td>
                                            <td class="text-muted text-truncate" style="max-width: 280px;" title="${r.comment}">
                                                ${empty r.comment ? '<i>Không có nội dung bình luận.</i>' : r.comment}
                                            </td>
                                            <td style="text-align: center;">
                                                <span class="badge ${r.moderationStatus eq 'Pending' ? 'badge-pending' : 
                                                                     (r.moderationStatus eq 'Approved' ? 'badge-approved' : 
                                                                     (r.moderationStatus eq 'Featured' ? 'badge-featured' : 'badge-secondary'))}">
                                                      <c:choose>
                                                          <c:when test="${r.moderationStatus eq 'Pending'}">Chờ duyệt</c:when>
                                                          <c:when test="${r.moderationStatus eq 'Approved'}">Đã hiển thị</c:when>
                                                          <c:when test="${r.moderationStatus eq 'Featured'}">⭐️ Nổi bật</c:when>
                                                          <c:when test="${r.moderationStatus eq 'Rejected'}">Đã ẩn</c:when>
                                                          <c:otherwise>${r.moderationStatus}</c:otherwise>
                                                      </c:choose>
                                                </span>
                                            </td>
                                            <td style="text-align: center;">
                                                <a href="${pageContext.request.contextPath}/admin/reviews?action=detail&id=${r.reviewId}" class="btn-action-view" title="Xem chi tiết & Phê duyệt">
                                                    <i class="fa-regular fa-eye"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" class="text-center p-5 text-muted">Không tìm thấy dữ liệu đánh giá nào phù hợp với bộ lọc!</td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>

                    <div class="pagination-area">
                        <span class="pagination-text">Trang số <b>${currentPage}</b> trên tổng số <b>${totalPages}</b> trang</span>
                        <ul class="pagination-nav">
                            <c:if test="${currentPage > 1}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/reviews?action=list&page=${currentPage - 1}&keyword=${keyword}&stars=${stars}&status=${status}">
                                        <i class="fa-solid fa-chevron-left" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>

                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <li class="page-num-item ${currentPage == i ? 'active' : ''}">
                                    <a href="${pageContext.request.contextPath}/admin/reviews?action=list&page=${i}&keyword=${keyword}&stars=${stars}&status=${status}">${i}</a>
                                </li>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <li class="page-num-item">
                                    <a href="${pageContext.request.contextPath}/admin/reviews?action=list&page=${currentPage + 1}&keyword=${keyword}&stars=${stars}&status=${status}">
                                        <i class="fa-solid fa-chevron-right" style="font-size: 11px;"></i>
                                    </a>
                                </li>
                            </c:if>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

        <script>
                            const urlParams = new URLSearchParams(window.location.search);
                            const msg = urlParams.get('msg');

                            if (msg === 'success') {
                                Toastify({
                                    text: "Cập nhật trạng thái kiểm duyệt thành công!",
                                    duration: 4000,
                                    close: true,
                                    gravity: "top",
                                    position: "right",
                                    backgroundColor: "linear-gradient(to right, #00b09b, #96c93d)"
                                }).showToast();
                            } else if (msg === 'fail' || msg === 'error') {
                                Toastify({
                                    text: "Thao tác thất bại hoặc có lỗi xảy ra!",
                                    duration: 4000,
                                    close: true,
                                    gravity: "top",
                                    position: "right",
                                    backgroundColor: "linear-gradient(to right, #ff5f6d, #ffc371)"
                                }).showToast();
                            }
        </script>
    </body>
</html>
