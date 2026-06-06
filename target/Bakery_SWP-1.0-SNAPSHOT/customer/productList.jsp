<%-- 
    Document   : productList
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <style>
            /* ===== PRODUCT LIST PAGE ===== */

            .page-section {
                max-width: 1420px;
                margin: 0 auto;
                padding: 22px 42px 80px;
            }

            /* ===== SEARCH + SORT ===== */

            .filter-row {
                display: grid;
                grid-template-columns: minmax(0, 1fr) 150px;
                gap: 12px;
                align-items: center;
                margin-bottom: 24px;
            }

            .product-search-box {
                position: relative;
                width: 100%;
            }

            .product-search-box i {
                position: absolute;
                top: 50%;
                left: 18px;
                transform: translateY(-50%);
                color: var(--text-muted);
                font-size: 15px;
            }

            .product-search-box input {
                width: 100%;
                height: 50px;
                border: 1px solid var(--border);
                border-radius: 15px;
                background-color: var(--white);
                color: var(--text);
                font-size: 15px;
                padding: 0 18px 0 48px;
                outline: none;
                box-sizing: border-box;
            }

            .sort-select {
                width: 150px;
                height: 50px;
                border: 1px solid var(--border);
                border-radius: 15px;
                background-color: var(--white);
                color: var(--text);
                font-size: 15px;
                padding: 0 14px;
                outline: none;
                cursor: pointer;
                box-sizing: border-box;
            }

            .product-search-box input:focus,
            .sort-select:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(21, 92, 46, 0.1);
            }

            /* ===== CATEGORY FILTER ===== */

            .category-list {
                display: flex;
                gap: 10px;
                overflow-x: auto;
                padding-bottom: 6px;
                margin-bottom: 28px;
            }

            .category-list::-webkit-scrollbar {
                height: 0;
            }

            .category-pill {
                height: 40px;
                border: none;
                border-radius: 999px;
                padding: 0 20px;
                background-color: #f0ede6;
                color: var(--text);
                font-size: 14px;
                font-weight: 500;
                white-space: nowrap;
                cursor: pointer;
            }

            .category-pill span {
                color: var(--text-muted);
                font-size: 12px;
                font-weight: 400;
                margin-left: 4px;
            }

            .category-pill.active {
                background-color: var(--primary);
                color: white;
                font-weight: 700;
            }

            .category-pill.active span {
                color: #e8f1e5;
            }

            /* ===== TOP ROW ===== */

            .product-top-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin: 30px 0 18px;
            }

            .product-count {
                margin: 0;
                color: var(--text-muted);
                font-size: 16px;
                font-weight: 400;
            }

            .voucher-link {
                color: var(--primary);
                font-size: 14px;
                font-weight: 600;
                text-decoration: none;
            }

            .voucher-link:hover {
                text-decoration: underline;
            }

            /* ===== CATEGORY SECTION ===== */

            .category-section {
                margin-bottom: 46px;
            }

            .category-section-banner {
                min-height: 135px;
                border-radius: 22px;
                padding: 30px;
                margin-bottom: 18px;
                background-color: var(--primary);
                color: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 18px;
            }

            .category-section-banner h2 {
                margin: 0 0 10px;
                color: white;
                font-size: 28px;
                font-weight: 700;
            }

            .category-section-banner p {
                margin: 0;
                color: rgba(255, 255, 255, 0.88);
                font-size: 15px;
                line-height: 1.6;
            }

            .view-all-btn {
                min-width: 110px;
                height: 40px;
                border: none;
                border-radius: 999px;
                background-color: rgba(255, 255, 255, 0.18);
                color: white;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
            }

            .view-all-btn:hover {
                background-color: rgba(255, 255, 255, 0.28);
            }

            /* ===== PRODUCT GRID ===== */

            #productList .row {
                display: grid;
                grid-template-columns: repeat(4, minmax(0, 1fr));
                gap: 24px;
                margin: 0;
            }

            #productList .col-lg-3,
            #productList .col-md-6 {
                width: 100%;
                padding: 0;
                margin: 0;
            }

            /* ===== PRODUCT CARD ===== */

            .cake-card {
                height: 100%;
                min-height: 385px;
                background-color: var(--white);
                border-radius: 18px;
                overflow: hidden;
                box-shadow: var(--shadow);
                position: relative;
                cursor: pointer;
                transition: 0.2s ease;
            }

            .cake-card:hover {
                transform: translateY(-4px);
            }

            .cake-img {
                width: 100%;
                height: 230px;
                object-fit: cover;
                display: block;
            }

            .cake-body {
                padding: 16px 18px 20px;
            }

            .cake-name {
                min-height: 40px;
                margin-bottom: 6px;
                color: var(--text);
                font-size: 16px;
                font-weight: 700;
                line-height: 1.35;
            }

            .cake-desc {
                min-height: 44px;
                margin-bottom: 12px;
                color: var(--text-muted);
                font-size: 14px;
                line-height: 1.45;
            }

            .cake-price {
                color: var(--primary);
                font-size: 18px;
                font-weight: 700;
            }

            .featured-badge {
                position: absolute;
                top: 14px;
                left: 14px;
                z-index: 2;
                background-color: var(--primary);
                color: white;
                border-radius: 999px;
                padding: 6px 14px;
                font-size: 13px;
                font-weight: 700;
            }

            /* ===== NO DATA ===== */

            .no-data {
                display: none;
                text-align: center;
                padding: 50px 0;
                color: var(--text-muted);
            }

            .no-data.show {
                display: block;
            }

            /* ===== PAGINATION ===== */

            .pagination {
                display: flex;
                justify-content: center;
                gap: 8px;
                padding-left: 0;
                margin-top: 45px;
                list-style: none;
            }

            .page-item {
                list-style: none;
            }

            .page-link {
                display: block;
                padding: 9px 14px;
                border: 1px solid var(--border);
                border-radius: 10px;
                background-color: var(--white);
                color: var(--primary);
                text-decoration: none;
            }

            .page-item.active .page-link {
                background-color: var(--primary);
                border-color: var(--primary);
                color: white;
            }

            .page-item.disabled .page-link {
                opacity: 0.45;
                pointer-events: none;
            }

            /* ===== RESPONSIVE ===== */

            @media (max-width: 1200px) {
                #productList .row {
                    grid-template-columns: repeat(3, minmax(0, 1fr));
                }
            }

            @media (max-width: 768px) {
                .page-section {
                    padding: 22px 20px 70px;
                }

                .filter-row {
                    grid-template-columns: 1fr;
                }

                .sort-select {
                    width: 100%;
                }

                .product-top-row {
                    flex-direction: column;
                    align-items: flex-start;
                    gap: 10px;
                }

                .category-section-banner {
                    flex-direction: column;
                    align-items: flex-start;
                }

                #productList .row {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 520px) {
                .page-section {
                    padding: 20px 18px 60px;
                }

                #productList .row {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>

    <body>

        <!-- Navbar -->
        <jsp:include page="../common/navbar.jsp" />
        <main class="main">
            <!-- Page Content -->
            <div class="page-section">

                <!-- Search and Sort -->
                <div class="filter-row">
                    <div class="product-search-box">
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
                    <button class="category-pill active" onclick="selectCategory('all', this)">Tất cả <span id="allProductCount">0</span></button>
                    <button class="category-pill" onclick="selectCategory('Bánh Flan Gato', this)">Bánh Flan Gato <span>3</span></button>
                    <button class="category-pill" onclick="selectCategory('Bánh Entremet', this)">Bánh Entremet <span>2</span></button>
                    <button class="category-pill" onclick="selectCategory('Bánh Kem Bắp', this)">Bánh Kem Bắp <span>2</span></button>
                    <button class="category-pill" onclick="selectCategory('Bánh Mousse', this)">Bánh Mousse <span>3</span></button>
                    <button class="category-pill" onclick="selectCategory('Sweetbox Premium', this)">Sweetbox Premium <span>1</span></button>
                    <button class="category-pill" onclick="selectCategory('Sweetbox', this)">Sweetbox <span>1</span></button>
                    <button class="category-pill" onclick="selectCategory('Sweetin', this)">Sweetin <span>1</span></button>
                    <button class="category-pill" onclick="selectCategory('Bánh Healthy', this)">Bánh Healthy <span>1</span></button>
                </div>

                <div class="product-top-row">
                    <div class="product-count" id="productCount">0 sản phẩm</div>

                    <a href="<%= request.getContextPath() %>/auth/login.jsp" class="voucher-link">
                        Đăng nhập xem voucher ưu đãi của bạn
                    </a>
                </div>

                <!-- Product List -->
                <div id="productList"></div>

                <div id="noDataMessage" class="no-data">
                    <i class="fa fa-box-open fa-2x mb-3"></i>
                    <p>Không tìm thấy sản phẩm phù hợp.</p>
                </div>

                <!-- Pagination chỉ dùng khi xem riêng 1 danh mục -->
                <nav>
                    <ul class="pagination justify-content-center mt-5" id="pagination"></ul>
                </nav>

            </div>
        </main>
        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

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
            const allProductCount = document.getElementById("allProductCount");

            if (allProductCount) {
                allProductCount.innerText = products.length;
            }
            function formatPrice(price) {
                return price.toLocaleString("vi-VN") + ".000đ";
            }

            function matchProductName(productName, keyword) {
                if (keyword === "") {
                    return true;
                }

                const words = productName.toLowerCase().split(" ");

                return words.some(function (word) {
                    return word.startsWith(keyword);
                });
            }

            function createProductCard(product) {
                let badge = "";

                if (product.featured) {
                    badge = '<div class="featured-badge">Nổi bật</div>';
                }

                return '' +
                        '<div class="col-lg-3 col-md-6 mb-4">' +
                        '<div class="cake-card" onclick="goToProductDetail(' + product.id + ')">' +
                        badge +
                        '<img src="' + product.image + '" class="cake-img" alt="' + product.name + '">' +
                        '<div class="cake-body">' +
                        '<div class="cake-name">' + product.name + '</div>' +
                        '<div class="cake-desc">' + product.desc + '</div>' +
                        '<div class="cake-price">' + formatPrice(product.price) + '</div>' +
                        '</div>' +
                        '</div>' +
                        '</div>';
            }

            function goToProductDetail(productId) {
                window.location.href = contextPath + "/customer/productDetail.jsp?id=" + productId;
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
                    const matchName = matchProductName(product.name, keyword);
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
                        const matchName = matchProductName(product.name, keyword);
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
                    noDataMessage.classList.add("show");
                } else {
                    noDataMessage.classList.remove("show");
                }
            }

            function renderSingleCategory() {
                const filteredProducts = getProductsBySearchAndCategory();

                const startIndex = (currentPage - 1) * itemsPerPage;
                const endIndex = startIndex + itemsPerPage;
                const pageProducts = filteredProducts.slice(startIndex, endIndex);

                productList.innerHTML = "";
                productCount.innerText = filteredProducts.length + " sản phẩm";

                if (filteredProducts.length === 0) {
                    noDataMessage.classList.add("show");
                } else {
                    noDataMessage.classList.remove("show");
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