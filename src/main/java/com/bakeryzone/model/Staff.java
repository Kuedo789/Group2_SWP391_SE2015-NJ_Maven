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

    private User user;

    public Staff() {
    }

    public Staff(String staffId, String userId, String fullName, String phone, String position, boolean isActiveStaff, Timestamp createdAt, User user) {
        this.staffId = staffId;
        this.userId = userId;
        this.fullName = fullName;
        this.phone = phone;
        this.position = position;
        this.isActiveStaff = isActiveStaff;
        this.createdAt = createdAt;
        this.user = user;
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

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

}
