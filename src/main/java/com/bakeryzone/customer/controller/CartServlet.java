package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.CartDAO;
import com.bakeryzone.model.CartItemDTO; // Required for your list
import java.io.IOException;
import java.math.BigDecimal; // Required for total calculations
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
        // Enforce Session Authentication
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUserId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userId = (String) session.getAttribute("loggedInUserId");
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
                    // Redirects to order generation flow instead of cart refresh
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

        // Replace with your actual auth check; using a test ID for isolated development
        String userId = (session != null && session.getAttribute("loggedInUserId") != null)
                ? (String) session.getAttribute("loggedInUserId")
                : "USR-TEST-001";

        List<CartItemDTO> cartItems = cartDAO.getCartItemsForUser(userId);
        String aggregateStatus = cartDAO.getCartAggregateStatus(userId);

        // Dynamic Subtotal Calculation (Respects Soft-Delete constraint)
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CartItemDTO item : cartItems) {
            // Only add to the user's checkout total if the item has not been disabled by an admin
            if (item.isActive() && item.getUnitPrice() != null) {
                BigDecimal itemTotal = item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
                subtotal = subtotal.add(itemTotal);
            }
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartSubtotal", subtotal);
        request.setAttribute("footerAggregateStatus", aggregateStatus);

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
}