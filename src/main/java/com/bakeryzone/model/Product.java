package com.bakeryzone.model;

/**
 * Represents a product in the BakeryZone system.
 * This can be either a cake template or an accessory.
 * 
 * Uses Java Record (introduced in Java 14, standardized in Java 16) 
 * for clean, immutable data representation.
 */
public record Product(
    String id,
    String name,
    String sku,
    String category,
    double price,
    double laborHours,
    int stock,
    String status,
    boolean featured,
    String imageUrl,
    String spongeFlavor,
    String frostingFlavor,
    String toppingChoice,
    String type,
    String allergens,
    String weightSize,
    String shelfLife,
    String storageInstructions,
    String shortDescription,
    String fullDescription,
    String availability
) {
    
    /**
     * Helper to get a human-readable preparation time.
     */
    public String getPreparationTimeDisplay() {
        if (laborHours <= 0) {
            return "N/A";
        }
        if (laborHours == (int) laborHours) {
            return (int) laborHours + " hours";
        }
        return laborHours + " hours";
    }
}
