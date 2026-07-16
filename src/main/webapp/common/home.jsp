
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
    </head>

    <body>
        <jsp:include page="navbar.jsp" />

        <main class="main">

            <!-- Hero Carousel -->
            <section class="section hero-section">
                <div class="hero-card" id="heroCarousel">

                    <div class="hero-slide active"
                         style="background-image: url('${pageContext.request.contextPath}/${not empty settings.banner1 ? settings.banner1 : 'assets/images/hero/hero-1.jpg'}');
                         background-position: center ${settings.banner1Align eq 'top' ? '0' : (settings.banner1Align eq 'bottom' ? '100' : (settings.banner1Align eq 'center' ? '50' : (not empty settings.banner1Align ? settings.banner1Align : '50')))}%;">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/${not empty settings.banner2 ? settings.banner2 : 'assets/images/hero/hero-2.jpg'}');
                         background-position: center ${settings.banner2Align eq 'top' ? '0' : (settings.banner2Align eq 'bottom' ? '100' : (settings.banner2Align eq 'center' ? '50' : (not empty settings.banner2Align ? settings.banner2Align : '50')))}%;">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/${not empty settings.banner3 ? settings.banner3 : 'assets/images/hero/hero-3.jpg'}');
                         background-position: center ${settings.banner3Align eq 'top' ? '0' : (settings.banner3Align eq 'bottom' ? '100' : (settings.banner3Align eq 'center' ? '50' : (not empty settings.banner3Align ? settings.banner3Align : '50')))}%;">
                    </div>

                    <div class="hero-slide"
                         style="background-image: url('${pageContext.request.contextPath}/${not empty settings.banner4 ? settings.banner4 : 'assets/images/hero/hero-4.jpg'}');
                         background-position: center ${settings.banner4Align eq 'top' ? '0' : (settings.banner4Align eq 'bottom' ? '100' : (settings.banner4Align eq 'center' ? '50' : (not empty settings.banner4Align ? settings.banner4Align : '50')))}%;">
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

                        <h1>${not empty settings.heroTitle ? settings.heroTitle : 'Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc'}</h1>

                        <p>
                            ${not empty settings.heroSubtitle ? settings.heroSubtitle : 'Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng được làm thủ công từ nguyên liệu tự nhiên.'}
                        </p>

                        <div class="hero-actions">
                            <a href="<%= request.getContextPath() %>/products" class="btn btn-primary">Đặt bánh ngay</a>
                            <a href="#" class="btn btn-outline">Tự thiết kế bánh của bạn</a>
                        </div>
                    </div>

                    <!-- Carousel Navigation Buttons -->
                    <button class="hero-nav-btn prev" id="heroPrevBtn" type="button" aria-label="Slide trước">
                        <span class="material-symbols-outlined">chevron_left</span>
                    </button>
                    <button class="hero-nav-btn next" id="heroNextBtn" type="button" aria-label="Slide sau">
                        <span class="material-symbols-outlined">chevron_right</span>
                    </button>

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

            <section class="section review-section" style="padding: 60px 0; background-color: #f8f6f4;">
                <h2 class="center-title" style="font-family: 'Outfit', sans-serif; font-weight: 700; text-align: center; margin-bottom: 8px;">Khách hàng nói về Bakery Zone</h2>
                <p class="center-title-sub" style="text-align: center; color: #777; margin-bottom: 40px;">Những lời phản hồi chân thực nhất từ những trải nghiệm ngọt ngào</p>

                <div class="review-home-grid" style="display: flex; flex-direction: column; align-items: center; gap: 24px; width: 100%; padding: 0 15px; box-sizing: border-box;">
                    <%
                        List<Review> featuredReviews = (List<Review>) request.getAttribute("FEATURED_REVIEWS");
                        if (featuredReviews != null && !featuredReviews.isEmpty()) {
                            for (Review rev : featuredReviews) {
                    %>
                    <%-- BỐ CỤC CARD CHUẨN: Sử dụng Flexbox để chia đôi trái phải --%>
                    <div class="review-home-card" style="display: flex; flex-direction: row; align-items: center; background: #ffffff; border-radius: 20px; padding: 30px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); max-width: 800px; width: 100%; border: 1px solid #eee; gap: 30px;">

                        <%-- CỘT TRÁI: Nội dung (Sao, Lời bình, Tên khách) --%>
                        <div style="flex: 1; display: flex; flex-direction: column; gap: 12px;">
                            <div style="color: #ffb400; font-size: 18px;">
                                <% for (int s = 0; s < rev.getRatingStars(); s++) { %>★<% } %>
                                <% for (int s = rev.getRatingStars(); s < 5; s++) { %><span style="color: #ddd;">★</span><% } %>
                            </div>
                            <p style="font-size: 15px; font-style: italic; color: #555; line-height: 1.5; margin: 0;">"<%= rev.getComment() %>"</p>
                            <div style="display: flex; align-items: center; gap: 10px; margin-top: 10px;">
                                <img src="https://ui-avatars.com/api/?name=<%= java.net.URLEncoder.encode(rev.getCustomerName() != null ? rev.getCustomerName() : "A", "UTF-8") %>&background=3f5f36&color=fff&size=40" style="border-radius: 50%; width: 40px; height: 40px;">
                                <div>
                                    <h4 style="margin: 0; font-size: 14px; font-weight: 700;"><%= rev.getCustomerName() %></h4>
                                    <small style="color: #888; font-size: 12px;">Mẫu: <%= rev.getTemplateName() %></small>
                                </div>
                            </div>
                        </div>

                        <div style="width: 160px; border-left: 1px solid #f1ede8; padding-left: 40px; display: flex; flex-direction: column; align-items: center; justify-content: center; min-width: 160px;">
                            <%-- Lấy đường dẫn từ đối tượng Review hiện tại --%>
                            <%
                                String imgPath = rev.getProductImageUrl();
                                if (imgPath == null || imgPath.trim().isEmpty()) {
                                    imgPath = "assets/images/products/basic.png";
                                }
                                String finalImgPath;
                                if (imgPath.startsWith("http://") || imgPath.startsWith("https://") || imgPath.startsWith("data:")) {
                                    finalImgPath = imgPath;
                                } else {
                                    finalImgPath = request.getContextPath() + "/" + imgPath;
                                }
                            %>

                            <img src="<%= finalImgPath %>" 
                                 alt="<%= rev.getTemplateName() != null ? rev.getTemplateName() : "Bánh" %>" 
                                 onerror="this.src='<%= request.getContextPath() %>/assets/images/products/basic.png'"
                                 style="width: 110px; height: 110px; object-fit: cover; border-radius: 14px; border: 1px solid #f1ede8; box-shadow: 0 8px 20px rgba(0,0,0,0.04);">

                            <span style="background-color: #f1ede8; color: #3f5f36; font-size: 11px; font-weight: 700; padding: 5px 12px; border-radius: 20px; margin-top: 10px;">
                                ✓ Đã mua hàng
                            </span>
                        </div>
                    </div>
                    <%
                            }
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
