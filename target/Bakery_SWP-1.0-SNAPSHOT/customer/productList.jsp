<%-- 
    Document   : productList
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Menu bánh - Cái Lò Nướng</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!-- Bootstrap -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">

        <style>
            body {
                background-color: #faf7f0;
                font-family: Arial, sans-serif;
                color: #2b241d;
            }

            .navbar {
                background-color: #fffdf8;
                border-bottom: 1px solid #e8e1d6;
                padding: 18px 0;
            }

            .navbar-brand {
                font-size: 30px;
                font-weight: bold;
                color: #2f261e !important;
            }

            .navbar-brand img {
                width: 42px;
                margin-right: 10px;
            }

            .navbar .nav-link {
                color: #5f554c !important;
                font-weight: 600;
                margin: 0 12px;
            }

            .navbar .nav-link:hover,
            .navbar .nav-link.active {
                color: #155c2e !important;
            }

            .login-btn {
                background-color: #155c2e;
                color: white;
                border-radius: 12px;
                padding: 9px 22px;
                font-weight: bold;
                text-decoration: none;
            }

            .login-btn:hover {
                background-color: #0f4723;
                color: white;
            }

            .cart-icon {
                position: relative;
                color: #2b241d;
                font-size: 22px;
                margin-right: 20px;
            }

            .cart-badge {
                position: absolute;
                top: -11px;
                right: -12px;
                background-color: #ffd8d8;
                color: #8a2b2b;
                font-size: 12px;
                width: 22px;
                height: 22px;
                border-radius: 50%;
                text-align: center;
                line-height: 22px;
                font-weight: bold;
            }

            .page-section {
                padding: 35px 0 70px;
            }

            @media (min-width: 1200px) {
                .container {
                    max-width: 1420px;
                }
            }

            .page-section {
                padding: 28px 0 70px;
            }

            .filter-row {
                display: grid;
                grid-template-columns: 1fr 150px;
                gap: 14px;
                align-items: center;
                margin-bottom: 28px;
            }

            .search-box {
                position: relative;
                width: 100%;
            }

            .search-box i {
                position: absolute;
                top: 50%;
                left: 18px;
                transform: translateY(-50%);
                color: #6f6a61;
                font-size: 17px;
            }

            .search-box input {
                width: 100%;
                height: 54px;
                border: 1px solid #ded6ca;
                border-radius: 16px;
                padding: 0 20px 0 48px;
                background-color: #fffdf8;
                font-size: 17px;
                outline: none;
            }

            .search-box input:focus {
                border-color: #155c2e;
                box-shadow: 0 0 0 3px rgba(21, 92, 46, 0.10);
            }

            .sort-select {
                width: 150px;
                height: 54px;
                border: 1px solid #ded6ca;
                border-radius: 16px;
                padding: 0 14px;
                background-color: #fffdf8;
                font-size: 16px;
                color: #3b332c;
                outline: none;
                cursor: pointer;
            }

            .sort-select:focus {
                border-color: #155c2e;
                box-shadow: 0 0 0 3px rgba(21, 92, 46, 0.10);
            }

            .category-list {
                display: flex;
                flex-wrap: nowrap;
                gap: 10px;
                margin-bottom: 32px;
                overflow-x: auto;
                padding-bottom: 4px;
            }

            .category-list::-webkit-scrollbar {
                height: 0;
            }

            .category-pill {
                border: none;
                border-radius: 28px;
                padding: 11px 22px;
                background-color: #efebe4;
                color: #5f554c;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                white-space: nowrap;
            }

            .category-pill span {
                color: #9b9388;
                margin-left: 4px;
                font-size: 13px;
            }

            .category-pill.active {
                background-color: #155c2e;
                color: white;
            }

            .category-pill.active span {
                color: #dce8d8;
            }

            .product-count {
                font-size: 18px;
                color: #6a5f56;
                margin-bottom: 22px;
            }

            .product-count {
                font-size: 20px;
                color: #6a5f56;
                margin-bottom: 25px;
            }

            .category-banner {
                background-color: #153b16;
                color: white;
                border-radius: 24px;
                padding: 55px 45px;
                margin-bottom: 28px;
                background-image: linear-gradient(120deg, #123411, #214f19);
            }

            .category-banner h2 {
                font-size: 36px;
                font-weight: bold;
                margin-bottom: 12px;
            }

            .category-banner p {
                font-size: 20px;
                margin-bottom: 0;
                color: #f1efe7;
            }

            .cake-card {
                background-color: #fffdf8;
                border-radius: 22px;
                overflow: hidden;
                box-shadow: 0 8px 25px rgba(0, 0, 0, 0.07);
                height: 100%;
                position: relative;
                transition: 0.2s;
            }

            .cake-card:hover {
                transform: translateY(-5px);
            }

            .cake-img {
                width: 100%;
                height: 260px;
                object-fit: cover;
            }

            .cake-body {
                padding: 18px;
            }

            .cake-name {
                font-size: 18px;
                font-weight: bold;
                color: #2b241d;
                margin-bottom: 6px;
            }

            .cake-desc {
                font-size: 14px;
                color: #776e65;
                min-height: 42px;
                margin-bottom: 10px;
            }

            .cake-price {
                font-size: 17px;
                font-weight: bold;
                color: #2b241d;
            }

            .featured-badge {
                position: absolute;
                top: 14px;
                left: 14px;
                background-color: #155c2e;
                color: white;
                border-radius: 14px;
                padding: 5px 13px;
                font-size: 14px;
                font-weight: bold;
            }

            .cart-btn {
                position: absolute;
                right: 16px;
                bottom: 16px;
                width: 38px;
                height: 38px;
                border-radius: 50%;
                border: none;
                background-color: #eef3eb;
                color: #155c2e;
            }

            .cart-btn:hover {
                background-color: #155c2e;
                color: white;
            }

            .detail-link {
                display: inline-block;
                margin-top: 8px;
                color: #155c2e;
                font-weight: bold;
                text-decoration: none;
                font-size: 14px;
            }

            .detail-link:hover {
                text-decoration: underline;
            }

            .pagination .page-link {
                color: #155c2e;
                border-radius: 10px;
                margin: 0 4px;
            }

            .pagination .active .page-link {
                background-color: #155c2e;
                border-color: #155c2e;
                color: white;
            }

            .no-data {
                background-color: #fffdf8;
                border-radius: 20px;
                padding: 50px;
                text-align: center;
                color: #777;
                font-size: 18px;
            }

            .category-section {
                margin-bottom: 45px;
            }

            .category-section-banner {
                background-color: #153b16;
                color: white;
                border-radius: 24px;
                padding: 40px 35px;
                margin-bottom: 24px;
                background-image: linear-gradient(120deg, #123411, #214f19);
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .category-section-banner h2 {
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 8px;
            }

            .category-section-banner p {
                font-size: 18px;
                margin-bottom: 0;
                color: #f1efe7;
            }

            .view-all-btn {
                background-color: rgba(255, 255, 255, 0.18);
                color: white;
                border: none;
                border-radius: 18px;
                padding: 12px 24px;
                font-weight: bold;
            }

            .view-all-btn:hover {
                background-color: rgba(255, 255, 255, 0.28);
            }

            .footer-section {
                background-color: #efede7;
                padding: 70px 0;
                margin-top: 70px;
            }

            .footer-logo {
                color: #2f3e24;
                font-size: 24px;
                font-weight: bold;
                line-height: 1.3;
                margin-bottom: 18px;
            }

            .footer-desc {
                color: #4f4a43;
                font-size: 15px;
                line-height: 1.8;
                max-width: 240px;
                margin-bottom: 22px;
            }

            .footer-title {
                color: #2b241d;
                font-weight: bold;
                margin-bottom: 18px;
            }

            .footer-section a {
                display: block;
                color: #2b241d;
                text-decoration: none;
                margin-bottom: 12px;
                font-size: 15px;
            }

            .footer-section a:hover {
                color: #155c2e;
            }

            .footer-social {
                display: flex;
                gap: 12px;
            }

            .footer-social a {
                width: 34px;
                height: 34px;
                background-color: #f8f5ef;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .footer-social i {
                color: #2b241d;
                font-size: 14px;
            }
        </style>
    </head>

    <body>

        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg">
            <div class="container">
                <a href="<%= request.getContextPath() %>/index.jsp" class="navbar-brand">
                    Cái Lò Nướng
                </a>

                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMenu">
                    <span class="navbar-toggler-icon"></span>
                </button>

                <div class="collapse navbar-collapse" id="navbarMenu">
                    <div class="navbar-nav mx-auto">
                        <a href="<%= request.getContextPath() %>/index.jsp" class="nav-link">Trang chủ</a>
                        <a href="<%= request.getContextPath() %>/customer/productList.jsp" class="nav-link active">Menu bánh</a>
                        <a href="#" class="nav-link">Tự thiết kế</a>
                        <a href="#" class="nav-link">Bộ sưu tập</a>
                        <a href="#" class="nav-link">Ưu đãi</a>
                        <a href="#" class="nav-link">Liên hệ</a>
                    </div>

                    <div class="d-flex align-items-center">
                        <a href="#" class="cart-icon">
                            <i class="fa fa-cart-shopping"></i>
                            <span class="cart-badge">1</span>
                        </a>

                        <% if (session.getAttribute("user") != null) { %>
                        <div class="dropdown">
                            <a href="#" class="login-btn dropdown-toggle" data-bs-toggle="dropdown">
                                <i class="fa fa-user me-1"></i>
                                ${sessionScope.user.fullName}
                            </a>

                            <div class="dropdown-menu dropdown-menu-end">
                                <a href="<%= request.getContextPath() %>/customer/profile.jsp" class="dropdown-item">
                                    Update Profile
                                </a>
                                <a href="<%= request.getContextPath() %>/logout" class="dropdown-item">
                                    Logout
                                </a>
                            </div>
                        </div>
                        <% } else { %>
                        <a href="<%= request.getContextPath() %>/auth/login.jsp" class="login-btn">
                            <i class="fa fa-right-to-bracket me-2"></i>
                            Đăng nhập
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>
        </nav>

        <!-- Page Content -->
        <div class="container page-section">

            <!-- Search and Sort -->
            <div class="filter-row">
                <div class="search-box">
                    <i class="fa fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Tìm bánh, đồ uống...">
                </div>

                <select id="sortSelect" class="sort-select">
                    <option value="default">Mặc định</option>
                    <option value="priceAsc">Giá tăng</option>
                    <option value="priceDesc">Giá giảm</option>
                </select>
            </div>

            <!-- Categories -->
            <div class="category-list" id="categoryList">
                <button class="category-pill active" onclick="selectCategory('all', this)">Tất cả <span>82</span></button>
                <button class="category-pill" onclick="selectCategory('Bánh Flan Gato', this)">Bánh Flan Gato <span>6</span></button>
                <button class="category-pill" onclick="selectCategory('Bánh Entremet', this)">Bánh Entremet <span>2</span></button>
                <button class="category-pill" onclick="selectCategory('Bánh Kem Bắp', this)">Bánh Kem Bắp <span>2</span></button>
                <button class="category-pill" onclick="selectCategory('Bánh Mousse', this)">Bánh Mousse <span>13</span></button>
                <button class="category-pill" onclick="selectCategory('Sweetbox Premium', this)">Sweetbox Premium <span>3</span></button>
                <button class="category-pill" onclick="selectCategory('Sweetbox', this)">Sweetbox <span>8</span></button>
                <button class="category-pill" onclick="selectCategory('Sweetin', this)">Sweetin <span>11</span></button>
                <button class="category-pill" onclick="selectCategory('Bánh Healthy', this)">Bánh Healthy <span>4</span></button>
            </div>

            <div class="d-flex justify-content-between align-items-center">
                <div class="product-count" id="productCount">0 sản phẩm</div>
                <a href="<%= request.getContextPath() %>/auth/login.jsp" class="text-success fw-bold text-decoration-none">
                    Đăng nhập xem voucher ưu đãi của bạn
                </a>
            </div>

            <!-- Product List -->
            <div id="productList"></div>

            <div id="noDataMessage" class="no-data d-none">
                <i class="fa fa-box-open fa-2x mb-3"></i>
                <p>Không tìm thấy sản phẩm phù hợp.</p>
            </div>

            <!-- Pagination chỉ dùng khi xem riêng 1 danh mục -->
            <nav>
                <ul class="pagination justify-content-center mt-5" id="pagination"></ul>
            </nav>

        </div>

        <!-- Footer -->
        <footer class="footer-section">
            <div class="container">
                <div class="row">

                    <div class="col-lg-3 col-md-6 mb-4">
                        <h4 class="footer-logo">Tiệm Bánh Thủ<br>Công</h4>
                        <p class="footer-desc">
                            Hương vị ngọt ngào từ những nguyên liệu tự nhiên nhất,
                            mang đến niềm vui cho mọi khoảnh khắc.
                        </p>

                        <div class="footer-social">
                            <a href="#"><i class="fa-brands fa-instagram"></i></a>
                            <a href="#"><i class="fa-regular fa-thumbs-up"></i></a>
                            <a href="#"><i class="fa-solid fa-play"></i></a>
                        </div>
                    </div>

                    <div class="col-lg-2 col-md-6 mb-4">
                        <h6 class="footer-title">Sản phẩm</h6>
                        <a href="#">Menu bánh</a>
                        <a href="#">Bánh sinh nhật</a>
                        <a href="#">Tự thiết kế</a>
                        <a href="#">Combo quà tặng</a>
                    </div>

                    <div class="col-lg-2 col-md-6 mb-4">
                        <h6 class="footer-title">Hỗ trợ</h6>
                        <a href="#">Hướng dẫn đặt hàng</a>
                        <a href="#">Chính sách vận chuyển</a>
                        <a href="#">Câu hỏi thường gặp</a>
                        <a href="#">Liên hệ</a>
                    </div>

                    <div class="col-lg-2 col-md-6 mb-4">
                        <h6 class="footer-title">Tài khoản</h6>
                        <a href="${pageContext.request.contextPath}/auth/login.jsp">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/auth/register.jsp">Đăng ký</a>
                    </div>

                </div>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                    const contextPath = "<%= request.getContextPath() %>";

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

                    const categories = [
                        "Bánh Flan Gato",
                        "Bánh Entremet",
                        "Bánh Kem Bắp",
                        "Bánh Mousse",
                        "Sweetbox Premium",
                        "Sweetbox",
                        "Sweetin",
                        "Bánh Healthy"
                    ];

                    let currentCategory = "all";
                    let currentPage = 1;
                    const itemsPerPage = 8;
                    const itemsPerCategoryHome = 4;

                    const searchInput = document.getElementById("searchInput");
                    const sortSelect = document.getElementById("sortSelect");
                    const productList = document.getElementById("productList");
                    const pagination = document.getElementById("pagination");
                    const noDataMessage = document.getElementById("noDataMessage");
                    const productCount = document.getElementById("productCount");

                    function formatPrice(price) {
                        return price.toLocaleString("vi-VN") + ".000đ";
                    }

                    function createProductCard(product) {
                        let badge = "";

                        if (product.featured) {
                            badge = '<div class="featured-badge">Nổi bật</div>';
                        }

                        return '' +
                                '<div class="col-lg-3 col-md-6 mb-4">' +
                                '<div class="cake-card">' +
                                badge +
                                '<img src="' + product.image + '" class="cake-img" alt="Cake">' +
                                '<div class="cake-body">' +
                                '<div class="cake-name">' + product.name + '</div>' +
                                '<div class="cake-desc">' + product.desc + '</div>' +
                                '<div class="cake-price">' + formatPrice(product.price) + '</div>' +
                                '<a href="' + contextPath + '/customer/productDetail.jsp?id=' + product.id + '" class="detail-link">' +
                                'Xem chi tiết' +
                                '</a>' +
                                '<button class="cart-btn" type="button">' +
                                '<i class="fa fa-cart-plus"></i>' +
                                '</button>' +
                                '</div>' +
                                '</div>' +
                                '</div>';
                    }

                    function getSortedProducts(list) {
                        const sort = sortSelect.value;
                        let sorted = list.slice();

                        if (sort === "priceAsc") {
                            sorted.sort(function (a, b) {
                                return a.price - b.price;
                            });
                        } else if (sort === "priceDesc") {
                            sorted.sort(function (a, b) {
                                return b.price - a.price;
                            });
                        }

                        return sorted;
                    }

                    function getProductsBySearchAndCategory() {
                        const keyword = searchInput.value.toLowerCase().trim();

                        let filtered = products.filter(function (product) {
                            const matchName = product.name.toLowerCase().includes(keyword);
                            const matchCategory = currentCategory === "all" || product.category === currentCategory;
                            return matchName && matchCategory;
                        });

                        return getSortedProducts(filtered);
                    }

                    function renderAllCategories() {
                        const keyword = searchInput.value.toLowerCase().trim();

                        productList.innerHTML = "";
                        pagination.innerHTML = "";

                        let totalMatched = 0;

                        for (let i = 0; i < categories.length; i++) {
                            const category = categories[i];

                            let categoryProducts = products.filter(function (product) {
                                const matchCategory = product.category === category;
                                const matchName = product.name.toLowerCase().includes(keyword);
                                return matchCategory && matchName;
                            });

                            categoryProducts = getSortedProducts(categoryProducts);

                            if (categoryProducts.length === 0) {
                                continue;
                            }

                            totalMatched += categoryProducts.length;

                            const showProducts = categoryProducts.slice(0, itemsPerCategoryHome);

                            let sectionHtml = '' +
                                    '<div class="category-section" id="section-' + i + '">' +
                                    '<div class="category-section-banner">' +
                                    '<div>' +
                                    '<h2>' + category + '</h2>' +
                                    '<p>' + getCategoryDescription(category) + '</p>' +
                                    '</div>' +
                                    '<button type="button" class="view-all-btn" onclick="showCategoryFromBanner(\'' + category + '\')">' +
                                    'Xem tất cả <i class="fa fa-angle-right ms-1"></i>' +
                                    '</button>' +
                                    '</div>' +
                                    '<div class="row">';

                            for (let j = 0; j < showProducts.length; j++) {
                                sectionHtml += createProductCard(showProducts[j]);
                            }

                            sectionHtml +=
                                    '</div>' +
                                    '</div>';

                            productList.innerHTML += sectionHtml;
                        }

                        productCount.innerText = totalMatched + " sản phẩm";

                        if (totalMatched === 0) {
                            noDataMessage.classList.remove("d-none");
                        } else {
                            noDataMessage.classList.add("d-none");
                        }
                    }

                    function renderSingleCategory() {
                        const filteredProducts = getProductsBySearchAndCategory();

                        const startIndex = (currentPage - 1) * itemsPerPage;
                        const endIndex = startIndex + itemsPerPage;
                        const pageProducts = filteredProducts.slice(startIndex, endIndex);

                        productList.innerHTML = "";
                        productCount.innerText = filteredProducts.length + " sản phẩm";

                        if (pageProducts.length === 0) {
                            noDataMessage.classList.remove("d-none");
                        } else {
                            noDataMessage.classList.add("d-none");
                        }

                        let html = '' +
                                '<div class="category-section">' +
                                '<div class="category-section-banner">' +
                                '<div>' +
                                '<h2>' + currentCategory + '</h2>' +
                                '<p>' + getCategoryDescription(currentCategory) + '</p>' +
                                '</div>' +
                                '</div>' +
                                '<div class="row">';

                        for (let i = 0; i < pageProducts.length; i++) {
                            html += createProductCard(pageProducts[i]);
                        }

                        html +=
                                '</div>' +
                                '</div>';

                        productList.innerHTML = html;

                        renderPagination(filteredProducts.length);
                    }

                    function renderProducts() {
                        if (currentCategory === "all") {
                            renderAllCategories();
                        } else {
                            renderSingleCategory();
                        }
                    }

                    function selectCategory(category, button) {
                        currentCategory = category;
                        currentPage = 1;

                        const buttons = document.querySelectorAll(".category-pill");
                        for (let i = 0; i < buttons.length; i++) {
                            buttons[i].classList.remove("active");
                        }

                        button.classList.add("active");
                        renderProducts();
                    }

                    function showCategoryFromBanner(category) {
                        currentCategory = category;
                        currentPage = 1;

                        const buttons = document.querySelectorAll(".category-pill");

                        for (let i = 0; i < buttons.length; i++) {
                            buttons[i].classList.remove("active");

                            if (buttons[i].innerText.indexOf(category) !== -1) {
                                buttons[i].classList.add("active");
                            }
                        }

                        renderProducts();

                        window.scrollTo({
                            top: 180,
                            behavior: "smooth"
                        });
                    }

                    function getCategoryDescription(category) {
                        if (category === "Bánh Flan Gato") {
                            return "Flan Gato - sự kết hợp hoàn hảo giữa flan nướng mịn và cốt gato chocolate.";
                        }

                        if (category === "Bánh Entremet") {
                            return "Dòng bánh nhiều lớp tinh tế, mềm mịn và sang trọng.";
                        }

                        if (category === "Bánh Kem Bắp") {
                            return "Bánh kem bắp thơm nhẹ, ít ngọt, phù hợp mọi dịp.";
                        }

                        if (category === "Bánh Mousse") {
                            return "Mousse mềm mịn, vị trái cây tươi mát và dễ ăn.";
                        }

                        if (category === "Sweetbox Premium") {
                            return "Hộp bánh cao cấp, thích hợp làm quà tặng.";
                        }

                        if (category === "Sweetbox") {
                            return "Những hộp bánh nhỏ xinh cho các buổi tiệc nhẹ.";
                        }

                        if (category === "Sweetin") {
                            return "Các món bánh nhỏ dùng kèm trà hoặc cà phê.";
                        }

                        if (category === "Bánh Healthy") {
                            return "Lựa chọn ít ngọt, nhẹ nhàng và cân bằng hơn.";
                        }

                        return "Những lựa chọn bánh thủ công dành cho bạn.";
                    }

                    function renderPagination(totalItems) {
                        const totalPages = Math.ceil(totalItems / itemsPerPage);
                        pagination.innerHTML = "";

                        if (totalPages <= 1) {
                            return;
                        }

                        pagination.innerHTML +=
                                '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
                                '<a class="page-link" href="#" onclick="changePage(' + (currentPage - 1) + ')">Trước</a>' +
                                '</li>';

                        for (let i = 1; i <= totalPages; i++) {
                            pagination.innerHTML +=
                                    '<li class="page-item ' + (currentPage === i ? 'active' : '') + '">' +
                                    '<a class="page-link" href="#" onclick="changePage(' + i + ')">' + i + '</a>' +
                                    '</li>';
                        }

                        pagination.innerHTML +=
                                '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
                                '<a class="page-link" href="#" onclick="changePage(' + (currentPage + 1) + ')">Sau</a>' +
                                '</li>';
                    }

                    function changePage(page) {
                        const totalPages = Math.ceil(getProductsBySearchAndCategory().length / itemsPerPage);

                        if (page < 1 || page > totalPages) {
                            return;
                        }

                        currentPage = page;
                        renderProducts();
                    }

                    searchInput.addEventListener("input", function () {
                        currentPage = 1;
                        renderProducts();
                    });

                    sortSelect.addEventListener("change", function () {
                        currentPage = 1;
                        renderProducts();
                    });

                    renderProducts();
        </script>

    </body>
</html>