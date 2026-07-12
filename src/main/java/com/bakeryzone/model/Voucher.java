package com.bakeryzone.model;

import java.math.BigDecimal;
import java.sql.Date;

public class Voucher {
    private String voucherCode;
    private BigDecimal discountAmount;
    private BigDecimal minOrderValue;
    private int totalQuantity;
    private int usagePerUser;
    private int requiredTierId;
    private Date startDate;
    private Date endDate;
    private boolean isActive;

    public Voucher() {
    }

    public Voucher(String voucherCode, BigDecimal discountAmount, BigDecimal minOrderValue, int totalQuantity, int usagePerUser, int requiredTierId, Date startDate, Date endDate, boolean isActive) {
        this.voucherCode = voucherCode;
        this.discountAmount = discountAmount;
        this.minOrderValue = minOrderValue;
        this.totalQuantity = totalQuantity;
        this.usagePerUser = usagePerUser;
        this.requiredTierId = requiredTierId;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isActive = isActive;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }

    public int getUsagePerUser() {
        return usagePerUser;
    }

    public void setUsagePerUser(int usagePerUser) {
        this.usagePerUser = usagePerUser;
    }

    public int getRequiredTierId() {
        return requiredTierId;
    }

    public void setRequiredTierId(int requiredTierId) {
        this.requiredTierId = requiredTierId;
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
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }
}
