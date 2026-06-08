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
        
        // Fallback default product if ID is invalid or not found
        if (product == null) {
            product = new Product();
            product.setId("new");
            product.setEstimatedLaborHours(1.0);
            product.setBasePrice(100.00);
            product.setAllowsGreeting(true);
            product.setStatus("Active");
        }
        
        // Load categories from DAO (Recipe Formula selection is removed from cake_template)
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        
        // Expose them to the JSTL detail view
        request.setAttribute("product", product);
        request.setAttribute("productCategories", categories);
        
        // Forward to the product detail JSP page
        request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
    }
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Extract form fields
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String categoryId = request.getParameter("categoryId");
        
        double basePrice = 0.0;
        try {
            String priceParam = request.getParameter("basePrice");
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                basePrice = Double.parseDouble(priceParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        double estimatedLaborHours = 1.0;
        try {
            String laborParam = request.getParameter("estimatedLaborHours");
            if (laborParam != null && !laborParam.trim().isEmpty()) {
                estimatedLaborHours = Double.parseDouble(laborParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        boolean allowsGreeting = request.getParameter("allowsGreeting") != null && "true".equalsIgnoreCase(request.getParameter("allowsGreeting"));
        
        String imageUrl = request.getParameter("imageUrl");
        String status = request.getParameter("status");
        
        // Checkboxes / Switches are only sent if checked
        boolean isFeatured = request.getParameter("isFeatured") != null && "true".equalsIgnoreCase(request.getParameter("isFeatured"));
        
        String fullDescription = request.getParameter("fullDescription");
        
        // Recipe properties
        String recipeName = request.getParameter("recipeName");
        String recipeInstructions = request.getParameter("recipeInstructions");
        
        // 2. Adjust ID and Type
        boolean isNew = false;
        if (id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "CZ-PROD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            isNew = true;
        }
        
        String productType = "Cake";
        
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            imageUrl = "https://images.unsplash.com/photo-1578985545062-69928b1d9587"; 
        }
        
        // 3. Construct product JavaBean
        Product product = new Product(
            id, name, categoryId, "", basePrice, estimatedLaborHours, allowsGreeting, imageUrl,
            status, isFeatured, fullDescription, productType
        );
        
        product.setRecipeName(recipeName);
        product.setRecipeInstructions(recipeInstructions);
        
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
        System.out.println("[INFO] Bat dau luu banh kem. ID: " + product.getId() + ", Ten: " + product.getName() + " (isNew: " + isNew + ")");
        boolean saved = productDAO.saveProduct(product);
        if (saved) {
            System.out.println("[SUCCESS] Luu banh kem thanh cong. ID: " + product.getId());
            if (isNew) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=add_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=edit_success");
            }
        } else {
            System.err.println("[ERROR] Luu banh kem that bai. ID: " + product.getId());
            response.sendRedirect(request.getContextPath() + "/admin/products?msg=save_error");
        }
    }
}
