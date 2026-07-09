package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.model.Voucher;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

/**
 * VoucherManagementServlet – Admin CRUD controller for the Voucher table.
 *
 * URL pattern : /admin/vouchers
 *
 * GET  ?action=list   (default)  → voucher-management.jsp  (list + stats)
 * GET  ?action=add               → voucher-add.jsp          (blank form)
 * GET  ?action=delete&id=N       → hard-delete, redirect back
 * GET  ?action=toggle&id=N       → flip IsActive, redirect back
 * POST (action=create)           → insert new voucher, redirect to list
 */
@WebServlet(name = "VoucherManagementServlet", urlPatterns = {"/admin/vouchers"})
public class VoucherManagementServlet extends HttpServlet {

    private final VoucherDAO dao = new VoucherDAO();

    // =========================================================================
    // GET – Route to appropriate handler
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String action = request.getParameter("action");
            if (action == null || action.isEmpty()) {
                action = "list";
            }

            switch (action) {
                case "add":
                    showAddForm(request, response);
                    break;
                case "delete":
                    handleDelete(request, response);
                    break;
                case "toggle":
                    handleToggle(request, response);
                    break;
                default:
                    listVouchers(request, response);
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi tải dữ liệu voucher.");
        }
    }

    // =========================================================================
    // POST – Handle form submission from voucher-add.jsp
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String formAction = request.getParameter("formAction");

            if ("create".equals(formAction)) {
                handleCreate(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=exception");
        }
    }

    // =========================================================================
    // Private Helpers
    // =========================================================================

    /** Renders the main voucher list with stats metric cards, filters, and pagination. */
    private void listVouchers(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // ── Flash messages ───────────────────────────────────────────────
        String msg     = request.getParameter("msg");
        String error   = request.getParameter("error");
        String success = request.getParameter("success");
        if (msg     != null) request.setAttribute("message", msg);
        if (error   != null) request.setAttribute("error",   error);
        if (success != null) request.setAttribute("success", success);

        // ── Search & status filter ────────────────────────────────────────
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        if (search == null) search = "";
        if (status == null || status.trim().isEmpty()) status = "all";

        // ── Pagination constants ──────────────────────────────────────────
        final int PAGE_SIZE = 6;

        int currentPage = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageStr.trim());
            } catch (NumberFormatException ignored) {
                currentPage = 1;
            }
        }
        if (currentPage < 1) currentPage = 1;

        // ── Count total matching rows (for page math) ─────────────────────
        int totalRecords = dao.getVoucherCount(search, status);
        int totalPages   = (totalRecords == 0) ? 1
                         : (int) Math.ceil((double) totalRecords / PAGE_SIZE);

        // Clamp page to valid range after we know totalPages
        if (currentPage > totalPages) currentPage = totalPages;

        int offset = (currentPage - 1) * PAGE_SIZE;

        // ── Stats (metric cards, always across the whole table) ───────────
        int[] stats = dao.getVoucherStats();
        request.setAttribute("totalVouchers",   stats[0]);
        request.setAttribute("activeVouchers",  stats[1]);
        request.setAttribute("expiredVouchers", stats[2]);

        // ── Paged voucher list ────────────────────────────────────────────
        List<Voucher> vouchers = dao.getAllVouchersPaged(search, status, offset, PAGE_SIZE);
        request.setAttribute("vouchers",      vouchers);
        request.setAttribute("searchQuery",   search);
        request.setAttribute("statusFilter",  status);
        request.setAttribute("currentPage",   currentPage);
        request.setAttribute("totalPages",    totalPages);
        request.setAttribute("totalRecords",  totalRecords);

        request.getRequestDispatcher("/admin/voucher-management.jsp").forward(request, response);
    }

    /** Shows the blank add-voucher form. */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/voucher-add.jsp").forward(request, response);
    }

    /**
     * Parses and validates the POST form, builds a Voucher model object,
     * calls the DAO insert, then redirects.
     */
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // -- Strings --
        String code  = trimOrNull(request.getParameter("voucherCode"));
        String title = trimOrNull(request.getParameter("title"));
        String type  = trimOrNull(request.getParameter("discountType")); // PERCENT | FIXED

        if (code == null || title == null || type == null) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?action=add&error=missing_fields");
            return;
        }

        // -- Numerics (safe BigDecimal parsing) --
        BigDecimal discountValue     = parseBigDecimal(request.getParameter("discountValue"));
        BigDecimal maxDiscountAmount = parseBigDecimal(request.getParameter("maxDiscountAmount"));
        BigDecimal minOrderValue     = parseBigDecimal(request.getParameter("minOrderValue"));

        if (discountValue == null) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?action=add&error=invalid_discount");
            return;
        }

        // -- Dates --
        Date startDate = parseDate(request.getParameter("startDate"));
        Date endDate   = parseDate(request.getParameter("endDate"));

        if (startDate == null || endDate == null) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?action=add&error=invalid_dates");
            return;
        }

        // -- Usage limit (optional int) --
        int usageLimit = 0;
        String usageLimitParam = request.getParameter("usageLimit");
        if (usageLimitParam != null && !usageLimitParam.trim().isEmpty()) {
            try { usageLimit = Integer.parseInt(usageLimitParam.trim()); } catch (NumberFormatException ignored) {}
        }

        // -- Active state --
        boolean isActive = !"false".equalsIgnoreCase(request.getParameter("isActive"));

        // -- Build model --
        Voucher v = new Voucher();
        v.setVoucherCode(code.toUpperCase());
        v.setTitle(title);
        v.setDiscountType(type.toUpperCase());
        v.setDiscountValue(discountValue);
        v.setMaxDiscountAmount(maxDiscountAmount);
        v.setMinOrderValue(minOrderValue != null ? minOrderValue : BigDecimal.ZERO);
        v.setStartDate(startDate);
        v.setEndDate(endDate);
        v.setUsageLimit(usageLimit);
        v.setActive(isActive);

        // -- Persist --
        boolean ok = dao.addVoucher(v);
        if (ok) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=created");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?action=add&error=db_error");
        }
    }

    /**
     * Deletes a voucher by ID.  If a FK constraint blocks the hard delete,
     * falls back to deactivating it instead.
     */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            return;
        }

        int id;
        try { id = Integer.parseInt(idParam.trim()); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=invalid_id");
            return;
        }

        boolean ok = dao.deleteVoucher(id);
        if (ok) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=deleted");
        } else {
            // FK constraint most likely – fall back to soft-disable
            boolean softOk = dao.updateVoucherStatus(id, false);
            if (softOk) {
                response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=deactivated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=delete_failed");
            }
        }
    }

    /** Flips the IsActive status of a voucher. */
    private void handleToggle(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idParam    = request.getParameter("id");
        String activeParam = request.getParameter("active"); // "true" or "false"

        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers");
            return;
        }

        int id;
        try { id = Integer.parseInt(idParam.trim()); }
        catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=invalid_id");
            return;
        }

        // Default: flip to active.  If the caller passes active=false, deactivate.
        boolean activate = !"false".equalsIgnoreCase(activeParam);
        boolean ok = dao.updateVoucherStatus(id, activate);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?success=" + (activate ? "activated" : "deactivated"));
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/vouchers?error=toggle_failed");
        }
    }

    // =========================================================================
    // Utility
    // =========================================================================

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private BigDecimal parseBigDecimal(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return new BigDecimal(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    private Date parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Date.valueOf(s.trim()); }
        catch (IllegalArgumentException e) { return null; }
    }

    @Override
    public String getServletInfo() {
        return "Admin Voucher Management Controller";
    }
}
