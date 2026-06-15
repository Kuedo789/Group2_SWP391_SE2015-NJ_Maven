package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class CustomerOrderListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Nếu chưa đăng nhập, chuyển hướng về trang đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Khách hàng có ID trùng khớp với User_ID
        String customerId = currentUser.getUserId();
        OrderDAO orderDAO = new OrderDAO();
        List<Order> ordersList = orderDAO.getOrdersByCustomerId(customerId);

        // Truyền danh sách đơn hàng sang trang JSP
        request.setAttribute("orders", ordersList);
        request.getRequestDispatcher("/customer/my-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Customer Order List Servlet";
    }
}
