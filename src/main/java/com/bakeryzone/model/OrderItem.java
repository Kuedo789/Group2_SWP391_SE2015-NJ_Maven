package com.bakeryzone.model;

import java.math.BigDecimal;

public class OrderItem {
    private String orderItemId;
    private String orderNo;
    private String customCakeId;
    private String accessoryId;
    private int quantity;
    private BigDecimal priceAtPurchase;
    
    // Fields mapped from cake_template or accessory for displaying on UI
    private String itemName;
    private String itemImage;

    public OrderItem() {
    }

    public String getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(String orderItemId) {
        this.orderItemId = orderItemId;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public String getCustomCakeId() {
        return customCakeId;
    }

    public void setCustomCakeId(String customCakeId) {
        this.customCakeId = customCakeId;
    }

    public String getAccessoryId() {
        return accessoryId;
    }

    public void setAccessoryId(String accessoryId) {
        this.accessoryId = accessoryId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPriceAtPurchase() {
        return priceAtPurchase;
    }

    public void setPriceAtPurchase(BigDecimal priceAtPurchase) {
        this.priceAtPurchase = priceAtPurchase;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String itemName) {
        this.itemName = itemName;
    }

    public String getItemImage() {
        return itemImage;
    }

    public void setItemImage(String itemImage) {
        this.itemImage = itemImage;
    }
}
