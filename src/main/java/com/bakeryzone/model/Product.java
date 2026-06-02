package com.bakeryzone.model;

/**
 * Model class representing a Product (either a Cake Template or an Accessory).
 * Synchronized with the updated database schema where stock and recipe columns are removed.
 */
public class Product {
    private String id;
    private String name;
    private String sku;
    private String category;
    private double price;
    private double laborHours;
    private String status;
    private boolean isFeatured;
    private String imageUrl;
    private String shortDescription;
    private String fullDescription;
    private String productType; // "Cake" or "Accessory"

    // Default constructor
    public Product() {
    }

    // Parameterized constructor
    public Product(String id, String name, String sku, String category, double price, double laborHours, 
                   String status, boolean isFeatured, String imageUrl, String shortDescription, 
                   String fullDescription, String productType) {
        this.id = id;
        this.name = name;
        this.sku = sku;
        this.category = category;
        this.price = price;
        this.laborHours = laborHours;
        this.status = status;
        this.isFeatured = isFeatured;
        this.imageUrl = imageUrl;
        this.shortDescription = shortDescription;
        this.fullDescription = fullDescription;
        this.productType = productType;
    }

    // Getters and Setters
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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public double getLaborHours() {
        return laborHours;
    }

    public void setLaborHours(double laborHours) {
        this.laborHours = laborHours;
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

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
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
        this.productType = productType;
    }
}
