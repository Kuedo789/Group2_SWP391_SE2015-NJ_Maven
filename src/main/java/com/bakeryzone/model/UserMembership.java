package com.bakeryzone.model;

import java.math.BigDecimal;

/**
 * UserMembership - maps to the `UserMembership` table.
 * Stores the current spending total and accumulated point balance for a user.
 * Also carries denormalised tier data for convenient access in servlets/JSPs.
 */
public class UserMembership {

    private String userId;
    private int currentTierId;
    private BigDecimal totalSpending;
    private int accumulatedPoints;

    // -----------------------------------------------------------------------
    // Denormalised fields – populated by the JOIN query in MembershipDAO
    // so that servlets and JSPs never need to look up tiers separately.
    // -----------------------------------------------------------------------

    /** Full current-tier POJO (name, multiplier, vouchers, description). */
    private MembershipTier currentTier;

    /**
     * Next-tier POJO.
     * Null when the user is already at the top tier (DIAMOND).
     */
    private MembershipTier nextTier;

    public UserMembership() {
    }

    public UserMembership(String userId, int currentTierId,
                          BigDecimal totalSpending, int accumulatedPoints) {
        this.userId = userId;
        this.currentTierId = currentTierId;
        this.totalSpending = totalSpending;
        this.accumulatedPoints = accumulatedPoints;
    }

    // -----------------------------------------------------------------------
    // Convenience helpers used in JSTL expressions
    // -----------------------------------------------------------------------

    /**
     * Returns the progress percentage (0–100) toward the next tier's
     * MinSpending threshold.  Returns 100 when the user is at DIAMOND.
     */
    public double getProgressPercent() {
        if (nextTier == null || nextTier.getMinSpending() == null) {
            return 100.0;
        }
        BigDecimal milestone = nextTier.getMinSpending();
        if (milestone.compareTo(BigDecimal.ZERO) <= 0) {
            return 100.0;
        }
        if (totalSpending == null) {
            return 0.0;
        }
        double pct = totalSpending.doubleValue() / milestone.doubleValue() * 100.0;
        return Math.min(pct, 100.0);
    }

    // -----------------------------------------------------------------------
    // Getters & Setters
    // -----------------------------------------------------------------------

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getCurrentTierId() {
        return currentTierId;
    }

    public void setCurrentTierId(int currentTierId) {
        this.currentTierId = currentTierId;
    }

    public BigDecimal getTotalSpending() {
        return totalSpending;
    }

    public void setTotalSpending(BigDecimal totalSpending) {
        this.totalSpending = totalSpending;
    }

    public int getAccumulatedPoints() {
        return accumulatedPoints;
    }

    public void setAccumulatedPoints(int accumulatedPoints) {
        this.accumulatedPoints = accumulatedPoints;
    }

    public MembershipTier getCurrentTier() {
        return currentTier;
    }

    public void setCurrentTier(MembershipTier currentTier) {
        this.currentTier = currentTier;
    }

    public MembershipTier getNextTier() {
        return nextTier;
    }

    public void setNextTier(MembershipTier nextTier) {
        this.nextTier = nextTier;
    }

    @Override
    public String toString() {
        return "UserMembership{"
                + "userId='" + userId + '\''
                + ", totalSpending=" + totalSpending
                + ", accumulatedPoints=" + accumulatedPoints
                + ", currentTier=" + (currentTier != null ? currentTier.getTierName() : "null")
                + '}';
    }
}
