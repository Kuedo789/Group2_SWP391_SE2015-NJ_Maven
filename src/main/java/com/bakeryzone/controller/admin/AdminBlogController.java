package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.BlogPostDAO;
import com.bakeryzone.model.BlogPost;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/admin/blog")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminBlogController extends HttpServlet {

    private final BlogPostDAO blogPostDAO = new BlogPostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "list":
            default:
                showBlogList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=list");
            return;
        }

        switch (action) {
            case "create":
                handleCreateBlog(request, response);
                break;
            case "update":
                handleEditBlog(request, response);
                break;
            case "delete":
                handleDeleteBlog(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/blog?action=list");
                break;
        }
    }

    private void showBlogList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("search");
        String category = request.getParameter("category");
        String status = request.getParameter("status");
        String sort = request.getParameter("sort");

        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        if (category != null && (category.trim().isEmpty() || category.equalsIgnoreCase("all"))) {
            category = null;
        }
        if (status != null && (status.trim().isEmpty() || status.equalsIgnoreCase("all"))) {
            status = null;
        }
        if (sort == null || sort.trim().isEmpty()) {
            sort = "date_desc";
        }

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

        int pageSize = 5;
        int totalRecords = blogPostDAO.getTotalBlogPostsCountAdmin(keyword, category, status);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<BlogPost> blogList = blogPostDAO.getBlogPostsPagedAdmin(keyword, category, status, sort, page, pageSize);
        List<String> categories = blogPostDAO.getAllCategories();

        request.setAttribute("blogList", blogList);
        request.setAttribute("categories", categories);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("search", keyword != null ? keyword : "");
        request.setAttribute("selectedCategory", category != null ? category : "all");
        request.setAttribute("selectedStatus", status != null ? status : "all");
        request.setAttribute("sort", sort);

        request.getRequestDispatcher("/admin/blogList.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BlogPost post = new BlogPost();
        List<String> categories = blogPostDAO.getAllCategories();
        
        request.setAttribute("post", post);
        request.setAttribute("categories", categories);
        request.setAttribute("formAction", "create");
        request.setAttribute("isEdit", false);
        
        request.getRequestDispatcher("/admin/blogDetail.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        BlogPost post = blogPostDAO.getBlogPostById(id);
        if (post == null) {
            request.getSession().setAttribute("errorMessage", "Không tìm thấy bài viết để chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=list");
            return;
        }

        List<String> categories = blogPostDAO.getAllCategories();
        
        request.setAttribute("post", post);
        request.setAttribute("categories", categories);
        request.setAttribute("formAction", "update");
        request.setAttribute("isEdit", true);
        
        request.getRequestDispatcher("/admin/blogDetail.jsp").forward(request, response);
    }

    private void handleCreateBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String authorId = (user != null) ? user.getUserId() : "ADMIN";

        String title = request.getParameter("title");
        String summary = request.getParameter("summary");
        String content = request.getParameter("content");
        String category = request.getParameter("category");
        String customCategory = request.getParameter("customCategory");
        String status = request.getParameter("status");

        if ("custom".equalsIgnoreCase(category) && customCategory != null && !customCategory.trim().isEmpty()) {
            category = customCategory.trim();
        }

        // Validate
        boolean isValid = true;
        String errorMsg = "";
        
        if (title == null || title.trim().length() < 5 || title.trim().length() > 200) {
            isValid = false;
            errorMsg = "Tiêu đề bài viết phải từ 5 đến 200 ký tự!";
        } else if (category == null || category.trim().length() < 2 || category.trim().length() > 50) {
            isValid = false;
            errorMsg = "Danh mục bài viết phải từ 2 đến 50 ký tự!";
        } else if (summary != null && summary.trim().length() > 500) {
            isValid = false;
            errorMsg = "Tóm tắt bài viết không được vượt quá 500 ký tự!";
        } else if (content == null || content.trim().length() < 10) {
            isValid = false;
            errorMsg = "Nội dung bài viết phải chứa tối thiểu 10 ký tự!";
        }

        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName != null && submittedFileName.contains(".")) {
                String ext = submittedFileName.substring(submittedFileName.lastIndexOf(".")).toLowerCase();
                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
                    isValid = false;
                    errorMsg = "Định dạng ảnh không hợp lệ! Chỉ nhận các định dạng JPG, JPEG, PNG, GIF hoặc WEBP.";
                }
            }
        }

        if (!isValid) {
            BlogPost post = new BlogPost("", title, summary, content, "", category, new Timestamp(System.currentTimeMillis()), authorId, status);
            request.setAttribute("post", post);
            request.setAttribute("error", errorMsg);
            request.setAttribute("categories", blogPostDAO.getAllCategories());
            request.setAttribute("formAction", "create");
            request.setAttribute("isEdit", false);
            request.getRequestDispatcher("/admin/blogDetail.jsp").forward(request, response);
            return;
        }

        // Xử lý upload ảnh đại diện
        String imageUrl = "";
        if (filePart != null && filePart.getSize() > 0) {
            imageUrl = saveBlogImage(filePart, request);
        }

        String postId = "BLOG_" + System.currentTimeMillis();
        BlogPost post = new BlogPost(
            postId,
            title.trim(),
            summary != null ? summary.trim() : "",
            content.trim(),
            imageUrl,
            category != null ? category.trim() : "Uncategorized",
            new Timestamp(System.currentTimeMillis()),
            authorId,
            status != null ? status : "Active"
        );

        boolean success = blogPostDAO.insertBlogPost(post);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=list&msg=add_success");
        } else {
            session.setAttribute("errorMessage", "Lỗi: Không thể lưu bài viết vào cơ sở dữ liệu!");
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=create");
        }
    }

    private void handleEditBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String postId = request.getParameter("postId");
        BlogPost post = blogPostDAO.getBlogPostById(postId);

        if (post == null) {
            session.setAttribute("errorMessage", "Không tìm thấy bài viết để cập nhật!");
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=list");
            return;
        }

        String title = request.getParameter("title");
        String summary = request.getParameter("summary");
        String content = request.getParameter("content");
        String category = request.getParameter("category");
        String customCategory = request.getParameter("customCategory");
        String status = request.getParameter("status");
        String currentImageUrl = request.getParameter("currentImageUrl");

        if ("custom".equalsIgnoreCase(category) && customCategory != null && !customCategory.trim().isEmpty()) {
            category = customCategory.trim();
        }

        // Validate
        boolean isValid = true;
        String errorMsg = "";
        
        if (title == null || title.trim().length() < 5 || title.trim().length() > 200) {
            isValid = false;
            errorMsg = "Tiêu đề bài viết phải từ 5 đến 200 ký tự!";
        } else if (category == null || category.trim().length() < 2 || category.trim().length() > 50) {
            isValid = false;
            errorMsg = "Danh mục bài viết phải từ 2 đến 50 ký tự!";
        } else if (summary != null && summary.trim().length() > 500) {
            isValid = false;
            errorMsg = "Tóm tắt bài viết không được vượt quá 500 ký tự!";
        } else if (content == null || content.trim().length() < 10) {
            isValid = false;
            errorMsg = "Nội dung bài viết phải chứa tối thiểu 10 ký tự!";
        }

        Part filePart = request.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String submittedFileName = filePart.getSubmittedFileName();
            if (submittedFileName != null && submittedFileName.contains(".")) {
                String ext = submittedFileName.substring(submittedFileName.lastIndexOf(".")).toLowerCase();
                if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".gif") && !ext.equals(".webp")) {
                    isValid = false;
                    errorMsg = "Định dạng ảnh không hợp lệ! Chỉ nhận các định dạng JPG, JPEG, PNG, GIF hoặc WEBP.";
                }
            }
        }

        if (!isValid) {
            post.setTitle(title);
            post.setSummary(summary);
            post.setContent(content);
            post.setCategory(category);
            post.setStatus(status);
            
            request.setAttribute("post", post);
            request.setAttribute("error", errorMsg);
            request.setAttribute("categories", blogPostDAO.getAllCategories());
            request.setAttribute("formAction", "update");
            request.setAttribute("isEdit", true);
            request.getRequestDispatcher("/admin/blogDetail.jsp").forward(request, response);
            return;
        }

        // Xử lý upload ảnh mới nếu có
        String imageUrl = currentImageUrl;
        if (filePart != null && filePart.getSize() > 0) {
            deletePhysicalImage(currentImageUrl, request);
            imageUrl = saveBlogImage(filePart, request);
        }

        post.setTitle(title.trim());
        post.setSummary(summary != null ? summary.trim() : "");
        post.setContent(content.trim());
        post.setCategory(category != null ? category.trim() : "Uncategorized");
        post.setImageUrl(imageUrl);
        post.setStatus(status != null ? status : "Active");

        boolean success = blogPostDAO.updateBlogPost(post);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=list&msg=edit_success");
        } else {
            session.setAttribute("errorMessage", "Lỗi: Không thể cập nhật bài viết!");
            response.sendRedirect(request.getContextPath() + "/admin/blog?action=edit&id=" + postId);
        }
    }

    private void handleDeleteBlog(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String id = request.getParameter("id");
        BlogPost post = blogPostDAO.getBlogPostById(id);

        if (post != null) {
            deletePhysicalImage(post.getImageUrl(), request);
            boolean success = blogPostDAO.deleteBlogPost(id);
            if (success) {
                // Do not set duplicate successMessage in session since we use msg=delete_success parameter
            } else {
                session.setAttribute("errorMessage", "Lỗi: Không thể xóa bài viết!");
            }
        } else {
            session.setAttribute("errorMessage", "Bài viết không tồn tại hoặc đã bị ẩn trước đó!");
        }
        response.sendRedirect(request.getContextPath() + "/admin/blog?action=list&msg=delete_success");
    }

    private String saveBlogImage(Part filePart, HttpServletRequest request) throws IOException {
        String baseUploadPath = com.bakeryzone.controller.ImageServlet.EXTERNAL_UPLOAD_DIR + File.separator + "blog";
        File uploadDir = new File(baseUploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String fileExtension = ".jpg";
        String submittedFileName = filePart.getSubmittedFileName();
        if (submittedFileName != null && submittedFileName.contains(".")) {
            fileExtension = submittedFileName.substring(submittedFileName.lastIndexOf("."));
        }
        String fileName = "blog_" + System.currentTimeMillis() + fileExtension;
        String filePath = baseUploadPath + File.separator + fileName;
        filePart.write(filePath);

        System.out.println("--> [BlogUpload] Saved blog thumbnail image to external persistent directory: " + filePath);

        return "uploads/blog/" + fileName;
    }

    private void deletePhysicalImage(String imageUrl, HttpServletRequest request) {
        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            try {
                String cleanPath = imageUrl.startsWith("/") ? imageUrl.substring(1) : imageUrl;
                String fileName = cleanPath.contains("/") ? cleanPath.substring(cleanPath.lastIndexOf("/") + 1) : cleanPath;
                String baseUploadPath = com.bakeryzone.controller.ImageServlet.EXTERNAL_UPLOAD_DIR + File.separator + "blog";
                File targetFile = new File(baseUploadPath, fileName);
                if (targetFile.exists()) {
                    targetFile.delete();
                    System.out.println("--> [BlogUpload] Deleted physical blog image: " + targetFile.getAbsolutePath());
                }
            } catch (Exception e) {
                System.err.println("--> [BlogUpload] Failed to delete physical blog image: " + e.getMessage());
            }
        }
    }
}
