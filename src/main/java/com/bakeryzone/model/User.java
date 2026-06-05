/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.model;

import java.sql.Timestamp;

/**
 *
 * @author Asus
 */
public class User {

    private String userId;
    private String fullName;
    private String email;
    private String password;
    private String phone;
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

    public User(String userId, String fullName, String email, String password, String phone, String roleId, String roleName, boolean verified, String otpCode, Timestamp otpExpiry, String provider, String providerId, String accountStatus, boolean activeStaff) {
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

    public String getUserId() {
        return userId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhone() {
        return phone;
    }

    public String getRoleId() {
        return roleId;
    }

    public String getRoleName() {
        return roleName;
    }

    public boolean isVerified() {
        return verified;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public Timestamp getOtpExpiry() {
        return otpExpiry;
    }

    public String getProvider() {
        return provider;
    }

    public String getProviderId() {
        return providerId;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public boolean isActiveStaff() {
        return activeStaff;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setRoleId(String roleId) {
        this.roleId = roleId;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public void setVerified(boolean verified) {
        this.verified = verified;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public void setOtpExpiry(Timestamp otpExpiry) {
        this.otpExpiry = otpExpiry;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }

    public void setActiveStaff(boolean activeStaff) {
        this.activeStaff = activeStaff;
    }
    
    
}
