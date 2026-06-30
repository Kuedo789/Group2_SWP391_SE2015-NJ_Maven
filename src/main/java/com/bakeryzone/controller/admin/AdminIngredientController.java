package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.IngredientDAO;
import com.bakeryzone.dao.UnitMeasureDAO;
import com.bakeryzone.model.Ingredient;
import com.bakeryzone.model.UnitMeasure;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/ingredient")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB max file size
    maxRequestSize = 1024 * 1024 * 10    // 10 MB max request size
)
public class AdminIngredientController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final IngredientDAO ingredientDAO = new IngredientDAO();
    private final UnitMeasureDAO unitMeasureDAO = new UnitMeasureDAO();

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
        
        String unitId = request.getParameter("unitId");
        if (unitId == null) {
            unitId = "";
        }

        String sortBy = request.getParameter("sortBy");
        if (sortBy == null) {
            sortBy = "";
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
        
        List<Ingredient> list = ingredientDAO.getIngredientsFiltered(search, unitId, sortBy, page, pageSize);
        int totalCount = ingredientDAO.getIngredientsCountFiltered(search, unitId);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
            list = ingredientDAO.getIngredientsFiltered(search, unitId, sortBy, page, pageSize);
        }
        
        request.setAttribute("ingredientList", list);
        request.setAttribute("search", search);
        request.setAttribute("unitId", unitId);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("unitMeasures", unitMeasureDAO.getAllUnitMeasures());
        
        request.getRequestDispatcher("/admin/ingredientList.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Ingredient ing = new Ingredient();
        ing.setIngredientId("new");
        
        request.setAttribute("ingredient", ing);
        request.setAttribute("unitMeasures", unitMeasureDAO.getAllUnitMeasures());
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
        request.setAttribute("unitMeasures", unitMeasureDAO.getAllUnitMeasures());
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
        
        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");
        String searchParam = request.getParameter("search");
        String unitIdParam = request.getParameter("unitId");
        String sortByParam = request.getParameter("sortBy");
        
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/ingredient?action=list");
        if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
        if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        if (unitIdParam != null && !unitIdParam.trim().isEmpty()) redirectUrl.append("&unitId=").append(java.net.URLEncoder.encode(unitIdParam, "UTF-8"));
        if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

        if (id != null && !id.trim().isEmpty()) {
            boolean success = ingredientDAO.deleteIngredient(id);
            if (success) {
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_success");
            } else {
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_error");
            }
        } else {
            response.sendRedirect(redirectUrl.toString());
        }
    }

    private void saveOrUpdateIngredient(HttpServletRequest request, HttpServletResponse response, boolean isNew) 
            throws ServletException, IOException {
        String id = request.getParameter("ingredientId");
        String name = request.getParameter("ingredientName");
        String priceParam = request.getParameter("pricePerUnit");
        String unitId = request.getParameter("unitMeasure");
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

        if (unitId == null || unitId.trim().isEmpty()) {
            unitId = "G";
        }

        if (isNew || id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = "ING-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        }

        Part filePart = null;
        String imageError = null;
        try {
            filePart = request.getPart("imageFile");
        } catch (Exception e) {
            imageError = "Kích thước tệp tin tải lên quá lớn (tối đa 5MB).";
        }

        if (imageError == null && filePart != null && filePart.getSize() > 0) {
            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                String extension = "";
                int dotIndex = submittedFileName.lastIndexOf('.');
                if (dotIndex > 0) {
                    extension = submittedFileName.substring(dotIndex).toLowerCase();
                }
                
                // Validate extension
                if (!".jpg".equals(extension) && !".jpeg".equals(extension) && !".png".equals(extension)) {
                    imageError = "Định dạng tệp ảnh không hợp lệ. Chỉ chấp nhận tệp đuôi .jpg, .jpeg, .png.";
                }
                // Validate size (5MB limit)
                else if (filePart.getSize() > 5 * 1024 * 1024) {
                    imageError = "Dung lượng ảnh vượt quá giới hạn cho phép (tối đa 5MB).";
                } else {
                    try {
                        String uploadPath = request.getServletContext().getRealPath("/assets/images/ingredients");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        
                        String newFileName = id.toLowerCase() + "_" + System.currentTimeMillis() + extension;
                        String filePath = uploadPath + File.separator + newFileName;
                        filePart.write(filePath);
                        imageUrl = "assets/images/ingredients/" + newFileName;
                    } catch (Exception e) {
                        imageError = "Lỗi khi lưu tệp ảnh lên máy chủ: " + e.getMessage();
                    }
                }
            }
        }

        if (!nameValid || !priceValid || imageError != null) {
            Ingredient ing = new Ingredient(id, name, price, unitId, imageUrl, true);
            request.setAttribute("ingredient", ing);
            request.setAttribute("unitMeasures", unitMeasureDAO.getAllUnitMeasures());
            
            String errorMsg = "Dữ liệu nhập vào không hợp lệ. Tên nguyên liệu tối thiểu 2 ký tự, đơn giá phải lớn hơn hoặc bằng 0.";
            if (imageError != null) {
                errorMsg = imageError;
            }
            request.setAttribute("error", errorMsg);
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
            return;
        }

        Ingredient ingredient = new Ingredient(id, name, price, unitId, imageUrl, true);
        boolean success = ingredientDAO.saveIngredient(ingredient);

        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");
        String searchParam = request.getParameter("search");
        String unitIdParam = request.getParameter("unitId");
        String sortByParam = request.getParameter("sortBy");
        
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/ingredient?action=list");
        if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
        if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        if (unitIdParam != null && !unitIdParam.trim().isEmpty()) redirectUrl.append("&unitId=").append(java.net.URLEncoder.encode(unitIdParam, "UTF-8"));
        if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

        if (success) {
            response.sendRedirect(redirectUrl.toString() + "&msg=" + (isNew ? "add_success" : "edit_success"));
        } else {
            request.setAttribute("ingredient", ingredient);
            request.setAttribute("unitMeasures", unitMeasureDAO.getAllUnitMeasures());
            request.setAttribute("error", "Lỗi hệ thống khi lưu nguyên liệu.");
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.getRequestDispatcher("/admin/ingredientDetail.jsp").forward(request, response);
        }
    }
}
