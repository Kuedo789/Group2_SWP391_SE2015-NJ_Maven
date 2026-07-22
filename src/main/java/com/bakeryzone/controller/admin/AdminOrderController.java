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

@WebServlet(name = "AdminOrderController", urlPatterns = {"/admin/orders", "/staff/orders"})
public class AdminOrderController extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

    // Whitelist trạng thái hợp lệ – ngăn giá trị rác ghi vào DB
    private static final java.util.Set<String> ALLOWED_STATUSES = java.util.Set.of(
        "Pending", "Confirmed", "Processing", "Delivering", "Completed", "Cancelled", "PAID"
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
        String cakeType = request.getParameter("cakeType");

        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        // Chuẩn hóa trạng thái cho DAO: null nghĩa là không lọc
        String statusForDao = null;
        String statusForView = "all"; // Luôn gửi 'all' hoặc trạng thái cụ thể tới trang hiển thị (view)
        if (statusParam != null && !statusParam.trim().isEmpty() && !statusParam.equalsIgnoreCase("all")) {
            statusForDao = statusParam.trim();
            statusForView = statusForDao;
        }
        // Xác thực ngày tháng
        String dateError = ValidationUtils.validateDateFilter(startDate, endDate);
        if (dateError != null) {
            request.setAttribute("errorMessage", dateError);
            request.getSession().setAttribute("errorMessage", dateError);
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

        // Reset về trang 1 khi thay đổi bộ lọc (không có tham số page nghĩa là bộ lọc mới)
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
        int totalRecords = orderDAO.getTotalOrdersCount(keyword, statusForDao, startDate, endDate, cakeType);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orders = orderDAO.getOrdersPaged(keyword, statusForDao, startDate, endDate, sort, page, pageSize, cakeType);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", keyword != null ? keyword : "");
        request.setAttribute("status", statusForView);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("sort", sort);
        request.setAttribute("cakeType", cakeType != null ? cakeType : "all");

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

        String realPath = request.getServletContext().getRealPath("/");
        String pickupPhoto = findEvidenceFile(realPath, orderNo, "pickup");
        String deliveryPhoto = findEvidenceFile(realPath, orderNo, "delivery");

        request.setAttribute("order", order);
        request.setAttribute("customer", customer);
        request.setAttribute("pickupPhoto", pickupPhoto);
        request.setAttribute("deliveryPhoto", deliveryPhoto);

        request.getRequestDispatcher("/admin/orderDetail.jsp").forward(request, response);
    }

    private String findEvidenceFile(String realPath, String orderNo, String type) {
        java.io.File dir = new java.io.File(realPath + "assets/images/evidence");
        if (dir.exists() && dir.isDirectory()) {
            String prefix = "evidence_" + orderNo + "_" + type;
            java.io.File[] files = dir.listFiles((d, name) -> name.startsWith(prefix));
            if (files != null && files.length > 0) {
                return "assets/images/evidence/" + files[0].getName();
            }
        }
        return "";
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
        
        // Ngăn chặn thay đổi nếu đơn hàng đã bị huỷ hoặc hoàn thành
        if (OrderDAO.isTerminalState(currentStatus)) {
            session.setAttribute("errorMessage", "Đơn hàng đã hoàn thành hoặc đã huỷ, không thể thay đổi trạng thái!");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
            return;
        }

        // Logic 1 chiều: Không cho phép quay lui trạng thái
        int currentLevel = getStatusLevel(currentStatus);
        int newLevel = getStatusLevel(status);
        if (newLevel < currentLevel && newLevel != 6 && currentLevel != 6) { // 6 is cancelled
            session.setAttribute("errorMessage", "Không thể lùi trạng thái đơn hàng (từ " + currentStatus + " về " + status + ")!");
            response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
            return;
        }

        boolean success = orderDAO.updateOrderStatus(orderNo, status);
        if (success) {
            // Tự động phân công Shipper & Gom đơn khi xác nhận/bắt đầu làm/sẵn sàng giao
            if ("Confirmed".equalsIgnoreCase(status) || "Processing".equalsIgnoreCase(status) || "Ready".equalsIgnoreCase(status) || "PAID".equalsIgnoreCase(status)) {
                orderDAO.autoAssignShipperAndTrip(orderNo);
            }
            session.setAttribute("successMessage", "Cập nhật trạng thái đơn hàng #" + orderNo + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Không thể cập nhật trạng thái đơn hàng.");
        }

        response.sendRedirect(request.getContextPath() + "/admin/orders?action=detail&orderNo=" + orderNo);
    }

    private int getStatusLevel(String status) {
        if (status == null) return 0;
        switch (status) {
            case "Pending":
            case "Chờ xác nhận":
                return 1;
            case "Confirmed":
            case "Đã xác nhận":
            case "PAID":
                return 2;
            case "Processing":
            case "Đang làm bánh":
            case "Đang xử lý":
                return 3;
            case "Delivering":
            case "Đang giao hàng":
            case "Đang giao":
                return 4;
            case "Completed":
            case "Hoàn thành":
                return 5;
            case "Cancelled":
            case "Đã hủy":
            case "Canceled":
                return 6;
            default: return 0;
        }
    }
}
