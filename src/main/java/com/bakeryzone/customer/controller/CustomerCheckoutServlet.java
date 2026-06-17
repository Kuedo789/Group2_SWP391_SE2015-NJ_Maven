package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.DeliveryAddressDAO;
import com.bakeryzone.model.DeliveryAddress;
import com.bakeryzone.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

public class CustomerCheckoutServlet extends HttpServlet {

    private final DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Redirect to login if user is not authenticated
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Retrieve customer's saved delivery addresses
        List<DeliveryAddress> addressList = addressDAO.getAddressesByUserId(currentUser.getUserId());
        request.setAttribute("addressList", addressList);

        // Forward to the checkout page
        request.getRequestDispatcher("/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Handle place order action
        String addressIdRaw = request.getParameter("addressId");
        String timeSlot = request.getParameter("timeSlot");
        String note = request.getParameter("note");
        String cartData = request.getParameter("cartData"); // JSON or serialized string of cart items

        // Simulating order placement success
        System.out.println("[INFO] Checkout form submitted by User: " + currentUser.getUserId());
        System.out.println("[INFO] Delivery Address ID: " + addressIdRaw);
        System.out.println("[INFO] Chosen Time Slot: " + timeSlot);
        System.out.println("[INFO] Note: " + note);
        System.out.println("[INFO] Cart Data: " + cartData);

        // Redirecting to order success/list page with a success message
        response.sendRedirect(request.getContextPath() + "/OrderList?msg=order_success");
    }
}
