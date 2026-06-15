package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.dao.IngredientDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.model.Ingredient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Unified Controller Servlet for managing admin Product operations.
 * Replaces separate List and Detail controllers using action-based MVC routing.
 * Integrates dynamic pricing logic (Margin/Service percentages), Kitchen instructions,
 * and BOM (Bill of Materials) ingredient allocations.
 */
@WebServlet("/admin/product")
public class AdminProductController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final ProductDAO productDAO = new ProductDAO();
    private final IngredientDAO ingredientDAO = new IngredientDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                handleList(request, response);
                break;
            case "detail":
                handleDetail(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                handleList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "create":
                createProduct(request, response);
                break;
            case "update":
                updateProduct(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/product?action=list");
                break;
        }
    }

    // --- GET handlers ---

    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Extract filtering, sorting, and pagination parameters
        String category = request.getParameter("category");
        if (category == null) category = "";
        
        String status = request.getParameter("status");
        if (status == null) status = "";
        
        String search = request.getParameter("search");
        if (search == null) search = "";
        
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) sortBy = "newest";
        
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int pageSize = 10;
        String sizeStr = request.getParameter("pageSize");
        if (sizeStr != null && !sizeStr.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(sizeStr);
                if (pageSize < 1) pageSize = 10;
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        // Query records from DAO
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        request.setAttribute("productCategories", categories);
        
        ProductSearchResult searchResult = productDAO.getAllProductsAdmin(category, status, search, sortBy, page, pageSize);
        List<Product> products = searchResult.list();
        int totalCount = searchResult.totalCount();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        
        // Set attributes for JSTL in productList.jsp
        request.setAttribute("productList", products);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("category", category);
        request.setAttribute("status", status);
        request.setAttribute("search", search);
        request.setAttribute("sortBy", sortBy);
        
        // Check if client expects JSON response
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setContentType("application/json;charset=UTF-8");
            
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < products.size(); i++) {
                Product p = products.get(i);
                json.append(String.format(
                    "{"
                    + "\"id\":\"%s\","
                    + "\"name\":\"%s\","
                    + "\"categoryId\":\"%s\","
                    + "\"categoryName\":\"%s\","
                    + "\"basePrice\":%.2f,"
                    + "\"estimatedLaborHours\":%.2f,"
                    + "\"allowsGreeting\":%b,"
                    + "\"status\":\"%s\","
                    + "\"featured\":%b,"
                    + "\"imageUrl\":\"%s\","
                    + "\"fullDescription\":\"%s\","
                    + "\"productType\":\"%s\""
                    + "}",
                    p.getId(), escapeJson(p.getName()), 
                    escapeJson(p.getCategoryId()), escapeJson(p.getCategoryName()),
                    p.getBasePrice(), p.getEstimatedLaborHours(), p.isAllowsGreeting(),
                    escapeJson(p.getStatus()), p.isFeatured(), escapeJson(p.getImageUrl()), 
                    escapeJson(p.getFullDescription()), 
                    escapeJson(p.getProductType())
                ));
                if (i < products.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } else {
            request.getRequestDispatcher("/admin/productList.jsp").forward(request, response);
        }
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        Product product = null;
        if (id != null && !id.trim().isEmpty()) {
            product = productDAO.getProductById(id);
        }
        
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/admin/product?action=list");
            return;
        }
        
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        List<Map<String, Object>> productIngredients = productDAO.getProductIngredients(id);
        List<Ingredient> allIngredients = ingredientDAO.getAllIngredients();

        request.setAttribute("product", product);
        request.setAttribute("productCategories", categories);
        request.setAttribute("productIngredients", productIngredients);
        request.setAttribute("allIngredients", allIngredients);
        request.setAttribute("formAction", "update"); // Editing mode
        
        request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Product product = new Product();
        product.setId("new");
        product.setEstimatedLaborHours(1.0);
        product.setAllowsGreeting(true);
        product.setStatus("Active");
        product.setDefaultMarginPercent(30.00);
        product.setDefaultServicePercent(30.00);
        
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        List<Ingredient> allIngredients = ingredientDAO.getAllIngredients();

        request.setAttribute("product", product);
        request.setAttribute("productCategories", categories);
        request.setAttribute("allIngredients", allIngredients);
        request.setAttribute("formAction", "create"); // Creating mode
        
        request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        Product product = null;
        if (id != null && !id.trim().isEmpty()) {
            product = productDAO.getProductById(id);
        }
        
        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/admin/product?action=list");
            return;
        }
        
        List<Map<String, String>> categories = productDAO.getAllProductCategories();
        List<Map<String, Object>> productIngredients = productDAO.getProductIngredients(id);
        List<Ingredient> allIngredients = ingredientDAO.getAllIngredients();

        request.setAttribute("product", product);
        request.setAttribute("productCategories", categories);
        request.setAttribute("productIngredients", productIngredients);
        request.setAttribute("allIngredients", allIngredients);
        request.setAttribute("formAction", "update"); // Editing mode
        
        request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
    }

    // --- POST handlers ---

    private void createProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateProduct(request, response, true);
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateProduct(request, response, false);
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id != null && !id.trim().isEmpty()) {
            System.out.println("[INFO] Bat dau xoa banh kem co ID: " + id);
            try {
                productDAO.deleteProduct(id);
                System.out.println("[SUCCESS] Xoa banh kem co ID: " + id + " thanh cong!");
                response.sendRedirect(request.getContextPath() + "/admin/product?action=list&msg=delete_success");
            } catch (Exception e) {
                System.err.println("[ERROR] Loi khi xoa banh kem co ID: " + id + ". Details: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/product?action=list&msg=delete_error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/product?action=list");
        }
    }

    private void saveOrUpdateProduct(HttpServletRequest request, HttpServletResponse response, boolean isNew) 
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        String categoryId = request.getParameter("categoryId");
        
        // Validate Margin Percent
        double defaultMarginPercent = 30.00;
        boolean marginValid = true;
        try {
            String mParam = request.getParameter("defaultMarginPercent");
            if (mParam != null && !mParam.trim().isEmpty()) {
                defaultMarginPercent = Double.parseDouble(mParam);
                if (defaultMarginPercent < 0 || defaultMarginPercent >= 100) marginValid = false;
            }
        } catch (NumberFormatException e) {
            marginValid = false;
        }

        // Validate Service Percent
        double defaultServicePercent = 30.00;
        boolean serviceValid = true;
        try {
            String sParam = request.getParameter("defaultServicePercent");
            if (sParam != null && !sParam.trim().isEmpty()) {
                defaultServicePercent = Double.parseDouble(sParam);
                if (defaultServicePercent < 0 || defaultServicePercent >= 100) serviceValid = false;
            }
        } catch (NumberFormatException e) {
            serviceValid = false;
        }

        if (defaultMarginPercent + defaultServicePercent >= 100) {
            marginValid = false;
            serviceValid = false;
        }
        
        // Validate labor hours
        boolean laborValid = true;
        double estimatedLaborHours = 0.0;
        String laborParam = request.getParameter("estimatedLaborHours");
        try {
            if (laborParam != null && !laborParam.trim().isEmpty()) {
                estimatedLaborHours = Double.parseDouble(laborParam);
                if (estimatedLaborHours < 0) {
                    laborValid = false;
                }
            } else {
                laborValid = false;
            }
        } catch (NumberFormatException e) {
            laborValid = false;
        }
        
        // Validate name
        boolean nameValid = name != null && !name.trim().isEmpty() && name.trim().length() >= 3 && name.trim().length() <= 100;
        
        if (!nameValid || !laborValid || !marginValid || !serviceValid) {
            Product product = new Product();
            product.setId(id);
            product.setName(name);
            product.setCategoryId(categoryId);
            product.setEstimatedLaborHours(estimatedLaborHours);
            product.setAllowsGreeting(request.getParameter("allowsGreeting") != null && "true".equalsIgnoreCase(request.getParameter("allowsGreeting")));
            product.setImageUrl(request.getParameter("imageUrl"));
            product.setStatus(request.getParameter("status"));
            product.setFullDescription(request.getParameter("fullDescription"));
            product.setDefaultMarginPercent(defaultMarginPercent);
            product.setDefaultServicePercent(defaultServicePercent);
            product.setInstructionSteps(request.getParameter("instructionSteps"));
            
            StringBuilder errorMsg = new StringBuilder("Dữ liệu nhập vào không hợp lệ: ");
            if (!nameValid) {
                errorMsg.append("Tên bánh phải từ 3 đến 100 ký tự. ");
            }
            if (!laborValid) {
                errorMsg.append("Thời gian làm việc phải là số lớn hơn hoặc bằng 0. ");
            }
            if (!marginValid || !serviceValid) {
                errorMsg.append("Tỷ lệ biên lãi và phí dịch vụ phải hợp lệ, tổng cộng phải nhỏ hơn 100%. ");
            }
            
            request.setAttribute("product", product);
            request.setAttribute("productCategories", productDAO.getAllProductCategories());
            request.setAttribute("allIngredients", ingredientDAO.getAllIngredients());
            request.setAttribute("error", errorMsg.toString().trim());
            request.setAttribute("formAction", isNew ? "create" : "update");
            
            request.getRequestDispatcher("/admin/productDetail.jsp").forward(request, response);
            return;
        }
        
        boolean allowsGreeting = request.getParameter("allowsGreeting") != null && "true".equalsIgnoreCase(request.getParameter("allowsGreeting"));
        String imageUrl = request.getParameter("imageUrl");
        String status = request.getParameter("status");
        boolean isFeatured = request.getParameter("isFeatured") != null && "true".equalsIgnoreCase(request.getParameter("isFeatured"));
        String fullDescription = request.getParameter("fullDescription");
        String instructionSteps = request.getParameter("instructionSteps");
        
        if (isNew || id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "CZ-PROD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }
        
        String productType = "Cake";
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            imageUrl = "https://images.unsplash.com/photo-1578985545062-69928b1d9587"; 
        }
        
        Product product = new Product(
            id, name, categoryId, "", estimatedLaborHours, allowsGreeting, imageUrl,
            status, isFeatured, fullDescription, productType, defaultMarginPercent, defaultServicePercent,
            instructionSteps
        );
        
        System.out.println("[INFO] Bat dau luu banh kem. ID: " + product.getId() + ", Ten: " + product.getName() + " (isNew: " + isNew + ")");
        boolean saved = productDAO.saveProduct(product);
        if (saved) {
            // Process and save BOM (Bill of Materials) Ingredients
            String[] bomIngredientIds = request.getParameterValues("bomIngredientId");
            String[] bomStandardGrams = request.getParameterValues("bomStandardGram");
            productDAO.saveProductIngredients(id, bomIngredientIds, bomStandardGrams);
            
            System.out.println("[SUCCESS] Luu banh kem thanh cong. ID: " + product.getId());
            response.sendRedirect(request.getContextPath() + "/admin/product?action=list&msg=" + (isNew ? "add_success" : "edit_success"));
        } else {
            System.err.println("[ERROR] Luu banh kem that bai. ID: " + product.getId());
            response.sendRedirect(request.getContextPath() + "/admin/product?action=list&msg=save_error");
        }
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
