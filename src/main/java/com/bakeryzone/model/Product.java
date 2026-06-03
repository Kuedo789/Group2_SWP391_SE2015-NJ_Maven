package com.bakeryzone.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a Product (Cake Template).
 * Synchronized with the updated database schema where static pricing, stock,
 * and accessory tables are removed.
 */
public class Product {
    private String id;
    private String name;
    private String sku;
    private String categoryId;
    private String categoryName;
    private double marginPercent; // Default_Margin_Percent
    private double servicePercent; // Default_Service_Percent
    private String recipeId; // References cake_recipe (Recipe_ID)
    private String imageUrl;
    private String status;
    private boolean isFeatured;
    private String shortDescription;
    private String fullDescription;
    private String productType; // Always "Cake"
    private double estimatedLaborHours;
    private List<String> additionalImages = new ArrayList<>(); // Secondary images from product_image

    // Default constructor
    public Product() {
        this.productType = "Cake";
        this.estimatedLaborHours = 0.0;
    }

    // Parameterized constructor
    public Product(String id, String name, String sku, String categoryId, String categoryName, 
                   double marginPercent, double servicePercent, String recipeId, String imageUrl, 
                   String status, boolean isFeatured, String shortDescription, String fullDescription, 
                   String productType) {
        this.id = id;
        this.name = name;
        this.sku = sku;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.marginPercent = marginPercent;
        this.servicePercent = servicePercent;
        this.recipeId = recipeId;
        this.imageUrl = imageUrl;
        this.status = status;
        this.isFeatured = isFeatured;
        this.shortDescription = shortDescription;
        this.fullDescription = fullDescription;
        this.productType = "Cake";
        this.additionalImages = new ArrayList<>();
        this.estimatedLaborHours = 0.0;
    }

    // Getters and Setters
    public double getEstimatedLaborHours() {
        return estimatedLaborHours;
    }

    public void setEstimatedLaborHours(double estimatedLaborHours) {
        this.estimatedLaborHours = estimatedLaborHours;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public double getMarginPercent() {
        return marginPercent;
    }

    public void setMarginPercent(double marginPercent) {
        this.marginPercent = marginPercent;
    }

    public double getServicePercent() {
        return servicePercent;
    }

    public void setServicePercent(double servicePercent) {
        this.servicePercent = servicePercent;
    }

    public String getRecipeId() {
        return recipeId;
    }

    public void setRecipeId(String recipeId) {
        this.recipeId = recipeId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isFeatured() {
        return isFeatured;
    }

    public void setFeatured(boolean featured) {
        isFeatured = featured;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    public String getFullDescription() {
        return fullDescription;
    }

    public void setFullDescription(String fullDescription) {
        this.fullDescription = fullDescription;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = "Cake";
    }

    public List<String> getAdditionalImages() {
        return additionalImages;
    }

    public void setAdditionalImages(List<String> additionalImages) {
        this.additionalImages = additionalImages;
    }
}
