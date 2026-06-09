/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.CategoryDAO;
import com.bakeryzone.model.CategoryDTO;
import java.io.IOException;
import java.io.PrintWriter;
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

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminCategoryServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminCategoryServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
// Handles displaying the page and the table
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            CategoryDAO dao = new CategoryDAO();

            // --- ACTION ROUTER (Add / Delete) ---
            String action = request.getParameter("action");

            if ("delete".equals(action)) {
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
                return; // Stop execution here
            }

            if ("add".equals(action)) {
                // Route user to the form
                request.getRequestDispatcher("/admin/category-add.jsp").forward(request, response);
                return; // Stop execution here
            }

            if ("edit".equals(action)) {
                String id = request.getParameter("id");
                CategoryDTO cat = dao.getCategoryById(id);
                if (cat != null) {
                    request.setAttribute("category", cat);
                    request.getRequestDispatcher("/admin/category-edit.jsp").forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/admin/categories?error=not_found");
                }
                return; // Stop execution here
            }

            // --- NORMAL TABLE LOAD (Pagination & Filters) ---
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
            int totalRecords = dao.getTotalCategoriesCount(searchQuery, filterType);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            List<CategoryDTO> categoryList = dao.getAdminCategoriesByPage(offset, pageSize, searchQuery, filterType);

            // Send to JSP
            request.setAttribute("categoryList", categoryList);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRecords", totalRecords);
            request.setAttribute("searchQuery", searchQuery);
            request.setAttribute("filterType", filterType);

            request.getRequestDispatcher("/admin/category-management.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    // =======================================================================
    // POST REQUESTS: Catching data submitted from the HTML forms (Save Button)
    // =======================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String formAction = request.getParameter("formAction");

        // 1. Force uppercase and trim accidental whitespaces
        String rawId = request.getParameter("categoryId");
        String id = (rawId != null) ? rawId.toUpperCase().trim() : "";

        String name = request.getParameter("categoryName");
        String description = request.getParameter("description");
        String type = request.getParameter("categoryType");

        // 2. BACKEND VALIDATION: Enforce ID Format Security
        if (!id.matches("^CAT-[A-Z0-9\\-]+$")) {
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=invalid_id_format");
            return; // Stops the process immediately
        }

        try {
            CategoryDTO cat = new CategoryDTO(id, name, description, type);
            CategoryDAO dao = new CategoryDAO();
            boolean success = false;

            if ("update".equals(formAction)) {
                success = dao.updateCategory(cat);
            } else {
                success = dao.addCategory(cat);
            }

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/categories?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories?error=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=exception");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
