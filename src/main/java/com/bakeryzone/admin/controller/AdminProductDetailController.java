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
 * Refactored to match JavaBean model structure and MySQL schema updates.
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
            product = new Product("new", "", "", "Chocolate Cakes", 0.0, 1.0, "Active", false, "", "", "", "Cake");
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
            String priceParam = request.getParameter("price");
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                price = Double.parseDouble(priceParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
        double laborHours = 1.0;
        try {
            String laborHoursParam = request.getParameter("laborHours");
            if (laborHoursParam != null && !laborHoursParam.trim().isEmpty()) {
                laborHours = Double.parseDouble(laborHoursParam);
            }
        } catch (NumberFormatException | NullPointerException e) {}
        
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
        
        String productType = "Accessories".equalsIgnoreCase(category) ? "Accessory" : "Cake";
        
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            if ("Accessories".equalsIgnoreCase(category)) {
                imageUrl = "https://images.unsplash.com/photo-1549465220-1a8b9238cd48"; 
            } else {
                imageUrl = "https://images.unsplash.com/photo-1578985545062-69928b1d9587"; 
            }
        }
        
        // 3. Construct product JavaBean
        Product product = new Product(
            id, name, sku, category, price, laborHours, status, isFeatured, imageUrl,
            shortDescription, fullDescription, productType
        );
        
        // 4. Save via DAO
        productDAO.saveProduct(product);
        
        // 5. Redirect back to list view
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
