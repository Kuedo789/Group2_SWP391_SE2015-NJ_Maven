<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="../common/header.jsp" />
    <title>Blog & Tin Tức - BakeryZone</title>
    <style>
        .blog-section {
            padding: 40px 20px;
            max-width: 1200px;
            margin: 0 auto;
            font-family: "Be Vietnam Pro", sans-serif;
        }
        .blog-header {
            text-align: center;
            margin-bottom: 40px;
        }
        .blog-title {
            font-family: "Playfair Display", serif;
            font-size: 42px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 10px;
        }
        .blog-subtitle {
            font-size: 16px;
            color: var(--muted);
        }
        .blog-filters {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 40px;
        }
        .filter-pill {
            padding: 8px 18px;
            border-radius: 30px;
            border: 1px solid var(--border);
            background-color: var(--card);
            color: var(--text);
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.25s ease;
            text-decoration: none;
            display: inline-block;
        }
        .filter-pill:hover {
            border-color: var(--primary);
            color: var(--primary);
            background-color: var(--primary-soft);
        }
        .filter-pill.active {
            background-color: var(--primary);
            border-color: var(--primary);
            color: #ffffff;
        }
        .blog-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(360px, 1fr));
            gap: 30px;
        }
        .blog-card {
            background-color: var(--card);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: var(--shadow-soft);
            border: 1px solid var(--border);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        .blog-card:hover {
            transform: translateY(-6px);
            box-shadow: var(--shadow);
        }
        .blog-image-wrapper {
            position: relative;
            aspect-ratio: 16/10;
            overflow: hidden;
            background-color: var(--primary-soft);
        }
        .blog-image-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            background-color: var(--primary);
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }
        .blog-image-placeholder h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 8px;
            text-transform: uppercase;
        }
        .blog-image-placeholder p {
            font-size: 12px;
            opacity: 0.8;
            margin: 0;
        }
        .blog-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }
        .blog-card:hover .blog-image {
            transform: scale(1.05);
        }
        .blog-content {
            padding: 24px;
            display: flex;
            flex-direction: column;
            flex: 1;
        }
        .blog-badge {
            align-self: flex-start;
            background-color: var(--primary-soft);
            color: var(--primary);
            font-size: 12px;
            font-weight: 600;
            padding: 4px 12px;
            border-radius: 6px;
            margin-bottom: 12px;
        }
        .blog-card-title {
            font-size: 18px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 10px;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            text-decoration: none;
            transition: color 0.2s;
        }
        .blog-card-title:hover {
            color: var(--primary);
        }
        .blog-card-summary {
            font-size: 14px;
            color: var(--muted);
            line-height: 1.6;
            margin-bottom: 20px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .blog-card-footer {
            margin-top: auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 13px;
            color: var(--muted);
            border-top: 1px solid var(--border);
            padding-top: 15px;
        }
        .no-blogs {
            grid-column: 1 / -1;
            text-align: center;
            padding: 80px 20px;
            color: var(--muted);
        }
        .no-blogs i {
            font-size: 48px;
            margin-bottom: 16px;
            color: #ddd;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <jsp:include page="../common/navbar.jsp" />

    <main class="main">
        <section class="blog-section">
            <div class="blog-header">
                <h1 class="blog-title">Blog & Tin Tức</h1>
                <p class="blog-subtitle">Công thức, mẹo hay và tin tức mới nhất</p>
            </div>

            <!-- Categories Filter -->
            <div class="blog-filters">
                <c:set var="activeCat" value="${not empty param.category ? param.category : 'all'}" />
                <a href="?category=all" class="filter-pill ${activeCat eq 'all' ? 'active' : ''}">Tất cả</a>
                <a href="?category=Tin tức" class="filter-pill ${activeCat eq 'Tin tức' ? 'active' : ''}">Tin tức</a>
                <a href="?category=Công thức" class="filter-pill ${activeCat eq 'Công thức' ? 'active' : ''}">Công thức</a>
                <a href="?category=Khuyến mãi" class="filter-pill ${activeCat eq 'Khuyến mãi' ? 'active' : ''}">Khuyến mãi</a>
                <a href="?category=Bánh sinh nhật" class="filter-pill ${activeCat eq 'Bánh sinh nhật' ? 'active' : ''}">Bánh sinh nhật</a>
                <a href="?category=Bánh Trung Thu" class="filter-pill ${activeCat eq 'Bánh Trung Thu' ? 'active' : ''}">Bánh Trung Thu</a>
                <a href="?category=Lời chúc" class="filter-pill ${activeCat eq 'Lời chúc' ? 'active' : ''}">Lời chúc</a>
                <a href="?category=Quà tặng" class="filter-pill ${activeCat eq 'Quà tặng' ? 'active' : ''}">Quà tặng</a>
                <a href="?category=Mùa lễ hội" class="filter-pill ${activeCat eq 'Mùa lễ hội' ? 'active' : ''}">Mùa lễ hội</a>
            </div>

            <!-- Blog Grid -->
            <div class="blog-grid">
                <c:choose>
                    <c:when test="${not empty blogList}">
                        <c:forEach var="blog" items="${blogList}">
                            <div class="blog-card">
                                <div class="blog-image-wrapper">
                                    <a href="blog?action=detail&id=${blog.postId}">
                                        <c:choose>
                                            <c:when test="${not empty blog.imageUrl}">
                                                <c:set var="resolvedBlogImg" value="${blog.imageUrl.startsWith('http') ? blog.imageUrl : pageContext.request.contextPath.concat('/').concat(blog.imageUrl.startsWith('/') ? blog.imageUrl.substring(1) : blog.imageUrl)}" />
                                                <img src="${resolvedBlogImg}" alt="${blog.title}" class="blog-image">
                                            </c:when>
                                            <c:otherwise>
                                                <!-- Dynamic styling banner matching image placeholder in user request -->
                                                <div class="blog-image-placeholder">
                                                    <h3>CÁI LÒ NƯỚNG</h3>
                                                    <p>${blog.title}</p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </a>
                                </div>
                                <div class="blog-content">
                                    <span class="blog-badge">${blog.category}</span>
                                    <a href="blog?action=detail&id=${blog.postId}" class="blog-card-title">${blog.title}</a>
                                    <p class="blog-card-summary">${blog.summary}</p>
                                    <div class="blog-card-footer">
                                        <span><i class="fa-regular fa-clock me-1"></i> <fmt:formatDate value="${blog.createdAt}" pattern="dd/MM/yyyy"/></span>
                                        <span>Đọc thêm <i class="fa-solid fa-arrow-right ms-1" style="font-size: 11px;"></i></span>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <!-- Fallback / Static data simulation for easy database testing -->
                        <c:if test="${activeCat eq 'all' or activeCat eq 'Tin tức'}">
                            <div class="blog-card">
                                <div class="blog-image-wrapper">
                                    <a href="#">
                                        <div class="blog-image-placeholder">
                                            <h3 style="font-size: 22px;">CÁI LÒ NƯỚNG THÔNG BÁO</h3>
                                            <h2 style="font-size: 32px; font-weight: bold; margin: 15px 0;">ĐIỀU CHỈNH<br>PHÍ GIAO HÀNG</h2>
                                            <p>Áp dụng từ ngày 12/03/2026</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="blog-content">
                                    <span class="blog-badge">Tin tức</span>
                                    <a href="#" class="blog-card-title">THÔNG BÁO: ĐIỀU CHỈNH PHÍ GIAO HÀNG MỘT SỐ KHU VỰC</a>
                                    <p class="blog-card-summary">Kính gửi Quý khách hàng thân thiết, BakeryZone xin thông báo điều chỉnh phí dịch vụ giao hàng tận nơi...</p>
                                    <div class="blog-card-footer">
                                        <span><i class="fa-regular fa-clock me-1"></i> 12/03/2026</span>
                                        <span>Đọc thêm <i class="fa-solid fa-arrow-right ms-1" style="font-size: 11px;"></i></span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="blog-card">
                                <div class="blog-image-wrapper">
                                    <a href="#">
                                        <div class="blog-image-placeholder" style="background-color: #6d8560;">
                                            <h3 style="font-size: 22px;">CÁI LÒ NƯỚNG THÔNG BÁO</h3>
                                            <h2 style="font-size: 32px; font-weight: bold; margin: 15px 0;">ĐIỀU CHỈNH<br>GIÁ SẢN PHẨM</h2>
                                            <p>Áp dụng từ ngày 16/03/2026</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="blog-content">
                                    <span class="blog-badge">Tin tức</span>
                                    <a href="#" class="blog-card-title">THÔNG BÁO: ĐIỀU CHỈNH GIÁ BÁN SẢN PHẨM TẠI CÁI LÒ NƯỚNG</a>
                                    <p class="blog-card-summary">Kính gửi Quý khách hàng thân thiết, để đảm bảo chất lượng nguyên liệu cao cấp nhập khẩu và duy trì hương vị truyền thống...</p>
                                    <div class="blog-card-footer">
                                        <span><i class="fa-regular fa-clock me-1"></i> 09/03/2026</span>
                                        <span>Đọc thêm <i class="fa-solid fa-arrow-right ms-1" style="font-size: 11px;"></i></span>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <jsp:include page="../common/footer.jsp" />
</body>
</html>
