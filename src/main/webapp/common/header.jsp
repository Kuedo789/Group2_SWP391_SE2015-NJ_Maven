<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
            dbSettings.put("shippingRate", "5000");
            dbSettings.put("depositPercent", "30");
            dbSettings.put("banner1", "assets/images/banner1.jpg");
            dbSettings.put("banner2", "assets/images/banner2.jpg");
            dbSettings.put("banner3", "assets/images/banner3.jpg");
            dbSettings.put("heroTitle", "Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc");
            dbSettings.put("heroSubtitle", "Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng được làm thủ công từ nguyên liệu tự nhiên.");
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
<title>${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}</title>
<script>
    (function() {
        var isDarkMode = ${not empty settings.darkMode ? settings.darkMode : 'false'};
        if (isDarkMode) {
            document.documentElement.classList.add('dark-theme');
        }
    })();
</script>
<link href="https://fonts.googleapis.com/css2?family=Bodoni+Moda:ital,wght@0,400..900;1,400..900&amp;family=Plus+Jakarta+Sans:ital,wght@0,200..800;1,200..800&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
<style>
    /* Force Toastify text visibility and design consistency */
    .toastify {
        color: #ffffff !important;
        font-weight: 500 !important;
        font-size: 14px !important;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15) !important;
        border-radius: 8px !important;
        padding: 12px 24px !important;
    }
</style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all/style.css?v=1.1">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/all/order.css">