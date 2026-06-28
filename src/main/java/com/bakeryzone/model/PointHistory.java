package com.bakeryzone.model;

import java.sql.Timestamp;

/**
 * PointHistory - maps to the `PointHistory` table.
 * Records every point credit or debit event for a user.
 * ChangeType values: EARN, REDEEM, EXPIRE, ADJUST
 */
public class PointHistory {

    private int transactionId;
    private String userId;
    private int amount;
    private String changeType;
    private String description;
    private Timestamp createdAt;

    public PointHistory() {
    }

    public PointHistory(int transactionId, String userId, int amount,
                        String changeType, String description, Timestamp createdAt) {
        this.transactionId = transactionId;
        this.userId = userId;
        this.amount = amount;
        this.changeType = changeType;
        this.description = description;
        this.createdAt = createdAt;
    }

    // -----------------------------------------------------------------------
    // Getters & Setters
    // -----------------------------------------------------------------------

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "PointHistory{"
                + "transactionId=" + transactionId
                + ", amount=" + amount
                + ", changeType='" + changeType + '\''
                + ", createdAt=" + createdAt
                + '}';
    }
}
