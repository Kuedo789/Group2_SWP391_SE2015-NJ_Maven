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

@WebServlet(name = "ReviewManagementServlet", urlPatterns = {"/admin/reviews"})
public class ReviewManagementServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

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
                redirectToDefault(request, response);
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
                
                if (exactStatus.equalsIgnoreCase("Approved")) exactStatus = "Approved";
                if (exactStatus.equalsIgnoreCase("Featured")) exactStatus = "Featured";
                if (exactStatus.equalsIgnoreCase("Rejected")) exactStatus = "Rejected";

                boolean success = reviewDAO.updateModerationStatus(reviewId, exactStatus);
                if (success) {
                    redirectToDefault(request, response, "success");
                    return;
                }
            }
            redirectToDefault(request, response, "fail");
            return;
        }
        
        redirectToDefault(request, response);
    }

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
        redirectToDefault(request, response, "error");
    }

    // 🟢 THÊM: Hàm điều hướng mặc định không kèm thông báo
    private void redirectToDefault(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/reviews?action=list");
    }

    // 🟢 THÊM: Hàm điều hướng nạp kèm tham số thông báo (success, fail, error) cho Toastify nhận diện
    private void redirectToDefault(HttpServletRequest request, HttpServletResponse response, String msg)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/admin/reviews?action=list&msg=" + msg);
    }

    @Override
    public String getServletInfo() {
        return "Review Management Controller";
    }
}
