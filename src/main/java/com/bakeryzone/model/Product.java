package com.bakeryzone.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a Product (Cake Template).
 * Synchronized with the updated database schema where static pricing, stock,
 * and accessory tables are removed, and pricing is computed dynamically.
 */
public class Product {
    private String id;
    private String name;
    private String categoryId;
    private String categoryName;
    private double basePrice; // Computed dynamically
    private double estimatedLaborHours; // Estimated_Labor_Hours
    private boolean allowsGreeting; // Allows_Greeting
    private String imageUrl;
    private String status;
    private boolean isFeatured;
    private String fullDescription;
    private String productType; // Always "Cake"

    // New dynamic financial fields and chef instructions
    private double defaultMarginPercent;
    private double defaultServicePercent;
    private String instructionSteps;

    private List<String> additionalImages = new ArrayList<>();

    // Default constructor
    public Product() {
        this.productType = "Cake";
        this.estimatedLaborHours = 0.0;
        this.basePrice = 0.0;
        this.allowsGreeting = true;
        this.defaultMarginPercent = 30.00;
        this.defaultServicePercent = 30.00;
    }

    // Parameterized constructor
    public Product(String id, String name, String categoryId, String categoryName,
            double estimatedLaborHours, boolean allowsGreeting, String imageUrl,
            String status, boolean isFeatured, String fullDescription,
            String productType, double defaultMarginPercent, double defaultServicePercent,
            String instructionSteps) {
        this.id = id;
        this.name = name;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.estimatedLaborHours = estimatedLaborHours;
        this.allowsGreeting = allowsGreeting;
        this.imageUrl = imageUrl;
        this.status = status;
        this.isFeatured = isFeatured;
        this.fullDescription = fullDescription;
        this.productType = "Cake";
        this.defaultMarginPercent = defaultMarginPercent;
        this.defaultServicePercent = defaultServicePercent;
        this.instructionSteps = instructionSteps;
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

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public boolean isAllowsGreeting() {
        return allowsGreeting;
    }

    public void setAllowsGreeting(boolean allowsGreeting) {
        this.allowsGreeting = allowsGreeting;
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

    public double getDefaultMarginPercent() {
        return defaultMarginPercent;
    }

    public void setDefaultMarginPercent(double defaultMarginPercent) {
        this.defaultMarginPercent = defaultMarginPercent;
    }

    public double getDefaultServicePercent() {
        return defaultServicePercent;
    }

    public void setDefaultServicePercent(double defaultServicePercent) {
        this.defaultServicePercent = defaultServicePercent;
    }

    public String getInstructionSteps() {
        return instructionSteps;
    }

    public void setInstructionSteps(String instructionSteps) {
        this.instructionSteps = instructionSteps;
    }

    public List<String> getAdditionalImages() {
        return additionalImages;
    }

    public void setAdditionalImages(List<String> additionalImages) {
        this.additionalImages = additionalImages;
    }
}
