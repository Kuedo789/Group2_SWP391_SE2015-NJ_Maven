<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bakeryzone.model.User" %>
<%@ page import="com.bakeryzone.dao.MembershipDAO" %>
<%@ page import="com.bakeryzone.model.UserMembership" %>

<%
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("user");

    // FETCH DYNAMIC CART COUNT: Fallback gracefully to 0 if not initialized yet
    Integer sessionCartCount = (Integer) session.getAttribute("cartCount");
    int cartCount = (sessionCartCount != null) ? sessionCartCount : 0;

    // FETCH MEMBERSHIP TIER: lightweight single-query lookup for the navbar chip.
    // Only runs when a user is logged in. Cached per-request; no session write.
    String navTierName   = null;  // e.g. "SILVER" – null = not loaded or guest
    String navTierClass  = "";    // CSS modifier for chip colour
    if (currentUser != null) {
        try {
            MembershipDAO _mDao = new MembershipDAO();
            UserMembership _um  = _mDao.getMembershipByUserId(currentUser.getUserId());
            if (_um != null && _um.getCurrentTier() != null) {
                navTierName  = _um.getCurrentTier().getTierName();
                navTierClass = "nav-tier-chip--" + navTierName.toLowerCase();
            }
        } catch (Exception _e) {
            // Silently swallow – tier chip is decorative, never block the navbar
        }
    }
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
            <a href="<%= request.getContextPath() %>/custom-cake">Thiết kế bánh</a>
            <% if (currentUser != null) { %>
            <a href="<%= contextPath %>/membership"
               class="nav-menu-membership-link">Thành viên</a>
            <% } %>

        </div>

        <!-- Main Right-Side Wrapper: Enforces horizontal alignment and prevents item collapse -->
        <div class="navbar-right-container">

            <!-- 1. Search Box Container -->
            <div class="search-box-wrapper">
                <form id="navSearchForm" action="<%= contextPath %>/products" method="get" class="nav-search-form">
                    <input type="text" name="search" placeholder="Tìm bánh..." class="nav-search-input">
                    <button type="submit" class="nav-search-btn" title="Tìm kiếm">
                        <span class="material-symbols-outlined">search</span>
                    </button>
                </form>
            </div>

            <!-- 2. Cart Icon Container (clean, no badge, no clipping) -->
            <div class="cart-icon-wrapper">
                <a href="<%= contextPath %>/cart" class="cart-link">
                    <span class="material-symbols-outlined">shopping_cart</span>
                </a>
            </div>

            <!-- 3. User Profile Section -->
            <% if (currentUser == null) { %>

                <a href="<%= contextPath %>/login" class="btn btn-primary">Đăng nhập</a>

            <% } else { %>

                <!-- Avatar on the left, username on the right, dropdown menu below -->
                <div class="user-dropdown">
                    <button type="button" class="user-dropdown-btn" id="userDropdownBtn" title="Tài khoản">
                        <div class="avatar-container">
                            <span class="material-symbols-outlined">account_circle</span>
                        </div>
                        <span class="navbar-username">
                            <%= currentUser.getFullName() %>
                        </span>
                    </button>

                    <div class="user-dropdown-menu" id="userDropdownMenu">
                        <div class="user-dropdown-header">
                            <div class="user-dropdown-avatar">
                                <span class="material-symbols-outlined">account_circle</span>
                            </div>
                            <div class="user-dropdown-info">
                                <div class="user-dropdown-hello">Xin chào,</div>
                                <div class="user-dropdown-identity">
                                    <span class="user-dropdown-fullname"><%= currentUser.getFullName() %></span>
                                    <% if (navTierName != null) { %>
                                    <span class="nav-tier-chip <%= navTierClass %>"><%= navTierName %></span>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <div class="user-dropdown-item">
                            <span class="material-symbols-outlined">leaderboard</span>
                            <%= currentUser.getRoleName() != null ? currentUser.getRoleName() : currentUser.getRoleId() %>
                        </div>
                        <div class="user-dropdown-divider"></div>
                        <a href="<%= contextPath %>/profile" class="user-dropdown-item">
                            <span class="material-symbols-outlined">person</span>
                            <span>Hồ sơ cá nhân</span>
                        </a>
                        <a href="<%= contextPath %>/OrderList" class="user-dropdown-item">
                            <span class="material-symbols-outlined">receipt_long</span>
                            <span>Xem đơn hàng</span>
                        </a>
                        <a href="<%= contextPath %>/membership" class="user-dropdown-item">
                            <span class="material-symbols-outlined">workspace_premium</span>
                            <span>Xem hạng của bạn</span>
                        </a>
                        <a href="<%= contextPath %>/my-designs" class="user-dropdown-item">
                            <span class="material-symbols-outlined">cake</span>
                            <span>Thiết kế của tôi</span>
                        </a>
                        <div class="user-dropdown-divider"></div>
                        <a href="<%= contextPath %>/logout" class="user-dropdown-item logout-item">
                            <span class="material-symbols-outlined">logout</span>
                            <span>Đăng xuất</span>
                        </a>
                    </div>
                </div>

            <% } %>

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
    });
</script>