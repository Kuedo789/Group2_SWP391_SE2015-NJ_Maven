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
                case "add":
                    handleAddSnapshot(request, response, userId);
                    return; // Method sends JSON response directly
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
                case "applyVouchersAjax":
                    handleApplyVouchersAjax(request, response, userId);
                    return; 
                case "removeVoucherAjax":
                    handleRemoveVoucherAjax(request, response);
                    return; 
                case "checkout":
                    String[] selectedItems = request.getParameterValues("selectedCartItems");
                    if (selectedItems != null && selectedItems.length > 0) {
                        request.getSession().setAttribute("checkoutSelectedItems", java.util.Arrays.asList(selectedItems));
                    }
                    response.sendRedirect(request.getContextPath() + "/checkout");
                    return;
                default:
                    break;
            }
        }

        // Strict PRG Rule: Always finish POST with a redirect to prevent double submissions
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void handleAddSnapshot(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {
        String productId = request.getParameter("productId");
        String name = request.getParameter("name");
        String priceStr = request.getParameter("price");
        String image = request.getParameter("image");
        String qtyStr = request.getParameter("qty");

        boolean success = false;
        try {
            BigDecimal price = (priceStr != null && !priceStr.isEmpty()) ? new BigDecimal(priceStr) : BigDecimal.ZERO;
            int qty = (qtyStr != null && !qtyStr.isEmpty()) ? Integer.parseInt(qtyStr) : 1;
            success = cartDAO.addSnapshotToCart(userId, productId, name, price, image, qty);
        } catch (Exception e) {
            e.printStackTrace();
        }

        int newCount = cartDAO.getCartCountForUser(userId);
        request.getSession().setAttribute("cartCount", newCount);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": " + success + ", \"cartCount\": " + newCount + "}");
    }

    // =========================================================
    // PRIVATE HELPER METHODS (Controller Pattern)
    // =========================================================
    private void renderCartPage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        com.bakeryzone.model.User user = (session != null) ? (com.bakeryzone.model.User) session.getAttribute("user") : null;

        if (user == null) {
            request.setAttribute("isUnauthenticated", true);
            request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
            return;
        }

        String userId = user.getUserId();
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

        // Fetch available vouchers for the modal
        List<Voucher> availableVouchers = voucherDAO.getAvailableVouchersForUser(userId);
        request.setAttribute("availableVouchers", availableVouchers);

        // Recalculate Order Voucher
        BigDecimal appliedOrderDiscount = BigDecimal.ZERO;
        String appliedOrderVoucherCode = (String) session.getAttribute("appliedOrderVoucherCode");
        if (appliedOrderVoucherCode != null) {
            Voucher voucher = voucherDAO.getVoucherByCodeAndUser(appliedOrderVoucherCode, userId);
            if (voucher != null && "ORDER".equalsIgnoreCase(voucher.getVoucherScope())) {
                BigDecimal minOrder = voucher.getMinOrderValue() != null ? voucher.getMinOrderValue() : BigDecimal.ZERO;
                if (subtotal.compareTo(minOrder) >= 0) {
                    appliedOrderDiscount = calculateDiscount(voucher, subtotal);
                    request.setAttribute("appliedOrderDiscount", appliedOrderDiscount);
                    request.setAttribute("appliedOrderVoucherCode", appliedOrderVoucherCode);
                    session.setAttribute("appliedOrderDiscount", appliedOrderDiscount);
                } else {
                    session.removeAttribute("appliedOrderVoucherCode");
                    session.removeAttribute("appliedOrderVoucherId");
                    session.removeAttribute("appliedOrderDiscount");
                }
            }
        }

        // Check Shipping Voucher (validation against subtotal, but discount applies to shipping fee later)
        String appliedShippingVoucherCode = (String) session.getAttribute("appliedShippingVoucherCode");
        if (appliedShippingVoucherCode != null) {
            Voucher voucher = voucherDAO.getVoucherByCodeAndUser(appliedShippingVoucherCode, userId);
            if (voucher != null && "SHIPPING".equalsIgnoreCase(voucher.getVoucherScope())) {
                BigDecimal minOrder = voucher.getMinOrderValue() != null ? voucher.getMinOrderValue() : BigDecimal.ZERO;
                if (subtotal.compareTo(minOrder) >= 0) {
                    // We don't have shipping fee here, so we just pass the voucher details to frontend
                    request.setAttribute("appliedShippingVoucherCode", appliedShippingVoucherCode);
                    request.setAttribute("shippingVoucherDiscountValue", voucher.getDiscountValue());
                    request.setAttribute("shippingVoucherDiscountType", voucher.getDiscountType());
                    request.setAttribute("shippingVoucherMaxDiscount", voucher.getMaxDiscountAmount());
                } else {
                    session.removeAttribute("appliedShippingVoucherCode");
                    session.removeAttribute("appliedShippingVoucherId");
                }
            }
        }

        int totalCount = cartDAO.getCartCountForUser(userId);
        session.setAttribute("cartCount", totalCount);
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartSubtotal", subtotal);
        request.getRequestDispatcher("/customer/cart.jsp").forward(request, response);
    }

    private BigDecimal calculateDiscount(Voucher voucher, BigDecimal baseAmount) {
        String discountType = voucher.getDiscountType();
        boolean isPercentage = "PERCENT".equalsIgnoreCase(discountType) || "PERCENTAGE".equalsIgnoreCase(discountType);
        BigDecimal discount = BigDecimal.ZERO;

        if (isPercentage) {
            discount = baseAmount.multiply(voucher.getDiscountValue()).divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
            if (voucher.getMaxDiscountAmount() != null && voucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                discount = discount.min(voucher.getMaxDiscountAmount());
            }
        } else {
            discount = voucher.getDiscountValue();
        }
        return discount.min(baseAmount);
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

    private void handleApplyVouchersAjax(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {
        String orderCode = request.getParameter("orderCode");
        String shippingCode = request.getParameter("shippingCode");
        HttpSession session = request.getSession();

        // Clear existing vouchers first
        session.removeAttribute("appliedOrderVoucherCode");
        session.removeAttribute("appliedOrderVoucherId");
        session.removeAttribute("appliedOrderDiscount");
        session.removeAttribute("appliedShippingVoucherCode");
        session.removeAttribute("appliedShippingVoucherId");

        List<CartItemDTO> cartItems = cartDAO.getCartItemsForUser(userId);
        BigDecimal subtotal = BigDecimal.ZERO;
        if (cartItems != null) {
            for (CartItemDTO item : cartItems) {
                if (item.isActive() && item.getUnitPrice() != null) {
                    subtotal = subtotal.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                }
            }
        }

        boolean success = true;
        String errorMsg = "";

        if (orderCode != null && !orderCode.trim().isEmpty()) {
            Voucher v = voucherDAO.getVoucherByCodeAndUser(orderCode.trim(), userId);
            if (v != null && "ORDER".equalsIgnoreCase(v.getVoucherScope())) {
                BigDecimal minOrder = v.getMinOrderValue() != null ? v.getMinOrderValue() : BigDecimal.ZERO;
                if (subtotal.compareTo(minOrder) >= 0) {
                    session.setAttribute("appliedOrderVoucherCode", v.getVoucherCode());
                    session.setAttribute("appliedOrderVoucherId", v.getVoucherId());
                } else {
                    success = false;
                    errorMsg = "Chưa đạt giá trị tối thiểu cho voucher toàn đơn.";
                }
            }
        }

        if (shippingCode != null && !shippingCode.trim().isEmpty()) {
            Voucher v = voucherDAO.getVoucherByCodeAndUser(shippingCode.trim(), userId);
            if (v != null && "SHIPPING".equalsIgnoreCase(v.getVoucherScope())) {
                BigDecimal minOrder = v.getMinOrderValue() != null ? v.getMinOrderValue() : BigDecimal.ZERO;
                if (subtotal.compareTo(minOrder) >= 0) {
                    session.setAttribute("appliedShippingVoucherCode", v.getVoucherCode());
                    session.setAttribute("appliedShippingVoucherId", v.getVoucherId());
                } else {
                    success = false;
                    errorMsg += (errorMsg.isEmpty() ? "" : " ") + "Chưa đạt giá trị tối thiểu cho voucher vận chuyển.";
                }
            }
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (success) {
            response.getWriter().write("{\"success\": true}");
        } else {
            response.getWriter().write("{\"success\": false, \"error\": \"" + errorMsg + "\"}");
        }
    }

    private void handleRemoveVoucherAjax(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String scope = request.getParameter("scope");
        HttpSession session = request.getSession();
        if ("ORDER".equalsIgnoreCase(scope)) {
            session.removeAttribute("appliedOrderVoucherCode");
            session.removeAttribute("appliedOrderVoucherId");
            session.removeAttribute("appliedOrderDiscount");
        } else if ("SHIPPING".equalsIgnoreCase(scope)) {
            session.removeAttribute("appliedShippingVoucherCode");
            session.removeAttribute("appliedShippingVoucherId");
        }
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\": true}");
    }
}
