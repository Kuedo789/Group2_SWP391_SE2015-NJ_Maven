package com.bakeryzone.dao;

import com.bakeryzone.model.MembershipAdminRow;
import com.bakeryzone.model.MembershipTier;
import com.bakeryzone.model.PointHistory;
import com.bakeryzone.model.UserMembership;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

/**
 * MembershipDAO – all database access for the Membership Dashboard feature.
 *
 * Key design decisions:
 *  - A single compound LEFT JOIN query fetches the user's membership row,
 *    their current-tier rules, AND the next tier's rules in one round-trip.
 *  - "Next tier" is resolved by MinSpending ordering: the cheapest tier whose
 *    MinSpending is strictly greater than the current tier's MinSpending.
 *  - getAllTiers() is a separate utility call used to populate the benefits matrix.
 *  - getPointHistory() returns the last N transactions for the point-history tab.
 */
public class MembershipDAO {

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /**
     * Loads the full membership snapshot for one user.
     *
     * The query executes a self-join on MembershipTier to retrieve both the
     * current tier and the next tier in a single SELECT, avoiding N+1 queries.
     *
     * @param userId  The User_ID (VARCHAR primary key from the user table)
     * @return        A fully populated UserMembership object, or null if no
     *                UserMembership row exists for the given user.
     */
    public UserMembership getMembershipByUserId(String userId) {

        /*
         * Strategy:
         *   1. Join UserMembership (um) → MembershipTier current (ct).
         *   2. LEFT JOIN MembershipTier next (nt) ON nt.MinSpending > ct.MinSpending
         *      ORDER BY nt.MinSpending ASC LIMIT 1  → achieved with a scalar subquery.
         *
         * Using a correlated scalar subquery for next-tier is more portable across
         * MySQL versions than a lateral join and avoids requiring an extra round-trip.
         */
        String sql =
            "SELECT "
            + "  um.UserID, "
            + "  um.CurrentTierID, "
            + "  um.TotalSpending, "
            + "  um.AccumulatedPoints, "
            // --- Current tier columns ---
            + "  ct.TierID        AS ct_TierID, "
            + "  ct.TierName      AS ct_TierName, "
            + "  ct.MinSpending   AS ct_MinSpending, "
            + "  ct.PointMultiplier AS ct_PointMultiplier, "
            + "  ct.MonthlyVouchers AS ct_MonthlyVouchers, "
            + "  ct.Description   AS ct_Description, "
            // --- Next tier columns (NULL if user is at top tier) ---
            + "  nt.TierID        AS nt_TierID, "
            + "  nt.TierName      AS nt_TierName, "
            + "  nt.MinSpending   AS nt_MinSpending, "
            + "  nt.PointMultiplier AS nt_PointMultiplier, "
            + "  nt.MonthlyVouchers AS nt_MonthlyVouchers, "
            + "  nt.Description   AS nt_Description "
            + "FROM UserMembership um "
            + "JOIN MembershipTier ct ON um.CurrentTierID = ct.TierID "
            + "LEFT JOIN MembershipTier nt "
            + "  ON nt.MinSpending > ct.MinSpending "
            + "  AND nt.TierID = ( "
            + "    SELECT TierID FROM MembershipTier "
            + "    WHERE MinSpending > ct.MinSpending "
            + "    ORDER BY MinSpending ASC "
            + "    LIMIT 1 "
            + "  ) "
            + "WHERE um.UserID = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return null;
            }

            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUserMembership(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return null;
    }

    /**
     * Retrieves member stats for the admin dashboard.
     * @return int array: [totalMembers, standardCount, bronzeCount, silverCount, goldCount]
     */
    public int[] getMemberStats() {
        int[] stats = new int[6];
        String sql = "SELECT " +
                     "  COUNT(*) AS total, " +
                     "  SUM(CASE WHEN t.TierName = 'MEMBER' THEN 1 ELSE 0 END) AS standardCount, " +
                     "  SUM(CASE WHEN t.TierName = 'BRONZE' THEN 1 ELSE 0 END) AS bronzeCount, " +
                     "  SUM(CASE WHEN t.TierName = 'SILVER' THEN 1 ELSE 0 END) AS silverCount, " +
                     "  SUM(CASE WHEN t.TierName = 'GOLD' THEN 1 ELSE 0 END) AS goldCount, " +
                     "  SUM(CASE WHEN t.TierName = 'DIAMOND' THEN 1 ELSE 0 END) AS diamondCount " +
                     "FROM UserMembership um " +
                     "LEFT JOIN MembershipTier t ON um.CurrentTierID = t.TierID";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn != null) {
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                if (rs.next()) {
                    stats[0] = rs.getInt("total");
                    stats[1] = rs.getInt("standardCount");
                    stats[2] = rs.getInt("bronzeCount");
                    stats[3] = rs.getInt("silverCount");
                    stats[4] = rs.getInt("goldCount");
                    stats[5] = rs.getInt("diamondCount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return stats;
    }

    /**
     * Retrieves a paginated and filtered list of members for the admin overview.
     */
    public List<MembershipAdminRow> getMemberListPaged(String tierFilter, String search, int offset, int pageSize) {
        List<MembershipAdminRow> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT um.UserID, c.Full_Name, u.Email, t.TierName, um.AccumulatedPoints, um.TotalSpending " +
            "FROM UserMembership um " +
            "LEFT JOIN MembershipTier t ON um.CurrentTierID = t.TierID " +
            "LEFT JOIN user u ON um.UserID = u.user_id " +
            "LEFT JOIN customer c ON u.user_id = c.user_id " +
            "WHERE 1=1 "
        );

        boolean hasTier = tierFilter != null && !tierFilter.equalsIgnoreCase("ALL");
        boolean hasSearch = search != null && !search.trim().isEmpty();

        if (hasTier) {
            sql.append(" AND t.TierName = ? ");
        }
        if (hasSearch) {
            sql.append(" AND (c.Full_Name LIKE ? OR u.Email LIKE ? OR um.UserID LIKE ?) ");
        }
        sql.append(" ORDER BY um.TotalSpending DESC LIMIT ? OFFSET ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return list;

            ps = conn.prepareStatement(sql.toString());
            int idx = 1;

            if (hasTier) {
                ps.setString(idx++, tierFilter.toUpperCase());
            }
            if (hasSearch) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }

            ps.setInt(idx++, pageSize);
            ps.setInt(idx++, offset);

            rs = ps.executeQuery();
            while (rs.next()) {
                MembershipAdminRow row = new MembershipAdminRow(
                    rs.getString("UserID"),
                    rs.getString("Full_Name") != null ? rs.getString("Full_Name") : "Chưa cập nhật",
                    rs.getString("Email"),
                    rs.getString("TierName"),
                    rs.getInt("AccumulatedPoints"),
                    rs.getBigDecimal("TotalSpending")
                );
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return list;
    }

    /**
     * Gets total count of members matching the filter (for pagination).
     */
    public int getMemberCount(String tierFilter, String search) {
        int count = 0;
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM UserMembership um " +
            "LEFT JOIN MembershipTier t ON um.CurrentTierID = t.TierID " +
            "LEFT JOIN user u ON um.UserID = u.user_id " +
            "LEFT JOIN customer c ON u.user_id = c.user_id " +
            "WHERE 1=1 "
        );

        boolean hasTier = tierFilter != null && !tierFilter.equalsIgnoreCase("ALL");
        boolean hasSearch = search != null && !search.trim().isEmpty();

        if (hasTier) {
            sql.append(" AND t.TierName = ? ");
        }
        if (hasSearch) {
            sql.append(" AND (c.Full_Name LIKE ? OR u.Email LIKE ? OR um.UserID LIKE ?) ");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return 0;

            ps = conn.prepareStatement(sql.toString());
            int idx = 1;

            if (hasTier) {
                ps.setString(idx++, tierFilter.toUpperCase());
            }
            if (hasSearch) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }

            rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return count;
    }

    /**
     * Retrieves all membership tiers ordered by MinSpending ascending.
     * Used to render the complete tier-benefits matrix on the dashboard.
     *
     * @return ordered list from MEMBER → DIAMOND
     */
    public List<MembershipTier> getAllTiers() {

        List<MembershipTier> list = new ArrayList<>();

        String sql =
            "SELECT TierID, TierName, MinSpending, PointMultiplier, MonthlyVouchers, Description "
            + "FROM MembershipTier "
            + "ORDER BY MinSpending ASC";

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
                list.add(mapTier(rs, ""));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    /**
     * Returns the most recent point-history entries for a user, newest first.
     *
     * @param userId  the user whose history is requested
     * @param limit   maximum number of rows to return (e.g. 20)
     * @return        list of PointHistory objects
     */
    public List<PointHistory> getPointHistory(String userId, int limit) {

        List<PointHistory> list = new ArrayList<>();

        String sql =
            "SELECT TransactionID, UserID, Amount, ChangeType, Description, CreatedAt "
            + "FROM PointHistory "
            + "WHERE UserID = ? "
            + "ORDER BY CreatedAt DESC "
            + "LIMIT ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return list;
            }

            ps = conn.prepareStatement(sql);
            ps.setString(1, userId);
            ps.setInt(2, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapPointHistory(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    /**
     * Inserts a new UserMembership row with MEMBER (lowest) tier defaults.
     * Called once during user registration or lazily on first dashboard visit
     * when no membership row is found.
     *
     * @param userId  the new user's ID
     * @return        true if the row was successfully created
     */
    public boolean initMembershipForUser(String userId) {

        // Fetch the MEMBER tier ID (MinSpending = 0) to set as default
        String sqlFetchMember =
            "SELECT TierID FROM MembershipTier "
            + "ORDER BY MinSpending ASC "
            + "LIMIT 1";

        String sqlInsert =
            "INSERT INTO UserMembership (UserID, CurrentTierID, TotalSpending, AccumulatedPoints) "
            + "VALUES (?, ?, 0, 0)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return false;
            }

            // Resolve the lowest tier ID
            int memberTierId = 1; // safe fallback
            ps = conn.prepareStatement(sqlFetchMember);
            rs = ps.executeQuery();
            if (rs.next()) {
                memberTierId = rs.getInt("TierID");
            }
            close(null, ps, rs);

            ps = conn.prepareStatement(sqlInsert);
            ps.setString(1, userId);
            ps.setInt(2, memberTierId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }

        return false;
    }

    /**
     * Retrieves all active, un-used vouchers that the user has claimed via the
     * rewards exchange.  Only returns vouchers that are still valid today.
     * Optionally filters by scope (ORDER / CATEGORY / TIER) and search keyword.
     *
     * @param userId the user whose wallet is being queried
     * @param scope  null or "all" = no scope filter;
     *               "ORDER"    = VoucherScope = 'ORDER'
     *               "CATEGORY" = VoucherScope = 'CATEGORY'
     *               "TIER"     = RequiredTierID IS NOT NULL
     * @param search null or empty = no keyword filter; otherwise matched
     *               against VoucherCode and Title (case-insensitive)
     * @return list of owned, still-valid, un-used Voucher objects (never null)
     */
    public List<com.bakeryzone.model.Voucher> getUserOwnedVouchers(
            String userId, String scope, String search) {
        return getUserOwnedVouchers(userId, scope, search, 1, Integer.MAX_VALUE);
    }

    /**
     * Retrieves one page of the user's valid, unused vouchers.
     */
    public List<com.bakeryzone.model.Voucher> getUserOwnedVouchers(
            String userId, String scope, String search, int page, int pageSize) {

        List<com.bakeryzone.model.Voucher> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT v.VoucherID, v.VoucherCode, v.Title, v.DiscountType, v.DiscountValue, "
            + "       v.MaxDiscountAmount, v.MinOrderValue, v.StartDate, v.EndDate, "
            + "       v.IsActive, v.UsageLimit, v.RequiredTierID, "
            + "       v.VoucherScope, v.TargetCategory "
            + "FROM UserVoucher uv "
            + "JOIN Voucher v ON uv.VoucherID = v.VoucherID "
            + "WHERE uv.UserID = ? "
            + "  AND uv.IsUsed  = 0 "
            + "  AND v.IsActive = 1 "
            + "  AND CURDATE() <= v.EndDate ");

        // --- Scope filter ---
        boolean scopeIsOrder    = "ORDER".equalsIgnoreCase(scope);
        boolean scopeIsShipping = "SHIPPING".equalsIgnoreCase(scope);

        if (scopeIsOrder) {
            sql.append("  AND v.VoucherScope = 'ORDER' ");
        } else if (scopeIsShipping) {
            sql.append("  AND v.VoucherScope = 'SHIPPING' ");
        }

        // --- Search filter ---
        boolean hasSearch = search != null && !search.trim().isEmpty();
        if (hasSearch) {
            sql.append("  AND (v.VoucherCode LIKE ? OR v.Title LIKE ?) ");
        }

        sql.append("ORDER BY uv.AssignedAt DESC LIMIT ? OFFSET ?");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) {
                return list;
            }

            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            ps.setString(idx++, userId);
            if (hasSearch) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx++, pattern);
            }
            int safePage = Math.max(page, 1);
            int safePageSize = Math.max(pageSize, 1);
            ps.setInt(idx++, safePageSize);
            ps.setLong(idx, (long) (safePage - 1) * safePageSize);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapOwnedVoucher(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }

        return list;
    }

    /**
     * Counts the user's valid, unused vouchers using the same filters as the
     * paginated wallet query.
     */
    public int countUserOwnedVouchers(String userId, String scope, String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) "
            + "FROM UserVoucher uv "
            + "JOIN Voucher v ON uv.VoucherID = v.VoucherID "
            + "WHERE uv.UserID = ? "
            + "  AND uv.IsUsed = 0 "
            + "  AND v.IsActive = 1 "
            + "  AND CURDATE() <= v.EndDate ");

        boolean scopeIsOrder = "ORDER".equalsIgnoreCase(scope);
        boolean scopeIsShipping = "SHIPPING".equalsIgnoreCase(scope);
        if (scopeIsOrder) {
            sql.append(" AND v.VoucherScope = 'ORDER' ");
        } else if (scopeIsShipping) {
            sql.append(" AND v.VoucherScope = 'SHIPPING' ");
        }

        boolean hasSearch = search != null && !search.trim().isEmpty();
        if (hasSearch) {
            sql.append(" AND (v.VoucherCode LIKE ? OR v.Title LIKE ?) ");
        }

        try (Connection conn = DBContext.getJDBCConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setString(idx++, userId);
            if (hasSearch) {
                String pattern = "%" + search.trim() + "%";
                ps.setString(idx++, pattern);
                ps.setString(idx, pattern);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Convenience overload with no filtering – delegates to the full version.
     */
    public List<com.bakeryzone.model.Voucher> getUserOwnedVouchers(String userId) {
        return getUserOwnedVouchers(userId, null, null);
    }

    // -----------------------------------------------------------------------
    // Private mapping helpers
    // -----------------------------------------------------------------------

    /**
     * Maps the compound result set row (with current + next tier columns)
     * into a fully populated UserMembership object.
     *
     * @param rs      an open ResultSet positioned at a valid row
     * @param prefix  column alias prefix ("ct_" or "nt_") – empty string
     *                means no prefix (used by getAllTiers single-table query)
     */
    private UserMembership mapUserMembership(ResultSet rs) throws Exception {
        UserMembership um = new UserMembership();
        um.setUserId(rs.getString("UserID"));
        um.setCurrentTierId(rs.getInt("CurrentTierID"));
        um.setTotalSpending(rs.getBigDecimal("TotalSpending"));
        um.setAccumulatedPoints(rs.getInt("AccumulatedPoints"));

        // Map current tier
        MembershipTier current = mapTier(rs, "ct_");
        um.setCurrentTier(current);

        // Map next tier – columns will be NULL if user is already at DIAMOND
        int nextTierId = rs.getInt("nt_TierID");
        if (!rs.wasNull()) {
            MembershipTier next = mapTier(rs, "nt_");
            um.setNextTier(next);
        }
        // else nextTier remains null → JSP/servlet treats as max tier

        return um;
    }

    /**
     * Maps a MembershipTier from the current ResultSet row.
     *
     * @param rs      open ResultSet positioned at a valid row
     * @param prefix  column alias prefix, e.g. "ct_", "nt_", or "" for
     *                bare column names (single-table query)
     */
    private MembershipTier mapTier(ResultSet rs, String prefix) throws Exception {
        MembershipTier tier = new MembershipTier();
        tier.setTierId(rs.getInt(prefix + "TierID"));
        tier.setTierName(rs.getString(prefix + "TierName"));
        tier.setMinSpending(rs.getBigDecimal(prefix + "MinSpending"));
        tier.setPointMultiplier(rs.getDouble(prefix + "PointMultiplier"));
        tier.setMonthlyVouchers(rs.getInt(prefix + "MonthlyVouchers"));
        tier.setDescription(rs.getString(prefix + "Description"));
        return tier;
    }

    private PointHistory mapPointHistory(ResultSet rs) throws Exception {
        PointHistory ph = new PointHistory();
        ph.setTransactionId(rs.getInt("TransactionID"));
        ph.setUserId(rs.getString("UserID"));
        ph.setAmount(rs.getInt("Amount"));
        ph.setChangeType(rs.getString("ChangeType"));
        ph.setDescription(rs.getString("Description"));
        ph.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return ph;
    }

    /**
     * Maps a Voucher from a plain (non-aliased) result set row produced by
     * the getUserOwnedVouchers JOIN query.
     * Now also reads the new VoucherScope and TargetCategory columns.
     */
    private com.bakeryzone.model.Voucher mapOwnedVoucher(ResultSet rs) throws Exception {
        com.bakeryzone.model.Voucher v = new com.bakeryzone.model.Voucher();
        v.setVoucherId(rs.getInt("VoucherID"));
        v.setVoucherCode(rs.getString("VoucherCode"));
        v.setTitle(rs.getString("Title"));
        v.setDiscountType(rs.getString("DiscountType"));
        v.setDiscountValue(rs.getBigDecimal("DiscountValue"));
        v.setMaxDiscountAmount(rs.getBigDecimal("MaxDiscountAmount"));
        v.setMinOrderValue(rs.getBigDecimal("MinOrderValue"));
        v.setStartDate(rs.getDate("StartDate"));
        v.setEndDate(rs.getDate("EndDate"));
        v.setActive(rs.getBoolean("IsActive"));
        v.setUsageLimit(rs.getInt("UsageLimit"));
        int reqTier = rs.getInt("RequiredTierID");
        v.setRequiredTierId(rs.wasNull() ? null : reqTier);
        v.setVoucherScope(rs.getString("VoucherScope"));
        v.setTargetCategory(rs.getString("TargetCategory"));
        // pointCost is not needed for the wallet display; leave at default 0
        return v;
    }

    // -----------------------------------------------------------------------
    // Admin Actions
    // -----------------------------------------------------------------------

    public boolean adjustPoints(String userId, int delta, String description) {
        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;

        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            
            conn.setAutoCommit(false);
            
            // First check current points to cap at 0
            UserMembership um = getMembershipByUserId(userId);
            if (um == null) return false;
            
            int currentPoints = um.getAccumulatedPoints();
            if (currentPoints + delta < 0) {
                delta = -currentPoints;
            }

            String updateSql = "UPDATE UserMembership SET AccumulatedPoints = AccumulatedPoints + ? WHERE UserID = ?";
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setInt(1, delta);
            psUpdate.setString(2, userId);
            int updated = psUpdate.executeUpdate();

            if (updated > 0) {
                String insertSql = "INSERT INTO PointHistory (UserID, Amount, ChangeType, Description, CreatedAt) VALUES (?, ?, 'ADJUST', ?, NOW())";
                psInsert = conn.prepareStatement(insertSql);
                psInsert.setString(1, userId);
                psInsert.setInt(2, delta);
                psInsert.setString(3, description);
                psInsert.executeUpdate();
                
                conn.commit();
                return true;
            } else {
                conn.rollback();
            }
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ignored) {}
            e.printStackTrace();
        } finally {
            try {
                if (psUpdate != null) psUpdate.close();
                if (psInsert != null) psInsert.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public boolean setTier(String userId, int newTierId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            
            String sql = "UPDATE UserMembership SET CurrentTierID = ? WHERE UserID = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, newTierId);
            ps.setString(2, userId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public List<com.bakeryzone.model.Voucher> getAllActiveVouchers() {
        List<com.bakeryzone.model.Voucher> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn != null) {
                String sql = "SELECT * FROM Voucher WHERE IsActive = 1 AND EndDate >= CURDATE() ORDER BY RequiredTierID DESC, VoucherID DESC";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();
                while (rs.next()) {
                    list.add(mapOwnedVoucher(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, rs);
        }
        return list;
    }

    public boolean assignVoucher(String userId, int voucherId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            
            // Check if already assigned and not used
            String checkSql = "SELECT * FROM UserVoucher WHERE UserID = ? AND VoucherID = ? AND IsUsed = 0";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setString(1, userId);
            psCheck.setInt(2, voucherId);
            ResultSet rs = psCheck.executeQuery();
            if (rs.next()) {
                // Already has an active version of this voucher
                close(null, psCheck, rs);
                return false;
            }
            close(null, psCheck, rs);
            
            String insertSql = "INSERT INTO UserVoucher (UserID, VoucherID, AssignedAt, IsUsed) VALUES (?, ?, NOW(), 0)";
            ps = conn.prepareStatement(insertSql);
            ps.setString(1, userId);
            ps.setInt(2, voucherId);
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public boolean assignVoucherByCode(String userId, String voucherCode) {
        Connection conn = null;
        PreparedStatement psFind = null;
        ResultSet rsFind = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            
            // Find voucher ID by code
            String findSql = "SELECT VoucherID FROM Voucher WHERE VoucherCode = ? AND Status = 'Active' AND EndDate >= CURDATE()";
            psFind = conn.prepareStatement(findSql);
            psFind.setString(1, voucherCode);
            rsFind = psFind.executeQuery();
            
            if (rsFind.next()) {
                int voucherId = rsFind.getInt("VoucherID");
                return assignVoucher(userId, voucherId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, psFind, rsFind);
        }
        return false;
    }

    // -----------------------------------------------------------------------
    // Tier Config Admin Actions
    // -----------------------------------------------------------------------
    
    public boolean saveTier(MembershipTier t) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            
            if (t.getTierId() > 0) {
                // Update
                String sql = "UPDATE MembershipTier SET TierName=?, MinSpending=?, PointMultiplier=?, MonthlyVouchers=?, Description=? WHERE TierID=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, t.getTierName());
                ps.setBigDecimal(2, t.getMinSpending());
                ps.setDouble(3, t.getPointMultiplier());
                ps.setInt(4, t.getMonthlyVouchers());
                ps.setString(5, t.getDescription());
                ps.setInt(6, t.getTierId());
            } else {
                // Insert
                String sql = "INSERT INTO MembershipTier (TierName, MinSpending, PointMultiplier, MonthlyVouchers, Description) VALUES (?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, t.getTierName());
                ps.setBigDecimal(2, t.getMinSpending());
                ps.setDouble(3, t.getPointMultiplier());
                ps.setInt(4, t.getMonthlyVouchers());
                ps.setString(5, t.getDescription());
            }
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public String deleteTier(int tierId) {
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psDel = null;
        ResultSet rsCheck = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return "Lỗi kết nối database.";
            
            // Check usage
            String checkSql = "SELECT COUNT(*) FROM UserMembership WHERE CurrentTierID = ?";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, tierId);
            rsCheck = psCheck.executeQuery();
            
            if (rsCheck.next()) {
                int count = rsCheck.getInt(1);
                if (count > 0) {
                    return "Không thể xóa hạng này vì đang có " + count + " thành viên thuộc hạng.";
                }
            }
            
            String delSql = "DELETE FROM MembershipTier WHERE TierID = ?";
            psDel = conn.prepareStatement(delSql);
            psDel.setInt(1, tierId);
            int rows = psDel.executeUpdate();
            if (rows > 0) {
                return "ok";
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi hệ thống khi xóa hạng.";
        } finally {
            try { if (rsCheck != null) rsCheck.close(); } catch(Exception e) {}
            try { if (psCheck != null) psCheck.close(); } catch(Exception e) {}
            try { if (psDel != null) psDel.close(); } catch(Exception e) {}
            if (conn != null) {
                try { conn.close(); } catch (Exception e) {}
            }
        }
        return "Không xóa được hạng này.";
    }

    // -----------------------------------------------------------------------
    // Resource cleanup
    // -----------------------------------------------------------------------

    private void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
