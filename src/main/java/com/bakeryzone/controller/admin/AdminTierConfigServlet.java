package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.MembershipDAO;
import com.bakeryzone.model.MembershipTier;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "AdminTierConfigServlet", urlPatterns = {"/admin/tier-config"})
public class AdminTierConfigServlet extends HttpServlet {

    private final MembershipDAO dao = new MembershipDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<MembershipTier> tiers = dao.getAllTiers();
        request.setAttribute("tiers", tiers);
        request.getRequestDispatcher("/admin/tier-config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if ("saveTier".equals(action)) {
            try {
                String idStr = request.getParameter("tierId");
                int tierId = (idStr != null && !idStr.trim().isEmpty()) ? Integer.parseInt(idStr.trim()) : 0;
                
                String tierName = request.getParameter("tierName");
                BigDecimal minSpending = new BigDecimal(request.getParameter("minSpending").trim());
                double pointMultiplier = Double.parseDouble(request.getParameter("pointMultiplier").trim());
                int monthlyVouchers = Integer.parseInt(request.getParameter("monthlyVouchers").trim());
                String description = request.getParameter("description");
                
                if (tierName == null || tierName.trim().isEmpty()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Tên hạng không được để trống.\"}");
                    return;
                }

                MembershipTier t = new MembershipTier(tierId, tierName.trim(), minSpending, pointMultiplier, monthlyVouchers, description);
                boolean success = dao.saveTier(t);
                
                if (success) {
                    response.getWriter().write("{\"status\":\"ok\"}");
                } else {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi lưu cấu hình.\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Dữ liệu đầu vào không hợp lệ.\"}");
            }
        } else if ("deleteTier".equals(action)) {
            try {
                int tierId = Integer.parseInt(request.getParameter("tierId").trim());
                String result = dao.deleteTier(tierId);
                
                if ("ok".equals(result)) {
                    response.getWriter().write("{\"status\":\"ok\"}");
                } else {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"" + result + "\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"status\":\"error\",\"message\":\"ID hạng không hợp lệ.\"}");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
