package com.bakeryzone.model;

import java.util.List;

/**
 * Data carrier grouping a paginated sublist of products and the total record count.
 * Used for rendering pagination states in the admin product list view.
 */
public record ProductSearchResult(
    List<Product> list,
    int totalCount
) {}
