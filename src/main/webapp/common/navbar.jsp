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
            ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}
        </a>

        <!-- Menu chính -->
        <div class="nav-menu" style="gap: 35px; margin: 0 auto;">
            <a href="<%= request.getContextPath() %>/home">Trang Chủ</a>
            <a href="<%= request.getContextPath() %>/products">Menu bánh</a>
            <a href="<%= request.getContextPath() %>/custom-cake">Thiết kế bánh</a>
            <a href="<%= request.getContextPath() %>/blog">Tin tức</a>
            <% if (currentUser != null && "CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) { %>
            <a href="<%= contextPath %>/membership"
               class="nav-menu-membership-link">Thành viên</a>
            <% } %>

        </div>

        <!-- Main Right-Side Wrapper: Enforces horizontal alignment and prevents item collapse -->
        <div class="navbar-right-container" style="display: flex; align-items: center; gap: 24px;">

            <!-- 1. Search Box Container -->
            <div class="search-box-wrapper">
                <form id="navSearchForm" action="<%= contextPath %>/products" method="get" class="nav-search-form">
                    <input type="text" name="search" placeholder="Tìm bánh..." class="nav-search-input">
                    <button type="submit" class="nav-search-btn" title="Tìm kiếm">
                        <span class="material-symbols-outlined">search</span>
                    </button>
                </form>
            </div>

            <% if (currentUser == null || "CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) { %>
            <!-- 2. Cart Icon Container (clean, no badge, no clipping) -->
            <div class="cart-icon-wrapper">
                <a href="<%= contextPath %>/cart" class="cart-link">
                    <span class="material-symbols-outlined">shopping_cart</span>
                </a>
            </div>
            <% } %>

            <!-- 3. User Profile Section -->
            <% if (currentUser == null) { %>

                <a href="<%= contextPath %>/login" class="btn btn-primary">Đăng nhập</a>

            <% } else { %>

                <!-- Avatar on the left, username on the right, dropdown menu below -->
                <div class="user-dropdown">
                    <button type="button" class="user-dropdown-btn" id="userDropdownBtn" title="Tài khoản"
                            style="display: flex; align-items: center; border: none; background: transparent; cursor: pointer; padding: 0;">
                        <div class="avatar-container" style="display: flex; align-items: center; line-height: 1;">
                            <span class="material-symbols-outlined" style="font-size: 28px; color: inherit;">account_circle</span>
                        </div>
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
                        <div class="user-dropdown-item-static">
                            <span class="material-symbols-outlined">leaderboard</span>
                            <%= currentUser.getRoleName() != null ? currentUser.getRoleName() : currentUser.getRoleId() %>
                        </div>
                        <div class="user-dropdown-divider"></div>
                        <a href="<%= contextPath %>/profile" class="user-dropdown-item">
                            <span class="material-symbols-outlined">person</span>
                            <span>Hồ sơ cá nhân</span>
                        </a>
                        <% if ("CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) { %>
                        <a href="<%= contextPath %>/OrderList" class="user-dropdown-item">
                            <span class="material-symbols-outlined">receipt_long</span>
                            <span>Xem đơn hàng</span>
                        </a>

                        <a href="<%= contextPath %>/membership" class="user-dropdown-item">
                            <span class="material-symbols-outlined">workspace_premium</span>
                            <span>Xem hạng của bạn</span>
                        </a>
                        <a href="<%= contextPath %>/membership#voucher-wallet" class="user-dropdown-item">
                            <span class="material-symbols-outlined">local_activity</span>
                            <span>Ví Voucher</span>
                        </a>
                        <% } else { %>
                        <a href="<%= "ADMIN".equalsIgnoreCase(currentUser.getRoleId()) ? (contextPath + "/admin/dashboard") : 
                                    ("SHIPPER".equalsIgnoreCase(currentUser.getRoleId()) ? (contextPath + "/shipper/orders?action=list") : 
                                    (contextPath + "/admin/orders?action=list")) %>" class="user-dropdown-item" style="color: var(--primary);">
                            <span class="material-symbols-outlined">dashboard</span>
                            <span>Vào trang quản lý</span>
                        </a>
                        <% } %>
                        <div class="user-dropdown-divider"></div>
                        <div class="user-dropdown-item" id="darkModeToggleItem" style="cursor: pointer; justify-content: space-between;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span class="material-symbols-outlined">dark_mode</span>
                                <span>Giao diện tối</span>
                            </div>
                            <div class="theme-toggle-switch">
                                <input type="checkbox" id="darkModeCheckbox" style="pointer-events: none;">
                                <span class="theme-slider"></span>
                            </div>
                        </div>
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
<style>
    .theme-toggle-switch {
        position: relative;
        display: inline-block;
        width: 36px;
        height: 20px;
    }
    .theme-toggle-switch input { 
        opacity: 0;
        width: 0;
        height: 0;
    }
    .theme-slider {
        position: absolute;
        cursor: pointer;
        top: 0; left: 0; right: 0; bottom: 0;
        background-color: #ccc;
        transition: .4s;
        border-radius: 20px;
    }
    .theme-slider:before {
        position: absolute;
        content: "";
        height: 14px;
        width: 14px;
        left: 3px;
        bottom: 3px;
        background-color: white;
        transition: .4s;
        border-radius: 50%;
    }
    input:checked + .theme-slider {
        background-color: #345f3d;
    }
    input:checked + .theme-slider:before {
        transform: translateX(16px);
    }
</style>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const toggleItem = document.getElementById("darkModeToggleItem");
        const checkbox = document.getElementById("darkModeCheckbox");
        
        if (toggleItem && checkbox) {
            // Check state
            const isDark = localStorage.getItem('theme') === 'dark';
            checkbox.checked = isDark;
            
            toggleItem.addEventListener("click", function(e) {
                e.stopPropagation(); // Keep dropdown open
                
                const currentState = document.documentElement.classList.contains('dark-theme');
                if (currentState) {
                    document.documentElement.classList.remove('dark-theme');
                    localStorage.setItem('theme', 'light');
                    checkbox.checked = false;
                } else {
                    document.documentElement.classList.add('dark-theme');
                    localStorage.setItem('theme', 'dark');
                    checkbox.checked = true;
                }
            });
        }
    });
</script>