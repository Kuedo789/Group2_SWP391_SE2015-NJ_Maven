
<%-- 
    Document   : home
    Created on : Jun 4, 2026, 1:15:29 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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
                            <a href="#" class="btn btn-primary">Đặt bánh ngay</a>
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

                    <a href="${pageContext.request.contextPath}/products?category=Bánh Flan Gato" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/flan-gato.png" alt="Bánh Flan Gato">
                        </div>
                        <span>Bánh Flan Gato</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Bánh Entremet" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/entremet.png" alt="Bánh Entremet">
                        </div>
                        <span>Bánh Entremet</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Bánh Kem Bắp" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/kem-bap.png" alt="Bánh Kem Bắp">
                        </div>
                        <span>Bánh Kem Bắp</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Bánh Mousse" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/banh-mousse.png" alt="Bánh Mousse">
                        </div>
                        <span>Bánh Mousse</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Sweetbox Premium" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/sweetbox-premium.png" alt="Sweetbox Premium">
                        </div>
                        <span>Sweetbox Premium</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Sweetbox" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/sweetbox.png" alt="Sweetbox">
                        </div>
                        <span>Sweetbox</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Sweetin" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/sweetin.png" alt="Sweetin">
                        </div>
                        <span>Sweetin</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Bánh Healthy" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/healthy.png" alt="Bánh Healthy">
                        </div>
                        <span>Bánh Healthy</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Bánh nướng %26 Bánh mì" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/banh-my.png" alt="Bánh nướng và Bánh mì">
                        </div>
                        <span>Bánh nướng & Bánh mì</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/products?category=Combo" class="category-item">
                        <div class="category-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/categories/icons/combo.png" alt="Combo">
                        </div>
                        <span>Combo</span>
                    </a>

                </div>
            </section>

            <!-- Bánh bán chạy -->
            <section class="section">
                <div class="section-heading section-heading-bottom">
                    <div>
                        <h2>Bánh bán chạy</h2>
                        <p>Những hương vị được yêu thích nhất tại tiệm.</p>
                    </div>

                    <a href="#" class="view-more">
                        Xem tất cả
                        <span class="material-symbols-outlined">arrow_forward</span>
                    </a>
                </div>

                <div class="product-grid">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/products/matcha_dautay.png"
                                 alt="Bánh Matcha Dâu Tây">
                            <span class="badge badge-red">Bán chạy</span>
                        </div>

                        <h3>Bánh Matcha Dâu Tây</h3>
                        <p>Cốt bánh matcha thơm lừng, kem tươi và dâu tươi chua ngọt hài hòa.</p>

                        <div class="product-bottom">
                            <strong>450.000đ</strong>
                            <button type="button">
                                <span class="material-symbols-outlined">add_shopping_cart</span>
                            </button>
                        </div>
                    </div>

                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/products/basic.png"
                                 alt="Bánh Sinh Nhật Tối Giản">
                            <span class="badge badge-brown">Mới</span>
                        </div>

                        <h3>Bánh Sinh Nhật Tối Giản</h3>
                        <p>Thiết kế thanh lịch, kem béo ngậy với điểm nhấn trang trí thiên nhiên.</p>

                        <div class="product-bottom">
                            <strong>380.000đ</strong>
                            <button type="button">
                                <span class="material-symbols-outlined">add_shopping_cart</span>
                            </button>
                        </div>
                    </div>

                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/products/basic-2.png"
                                 alt="Mousse Dâu Tây">
                            <span class="badge badge-yellow">Nổi bật</span>
                        </div>

                        <h3>Mousse Dâu Tây</h3>
                        <p>Lớp mousse dâu tươi mềm mịn, ngọt thanh mát lạnh bọc nhân dâu tây.</p>

                        <div class="product-bottom">
                            <strong>420.000đ</strong>
                            <button type="button">
                                <span class="material-symbols-outlined">add_shopping_cart</span>
                            </button>
                        </div>
                    </div>

                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/assets/images/products/sung_bo.png"
                                 alt="Croissant Bơ Pháp">
                        </div>

                        <h3>Croissant Bơ Pháp</h3>
                        <p>Vỏ bánh giòn rụm, ngàn lớp thơm phức mùi bơ Pháp hảo hạng.</p>

                        <div class="product-bottom">
                            <strong>45.000đ</strong>
                            <button type="button">
                                <span class="material-symbols-outlined">add_shopping_cart</span>
                            </button>
                        </div>
                    </div>
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