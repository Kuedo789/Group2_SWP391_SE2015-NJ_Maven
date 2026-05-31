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
        
        // 1. Handle actions (e.g., delete)
        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            String deleteId = request.getParameter("id");
            if (deleteId != null && !deleteId.trim().isEmpty()) {
                productDAO.deleteProduct(deleteId);
            }
            response.sendRedirect(request.getContextPath() + "/admin/products");
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
                    + "\"sku\":\"%s\","
                    + "\"category\":\"%s\","
                    + "\"price\":%.2f,"
                    + "\"laborHours\":%.2f,"
                    + "\"stock\":%d,"
                    + "\"status\":\"%s\","
                    + "\"featured\":%b,"
                    + "\"imageUrl\":\"%s\","
                    + "\"spongeFlavor\":\"%s\","
                    + "\"frostingFlavor\":\"%s\","
                    + "\"toppingChoice\":\"%s\","
                    + "\"type\":\"%s\","
                    + "\"allergens\":\"%s\","
                    + "\"weightSize\":\"%s\","
                    + "\"shelfLife\":\"%s\","
                    + "\"storageInstructions\":\"%s\","
                    + "\"shortDescription\":\"%s\","
                    + "\"fullDescription\":\"%s\","
                    + "\"availability\":\"%s\""
                    + "}",
                    p.id(), escapeJson(p.name()), escapeJson(p.sku()), escapeJson(p.category()), 
                    p.price(), p.laborHours(), p.stock(), escapeJson(p.status()), p.featured(), 
                    escapeJson(p.imageUrl()), escapeJson(p.spongeFlavor()), escapeJson(p.frostingFlavor()), 
                    escapeJson(p.toppingChoice()), escapeJson(p.type()), escapeJson(p.allergens()), 
                    escapeJson(p.weightSize()), escapeJson(p.shelfLife()), escapeJson(p.storageInstructions()), 
                    escapeJson(p.shortDescription()), escapeJson(p.fullDescription()), escapeJson(p.availability())
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
