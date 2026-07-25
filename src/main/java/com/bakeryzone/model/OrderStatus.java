package com.bakeryzone.model;

public enum OrderStatus {
    Waiting_Payment("Chờ thanh toán"),
    PAID("Đã thanh toán"),
    Processing("Đang xử lý"),
    Waiting_Delivery("Chờ giao hàng"),
    Delivering("Đang giao hàng"),
    Completed("Hoàn thành"),
    Cancelled("Đã hủy");

    private final String description;

    OrderStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
