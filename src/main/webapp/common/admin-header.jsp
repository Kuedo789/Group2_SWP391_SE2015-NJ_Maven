<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (application.getAttribute("settings") == null) {
        com.bakeryzone.dao.SettingDAO settingDAO = new com.bakeryzone.dao.SettingDAO();
        java.util.Map<String, Object> dbSettings = settingDAO.getSettings();
        if (dbSettings == null || dbSettings.isEmpty()) {
            dbSettings = new java.util.HashMap<>();
            dbSettings.put("bakeryName", "BakeryZone");
            dbSettings.put("hotline", "0901234567");
            dbSettings.put("email", "support@bakeryzone.vn");
            dbSettings.put("address", "123 Đường Sourdough, TP. Hồ Chí Minh");
            dbSettings.put("announcement", "Chào mừng bạn đến với BakeryZone - Thế giới bánh ngọt tinh tế!");
            dbSettings.put("banner1", "assets/images/banner1.jpg");
            dbSettings.put("banner2", "assets/images/banner2.jpg");
            dbSettings.put("banner3", "assets/images/banner3.jpg");
            dbSettings.put("banner4", "assets/images/hero/hero-4.jpg");
            dbSettings.put("darkMode", false);
        } else {
            String currentHotline = (String) dbSettings.get("hotline");
            if (currentHotline != null) {
                dbSettings.put("hotline", currentHotline.replaceAll("\\s+", ""));
            }
        }
        application.setAttribute("settings", dbSettings);
    }
%>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${not empty param.title ? param.title : (not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone Admin')}</title>

<!-- Dark Mode Init Script (Runs before render to prevent white flash) -->
<script>
    (function() {
        var globalDark = ${not empty settings.darkMode ? settings.darkMode : 'false'};
        var saved = localStorage.getItem('darkMode');
        if (globalDark || saved === 'true') {
            document.documentElement.classList.add('dark-theme');
        }
    })();
</script>

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700;800&display=swap" rel="stylesheet">

<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- FontAwesome Icons -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/v4-shims.min.css" rel="stylesheet">

<!-- Toastify CSS -->
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

<!-- Global Admin CSS -->
<link href="${pageContext.request.contextPath}/assets/css/all/admin-global.css?v=1.5" rel="stylesheet">
