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
                String minSpendStr = request.getParameter("minSpending");
                String multStr = request.getParameter("pointMultiplier");
                String vouchersStr = request.getParameter("monthlyVouchers");
                String description = request.getParameter("description");
                
                if (tierName == null || tierName.trim().isEmpty()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Tên hạng không được để trống.\"}");
                    return;
                }
                
                if (tierName.trim().length() > 50) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Tên hạng không được vượt quá 50 ký tự.\"}");
                    return;
                }

                if (dao.checkDuplicateTierName(tierName, tierId)) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Tên hạng thành viên đã tồn tại.\"}");
                    return;
                }

                if (minSpendStr == null || minSpendStr.trim().isEmpty()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Chi tiêu tối thiểu không được để trống.\"}");
                    return;
                }
                BigDecimal minSpending;
                try {
                    minSpending = new BigDecimal(minSpendStr.trim());
                    if (minSpending.compareTo(BigDecimal.ZERO) < 0) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Chi tiêu tối thiểu không được là số âm.\"}");
                        return;
                    }
                    if (minSpending.compareTo(new BigDecimal("9999999999.99")) > 0) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Chi tiêu tối thiểu không được vượt quá 9,999,999,999.99₫.\"}");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Chi tiêu tối thiểu không hợp lệ.\"}");
                    return;
                }

                if (dao.checkDuplicateMinSpending(minSpending, tierId)) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Mốc chi tiêu tối thiểu này đã tồn tại ở hạng thành viên khác.\"}");
                    return;
                }

                if (multStr == null || multStr.trim().isEmpty()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Hệ số tích điểm không được để trống.\"}");
                    return;
                }
                double pointMultiplier;
                try {
                    pointMultiplier = Double.parseDouble(multStr.trim());
                    if (pointMultiplier < 1.0) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Hệ số tích điểm phải từ 1.0 trở lên.\"}");
                        return;
                    }
                    if (pointMultiplier > 99.9) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Hệ số tích điểm không được vượt quá 99.9.\"}");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Hệ số tích điểm không hợp lệ.\"}");
                    return;
                }

                if (vouchersStr == null || vouchersStr.trim().isEmpty()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Số lượng voucher không được để trống.\"}");
                    return;
                }
                int monthlyVouchers;
                try {
                    monthlyVouchers = Integer.parseInt(vouchersStr.trim());
                    if (monthlyVouchers < 0) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Số lượng voucher không được nhỏ hơn 0.\"}");
                        return;
                    }
                    if (monthlyVouchers > 1000) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Số lượng voucher không được vượt quá 1000.\"}");
                        return;
                    }
                } catch (NumberFormatException e) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Số lượng voucher không hợp lệ.\"}");
                    return;
                }

                if (description != null && description.trim().length() > 500) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Mô tả không được vượt quá 500 ký tự.\"}");
                    return;
                }

                // Validation: monthlyVouchers must be greater than the lower tier
                List<MembershipTier> tiers = dao.getAllTiers();
                MembershipTier lowerTier = null;
                for (MembershipTier existing : tiers) {
                    if (existing.getTierId() != tierId && existing.getMinSpending().compareTo(minSpending) < 0) {
                        if (lowerTier == null || existing.getMinSpending().compareTo(lowerTier.getMinSpending()) > 0) {
                            lowerTier = existing;
                        }
                    }
                }
                if (lowerTier != null && monthlyVouchers <= lowerTier.getMonthlyVouchers()) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Số lượng voucher phải lớn hơn hạng dưới (" + lowerTier.getTierName() + " có " + lowerTier.getMonthlyVouchers() + " voucher).\"}");
                    return;
                }

                MembershipTier t = new MembershipTier(tierId, tierName.trim(), minSpending, pointMultiplier, monthlyVouchers, description == null ? "" : description.trim());
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
