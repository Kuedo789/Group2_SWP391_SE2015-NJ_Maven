package com.bakeryzone.model;

/**
 * Model representing a custom-designed cake saved by a customer.
 * Maps to the custom_cake table in the database.
 */
public class CustomCake {

    private String customCakeId;
    private String canvasImageUrl;
    private String greetingText;
    private String cakeHashStructure;
    private double calculatedPrice;

    public CustomCake() {}

    public CustomCake(String customCakeId, String canvasImageUrl, String greetingText,
                      String cakeHashStructure, double calculatedPrice) {
        this.customCakeId = customCakeId;
        this.canvasImageUrl = canvasImageUrl;
        this.greetingText = greetingText;
        this.cakeHashStructure = cakeHashStructure;
        this.calculatedPrice = calculatedPrice;
    }

    public String getCustomCakeId() {
        return customCakeId;
    }

    public void setCustomCakeId(String customCakeId) {
        this.customCakeId = customCakeId;
    }

    public String getCanvasImageUrl() {
        return canvasImageUrl;
    }

    public void setCanvasImageUrl(String canvasImageUrl) {
        this.canvasImageUrl = canvasImageUrl;
    }

    public String getGreetingText() {
        return greetingText;
    }

    public void setGreetingText(String greetingText) {
        this.greetingText = greetingText;
    }

    public String getCakeHashStructure() {
        return cakeHashStructure;
    }

    public void setCakeHashStructure(String cakeHashStructure) {
        this.cakeHashStructure = cakeHashStructure;
    }

    public double getCalculatedPrice() {
        return calculatedPrice;
    }

    public void setCalculatedPrice(double calculatedPrice) {
        this.calculatedPrice = calculatedPrice;
    }
}
