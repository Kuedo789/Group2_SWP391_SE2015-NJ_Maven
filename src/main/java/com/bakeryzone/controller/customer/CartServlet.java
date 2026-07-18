package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CartDAO;
import com.bakeryzone.model.CartItemDTO; // Required for your list
import com.bakeryzone.model.Voucher;
import com.bakeryzone.dao.VoucherDAO;
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
                    handleApplyVoucher(request, response, userId);
                    return; // Method redirects, so we return here
                case "removeVoucher":
                    handleRemoveVoucher(request, response);
                    return; // Method redirects, so we return here
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

        // Voucher recalculation to ensure the discount remains valid if cart items change
        BigDecimal appliedDiscount = BigDecimal.ZERO;
        String appliedVoucherCode = (String) session.getAttribute("appliedVoucherCode");
        Integer appliedVoucherId = (Integer) session.getAttribute("appliedVoucherId");

        if (appliedVoucherCode != null && appliedVoucherId != null) {
            Voucher voucher = voucherDAO.getVoucherByCodeAndUser(appliedVoucherCode, userId);

            // Null-safe minimum order check: treat null minOrderValue as 0 (no minimum)
            BigDecimal minOrder = (voucher != null && voucher.getMinOrderValue() != null)
                    ? voucher.getMinOrderValue() : BigDecimal.ZERO;

            if (voucher != null && subtotal.compareTo(minOrder) >= 0) {
                String discountType = voucher.getDiscountType();

                // Accept both "PERCENT" and "PERCENTAGE" as stored in the DB
                boolean isPercentage = "PERCENT".equalsIgnoreCase(discountType)
                        || "PERCENTAGE".equalsIgnoreCase(discountType);

                if (isPercentage) {
                    // Use HALF_UP rounding to avoid ArithmeticException on
                    // non-terminating decimals (e.g. 450,001 × 25 / 100)
                    BigDecimal calculatedDiscount = subtotal
                            .multiply(voucher.getDiscountValue())
                            .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);

                    // Apply cap if a maximum discount amount is defined
                    if (voucher.getMaxDiscountAmount() != null
                            && voucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                        appliedDiscount = calculatedDiscount.min(voucher.getMaxDiscountAmount());
                    } else {
                        appliedDiscount = calculatedDiscount;
                    }
                } else {
                    // FIXED / FLAT discount: deduct the exact value from the voucher row
                    appliedDiscount = voucher.getDiscountValue();
                }

                // Safety guard: discount can never exceed the cart subtotal
                appliedDiscount = appliedDiscount.min(subtotal);

                System.out.println("[VOUCHER] code=" + appliedVoucherCode
                        + " type=" + discountType
                        + " value=" + voucher.getDiscountValue()
                        + " subtotal=" + subtotal
                        + " -> discount=" + appliedDiscount);

                request.setAttribute("appliedDiscount", appliedDiscount);
                request.setAttribute("appliedVoucherCode", appliedVoucherCode);
                request.setAttribute("appliedVoucher", voucher);
                session.setAttribute("appliedDiscount", appliedDiscount); // Keep synced for checkout
                session.setAttribute("voucherDiscountType", discountType);
                session.setAttribute("voucherDiscountValue", voucher.getDiscountValue());
                session.setAttribute("voucherMaxDiscount", voucher.getMaxDiscountAmount());
            } else {
                // Voucher no longer valid (e.g. subtotal dropped below minimum)
                session.removeAttribute("appliedVoucherCode");
                session.removeAttribute("appliedVoucherId");
                session.removeAttribute("appliedDiscount");
                session.removeAttribute("voucherDiscountType");
                session.removeAttribute("voucherDiscountValue");
                session.removeAttribute("voucherMaxDiscount");
                request.setAttribute("voucherError", "Giỏ hàng không còn đủ điều kiện áp dụng voucher này.");
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

    private void handleApplyVoucher(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {
        String voucherCode = request.getParameter("voucherCode");
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/cart?voucherError=empty");
            return;
        }

        voucherCode = voucherCode.trim();
        Voucher voucher = voucherDAO.getVoucherByCodeAndUser(voucherCode, userId);

        if (voucher == null) {
            response.sendRedirect(request.getContextPath() + "/cart?voucherError=notFound");
            return;
        }

        // Calculate subtotal to check minimum order condition
        List<CartItemDTO> cartItems = cartDAO.getCartItemsForUser(userId);
        BigDecimal subtotal = BigDecimal.ZERO;
        if (cartItems != null) {
            for (CartItemDTO item : cartItems) {
                if (item.isActive() && item.getUnitPrice() != null) {
                    BigDecimal itemTotal = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                    subtotal = subtotal.add(itemTotal);
                }
            }
        }

        // Null-safe minimum order check (vouchers with no minimum always pass)
        BigDecimal minOrder = voucher.getMinOrderValue() != null
                ? voucher.getMinOrderValue() : BigDecimal.ZERO;
        if (subtotal.compareTo(minOrder) < 0) {
            response.sendRedirect(request.getContextPath() + "/cart?voucherError=minOrder");
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("appliedVoucherId", voucher.getVoucherId());
        session.setAttribute("appliedVoucherCode", voucher.getVoucherCode());
        // The actual discount amount is calculated dynamically in renderCartPage

        response.sendRedirect(request.getContextPath() + "/cart?voucherApplied=true");
    }

    private void handleRemoveVoucher(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        session.removeAttribute("appliedVoucherId");
        session.removeAttribute("appliedVoucherCode");
        session.removeAttribute("appliedDiscount");
        session.removeAttribute("voucherDiscountType");
        session.removeAttribute("voucherDiscountValue");
        session.removeAttribute("voucherMaxDiscount");
        response.sendRedirect(request.getContextPath() + "/cart");
    }
}
