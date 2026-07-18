package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.MembershipDAO;
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
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * MembershipController – serves the Membership Dashboard page.
 *
 * URL pattern : /membership
 * View        : /customer/membershipDashboard.jsp
 *
 * Session requirement: The user must be logged in with a valid "user" attribute
 * (populated by LoginServlet as a {@link User} object).
 *
 * Request attributes set before forwarding to the view:
 * <ul>
 *   <li>{@code membership}     – {@link UserMembership} with currentTier and nextTier populated</li>
 *   <li>{@code allTiers}       – {@code List<MembershipTier>} ordered MEMBER → DIAMOND</li>
 *   <li>{@code pointHistory}   – {@code List<PointHistory>} most-recent 20 transactions</li>
 *   <li>{@code ownedVouchers}  – {@code List<Voucher>} un-used, in-date vouchers in the user wallet</li>
 * </ul>
 */
@WebServlet(name = "MembershipController", urlPatterns = {"/membership"})
public class MembershipController extends HttpServlet {

    /** Max point-history rows shown on the dashboard. */
    private static final int POINT_HISTORY_LIMIT = 20;

    private final MembershipDAO membershipDAO = new MembershipDAO();

    // -----------------------------------------------------------------------
    // GET – render dashboard
    // -----------------------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Guard: require authenticated session
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String userId = user.getUserId();

        // Detect whether this is an AJAX wallet-filter request.
        // The JS Fetch call will include the header X-Requested-With: XMLHttpRequest.
        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        // Load membership record; create defaults on first visit if absent
        UserMembership membership = membershipDAO.getMembershipByUserId(userId);

        if (membership == null) {
            // Lazy initialisation: provision a MEMBER-tier row for this user
            boolean created = membershipDAO.initMembershipForUser(userId);
            if (created) {
                membership = membershipDAO.getMembershipByUserId(userId);
            }
        }

        if (membership == null) {
            if (isAjax) {
                // Return a minimal error fragment for the AJAX caller
                response.setContentType("text/html;charset=UTF-8");
                response.getWriter().write("<div class=\"ms-wallet-empty\"><p>Không thể tải dữ liệu.</p></div>");
                return;
            }
            // Fallback safety: membership tables may not be set up yet
            request.setAttribute("membershipError",
                    "Không thể tải thông tin hạng thành viên. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/customer/membershipDashboard.jsp")
                    .forward(request, response);
            return;
        }

        // Load the user's own un-used, still-valid vouchers for the wallet section.
        // Honour optional ?scope= and ?search= query parameters for wallet filtering.
        String walletScope  = request.getParameter("scope");   // null | all | ORDER | SHIPPING
        String walletSearch = request.getParameter("search");  // null | keyword
        if (walletScope == null || walletScope.isBlank()) {
            walletScope = "all";
        }
        if (walletSearch == null) {
            walletSearch = "";
        }
        List<Voucher> ownedVouchers = membershipDAO.getUserOwnedVouchers(
                userId,
                "all".equalsIgnoreCase(walletScope) ? null : walletScope,
                walletSearch);

        request.setAttribute("ownedVouchers", ownedVouchers);
        request.setAttribute("walletScope",   walletScope);
        request.setAttribute("walletSearch",  walletSearch);

        // ── AJAX path: return only the voucher list fragment ──────────────────
        if (isAjax) {
            response.setContentType("text/html;charset=UTF-8");
            request.getRequestDispatcher("/customer/walletFragment.jsp")
                    .forward(request, response);
            return;
        }

        // ── Full-page path: load the remaining data and render the dashboard ──
        List<MembershipTier> allTiers = membershipDAO.getAllTiers();
        List<PointHistory>   pointHistory = membershipDAO.getPointHistory(userId, POINT_HISTORY_LIMIT);

        // Bind to request scope → JSP reads via EL: ${membership}, ${ownedVouchers}, etc.
        request.setAttribute("membership",    membership);
        request.setAttribute("allTiers",      allTiers);
        request.setAttribute("pointHistory",  pointHistory);

        // Also consume the PRG flash message placed by RewardsController on success
        String rewardSuccess = (String) session.getAttribute("rewardSuccess");
        if (rewardSuccess != null) {
            request.setAttribute("successMsg", rewardSuccess);
            session.removeAttribute("rewardSuccess");
        }

        request.getRequestDispatcher("/customer/membershipDashboard.jsp")
                .forward(request, response);
    }

    // -----------------------------------------------------------------------
    // POST – not used for this read-only dashboard; redirect to GET
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/membership");
    }
}
