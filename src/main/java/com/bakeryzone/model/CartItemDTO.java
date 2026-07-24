package com.bakeryzone.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.regex.Pattern;

public class CartItemDTO {
    // Strict pattern matching tracking for universal database ID design
    private static final Pattern VALID_ID_PATTERN = Pattern.compile("^CRT-[A-Z0-9\\-]+$");

    // Core Cart Identifiers
    private String cartItemId;
    private int quantity;
    private LocalDateTime addedAt;

    // Flattened UI Fields (Populated by the DAO via SQL JOINs)
    private String name;
    private String description;
    private String greetingText;
    private BigDecimal unitPrice;
    private String imageUrl;
    
    private String customCakeId;

    // Soft-Delete Flag for UI rendering
    private boolean isActive; 


    public CartItemDTO() {}

    public String getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(String cartItemId) {
        if (cartItemId != null && !VALID_ID_PATTERN.matcher(cartItemId).matches()) {
            throw new IllegalArgumentException("Violates System Architecture: Cart ID does not match strict prefix format.");
        }
        this.cartItemId = cartItemId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        if (quantity < 1) {
            throw new IllegalArgumentException("Validation Error: Cart item quantity must be at least 1.");
        }
        this.quantity = quantity;
    }

    public LocalDateTime getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getGreetingText() {
        return greetingText;
    }

    public void setGreetingText(String greetingText) {
        this.greetingText = greetingText;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public String getCustomCakeId() {
        return customCakeId;
    }

    public void setCustomCakeId(String customCakeId) {
        this.customCakeId = customCakeId;
    }
}