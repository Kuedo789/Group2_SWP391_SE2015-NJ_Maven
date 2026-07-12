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

@WebServlet(name = "ShipperOrderServlet", urlPatterns = {"/shipper/orders"})
@jakarta.servlet.annotation.MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ShipperOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final CustomerDAO customerDAO = new CustomerDAO();

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

        String contentType = request.getContentType();
        if (contentType != null && contentType.startsWith("multipart/form-data")) {
            handleUploadEvidence(request, response);
            return;
        }

        String action = request.getParameter("action");
        if ("update-status".equals(action)) {
            handleUpdateStatus(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
        }
    }

    private void handleUploadEvidence(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        java.io.PrintWriter out = response.getWriter();
        
        try {
            jakarta.servlet.http.Part filePart = request.getPart("file");
            String tripId = request.getParameter("tripId");
            String orderNo = request.getParameter("orderNo");
            String type = request.getParameter("type"); // "pickup" or "delivery"

            if (filePart == null || filePart.getSize() == 0 || tripId == null || tripId.trim().isEmpty() || type == null || type.trim().isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Dữ liệu gửi lên thiếu hoặc không hợp lệ!\"}");
                return;
            }

            // 1. Tạo thư mục lưu trữ nếu chưa có
            String uploadPath = request.getServletContext().getRealPath("/") + "assets/images/evidence";
            java.io.File uploadDir = new java.io.File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Xóa ảnh cũ cùng loại của riêng đơn hàng này (tự dọn dẹp)
            String prefix = "evidence_" + orderNo + "_" + type;
            java.io.File[] oldFiles = uploadDir.listFiles((d, name) -> name.startsWith(prefix));
            if (oldFiles != null) {
                for (java.io.File f : oldFiles) {
                    f.delete();
                }
            }

            // 2. Lưu file vật lý
            String fileExtension = ".jpg"; // mặc định
            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName != null && submittedFileName.contains(".")) {
                fileExtension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
            }
            
            String fileName = prefix + "_" + System.currentTimeMillis() + fileExtension;
            String relativePath = "assets/images/evidence/" + fileName;
            String absoluteFilePath = uploadPath + java.io.File.separator + fileName;
            filePart.write(absoluteFilePath);

            // 3. Cập nhật cơ sở dữ liệu
            boolean dbSuccess = orderDAO.saveDeliveryEvidence(tripId, relativePath, type);
            if (!dbSuccess) {
                out.print("{\"success\":false,\"message\":\"Không thể lưu thông tin ảnh vào cơ sở dữ liệu!\"}");
                return;
            }

            // 4. Tự động cập nhật trạng thái đơn hàng tương ứng
            String nextStatus = "pickup".equalsIgnoreCase(type) ? "Delivering" : "Completed";
            boolean statusSuccess = orderDAO.updateOrderStatus(orderNo, nextStatus);

            if (statusSuccess) {
                out.print("{\"success\":true,\"message\":\"Tải ảnh lên và cập nhật trạng thái thành công!\",\"photoUrl\":\"" + request.getContextPath() + "/" + relativePath + "\"}");
            } else {
                out.print("{\"success\":true,\"message\":\"Tải ảnh lên thành công nhưng không thể tự động chuyển trạng thái đơn hàng!\",\"photoUrl\":\"" + request.getContextPath() + "/" + relativePath + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Có lỗi xảy ra: " + e.getMessage() + "\"}");
        }
    }

    private void showOrderList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String shipperId = user.getUserId();
        String keyword = request.getParameter("search");
        String statusParam = request.getParameter("status");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String sort = request.getParameter("sort");

        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }

        String statusForDao = null;
        String statusForView = "all";
        if (statusParam != null && !statusParam.trim().isEmpty() && !statusParam.equalsIgnoreCase("all")) {
            statusForDao = statusParam.trim();
            statusForView = statusForDao;
        }

        String dateError = ValidationUtils.validateDateFilter(startDate, endDate);
        if (dateError != null) {
            request.setAttribute("errorMessage", dateError);
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
        int totalRecords = orderDAO.getTotalOrdersCountByShipper(shipperId, keyword, statusForDao, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orders = orderDAO.getOrdersByShipperPaged(shipperId, keyword, statusForDao, startDate, endDate, sort, page, pageSize);

        String managedZone = orderDAO.getManagedZoneByStaffId(shipperId);
        request.setAttribute("managedZone", managedZone);

        request.setAttribute("orders", orders);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", keyword != null ? keyword : "");
        request.setAttribute("status", statusForView);
        request.setAttribute("startDate", startDate != null ? startDate : "");
        request.setAttribute("endDate", endDate != null ? endDate : "");
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("/shipper/orderList.jsp").forward(request, response);
    }

    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderNo = request.getParameter("orderNo");
        if (orderNo == null || orderNo.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);
        if (order == null) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy đơn hàng #" + orderNo);
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
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

        request.getRequestDispatcher("/shipper/orderDetail.jsp").forward(request, response);
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderNo = request.getParameter("orderNo");
        String status = request.getParameter("status");
        String shipperNote = request.getParameter("shipperNote");

        if (orderNo == null || orderNo.trim().isEmpty() || status == null || status.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Dữ liệu trạng thái không hợp lệ!");
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
            return;
        }

        Order order = orderDAO.getOrderByNo(orderNo);
        if (order == null) {
            session.setAttribute("errorMessage", "Không tìm thấy đơn hàng #" + orderNo);
            response.sendRedirect(request.getContextPath() + "/shipper/orders");
            return;
        }

        String currentStatus = order.getOrderStatus();
        if (currentStatus != null && (
                currentStatus.equalsIgnoreCase("Cancelled") || currentStatus.equals("Đã hủy") ||
                currentStatus.equalsIgnoreCase("Completed") || currentStatus.equals("Hoàn thành") || currentStatus.equals("Đã giao"))) {
            session.setAttribute("errorMessage", "Đơn hàng đã hoàn thành hoặc đã huỷ, không thể thay đổi trạng thái!");
            response.sendRedirect(request.getContextPath() + "/shipper/orders?action=detail&orderNo=" + orderNo);
            return;
        }

        boolean success;
        if ("Cancelled".equalsIgnoreCase(status) && shipperNote != null && !shipperNote.trim().isEmpty()) {
            success = orderDAO.updateOrderStatusWithNote(orderNo, status, shipperNote.trim());
        } else {
            success = orderDAO.updateOrderStatus(orderNo, status);
        }

        if (success) {
            session.setAttribute("successMessage", "Cập nhật trạng thái đơn hàng #" + orderNo + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Không thể cập nhật trạng thái đơn hàng.");
        }

        response.sendRedirect(request.getContextPath() + "/shipper/orders?action=detail&orderNo=" + orderNo);
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
}
