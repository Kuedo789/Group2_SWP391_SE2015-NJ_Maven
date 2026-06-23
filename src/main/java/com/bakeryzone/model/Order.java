package com.bakeryzone.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order {

    private String orderNo;
    private String customerId;
    private String customerName;
    private String tripId;
    private Timestamp orderTime;
    private Timestamp deliveryWindowStart;
    private Timestamp deliveryWindowEnd;
    private String deliveryAddress;
    private BigDecimal depositAmount;
    private BigDecimal totalCost;
    private String orderStatus;
    private BigDecimal shippingFee;
    private String productionStatus;
    private String shipperName;
    private BigDecimal remainingCodBalance;
    private final List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    public BigDecimal getRemainingCodBalance() {
        if (remainingCodBalance != null) {
            return remainingCodBalance;
        }
        return getRemainingAmount();
    }

    public void setRemainingCodBalance(BigDecimal remainingCodBalance) {
        this.remainingCodBalance = remainingCodBalance;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getTripId() {
        return tripId;
    }

    public void setTripId(String tripId) {
        this.tripId = tripId;
    }

    public Timestamp getOrderTime() {
        return orderTime;
    }

    public void setOrderTime(Timestamp orderTime) {
        this.orderTime = orderTime;
    }

    public Timestamp getDeliveryWindowStart() {
        return deliveryWindowStart;
    }

    public void setDeliveryWindowStart(Timestamp deliveryWindowStart) {
        this.deliveryWindowStart = deliveryWindowStart;
    }

    public Timestamp getDeliveryWindowEnd() {
        return deliveryWindowEnd;
    }

    public void setDeliveryWindowEnd(Timestamp deliveryWindowEnd) {
        this.deliveryWindowEnd = deliveryWindowEnd;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public BigDecimal getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(BigDecimal shippingFee) {
        this.shippingFee = shippingFee;
    }

    public String getProductionStatus() {
        return productionStatus;
    }

    public void setProductionStatus(String productionStatus) {
        this.productionStatus = productionStatus;
    }

    public String getShipperName() {
        return shipperName;
    }

    public void setShipperName(String shipperName) {
        this.shipperName = shipperName;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public BigDecimal getRemainingAmount() {
        BigDecimal total = totalCost == null ? BigDecimal.ZERO : totalCost;
        BigDecimal deposit = depositAmount == null ? BigDecimal.ZERO : depositAmount;
        return total.subtract(deposit);
    }
}