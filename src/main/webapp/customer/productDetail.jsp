<%-- 
    Document   : productDetail
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.bakeryzone.model.Product"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String js(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("'", "\\'")
                .replace("\n", " ")
                .replace("\r", " ");
    }
%>

<%
    Product product = (Product) request.getAttribute("product");
    List<Product> relatedProducts = (List<Product>) request.getAttribute("relatedProducts");

    if (relatedProducts == null) {
        relatedProducts = new ArrayList<>();
    }

    if (product == null) {
        response.sendRedirect(request.getContextPath() + "/products");
        return;
    }

    List<String> imageList = new ArrayList<>();

    if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty()) {
        imageList.add(product.getImageUrl());
    }

    if (product.getAdditionalImages() != null) {
        for (String img : product.getAdditionalImages()) {
            if (img != null && !img.trim().isEmpty() && !imageList.contains(img)) {
                imageList.add(img);
            }
        }
    }

    if (imageList.isEmpty()) {
        imageList.add("assets/images/products/basic.png");
    }
%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />
        <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/productDetail.css">
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="detail-page">

            <div class="breadcrumb">
                <a href="<%= request.getContextPath() %>/common/home.jsp">Trang chủ</a>
                <span>›</span>
                <a href="<%= request.getContextPath() %>/products">Menu bánh</a>
                <span>›</span>
                <span id="breadcrumbName">Chi tiết bánh</span>
            </div>

            <section class="detail-layout">

                <div class="detail-image-box">
                    <div class="main-image-wrap">
                        <img src="" alt="Product image" class="main-image" id="mainImage">

                        <button type="button" class="image-arrow left" onclick="changeImage(-1)">
                            <i class="fa fa-angle-left"></i>
                        </button>

                        <button type="button" class="image-arrow right" onclick="changeImage(1)">
                            <i class="fa fa-angle-right"></i>
                        </button>

                        <div class="image-count" id="imageCount">1/3</div>
                    </div>

                    <div class="thumb-list" id="thumbList"></div>
                </div>

                <div class="detail-info">
                    <div class="detail-category" id="productCategory">Danh mục</div>

                    <h1 class="detail-title" id="productName">Tên sản phẩm</h1>

                    <p class="detail-desc" id="productDesc">Mô tả sản phẩm</p>

                    <div class="section-label">Chọn phiên bản</div>

                    <div class="variant-list" id="variantList"></div>

                    <div class="detail-price" id="productPrice">0đ</div>

                    <a href="<%= request.getContextPath() %>/auth/login.jsp" class="voucher-text">
                        Đăng nhập để xem voucher ưu đãi của bạn ›
                    </a>

                    <div class="tag-list">
                        <div class="tag-item" id="sizeTag">Size 16cm</div>
                        <div class="tag-item" id="peopleTag">4-6 người</div>
                    </div>

                    <div class="benefit-list">
                        <span>Giao nhanh 2h</span>
                        <span>100% tự nhiên</span>
                        <span>Đổi nếu lỗi</span>
                    </div>

                    <div class="buy-row">
                        <div class="quantity-box">
                            <button type="button" onclick="changeQuantity(-1)">−</button>
                            <span id="quantity">1</span>
                            <button type="button" onclick="changeQuantity(1)">+</button>
                        </div>

                        <button type="button" class="add-cart-btn" onclick="addToCart()">
                            <i class="fa fa-shopping-bag"></i>
                            Thêm vào giỏ · <span id="cartPrice">0đ</span>
                        </button>

                        <button type="button" class="favorite-btn" id="favoriteBtn" onclick="toggleFavorite()">
                            <span id="favoriteIcon">♡</span>
                        </button>
                    </div>
                </div>

            </section>

            <section class="detail-tabs">
                <div class="tab-header">
                    <button type="button" class="tab-btn active" onclick="showTab('desc', this)">Mô tả</button>
                    <button type="button" class="tab-btn" onclick="showTab('review', this)">Đánh giá</button>
                </div>

                <div class="tab-content" id="tabContent"></div>
            </section>

            <section class="related-section">
                <div class="section-top">
                    <h2>Sản phẩm liên quan</h2>
                    <a href="<%= request.getContextPath() %>/products">Xem tất cả</a>
                </div>

                <div class="related-grid" id="relatedList"></div>
            </section>

        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script>
            const contextPath = "<%= request.getContextPath() %>";

            const product = {
                id: "<%= js(product.getId()) %>",
                name: "<%= js(product.getName()) %>",
                category: "<%= js(product.getCategoryName()) %>",
                price: <%= product.getBasePrice() %>,
                desc: "<%= js(product.getFullDescription()) %>",
                image: contextPath + "/<%= js(imageList.get(0)) %>"
            };

            const images = [
            <%
                for (String img : imageList) {
            %>
                contextPath + "/<%= js(img) %>",
            <%
                }
            %>
            ];

            const relatedProducts = [
            <%
                for (Product p : relatedProducts) {
            %>
                {
                    id: "<%= js(p.getId()) %>",
                            name: "<%= js(p.getName()) %>",
                    category: "<%= js(p.getCategoryName()) %>",
                            price: <%= p.getBasePrice() %>,
                    desc: "<%= js(p.getFullDescription()) %>",
                            image: contextPath + "/<%= js(p.getImageUrl()) %>"
                },
            <%
                }
            %>
            ];

            let selectedVariant = 0;
            let selectedImage = 0;
            let quantity = 1;
            let selectedRating = 5;
            let isFavorite = false;

            const variants = [
                {
                    name: product.name + " 16cm",
                    price: product.price,
                    note: "Size bánh dành cho 4 - 6 người dùng.",
                    size: "Size 16cm",
                    people: "4-6 người"
                },
                {
                    name: product.name + " 20cm",
                    price: product.price + 80000,
                    note: "Size bánh dành cho 6 - 8 người dùng.",
                    size: "Size 20cm",
                    people: "6-8 người"
                },
                {
                    name: product.name + " 24cm",
                    price: product.price + 160000,
                    note: "Size bánh dành cho trên 8 người dùng.",
                    size: "Size 24cm",
                    people: ">8 người"
                }
            ];

            function formatPrice(price) {
                return price.toLocaleString("vi-VN") + " đ";
            }

            function renderProductInfo() {
                document.getElementById("breadcrumbName").innerText = product.name;
                document.getElementById("productCategory").innerText = product.category;
                document.getElementById("productName").innerText = product.name;
                document.getElementById("productDesc").innerText = product.desc;
                document.getElementById("mainImage").src = images[selectedImage];

                renderImages();
                renderVariants();
                updatePrice();
                renderDescription();
                renderRelatedProducts();
            }

            function renderImages() {
                document.getElementById("mainImage").src = images[selectedImage];
                document.getElementById("imageCount").innerText = (selectedImage + 1) + "/" + images.length;

                let html = "";

                for (let i = 0; i < images.length; i++) {
                    html += '<div class="thumb-item ' + (i === selectedImage ? 'active' : '') + '" onclick="selectImage(' + i + ')">';
                    html += '<img src="' + images[i] + '" alt="Ảnh bánh">';
                    html += '</div>';
                }

                document.getElementById("thumbList").innerHTML = html;
            }

            function selectImage(index) {
                selectedImage = index;
                renderImages();
            }

            function changeImage(step) {
                selectedImage += step;

                if (selectedImage < 0) {
                    selectedImage = images.length - 1;
                }

                if (selectedImage >= images.length) {
                    selectedImage = 0;
                }

                renderImages();
            }

            function renderVariants() {
                let html = "";

                for (let i = 0; i < variants.length; i++) {
                    html += '<div class="variant-item ' + (i === selectedVariant ? 'active' : '') + '" onclick="selectVariant(' + i + ')">';
                    html += '<div class="variant-left">';
                    html += '<img src="' + product.image + '" alt="Phiên bản bánh">';
                    html += '<div>';
                    html += '<div class="variant-name">' + variants[i].name + '</div>';
                    html += '<div class="variant-note">' + variants[i].note + '</div>';
                    html += '</div>';
                    html += '</div>';
                    html += '<div class="variant-price">' + formatPrice(variants[i].price) + '</div>';
                    html += '<div class="variant-check"></div>';
                    html += '</div>';
                }

                document.getElementById("variantList").innerHTML = html;
            }

            function selectVariant(index) {
                selectedVariant = index;
                renderVariants();
                updatePrice();
            }

            function updatePrice() {
                const price = variants[selectedVariant].price;
                const total = price * quantity;

                document.getElementById("productPrice").innerText = formatPrice(price);
                document.getElementById("cartPrice").innerText = formatPrice(total);
                document.getElementById("sizeTag").innerText = variants[selectedVariant].size;
                document.getElementById("peopleTag").innerText = variants[selectedVariant].people;
                document.getElementById("quantity").innerText = quantity;
            }

            function changeQuantity(step) {
                quantity += step;

                if (quantity < 1) {
                    quantity = 1;
                }

                updatePrice();
            }

            function addToCart() {
                alert("Đã thêm " + quantity + " sản phẩm vào giỏ hàng!");
            }

            function toggleFavorite() {
                isFavorite = !isFavorite;

                const favoriteBtn = document.getElementById("favoriteBtn");
                const favoriteIcon = document.getElementById("favoriteIcon");

                if (isFavorite) {
                    favoriteBtn.classList.add("active");
                    favoriteIcon.innerText = "♥";
                } else {
                    favoriteBtn.classList.remove("active");
                    favoriteIcon.innerText = "♡";
                }
            }

            function showTab(tabName, button) {
                const buttons = document.querySelectorAll(".tab-btn");

                for (let i = 0; i < buttons.length; i++) {
                    buttons[i].classList.remove("active");
                }

                button.classList.add("active");

                if (tabName === "desc") {
                    renderDescription();
                } else {
                    renderReviews();
                }
            }

            function renderDescription() {
                document.getElementById("tabContent").innerHTML =
                        '<p><strong>Mô tả:</strong> ' + product.desc + '</p>' +
                        '<p><strong>Hương vị:</strong> Ngọt dịu - béo nhẹ - thơm mềm.</p>' +
                        '<p><strong>Bảo quản:</strong> Bánh nên được dùng trong ngày và bảo quản lạnh trước khi thưởng thức.</p>' +
                        '<p><strong>Phụ kiện tặng kèm:</strong></p>' +
                        '<ul>' +
                        '<li>1 dao cắt bánh</li>' +
                        '<li>1 bộ đĩa và muỗng</li>' +
                        '<li>Hộp nến nhỏ</li>' +
                        '</ul>';
            }

            function renderReviews() {
                document.getElementById("tabContent").innerHTML =
                        '<div class="review-box">' +
                        '<div class="review-title">Đánh giá sản phẩm</div>' +
                        '<div class="star-row" id="starRow">' +
                        createStars(selectedRating) +
                        '</div>' +
                        '<textarea class="review-textarea" id="reviewContent" placeholder="Viết cảm nhận của bạn về sản phẩm..."></textarea>' +
                        '<button type="button" class="review-submit" onclick="submitReview()">Gửi đánh giá</button>' +
                        '<div class="review-list" id="reviewList">' +
                        '<div class="review-empty" id="reviewEmpty">Chưa có đánh giá nào cho sản phẩm này.</div>' +
                        '</div>' +
                        '</div>';
            }

            function createStars(rating) {
                let html = "";

                for (let i = 1; i <= 5; i++) {
                    html += '<button type="button" class="star-item ' + (i <= rating ? 'active' : '') + '" onclick="selectRating(' + i + ')">★</button>';
                }

                return html;
            }

            function selectRating(rating) {
                selectedRating = rating;
                document.getElementById("starRow").innerHTML = createStars(selectedRating);
            }

            function submitReview() {
                const content = document.getElementById("reviewContent").value.trim();

                if (content === "") {
                    alert("Vui lòng nhập nội dung đánh giá.");
                    return;
                }

                let stars = "";

                for (let i = 1; i <= selectedRating; i++) {
                    stars += "★";
                }

                const reviewList = document.getElementById("reviewList");
                const reviewEmpty = document.getElementById("reviewEmpty");

                if (reviewEmpty) {
                    reviewEmpty.remove();
                }

                reviewList.innerHTML =
                        '<div class="review-item">' +
                        '<div class="review-name">Bạn</div>' +
                        '<div class="review-stars">' + stars + '</div>' +
                        '<div class="review-content">' + content + '</div>' +
                        '</div>' +
                        reviewList.innerHTML;

                document.getElementById("reviewContent").value = "";
                selectedRating = 5;
                document.getElementById("starRow").innerHTML = createStars(selectedRating);
            }

            function renderRelatedProducts() {
                let html = "";

                if (relatedProducts.length === 0) {
                    document.getElementById("relatedList").innerHTML = "<p>Chưa có sản phẩm liên quan.</p>";
                    return;
                }

                for (let i = 0; i < relatedProducts.length; i++) {
                    html += '<div class="related-card" onclick="goToProductDetail(\'' + relatedProducts[i].id + '\')">';
                    html += '<img src="' + relatedProducts[i].image + '" alt="' + relatedProducts[i].name + '">';
                    html += '<div class="related-body">';
                    html += '<div class="related-name">' + relatedProducts[i].name + '</div>';
                    html += '<div class="related-price">' + formatPrice(relatedProducts[i].price) + '</div>';
                    html += '</div>';
                    html += '</div>';
                }

                document.getElementById("relatedList").innerHTML = html;
            }

            function goToProductDetail(id) {
                window.location.href = contextPath + "/product-detail?id=" + id;
            }

            renderProductInfo();
        </script>    

    </body>
</html>