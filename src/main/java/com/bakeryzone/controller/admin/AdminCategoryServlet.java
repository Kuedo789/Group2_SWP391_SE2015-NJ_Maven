/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.CategoryDAO;
import com.bakeryzone.model.CategoryDTO;
import com.bakeryzone.controller.ImageServlet;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Iterator;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.util.List;

/**
 *
 * @author thais
 */
@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
@MultipartConfig(
        fileSizeThreshold = 256 * 1024,
        maxFileSize = 3 * 1024 * 1024,
        maxRequestSize = 4 * 1024 * 1024
)
public class AdminCategoryServlet extends HttpServlet {

    private static final long MAX_ICON_SIZE = 2L * 1024 * 1024;
    private static final int MAX_ICON_DIMENSION = 2048;
    private static final int MAX_CATEGORY_NAME_LENGTH = 49;
    private static final Set<String> ALLOWED_ICON_EXTENSIONS =
            Set.of("png", "jpg", "jpeg", "gif");
    private static final Set<String> ALLOWED_ICON_MIME_TYPES =
            Set.of("image/png", "image/jpeg", "image/gif");

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
        } catch (IllegalStateException e) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/categories?error=icon_too_large");
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
        String name = trimToEmpty(request.getParameter("categoryName"));
        String description = request.getParameter("description");
        String type = request.getParameter("categoryType");

        // 1. Check ID Format Security (allowing both hyphens and underscores, as database uses underscores like CAT_CREAM)
        if (!id.matches("^CAT[\\-_][A-Z0-9\\-_]+$")) {
            redirectFormError(request, response, "invalid_id_format");
            return;
        }

        // 2. Check Category Name Length (Backend Defense)
        if (name.codePointCount(0, name.length()) > MAX_CATEGORY_NAME_LENGTH) {
            redirectFormError(request, response, "name_too_long");
            return;
        }

        // 3. Check Description Length (Backend Defense)
        if (description != null && description.length() > 255) {
            redirectFormError(request, response, "desc_too_long");
            return;
        }

        boolean isUpdate = "update".equals(formAction);
        CategoryDTO existingCategory = isUpdate ? dao.getCategoryById(id) : null;

        // Check duplicates before writing an uploaded file to disk.
        if (!isUpdate && dao.isCategoryIdExists(id)) {
            redirectFormError(request, response, "duplicate_id");
            return;
        }

        String previousIconUrl = existingCategory != null ? existingCategory.getIconUrl() : null;
        String iconUrl;
        String uploadedIconUrl = null;
        try {
            iconUrl = resolveIconUrl(request, type, previousIconUrl, isUpdate);
            if (iconUrl != null && iconUrl.startsWith("uploads/categories/")
                    && !iconUrl.equals(previousIconUrl)) {
                uploadedIconUrl = iconUrl;
            }
        } catch (IconValidationException e) {
            redirectFormError(request, response, e.getErrorCode());
            return;
        }

        CategoryDTO cat = new CategoryDTO(id, name, description, type, true, iconUrl);
        boolean success = isUpdate ? dao.updateCategory(cat) : dao.addCategory(cat);

        if (success) {
            if (isUpdate && previousIconUrl != null && !previousIconUrl.equals(iconUrl)) {
                deleteUploadedCategoryIcon(previousIconUrl);
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories?success=true");
        } else {
            if (uploadedIconUrl != null) {
                deleteUploadedCategoryIcon(uploadedIconUrl);
            }
            response.sendRedirect(request.getContextPath() + "/admin/categories?error=db_error");
        }
    }

    private String resolveIconUrl(HttpServletRequest request, String categoryType,
            String previousIconUrl, boolean isUpdate)
            throws IOException, ServletException, IconValidationException {

        if ("Nguyên liệu".equalsIgnoreCase(categoryType)) {
            return null;
        }

        String iconMode = trimToEmpty(request.getParameter("iconMode"));
        String requestedUrl = trimToEmpty(request.getParameter("iconUrl"));
        Part iconFile = request.getPart("iconFile");

        if ("upload".equalsIgnoreCase(iconMode)) {
            if (iconFile != null && iconFile.getSize() > 0) {
                return saveUploadedCategoryIcon(iconFile);
            }
            return isUpdate ? previousIconUrl : null;
        }

        if (requestedUrl.isEmpty()) {
            return null;
        }
        // Preserve legacy values when the administrator edits another field.
        if (isUpdate && requestedUrl.equals(previousIconUrl)) {
            return previousIconUrl;
        }
        if (!isValidIconUrl(requestedUrl)) {
            throw new IconValidationException("invalid_icon_url");
        }
        return requestedUrl;
    }

    private String saveUploadedCategoryIcon(Part iconFile)
            throws IOException, IconValidationException {

        if (iconFile.getSize() > MAX_ICON_SIZE) {
            throw new IconValidationException("icon_too_large");
        }

        String submittedName = iconFile.getSubmittedFileName();
        String extension = getExtension(submittedName);
        String mimeType = iconFile.getContentType() == null
                ? "" : iconFile.getContentType().toLowerCase(Locale.ROOT);
        if (!ALLOWED_ICON_EXTENSIONS.contains(extension)
                || !ALLOWED_ICON_MIME_TYPES.contains(mimeType)) {
            throw new IconValidationException("invalid_icon_type");
        }

        validateImageContent(iconFile, extension);

        File uploadDirectory = new File(
                ImageServlet.EXTERNAL_UPLOAD_DIR + File.separator + "categories");
        if (!uploadDirectory.exists() && !uploadDirectory.mkdirs()) {
            throw new IOException("Could not create category icon upload directory");
        }

        String storedFileName = "category_" + UUID.randomUUID() + "." + extension;
        File targetFile = new File(uploadDirectory, storedFileName);
        try (InputStream input = iconFile.getInputStream()) {
            Files.copy(input, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
        return "uploads/categories/" + storedFileName;
    }

    private void validateImageContent(Part iconFile, String extension)
            throws IOException, IconValidationException {

        try (InputStream input = iconFile.getInputStream();
                ImageInputStream imageInput = ImageIO.createImageInputStream(input)) {
            if (imageInput == null) {
                throw new IconValidationException("invalid_icon_type");
            }

            Iterator<ImageReader> readers = ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) {
                throw new IconValidationException("invalid_icon_type");
            }

            ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                String detectedFormat = reader.getFormatName().toLowerCase(Locale.ROOT);
                boolean formatMatches = (detectedFormat.equals("png")
                            && extension.equals("png"))
                        || (detectedFormat.equals("gif") && extension.equals("gif"))
                        || (detectedFormat.equals("jpeg")
                            && (extension.equals("jpg") || extension.equals("jpeg")));
                if (!formatMatches || width < 1 || height < 1
                        || width > MAX_ICON_DIMENSION || height > MAX_ICON_DIMENSION) {
                    throw new IconValidationException(
                            width > MAX_ICON_DIMENSION || height > MAX_ICON_DIMENSION
                                    ? "icon_dimensions_too_large"
                                    : "invalid_icon_type");
                }
            } finally {
                reader.dispose();
            }
        }
    }

    private boolean isValidIconUrl(String iconUrl) {
        if (iconUrl.length() > 255 || iconUrl.contains("..")
                || iconUrl.contains("\r") || iconUrl.contains("\n")) {
            return false;
        }

        try {
            URI uri = URI.create(iconUrl);
            if (uri.isAbsolute()) {
                if (!"http".equals(uri.getScheme()) && !"https".equals(uri.getScheme())
                        || uri.getHost() == null) {
                    return false;
                }
                return true; // Bỏ qua check đuôi file với ảnh ngoài mạng
            } else if (!iconUrl.matches(
                    "^/?(?:assets/images|uploads)/[A-Za-z0-9._/-]+$")) {
                return false;
            }

            String path = uri.getPath() == null ? "" : uri.getPath().toLowerCase(Locale.ROOT);
            return path.matches("^.*\\.(png|jpe?g|gif|webp)$");
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private void deleteUploadedCategoryIcon(String iconUrl) {
        if (iconUrl == null || !iconUrl.startsWith("uploads/categories/")) {
            return;
        }

        String fileName = iconUrl.substring("uploads/categories/".length());
        if (fileName.contains("/") || fileName.contains("\\") || fileName.contains("..")) {
            return;
        }

        try {
            Files.deleteIfExists(new File(
                    ImageServlet.EXTERNAL_UPLOAD_DIR + File.separator
                    + "categories", fileName).toPath());
        } catch (IOException e) {
            System.err.println("[CategoryIcon] Could not remove old icon: " + e.getMessage());
        }
    }

    private String getExtension(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 && dot < fileName.length() - 1
                ? fileName.substring(dot + 1).toLowerCase(Locale.ROOT)
                : "";
    }

    private String trimToEmpty(String value) {
        return value == null ? "" : value.trim();
    }

    private void redirectFormError(HttpServletRequest request,
            HttpServletResponse response, String errorCode) throws IOException {
        String formAction = request.getParameter("formAction");
        String categoryId = trimToEmpty(request.getParameter("categoryId"));
        String target = request.getContextPath() + "/admin/categories?action="
                + ("update".equals(formAction) ? "edit&id="
                    + java.net.URLEncoder.encode(categoryId,
                            java.nio.charset.StandardCharsets.UTF_8) : "add")
                + "&error=" + errorCode;
        response.sendRedirect(target);
    }

    private static class IconValidationException extends Exception {
        private final String errorCode;

        IconValidationException(String errorCode) {
            this.errorCode = errorCode;
        }

        String getErrorCode() {
            return errorCode;
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
