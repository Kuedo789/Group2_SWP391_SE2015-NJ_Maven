package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.MembershipDAO;
import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.dao.VoucherDAO.RedeemResult;
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
 * RewardsController – serves the Rewards Exchange marketplace page.
 *
 * URL pattern  : /rewards
 * View         : /customer/rewardsExchange.jsp
 *
 * GET  → display all active vouchers the user can redeem with their points.
 * POST → process a redemption request for a specific voucherId.
 *
 * Session requirements
 * --------------------
 *  The user must be authenticated: session must contain a "user" attribute
 *  (a {@link User} object set by LoginServlet).
 *
 * Request attributes set before GET forward
 * ------------------------------------------
 *  {@code availableRewards} – {@code List<Voucher>} of redeemable vouchers
 *  {@code userPoints}        – {@code int} current accumulated-points balance
 *  {@code successMsg}        – {@code String} (optional) PRG flash message
 *  {@code errorMsg}          – {@code String} (optional) PRG flash message
 *
 * POST / Redirect / GET (PRG) pattern
 * ------------------------------------
 *  After processing the POST, the servlet stores a flash message in the
 *  session and redirects to GET /rewards (or /membership on full success)
 *  to prevent double-submission on browser refresh.
 */
@WebServlet(name = "RewardsController", urlPatterns = {"/rewards"})
public class RewardsController extends HttpServlet {

    private final VoucherDAO    voucherDAO    = new VoucherDAO();
    private final MembershipDAO membershipDAO = new MembershipDAO();

    // -----------------------------------------------------------------------
    // GET – render rewards marketplace
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

        User user   = (User) session.getAttribute("user");
        String userId = user.getUserId();

        // -- Fetch active vouchers for the marketplace grid --
        List<Voucher> rewards = voucherDAO.getAvailableRewards();

        // -- Fetch the user's current point balance --
        int userPoints = 0;
        UserMembership membership = membershipDAO.getMembershipByUserId(userId);
        if (membership != null) {
            userPoints = membership.getAccumulatedPoints();
        }

        // -- Consume PRG flash messages from the session --
        String successMsg = (String) session.getAttribute("rewardSuccess");
        String errorMsg   = (String) session.getAttribute("rewardError");
        session.removeAttribute("rewardSuccess");
        session.removeAttribute("rewardError");

        // -- Bind to request scope for the JSP --
        request.setAttribute("availableRewards", rewards);
        request.setAttribute("userPoints",       userPoints);
        if (successMsg != null) request.setAttribute("successMsg", successMsg);
        if (errorMsg   != null) request.setAttribute("errorMsg",   errorMsg);

        request.getRequestDispatcher("/customer/rewardsExchange.jsp")
               .forward(request, response);
    }

    // -----------------------------------------------------------------------
    // POST – process a redemption request
    // -----------------------------------------------------------------------

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Guard: require authenticated session
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user   = (User) session.getAttribute("user");
        String userId = user.getUserId();

        // -- Parse voucherId from the form --
        int voucherId = 0;
        try {
            String raw = request.getParameter("voucherId");
            if (raw != null && !raw.isBlank()) {
                voucherId = Integer.parseInt(raw.trim());
            }
        } catch (NumberFormatException e) {
            session.setAttribute("rewardError", "Yêu cầu không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/rewards");
            return;
        }

        if (voucherId <= 0) {
            session.setAttribute("rewardError", "Không tìm thấy voucher.");
            response.sendRedirect(request.getContextPath() + "/rewards");
            return;
        }

        // -- Resolve the voucher and its point cost --
        Voucher voucher = voucherDAO.getActiveVoucherById(voucherId);
        if (voucher == null) {
            session.setAttribute("rewardError",
                    "Voucher không còn khả dụng hoặc đã hết hạn.");
            response.sendRedirect(request.getContextPath() + "/rewards");
            return;
        }

        int pointCost = voucher.getPointCost();

        // -- Execute the atomic transaction --
        RedeemResult result = voucherDAO.redeemVoucher(userId, voucherId, pointCost);

        switch (result) {
            case SUCCESS:
                session.setAttribute("rewardSuccess",
                        "🎉 Đổi thưởng thành công! Voucher \"" + voucher.getTitle()
                        + "\" đã được thêm vào tài khoản của bạn.");
                // Redirect to /membership so the updated point balance is visible
                response.sendRedirect(request.getContextPath() + "/membership");
                break;

            case INSUFFICIENT_POINTS:
                session.setAttribute("rewardError",
                        "Bạn không đủ điểm để đổi voucher này. Cần "
                        + pointCost + " điểm.");
                response.sendRedirect(request.getContextPath() + "/rewards");
                break;

            case ALREADY_OWNED:
                session.setAttribute("rewardError",
                        "Bạn đã sở hữu voucher này rồi. Hãy sử dụng trước khi đổi thêm.");
                response.sendRedirect(request.getContextPath() + "/rewards");
                break;

            default:
                session.setAttribute("rewardError",
                        "Đã xảy ra lỗi trong quá trình đổi thưởng. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/rewards");
                break;
        }
    }
}
