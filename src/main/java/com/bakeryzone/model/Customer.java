package com.bakeryzone.model;

import java.sql.Timestamp;

/**
 * Customer lưu hồ sơ khách hàng.
 *
 * Email, password, role, OTP, account status nằm ở bảng user.
 */
public class Customer {

    private String customerId;
    private String userId;

    private String fullName;
    private String phone;
    private String defaultAddress;

    private Timestamp createdAt;

    public Customer() {
    }

    public Customer(String customerId, String userId, String fullName,
                    String phone, String defaultAddress, Timestamp createdAt) {
        this.customerId = customerId;
        this.userId = userId;
        this.fullName = fullName;
        this.phone = phone;
        this.defaultAddress = defaultAddress;
        this.createdAt = createdAt;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
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

    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getDefaultAddress() {
        return defaultAddress;
    }
    
    public void setDefaultAddress(String defaultAddress) {
        this.defaultAddress = defaultAddress;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}