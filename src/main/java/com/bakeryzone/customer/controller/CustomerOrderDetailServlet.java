/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class CustomerOrderDetailServlet extends HttpServlet {
   
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

        String orderNo = request.getParameter("orderNo");
        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();
        Order order = orderDAO.getOrderByNo(orderNo);

        // Kiểm tra đơn hàng tồn tại
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        // Đảm bảo khách hàng chỉ xem được đơn hàng của chính mình (Bảo mật)
        if (!order.getCustomerId().equals(currentUser.getUserId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập thông tin đơn hàng này.");
            return;
        }

        // Lấy thông tin chi tiết khách hàng để hiển thị Tên và Số điện thoại người nhận
        CustomerDAO customerDAO = new CustomerDAO();
        Customer customer = customerDAO.getCustomerById(order.getCustomerId());

        // Truyền thông tin sang trang JSP
        request.setAttribute("order", order);
        request.setAttribute("customer", customer);
        
        request.getRequestDispatcher("/customer/order-detail.jsp").forward(request, response);
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

        String action = request.getParameter("action");
        String orderNo = request.getParameter("orderNo");

        if ("cancel".equalsIgnoreCase(action) && orderNo != null && !orderNo.trim().isEmpty()) {
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderByNo(orderNo);

            if (order != null && order.getCustomerId().equals(currentUser.getUserId())) {
                String dbStatus = order.getOrderStatus();
                if (dbStatus != null && (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed"))) {
                    orderDAO.updateOrderStatus(orderNo, "Cancelled");
                }
            }
            response.sendRedirect(request.getContextPath() + "/OrderDetail?orderNo=" + orderNo);
            return;
        }

        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Customer Order Detail Servlet";
    }
}
