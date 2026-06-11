package com.bakeryzone.model;

import java.sql.Timestamp;

/**
 * User lưu thông tin tài khoản đăng nhập.
 *
 * Các field fullName, phone, defaultAddress, activeStaff không nằm trực tiếp
 * trong bảng user. Chúng được lấy thêm khi JOIN với customer/staff để tiện dùng
 * trong servlet, session, navbar, profile.
 */
public class User {

    private String userId;
    private String email;
    private String password;

    private String roleId;
    private String roleName;

    private boolean verified;
    private String otpCode;
    private Timestamp otpExpiry;

    private Timestamp createdAt;
    private String accountStatus;

    // Field phụ lấy từ customer/staff qua JOIN
    private String fullName;
    private String phone;
    private String defaultAddress;
    private boolean activeStaff;

    public User() {
    }

    public User(String userId, String email, String password, String roleId,
                String roleName, boolean verified, String otpCode,
                Timestamp otpExpiry, Timestamp createdAt, String accountStatus) {
        this.userId = userId;
        this.email = email;
        this.password = password;
        this.roleId = roleId;
        this.roleName = roleName;
        this.verified = verified;
        this.otpCode = otpCode;
        this.otpExpiry = otpExpiry;
        this.createdAt = createdAt;
        this.accountStatus = accountStatus;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getRoleId() {
        return roleId;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }
    
    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
    
    public boolean isVerified() {
        return verified;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }
    
    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }
    
    public Timestamp getOtpExpiry() {
        return otpExpiry;
    }

    public void setOtpExpiry(Timestamp otpExpiry) {
        this.otpExpiry = otpExpiry;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
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

    public boolean isActiveStaff() {
        return activeStaff;
    }

    public boolean isIsActiveStaff() {
        return activeStaff;
    }

    public void setActiveStaff(boolean activeStaff) {
        this.activeStaff = activeStaff;
    }
}