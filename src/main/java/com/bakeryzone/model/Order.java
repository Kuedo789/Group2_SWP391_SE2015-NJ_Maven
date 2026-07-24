package com.bakeryzone.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Order {

    // =====================================================
    // HẰNG SỐ TRẠNG THÁI CHUẨN 1 CHIỀU
    // Luồng: PAID → Processing → Waiting_Delivery → Delivering → Completed
    // Ngoại lệ: PAID / Processing → Cancelled
    // =====================================================
    public static final String STATUS_WAITING_PAYMENT  = "Waiting_Payment";
    public static final String STATUS_PAID             = "PAID";
    public static final String STATUS_PROCESSING       = "Processing";
    public static final String STATUS_WAITING_DELIVERY = "Waiting_Delivery";
    public static final String STATUS_DELIVERING       = "Delivering";
    public static final String STATUS_COMPLETED        = "Completed";
    public static final String STATUS_CANCELLED        = "Cancelled";

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
    private String receiverName;
    private String receiverPhone;
    private String customerNote;
    private String shipperNote;
    private String paymentMethod = "COD";
    private String appliedVoucherCode;
    private BigDecimal discountAmount;
    private final List<OrderItem> items = new ArrayList<>();

    public Order() {
    }

    /**
     * Trả về tên trạng thái tiếng Việt để hiển thị trên UI.
     * Mapping chuẩn từ DB value → Label hiển thị.
     */
    public String getOrderStatusVietnamese() {
        if (orderStatus == null) return "Không xác định";
        switch (orderStatus) {
            case STATUS_WAITING_PAYMENT:  return "Chờ thanh toán";
            case STATUS_PAID:             return "Đã thanh toán";
            case STATUS_PROCESSING:       return "Đang làm bánh";
            case STATUS_WAITING_DELIVERY: return "Chờ giao hàng";
            case STATUS_DELIVERING:       return "Đang giao hàng";
            case STATUS_COMPLETED:        return "Hoàn thành";
            case STATUS_CANCELLED:        return "Đã hủy";
            default:                      return orderStatus;
        }
    }

    /**
     * Trả về tên hiển thị cho Customer (giờ giống với tất cả role).
     */
    public String getOrderStatusForCustomer() {
        return getOrderStatusVietnamese();
    }

    public String getAppliedVoucherCode() {
        return appliedVoucherCode;
    }

    public void setAppliedVoucherCode(String appliedVoucherCode) {
        this.appliedVoucherCode = appliedVoucherCode;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
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

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getReceiverPhone() {
        return receiverPhone;
    }

    public void setReceiverPhone(String receiverPhone) {
        this.receiverPhone = receiverPhone;
    }

    public String getCustomerNote() {
        return customerNote;
    }

    public void setCustomerNote(String customerNote) {
        this.customerNote = customerNote;
    }

    public String getShipperNote() {
        return shipperNote;
    }

    public void setShipperNote(String shipperNote) {
        this.shipperNote = shipperNote;
    }


    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public boolean isCustomCake() {
        if (items != null && !items.isEmpty()) {
            for (OrderItem item : items) {
                String tplId = item.getTemplateId();
                String ccId = item.getCustomCakeId();
                // Bánh tự thiết kế (Custom Studio): Không có Template_ID của Admin mẫu, chỉ có Custom_Cake_ID
                if ((tplId == null || tplId.trim().isEmpty()) && (ccId != null && !ccId.trim().isEmpty())) {
                    return true;
                }
            }
        }
        return false;
    }

    // Kiểm tra đơn hàng có cả bánh có sẵn (TPL) lẫn bánh thiết kế (CC) không
    public boolean hasMixedCakeTypes() {
        if (items == null || items.isEmpty()) return false;
        boolean hasCustom = false;
        boolean hasTemplate = false;
        for (OrderItem item : items) {
            String tplId = item.getTemplateId();
            String ccId = item.getCustomCakeId();
            if ((tplId == null || tplId.trim().isEmpty()) && (ccId != null && !ccId.trim().isEmpty())) {
                hasCustom = true;
            } else {
                hasTemplate = true;
            }
            if (hasCustom && hasTemplate) return true;
        }
        return false;
    }

    public String getCakeTypeLabel() {
        if (hasMixedCakeTypes()) return "Hỗn hợp";
        return isCustomCake() ? "Thiết kế" : "Có sẵn";
    }


    public BigDecimal getRemainingAmount() {
        if (remainingCodBalance != null) {
            return remainingCodBalance;
        }
        BigDecimal total = totalCost == null ? BigDecimal.ZERO : totalCost;
        BigDecimal deposit = depositAmount == null ? BigDecimal.ZERO : depositAmount;
        return total.subtract(deposit);
    }
}
