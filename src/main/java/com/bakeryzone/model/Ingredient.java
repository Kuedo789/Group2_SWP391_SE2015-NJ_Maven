package com.bakeryzone.model;

public class Ingredient {
    private String ingredientId;
    private String ingredientName;
    private double pricePerUnit;
    private String unitId;
    private String unitName;
    private String imageUrl;
    private boolean enable;

    public Ingredient() {
        this.unitId = "G";
        this.enable = true;
    }

    public Ingredient(String ingredientId, String ingredientName, double pricePerUnit, String unitId, String imageUrl, boolean enable) {
        this.ingredientId = ingredientId;
        this.ingredientName = ingredientName;
        this.pricePerUnit = pricePerUnit;
        this.unitId = unitId;
        this.imageUrl = imageUrl;
        this.enable = enable;
    }

    public Ingredient(String ingredientId, String ingredientName, double pricePerUnit, String unitId, String unitName, String imageUrl, boolean enable) {
        this.ingredientId = ingredientId;
        this.ingredientName = ingredientName;
        this.pricePerUnit = pricePerUnit;
        this.unitId = unitId;
        this.unitName = unitName;
        this.imageUrl = imageUrl;
        this.enable = enable;
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

    public double getPricePerUnit() {
        return pricePerUnit;
    }

    public void setPricePerUnit(double pricePerUnit) {
        this.pricePerUnit = pricePerUnit;
    }

    // Deprecated but kept for backward compatibility in JSPs
    public String getUnitMeasure() {
        return unitId;
    }

    // Deprecated but kept for backward compatibility in JSPs
    public void setUnitMeasure(String unitMeasure) {
        this.unitId = unitMeasure;
    }

    public String getUnitId() {
        return unitId;
    }

    public void setUnitId(String unitId) {
        this.unitId = unitId;
    }

    public String getUnitName() {
        return unitName;
    }

    public void setUnitName(String unitName) {
        this.unitName = unitName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isEnable() {
        return enable;
    }

    public void setEnable(boolean enable) {
        this.enable = enable;
    }
}
