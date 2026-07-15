package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AdminVoucherController", urlPatterns = {"/admin/vouchers"})
public class AdminVoucherController extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("toggle".equals(action)) {
            String code = request.getParameter("code");
            boolean status = Boolean.parseBoolean(request.getParameter("status"));
            voucherDAO.toggleVoucherStatus(code, status);
            session.setAttribute("successMessage", "Cập nhật trạng thái voucher thành công!");
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            return;
        } else if ("delete".equals(action)) {
            String code = request.getParameter("code");
            voucherDAO.deleteVoucher(code);
            session.setAttribute("successMessage", "Đã xóa voucher thành công!");
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            return;
        }

        List<Voucher> vouchers = voucherDAO.getAllVouchers();
        request.setAttribute("vouchers", vouchers);

        request.getRequestDispatcher("/admin/voucherList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null || !"ADMIN".equals(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        try {
            String code = request.getParameter("voucherCode");
            BigDecimal discountAmount = new BigDecimal(request.getParameter("discountAmount"));
            BigDecimal minOrderValue = new BigDecimal(request.getParameter("minOrderValue"));
            int totalQuantity = Integer.parseInt(request.getParameter("totalQuantity"));
            int usagePerUser = Integer.parseInt(request.getParameter("usagePerUser"));
            int requiredTierId = Integer.parseInt(request.getParameter("requiredTierId"));
            Date startDate = Date.valueOf(request.getParameter("startDate"));
            Date endDate = Date.valueOf(request.getParameter("endDate"));
            boolean isActive = request.getParameter("isActive") != null;

            Voucher v = new Voucher(code, discountAmount, minOrderValue, totalQuantity, usagePerUser, requiredTierId, startDate, endDate, isActive);

            if ("create".equals(action)) {
                if (voucherDAO.getVoucherByCode(code) != null) {
                    session.setAttribute("errorMessage", "Mã voucher đã tồn tại!");
                } else {
                    voucherDAO.insertVoucher(v);
                    session.setAttribute("successMessage", "Thêm mới voucher thành công!");
                }
            } else if ("update".equals(action)) {
                voucherDAO.updateVoucher(v);
                session.setAttribute("successMessage", "Cập nhật voucher thành công!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/vouchers");
    }
}
