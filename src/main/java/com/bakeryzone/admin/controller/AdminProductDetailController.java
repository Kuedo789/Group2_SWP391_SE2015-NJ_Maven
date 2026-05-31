package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Controller Servlet for handling the admin product detail display and CRUD saving.
 * Maps to /admin/product-detail.
 */
@WebServlet(name = "AdminProductDetailController", urlPatterns = {"/admin/product-detail"})
public class AdminProductDetailController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        Product product = null;
        
        if ("new".equalsIgnoreCase(id)) {
            // Provide empty template for "Add New Cake"
            product = new Product(
                "new", "", "", "Chocolate Cakes", 0.0, 1.0, 0, "Active", false,
                "", "Chocolate Sponge", "Chocolate Ganache", "Chocolate Shavings & Cherry", "Cake",
                "Egg, Milk, Wheat, Soy", "1 kg", "3 Days", "Keep refrigerated. Best served chilled.",
                "", "", "Same Day"
            );
        } else {
            // Retrieve all products to search from
            List<Product> products = productDAO.getAllProductsAdmin();
            if (id != null && !id.trim().isEmpty()) {
                for (Product p : products) {
                    if (p.id().equalsIgnoreCase(id) || p.sku().equalsIgnoreCase(id)) {
                        product = p;
                        break;
                    }
                }
            }
        }
        
        // Fallback default product if ID is invalid or not found
        if (product == null) {
            product = new Product(
                "new", "", "", "Chocolate Cakes", 0.0, 1.0, 0, "Active", false,
                "", "Chocolate Sponge", "Chocolate Ganache", "Chocolate Shavings & Cherry", "Cake",
                "Egg, Milk, Wheat, Soy", "1 kg", "3 Days", "Keep refrigerated. Best served chilled.",
                "", "", "Same Day"
            );
        }
        
        // Expose product to the JSP detail view
        request.setAttribute("product", product);
        
        // Forward to the product detail JSP page
        request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Extract form fields
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String sku = request.getParameter("sku");
        String category = request.getParameter("category");
        
        double price = 0.0;
        try {
            price = Double.parseDouble(request.getParameter("price"));
        } catch (NumberFormatException e) {}
        
        int stock = 0;
        try {
            stock = Integer.parseInt(request.getParameter("stock"));
        } catch (NumberFormatException e) {}
        
        double laborHours = 1.0;
        try {
            laborHours = Double.parseDouble(request.getParameter("laborHours"));
        } catch (NumberFormatException e) {}
        
        String availability = request.getParameter("availability");
        String status = request.getParameter("status");
        
        // Checkboxes / Switches are only sent if checked
        boolean featured = request.getParameter("featured") != null;
        
        String spongeFlavor = request.getParameter("spongeFlavor");
        String frostingFlavor = request.getParameter("frostingFlavor");
        String toppingChoice = request.getParameter("toppingChoice");
        String allergens = request.getParameter("allergens");
        String weightSize = request.getParameter("weightSize");
        
        String shortDescription = request.getParameter("shortDescription");
        String fullDescription = request.getParameter("fullDescription");
        
        String shelfLife = request.getParameter("shelfLife");
        String storageInstructions = request.getParameter("storageInstructions");
        
        // 2. Adjust ID & type for new entries
        if (id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "CZ-PROD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        
        if (sku == null || sku.trim().isEmpty()) {
            sku = id;
        }
        
        String type = "Cake";
        if ("Accessories".equalsIgnoreCase(category)) {
            type = "Accessory";
            spongeFlavor = "";
            frostingFlavor = "";
            toppingChoice = "";
        }
        
        // Image URL mapping: default image from unsplash if custom image isn't provided
        String imageUrl = request.getParameter("imageUrl");
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            if ("Accessories".equalsIgnoreCase(category)) {
                imageUrl = "https://images.unsplash.com/photo-1549465220-1a8b9238cd48"; // default gift box
            } else {
                imageUrl = "https://images.unsplash.com/photo-1578985545062-69928b1d9587"; // default cake
            }
        }
        
        // 3. Construct product record
        Product product = new Product(
            id, name, sku, category, price, laborHours, stock, status, featured, imageUrl,
            spongeFlavor, frostingFlavor, toppingChoice, type, allergens, weightSize,
            shelfLife, storageInstructions, shortDescription, fullDescription, availability
        );
        
        // 4. Save via DAO
        productDAO.saveProduct(product);
        
        // 5. Redirect back to list view
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
