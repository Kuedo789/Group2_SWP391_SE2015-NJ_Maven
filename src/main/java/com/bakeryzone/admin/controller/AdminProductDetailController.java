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
import java.util.Map;
import java.util.UUID;

/**
 * Controller Servlet for handling the admin product detail display and CRUD saving.
 * Refactored to support exclusive Cake category features and cake_recipe formula assignments.
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
        
        if (id != null && !"new".equalsIgnoreCase(id) && !id.trim().isEmpty()) {
            product = productDAO.getProductById(id);
        }
        
        // Fallback default product if ID is invalid or not found (default 35% margin, 30% service)
        if (product == null) {
            product = new Product("new", "", "", "", "", 35.0, 30.0, "", "", "Active", false, "", "", "Cake");
            product.setEstimatedLaborHours(1.0);
        }
        
        // Load categories and recipe masters from DAO
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        List<Map<String, String>> recipes = productDAO.getAllRecipeMasters();
        
        // Expose them to the JSTL detail view
        request.setAttribute("product", product);
        request.setAttribute("productCategories", categories);
        request.setAttribute("recipeMasters", recipes);
        
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
        String categoryId = request.getParameter("categoryId");
        
        double marginPercent = 35.0;
        try {
            String marginParam = request.getParameter("marginPercent");
            if (marginParam != null && !marginParam.trim().isEmpty()) {
                marginPercent = Double.parseDouble(marginParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        double servicePercent = 30.0;
        try {
            String serviceParam = request.getParameter("servicePercent");
            if (serviceParam != null && !serviceParam.trim().isEmpty()) {
                servicePercent = Double.parseDouble(serviceParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        double estimatedLaborHours = 1.0;
        try {
            String laborParam = request.getParameter("estimatedLaborHours");
            if (laborParam != null && !laborParam.trim().isEmpty()) {
                estimatedLaborHours = Double.parseDouble(laborParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        String recipeId = request.getParameter("recipeId");
        String imageUrl = request.getParameter("imageUrl");
        String status = request.getParameter("status");
        
        // Checkboxes / Switches are only sent if checked
        boolean isFeatured = request.getParameter("isFeatured") != null && "true".equalsIgnoreCase(request.getParameter("isFeatured"));
        
        String shortDescription = request.getParameter("shortDescription");
        String fullDescription = request.getParameter("fullDescription");
        
        // 2. Adjust ID, SKU, and Type
        if (id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "CZ-PROD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        
        if (sku == null || sku.trim().isEmpty()) {
            sku = id;
        }
        
        String productType = "Cake";
        
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            imageUrl = "https://images.unsplash.com/photo-1578985545062-69928b1d9587"; 
        }
        
        // 3. Construct product JavaBean
        Product product = new Product(
            id, name, sku, categoryId, "", marginPercent, servicePercent, recipeId, imageUrl,
            status, isFeatured, shortDescription, fullDescription, productType
        );
        product.setEstimatedLaborHours(estimatedLaborHours);
        
        // Retrieve dynamic product images from form
        String[] additionalImagesArr = request.getParameterValues("additionalImages");
        if (additionalImagesArr != null) {
            java.util.List<String> additionalImages = new java.util.ArrayList<>();
            for (String img : additionalImagesArr) {
                if (img != null && !img.trim().isEmpty()) {
                    additionalImages.add(img.trim());
                }
            }
            product.setAdditionalImages(additionalImages);
        }
        
        // 4. Save via DAO
        productDAO.saveProduct(product);
        
        // 5. Redirect back to list view
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
