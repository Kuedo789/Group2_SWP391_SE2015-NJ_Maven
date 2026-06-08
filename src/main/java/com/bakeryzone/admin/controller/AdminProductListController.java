package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Controller Servlet for handling the admin product list operations.
 * Maps to /admin/products and supports pagination, search, category/status filters, and delete actions.
 */
@WebServlet(name = "AdminProductListController", urlPatterns = {"/admin/products"})
public class AdminProductListController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Handle actions (e.g., deactivate)
        String action = request.getParameter("action");
        if ("deactivate".equalsIgnoreCase(action)) {
            String deactivateId = request.getParameter("id");
            if (deactivateId != null && !deactivateId.trim().isEmpty()) {
                System.out.println("[INFO] Bat dau vo hieu hoa banh kem co ID: " + deactivateId);
                boolean success = productDAO.deactivateProduct(deactivateId);
                if (success) {
                    System.out.println("[SUCCESS] Vo hieu hoa banh kem co ID: " + deactivateId + " thanh cong!");
                    response.sendRedirect(request.getContextPath() + "/admin/products?msg=deactivate_success");
                } else {
                    System.err.println("[ERROR] Loi khi vo hieu hoa banh kem co ID: " + deactivateId);
                    response.sendRedirect(request.getContextPath() + "/admin/products?msg=deactivate_error");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products");
            }
            return;
        }
        
        if ("activate".equalsIgnoreCase(action)) {
            String activateId = request.getParameter("id");
            if (activateId != null && !activateId.trim().isEmpty()) {
                System.out.println("[INFO] Bat dau kich hoat banh kem co ID: " + activateId);
                boolean success = productDAO.activateProduct(activateId);
                if (success) {
                    System.out.println("[SUCCESS] Kich hoat banh kem co ID: " + activateId + " thanh cong!");
                    response.sendRedirect(request.getContextPath() + "/admin/products?msg=activate_success");
                } else {
                    System.err.println("[ERROR] Loi khi kich hoat banh kem co ID: " + activateId);
                    response.sendRedirect(request.getContextPath() + "/admin/products?msg=activate_error");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/products");
            }
            return;
        }
        
        // 2. Extract filtering, sorting, and pagination parameters
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
        
        // 3. Query records from DAO
        List<java.util.Map<String, String>> categories = productDAO.getAllProductCategories();
        request.setAttribute("productCategories", categories);
        
        ProductSearchResult searchResult = productDAO.getAllProductsAdmin(category, status, search, sortBy, page, pageSize);
        List<Product> products = searchResult.list();
        int totalCount = searchResult.totalCount();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        
        // 4. Set attributes for JSTL in productList.jsp
        request.setAttribute("productList", products);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("category", category);
        request.setAttribute("status", status);
        request.setAttribute("search", search);
        request.setAttribute("sortBy", sortBy);
        
        // Check if client expects JSON response (for AJAX or API testing)
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setContentType("application/json;charset=UTF-8");
            
            // Build simple JSON output manually to avoid external library runtime dependencies
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
            // Forward to standard JSTL JSP view
            request.getRequestDispatcher("/admin/productList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }

    /**
     * Escape special characters for standard JSON compliance.
     */
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
