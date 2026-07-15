package com.bakeryzone.model;

import java.math.BigDecimal;

/**
 * MembershipTier - maps to the `MembershipTier` table.
 * Holds tier rules: spending threshold, point multiplier, and monthly voucher allowance.
 * TierName values: MEMBER, BRONZE, SILVER, GOLD, DIAMOND
 */
public class MembershipTier {

    private int tierId;
    private String tierName;
    private BigDecimal minSpending;
    private double pointMultiplier;
    private int monthlyVouchers;
    private String description;

    public MembershipTier() {
    }

    public MembershipTier(int tierId, String tierName, BigDecimal minSpending,
                          double pointMultiplier, int monthlyVouchers, String description) {
        this.tierId = tierId;
        this.tierName = tierName;
        this.minSpending = minSpending;
        this.pointMultiplier = pointMultiplier;
        this.monthlyVouchers = monthlyVouchers;
        this.description = description;
    }

    // -----------------------------------------------------------------------
    // Getters & Setters
    // -----------------------------------------------------------------------

    public int getTierId() {
        return tierId;
    }

    public void setTierId(int tierId) {
        this.tierId = tierId;
    }

    public String getTierName() {
        return tierName;
    }

    public void setTierName(String tierName) {
        this.tierName = tierName;
    }

    public BigDecimal getMinSpending() {
        return minSpending;
    }

    public void setMinSpending(BigDecimal minSpending) {
        this.minSpending = minSpending;
    }

    public double getPointMultiplier() {
        return pointMultiplier;
    }

    public void setPointMultiplier(double pointMultiplier) {
        this.pointMultiplier = pointMultiplier;
    }

    public int getMonthlyVouchers() {
        return monthlyVouchers;
    }

    public void setMonthlyVouchers(int monthlyVouchers) {
        this.monthlyVouchers = monthlyVouchers;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "MembershipTier{"
                + "tierId=" + tierId
                + ", tierName='" + tierName + '\''
                + ", minSpending=" + minSpending
                + '}';
    }
}
