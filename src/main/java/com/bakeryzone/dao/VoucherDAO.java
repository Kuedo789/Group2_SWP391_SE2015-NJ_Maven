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
            "SELECT * "
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
            "SELECT * "
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
        
        java.sql.ResultSetMetaData meta = rs.getMetaData();
        int colCount = meta.getColumnCount();
        java.util.Set<String> cols = new java.util.HashSet<>();
        for (int i = 1; i <= colCount; i++) {
            cols.add(meta.getColumnLabel(i).toUpperCase());
        }

        v.setVoucherId(rs.getInt("VoucherID"));
        v.setVoucherCode(rs.getString("VoucherCode"));
        
        if (cols.contains("TITLE")) v.setTitle(rs.getString("Title"));
        if (cols.contains("DISCOUNTTYPE")) v.setDiscountType(rs.getString("DiscountType"));
        if (cols.contains("DISCOUNTVALUE")) v.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        if (cols.contains("MAXDISCOUNTAMOUNT")) v.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));
        if (cols.contains("MINORDERVALUE")) v.setMinOrderValue(rs.getBigDecimal("MinOrderValue"));

        // The schema defines StartDate/EndDate as DATETIME (not DATE).
        // rs.getDate() on a DATETIME column can return null in MySQL JDBC 8 strict mode.
        // Use getTimestamp() and convert to java.sql.Date via the millisecond value.
        if (cols.contains("STARTDATE")) {
            java.sql.Timestamp startTs = rs.getTimestamp("StartDate");
            v.setStartDate(startTs != null ? new Date(startTs.getTime()) : null);
        }
        if (cols.contains("ENDDATE")) {
            java.sql.Timestamp endTs = rs.getTimestamp("EndDate");
            v.setEndDate(endTs != null ? new Date(endTs.getTime()) : null);
        }

        if (cols.contains("ISACTIVE")) v.setActive(rs.getBoolean("IsActive"));
        if (cols.contains("USAGELIMIT")) v.setUsageLimit(rs.getInt("UsageLimit"));

        if (cols.contains("REQUIREDTIERID")) {
            int reqTier = rs.getInt("RequiredTierID");
            v.setRequiredTierId(rs.wasNull() ? null : reqTier);
        }

        if (cols.contains("VOUCHERSCOPE")) v.setVoucherScope(rs.getString("VoucherScope"));
        if (cols.contains("TARGETCATEGORY")) v.setTargetCategory(rs.getString("TargetCategory"));
        if (cols.contains("ISSTACKABLE")) v.setStackable(rs.getBoolean("IsStackable"));

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

    /**
     * Looks up a specific voucher by its code, but ONLY if the user owns it
     * (in UserVoucher) and it hasn't been used yet.
     */
    public Voucher getVoucherByCodeAndUser(String voucherCode, String userId) {
        String sql =
            "SELECT v.* "
            + "FROM UserVoucher uv "
            + "JOIN Voucher v ON uv.VoucherID = v.VoucherID "
            + "WHERE v.VoucherCode = ? "
            + "  AND uv.UserID = ? "
            + "  AND uv.IsUsed = 0 "
            + "  AND v.IsActive = 1 "
            + "  AND CURDATE() BETWEEN v.StartDate AND v.EndDate";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return null;

            ps = conn.prepareStatement(sql);
            ps.setString(1, voucherCode);
            ps.setString(2, userId);
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
     * Fetches all valid, unused vouchers for a specific user, ordered by scope and discount value.
     */
    public List<Voucher> getAvailableVouchersForUser(String userId) {
        List<Voucher> list = new ArrayList<>();
        String sql =
            "SELECT v.* "
            + "FROM UserVoucher uv "
            + "JOIN Voucher v ON uv.VoucherID = v.VoucherID "
            + "WHERE uv.UserID = ? "
            + "  AND uv.IsUsed = 0 "
            + "  AND v.IsActive = 1 "
            + "  AND CURDATE() BETWEEN v.StartDate AND v.EndDate "
            + "ORDER BY v.VoucherScope DESC, v.DiscountValue DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return list;

            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
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
     * Marks a user's private voucher as used after a successful checkout.
     */
    public void markVoucherUsed(int voucherId, String userId) {
        String sql = "UPDATE UserVoucher SET IsUsed = 1 WHERE VoucherID = ? AND UserID = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return;

            ps = conn.prepareStatement(sql);
            ps.setInt(1, voucherId);
            ps.setString(2, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
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

    // =========================================================================
    // ADMIN MANAGEMENT METHODS
    // =========================================================================

    /**
     * Returns aggregate statistics for the admin dashboard metric cards.
     * Executes a single round-trip query using conditional aggregation.
     *
     * @return int[3]:  [0] = total count, [1] = active count, [2] = expired/inactive count
     */
    public int[] getVoucherStats() {
        int[] stats = {0, 0, 0};

        String sql = "SELECT "
            + "  COUNT(*) AS TotalCount, "
            + "  COALESCE(SUM(CASE WHEN IsActive = 1 AND EndDate >= CURDATE() THEN 1 ELSE 0 END), 0) AS ActiveCount, "
            + "  COALESCE(SUM(CASE WHEN IsActive = 0 OR EndDate < CURDATE() THEN 1 ELSE 0 END), 0) AS ExpiredCount "
            + "FROM voucher";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return stats;

            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                stats[0] = rs.getInt("TotalCount");
                stats[1] = rs.getInt("ActiveCount");
                stats[2] = rs.getInt("ExpiredCount");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return stats;
    }

    /**
     * Returns the total number of vouchers matching the given filters.
     * Used by the servlet to calculate totalPages for the pagination widget.
     *
     * @param searchKeyword  text to match against VoucherCode or Title (null = no filter)
     * @param statusFilter   "ACTIVE", "EXPIRED", "INACTIVE", or null/"all" for all records
     * @return count of matching rows
     */
    public int getVoucherCount(String searchKeyword, String statusFilter) {
        boolean hasSearch = isNonBlank(searchKeyword) && !"all".equalsIgnoreCase(searchKeyword.trim());
        boolean hasStatus = isNonBlank(statusFilter)  && !"all".equalsIgnoreCase(statusFilter.trim());

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM voucher WHERE 1=1 ");
        appendStatusClause(sql, statusFilter, hasStatus);
        if (hasSearch) sql.append("AND (VoucherCode LIKE ? OR Title LIKE ?) ");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int count = 0;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return 0;

            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (hasSearch) {
                String p = "%" + searchKeyword.trim() + "%";
                ps.setString(idx++, p);
                ps.setString(idx++, p);
            }
            rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);

        } catch (Exception e) {
            System.err.println("[VoucherDAO.getVoucherCount] " + e.getMessage());
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return count;
    }

    /**
     * Fetches one page of vouchers for the admin management table.
     *
     * @param searchKeyword  text to match against VoucherCode or Title (null = no filter)
     * @param statusFilter   "ACTIVE", "EXPIRED", "INACTIVE", or null/"all" for all records
     * @param offset         0-based row offset (= (page-1) * limit)
     * @param limit          page size (e.g. 6)
     * @return list of Voucher objects for the requested page (may be empty, never null)
     */
    public List<Voucher> getAllVouchersPaged(String searchKeyword, String statusFilter,
                                            int offset, int limit) {
        List<Voucher> list = new ArrayList<>();

        boolean hasSearch = isNonBlank(searchKeyword) && !"all".equalsIgnoreCase(searchKeyword.trim());
        boolean hasStatus = isNonBlank(statusFilter)  && !"all".equalsIgnoreCase(statusFilter.trim());

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * ")
           .append("FROM voucher WHERE 1=1 ");
        appendStatusClause(sql, statusFilter, hasStatus);
        if (hasSearch) sql.append("AND (VoucherCode LIKE ? OR Title LIKE ?) ");
        sql.append("ORDER BY VoucherID DESC LIMIT ? OFFSET ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return list;

            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (hasSearch) {
                String p = "%" + searchKeyword.trim() + "%";
                ps.setString(idx++, p);
                ps.setString(idx++, p);
            }
            ps.setInt(idx++, limit);
            ps.setInt(idx,   offset);

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapVoucher(rs));
            }

        } catch (Exception e) {
            System.err.println("[VoucherDAO.getAllVouchersPaged] Exception – returning empty list. Cause: " + e.getMessage());
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    // -----------------------------------------------------------------------
    // Shared SQL helpers
    // -----------------------------------------------------------------------

    /** Appends the status-based WHERE fragment to sql when hasStatus is true. */
    private void appendStatusClause(StringBuilder sql, String statusFilter, boolean hasStatus) {
        if (!hasStatus) return;
        if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
            sql.append("AND IsActive = 1 AND EndDate >= CURDATE() ");
        } else if ("EXPIRED".equalsIgnoreCase(statusFilter)) {
            sql.append("AND (IsActive = 0 OR EndDate < CURDATE()) ");
        } else if ("INACTIVE".equalsIgnoreCase(statusFilter)) {
            sql.append("AND IsActive = 0 ");
        }
    }

    /** Returns true when s is non-null and non-blank. */
    private boolean isNonBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    /**
     * Inserts a new voucher row from the admin add form.
     *
     * @param v  a Voucher object populated from the POST form
     * @return true on success
     */
    public boolean addVoucher(Voucher v) {
        String sql = "INSERT INTO voucher "
            + "(VoucherCode, Title, DiscountType, DiscountValue, MaxDiscountAmount, "
            + " MinOrderValue, StartDate, EndDate, IsActive, UsageLimit, VoucherScope, TargetCategory, IsStackable) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;

            ps = conn.prepareStatement(sql);
            ps.setString(1, v.getVoucherCode());
            ps.setString(2, v.getTitle());
            ps.setString(3, v.getDiscountType());
            ps.setBigDecimal(4, v.getDiscountValue());
            ps.setBigDecimal(5, v.getMaxDiscountAmount());
            ps.setBigDecimal(6, v.getMinOrderValue() != null ? v.getMinOrderValue() : java.math.BigDecimal.ZERO);
            ps.setDate(7, v.getStartDate());
            ps.setDate(8, v.getEndDate());
            ps.setBoolean(9, v.isActive());
            if (v.getUsageLimit() > 0) {
                ps.setInt(10, v.getUsageLimit());
            } else {
                ps.setNull(10, java.sql.Types.INTEGER);
            }
            ps.setString(11, v.getVoucherScope());
            ps.setString(12, v.getTargetCategory());
            ps.setBoolean(13, v.isStackable());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close(conn, ps, null);
        }
    }

    /**
     * Hard-deletes a voucher by its primary key.
     * Note: will fail with a FK constraint if UserVoucher rows reference this ID.
     * Consider using updateVoucherStatus(id, false) for safe archival instead.
     *
     * @param voucherId  the PK of the voucher to remove
     * @return true on success
     */
    public boolean deleteVoucher(int voucherId) {
        String sql = "DELETE FROM voucher WHERE VoucherID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;

            ps = conn.prepareStatement(sql);
            ps.setInt(1, voucherId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close(conn, ps, null);
        }
    }

    /**
     * Toggles the IsActive flag of a voucher (soft-enable / soft-disable).
     *
     * @param voucherId  the PK
     * @param active     true = activate, false = deactivate
     * @return true on success
     */
    public boolean updateVoucherStatus(int voucherId, boolean active) {
        String sql = "UPDATE voucher SET IsActive = ? WHERE VoucherID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;

            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setInt(2, voucherId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close(conn, ps, null);
        }
    }

    /**
     * Loads a voucher by its primary key, regardless of active/expired state.
     * Used by the admin edit form to pre-fill all fields.
     *
     * @param voucherId  the PK to look up
     * @return the Voucher, or null if not found
     */
    public Voucher getVoucherById(int voucherId) {
        String sql =
            "SELECT * "
            + "FROM voucher "
            + "WHERE VoucherID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return null;

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
     * Updates all editable fields of an existing voucher.
     * VoucherCode is intentionally kept immutable (unique natural key).
     *
     * @param v  Voucher with voucherId set and all editable fields populated
     * @return true on success
     */
    public boolean updateVoucher(Voucher v) {
        String sql =
            "UPDATE voucher SET "
            + "  Title = ?, DiscountType = ?, DiscountValue = ?, "
            + "  MaxDiscountAmount = ?, MinOrderValue = ?, "
            + "  StartDate = ?, EndDate = ?, IsActive = ?, UsageLimit = ?, "
            + "  VoucherScope = ?, TargetCategory = ?, IsStackable = ? "
            + "WHERE VoucherID = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;

            ps = conn.prepareStatement(sql);
            ps.setString(1, v.getTitle());
            ps.setString(2, v.getDiscountType());
            ps.setBigDecimal(3, v.getDiscountValue());
            ps.setBigDecimal(4, v.getMaxDiscountAmount());  // may be null
            ps.setBigDecimal(5, v.getMinOrderValue() != null ? v.getMinOrderValue() : java.math.BigDecimal.ZERO);
            ps.setDate(6, v.getStartDate());
            ps.setDate(7, v.getEndDate());
            ps.setBoolean(8, v.isActive());
            if (v.getUsageLimit() > 0) {
                ps.setInt(9, v.getUsageLimit());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }
            ps.setString(10, v.getVoucherScope());
            ps.setString(11, v.getTargetCategory());
            ps.setBoolean(12, v.isStackable());
            ps.setInt(13, v.getVoucherId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close(conn, ps, null);
        }
    }
}
