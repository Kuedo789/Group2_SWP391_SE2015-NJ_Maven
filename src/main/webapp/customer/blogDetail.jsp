<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>${not empty blog ? blog.title : 'Chi tiết bài viết'} - BakeryZone</title>
    <style>
        .blog-detail-section {
            padding: 50px 20px;
            max-width: 800px;
            margin: 0 auto;
            font-family: "Be Vietnam Pro", sans-serif;
        }
        .blog-detail-meta {
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 14px;
            color: var(--muted);
            margin-bottom: 20px;
        }
        .blog-detail-badge {
            background-color: var(--primary-soft);
            color: var(--primary);
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 6px;
        }
        .blog-detail-title {
            font-family: "Playfair Display", serif;
            font-size: 36px;
            font-weight: 700;
            color: var(--text);
            line-height: 1.3;
            margin-bottom: 25px;
        }
        .blog-detail-image-wrapper {
            margin-bottom: 35px;
            border-radius: 16px;
            overflow: hidden;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-soft);
        }
        .blog-detail-placeholder {
            width: 100%;
            aspect-ratio: 16/9;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background-color: var(--primary);
            color: #ffffff;
            padding: 40px;
            text-align: center;
        }
        .blog-detail-content {
            font-size: 16px;
            color: var(--text);
            line-height: 1.8;
        }
        /* Rich Text / TinyMCE formatting overrides to match premium look */
        .blog-detail-content h2, 
        .blog-detail-content h3 {
            font-family: "Playfair Display", serif;
            color: var(--text);
            margin-top: 30px;
            margin-bottom: 15px;
            font-weight: 700;
        }
        .blog-detail-content p {
            margin-bottom: 20px;
        }
        .blog-detail-content img {
            max-width: 100%;
            height: auto;
            border-radius: 12px;
            margin: 20px 0;
            display: block;
        }
        .blog-back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 30px;
            color: var(--primary);
            font-weight: 600;
            font-size: 14px;
            transition: color 0.2s;
        }
        .blog-back-btn:hover {
            color: var(--primary-dark);
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <jsp:include page="../common/navbar.jsp" />

    <main class="main">
        <article class="blog-detail-section">
            <a href="blog" class="blog-back-btn">
                <i class="fa-solid fa-arrow-left"></i> Quay lại Blog
            </a>

            <c:choose>
                <c:when test="${not empty blog}">
                    <div class="blog-detail-meta">
                        <span class="blog-detail-badge">${blog.category}</span>
                        <span><i class="fa-regular fa-calendar me-1"></i> <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy"/></span>
                    </div>
                    <h1 class="blog-detail-title">${blog.title}</h1>

                    <c:if test="${not empty blog.imageUrl}">
                        <div class="blog-detail-image-wrapper">
                            <img src="${blog.imageUrl}" alt="${blog.title}" style="width:100%; height:auto; display:block;">
                        </div>
                    </c:if>

                    <!-- Render output from database containing TinyMCE HTML code dynamically -->
                    <div class="blog-detail-content">
                        ${blog.content}
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Simulated fallback detail view for static demonstration -->
                    <div class="blog-detail-meta">
                        <span class="blog-detail-badge">Tin tức</span>
                        <span><i class="fa-regular fa-calendar me-1"></i> 12/03/2026</span>
                    </div>
                    <h1 class="blog-detail-title">THÔNG BÁO: ĐIỀU CHỈNH PHÍ GIAO HÀNG MỘT SỐ KHU VỰC</h1>
                    
                    <div class="blog-detail-image-wrapper">
                        <div class="blog-detail-placeholder">
                            <h3 style="font-size: 24px;">CÁI LÒ NƯỚNG THÔNG BÁO</h3>
                            <h2 style="font-size: 36px; font-weight: bold; margin: 20px 0;">ĐIỀU CHỈNH PHÍ GIAO HÀNG</h2>
                            <p>Áp dụng từ ngày 12/03/2026</p>
                        </div>
                    </div>

                    <div class="blog-detail-content">
                        <p>Kính gửi Quý khách hàng thân thiết của BakeryZone,</p>
                        <p>Nhằm nâng cao chất lượng dịch vụ vận chuyển và đảm bảo các đơn hàng bánh kem tươi luôn được giao đến tay quý khách trong trạng thái hoàn hảo nhất, chúng tôi xin thông báo điều chỉnh phí dịch vụ giao hàng kể từ ngày <strong>12/03/2026</strong>.</p>
                        <h2>Mức phí điều chỉnh cụ thể:</h2>
                        <ul>
                            <li>Khu vực nội thành (dưới 5km): Phí cố định 15,000đ.</li>
                            <li>Khu vực lân cận (5km - 10km): Phí cố định 25,000đ.</li>
                            <li>Các khu vực khác: Tính theo giá ứng dụng vận chuyển của đối tác.</li>
                        </ul>
                        <p>BakeryZone chân thành cảm ơn sự đồng hành và thấu hiểu của quý khách.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </article>
    </main>

    <!-- Footer -->
    <jsp:include page="../common/footer.jsp" />
</body>
</html>
