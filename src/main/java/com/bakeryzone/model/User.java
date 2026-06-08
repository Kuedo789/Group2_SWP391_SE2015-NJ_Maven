/*
 * Model User dùng để lưu thông tin tài khoản trong hệ thống.
 * Bao gồm cả tài khoản đăng ký thường LOCAL và tài khoản Google.
 */
package com.bakeryzone.model;

import java.sql.Timestamp;

public class User {

    private String userId;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String defaultAddress;
    private String roleId;
    private String roleName;
    private boolean verified;
    private String otpCode;
    private Timestamp otpExpiry;
    private String provider;
    private String providerId;
    private String accountStatus;
    private boolean activeStaff;

    public User() {
    }

    // Constructor đầy đủ: dùng khi cần khởi tạo User với toàn bộ thông tin
    public User(String userId, String fullName, String email, String password,
            String phone, String roleId, String roleName,
            boolean verified, String otpCode, Timestamp otpExpiry,
            String provider, String providerId,
            String accountStatus, boolean activeStaff) {

        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.roleId = roleId;
        this.roleName = roleName;
        this.verified = verified;
        this.otpCode = otpCode;
        this.otpExpiry = otpExpiry;
        this.provider = provider;
        this.providerId = providerId;
        this.accountStatus = accountStatus;
        this.activeStaff = activeStaff;
    }

    // Constructor ngắn: giữ lại để tránh lỗi nếu code của thành viên khác đang gọi constructor cũ
//    public User(String userId, String fullName, String email, String password,
//                String phone, String roleId, String roleName, String accountStatus) {
//
//        this.userId = userId;
//        this.fullName = fullName;
//        this.email = email;
//        this.password = password;
//        this.phone = phone;
//        this.roleId = roleId;
//        this.roleName = roleName;
//        this.accountStatus = accountStatus;
//    }
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }

    public boolean isActiveStaff() {
        return activeStaff;
    }

    public void setActiveStaff(boolean activeStaff) {
        this.activeStaff = activeStaff;
    }
}
