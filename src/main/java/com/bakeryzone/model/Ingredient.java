package com.bakeryzone.model;

public class Ingredient {
    private String ingredientId;
    private String ingredientName;
    private double pricePerUnit;
    private String unitMeasure;
    private String imageUrl;
    private boolean enable;

    public Ingredient() {
        this.unitMeasure = "gram";
        this.enable = true;
    }

    public Ingredient(String ingredientId, String ingredientName, double pricePerUnit, String unitMeasure, String imageUrl, boolean enable) {
        this.ingredientId = ingredientId;
        this.ingredientName = ingredientName;
        this.pricePerUnit = pricePerUnit;
        this.unitMeasure = unitMeasure;
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

    public String getUnitMeasure() {
        return unitMeasure;
    }

    public void setUnitMeasure(String unitMeasure) {
        this.unitMeasure = unitMeasure;
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
