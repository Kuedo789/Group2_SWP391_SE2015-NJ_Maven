package com.bakeryzone.dao;

import com.bakeryzone.model.Voucher;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * VoucherDAO – database access for the Rewards Exchange feature.
 *
 * Responsibilities:
 *  1. Fetching active, in-date vouchers available for redemption.
 *  2. Executing the atomic voucher-redemption transaction:
 *       a) Validate the user has sufficient AccumulatedPoints.
 *       b) Deduct the point cost from UserMembership.
 *       c) Insert a row into UserVoucher.
 *       d) Insert a REDEEM entry into PointHistory.
 *
 * All writes are executed inside a single JDBC transaction with
 * autoCommit = false so that either all four steps succeed or
 * none of them are persisted (full rollback on any error).
 *
 * Point-cost convention:
 *   The Voucher table currently does not have a dedicated PointCost column.
 *   The cost is derived in-memory from the discount value using the formula:
 *       pointCost = FIXED: round(DiscountValue / 1_000)   (1 pt per 1,000 ₫)
 *       pointCost = PERCENT: round(DiscountValue * 5)     (5 pts per % point)
 *   This keeps the DAO self-contained until a PointCost column is added to
 *   the schema.  To switch to a DB column simply replace the two lines in
 *   mapVoucher() that compute pointCost.
 */
public class VoucherDAO {

    // -----------------------------------------------------------------------
    // Redemption result codes
    // -----------------------------------------------------------------------

    public enum RedeemResult {
        SUCCESS,
        INSUFFICIENT_POINTS,
        VOUCHER_NOT_FOUND,
        ALREADY_OWNED,
        ERROR
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /**
     * Fetches all vouchers that are:
     *   - Marked active (IsActive = 1)
     *   - Currently within their validity window (StartDate ≤ TODAY ≤ EndDate)
     *
     * Results are ordered by DiscountValue DESC so the most generous rewards
     * appear first on the rewards page.
     *
     * @return list of available Voucher objects (may be empty, never null)
     */
    public List<Voucher> getAvailableRewards() {

        List<Voucher> list = new ArrayList<>();

        String sql =
            "SELECT VoucherID, VoucherCode, Title, DiscountType, DiscountValue, "
            + "       MaxDiscountAmount, MinOrderValue, StartDate, EndDate, "
            + "       IsActive, UsageLimit, RequiredTierID "
            + "FROM Voucher "
            + "WHERE IsActive = 1 "
            + "  AND CURDATE() BETWEEN StartDate AND EndDate "
            + "ORDER BY DiscountValue DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return list;
            }

            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapVoucher(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    /**
     * Looks up a single active, in-date voucher by its primary key.
     * Used by RewardsController to resolve the point cost before executing
     * the redemption transaction.
     *
     * @param voucherId the voucher to look up
     * @return the Voucher, or null if not found / no longer active
     */
    public Voucher getActiveVoucherById(int voucherId) {

        String sql =
            "SELECT VoucherID, VoucherCode, Title, DiscountType, DiscountValue, "
            + "       MaxDiscountAmount, MinOrderValue, StartDate, EndDate, "
            + "       IsActive, UsageLimit, RequiredTierID "
            + "FROM Voucher "
            + "WHERE VoucherID = ? "
            + "  AND IsActive = 1 "
            + "  AND CURDATE() BETWEEN StartDate AND EndDate";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return null;
            }

            ps = conn.prepareStatement(sql);
            ps.setInt(1, voucherId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapVoucher(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return null;
    }

    /**
     * Executes the full point-redemption transaction atomically.
     *
     * Steps (all-or-nothing):
     *   1. Re-read the user's current AccumulatedPoints inside the transaction
     *      to guard against race conditions (SELECT ... FOR UPDATE).
     *   2. Verify points >= pointCost; abort with INSUFFICIENT_POINTS if not.
     *   3. Check whether the user already owns an un-used copy of the voucher;
     *      abort with ALREADY_OWNED if so (prevents duplicate redemptions).
     *   4. Deduct pointCost from UserMembership.AccumulatedPoints.
     *   5. Insert a new UserVoucher row (IsUsed = 0).
     *   6. Insert a PointHistory row (ChangeType = 'REDEEM', Amount = pointCost).
     *   7. COMMIT on success, ROLLBACK on any failure.
     *
     * @param userId    the user redeeming the reward
     * @param voucherId the voucher being redeemed
     * @param pointCost the points to deduct (derived from the Voucher object)
     * @return a {@link RedeemResult} enum value indicating the outcome
     */
    public RedeemResult redeemVoucher(String userId, int voucherId, int pointCost) {

        Connection conn = null;

        // Individual PreparedStatements are declared here so we can close
        // them in the finally block regardless of which step fails.
        PreparedStatement psCheckPoints = null;
        PreparedStatement psCheckOwned  = null;
        PreparedStatement psDeduct      = null;
        PreparedStatement psInsertUV    = null;
        PreparedStatement psInsertPH    = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return RedeemResult.ERROR;
            }

            conn.setAutoCommit(false);

            // ------------------------------------------------------------------
            // Step 1 – read current points (locking the row for the transaction)
            // ------------------------------------------------------------------
            String sqlCheck = "SELECT AccumulatedPoints FROM UserMembership "
                            + "WHERE UserID = ? FOR UPDATE";
            psCheckPoints = conn.prepareStatement(sqlCheck);
            psCheckPoints.setString(1, userId);
            rs = psCheckPoints.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return RedeemResult.ERROR;
            }

            int currentPoints = rs.getInt("AccumulatedPoints");
            rs.close();
            psCheckPoints.close();

            // ------------------------------------------------------------------
            // Step 2 – verify sufficient balance
            // ------------------------------------------------------------------
            if (currentPoints < pointCost) {
                conn.rollback();
                return RedeemResult.INSUFFICIENT_POINTS;
            }

            // ------------------------------------------------------------------
            // Step 3 – guard against re-redemption of the same voucher
            // ------------------------------------------------------------------
            String sqlOwned = "SELECT UserVoucherID FROM UserVoucher "
                            + "WHERE UserID = ? AND VoucherID = ? AND IsUsed = 0";
            psCheckOwned = conn.prepareStatement(sqlOwned);
            psCheckOwned.setString(1, userId);
            psCheckOwned.setInt(2, voucherId);
            rs = psCheckOwned.executeQuery();

            if (rs.next()) {
                conn.rollback();
                return RedeemResult.ALREADY_OWNED;
            }
            rs.close();
            psCheckOwned.close();

            // ------------------------------------------------------------------
            // Step 4 – deduct points
            // ------------------------------------------------------------------
            String sqlDeduct = "UPDATE UserMembership "
                             + "SET AccumulatedPoints = AccumulatedPoints - ? "
                             + "WHERE UserID = ?";
            psDeduct = conn.prepareStatement(sqlDeduct);
            psDeduct.setInt(1, pointCost);
            psDeduct.setString(2, userId);
            int deductRows = psDeduct.executeUpdate();

            if (deductRows == 0) {
                conn.rollback();
                return RedeemResult.ERROR;
            }

            // ------------------------------------------------------------------
            // Step 5 – insert UserVoucher
            // ------------------------------------------------------------------
            String sqlInsertUV =
                "INSERT INTO UserVoucher (UserID, VoucherID, IsUsed, AssignedAt) "
                + "VALUES (?, ?, 0, NOW())";
            psInsertUV = conn.prepareStatement(sqlInsertUV);
            psInsertUV.setString(1, userId);
            psInsertUV.setInt(2, voucherId);
            psInsertUV.executeUpdate();

            // ------------------------------------------------------------------
            // Step 6 – insert PointHistory
            // ------------------------------------------------------------------
            String sqlInsertPH =
                "INSERT INTO PointHistory (UserID, Amount, ChangeType, Description, CreatedAt) "
                + "VALUES (?, ?, 'REDEEM', ?, NOW())";
            psInsertPH = conn.prepareStatement(sqlInsertPH);
            psInsertPH.setString(1, userId);
            psInsertPH.setInt(2, pointCost);
            psInsertPH.setString(3, "Đổi thưởng voucher #" + voucherId);
            psInsertPH.executeUpdate();

            // ------------------------------------------------------------------
            // Step 7 – commit
            // ------------------------------------------------------------------
            conn.commit();
            return RedeemResult.SUCCESS;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return RedeemResult.ERROR;

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            // Close in reverse order of creation
            close(null, psInsertPH, null);
            close(null, psInsertUV, null);
            close(null, psDeduct,   null);
            close(null, psCheckOwned, null);
            close(conn, psCheckPoints, rs);
        }
    }

    // -----------------------------------------------------------------------
    // Private helpers
    // -----------------------------------------------------------------------

    /**
     * Maps one ResultSet row to a Voucher and computes the in-memory pointCost.
     *
     * Point-cost formula (no DB column required):
     *   FIXED   → round(DiscountValue / 1_000)  — 1 pt per 1,000 ₫ discount
     *   PERCENT → round(DiscountValue * 5)       — 5 pts per percentage point
     */
    private Voucher mapVoucher(ResultSet rs) throws Exception {
        Voucher v = new Voucher();
        v.setVoucherId(rs.getInt("VoucherID"));
        v.setVoucherCode(rs.getString("VoucherCode"));
        v.setTitle(rs.getString("Title"));
        v.setDiscountType(rs.getString("DiscountType"));
        v.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        v.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));
        v.setMinOrderValue(rs.getBigDecimal("MinOrderValue"));

        // Convert java.sql.Date safely
        Date startDate = rs.getDate("StartDate");
        Date endDate   = rs.getDate("EndDate");
        v.setStartDate(startDate);
        v.setEndDate(endDate);

        v.setActive(rs.getBoolean("IsActive"));
        v.setUsageLimit(rs.getInt("UsageLimit"));

        int reqTier = rs.getInt("RequiredTierID");
        v.setRequiredTierId(rs.wasNull() ? null : reqTier);

        // Derive point cost from discount value
        if (v.getDiscountValue() != null) {
            double dv = v.getDiscountValue().doubleValue();
            int cost;
            if ("PERCENT".equalsIgnoreCase(v.getDiscountType())) {
                cost = (int) Math.round(dv * 5);
            } else {
                // FIXED – 1 pt per 1,000 ₫, minimum 10 pts
                cost = (int) Math.max(10, Math.round(dv / 1_000.0));
            }
            v.setPointCost(cost);
        } else {
            v.setPointCost(50); // safe fallback
        }

        return v;
    }

    private void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null)   rs.close();
            if (ps != null)   ps.close();
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
