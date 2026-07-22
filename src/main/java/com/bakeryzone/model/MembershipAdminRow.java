package com.bakeryzone.model;

import java.math.BigDecimal;

/**
 * Lightweight DTO for rendering rows in the Admin Membership Overview table.
 */
public class MembershipAdminRow {
    private String userId;
    private String fullName;
    private String email;
    private String tierName;
    private int accumulatedPoints;
    private BigDecimal totalSpending;

    public MembershipAdminRow() {
    }

    public MembershipAdminRow(String userId, String fullName, String email, String tierName, int accumulatedPoints, BigDecimal totalSpending) {
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.tierName = tierName;
        this.accumulatedPoints = accumulatedPoints;
        this.totalSpending = totalSpending;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTierName() {
        return tierName;
    }

    public void setTierName(String tierName) {
        this.tierName = tierName;
    }

    public int getAccumulatedPoints() {
        return accumulatedPoints;
    }

    public void setAccumulatedPoints(int accumulatedPoints) {
        this.accumulatedPoints = accumulatedPoints;
    }

    public BigDecimal getTotalSpending() {
        return totalSpending;
    }

    public void setTotalSpending(BigDecimal totalSpending) {
        this.totalSpending = totalSpending;
    }
}
