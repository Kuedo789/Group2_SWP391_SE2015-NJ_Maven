package com.bakeryzone.model;

/**
 * Model representing one flavor layer entry in a custom cake.
 * Maps to the custom_cake_layer_ingredient table.
 */
public class CustomCakeLayerIngredient {

    private int layerIngredientId;
    private String customCakeId;
    private int layerPosition;       // 1 = bottom layer, up to 5 = top layer
    private String ingredientId;
    private double quantityUsed;     // Base quantity scaled by cake size multiplier

    public CustomCakeLayerIngredient() {}

    public CustomCakeLayerIngredient(String customCakeId, int layerPosition,
                                     String ingredientId, double quantityUsed) {
        this.customCakeId = customCakeId;
        this.layerPosition = layerPosition;
        this.ingredientId = ingredientId;
        this.quantityUsed = quantityUsed;
    }

    public int getLayerIngredientId() {
        return layerIngredientId;
    }

    public void setLayerIngredientId(int layerIngredientId) {
        this.layerIngredientId = layerIngredientId;
    }

    public String getCustomCakeId() {
        return customCakeId;
    }

    public void setCustomCakeId(String customCakeId) {
        this.customCakeId = customCakeId;
    }

    public int getLayerPosition() {
        return layerPosition;
    }

    public void setLayerPosition(int layerPosition) {
        this.layerPosition = layerPosition;
    }

    public String getIngredientId() {
        return ingredientId;
    }

    public void setIngredientId(String ingredientId) {
        this.ingredientId = ingredientId;
    }

    public double getQuantityUsed() {
        return quantityUsed;
    }

    public void setQuantityUsed(double quantityUsed) {
        this.quantityUsed = quantityUsed;
    }
}
