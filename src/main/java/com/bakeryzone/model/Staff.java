/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.model;

/**
 *
 * @author Asus
 */
public class Staff {
    private String staffId;
    private String fullName;
    private String email;
    private String password;
    private String phone;
    private String roleId;
    private String accountStatus;
    private boolean isActiveStaff;

    public Staff() {
    }

    public Staff(String staffId, String fullName, String email, String password, String phone, String roleId, String accountStatus, boolean isActiveStaff) {
        this.staffId = staffId;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.roleId = roleId;
        this.accountStatus = accountStatus;
        this.isActiveStaff = isActiveStaff;
    }

    public String getStaffId() {
        return staffId;
    }

    public void setStaffId(String staffId) {
        this.staffId = staffId;
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

    public boolean isIsActiveStaff() {
        return isActiveStaff;
    }

    public void setIsActiveStaff(boolean isActiveStaff) {
        this.isActiveStaff = isActiveStaff;
    }
    
    
}