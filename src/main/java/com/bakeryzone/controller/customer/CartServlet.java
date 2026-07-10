package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CartDAO;
import com.bakeryzone.model.CartItemDTO; // Required for your list
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
    }}
