package com.bakeryzone.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.bakeryzone.dao.SettingDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "AdminSettingsServlet", urlPatterns = { "/admin/settings" })
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class AdminSettingsServlet extends HttpServlet {

    private static final String SETTINGS_ATTR = "settings";
    private final SettingDAO settingDAO = new SettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy cấu hình từ Cơ sở dữ liệu
        Map<String, Object> settings = settingDAO.getSettings();
        if (settings.isEmpty()) {
            settings = initDefaultSettings();
            // Nếu trống, lưu cấu hình mặc định vào cơ sở dữ liệu
            settingDAO.updateSettings(settings);
        } else {
            // Làm sạch khoảng trắng hotline không hợp lệ cũ nếu có
            String currentHotline = (String) settings.get("hotline");
            if (currentHotline != null) {
                settings.put("hotline", currentHotline.replaceAll("\\s+", ""));
            }
            if (!settings.containsKey("heroTitle")) {
                settings.put("heroTitle", "Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc");
            }
            if (!settings.containsKey("heroSubtitle")) {
                settings.put("heroSubtitle", "Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng được làm thủ công từ nguyên liệu tự nhiên.");
            }
        }

        // Đồng bộ vào phạm vi ứng dụng (application scope) để các thành phần khác có thể truy cập
        getServletContext().setAttribute(SETTINGS_ATTR, settings);

        request.setAttribute(SETTINGS_ATTR, settings);
        request.getRequestDispatcher("/admin/setting.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Kiểm tra hành động khôi phục cấu hình mặc định
        String resetDefaults = request.getParameter("resetDefaults");
        if (resetDefaults != null && "true".equals(resetDefaults)) {
            Map<String, Object> defaults = initDefaultSettings();
            settingDAO.updateSettings(defaults);
            getServletContext().setAttribute(SETTINGS_ATTR, defaults);
            session.setAttribute("successMessage", "Khôi phục cấu hình mặc định thành công!");
            response.sendRedirect(request.getContextPath() + "/admin/settings");
            return;
        }

        // Lấy cấu hình hiện tại từ DB để kiểm tra các đường dẫn banner cũ
        Map<String, Object> currentSettings = settingDAO.getSettings();
        if (currentSettings.isEmpty()) {
            currentSettings = initDefaultSettings();
        }

        // Trích xuất các giá trị cấu hình
        String bakeryName = request.getParameter("bakeryName");
        String hotline = request.getParameter("hotline");
        String email = request.getParameter("email");
        String address = request.getParameter("address");

        String depositPercent = request.getParameter("depositPercent");
        String shippingRate = request.getParameter("shippingRate");
        String maxCakesPerHour = request.getParameter("maxCakesPerHour");
        String openingTime = request.getParameter("openingTime");
        String closingTime = request.getParameter("closingTime");

        String systemEmail = request.getParameter("systemEmail");
        String appPassword = request.getParameter("appPassword");
        String otpExpiry = request.getParameter("otpExpiry");

        boolean darkMode = request.getParameter("darkMode") != null;
        String heroTitle = request.getParameter("heroTitle");
        String heroSubtitle = request.getParameter("heroSubtitle");

        String banner1Align = request.getParameter("banner1Align");
        String banner2Align = request.getParameter("banner2Align");
        String banner3Align = request.getParameter("banner3Align");
        String banner4Align = request.getParameter("banner4Align");
        
        if (banner1Align == null) banner1Align = "50";
        if (banner2Align == null) banner2Align = "50";
        if (banner3Align == null) banner3Align = "50";
        if (banner4Align == null) banner4Align = "50";

        // Xác thực dữ liệu đầu vào bằng ValidationUtils
        String errorMsg = com.bakeryzone.utils.ValidationUtils.validateSystemSettings(
            bakeryName, hotline, email, address,
            depositPercent, shippingRate, maxCakesPerHour,
            systemEmail, appPassword, otpExpiry
        );
        
        if (errorMsg != null) {
            request.setAttribute("errorMessage", errorMsg);
            
            // Tái điền dữ liệu cấu hình với các dữ liệu hiện tại để người dùng không bị mất dữ liệu đã nhập
            Map<String, Object> settings = new HashMap<>(currentSettings);
            settings.put("bakeryName", bakeryName);
            settings.put("hotline", hotline);
            settings.put("email", email);
            settings.put("address", address);
            settings.put("depositPercent", depositPercent);
            settings.put("shippingRate", shippingRate);
            settings.put("maxCakesPerHour", maxCakesPerHour);
            settings.put("openingTime", openingTime);
            settings.put("closingTime", closingTime);
            settings.put("systemEmail", systemEmail);
            settings.put("appPassword", appPassword);
            settings.put("otpExpiry", otpExpiry);
            settings.put("darkMode", darkMode);
            settings.put("banner1Align", banner1Align);
            settings.put("heroTitle", heroTitle);
            settings.put("heroSubtitle", heroSubtitle);
            settings.put("banner2Align", banner2Align);
            settings.put("banner3Align", banner3Align);
            settings.put("banner4Align", banner4Align);
            
            request.setAttribute("settings", settings);
            request.getRequestDispatcher("/admin/setting.jsp").forward(request, response);
            return;
        }

        // Xử lý tải ảnh lên cho các banner
        jakarta.servlet.http.Part banner1Part = request.getPart("banner1");
        jakarta.servlet.http.Part banner2Part = request.getPart("banner2");
        jakarta.servlet.http.Part banner3Part = request.getPart("banner3");
        jakarta.servlet.http.Part banner4Part = request.getPart("banner4");

        String banner1 = uploadFile(banner1Part, request);
        String banner2 = uploadFile(banner2Part, request);
        String banner3 = uploadFile(banner3Part, request);
        String banner4 = uploadFile(banner4Part, request);

        // Giữ nguyên các banner hiện tại nếu không có tệp mới nào được tải lên
        if (banner1 == null) {
            banner1 = (String) currentSettings.get("banner1");
            if (banner1 == null) banner1 = "assets/images/hero/hero-1.jpg";
        }
        if (banner2 == null) {
            banner2 = (String) currentSettings.get("banner2");
            if (banner2 == null) banner2 = "assets/images/hero/hero-2.jpg";
        }
        if (banner3 == null) {
            banner3 = (String) currentSettings.get("banner3");
            if (banner3 == null) banner3 = "assets/images/hero/hero-3.jpg";
        }
        if (banner4 == null) {
            banner4 = (String) currentSettings.get("banner4");
            if (banner4 == null) banner4 = "assets/images/hero/hero-4.jpg";
        }

        Map<String, Object> settings = new HashMap<>();
        settings.put("bakeryName", bakeryName);
        settings.put("hotline", hotline);
        settings.put("email", email);
        settings.put("address", address);

        settings.put("depositPercent", depositPercent);
        settings.put("shippingRate", shippingRate);
        settings.put("maxCakesPerHour", maxCakesPerHour);
        settings.put("openingTime", openingTime);
        settings.put("closingTime", closingTime);

        settings.put("systemEmail", systemEmail);
        settings.put("appPassword", appPassword);
        settings.put("otpExpiry", otpExpiry);

        settings.put("darkMode", darkMode);
        settings.put("banner1", banner1);
        settings.put("heroTitle", heroTitle != null ? heroTitle.trim() : "");
        settings.put("heroSubtitle", heroSubtitle != null ? heroSubtitle.trim() : "");
        settings.put("banner2", banner2);
        settings.put("banner3", banner3);
        settings.put("banner4", banner4);
        settings.put("banner1Align", banner1Align);
        settings.put("banner2Align", banner2Align);
        settings.put("banner3Align", banner3Align);
        settings.put("banner4Align", banner4Align);

        // Cập nhật cơ sở dữ liệu
        settingDAO.updateSettings(settings);

        // Lưu lại vào ServletContext để truy cập toàn cục
        getServletContext().setAttribute(SETTINGS_ATTR, settings);

        // Thông báo nhanh (Flash message)
        session.setAttribute("successMessage", "Cập nhật cấu hình hệ thống thành công!");
        response.sendRedirect(request.getContextPath() + "/admin/settings");
    }

    private Map<String, Object> initDefaultSettings() {
        Map<String, Object> defaults = new HashMap<>();
        defaults.put("bakeryName", "BakeryZone");
        defaults.put("hotline", "0901234567");
        defaults.put("email", "support@bakeryzone.vn");
        defaults.put("address", "123 Đường Sourdough, TP. Hồ Chí Minh");

        defaults.put("depositPercent", "30");
        defaults.put("shippingRate", "5000");
        defaults.put("maxCakesPerHour", "15000");
        defaults.put("openingTime", "07:00 AM");
        defaults.put("closingTime", "09:00 PM");

        defaults.put("systemEmail", "doduyhung0901@gmail.com");
        defaults.put("appPassword", "erqx uoeu fsdv nwlk");
        defaults.put("otpExpiry", "5");

        defaults.put("darkMode", false);
        defaults.put("heroTitle", "Bánh tươi mỗi ngày, ngọt lành từng khoảnh khắc");
        defaults.put("heroSubtitle", "Khám phá những chiếc bánh ngọt, bánh sinh nhật và quà tặng được làm thủ công từ nguyên liệu tự nhiên.");
        defaults.put("banner1", "assets/images/hero/hero-1.jpg");
        defaults.put("banner2", "assets/images/hero/hero-2.jpg");
        defaults.put("banner3", "assets/images/hero/hero-3.jpg");
        defaults.put("banner4", "assets/images/hero/hero-4.jpg");
        defaults.put("banner1Align", "50");
        defaults.put("banner2Align", "50");
        defaults.put("banner3Align", "50");
        defaults.put("banner4Align", "50");
        return defaults;
    }

    private String uploadFile(jakarta.servlet.http.Part part, HttpServletRequest request) {
        if (part == null || part.getSize() <= 0)
            return null;
        String fileName = getFileName(part);
        if (fileName == null || fileName.isEmpty())
            return null;

        // Tạo thư mục assets/images/banners bên trong ứng dụng
        String uploadPath = request.getServletContext().getRealPath("") + java.io.File.separator + "assets"
                + java.io.File.separator + "images" + java.io.File.separator + "banners";
        java.io.File uploadDir = new java.io.File(uploadPath);
        if (!uploadDir.exists())
            uploadDir.mkdirs();

        String filePath = uploadPath + java.io.File.separator + fileName;
        try {
            part.write(filePath);
            return "assets/images/banners/" + fileName;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String getFileName(jakarta.servlet.http.Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
