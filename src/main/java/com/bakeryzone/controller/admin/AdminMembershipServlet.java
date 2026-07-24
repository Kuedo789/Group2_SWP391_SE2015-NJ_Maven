package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.MembershipDAO;
import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.MembershipAdminRow;
import com.bakeryzone.model.MembershipTier;
import com.bakeryzone.model.PointHistory;
import com.bakeryzone.model.User;
import com.bakeryzone.model.UserMembership;
import com.bakeryzone.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(name = "AdminMembershipServlet", urlPatterns = {"/admin/membership"})
public class AdminMembershipServlet extends HttpServlet {

    private final MembershipDAO dao = new MembershipDAO();
    private final UserDAO userDAO = new UserDAO();
    private final DecimalFormat moneyFormat = new DecimalFormat("#,###₫");
    private final DecimalFormat numFormat = new DecimalFormat("#,###");
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null || action.isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                showDetailAjax(request, response);
                break;
            default:
                listMembers(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("adjustPoints".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            String userId = request.getParameter("userId");
            String amountStr = request.getParameter("amount");
            String reasonType = request.getParameter("reasonType");
            String notes = request.getParameter("notes");
            
            if (userId == null || amountStr == null || reasonType == null) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Thiếu thông tin bắt buộc.\"}");
                return;
            }
            
            try {
                int delta = Integer.parseInt(amountStr.trim());
                String description = reasonType;
                if (notes != null && !notes.trim().isEmpty()) {
                    description += " - " + notes.trim();
                }
                
                boolean success = dao.adjustPoints(userId, delta, description);
                if (success) {
                    UserMembership um = dao.getMembershipByUserId(userId);
                    int newPoints = um != null ? um.getAccumulatedPoints() : 0;
                    response.getWriter().write("{\"status\":\"ok\",\"newPoints\":" + newPoints + "}");
                } else {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi cập nhật điểm.\"}");
                }
            } catch (NumberFormatException e) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Số điểm không hợp lệ.\"}");
            }
        } else if ("upgradeTier".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            String userId = request.getParameter("userId");
            String tierIdStr = request.getParameter("tierId");
            
            if (userId == null || tierIdStr == null) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Thiếu thông tin bắt buộc.\"}");
                return;
            }
            
            try {
                int tierId = Integer.parseInt(tierIdStr.trim());
                boolean success = dao.setTier(userId, tierId);
                
                if (success) {
                    response.getWriter().write("{\"status\":\"ok\"}");
                } else {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi nâng hạng.\"}");
                }
            } catch (NumberFormatException e) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Hạng không hợp lệ.\"}");
            }
        } else if ("assignVoucher".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            String userId = request.getParameter("userId");
            String voucherCode = request.getParameter("voucherCode");
            
            if (userId == null || voucherCode == null || voucherCode.trim().isEmpty()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Thiếu thông tin bắt buộc.\"}");
                return;
            }
            
            boolean success = dao.assignVoucherByCode(userId, voucherCode.trim());
            
            if (success) {
                response.getWriter().write("{\"status\":\"ok\"}");
            } else {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Gán voucher thất bại. Mã voucher không tồn tại hoặc khách hàng đã sở hữu voucher này.\"}");
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private void listMembers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String search = request.getParameter("search");
        String tier = request.getParameter("tier");

        if (search == null) search = "";
        if (tier == null || tier.trim().isEmpty()) tier = "all";

        final int PAGE_SIZE = 10;
        int currentPage = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try { currentPage = Integer.parseInt(pageStr.trim()); } catch (Exception ignored) {}
        }
        if (currentPage < 1) currentPage = 1;

        int totalRecords = dao.getMemberCount(tier, search);
        int totalPages = (totalRecords == 0) ? 1 : (int) Math.ceil((double) totalRecords / PAGE_SIZE);
        if (currentPage > totalPages) currentPage = totalPages;

        int offset = (currentPage - 1) * PAGE_SIZE;

        int[] stats = dao.getMemberStats();
        request.setAttribute("totalMembers", stats[0]);
        request.setAttribute("standardCount", stats[1]);
        request.setAttribute("bronzeCount", stats[2]);
        request.setAttribute("silverCount", stats[3]);
        request.setAttribute("goldCount", stats[4]);
        request.setAttribute("diamondCount", stats[5]);
        
        List<MembershipTier> allTiers = dao.getAllTiers();
        request.setAttribute("allTiers", allTiers);
        
        List<Voucher> allActiveVouchers = dao.getAllActiveVouchers();
        request.setAttribute("allActiveVouchers", allActiveVouchers);

        List<MembershipAdminRow> members = dao.getMemberListPaged(tier, search, offset, PAGE_SIZE);
        
        request.setAttribute("members", members);
        request.setAttribute("searchQuery", search);
        request.setAttribute("tierFilter", tier);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);

        request.getRequestDispatcher("/admin/membership-overview.jsp").forward(request, response);
    }

    private void showDetailAjax(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String userId = request.getParameter("userId");
        if (userId == null || userId.trim().isEmpty()) {
            out.write("{\"error\": \"Missing userId\"}");
            return;
        }

        UserMembership um = dao.getMembershipByUserId(userId);
        if (um == null) {
            out.write("{\"error\": \"User not found\"}");
            return;
        }

        User user = userDAO.getUserById(userId);
        if (user == null) {
            out.write("{\"error\": \"User not found in user table\"}");
            return;
        }

        List<PointHistory> history = dao.getPointHistory(userId, 3);
        List<Voucher> ownedVouchers = dao.getUserOwnedVouchers(userId);

        String fullName = user.getFullName() != null ? user.getFullName() : "Chưa cập nhật";
        String initial = fullName.substring(0, 1).toUpperCase();
        
        MembershipTier ct = um.getCurrentTier();
        String tierCode = ct.getTierName().toLowerCase();
        if ("member".equals(tierCode)) tierCode = "standard";

        String progressLabel = "Đã đạt hạng tối đa hiện tại";
        if (um.getNextTier() != null) {
            progressLabel = numFormat.format(um.getTotalSpending()) + " / " + numFormat.format(um.getNextTier().getMinSpending()) + "₫ đến " + um.getNextTier().getTierName();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"name\":\"").append(escapeJson(fullName)).append("\",");
        sb.append("\"initials\":\"").append(initial).append("\",");
        sb.append("\"avatarGrad\":\"").append(getAvatarGrad(tierCode)).append("\",");
        sb.append("\"id\":\"").append(escapeJson(userId)).append("\",");
        sb.append("\"email\":\"").append(escapeJson(user.getEmail())).append("\",");
        sb.append("\"tier\":\"").append(tierCode).append("\",");
        sb.append("\"points\":\"").append(numFormat.format(um.getAccumulatedPoints())).append("\",");
        sb.append("\"spending\":\"").append(moneyFormat.format(um.getTotalSpending())).append("\",");
        sb.append("\"vouchers\":").append(ownedVouchers.size()).append(",");
        sb.append("\"progressPct\":").append((int) um.getProgressPercent()).append(",");
        sb.append("\"progressLabel\":\"").append(escapeJson(progressLabel)).append("\",");

        // History
        sb.append("\"history\":[");
        for (int i = 0; i < history.size(); i++) {
            PointHistory ph = history.get(i);
            sb.append("{");
            sb.append("\"date\":\"").append(dateFormat.format(ph.getCreatedAt())).append("\",");
            sb.append("\"desc\":\"").append(escapeJson(ph.getDescription())).append("\",");
            String sign = ph.getAmount() >= 0 ? "+" : "";
            sb.append("\"pts\":\"").append(sign).append(ph.getAmount()).append("\",");
            sb.append("\"type\":\"").append(ph.getAmount() >= 0 ? "earned" : "spent").append("\"");
            sb.append("}");
            if (i < history.size() - 1) sb.append(",");
        }
        sb.append("],");

        // Vouchers
        sb.append("\"ownedVouchers\":[");
        for (int i = 0; i < ownedVouchers.size(); i++) {
            sb.append("\"").append(escapeJson(ownedVouchers.get(i).getVoucherCode())).append("\"");
            if (i < ownedVouchers.size() - 1) sb.append(",");
        }
        sb.append("]");
        sb.append("}");

        out.write(sb.toString());
    }

    private String getAvatarGrad(String tierCode) {
        switch (tierCode) {
            case "diamond":
                return "linear-gradient(135deg,#c4b5fd,#8b5cf6)";
            case "gold":
                return "linear-gradient(135deg,#f59e0b,#d97706)";
            case "silver":
                return "linear-gradient(135deg,#94a3b8,#64748b)";
            case "bronze":
                return "linear-gradient(135deg,#fde68a,#d97706)";
            default:
                return "linear-gradient(135deg,#bfdbfe,#3b82f6)";
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
