package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderController", urlPatterns = {"/admin/orders"})
public class AdminOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    // Whitelist trạng thái hợp lệ – ngăn giá trị rác ghi vào DB
    private static final java.util.Set<String> ALLOWED_STATUSES = java.util.Set.of(
        "Pending", "Confirmed", "Processing", "Delivering", "Completed", "Cancelled"
    );

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                showOrderDetail(request, response);
                break;
            case "list":
            default:
                showOrderList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        

        String action = request.getParameter("action");
        if ("update-status".equals(action)) {
            handleUpdateStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
        }
    }

    private void showOrderList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("search");
        String statusParam = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String sort = request.getParameter("sort");

        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        // Normalize status for DAO: null means no filter
        String statusForDao = null;
        String statusForView = "all"; // Always send 'all' or a specific status to the view
        if (statusParam != null && !statusParam.trim().isEmpty() && !statusParam.equalsIgnoreCase("all")) {
            statusForDao = statusParam.trim();
            statusForView = statusForDao;
        }
        // Validate Dates
        if (!ValidationUtils.isValidDateFormat(startDate) || !ValidationUtils.isValidDateFormat(endDate)) {
            request.setAttribute("errorMessage", "Định dạng ngày không hợp lệ.");
            request.getSession().setAttribute("errorMessage", "Định dạng ngày không hợp lệ.");
            startDate = null;
            endDate = null;
        } else if (!ValidationUtils.isValidDateRange(startDate, endDate)) {
            request.setAttribute("errorMessage", "Ngày bắt đầu không được lớn hơn Ngày kết thúc.");
            request.getSession().setAttribute("errorMessage", "Ngày bắt đầu không được lớn hơn Ngày kết thúc.");
            startDate = null;
            endDate = null;
        }

        if (startDate != null && startDate.trim().isEmpty()) {
            startDate = null;
        }
        if (endDate != null && endDate.trim().isEmpty()) {
            endDate = null;
        }

        if (sort == null || sort.trim().isEmpty()) {
            sort = "date_desc";
        }

        // Reset to page 1 when filters change (no page param means fresh filter)
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int pageSize = 10;
        int totalRecords = orderDAO.getTotalOrdersCount(keyword, statusForDao, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orders = orderDAO.getOrdersPaged(keyword, statusForDao, startDate, endDate, sort, page, pageSize);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", keyword != null ? keyword : "");
        request.setAttribute("status", statusForView);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("/admin/orderList.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderNo = request.getParameter("orderNo");
        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);
        if (order == null) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy đơn hàng #" + orderNo);
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        Customer customer = customerDAO.getCustomerById(order.getCustomerId());

        request.setAttribute("order", order);
        request.setAttribute("customer", customer);

        request.getRequestDispatcher("/admin/orderDetail.jsp").forward(request, response);
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderNo = request.getParameter("orderNo");
        String status = request.getParameter("status");
        HttpSession session = request.getSession();

        if (orderNo == null || orderNo.trim().isEmpty() || status == null || status.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Dữ liệu trạng thái không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        // Kiểm tra status nằm trong whitelist trước khi làm bất cứ điều gì
        if (!ALLOWED_STATUSES.contains(status)) {
            session.setAttribute("errorMessage", "Trạng thái '" + status + "' không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);
        if (order == null) {
            session.setAttribute("errorMessage", "Không tìm thấy đơn hàng #" + orderNo);
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        String currentStatus = order.getOrderStatus();
        
        // Ngăn chặn thay đổi nếu đơn hàng đã bị huỷ hoặc hoàn thành (hỗ trợ cả Việt/Anh)
        if (currentStatus != null && (
                currentStatus.equalsIgnoreCase("Cancelled") || currentStatus.equals("Đã hủy") ||
                currentStatus.equalsIgnoreCase("Completed") || currentStatus.equals("Hoàn thành") || currentStatus.equals("Đã giao"))) {
            session.setAttribute("errorMessage", "Đơn hàng đã hoàn thành hoặc đã huỷ, không thể thay đổi trạng thái!");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
            return;
        }

        // Admin có quyền chuyển sang bất kỳ trạng thái nào trong whitelist

        boolean success = orderDAO.updateOrderStatus(orderNo, status);
        if (success) {
            session.setAttribute("successMessage", "Cập nhật trạng thái đơn hàng #" + orderNo + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Không thể cập nhật trạng thái đơn hàng.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
    }
}
