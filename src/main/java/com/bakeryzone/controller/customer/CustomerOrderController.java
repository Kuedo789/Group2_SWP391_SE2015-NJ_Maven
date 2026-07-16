package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

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

        // Đảm bảo chỉ khách hàng mới truy cập được các trang này
        if (!"CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
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

        String startDateStr = request.getParameter("startDate");
        String endDateStr   = request.getParameter("endDate");
        String search       = request.getParameter("search");
        String sort         = request.getParameter("sort");
        String status       = request.getParameter("status");

        // Chuẩn hóa dữ liệu đầu vào
        if (search != null && search.trim().isEmpty()) search = null;
        if (sort == null || sort.trim().isEmpty())     sort = "date_desc";
        if (status == null || status.trim().isEmpty()) status = "all";
        else status = status.trim().toLowerCase();

        // Xác thực khoảng ngày
        String dateError = ValidationUtils.validateDateFilter(startDateStr, endDateStr);
        if (dateError != null) {
            request.setAttribute("errorMessage", dateError);
            request.getSession().setAttribute("errorMessage", dateError);
            startDateStr = null;
            endDateStr = null;
        }
        if (startDateStr != null && startDateStr.trim().isEmpty()) startDateStr = null;
        if (endDateStr   != null && endDateStr.trim().isEmpty())   endDateStr   = null;

        // Phân trang đơn hàng
        int pageSize = 6;
        int totalOrders = orderDAO.getOrdersCountByCustomer(customerId, search, status, startDateStr, endDateStr);
        int totalPages  = (int) Math.ceil((double) totalOrders / pageSize);
        if (totalPages < 1) totalPages = 1;

        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try { currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
        }
        if (currentPage < 1)          currentPage = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        // Chỉ lấy dữ liệu trang hiện tại từ DB (Tránh tải thừa toàn bộ đơn hàng của khách)
        java.util.List<Order> paginatedOrders = orderDAO.getOrdersByCustomerPaged(
            customerId, search, status, startDateStr, endDateStr, sort, currentPage, pageSize);

        // Thống kê số lượng đơn theo từng tab trạng thái bằng 1 truy vấn SQL duy nhất thay vì lặp trong Java
        java.util.Map<String, Integer> statusCounts = orderDAO.getOrderStatusCountsByCustomer(
            customerId, search, startDateStr, endDateStr);

        request.setAttribute("orders",          paginatedOrders);
        request.setAttribute("currentPage",     currentPage);
        request.setAttribute("totalPages",      totalPages);
        request.setAttribute("startDate",       startDateStr);
        request.setAttribute("endDate",         endDateStr);
        request.setAttribute("search",          search != null ? search : "");
        request.setAttribute("sort",            sort);
        request.setAttribute("status",          status);
        request.setAttribute("countAll",        statusCounts.getOrDefault("all", 0));
        request.setAttribute("countProcessing", statusCounts.getOrDefault("processing", 0));
        request.setAttribute("countShipping",   statusCounts.getOrDefault("shipping", 0));
        request.setAttribute("countCompleted",  statusCounts.getOrDefault("completed", 0));
        request.setAttribute("countCancelled",  statusCounts.getOrDefault("cancelled", 0));
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
        if (order == null || !actualCustomerId.equals(order.getCustomerId())) {
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

        // Đảm bảo chỉ khách hàng mới truy cập được các trang này
        if (!"CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
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
                    if (dbStatus != null && 
                        !dbStatus.equalsIgnoreCase("Delivering") && 
                        !dbStatus.equalsIgnoreCase("Completed") && 
                        !dbStatus.equalsIgnoreCase("Cancelled") && 
                        !dbStatus.equalsIgnoreCase("Canceled")) {
                        
                        boolean success = orderDAO.updateOrderStatus(orderNo, "Cancelled");
                        if (success) {
                            session.setAttribute("successMessage", "Huỷ đơn hàng #" + orderNo + " thành công!");
                        } else {
                            session.setAttribute("errorMessage", "Không thể huỷ đơn hàng.");
                        }
                    } else {
                        if (dbStatus != null && (dbStatus.equalsIgnoreCase("Cancelled") || dbStatus.equalsIgnoreCase("Canceled"))) {
                            session.setAttribute("errorMessage", "Đơn hàng này đã được huỷ từ trước.");
                        } else {
                            session.setAttribute("errorMessage", "Đơn hàng đang giao hoặc đã hoàn thành, không thể huỷ!");
                        }
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
