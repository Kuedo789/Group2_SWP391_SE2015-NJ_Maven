package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CustomCakeDAO;
import com.bakeryzone.model.CustomCake;
import com.bakeryzone.model.CustomCakeLayerIngredient;
import com.bakeryzone.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet handling the Custom Cake Builder save workflow.
 *
 * URL mapping: /custom-cake
 *
 * GET  → serves the customCakeStudio.jsp view.
 * POST → validates session auth, builds the model objects from JSON payload,
 *        delegates persistence to CustomCakeDAO (transactional), and returns a
 *        JSON response so the frontend can react without a full page reload.
 *
 * Expected POST parameters (all sent as application/x-www-form-urlencoded):
 *   canvasImageData  – base64 PNG data-URL string of the drawing canvas
 *   greetingText     – optional text (max 30 chars)
 *   cakeSize         – integer: 16 | 20 | 24
 *   layerCount       – integer: 2..5
 *   flavor_1..N      – flavor key for each layer position ("vanilla"|"chocolate"|"strawberry"|"matcha")
 *   calculatedPrice  – double, computed by the JS pricing engine
 */
public class CustomCakeServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CustomCakeServlet.class.getName());

    // Flavor key → database Ingredient_ID mapping.
    // Update these IDs to match the actual Ingredient_ID values in your ingredients table.
    private static final java.util.Map<String, String> FLAVOR_INGREDIENT_MAP = new java.util.HashMap<>();
    static {
        FLAVOR_INGREDIENT_MAP.put("vanilla",    "ING-VANILLA-SPG");
        FLAVOR_INGREDIENT_MAP.put("chocolate",  "ING-CHOC-SPG");
        FLAVOR_INGREDIENT_MAP.put("strawberry", "ING-STRAWBERRY-SPG");
        FLAVOR_INGREDIENT_MAP.put("matcha",     "ING-MATCHA-SPG");
    }

    // Base quantity (in grams) used per layer, scaled by the size multiplier below
    private static final double BASE_LAYER_QUANTITY_G = 200.0;

    private final CustomCakeDAO customCakeDAO = new CustomCakeDAO();

    // ── GET ────────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Simply forward to the JSP view
        request.getRequestDispatcher("/customer/customCakeStudio.jsp").forward(request, response);
    }

    // ── POST ───────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        // 1. Auth guard – must be logged in
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            sendJsonResponse(response, false, "Bạn cần đăng nhập để lưu thiết kế bánh.", null);
            return;
        }

        String userId = user.getUserId();

        try {
            // 2. Parse & validate inputs
            String canvasImageData = request.getParameter("canvasImageData");
            String greetingText    = trimAndNull(request.getParameter("greetingText"));
            String calculatedPriceStr = request.getParameter("calculatedPrice");
            String cakeSizeStr        = request.getParameter("cakeSize");
            String layerCountStr      = request.getParameter("layerCount");

            int cakeSize   = parseIntSafe(cakeSizeStr, 16);
            int layerCount = parseIntSafe(layerCountStr, 3);

            // Clamp layer count to allowed range
            layerCount = Math.max(2, Math.min(5, layerCount));

            double calculatedPrice = 0.0;
            try {
                calculatedPrice = Double.parseDouble(calculatedPriceStr);
            } catch (NumberFormatException e) {
                calculatedPrice = 0.0;
            }

            // Greeting max-length guard (30 chars, matching the JSP maxlength attribute)
            if (greetingText != null && greetingText.length() > 30) {
                greetingText = greetingText.substring(0, 30);
            }

            // 3. Build CustomCake entity
            String customCakeId = "CC-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase();

            // Build a structural hash string that describes the cake configuration
            // Format: SIZE_<size>_LAYERS_<count>_<flavor1>-<flavor2>-...
            StringBuilder hashBuilder = new StringBuilder();
            hashBuilder.append("SIZE_").append(cakeSize)
                       .append("_LAYERS_").append(layerCount);
            for (int i = 1; i <= layerCount; i++) {
                String flavor = trimAndNull(request.getParameter("flavor_" + i));
                if (flavor == null) flavor = "vanilla";
                hashBuilder.append("_").append(flavor.toUpperCase());
            }
            String cakeHashStructure = hashBuilder.toString();

            CustomCake cake = new CustomCake(
                customCakeId,
                canvasImageData,   // stored as LONGTEXT / base64 data URL
                greetingText,
                cakeHashStructure,
                calculatedPrice
            );

            // 4. Build layer-ingredient list
            double sizeMultiplier = getSizeMultiplier(cakeSize);
            List<CustomCakeLayerIngredient> layers = new ArrayList<>();

            for (int i = 1; i <= layerCount; i++) {
                String flavor = trimAndNull(request.getParameter("flavor_" + i));
                if (flavor == null) flavor = "vanilla";

                String ingredientId = FLAVOR_INGREDIENT_MAP.getOrDefault(flavor, "ING-VANILLA-SPG");
                double qty = BASE_LAYER_QUANTITY_G * sizeMultiplier;

                layers.add(new CustomCakeLayerIngredient(customCakeId, i, ingredientId, qty));
            }

            // 5. Delegate to DAO (transactional: custom_cake + layers + cart_item)
            boolean success = customCakeDAO.saveCustomCakeAndAddToCart(cake, layers, userId);

            if (success) {
                // Sync the user's HttpSession cart cache block so the browser view updates its badge counter instantly.
                com.bakeryzone.dao.CartDAO cartDAO = new com.bakeryzone.dao.CartDAO();
                int cartCount = cartDAO.getCartCountForUser(userId);
                session.setAttribute("cartCount", cartCount);

                sendJsonResponse(response, true, "Bánh tùy chỉnh đã được thêm vào giỏ hàng!", customCakeId);
            } else {
                sendJsonResponse(response, false, "Đã xảy ra lỗi khi lưu bánh. Vui lòng thử lại.", null);
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "CustomCakeServlet: Unexpected error during POST", e);
            sendJsonResponse(response, false, "Lỗi hệ thống. Vui lòng thử lại sau.", null);
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    /**
     * Size multiplier for scaling ingredient quantities.
     * 16cm → 1.0×, 20cm → 1.5×, 24cm → 2.0×
     */
    private double getSizeMultiplier(int cakeSize) {
        switch (cakeSize) {
            case 20: return 1.5;
            case 24: return 2.0;
            default: return 1.0; // 16cm
        }
    }

    private int parseIntSafe(String value, int defaultVal) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultVal;
        }
    }

    private String trimAndNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void sendJsonResponse(HttpServletResponse response,
                                  boolean success, String message, String customCakeId)
            throws IOException {
        PrintWriter out = response.getWriter();
        String idPart = customCakeId != null
                ? ",\"customCakeId\":\"" + customCakeId + "\""
                : "";
        out.print("{\"success\":" + success
                + ",\"message\":\"" + escapeJson(message) + "\""
                + idPart + "}");
        out.flush();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
