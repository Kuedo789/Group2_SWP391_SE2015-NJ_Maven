/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.model;

/**
 *
 * @author thais
 */
public class CategoryDTO {
    private String categoryId;
    private String categoryName;
    private String description;
    private String categoryType; // "Sản phẩm chính" or "Nguyên liệu"
    private boolean enable; // NEW: Soft delete flag
    private String iconUrl; // NEW: Icon image path for category

    // Empty Constructor
    public CategoryDTO() {}

    // Original 5-arg Constructor
    public CategoryDTO(String categoryId, String categoryName, String description, String categoryType, boolean enable) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.description = description;
        this.categoryType = categoryType;
        this.enable = enable;
    }

    // New 6-arg Constructor with iconUrl
    public CategoryDTO(String categoryId, String categoryName, String description, String categoryType, boolean enable, String iconUrl) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.description = description;
        this.categoryType = categoryType;
        this.enable = enable;
        this.iconUrl = iconUrl;
    }

    // Getters and Setters
    public String getCategoryId() { return categoryId; }
    public void setCategoryId(String categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategoryType() { return categoryType; }
    public void setCategoryType(String categoryType) { this.categoryType = categoryType; }

    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }

    public String getIconUrl() {
        return iconUrl;
    }

    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }
}