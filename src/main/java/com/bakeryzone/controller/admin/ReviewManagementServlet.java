package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.ReviewDAO;
import com.bakeryzone.model.Review;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReviewManagementServlet", urlPatterns = {"/reviews"})
public class ReviewManagementServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        // Đồng bộ đọc action an toàn cho cả GET và POST
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                showReviewList(request, response);
                break;
            case "detail":
                showReviewDetail(request, response);
                break;
            default:
                showReviewList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if ("updateStatus".equals(action)) {
            String reviewId = request.getParameter("reviewId");
            String status = request.getParameter("status"); 

            if (reviewId != null && status != null) {
                String exactStatus = status.trim();
                
                // Đồng bộ hóa chuỗi chữ hoa chữ thường an toàn với DB
                if (exactStatus.equalsIgnoreCase("Approved")) exactStatus = "Approved";
                if (exactStatus.equalsIgnoreCase("Featured")) exactStatus = "Featured";
                if (exactStatus.equalsIgnoreCase("Rejected")) exactStatus = "Rejected";

                boolean success = reviewDAO.updateModerationStatus(reviewId, exactStatus);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/reviews?action=list&msg=success");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/reviews?action=list&msg=fail");
            return;
        }
        
        // Nếu không khớp hành động post nào, đá về trang list mặc định
        response.sendRedirect(request.getContextPath() + "/reviews?action=list");
    }

    // 1. Logic xử lý hiển thị danh sách đánh giá kèm Tìm kiếm, Lọc, Phân trang
    private void showReviewList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }

        String starsStr = request.getParameter("stars");
        Integer stars = null;
        if (starsStr != null && !starsStr.isEmpty()) {
            try {
                stars = Integer.parseInt(starsStr);
            } catch (NumberFormatException e) {
                stars = null;
            }
        }

        String status = request.getParameter("status");
        if (status != null && status.isEmpty()) {
            status = null;
        }

        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        int totalReviews = reviewDAO.getTotalReviewsForAdmin(keyword, stars, status);
        int totalPages = (int) Math.ceil((double) totalReviews / PAGE_SIZE);
        if (totalPages == 0) {
            totalPages = 1;
        }

        List<Review> reviewList = reviewDAO.searchAndFilterReviewsForAdmin(keyword, stars, status, page, PAGE_SIZE);

        request.setAttribute("reviewList", reviewList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("keyword", keyword);
        request.setAttribute("stars", stars);
        request.setAttribute("status", status);

        request.getRequestDispatcher("/admin/reviewList.jsp").forward(request, response);
    }

    // 2. Logic xử lý hiển thị chi tiết 1 đánh giá
    private void showReviewDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String reviewId = request.getParameter("id");
        if (reviewId != null) {
            Review review = reviewDAO.getReviewByIdForAdmin(reviewId);
            if (review != null) {
                request.setAttribute("review", review);
                request.getRequestDispatcher("/admin/reviewDetail.jsp").forward(request, response);
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/reviews?action=list&msg=error");
    }

    @Override
    public String getServletInfo() {
        return "Review Management Controller";
    }
}