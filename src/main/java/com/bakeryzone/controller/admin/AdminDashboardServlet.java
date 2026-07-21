package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.IngredientDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Order;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.bakeryzone.model.User;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard", "/staff/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final IngredientDAO ingredientDAO = new IngredientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;

        // Lấy dữ liệu thống kê từ DAO
        double totalRevenue = orderDAO.getTotalRevenue(null, null);
        int totalOrders = orderDAO.getTotalOrdersCount(null, null, null, null);
        int totalCustomers = orderDAO.getTotalCustomers(null, null);
        int totalProducts = orderDAO.getTotalProducts();
        
        List<Order> recentOrders = orderDAO.getOrdersPaged(null, null, null, null, null, 1, 5);
        Map<String, Integer> statusCounts = orderDAO.getOrderStatusCounts(null, null);
        List<Map<String, Object>> bestSellers = null;
        List<Map<String, Object>> topCustomers = null;

        // 0. Trích xuất khoảng ngày tùy chỉnh nếu có
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        // Xác thực khoảng ngày
        String dateError = ValidationUtils.validateDateFilter(startDate, endDate);
        if (dateError != null) {
            request.setAttribute("errorMessage", dateError);
            request.getSession().setAttribute("errorMessage", dateError);
            startDate = null;
            endDate = null;
        }

        boolean hasCustomDate = (startDate != null && !startDate.trim().isEmpty() && endDate != null && !endDate.trim().isEmpty());
        if (hasCustomDate) {
            String sDate = startDate.trim();
            String eDate = endDate.trim();
            Map<String, Double> customRevenue = orderDAO.getRevenueTrendCustom(sDate, eDate);
            Map<String, Integer> customOrders = orderDAO.getOrdersTrendCustom(sDate, eDate);
            Map<String, Double> customProfit = orderDAO.getProfitTrendCustom(sDate, eDate);
            
            // Cập nhật lại thông số các thẻ và danh sách theo khoảng ngày tùy chọn
            totalRevenue = orderDAO.getTotalRevenue(sDate, eDate);
            totalOrders = orderDAO.getTotalOrdersCount(null, null, sDate, eDate);
            totalCustomers = orderDAO.getTotalCustomers(sDate, eDate);
            statusCounts = orderDAO.getOrderStatusCounts(sDate, eDate);
            bestSellers = orderDAO.getBestSellingProducts(sDate, eDate, 5);
            topCustomers = orderDAO.getTopCustomers(sDate, eDate, 5);

            request.setAttribute("customRevLabels", mapKeysToString(customRevenue));
            request.setAttribute("customRevData", mapValuesToString(customRevenue));
            request.setAttribute("customOrdLabels", mapKeysToString(customOrders));
            request.setAttribute("customOrdData", mapValuesToString(customOrders));
            request.setAttribute("customPrfLabels", mapKeysToString(customProfit));
            request.setAttribute("customPrfData", mapValuesToString(customProfit));
            request.setAttribute("hasCustomDate", true);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
        } else {
            bestSellers = orderDAO.getBestSellingProducts(null, null, 5);
            topCustomers = orderDAO.getTopCustomers(null, null, 5);
            request.setAttribute("hasCustomDate", false);
            request.setAttribute("startDate", "");
            request.setAttribute("endDate", "");
        }

        // 1. Lấy dữ liệu xu hướng theo tháng (6 tháng gần nhất)
        Map<String, Double> monthlyRevenue = orderDAO.getRevenueTrend("month", 6);
        Map<String, Integer> monthlyOrders = orderDAO.getOrdersTrend("month", 6);
        Map<String, Double> monthlyProfit = orderDAO.getProfitTrend("month", 6);

        // 2. Lấy dữ liệu xu hướng theo ngày (30 ngày gần nhất)
        Map<String, Double> daily30Revenue = orderDAO.getRevenueTrend("day", 30);
        Map<String, Integer> daily30Orders = orderDAO.getOrdersTrend("day", 30);
        Map<String, Double> daily30Profit = orderDAO.getProfitTrend("day", 30);

        // 3. Lấy dữ liệu xu hướng theo ngày (7 ngày qua)
        Map<String, Double> daily7Revenue = orderDAO.getRevenueTrend("day", 7);
        Map<String, Integer> daily7Orders = orderDAO.getOrdersTrend("day", 7);
        Map<String, Double> daily7Profit = orderDAO.getProfitTrend("day", 7);

        // Thiết lập thuộc tính request cho các thẻ thống kê và danh sách
        int totalIngredients = 0;
        try {
            totalIngredients = ingredientDAO.getAllIngredients().size();
        } catch (Exception e) {
            totalIngredients = 0;
        }

        int pendingCount = statusCounts.getOrDefault("Chờ xác nhận", 0) + statusCounts.getOrDefault("Đã xác nhận", 0);
        int processingCount = statusCounts.getOrDefault("Đang xử lý", 0);
        int deliveringCount = statusCounts.getOrDefault("Đang giao", 0);
        int completedCount = statusCounts.getOrDefault("Hoàn thành", 0);

        // Tính % thay đổi doanh thu so với tháng trước (lấy 2 giá trị cuối của map xu hướng 6 tháng)
        java.util.List<Double> revValues = new java.util.ArrayList<>(monthlyRevenue.values());
        double revThisMonth  = revValues.size() > 0 ? revValues.get(revValues.size() - 1) : 0;
        double revLastMonth  = revValues.size() > 1 ? revValues.get(revValues.size() - 2) : 0;
        double revChangePct  = revLastMonth > 0 ? Math.round(((revThisMonth - revLastMonth) / revLastMonth * 100) * 10.0) / 10.0 : (revThisMonth > 0 ? 100.0 : 0.0);

        // Tính % thay đổi số đơn hàng so với tháng trước
        java.util.List<Integer> ordValues = new java.util.ArrayList<>(monthlyOrders.values());
        int ordThisMonth   = ordValues.size() > 0 ? ordValues.get(ordValues.size() - 1) : 0;
        int ordLastMonth   = ordValues.size() > 1 ? ordValues.get(ordValues.size() - 2) : 0;
        double ordChangePct = ordLastMonth > 0 ? Math.round(((ordThisMonth - ordLastMonth) / (double) ordLastMonth * 100) * 10.0) / 10.0 : (ordThisMonth > 0 ? 100.0 : 0.0);

        // Tính % thay đổi số khách hàng (so sánh tháng hiện tại với tháng trước theo dữ liệu DB)
        double custThisMonth = orderDAO.getTotalCustomers(
                java.time.LocalDate.now().withDayOfMonth(1).toString(),
                java.time.LocalDate.now().toString());
        double custLastMonth = orderDAO.getTotalCustomers(
                java.time.LocalDate.now().minusMonths(1).withDayOfMonth(1).toString(),
                java.time.LocalDate.now().minusMonths(1).withDayOfMonth(java.time.LocalDate.now().minusMonths(1).lengthOfMonth()).toString());
        double custChangePct = custLastMonth > 0 ? Math.round(((custThisMonth - custLastMonth) / custLastMonth * 100) * 10.0) / 10.0 : (custThisMonth > 0 ? 100.0 : 0.0);

        // Gán thuộc tính % thay đổi vào request
        request.setAttribute("revChangePct", revChangePct);
        request.setAttribute("ordChangePct", ordChangePct);
        request.setAttribute("custChangePct", custChangePct);
        // Lưu ý: Mẫu bánh (products) là dữ liệu tổng số, không có xu hướng tháng → giữ nguyên không hardcode

        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("totalIngredients", totalIngredients);
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("processingCount", processingCount);
        request.setAttribute("deliveringCount", deliveringCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("bestSellers", bestSellers);
        request.setAttribute("topCustomers", topCustomers);


        // Chuẩn bị danh sách đơn hàng sắp xếp theo thứ tự ưu tiên cho Nhân viên & lấy ghi chú thực tế từ khách hàng
        List<Order> allRecentOrders = orderDAO.getOrdersPaged(null, null, null, null, null, 1, 15);
        List<Order> staffOrders = new java.util.ArrayList<>(allRecentOrders);
        staffOrders.sort((o1, o2) -> {
            int p1 = getStaffStatusPriority(o1.getOrderStatus());
            int p2 = getStaffStatusPriority(o2.getOrderStatus());
            if (p1 != p2) {
                return Integer.compare(p1, p2);
            }
            if (o1.getOrderTime() != null && o2.getOrderTime() != null) {
                return o2.getOrderTime().compareTo(o1.getOrderTime());
            }
            return 0;
        });

        List<Order> noteOrders = new java.util.ArrayList<>();
        for (Order o : allRecentOrders) {
            if (o.getCustomerNote() != null && !o.getCustomerNote().trim().isEmpty()) {
                noteOrders.add(o);
            }
        }
        if (noteOrders.size() < 3) {
            List<Order> extraOrders = orderDAO.getOrdersPaged(null, null, null, null, null, 2, 20);
            for (Order o : extraOrders) {
                if (o.getCustomerNote() != null && !o.getCustomerNote().trim().isEmpty()) {
                    noteOrders.add(o);
                    if (noteOrders.size() >= 5) break;
                }
            }
        }

        // Lấy toàn bộ danh sách đơn hàng Đang xử lý cho Hàng đợi bếp
        List<Order> processingOrdersRaw = orderDAO.getOrdersPaged(null, "Processing", null, null, null, 1, 50);
        List<Order> processingOrders = new java.util.ArrayList<>();
        for (Order o : processingOrdersRaw) {
            Order fullOrder = orderDAO.getOrderByNo(o.getOrderNo());
            processingOrders.add(fullOrder != null ? fullOrder : o);
        }

        Order urgentOrder = !processingOrders.isEmpty() ? processingOrders.get(0) : (!staffOrders.isEmpty() ? staffOrders.get(0) : null);

        request.setAttribute("staffOrders", staffOrders);
        request.setAttribute("noteOrders", noteOrders);
        request.setAttribute("processingOrders", processingOrders);
        request.setAttribute("urgentOrder", urgentOrder);
        
        // Lấy dữ liệu thống kê dành riêng cho Shipper nếu vai trò là SHIPPER
        if (currentUser != null && "SHIPPER".equalsIgnoreCase(currentUser.getRoleId())) {
            String shipperId = currentUser.getUserId();
            String managedZone = orderDAO.getManagedZoneByStaffId(shipperId);
            List<Order> deliveringShipperOrders = orderDAO.getOrdersByShipperPaged(shipperId, null, "Delivering", null, null, "date_desc", 1, 5);
            Order shipperActiveOrder = !deliveringShipperOrders.isEmpty() ? deliveringShipperOrders.get(0) : null;
            int shipperDeliveringCount = orderDAO.getTotalOrdersCountByShipper(shipperId, null, "Delivering", null, null);
            int shipperCompletedCount = orderDAO.getTotalOrdersCountByShipper(shipperId, null, "Completed", null, null);

            Map<String, Object> dailyStats = orderDAO.getShipperDailyStats(shipperId);
            List<Order> readyOrders = orderDAO.getReadyOrdersForShipper(shipperId, 5);
            List<Order> deliveredOrders = orderDAO.getDeliveredOrdersForShipper(shipperId, 5);

            request.setAttribute("shipperManagedZone", managedZone);
            request.setAttribute("shipperActiveOrder", shipperActiveOrder);
            request.setAttribute("deliveringCount", shipperDeliveringCount);
            request.setAttribute("completedCount", shipperCompletedCount);
            request.setAttribute("dailyStats", dailyStats);
            request.setAttribute("readyOrders", readyOrders);
            request.setAttribute("deliveredOrders", deliveredOrders);
        }
        
        // Hàm hỗ trợ định dạng dữ liệu xu hướng thành mảng Javascript
        request.setAttribute("monthlyRevLabels", mapKeysToString(monthlyRevenue));
        request.setAttribute("monthlyRevData", mapValuesToString(monthlyRevenue));
        request.setAttribute("monthlyOrdLabels", mapKeysToString(monthlyOrders));
        request.setAttribute("monthlyOrdData", mapValuesToString(monthlyOrders));
        request.setAttribute("monthlyPrfLabels", mapKeysToString(monthlyProfit));
        request.setAttribute("monthlyPrfData", mapValuesToString(monthlyProfit));

        request.setAttribute("daily30RevLabels", mapKeysToString(daily30Revenue));
        request.setAttribute("daily30RevData", mapValuesToString(daily30Revenue));
        request.setAttribute("daily30OrdLabels", mapKeysToString(daily30Orders));
        request.setAttribute("daily30OrdData", mapValuesToString(daily30Orders));
        request.setAttribute("daily30PrfLabels", mapKeysToString(daily30Profit));
        request.setAttribute("daily30PrfData", mapValuesToString(daily30Profit));

        request.setAttribute("daily7RevLabels", mapKeysToString(daily7Revenue));
        request.setAttribute("daily7RevData", mapValuesToString(daily7Revenue));
        request.setAttribute("daily7OrdLabels", mapKeysToString(daily7Orders));
        request.setAttribute("daily7OrdData", mapValuesToString(daily7Orders));
        request.setAttribute("daily7PrfLabels", mapKeysToString(daily7Profit));
        request.setAttribute("daily7PrfData", mapValuesToString(daily7Profit));

        // Giữ các thuộc tính dự phòng nếu có tham chiếu cũ
        request.setAttribute("revenueLabels", mapKeysToString(monthlyRevenue));
        request.setAttribute("revenueData", mapValuesToString(monthlyRevenue));
        
        StringBuilder statLabels = new StringBuilder();
        StringBuilder statData = new StringBuilder();
        int j = 0;
        for (Map.Entry<String, Integer> entry : statusCounts.entrySet()) {
            if (j > 0) {
                statLabels.append(",");
                statData.append(",");
            }
            statLabels.append("\"").append(entry.getKey()).append("\"");
            statData.append(entry.getValue());
            j++;
        }
        request.setAttribute("statusLabels", statLabels.toString());
        request.setAttribute("statusData", statData.toString());

        // Chuyển hướng tới trang giao diện JSP
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private int getStaffStatusPriority(String status) {
        if (status == null) return 99;
        String s = status.trim().toLowerCase();
        if (s.equals("pending") || s.contains("chờ xác nhận") || s.contains("chờ duyệt")) return 1;
        if (s.equals("confirmed") || s.equals("paid") || s.contains("đã xác nhận") || s.contains("đã thanh toán")) return 2;
        if (s.equals("processing") || s.contains("đang xử lý") || s.contains("đang làm bánh")) return 3;
        if (s.equals("delivering") || s.contains("đang giao")) return 4;
        if (s.equals("completed") || s.contains("hoàn thành")) return 5;
        if (s.equals("cancelled") || s.contains("đã hủy")) return 6;
        return 7;
    }

    private String mapKeysToString(Map<String, ? extends Object> map) {
        StringBuilder sb = new StringBuilder();
        int i = 0;
        for (String key : map.keySet()) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append("\"").append(key).append("\"");
            i++;
        }
        return sb.toString();
    }

    private String mapValuesToString(Map<String, ? extends Number> map) {
        StringBuilder sb = new StringBuilder();
        int i = 0;
        for (Number val : map.values()) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(val);
            i++;
        }
        return sb.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
