package com.bakeryzone.model;

public class Ingredient {
    private String ingredientId;
    private String ingredientName;
    private String categoryId;
    private String categoryName;
    private double pricePerUnit;
    private String status;

    public Ingredient() {
    }

    public Ingredient(String ingredientId, String ingredientName, String categoryId, double pricePerUnit) {
        this.ingredientId = ingredientId;
        this.ingredientName = ingredientName;
        this.categoryId = categoryId;
        this.pricePerUnit = pricePerUnit;
        this.status = "Active";
    }

    public Ingredient(String ingredientId, String ingredientName, String categoryId, double pricePerUnit, String status) {
        this.ingredientId = ingredientId;
        this.ingredientName = ingredientName;
        this.categoryId = categoryId;
        this.pricePerUnit = pricePerUnit;
        this.status = status;
    }

    public String getIngredientId() {
        return ingredientId;
    }

    public void setIngredientId(String ingredientId) {
        this.ingredientId = ingredientId;
    }

    public String getIngredientName() {
        return ingredientName;
    }

    public void setIngredientName(String ingredientName) {
        this.ingredientName = ingredientName;
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

    public double getPricePerUnit() {
        return pricePerUnit;
    }

    public void setPricePerUnit(double pricePerUnit) {
        this.pricePerUnit = pricePerUnit;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
