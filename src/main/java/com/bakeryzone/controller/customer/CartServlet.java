package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CartDAO;
import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.model.CartItemDTO;
import java.io.IOException;
import java.math.BigDecimal; // Required for total calculations
import java.math.RoundingMode;
import java.util.List; // Required for the cart list

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Required for session auth

/**
 * Cart Controller handling routing and PRG patterns.
 */
@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private final CartDAO cartDAO = new CartDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Pure MVC Router: Delegate to view renderer
        renderCartPage(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Enforce Session Authentication using your unified mapping strategy
        HttpSession session = request.getSession(false);
        com.bakeryzone.model.User user = (session != null) ? (com.bakeryzone.model.User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Safely extract verified target credentials
        String userId = user.getUserId();
        String actionParam = request.getParameter("action");

        // Command Pattern Routing based on JSP value="action-ID"
        if (actionParam != null) {
            String[] parts = actionParam.split("-", 2);
            String command = parts[0];
            String targetId = parts.length > 1 ? parts[1] : null;

            switch (command) {
                case "increase":
                    handleQuantityChange(targetId, userId, 1);
                    break;
                case "decrease":
                    handleQuantityChange(targetId, userId, -1);
                    break;
                case "remove":
                    handleRemoveItem(targetId, userId);
                    break;
                case "restore":
                    // Handled by admin product states.
                    break;
                case "applyVoucher":
                    handleApplyVoucher(request, session);
                    break;
                case "removeVoucher":
                    session.removeAttribute("appliedVoucherCode");
                    session.removeAttribute("appliedDiscount");
                    response.sendRedirect(request.getContextPath() + "/cart?voucherRemoved=true");
                    return;
                case "checkout":
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                default:
                    break;
            }
        }

        // Strict PRG Rule: Always finish POST with a redirect to prevent double submissions
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    // =========================================================
    // PRIVATE HELPER METHODS (Controller Pattern)
    // =========================================================
    private void renderCartPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // 1. Fetch the user object from the session
        com.bakeryzone.model.User user = (session != null) ? (com.bakeryzone.model.User) session.getAttribute("user") : null;

        // 2. Guard Clause: If no user object exists, flag as unauthenticated
        if (user == null) {
            request.setAttribute("isUnauthenticated", true);
            request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
            return;
        }

        // 3. Extract the real verified ID from the session user object
        // (Double-check if your getter is getUserId() or getUser_ID() in your model)
        String userId = user.getUserId();
        List<CartItemDTO> cartItems = cartDAO.getCartItemsForUser(userId);

        // 4. Calculate running subtotal for active items
        BigDecimal subtotal = BigDecimal.ZERO;
        if (cartItems != null) {
            for (CartItemDTO item : cartItems) {
                if (item.isActive() && item.getUnitPrice() != null) {
                    BigDecimal itemTotal = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                    subtotal = subtotal.add(itemTotal);
                }
            }
        }


        // 5. Update the navbar total item quantity badge state
        int totalCount = cartDAO.getCartCountForUser(userId);
        session.setAttribute("cartCount", totalCount);

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartSubtotal", subtotal);
        request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
    }

    private void handleQuantityChange(String cartItemId, String userId, int delta) {
        if (cartItemId != null && !cartItemId.trim().isEmpty()) {
            cartDAO.updateQuantity(cartItemId, userId, delta);
        }
    }

    private void handleRemoveItem(String cartItemId, String userId) {
        if (cartItemId != null && !cartItemId.trim().isEmpty()) {
            cartDAO.removeCartItem(cartItemId, userId);
        }
    }

    private void handleApplyVoucher(HttpServletRequest request, HttpSession session) throws IOException {
        String code = request.getParameter("voucherCode");
        if (code == null || code.trim().isEmpty()) {
            session.setAttribute("voucherError", "Vui lòng nhập mã voucher!");
            return;
        }
        
        com.bakeryzone.model.Voucher v = voucherDAO.getVoucherByCode(code.trim().toUpperCase());
        if (v == null || !v.isActive()) {
            session.setAttribute("voucherError", "Mã voucher không tồn tại hoặc đã bị khóa!");
            return;
        }

        long now = System.currentTimeMillis();
        if (v.getStartDate().getTime() > now || v.getEndDate().getTime() < now) {
            session.setAttribute("voucherError", "Mã voucher chưa bắt đầu hoặc đã hết hạn!");
            return;
        }

        if (v.getTotalQuantity() <= 0) {
            session.setAttribute("voucherError", "Mã voucher này đã hết số lượng!");
            return;
        }

        com.bakeryzone.model.User user = (com.bakeryzone.model.User) session.getAttribute("user");
        int userUsage = voucherDAO.getUserUsageCount(user.getUserId(), v.getVoucherCode());
        if (userUsage >= v.getUsagePerUser()) {
            session.setAttribute("voucherError", "Bạn đã sử dụng hết lượt cho mã này!");
            return;
        }

        // Tier check could go here if Membership was fully loaded in session. 
        // For now, we will assume pass or check if user.getTierId() exists.

        // Also we need cart subtotal. Since we do this on POST before GET, we could calculate here,
        // but easier to just save code to session and let GET (renderCartPage) validate minOrderValue.
        // Actually, we can just save it, and let Checkout validate.
        session.setAttribute("appliedVoucherCode", v.getVoucherCode());
        session.setAttribute("appliedDiscount", v.getDiscountAmount());
        session.setAttribute("appliedVoucherMinOrder", v.getMinOrderValue());
        session.removeAttribute("voucherError");
    }
}
