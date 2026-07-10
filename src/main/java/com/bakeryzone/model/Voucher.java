package com.bakeryzone.model;

import java.math.BigDecimal;
import java.sql.Date;

/**
 * Voucher – maps to the `Voucher` table.
 *
 * DiscountType values : PERCENT | FIXED
 * RequiredTierID      : FK to MembershipTier.TierID (null = any tier)
 *
 * The transient field {@code pointCost} is NOT stored in the database;
 * it is assigned by the application layer to express how many accumulated
 * points a user must spend to redeem this reward.
 */
public class Voucher {

    private int voucherId;
    private String voucherCode;
    private String title;
    private String discountType;         // "PERCENT" or "FIXED"
    private BigDecimal discountValue;
    private BigDecimal maxDiscountAmount; // cap for PERCENT discounts
    private BigDecimal minOrderValue;
    private Date startDate;
    private Date endDate;
    private boolean active;
    private int usageLimit;
    private Integer requiredTierId;      // nullable – null = any tier

    /**
     * Transient field: point cost to redeem this voucher.
     * Populated by the application layer (e.g., a fixed formula or a
     * dedicated reward_cost column added later). Defaults to 0.
     */
    private int pointCost;

    public Voucher() {
    }

    // -----------------------------------------------------------------------
    // Getters & Setters
    // -----------------------------------------------------------------------

    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMaxDiscountAmount() {
        return maxDiscountAmount;
    }

    public void setMaxDiscountAmount(BigDecimal maxDiscountAmount) {
        this.maxDiscountAmount = maxDiscountAmount;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public int getUsageLimit() {
        return usageLimit;
    }

    public void setUsageLimit(int usageLimit) {
        this.usageLimit = usageLimit;
    }

    public Integer getRequiredTierId() {
        return requiredTierId;
    }

    public void setRequiredTierId(Integer requiredTierId) {
        this.requiredTierId = requiredTierId;
    }

    public int getPointCost() {
        return pointCost;
    }

    public void setPointCost(int pointCost) {
        this.pointCost = pointCost;
    }

    // -----------------------------------------------------------------------
    // Convenience helpers used in JSTL
    // -----------------------------------------------------------------------

    /**
     * Returns a human-readable discount description, e.g.:
     * "Giảm 20%" or "Giảm 50.000 ₫"
     */
    public String getDiscountLabel() {
        if ("PERCENT".equalsIgnoreCase(discountType) && discountValue != null) {
            return "Giảm " + discountValue.stripTrailingZeros().toPlainString() + "%";
        }
        if ("FIXED".equalsIgnoreCase(discountType) && discountValue != null) {
            return "Giảm " + String.format("%,.0f", discountValue.doubleValue()) + " ₫";
        }
        return title != null ? title : "Voucher";
    }

    @Override
    public String toString() {
        return "Voucher{voucherId=" + voucherId
                + ", voucherCode='" + voucherCode + '\''
                + ", title='" + title + '\''
                + ", pointCost=" + pointCost + '}';
    }
}
