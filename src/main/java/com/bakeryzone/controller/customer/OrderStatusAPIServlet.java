package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Order;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/order/status")
public class OrderStatusAPIServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderNo = request.getParameter("orderNo");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        JsonObject json = new JsonObject();
        if (orderNo == null || orderNo.trim().isEmpty()) {
            json.addProperty("error", "Missing orderNo");
            response.getWriter().write(json.toString());
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);
        if (order != null) {
            json.addProperty("status", order.getOrderStatus());
        } else {
            json.addProperty("error", "Order not found");
        }
        
        response.getWriter().write(json.toString());
    }
}
