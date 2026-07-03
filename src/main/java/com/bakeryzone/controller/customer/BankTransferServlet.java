package com.bakeryzone.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.bakeryzone.model.User;

import java.io.IOException;

public class BankTransferServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Redirect to login if not authenticated
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get order info from query params
        String orderNo = request.getParameter("orderNo");
        String totalStr = request.getParameter("total");

        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Format total for display
        long totalAmount = 0L;
        if (totalStr != null && !totalStr.trim().isEmpty()) {
            try {
                totalAmount = Math.round(Double.parseDouble(totalStr.trim()));
            } catch (NumberFormatException ignored) {}
        }

        request.setAttribute("orderNo", orderNo);
        request.setAttribute("totalAmount", totalAmount);

        request.getRequestDispatcher("/customer/bank-transfer.jsp").forward(request, response);
    }
}
