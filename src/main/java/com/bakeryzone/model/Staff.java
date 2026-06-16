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
public class Staff {
   private String staffId;
    private String userId;       
    private String fullName;
    private String phone;
    private String position;    
    private boolean isActiveStaff;
    private Timestamp createdAt; 
    private String email;
    private String password;
    private String roleId;
    private String accountStatus;

    public Staff() {
    }

    public Staff(String staffId, String userId, String fullName, String phone, String position, boolean isActiveStaff, Timestamp createdAt, String email, String password, String roleId, String accountStatus) {
        this.staffId = staffId;
        this.userId = userId;
        this.fullName = fullName;
        this.phone = phone;
        this.position = position;
        this.isActiveStaff = isActiveStaff;
        this.createdAt = createdAt;
        this.email = email;
        this.password = password;
        this.roleId = roleId;
        this.accountStatus = accountStatus;
    }

    public String getStaffId() {
        return staffId;
    }

    public void setStaffId(String staffId) {
        this.staffId = staffId;
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

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public boolean isIsActiveStaff() {
        return isActiveStaff;
    }

    public void setIsActiveStaff(boolean isActiveStaff) {
        this.isActiveStaff = isActiveStaff;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
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

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }

    
    
    
}
