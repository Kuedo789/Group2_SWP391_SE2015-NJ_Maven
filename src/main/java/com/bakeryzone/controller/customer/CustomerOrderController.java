package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CustomerOrderController", urlPatterns = {"/OrderList", "/OrderDetail", "/order-success"})
public class CustomerOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

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

        String path = request.getServletPath();

        if ("/OrderDetail".equals(path)) {
            handleDetail(request, response, currentUser);
        } else if ("/order-success".equals(path)) {
            handleSuccess(request, response, currentUser);
        } else {
            handleList(request, response, currentUser);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String customerId = orderDAO.getCustomerIdByUserId(currentUser.getUserId());
        List<Order> ordersList = orderDAO.getOrdersByCustomerId(customerId);


        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");

        java.util.Date startDate = null;
        java.util.Date endDate = null;
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");

        if (startDateStr != null && !startDateStr.trim().isEmpty()) {
            try {
                startDate = sdf.parse(startDateStr.trim());
            } catch (Exception e) {}
        }
        if (endDateStr != null && !endDateStr.trim().isEmpty()) {
            try {
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(sdf.parse(endDateStr.trim()));
                cal.set(java.util.Calendar.HOUR_OF_DAY, 23);
                cal.set(java.util.Calendar.MINUTE, 59);
                cal.set(java.util.Calendar.SECOND, 59);
                cal.set(java.util.Calendar.MILLISECOND, 999);
                endDate = cal.getTime();
            } catch (Exception e) {}
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "all";
        } else {
            status = status.trim().toLowerCase();
        }

        List<Order> filteredOrders = new ArrayList<>();
        for (Order order : ordersList) {
            boolean keep = true;
            
            // 1. Date filter with NPE checks
            if (order.getOrderTime() == null) {
                keep = false;
            } else {
                if (startDate != null && order.getOrderTime().before(startDate)) {
                    keep = false;
                }
                if (endDate != null && order.getOrderTime().after(endDate)) {
                    keep = false;
                }
            }

            // 2. Status filter
            if (keep) {
                String dbStatus = order.getOrderStatus();
                if ("processing".equals(status)) {
                    if (dbStatus == null || (!dbStatus.equalsIgnoreCase("Pending") && !dbStatus.equalsIgnoreCase("Confirmed") && !dbStatus.equalsIgnoreCase("Processing"))) {
                        keep = false;
                    }
                } else if ("shipping".equals(status)) {
                    if (dbStatus == null || !dbStatus.equalsIgnoreCase("Delivering")) {
                        keep = false;
                    }
                } else if ("completed".equals(status)) {
                    if (dbStatus == null || !dbStatus.equalsIgnoreCase("Completed")) {
                        keep = false;
                    }
                } else if ("cancelled".equals(status)) {
                    if (dbStatus == null || (!dbStatus.equalsIgnoreCase("Cancelled") && !dbStatus.equalsIgnoreCase("Canceled"))) {
                        keep = false;
                    }
                }
            }

            if (keep) {
                filteredOrders.add(order);
            }
        }

        int totalOrders = filteredOrders.size();
        int pageSize = 6;
        int totalPages = (int) Math.ceil((double) totalOrders / pageSize);
        
        // Count orders for each status matching the date range
        int countAll = 0;
        int countProcessing = 0;
        int countShipping = 0;
        int countCompleted = 0;
        int countCancelled = 0;

        for (Order order : ordersList) {
            boolean dateMatch = true;
            if (order.getOrderTime() == null) {
                dateMatch = false;
            } else {
                if (startDate != null && order.getOrderTime().before(startDate)) {
                    dateMatch = false;
                }
                if (endDate != null && order.getOrderTime().after(endDate)) {
                    dateMatch = false;
                }
            }
            if (dateMatch) {
                countAll++;
                String dbStatus = order.getOrderStatus();
                if (dbStatus != null) {
                    if (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equalsIgnoreCase("Processing")) {
                        countProcessing++;
                    } else if (dbStatus.equalsIgnoreCase("Delivering")) {
                        countShipping++;
                    } else if (dbStatus.equalsIgnoreCase("Completed")) {
                        countCompleted++;
                    } else if (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled")) {
                        countCancelled++;
                    }
                }
            }
        }

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (Exception e) {}
        }
        if (currentPage < 1) currentPage = 1;
        if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;

        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, totalOrders);
        List<Order> paginatedOrders = (totalOrders > 0) ? filteredOrders.subList(start, end) : new ArrayList<>();

        request.setAttribute("orders", paginatedOrders);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("startDate", startDateStr);
        request.setAttribute("endDate", endDateStr);
        request.setAttribute("status", status);
        request.setAttribute("countAll", countAll);
        request.setAttribute("countProcessing", countProcessing);
        request.setAttribute("countShipping", countShipping);
        request.setAttribute("countCompleted", countCompleted);
        request.setAttribute("countCancelled", countCancelled);
        request.getRequestDispatcher("/customer/my-orders.jsp").forward(request, response);
    }

    private void handleSuccess(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String orderNo = request.getParameter("orderNo");
        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);

        String actualCustomerId = orderDAO.getCustomerIdByUserId(currentUser.getUserId());
        if (order == null || !order.getCustomerId().equals(actualCustomerId)) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/customer/order-success.jsp").forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response, User currentUser)
            throws ServletException, IOException {
        String orderNo = request.getParameter("orderNo");
        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);

        // Kiểm tra đơn hàng tồn tại
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/OrderList");
            return;
        }

        // Đảm bảo khách hàng chỉ xem được đơn hàng của chính mình (Bảo mật)
        String actualCustomerId = orderDAO.getCustomerIdByUserId(currentUser.getUserId());
        if (!order.getCustomerId().equals(actualCustomerId)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập thông tin đơn hàng này.");
            return;
        }

        // Lấy thông tin chi tiết khách hàng để hiển thị Tên và Số điện thoại người nhận
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

        String path = request.getServletPath();

        if ("/OrderDetail".equals(path)) {
            String action = request.getParameter("action");
            String orderNo = request.getParameter("orderNo");

            if ("cancel".equalsIgnoreCase(action) && orderNo != null && !orderNo.trim().isEmpty()) {
                Order order = orderDAO.getOrderByNo(orderNo);
                String actualCustomerId = orderDAO.getCustomerIdByUserId(currentUser.getUserId());

                if (order != null && order.getCustomerId().equals(actualCustomerId)) {
                    String dbStatus = order.getOrderStatus();
                    if (dbStatus != null && (dbStatus.equalsIgnoreCase("Pending") || dbStatus.equalsIgnoreCase("Confirmed") || dbStatus.equalsIgnoreCase("Processing"))) {
                        orderDAO.updateOrderStatus(orderNo, "Cancelled");
                    }
                }
                response.sendRedirect(request.getContextPath() + "/OrderDetail?orderNo=" + orderNo);
                return;
            }
        }

        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Customer Order Controller";
    }
}
