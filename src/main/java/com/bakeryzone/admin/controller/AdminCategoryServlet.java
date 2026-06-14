/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.CategoryDAO;
import com.bakeryzone.model.CategoryDTO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author thais
 */
@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    private final CategoryDAO dao = new CategoryDAO();

    // =======================================================================
    // GET REQUESTS: Routing the user to the correct view
    // =======================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String action = request.getParameter("action");
            if (action == null) {
                action = "list"; // Default action
            }

            switch (action) {
                case "delete":
                    handleDelete(request, response);
                    break;
                case "add":
                    showAddForm(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "restore": // ADD THIS CASE
                    handleRestore(request, response);
                    break;
                default:
                    listCategories(request, response);
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    // =======================================================================
    // POST REQUESTS: Catching data submitted from forms
    // =======================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            saveOrUpdateCategory(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=exception");
        }
    }

    // =======================================================================
    // HELPER METHODS (The "Workers")
    // =======================================================================
    private void listCategories(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // Catch redirect messages
        String msg = request.getParameter("msg");
        String error = request.getParameter("error");
        String success = request.getParameter("success");

        if (msg != null) {
            request.setAttribute("message", msg);
        }
        if (error != null) {
            request.setAttribute("error", error);
        }
        if (success != null) {
            request.setAttribute("success", success);
        }

        // Search & Filter
        String searchQuery = request.getParameter("search");
        String filterType = request.getParameter("filterType");
        if (searchQuery == null) {
            searchQuery = "";
        }
        if (filterType == null) {
            filterType = "all";
        }

        // Pagination
        int pageSize = 5;
        int currentPage = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            currentPage = Integer.parseInt(pageParam);
        }

// Math & Fetch
        int offset = (currentPage - 1) * pageSize;

        // Fetch the array of counts from the DAO
        int[] counts = dao.getTotalCategoriesCount(searchQuery, filterType);
        int totalRecords = counts[0];
        int totalActive = counts[1];
        int totalDisabled = counts[2];

        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        List<CategoryDTO> categoryList = dao.getAdminCategoriesByPage(offset, pageSize, searchQuery, filterType);

        // Send to JSP
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("totalActive", totalActive);     // NEW
        request.setAttribute("totalDisabled", totalDisabled); // NEW
        request.setAttribute("searchQuery", searchQuery);
        request.setAttribute("filterType", filterType);

        request.getRequestDispatcher("/admin/category-management.jsp").forward(request, response);
    }

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/category-add.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String id = request.getParameter("id");
        CategoryDTO cat = dao.getCategoryById(id);

        if (cat != null) {
            request.setAttribute("category", cat);
            request.getRequestDispatcher("/admin/category-edit.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=not_found");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String categoryId = request.getParameter("id");

        if (categoryId != null && !categoryId.trim().isEmpty()) {
            boolean success = dao.deleteCategory(categoryId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories?error=delete_failed");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

    private void saveOrUpdateCategory(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        request.setCharacterEncoding("UTF-8");
        String formAction = request.getParameter("formAction");

        String rawId = request.getParameter("categoryId");
        String id = (rawId != null) ? rawId.toUpperCase().trim() : "";
        String name = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String type = request.getParameter("categoryType");

        // 1. Check ID Format Security
        if (!id.matches("^CAT-[A-Z0-9\\-]+$")) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=invalid_id_format");
            return;
        }

        // 2. Check Description Length (Backend Defense)
        if (description != null && description.length() > 255) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=desc_too_long");
            return;
        }

        // ADDED 'true' to the constructor since newly added/updated items should be active!
        CategoryDTO cat = new CategoryDTO(id, name, description, type, true);
        boolean success = false;

        // 3. Save vs Update Logic with Duplicate Checking
        if ("update".equals(formAction)) {
            success = dao.updateCategory(cat);
        } else {
            // It's an ADD action. Check if ID exists first!
            if (dao.isCategoryIdExists(id)) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?error=duplicate_id");
                return; // Stop execution!
            }
            success = dao.addCategory(cat);
        }

        // 4. Final Routing
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?success=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=db_error");
        }
    }

    private void handleRestore(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String categoryId = request.getParameter("id");

        if (categoryId != null && !categoryId.trim().isEmpty()) {
            boolean success = dao.restoreCategory(categoryId);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories?error=db_error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

    @Override
    public String getServletInfo() {
        return "Admin Category Controller mapping actions to specific helper methods.";
    }
}
