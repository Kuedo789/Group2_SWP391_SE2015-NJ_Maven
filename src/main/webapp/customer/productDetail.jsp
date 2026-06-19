<%-- 
    Document   : productDetail
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.bakeryzone.model.Product"%>
<%@page import="com.bakeryzone.model.Review"%>
<%@page import="com.bakeryzone.model.User"%>
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

    boolean hasBought = request.getAttribute("hasBought") != null ? (Boolean) request.getAttribute("hasBought") : false;
    boolean hasReviewed = request.getAttribute("hasReviewed") != null ? (Boolean) request.getAttribute("hasReviewed") : false;
    List<Review> reviewsList = (List<Review>) request.getAttribute("reviewsList");
    if (reviewsList == null) {
        reviewsList = new ArrayList<>();
    }
    User sessionUser = (User) session.getAttribute("user");
    String currentUserId = sessionUser != null ? sessionUser.getUserId() : "";
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

                        <button type="button" class="add-cart-btn" onclick="buyNow()">
                            Đặt hàng · <span id="cartPrice">0đ</span>
                        </button>

                        <button type="button" class="favorite-btn" onclick="addToCartIconOnly()" title="Thêm vào giỏ hàng" style="color: var(--primary); display: flex; align-items: center; justify-content: center;">
                            <i class="fa fa-shopping-cart"></i>
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
                image: "<%= js(imageList.get(0)) %>".startsWith("http") ? "<%= js(imageList.get(0)) %>" : contextPath + "/<%= js(imageList.get(0)) %>"
            };

            const images = [
            <%
                for (String img : imageList) {
            %>
                "<%= js(img) %>".startsWith("http") ? "<%= js(img) %>" : contextPath + "/<%= js(img) %>",
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
                            image: "<%= js(p.getImageUrl()) %>".startsWith("http") ? "<%= js(p.getImageUrl()) %>" : contextPath + "/<%= js(p.getImageUrl()) %>"
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

            function addToCartIconOnly() {
                let cart = [];
                try {
                    const cartStr = localStorage.getItem("cart");
                    if (cartStr) {
                        cart = JSON.parse(cartStr);
                    }
                } catch (e) {
                    cart = [];
                }

                if (!Array.isArray(cart)) {
                    cart = [];
                }

                const selectedVar = variants[selectedVariant];
                let resolvedImage = "assets/images/products/basic.png";
                if (product.image) {
                    if (product.image.startsWith("http")) {
                        resolvedImage = product.image;
                    } else {
                        let imgPath = product.image;
                        if (contextPath && imgPath.startsWith(contextPath)) {
                            imgPath = imgPath.substring(contextPath.length);
                        }
                        if (imgPath.startsWith("/")) {
                            imgPath = imgPath.substring(1);
                        }
                        resolvedImage = imgPath;
                    }
                }

                const item = {
                    id: product.id + "_" + selectedVariant,
                    name: selectedVar.name,
                    desc: selectedVar.note,
                    price: selectedVar.price,
                    qty: quantity,
                    image: resolvedImage
                };

                const existingItem = cart.find(x => x && x.name === item.name);
                if (existingItem) {
                    existingItem.qty = (parseInt(existingItem.qty) || 0) + quantity;
                } else {
                    cart.push(item);
                }

                localStorage.setItem("cart", JSON.stringify(cart));
                
                window.dispatchEvent(new Event("storage"));
                const countEl = document.getElementById("navCartCount");
                if (countEl) {
                    let totalQty = 0;
                    cart.forEach(c => { if (c) totalQty += (parseInt(c.qty) || 1); });
                    countEl.innerText = totalQty;
                }

                alert("Đã thêm " + quantity + " sản phẩm \"" + item.name + "\" vào giỏ hàng!");
            }

            function buyNow() {
                let cart = [];
                try {
                    const cartStr = localStorage.getItem("cart");
                    if (cartStr) {
                        cart = JSON.parse(cartStr);
                    }
                } catch (e) {
                    cart = [];
                }

                if (!Array.isArray(cart)) {
                    cart = [];
                }

                const selectedVar = variants[selectedVariant];
                let resolvedImage = "assets/images/products/basic.png";
                if (product.image) {
                    if (product.image.startsWith("http")) {
                        resolvedImage = product.image;
                    } else {
                        let imgPath = product.image;
                        if (contextPath && imgPath.startsWith(contextPath)) {
                            imgPath = imgPath.substring(contextPath.length);
                        }
                        if (imgPath.startsWith("/")) {
                            imgPath = imgPath.substring(1);
                        }
                        resolvedImage = imgPath;
                    }
                }

                const item = {
                    id: product.id + "_" + selectedVariant,
                    name: selectedVar.name,
                    desc: selectedVar.note,
                    price: selectedVar.price,
                    qty: quantity,
                    image: resolvedImage
                };

                const existingItem = cart.find(x => x && x.name === item.name);
                if (existingItem) {
                    existingItem.qty = (parseInt(existingItem.qty) || 0) + quantity;
                } else {
                    cart.push(item);
                }

                localStorage.setItem("cart", JSON.stringify(cart));
                
                window.dispatchEvent(new Event("storage"));
                
                window.location.href = contextPath + "/checkout";
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

            const dbReviews = [
            <%
                for (Review r : reviewsList) {
            %>
                {
                    reviewId: "<%= js(r.getReviewId()) %>",
                    customCakeId: "<%= js(r.getCustomCakeId()) %>",
                    customerId: "<%= js(r.getCustomerId()) %>",
                    customerName: "<%= js(r.getCustomerName()) %>",
                    ratingStars: <%= r.getRatingStars() %>,
                    comment: "<%= js(r.getComment()) %>",
                    variationName: "<%= js(r.getVariationName()) %>",
                    greetingText: "<%= js(r.getGreetingText()) %>"
                },
            <%
                }
            %>
            ];

            const hasBought = <%= hasBought %>;
            const hasReviewed = <%= hasReviewed %>;
            const currentUserId = "<%= js(currentUserId) %>";
            const customCakeIdFromUrl = new URLSearchParams(window.location.search).get("customCakeId") || "";

            function renderReviews() {
                let formHtml = "";
                if (hasBought && !hasReviewed) {
                    formHtml = 
                        '<div class="review-box">' +
                        '<div class="review-title">Đánh giá sản phẩm</div>' +
                        '<div class="star-row" id="starRow">' +
                        createStars(selectedRating) +
                        '</div>' +
                        '<textarea class="review-textarea" id="reviewContent" placeholder="Viết cảm nhận của bạn về sản phẩm..."></textarea>' +
                        '<button type="button" class="review-submit" onclick="submitReview()">Gửi đánh giá</button>' +
                        '</div>';
                } else if (!hasBought) {
                    formHtml = 
                        '<div class="review-box" style="background: var(--bg-soft); border: 1px dashed var(--border); text-align: center; padding: 24px; color: var(--muted); border-radius: var(--radius-md);">' +
                        '<span class="material-symbols-outlined" style="font-size: 36px; margin-bottom: 8px; color: var(--primary);">info</span>' +
                        '<p style="margin: 0; font-size: 14px; font-weight: 500;">Chỉ những khách hàng đã mua sản phẩm này mới có thể gửi đánh giá. Bạn có thể xem các đánh giá khác bên dưới.</p>' +
                        '</div>';
                } else if (hasReviewed) {
                    formHtml = 
                        '<div class="review-box" style="background: #eefdf4; border: 1px dashed #bbf7d0; text-align: center; padding: 24px; color: #166534; border-radius: var(--radius-md);">' +
                        '<span class="material-symbols-outlined" style="font-size: 36px; margin-bottom: 8px; color: #15803d;">check_circle</span>' +
                        '<p style="margin: 0; font-size: 14px; font-weight: 500;">Bạn đã gửi đánh giá cho sản phẩm này. Cảm ơn phản hồi của bạn!</p>' +
                        '</div>';
                }

                let listHtml = '<div class="review-list" id="reviewList" style="margin-top: 30px;">';
                if (dbReviews.length === 0) {
                    listHtml += '<div class="review-empty" id="reviewEmpty">Chưa có đánh giá nào cho sản phẩm này.</div>';
                } else {
                    for (let i = 0; i < dbReviews.length; i++) {
                        listHtml += createReviewItemHtml(dbReviews[i]);
                    }
                }
                listHtml += '</div>';

                document.getElementById("tabContent").innerHTML = formHtml + listHtml;
            }

            function createReviewItemHtml(r) {
                let stars = "";
                for (let j = 1; j <= 5; j++) {
                    stars += j <= r.ratingStars ? "★" : "☆";
                }

                let subText = "Phiên bản: " + r.variationName;

                let actionsMenu = "";
                if (r.customerId === currentUserId) {
                    actionsMenu = 
                        '<div class="review-actions-menu" style="position: relative; float: right;">' +
                        '<button class="btn-dots" onclick="toggleReviewMenu(event, \'' + r.reviewId + '\')" style="background: none; border: none; font-size: 20px; cursor: pointer; color: var(--muted); padding: 4px 8px;">•••</button>' +
                        '<div class="review-dropdown" id="dropdown-' + r.reviewId + '" style="display: none; position: absolute; right: 0; top: 28px; background: white; border: 1px solid var(--border); border-radius: 4px; box-shadow: var(--shadow-soft); z-index: 10; min-width: 100px;">' +
                        '<button onclick="editReview(\'' + r.reviewId + '\', \'' + r.comment.replace(/'/g, "\\'") + '\', ' + r.ratingStars + ')" style="width: 100%; text-align: left; background: none; border: none; padding: 8px 12px; cursor: pointer; font-size: 13px; font-weight: 500; display: block; color: var(--text);">Chỉnh sửa</button>' +
                        '<button onclick="deleteReview(\'' + r.reviewId + '\')" style="width: 100%; text-align: left; background: none; border: none; padding: 8px 12px; cursor: pointer; font-size: 13px; font-weight: 500; color: #dc2626; border-top: 1px solid var(--border); display: block;">Xóa</button>' +
                        '</div>' +
                        '</div>';
                }

                return '' +
                    '<div class="review-item" id="review-item-' + r.reviewId + '" style="margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--border); position: relative;">' +
                    actionsMenu +
                    '<div class="review-name" style="font-weight: 700; font-size: 15px; color: var(--text);">' + r.customerName + '</div>' +
                    '<div class="review-version" style="font-size: 11px; color: var(--muted); margin: 2px 0 6px 0; font-style: italic;">' + subText + '</div>' +
                    '<div class="review-stars" style="color: #fbbf24; font-size: 14px; margin-bottom: 8px;">' + stars + '</div>' +
                    '<div class="review-content" id="review-content-' + r.reviewId + '" style="font-size: 14px; line-height: 1.5; color: var(--text);">' + r.comment + '</div>' +
                    '</div>';
            }

            function toggleReviewMenu(event, reviewId) {
                event.stopPropagation();
                const dropdowns = document.querySelectorAll(".review-dropdown");
                dropdowns.forEach(d => {
                    if (d.id !== 'dropdown-' + reviewId) {
                        d.style.display = 'none';
                    }
                });
                const current = document.getElementById('dropdown-' + reviewId);
                if (current) {
                    current.style.display = current.style.display === 'none' ? 'block' : 'none';
                }
            }

            // Close dropdowns when clicking outside
            document.addEventListener('click', function() {
                const dropdowns = document.querySelectorAll(".review-dropdown");
                dropdowns.forEach(d => d.style.display = 'none');
            });

            function editReview(reviewId, comment, rating) {
                const contentDiv = document.getElementById('review-content-' + reviewId);
                if (!contentDiv) return;
                
                let selectHtml = '<select id="edit-stars-' + reviewId + '" style="padding: 4px; border: 1px solid var(--border); border-radius: 4px; margin-bottom: 8px; display: block; font-size: 13px;">';
                for (let i = 5; i >= 1; i--) {
                    selectHtml += '<option value="' + i + '" ' + (i === rating ? 'selected' : '') + '>' + i + ' sao</option>';
                }
                selectHtml += '</select>';

                contentDiv.innerHTML = 
                    '<div class="edit-review-box" style="margin-top: 8px;">' +
                    selectHtml +
                    '<textarea id="edit-content-' + reviewId + '" class="review-textarea" style="width: 100%; height: 80px; font-size: 13px; padding: 8px; border: 1px solid var(--border); border-radius: 4px; margin-bottom: 8px;">' + comment + '</textarea>' +
                    '<div style="display: flex; gap: 8px;">' +
                    '<button type="button" class="btn" style="padding: 6px 12px; font-size: 12px; font-weight: 600; border-radius: 4px; background: var(--primary); color: white; border: none; cursor: pointer;" onclick="saveReviewUpdate(\'' + reviewId + '\')">Lưu</button>' +
                    '<button type="button" class="btn" style="padding: 6px 12px; font-size: 12px; font-weight: 600; border-radius: 4px; background: var(--bg-soft); color: var(--text); border: 1px solid var(--border); cursor: pointer;" onclick="renderReviews()">Hủy</button>' +
                    '</div>' +
                    '</div>';
            }

            function saveReviewUpdate(reviewId) {
                const rating = document.getElementById('edit-stars-' + reviewId).value;
                const comment = document.getElementById('edit-content-' + reviewId).value.trim();
                if (comment === "") {
                    alert("Nội dung đánh giá không được để trống.");
                    return;
                }

                const params = new URLSearchParams();
                params.append("action", "update");
                params.append("reviewId", reviewId);
                params.append("rating", rating);
                params.append("comment", comment);

                fetch(contextPath + "/review-api", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                    },
                    body: params
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        window.location.reload();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Đã xảy ra lỗi khi cập nhật đánh giá.");
                });
            }

            function deleteReview(reviewId) {
                if (!confirm("Bạn có chắc chắn muốn xóa đánh giá này không?")) {
                    return;
                }

                const params = new URLSearchParams();
                params.append("action", "delete");
                params.append("reviewId", reviewId);

                fetch(contextPath + "/review-api", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                    },
                    body: params
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        window.location.reload();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Đã xảy ra lỗi khi xóa đánh giá.");
                });
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

                const params = new URLSearchParams();
                params.append("action", "create");
                params.append("productId", product.id);
                params.append("rating", selectedRating);
                params.append("comment", content);
                params.append("customCakeId", customCakeIdFromUrl);

                fetch(contextPath + "/review-api", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                    },
                    body: params
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        window.location.reload();
                    } else {
                        alert(data.message);
                    }
                })
                .catch(err => {
                    console.error(err);
                    alert("Đã xảy ra lỗi khi gửi đánh giá.");
                });
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

            document.addEventListener("DOMContentLoaded", function () {
                renderProductInfo();
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('tab') === 'review') {
                    const buttons = document.querySelectorAll(".tab-btn");
                    let reviewBtn = null;
                    buttons.forEach(btn => {
                        const onclickAttr = btn.getAttribute('onclick');
                        if (onclickAttr && onclickAttr.includes('review')) {
                            reviewBtn = btn;
                        }
                    });
                    if (reviewBtn) {
                        showTab('review', reviewBtn);
                        setTimeout(() => {
                            const tabsSection = document.querySelector(".detail-tabs");
                            if (tabsSection) {
                                tabsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
                            }
                        }, 300);
                    }
                }
            });
        </script>    

    </body>
</html>