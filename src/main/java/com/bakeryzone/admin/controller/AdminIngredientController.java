package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.IngredientDAO;
import com.bakeryzone.model.Ingredient;
import com.bakeryzone.model.IngredientCategory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/ingredient")
public class AdminIngredientController extends HttpServlet {
    private static final long serialVersionUID = 1L;
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
                createIngredient(request, response);
                break;
            case "update":
                updateIngredient(request, response);
                break;
            case "delete":
                deleteIngredient(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list");
                break;
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }
        
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int pageSize = 10;
        String pageSizeParam = request.getParameter("pageSize");
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeParam);
                if (pageSize < 1) pageSize = 10;
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }
        
        List<Ingredient> list = ingredientDAO.getIngredientsFiltered(search, page, pageSize);
        int totalCount = ingredientDAO.getIngredientsCountFiltered(search);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
            list = ingredientDAO.getIngredientsFiltered(search, page, pageSize);
        }
        
        request.setAttribute("ingredientList", list);
        request.setAttribute("search", search);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        
        request.getRequestDispatcher("/admin/ingredientList.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Ingredient ing = new Ingredient();
        ing.setIngredientId("new");
        
        request.setAttribute("ingredient", ing);
        request.setAttribute("formAction", "create");
        
        request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        Ingredient ing = ingredientDAO.getIngredientById(id);
        
        if (ing == null) {
            response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list");
            return;
        }

        request.setAttribute("ingredient", ing);
        request.setAttribute("formAction", "update");
        
        request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
    }

    private void createIngredient(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateIngredient(request, response, true);
    }

    private void updateIngredient(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateIngredient(request, response, false);
    }

    private void deleteIngredient(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (id != null && !id.trim().isEmpty()) {
            boolean success = ingredientDAO.deleteIngredient(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list&msg=delete_success");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list&msg=delete_error");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list");
        }
    }

    private void saveOrUpdateIngredient(HttpServletRequest request, HttpServletResponse response, boolean isNew) 
            throws ServletException, IOException {
        String id = request.getParameter("ingredientId");
        String name = request.getParameter("ingredientName");
        String priceParam = request.getParameter("pricePerUnit");
        String unitMeasure = request.getParameter("unitMeasure");
        String imageUrl = request.getParameter("imageUrl");

        double price = 0.0;
        boolean priceValid = true;
        try {
            if (priceParam != null && !priceParam.trim().isEmpty()) {
                price = Double.parseDouble(priceParam);
                if (price < 0) priceValid = false;
            } else {
                priceValid = false;
            }
        } catch (NumberFormatException e) {
            priceValid = false;
        }

        boolean nameValid = name != null && !name.trim().isEmpty() && name.trim().length() >= 2;

        if (unitMeasure == null || unitMeasure.trim().isEmpty()) {
            unitMeasure = "gram";
        }

        if (!nameValid || !priceValid) {
            Ingredient ing = new Ingredient(id, name, price, unitMeasure, imageUrl, true);
            request.setAttribute("ingredient", ing);
            request.setAttribute("error", "Dữ liệu nhập vào không hợp lệ. Tên nguyên liệu tối thiểu 2 ký tự, đơn giá phải lớn hơn hoặc bằng 0.");
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
            return;
        }

        if (isNew || id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "ING-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }

        Ingredient ingredient = new Ingredient(id, name, price, unitMeasure, imageUrl, true);
        boolean success = ingredientDAO.saveIngredient(ingredient);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/ingredient?action=list&msg=" + (isNew ? "add_success" : "edit_success"));
        } else {
            request.setAttribute("ingredient", ingredient);
            request.setAttribute("error", "Lỗi hệ thống khi lưu nguyên liệu.");
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
        }
    }
}
