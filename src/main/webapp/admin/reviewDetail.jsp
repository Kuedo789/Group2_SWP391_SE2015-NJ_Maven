<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%-- Khai báo cả 2 phiên bản URI để đảm bảo NetBeans/Tomcat không bao giờ bị báo đỏ sọc --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="c_old" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>CakeZone - Chi tiết kiểm duyệt đánh giá</title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

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

            /* Sidebar Styling ghim chặt bên trái */
            .sidebar {
                width: 260px;
                background-color: var(--cz-dark-bg);
                min-height: 100vh;
                position: fixed;
                top: 0;
                left: 0;
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

            .breadcrumbs {
                font-size: 13px;
                color: var(--cz-text-muted);
            }
            .breadcrumbs a {
                color: var(--cz-text-muted);
                text-decoration: none;
            }
            .breadcrumbs span {
                margin: 0 6px;
            }

            .content-container {
                padding: 35px;
                flex: 1;
            }

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

            .info-block {
                background-color: var(--cz-light-bg);
                border-radius: 8px;
                padding: 12px 18px;
                min-height: 48px;
                font-size: 14px;
                font-weight: 600;
                color: #111;
                border: 1px solid var(--cz-border-color);
                display: flex;
                align-items: center;
            }

            .comment-area {
                background-color: #fffaf5;
                border-left: 4px solid var(--cz-primary);
                border-radius: 0 8px 8px 0;
                padding: 20px;
                font-size: 15px;
                line-height: 1.6;
                color: #444;
            }

            .star-gold {
                color: #ffc107;
                font-size: 18px;
                margin-right: 3px;
            }

            .btn-approve {
                background-color: #28a745;
                color: #fff;
                font-weight: 600;
                padding: 12px 25px;
                border-radius: 8px;
                border: none;
                transition: all 0.2s;
            }
            .btn-approve:hover {
                background-color: #218838;
                transform: translateY(-1px);
                box-shadow: 0 4px 10px rgba(40, 167, 69, 0.2);
            }

            .btn-feature {
                background-color: #1a73e8;
                color: #fff;
                font-weight: 600;
                padding: 12px 25px;
                border-radius: 8px;
                border: none;
                transition: all 0.2s;
            }
            .btn-feature:hover {
                background-color: #1557b0;
                transform: translateY(-1px);
                box-shadow: 0 4px 10px rgba(26, 115, 232, 0.2);
            }

            .btn-reject {
                background-color: #dc3545;
                color: #fff;
                font-weight: 600;
                padding: 12px 25px;
                border-radius: 8px;
                border: none;
                transition: all 0.2s;
            }
            .btn-reject:hover {
                background-color: #c82333;
                transform: translateY(-1px);
                box-shadow: 0 4px 10px rgba(220, 53, 69, 0.2);
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

            .badge-large {
                padding: 6px 16px;
                border-radius: 30px;
                font-size: 13px;
                font-weight: 700;
            }
        </style>
    </head>

    <body>
        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="reviews" />
        </jsp:include>
        
        <div class="main-panel">
            <div class="top-header">
                <div class="header-left">
                    <div class="breadcrumbs">
                        <a href="#">Dashboard</a>
                        <span>&gt;</span>
                        <a href="${pageContext.request.contextPath}/admin/reviews?action=list">Quản lý đánh giá</a>
                        <span>&gt;</span>
                        <a href="#" class="active text-dark font-weight-bold">Chi tiết đánh giá</a>
                    </div>
                </div>

                <div class="header-right">
                    <div class="profile-section d-flex align-items-center gap-3">
                        <span class="fw-bold" style="font-size: 14px;"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></span>
                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="rounded-circle" width="35" height="35">
                    </div>
                </div>
            </div>

            <div class="content-container">
                <div class="form-card">
                    <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
                        <div>
                            <h1 class="page-title text-uppercase">Chi tiết kiểm duyệt đánh giá</h1>
                            <p class="page-subtitle">Xem thông tin phản hồi của khách hàng và đưa ra quyết định kiểm duyệt nội dung ngoài hệ thống website CakeZone</p>
                        </div>
                        <div>
                            <span class="badge-large 
                                ${review.moderationStatus eq 'Pending' ? 'bg-warning text-dark' : 
                                  (review.moderationStatus eq 'Approved' ? 'bg-success text-white' : 
                                  (review.moderationStatus eq 'Featured' ? 'bg-primary text-white' : 'bg-danger text-white'))}">
                                Trạng thái hiện tại: 
                                <c:choose>
                                    <c:when test="${review.moderationStatus eq 'Pending'}">Chờ kiểm duyệt</c:when>
                                    <c:when test="${review.moderationStatus eq 'Approved'}">Đã hiển thị</c:when>
                                    <c:when test="${review.moderationStatus eq 'Featured'}">⭐ Nổi bật trang chủ</c:when>
                                    <c:when test="${review.moderationStatus eq 'Rejected'}">Đã ẩn</c:when>
                                    <c:otherwise>${review.moderationStatus}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="row g-4">
                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Họ tên khách hàng</label>
                            <div class="info-block">${review.customerName}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Mức sao xếp hạng</label>
                            <div class="info-block">
                                <c:forEach begin="1" end="${review.ratingStars}">
                                    <i class="fa-solid fa-star star-gold"></i>
                                </c:forEach>
                                <c:forEach begin="${review.ratingStars + 1}" end="5">
                                    <i class="fa-regular fa-star text-muted" style="font-size: 14px; margin-right: 3px;"></i>
                                </c:forEach>
                                <span class="ms-2">(${review.ratingStars} / 5 Sao)</span>
                            </div>
                        </div>

                        <div class="col-12">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Nội dung phản hồi từ khách hàng</label>
                            <div class="comment-area fw-medium">
                                <c:choose>
                                    <c:when test="${not empty review.comment}">
                                        "${review.comment}"
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted" style="font-style: italic;">Khách hàng chỉ chấm điểm sao, không để lại lời bình luận văn bản.</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="col-12 mt-5">
                            <h5 class="fw-bold text-dark border-bottom pb-2 mb-3"><i class="fa-solid fa-cake-candles text-success me-2"></i>Chi tiết mẫu bánh đã đặt mua</h5>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Tên mẫu bánh (Template Name)</label>
                            <div class="info-block">${review.templateName}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Kích thước bánh đặt (Size)</label>
                            <div class="info-block text-success"><i class="fa-solid fa-arrows-left-right me-2"></i> ${review.variationName}</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Chữ ghi lên mặt bánh (Greeting Text)</label>
                            <div class="info-block">
                                <c:choose>
                                    <c:when test="${not empty review.greetingText}">
                                        ${review.greetingText}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted fw-normal">Không yêu cầu ghi chữ</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label text-muted text-uppercase" style="font-size: 11px; letter-spacing: 0.5px;">Mã thiết kế (Custom Cake ID)</label>
                            <div class="info-block font-monospace text-secondary">${review.customCakeId}</div>
                        </div>

                        <div class="col-12 d-flex flex-wrap justify-content-end gap-3 mt-5 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/admin/reviews?action=list" class="btn-cz-secondary">
                                <i class="fa-solid fa-arrow-left"></i> Trở về danh sách
                            </a>

                            <form action="${pageContext.request.contextPath}/admin/reviews" method="POST" class="d-inline">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="reviewId" value="${review.reviewId}">
                                <input type="hidden" name="status" value="Approved">
                                <button type="submit" class="btn-approve" ${review.moderationStatus eq 'Approved' ? 'disabled style="opacity: 0.5; cursor: not-allowed;"' : ''}>
                                    <i class="fa-solid fa-check me-1"></i> Phê duyệt hiển thị
                                </button>
                            </form>

                            <form action="${pageContext.request.contextPath}/admin/reviews" method="POST" class="d-inline">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="reviewId" value="${review.reviewId}">
                                <input type="hidden" name="status" value="Featured">
                                <button type="submit" class="btn-feature" ${review.moderationStatus eq 'Featured' ? 'disabled style="opacity: 0.5; cursor: not-allowed;"' : ''}>
                                    <i class="fa-solid fa-star me-1"></i> Đưa lên nổi bật (Trang chủ)
                                </button>
                            </form>

                            <form action="${pageContext.request.contextPath}/admin/reviews" method="POST" class="d-inline">
                                <input type="hidden" name="action" value="updateStatus">
                                <input type="hidden" name="reviewId" value="${review.reviewId}">
                                <input type="hidden" name="status" value="Rejected">
                                <button type="submit" class="btn-reject" ${review.moderationStatus eq 'Rejected' ? 'disabled style="opacity: 0.5; cursor: not-allowed;"' : ''}>
                                    <i class="fa-solid fa-eye-slash me-1"></i> Ẩn / Từ chối đánh giá
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
