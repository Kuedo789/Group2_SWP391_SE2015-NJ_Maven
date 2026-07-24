package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.dao.IngredientDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.model.Ingredient;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;

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
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 5,       // 5 MB max file size
    maxRequestSize = 1024 * 1024 * 10    // 10 MB max request size
)
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
            case "bom":
                handleBomView(request, response);
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
            case "checkName":
                checkProductNameAjax(request, response);
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
            case "restore":
                restoreProduct(request, response);
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
        
        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");
        String categoryParam = request.getParameter("category");
        String statusFilterParam = request.getParameter("status");
        String searchParam = request.getParameter("search");
        String sortByParam = request.getParameter("sortBy");
        
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/product?action=list");
        if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
        if (categoryParam != null && !categoryParam.trim().isEmpty()) redirectUrl.append("&category=").append(java.net.URLEncoder.encode(categoryParam, "UTF-8"));
        if (statusFilterParam != null && !statusFilterParam.trim().isEmpty()) redirectUrl.append("&status=").append(java.net.URLEncoder.encode(statusFilterParam, "UTF-8"));
        if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

        if (id != null && !id.trim().isEmpty()) {
            System.out.println("[INFO] Bat dau xoa banh kem co ID: " + id);
            try {
                productDAO.deleteProduct(id);
                System.out.println("[SUCCESS] Xoa banh kem co ID: " + id + " thanh cong!");
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_success");
            } catch (Exception e) {
                System.err.println("[ERROR] Loi khi xoa banh kem co ID: " + id + ". Details: " + e.getMessage());
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_error");
            }
        } else {
            response.sendRedirect(redirectUrl.toString());
        }
    }

    private void restoreProduct(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        
        String pageParam = request.getParameter("page");
        String pageSizeParam = request.getParameter("pageSize");
        String categoryParam = request.getParameter("category");
        String statusFilterParam = request.getParameter("status");
        String searchParam = request.getParameter("search");
        String sortByParam = request.getParameter("sortBy");
        
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/product?action=list");
        if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
        if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
        if (categoryParam != null && !categoryParam.trim().isEmpty()) redirectUrl.append("&category=").append(java.net.URLEncoder.encode(categoryParam, "UTF-8"));
        if (statusFilterParam != null && !statusFilterParam.trim().isEmpty()) redirectUrl.append("&status=").append(java.net.URLEncoder.encode(statusFilterParam, "UTF-8"));
        if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

        if (id != null && !id.trim().isEmpty()) {
            System.out.println("[INFO] Bat dau khoi phuc banh kem co ID: " + id);
            try {
                productDAO.activateProduct(id);
                System.out.println("[SUCCESS] Khoi phuc banh kem co ID: " + id + " thanh cong!");
                response.sendRedirect(redirectUrl.toString() + "&msg=restore_success");
            } catch (Exception e) {
                System.err.println("[ERROR] Loi khi khoi phuc banh kem co ID: " + id + ". Details: " + e.getMessage());
                response.sendRedirect(redirectUrl.toString() + "&msg=restore_error");
            }
        } else {
            response.sendRedirect(redirectUrl.toString());
        }
    }

    private void saveOrUpdateProduct(HttpServletRequest request, HttpServletResponse response, boolean isNew) 
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String name = request.getParameter("name");
        if (name != null) {
            name = name.trim();
        }
        String categoryId = request.getParameter("categoryId");
        
        boolean isNewProductForced = false;
        String oldId = id;
        if (!isNew && id != null && !id.trim().isEmpty() && !"new".equalsIgnoreCase(id)) {
            String[] bomIngredientIds = request.getParameterValues("bomIngredientId");
            String[] bomStandardGrams = request.getParameterValues("bomStandardGram");
            
            if (productDAO.hasOrders(id) && isBomChanged(id, bomIngredientIds, bomStandardGrams)) {
                isNew = true;
                isNewProductForced = true;
            }
        }
        
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
        
        // File Upload Processing & Validation
        if (isNew || id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id)) {
            id = productDAO.getNextTemplateId();
        }

        String imageUrl = request.getParameter("imageUrl");
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
                        String uploadPath = request.getServletContext().getRealPath("/assets/images/products");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }
                        
                        String newFileName = id.toLowerCase() + "_" + System.currentTimeMillis() + extension;
                        String filePath = uploadPath + File.separator + newFileName;
                        filePart.write(filePath);
                        imageUrl = "assets/images/products/" + newFileName;
                    } catch (Exception e) {
                        imageError = "Lỗi khi lưu tệp ảnh lên máy chủ: " + e.getMessage();
                    }
                }
            }
        }

        // Process additional images (existing ones + new file uploads)
        List<String> additionalImageUrls = new ArrayList<>();
        String[] existingAdditionalUrls = request.getParameterValues("existingAdditionalImages");
        if (existingAdditionalUrls != null) {
            for (String url : existingAdditionalUrls) {
                if (url != null && !url.trim().isEmpty()) {
                    additionalImageUrls.add(url);
                }
            }
        }

        try {
            for (Part part : request.getParts()) {
                if ("additionalImageFiles".equals(part.getName()) && part.getSize() > 0) {
                    String submittedFileName = part.getSubmittedFileName();
                    if (submittedFileName != null && !submittedFileName.trim().isEmpty()) {
                        String extension = "";
                        int dotIndex = submittedFileName.lastIndexOf('.');
                        if (dotIndex > 0) {
                            extension = submittedFileName.substring(dotIndex).toLowerCase();
                        }
                        
                        if ((".jpg".equals(extension) || ".jpeg".equals(extension) || ".png".equals(extension)) 
                                && part.getSize() <= 5 * 1024 * 1024) {
                            try {
                                String uploadPath = request.getServletContext().getRealPath("/assets/images/products");
                                File uploadDir = new File(uploadPath);
                                if (!uploadDir.exists()) {
                                    uploadDir.mkdirs();
                                }
                                
                                String newFileName = id.toLowerCase() + "_add_" + System.nanoTime() + extension;
                                String filePath = uploadPath + File.separator + newFileName;
                                part.write(filePath);
                                additionalImageUrls.add("assets/images/products/" + newFileName);
                            } catch (Exception e) {
                                System.err.println("[ERROR] Failed to save additional image file: " + e.getMessage());
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[ERROR] Error reading additional image parts: " + e.getMessage());
        }

        boolean isDuplicateName = false;
        if (nameValid) {
            String checkId = (isNew || id == null || id.trim().isEmpty() || "new".equalsIgnoreCase(id.trim())) ? "new" : id;
            if (productDAO.isProductNameExists(name, checkId)) {
                isDuplicateName = true;
            }
        }

        if (!nameValid || isDuplicateName || !laborValid || !marginValid || !serviceValid || imageError != null) {
            Product product = new Product();
            product.setId(id);
            product.setName(name);
            product.setCategoryId(categoryId);
            product.setEstimatedLaborHours(estimatedLaborHours);
            product.setAllowsGreeting(request.getParameter("allowsGreeting") != null && "true".equalsIgnoreCase(request.getParameter("allowsGreeting")));
            product.setImageUrl(imageUrl);
            product.setStatus(request.getParameter("status"));
            product.setFullDescription(request.getParameter("fullDescription"));
            product.setDefaultMarginPercent(defaultMarginPercent);
            product.setDefaultServicePercent(defaultServicePercent);
            product.setInstructionSteps(request.getParameter("instructionSteps"));
            product.setAdditionalImages(additionalImageUrls);
            
            StringBuilder errorMsg = new StringBuilder("Dữ liệu nhập vào không hợp lệ: ");
            if (!nameValid) {
                errorMsg.append("Tên bánh phải từ 3 đến 100 ký tự. ");
            } else if (isDuplicateName) {
                errorMsg.append("Tên bánh kem này đã tồn tại trên hệ thống. Vui lòng chọn tên khác! ");
            }
            if (!laborValid) {
                errorMsg.append("Thời gian làm việc phải là số lớn hơn hoặc bằng 0. ");
            }
            if (!marginValid || !serviceValid) {
                errorMsg.append("Tỷ lệ biên lãi và phí dịch vụ phải hợp lệ, tổng cộng phải nhỏ hơn 100%. ");
            }
            if (imageError != null) {
                errorMsg.append(imageError);
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
        String status = request.getParameter("status");
        boolean isFeatured = request.getParameter("isFeatured") != null && "true".equalsIgnoreCase(request.getParameter("isFeatured"));
        String fullDescription = request.getParameter("fullDescription");
        String instructionSteps = request.getParameter("instructionSteps");
        
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
            // Save additional images
            productDAO.saveProductAdditionalImages(id, additionalImageUrls);
            
            // Process and save BOM (Bill of Materials) Ingredients
            String[] bomIngredientIds = request.getParameterValues("bomIngredientId");
            String[] bomStandardGrams = request.getParameterValues("bomStandardGram");
            productDAO.saveProductIngredients(id, bomIngredientIds, bomStandardGrams);
            
            String pageParam = request.getParameter("page");
            String pageSizeParam = request.getParameter("pageSize");
            String categoryParam = request.getParameter("category");
            String statusFilterParam = request.getParameter("statusFilter");
            String searchParam = request.getParameter("search");
            String sortByParam = request.getParameter("sortBy");
            
            StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/product?action=list");
            if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
            if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
            if (categoryParam != null && !categoryParam.trim().isEmpty()) redirectUrl.append("&category=").append(java.net.URLEncoder.encode(categoryParam, "UTF-8"));
            if (statusFilterParam != null && !statusFilterParam.trim().isEmpty()) redirectUrl.append("&status=").append(java.net.URLEncoder.encode(statusFilterParam, "UTF-8"));
            if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
            if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

            System.out.println("[SUCCESS] Luu banh kem thanh cong. ID: " + product.getId());
            if (isNewProductForced) {
                productDAO.deactivateProduct(oldId);
                response.sendRedirect(redirectUrl.toString() + "&msg=new_version_success");
            } else {
                response.sendRedirect(redirectUrl.toString() + "&msg=" + (isNew ? "add_success" : "edit_success"));
            }
        } else {
            String pageParam = request.getParameter("page");
            String pageSizeParam = request.getParameter("pageSize");
            String categoryParam = request.getParameter("category");
            String statusFilterParam = request.getParameter("statusFilter");
            String searchParam = request.getParameter("search");
            String sortByParam = request.getParameter("sortBy");
            
            StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/product?action=list");
            if (pageParam != null && !pageParam.trim().isEmpty()) redirectUrl.append("&page=").append(pageParam);
            if (pageSizeParam != null && !pageSizeParam.trim().isEmpty()) redirectUrl.append("&pageSize=").append(pageSizeParam);
            if (categoryParam != null && !categoryParam.trim().isEmpty()) redirectUrl.append("&category=").append(java.net.URLEncoder.encode(categoryParam, "UTF-8"));
            if (statusFilterParam != null && !statusFilterParam.trim().isEmpty()) redirectUrl.append("&status=").append(java.net.URLEncoder.encode(statusFilterParam, "UTF-8"));
            if (searchParam != null && !searchParam.trim().isEmpty()) redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
            if (sortByParam != null && !sortByParam.trim().isEmpty()) redirectUrl.append("&sortBy=").append(java.net.URLEncoder.encode(sortByParam, "UTF-8"));

            System.err.println("[ERROR] Luu banh kem that bai. ID: " + product.getId());
            response.sendRedirect(redirectUrl.toString() + "&msg=save_error");
        }
    }

    private boolean isBomChanged(String productId, String[] newIds, String[] newGrams) {
        List<Map<String, Object>> currentIngredients = productDAO.getProductIngredients(productId);
        
        List<String> validNewIds = new ArrayList<>();
        List<Double> validNewGrams = new ArrayList<>();
        if (newIds != null && newGrams != null) {
            for (int i = 0; i < newIds.length; i++) {
                if (newIds[i] != null && !newIds[i].trim().isEmpty()) {
                    validNewIds.add(newIds[i].trim());
                    double val = 0.0;
                    try {
                        val = Double.parseDouble(newGrams[i]);
                    } catch (Exception e) {}
                    validNewGrams.add(val);
                }
            }
        }
        
        if (currentIngredients.size() != validNewIds.size()) {
            return true;
        }
        
        java.util.HashMap<String, Double> currentMap = new java.util.HashMap<>();
        for (Map<String, Object> ing : currentIngredients) {
            currentMap.put((String) ing.get("ingredientId"), (Double) ing.get("standardGram"));
        }
        
        for (int i = 0; i < validNewIds.size(); i++) {
            String id = validNewIds.get(i);
            Double currentGram = currentMap.get(id);
            if (currentGram == null) {
                return true;
            }
            if (Math.abs(currentGram - validNewGrams.get(i)) > 0.0001) {
                return true;
            }
        }
        
        return false;
    }

    private void handleBomView(HttpServletRequest request, HttpServletResponse response) 
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
        
        List<Map<String, Object>> productIngredients = productDAO.getProductIngredients(id);
        
        // Calculate total BOM cost
        double bomCostTotal = 0.0;
        if (productIngredients != null) {
            for (Map<String, Object> item : productIngredients) {
                double gram = 0.0;
                double price = 0.0;
                try {
                    gram = Double.parseDouble(item.get("standardGram").toString());
                    price = Double.parseDouble(item.get("pricePerUnit").toString());
                } catch (Exception e) {}
                bomCostTotal += gram * price;
            }
        }

        request.setAttribute("product", product);
        request.setAttribute("productIngredients", productIngredients);
        request.setAttribute("bomCostTotal", bomCostTotal);
        
        request.getRequestDispatcher("/admin/productBomView.jsp").forward(request, response);
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

    private void checkProductNameAjax(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String name = request.getParameter("name");
        String id = request.getParameter("id");
        boolean exists = productDAO.isProductNameExists(name, id);
        response.getWriter().write("{\"exists\":" + exists + "}");
    }
}
