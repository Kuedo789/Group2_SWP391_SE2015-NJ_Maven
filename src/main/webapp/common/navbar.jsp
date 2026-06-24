<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.User" %>

<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");
    
// FETCH DYNAMIC CART COUNT: Fallback gracefully to 0 if not initialized yet
    Integer sessionCartCount = (Integer) session.getAttribute("cartCount");
    int cartCount = (sessionCartCount != null) ? sessionCartCount : 0;
%>

<nav class="navbar">
    <div class="navbar-inner">

        <!-- Logo -->
        <a href="<%= contextPath %>/home" class="logo">
            BakeryZone
        </a>

        <!-- Menu chính -->
        <div class="nav-menu">
            <a href="<%= request.getContextPath() %>/home">Trang Chủ</a>
            <a href="<%= request.getContextPath() %>/products">Menu bánh</a>
            <a href="#">Thiết kế bánh</a>
            <a href="#">Về chúng tôi</a>
            <a href="#">Liên hệ</a>
        </div>

        <!-- Icons bên phải -->
        <div class="nav-icons">

            <!-- Search -->
            <form action="<%= contextPath %>/products" method="get" class="nav-search-form">
                <input
                    type="text"
                    name="search"
                    placeholder="Tìm bánh..."
                    class="nav-search-input">

                <button type="submit" class="nav-search-btn" title="Tìm kiếm">
                    <span class="material-symbols-outlined">search</span>
                </button>
            </form>

            <!-- Cart -->
            <button type="button" title="Giỏ hàng" onclick="window.location.href = '${pageContext.request.contextPath}/cart'">
                <span class="material-symbols-outlined">shopping_cart</span>
                <%-- Floating count badge tag removed for a clean layout look --%>
            </button>

            <!-- User dropdown -->
            <div class="user-dropdown">

                <% if (currentUser == null) { %>

                <!-- Chưa đăng nhập -->
                <a href="<%= contextPath %>/login"
                   class="btn btn-primary">
                    Đăng nhập
                </a>

                <% } else { %>

                <!-- Đã đăng nhập -->
                <button type="button" class="user-dropdown-btn" id="userDropdownBtn" title="Tài khoản">
                    <span class="material-symbols-outlined">account_circle</span>
                </button>

                <div class="user-dropdown-menu" id="userDropdownMenu">

                    <!-- Header user -->
                    <div class="user-dropdown-header">
                        <div class="user-dropdown-avatar">
                            <span class="material-symbols-outlined">account_circle</span>
                        </div>

                        <div class="user-dropdown-info">
                            <div class="user-dropdown-hello">Xin chào,</div>
                            <div class="user-dropdown-fullname">
                                <%= currentUser.getFullName() %>                         
                            </div>
                        </div>
                    </div>
                    <div class="user-dropdown-item">
                        <span class="material-symbols-outlined">
                            leaderboard
                        </span>
                        <%= currentUser.getRoleName() != null ? currentUser.getRoleName() : currentUser.getRoleId() %>
                    </div>
                    <div class="user-dropdown-divider"></div>

                    <!-- Profile -->
                    <a href="<%= contextPath %>/profile" class="user-dropdown-item">
                        <span class="material-symbols-outlined">person</span>
                        <span>Hồ sơ cá nhân</span>
                    </a>

                    <!-- Orders -->
                    <a href="<%= contextPath %>/OrderList" class="user-dropdown-item">
                        <span class="material-symbols-outlined">receipt_long</span>
                        <span>Xem đơn hàng</span>
                    </a>

                    <!-- My designs -->
                    <a href="<%= contextPath %>/my-designs" class="user-dropdown-item">
                        <span class="material-symbols-outlined">cake</span>
                        <span>Thiết kế của tôi</span>
                    </a>

                    <div class="user-dropdown-divider"></div>

                    <!-- Logout -->
                    <a href="<%= contextPath %>/logout" class="user-dropdown-item logout-item">
                        <span class="material-symbols-outlined">logout</span>
                        <span>Đăng xuất</span>
                    </a>

                </div>

                <% } %>

            </div>
        </div>
    </div>
</nav>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        // Handle search form validation
        const navSearchForm = document.getElementById("navSearchForm");
        if (navSearchForm) {
            navSearchForm.addEventListener("submit", function (event) {
                const input = navSearchForm.querySelector("input[name='search']");
                const keyword = input ? input.value.trim() : "";
                if (keyword.length === 0) {
                    event.preventDefault();
                    if (input) {
                        input.focus();
                    }
                }
            });
        }

        // Update cart badge from localStorage
        const updateCartCount = () => {
            const countEl = document.getElementById("navCartCount");
            if (countEl) {
                try {
                    const cartStr = localStorage.getItem("cart");
                    if (cartStr) {
                        const cart = JSON.parse(cartStr);
                        if (Array.isArray(cart)) {
                            let totalQty = 0;
                            cart.forEach(item => {
                                if (item)
                                    totalQty += (parseInt(item.qty) || 1);
                            });
                            countEl.innerText = totalQty;
                        } else {
                            countEl.innerText = "0";
                        }
                    } else {
                        countEl.innerText = "0";
                    }
                } catch (e) {
                    countEl.innerText = "0";
                }
            }
        };

        updateCartCount();
        // Listen to storage events to keep it synchronized across tabs
        window.addEventListener("storage", updateCartCount);
    });
</script>