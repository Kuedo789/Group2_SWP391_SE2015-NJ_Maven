<%-- 
    Document   : productDetail
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    int productId = 1;

    try {
        String idParam = request.getParameter("id");

        if (idParam != null) {
            productId = Integer.parseInt(idParam);
        }
    } catch (Exception e) {
        productId = 1;
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
                <a href="<%= request.getContextPath() %>/customer/productList.jsp">Menu bánh</a>
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
                    <a href="<%= request.getContextPath() %>/customer/productList.jsp">Xem tất cả</a>
                </div>

                <div class="related-grid" id="relatedList"></div>
            </section>

        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

        <script>
            const contextPath = "<%= request.getContextPath() %>";
            const currentProductId = <%= productId %>;

            const products = [
                {
                    id: 1,
                    name: "Bánh Matcha Dâu Tây",
                    category: "Bánh Flan Gato",
                    price: 450,
                    desc: "Cốt bánh matcha mềm, kem tươi và dâu tươi chua ngọt.",
                    image: contextPath + "/img/cake-1.jpg",
                    featured: true
                },
                {
                    id: 2,
                    name: "Flan Gato Chocolate",
                    category: "Bánh Flan Gato",
                    price: 390,
                    desc: "Flan mềm mịn kết hợp cốt gato chocolate thơm béo.",
                    image: contextPath + "/img/cake-2.jpg",
                    featured: false
                },
                {
                    id: 3,
                    name: "Flan Gato Dâu",
                    category: "Bánh Flan Gato",
                    price: 420,
                    desc: "Vị dâu nhẹ nhàng, phù hợp cho tiệc sinh nhật nhỏ.",
                    image: contextPath + "/img/cake-3.jpg",
                    featured: false
                },
                {
                    id: 4,
                    name: "Bánh Sinh Nhật Tối Giản",
                    category: "Bánh Entremet",
                    price: 380,
                    desc: "Thiết kế tinh tế, kem bơ ngọt vừa, phù hợp sinh nhật.",
                    image: contextPath + "/img/cake-1.jpg",
                    featured: true
                },
                {
                    id: 5,
                    name: "Entremet Trái Cây",
                    category: "Bánh Entremet",
                    price: 520,
                    desc: "Nhiều lớp bánh mềm, vị trái cây tươi mát.",
                    image: contextPath + "/img/cake-2.jpg",
                    featured: false
                },
                {
                    id: 6,
                    name: "Bánh Kem Bắp Mini",
                    category: "Bánh Kem Bắp",
                    price: 320,
                    desc: "Kem bắp thơm nhẹ, cốt bánh mềm và ít ngọt.",
                    image: contextPath + "/img/cake-3.jpg",
                    featured: false
                },
                {
                    id: 7,
                    name: "Bánh Kem Bắp Phô Mai",
                    category: "Bánh Kem Bắp",
                    price: 360,
                    desc: "Kết hợp kem bắp và lớp phô mai béo nhẹ.",
                    image: contextPath + "/img/cake-1.jpg",
                    featured: true
                },
                {
                    id: 8,
                    name: "Mousse Dâu Tây",
                    category: "Bánh Mousse",
                    price: 420,
                    desc: "Lớp mousse dâu mềm mịn, hương vị nhẹ nhàng.",
                    image: contextPath + "/img/cake-2.jpg",
                    featured: false
                },
                {
                    id: 9,
                    name: "Mousse Xoài",
                    category: "Bánh Mousse",
                    price: 410,
                    desc: "Vị xoài tươi, mềm mịn, phù hợp ngày hè.",
                    image: contextPath + "/img/cake-3.jpg",
                    featured: false
                },
                {
                    id: 10,
                    name: "Mousse Chocolate",
                    category: "Bánh Mousse",
                    price: 450,
                    desc: "Vị chocolate đậm, ít ngọt, thơm béo.",
                    image: contextPath + "/img/cake-1.jpg",
                    featured: true
                },
                {
                    id: 11,
                    name: "Sweetbox Premium Socola",
                    category: "Sweetbox Premium",
                    price: 520,
                    desc: "Phiên bản cao cấp với socola đậm vị.",
                    image: contextPath + "/img/cake-2.jpg",
                    featured: false
                },
                {
                    id: 12,
                    name: "Sweetbox Dâu Mix",
                    category: "Sweetbox",
                    price: 260,
                    desc: "Hộp bánh nhỏ xinh gồm nhiều vị trái cây.",
                    image: contextPath + "/img/cake-3.jpg",
                    featured: true
                },
                {
                    id: 13,
                    name: "Sweetin Croissant",
                    category: "Sweetin",
                    price: 45,
                    desc: "Vỏ bánh giòn, thơm bơ, phù hợp dùng cùng cà phê.",
                    image: contextPath + "/img/cake-1.jpg",
                    featured: false
                },
                {
                    id: 14,
                    name: "Bánh Healthy Yến Mạch",
                    category: "Bánh Healthy",
                    price: 280,
                    desc: "Ít đường, vị nhẹ, phù hợp người thích ăn lành mạnh.",
                    image: contextPath + "/img/cake-2.jpg",
                    featured: false
                }
            ];

            let product = products.find(function (item) {
                return item.id === currentProductId;
            });

            if (!product) {
                product = products[0];
            }

            let selectedVariant = 0;
            let selectedImage = 0;
            let quantity = 1;
            let selectedRating = 5;
            let isFavorite = false;

            const images = [
                product.image,
                contextPath + "/img/cake-2.jpg",
                contextPath + "/img/cake-3.jpg"
            ];

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
                    price: product.price + 80,
                    note: "Size bánh dành cho 6 - 8 người dùng.",
                    size: "Size 20cm",
                    people: "6-8 người"
                },
                {
                    name: product.name + " 24cm",
                    price: product.price + 160,
                    note: "Size bánh dành cho trên 8 người dùng.",
                    size: "Size 24cm",
                    people: ">8 người"
                }
            ];

            function formatPrice(price) {
                return price.toLocaleString("vi-VN") + ".000đ";
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
                        '<p><strong>Hương vị:</strong> Ngọt dịu - béo nhẹ - thơm mềm.</p>' +
                        '<p><strong>Cấu trúc bánh:</strong></p>' +
                        '<ul>' +
                        '<li>Cốt bánh mềm, thơm và dễ ăn.</li>' +
                        '<li>Lớp kem mịn, vị ngọt vừa phải.</li>' +
                        '<li>Trang trí tinh tế, phù hợp sinh nhật và tiệc nhỏ.</li>' +
                        '</ul>' +
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
                        '<button type="button" class="review-submit" onclick="submitReview()">' +
                        'Gửi đánh giá' +
                        '</button>' +
                        '<div class="review-list" id="reviewList">' +
                        '<div class="review-empty" id="reviewEmpty">' +
                        'Chưa có đánh giá nào cho sản phẩm này.' +
                        '</div>' +
                        '</div>' +
                        '</div>';
            }

            function createStars(rating) {
                let html = "";

                for (let i = 1; i <= 5; i++) {
                    html += '<button type="button" class="star-item ' + (i <= rating ? 'active' : '') + '" onclick="selectRating(' + i + ')">' +
                            '★' +
                            '</button>';
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
                let related = products.filter(function (item) {
                    return item.category === product.category && item.id !== product.id;
                });

                if (related.length === 0) {
                    related = products.filter(function (item) {
                        return item.id !== product.id;
                    });
                }

                related = related.slice(0, 4);

                let html = "";

                for (let i = 0; i < related.length; i++) {
                    html += '<div class="related-card" onclick="goToProductDetail(' + related[i].id + ')">';
                    html += '<img src="' + related[i].image + '" alt="' + related[i].name + '">';
                    html += '<div class="related-body">';
                    html += '<div class="related-name">' + related[i].name + '</div>';
                    html += '<div class="related-price">' + formatPrice(related[i].price) + '</div>';
                    html += '</div>';
                    html += '</div>';
                }

                document.getElementById("relatedList").innerHTML = html;
            }

            function goToProductDetail(id) {
                window.location.href = contextPath + "/customer/productDetail.jsp?id=" + id;
            }

            renderProductInfo();
        </script>

    </body>
</html>