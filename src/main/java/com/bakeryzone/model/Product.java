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
    private String categoryId;
    private String categoryName;
    private double basePrice; // Base_Price
    private double estimatedLaborHours; // Estimated_Labor_Hours
    private boolean allowsGreeting; // Allows_Greeting
    private String imageUrl;
    private String status;
    private boolean isFeatured;
    private String fullDescription;
    private String productType; // Always "Cake"
    private List<String> additionalImages = new ArrayList<>(); // Secondary images from product_image
    
    // Cake Recipe Fields (1:1 relationship)
    private String recipeId;
    private String recipeName;
    private String recipeInstructions;

    // Default constructor
    public Product() {
        this.productType = "Cake";
        this.estimatedLaborHours = 0.0;
        this.basePrice = 0.0;
        this.allowsGreeting = true;
    }

    // Parameterized constructor
    public Product(String id, String name, String categoryId, String categoryName, 
                   double basePrice, double estimatedLaborHours, boolean allowsGreeting, String imageUrl, 
                   String status, boolean isFeatured, String fullDescription, 
                   String productType) {
        this.id = id;
        this.name = name;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.basePrice = basePrice;
        this.estimatedLaborHours = estimatedLaborHours;
        this.allowsGreeting = allowsGreeting;
        this.imageUrl = imageUrl;
        this.status = status;
        this.isFeatured = isFeatured;
        this.fullDescription = fullDescription;
        this.productType = "Cake";
        this.additionalImages = new ArrayList<>();
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

    public List<String> getAdditionalImages() {
        return additionalImages;
    }

    public void setAdditionalImages(List<String> additionalImages) {
        this.additionalImages = additionalImages;
    }

    public String getRecipeId() {
        return recipeId;
    }

    public void setRecipeId(String recipeId) {
        this.recipeId = recipeId;
    }

    public String getRecipeName() {
        return recipeName;
    }

    public void setRecipeName(String recipeName) {
        this.recipeName = recipeName;
    }

    public String getRecipeInstructions() {
        return recipeInstructions;
    }

    public void setRecipeInstructions(String recipeInstructions) {
        this.recipeInstructions = recipeInstructions;
    }
}
