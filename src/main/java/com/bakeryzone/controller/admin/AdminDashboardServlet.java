package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.DashboardDAO;
import com.bakeryzone.model.Order;
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

    private final DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Retrieve statistics from DAO
        double totalRevenue = dashboardDAO.getTotalRevenue();
        int totalOrders = dashboardDAO.getTotalOrders();
        int totalCustomers = dashboardDAO.getTotalCustomers();
        int totalProducts = dashboardDAO.getTotalProducts();
        
        List<Order> recentOrders = dashboardDAO.getRecentOrders(5);
        Map<String, Integer> statusCounts = dashboardDAO.getOrderStatusCounts();
        Map<String, Double> monthlyRevenue = dashboardDAO.getMonthlyRevenueTrend(6);

        // Format data for Chart.js (Revenue Trend)
        StringBuilder revLabels = new StringBuilder();
        StringBuilder revData = new StringBuilder();
        int i = 0;
        for (Map.Entry<String, Double> entry : monthlyRevenue.entrySet()) {
            if (i > 0) {
                revLabels.append(",");
                revData.append(",");
            }
            revLabels.append("\"").append(entry.getKey()).append("\"");
            revData.append(entry.getValue());
            i++;
        }

        // Format data for Chart.js (Order Status Breakdown)
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

        // Set request attributes
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("recentOrders", recentOrders);
        
        request.setAttribute("revenueLabels", revLabels.toString());
        request.setAttribute("revenueData", revData.toString());
        request.setAttribute("statusLabels", statLabels.toString());
        request.setAttribute("statusData", statData.toString());

        // Forward to the JSP view
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
