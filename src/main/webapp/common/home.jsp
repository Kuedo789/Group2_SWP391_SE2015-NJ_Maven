
<%-- 
    Document   : home
    Created on : Jun 4, 2026, 1:15:29 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.bakeryzone.model.Product" %>
<%@ page import="com.bakeryzone.model.Review" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="header.jsp" />
        <style>
            /* 🎨 STYLE CHO KHỐI ĐÁNH GIÁ NỔI BẬT */
            .review-section {
                background-color: #fffaf5;
                padding: 60px 0;
            }
            .center-title-sub {
                text-align: center;
                color: #666;
                font-size: 14px;
                margin-top: -10px;
                margin-bottom: 40px;
            }
            .review-home-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 30px;
                max-width: 1200px;
                margin: 0 auto;
                padding: 0 20px;
            }
            .review-home-card {
                background: #ffffff;
                padding: 30px;
                border-radius: 12px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.03);
                border: 1px solid #f3ebe1;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }
            .review-home-stars {
                color: #ffc107;
                margin-bottom: 15px;
                display: flex;
                gap: 2px;
            }
            .review-home-comment {
                font-style: italic;
                color: #555;
                font-size: 15px;
                line-height: 1.6;
                margin-bottom: 20px;
                flex-grow: 1;
            }
            .review-home-user {
                border-top: 1px solid #f5f5f5;
                padding-top: 15px;
            }
            .review-home-name {
                font-weight: 700;
                color: #222;
                margin: 0 0 4px 0;
                font-size: 16px;
            }
            .review-home-cake {
                color: #888;
                font-size: 12.5px;
                display: block;
            }
            .review-empty {
                grid-column: span 3;
                text-align: center;
                color: #999;
                font-style: italic;
                padding: 20px;
            }
        </style>
    </head>

    <body>
        <jsp:include page="navbar.jsp" />

        <main class="main">

            <!-- Hero Carousel -->
            <section class="section hero-section">
                <div class="hero-card" id="heroCarousel">

                    <div class="hero-slide active"
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/hero/hero-1.jpg');">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/hero/hero-2.jpg');">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/hero/hero-3.jpg');">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/assets/images/hero/hero-4.jpg');">
                    </div>

                    <div class="hero-overlay"></div>

                    <div class="hero-content">
                        <div class="hero-tags">
                            <span>
                                <span class="material-symbols-outlined">bakery_dining</span>
                                Làm mới mỗi ngày
                            </span>

                            <span>
                                <span class="material-symbols-outlined">favorite</span>
                                Làm thủ công
                            </span>
                        </div>

                        <h1>Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc</h1>

                        <p>
                            Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng
                            được làm thủ công từ nguyên liệu tự nhiên.
                        </p>

                        <div class="hero-actions">
                            <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">Đặt bánh ngay</a>
                            <a href="#" class="btn btn-outline">Tự thiết kế bánh của bạn</a>
                        </div>
                    </div>

                    <div class="hero-dots"></div>
                </div>
            </section>

            <!-- Danh mục -->
            <section class="section category-section">
                <div class="section-heading">
                    <div>
                        <h2>Danh mục</h2>
                    </div>
                    <a href="${pageContext.request.contextPath}/products" class="view-more">
                        Xem thêm <i class="fa-solid fa-chevron-right"></i>
                    </a>
                </div>

                <div class="category-grid">

                    <%
                        List<Map<String, String>> homepageCategories =
                                (List<Map<String, String>>) request.getAttribute("homepageCategories");

                        if (homepageCategories != null && !homepageCategories.isEmpty()) {
                            for (Map<String, String> category : homepageCategories) {
                                String categoryId = category.get("id");
                                String categoryName = category.get("name");

                               String encodedCategory = java.net.URLEncoder.encode(categoryName, "UTF-8");

                               String iconPath = category.get("iconUrl");
                               if (iconPath == null || iconPath.trim().isEmpty()) {
                                   iconPath = request.getContextPath() + "/assets/images/categories/icons/default.png";
                               } else if (!iconPath.startsWith("http://") && !iconPath.startsWith("https://")) {
                                   if (!iconPath.startsWith("/")) {
                                       if (iconPath.contains("assets/")) {
                                           iconPath = request.getContextPath() + "/" + iconPath;
                                       } else {
                                           iconPath = request.getContextPath() + "/assets/images/categories/icons/" + iconPath;
                                       }
                                   } else {
                                       iconPath = request.getContextPath() + iconPath;
                                   }
                               }
                    %>

                    <a href="${pageContext.request.contextPath}/products?category=<%= encodedCategory %>" class="category-item">
                        <div class="category-icon">
                            <img src="<%= iconPath %>" alt="<%= categoryName %>">
                        </div>
                        <span><%= categoryName %></span>
                    </a>

                    <%
                            }
                        } else {
                    %>

                    <div class="category-empty">
                        <p>Hiện chưa có danh mục nào.</p>
                    </div>

                    <%
                        }
                    %>

                </div>
            </section>
            <!-- Bánh bán chạy -->
            <section class="section">
                <div class="section-heading section-heading-bottom">
                    <div>
                        <h2>Bánh bán chạy</h2>
                        <p>Những hương vị được yêu thích nhất tại tiệm.</p>
                    </div>

                    <a href="${pageContext.request.contextPath}/products" class="view-more">
                        Xem tất cả
                        <span class="material-symbols-outlined">arrow_forward</span>
                    </a>
                </div>

                <div class="product-grid">
                    <%
                        List<Product> bestSellerProducts =
                                (List<Product>) request.getAttribute("bestSellerProducts");

                        if (bestSellerProducts != null && !bestSellerProducts.isEmpty()) {
                            for (int i = 0; i < bestSellerProducts.size(); i++) {
                                Product product = bestSellerProducts.get(i);

                                String productId = product.getId();
                                String productName = product.getName();
                                String description = product.getFullDescription();
                                String imageUrl = product.getImageUrl();

                                if (description == null || description.trim().isEmpty()) {
                                    description = "Sản phẩm được yêu thích tại Bakery Zone.";
                                }

                                if (description.length() > 95) {
                                    description = description.substring(0, 95) + "...";
                                }

                                if (imageUrl == null || imageUrl.trim().isEmpty()) {
                                    imageUrl = "assets/images/products/basic.png";
                                }

                                String finalImageUrl;
                                if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
                                    finalImageUrl = imageUrl;
                                } else {
                                    finalImageUrl = request.getContextPath() + "/" + imageUrl;
                                }

                                String badgeClass = "";
                                String badgeText = "";

                                if (i == 0) {
                                    badgeClass = "badge-red";
                                    badgeText = "Bán chạy";
                                } else if (i == 1) {
                                    badgeClass = "badge-brown";
                                    badgeText = "Mới";
                                } else if (i == 2) {
                                    badgeClass = "badge-yellow";
                                    badgeText = "Nổi bật";
                                }
                        %>

                        <div class="product-card">
                            <div class="product-image">
                                <a href="<%= request.getContextPath() %>/product-detail?id=<%= productId %>">
                                    <img src="<%= finalImageUrl %>" alt="<%= productName %>">
                                </a>

                                <% if (!badgeText.isEmpty()) { %>
                                <span class="badge <%= badgeClass %>"><%= badgeText %></span>
                                <% } %>
                            </div>

                            <h3><%= productName %></h3>
                            <p><%= description %></p>

                            <div class="product-bottom">
                                <strong><%= String.format("%,.0f", product.getBasePrice()).replace(",", ".") %>đ</strong>

                                <button type="button"
                                        onclick="window.location.href = '<%= request.getContextPath() %>/product-detail?id=<%= productId %>'">
                                    <span class="material-symbols-outlined">add_shopping_cart</span>
                                </button>
                            </div>
                        </div>

                        <%
                            }
                        } else {
                        %>
                        <div class="category-empty" style="grid-column: span 4; text-align: center; padding: 40px;">
                            <p>Hiện chưa có bánh bán chạy nào.</p>
                        </div>
                        <%
                            }
                        %>
                </div>
            </section>

            <!-- Tự thiết kế -->
            <section class="section designer-section">

                <div class="designer-card">

                    <div class="designer-content">

                        <span class="auth-label">Cake Designer</span>

                        <h2>Tự thiết kế chiếc bánh của bạn</h2>

                        <p>
                            Thể hiện tình cảm qua từng lớp bánh. Chọn hương vị,
                            màu sắc và lời nhắn để tạo nên món quà độc nhất vô nhị.
                        </p>

                        <div class="steps">
                            <div class="step">
                                <span>1</span>
                                Chọn cốt bánh
                            </div>

                            <div class="step">
                                <span>2</span>
                                Chọn lớp kem
                            </div>

                            <div class="step">
                                <span>3</span>
                                Thêm topping
                            </div>

                            <div class="step">
                                <span>4</span>
                                Viết lời nhắn
                            </div>
                        </div>

                        <a href="#" class="btn btn-primary">
                            Bắt đầu thiết kế
                        </a>

                    </div>
                    <div class="designer-preview" id="designerPreview">

                        <img
                            src="${pageContext.request.contextPath}/assets/images/products/banh_dau.jpg"
                            alt="Custom strawberry cake"
                            class="designer-cake-img"
                            id="designerCakeImg">

                        <div class="floating-label label-1">
                            <span class="material-symbols-outlined">cake</span>
                            Bánh theo yêu cầu
                        </div>

                        <div class="floating-label label-2">
                            <span class="material-symbols-outlined">favorite</span>
                            Topping tuỳ chọn
                        </div>

                        <div class="floating-label label-3">
                            <span class="material-symbols-outlined">edit_note</span>
                            Lời nhắn riêng
                        </div>

                        <div class="price-note">
                            Từ <strong>35.000đ</strong>
                        </div>

                    </div>

                </div>

            </section>

            <!-- Bộ sưu tập nổi bật -->
            <section class="section">
                <div class="section-heading">
                    <h2>Bộ sưu tập nổi bật</h2>

                    <a href="#" class="view-more">
                        Xem thêm
                        <span class="material-symbols-outlined">chevron_right</span>
                    </a>
                </div>

                <div class="collection-grid">
                    <a href="#" class="collection-card">
                        <img src="${pageContext.request.contextPath}/assets/images/products/combo.png"
                             alt="Sweetbox quà tặng">
                        <div class="collection-content">
                            <span>Sweetbox 2026</span>
                            <h3>Quà tặng ngọt ngào</h3>
                            <p>Những chiếc bánh nhỏ xinh cho mọi dịp đặc biệt.</p>
                        </div>
                    </a>

                    <a href="#" class="collection-card">
                        <img src="${pageContext.request.contextPath}/assets/images/products/Combo2.png"
                             alt="Combo bánh thủ công">
                        <div class="collection-content">
                            <span>Combo yêu thích</span>
                            <h3>Hộp bánh thủ công</h3>
                            <p>Kết hợp nhiều hương vị trong một hộp quà thanh lịch.</p>
                        </div>
                    </a>
                </div>
            </section>

            <!-- Vì sao chọn chúng tôi -->
            <section class="section">
                <h2 class="center-title">Vì sao chọn chúng tôi?</h2>

                <div class="why-grid">
                    <div class="why-card">
                        <div class="why-icon">
                            <span class="material-symbols-outlined">schedule</span>
                        </div>
                        <h3>Bánh làm mới mỗi ngày</h3>
                        <p>Cam kết không dùng bánh cũ, chỉ nướng theo đơn đặt hàng để đảm bảo độ tươi ngon nhất.</p>
                    </div>

                    <div class="why-card">
                        <div class="why-icon">
                            <span class="material-symbols-outlined">design_services</span>
                        </div>
                        <h3>Tùy chỉnh theo ý bạn</h3>
                        <p>Dễ dàng lựa chọn cốt bánh, mức độ ngọt và phong cách trang trí mang đậm dấu ấn cá nhân.</p>
                    </div>

                    <div class="why-card">
                        <div class="why-icon">
                            <span class="material-symbols-outlined">eco</span>
                        </div>
                        <h3>Nguyên liệu chọn lọc</h3>
                        <p>Sử dụng trái cây tươi, bơ Pháp cao cấp và màu tự nhiên, an toàn cho sức khỏe.</p>
                    </div>

                    <div class="why-card">
                        <div class="why-icon">
                            <span class="material-symbols-outlined">local_shipping</span>
                        </div>
                        <h3>Giao hàng cẩn thận</h3>
                        <p>Đội ngũ giao hàng chuyên biệt, đảm bảo bánh nguyên vẹn, đẹp mắt đến tận tay người nhận.</p>
                    </div>
                </div>
            </section>
            
            <section class="section review-section">
                <h2 class="center-title">Khách hàng nói về CakeZone</h2>
                <p class="center-title-sub">Những lời phản hồi chân thực nhất từ những trải nghiệm ngọt ngào</p>

                <div class="review-home-grid">
                    <%
                        List<Review> featuredReviews = (List<Review>) request.getAttribute("FEATURED_REVIEWS");
                        if (featuredReviews != null && !featuredReviews.isEmpty()) {
                            for (Review rev : featuredReviews) {
                    %>
                    <div class="review-home-card">
                        <div>
                            <!-- Tạo số sao động dựa vào thuộc tính ratingStars -->
                            <div class="review-home-stars">
                                <% for (int s = 0; s < rev.getRatingStars(); s++) { %>
                                    <span class="material-symbols-outlined" style="font-size: 20px;">star</span>
                                <% } %>
                            </div>
                            <p class="review-home-comment">"<%= rev.getComment() %>"</p>
                        </div>
                        <div class="review-home-user">
                            <h4 class="review-home-name"><%= rev.getCustomerName() != null ? rev.getCustomerName() : "Khách hàng ẩn danh" %></h4>
                            <small class="review-home-cake">Mẫu bánh: <%= rev.getTemplateName() %></small>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="review-empty">
                        <p>Chưa có đánh giá nổi bật nào được chọn hiển thị.</p>
                    </div>
                    <%
                        }
                    %>
                </div>
            </section>

            <!-- CTA -->
            <section class="section">
                <div class="cta-card">
                    <h2>Sẵn sàng chọn chiếc bánh cho hôm nay?</h2>

                    <div class="cta-actions">
                        <a href="#" class="btn btn-primary">Đặt bánh ngay</a>
                        <a href="#" class="btn btn-outline">Tự thiết kế bánh</a>
                    </div>
                </div>
            </section>

        </main>

        <jsp:include page="footer.jsp" />
        <jsp:include page="scripts.jsp" />
    </body>

</html>
