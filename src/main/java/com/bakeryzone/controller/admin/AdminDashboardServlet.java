package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Order;
import com.bakeryzone.utils.ValidationUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Retrieve statistics from DAO
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
            
            // Override stats cards and lists for specified date range
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

        // 1. Fetch Monthly Trends (6 months)
        Map<String, Double> monthlyRevenue = orderDAO.getRevenueTrend("month", 6);
        Map<String, Integer> monthlyOrders = orderDAO.getOrdersTrend("month", 6);
        Map<String, Double> monthlyProfit = orderDAO.getProfitTrend("month", 6);

        // 2. Fetch Daily Trends (30 days)
        Map<String, Double> daily30Revenue = orderDAO.getRevenueTrend("day", 30);
        Map<String, Integer> daily30Orders = orderDAO.getOrdersTrend("day", 30);
        Map<String, Double> daily30Profit = orderDAO.getProfitTrend("day", 30);

        // 3. Fetch Daily Trends (7 days)
        Map<String, Double> daily7Revenue = orderDAO.getRevenueTrend("day", 7);
        Map<String, Integer> daily7Orders = orderDAO.getOrdersTrend("day", 7);
        Map<String, Double> daily7Profit = orderDAO.getProfitTrend("day", 7);

        // Set request attributes for stats and lists
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("bestSellers", bestSellers);
        request.setAttribute("topCustomers", topCustomers);
        
        // Helper to format trends for Javascript array insertion
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

        // Keep fallback attributes if old references exist
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

        // Forward to the JSP view
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
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
