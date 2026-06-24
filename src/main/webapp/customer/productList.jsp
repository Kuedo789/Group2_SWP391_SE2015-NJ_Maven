<%-- 
    Document   : productList
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/productList.css">
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
                        <input type="text" id="searchInput" placeholder="Tìm bánh, đồ uống..."
                         value="${not empty param.search ? param.search : ''}">
                    </div>

                    <select id="sortSelect" class="sort-select">
                        <option value="default">Mặc định</option>
                        <option value="priceAsc">Giá tăng</option>
                        <option value="priceDesc">Giá giảm</option>
                    </select>
                </div>

                <!-- Categories -->
                <div class="category-list" id="categoryList">
                    <button class="category-pill active" onclick="selectCategory('all', this)">
                        Tất cả <span id="allProductCount">0</span>
                    </button>
                    <!-- Category pills will be rendered dynamically by JS -->
                </div>

                <div class="product-top-row">
                    <div class="product-count" id="productCount">0 sản phẩm</div>

                    <a href="${pageContext.request.contextPath}/auth/login.jsp" class="voucher-link">
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
            const contextPath = "${pageContext.request.contextPath}";

            const products = ${requestScope.productsJson};
            const categories = ${requestScope.categoriesJson};
            
            // Render category pills dynamically based on data
            function renderCategoryPills() {
                const categoryListDiv = document.getElementById("categoryList");
                let html = '<button class="category-pill active" onclick="selectCategory(\'all\', this)">' +
                           'Tất cả <span id="allProductCount">' + products.length + '</span></button>';
                
                for (let i = 0; i < categories.length; i++) {
                    const categoryName = categories[i];
                    let count = 0;
                    for (let j = 0; j < products.length; j++) {
                        if (products[j].category === categoryName) {
                            count++;
                        }
                    }
                    html += '<button class="category-pill" onclick="selectCategory(\'' + categoryName.replace(/'/g, "\\'") + '\', this)">' +
                            categoryName + ' <span>' + count + '</span></button>';
                }
                categoryListDiv.innerHTML = html;
            }
            
            renderCategoryPills();

            let currentCategory = "${not empty param.category ? param.category : 'all'}";
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
                return price.toLocaleString("vi-VN") + " đ";
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
                        '<div class="cake-card" onclick="goToProductDetail(\'' + product.id + '\')">' +
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

            function goToProductDetail(id) {
                window.location.href = contextPath + "/product-detail?id=" + id;
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