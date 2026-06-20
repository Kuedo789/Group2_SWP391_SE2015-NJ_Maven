package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.ReviewDAO;
import com.bakeryzone.model.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CustomerReviewServlet", urlPatterns = {"/review-api"})
public class CustomerReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        Map<String, Object> jsonResponse = new HashMap<>();

        if (currentUser == null) {
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Vui lòng đăng nhập để thực hiện thao tác.");
            response.getWriter().write(gson.toJson(jsonResponse));
            return;
        }

        String action = request.getParameter("action");
        String customerId = currentUser.getUserId();

        try {
            if ("create".equalsIgnoreCase(action)) {
                String productId = request.getParameter("productId");
                String ratingStr = request.getParameter("rating");
                String comment = request.getParameter("comment");
                String customCakeId = request.getParameter("customCakeId");

                int rating = 5;
                try {
                    rating = Integer.parseInt(ratingStr);
                } catch (NumberFormatException e) {
                    // default 5 stars
                }

                if (comment == null || comment.trim().isEmpty()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Nội dung đánh giá không được để trống.");
                    response.getWriter().write(gson.toJson(jsonResponse));
                    return;
                }

                // If customCakeId not provided, find the most recent completed custom cake purchase
                if (customCakeId == null || customCakeId.trim().isEmpty()) {
                    customCakeId = reviewDAO.getRecentCustomCakeId(customerId, productId);
                }

                if (customCakeId == null) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Bạn chưa mua sản phẩm này hoặc đơn hàng chưa hoàn thành.");
                    response.getWriter().write(gson.toJson(jsonResponse));
                    return;
                }

                // Generate a unique Review_ID
                String reviewId = "REV_" + System.currentTimeMillis();

                boolean success = reviewDAO.addReview(reviewId, customCakeId, customerId, rating, comment.trim());
                jsonResponse.put("success", success);
                if (success) {
                    jsonResponse.put("message", "Gửi đánh giá thành công!");
                } else {
                    jsonResponse.put("message", "Không thể lưu đánh giá vào hệ thống.");
                }

            } else if ("update".equalsIgnoreCase(action)) {
                String reviewId = request.getParameter("reviewId");
                String ratingStr = request.getParameter("rating");
                String comment = request.getParameter("comment");

                int rating = 5;
                try {
                    rating = Integer.parseInt(ratingStr);
                } catch (NumberFormatException e) {
                }

                if (comment == null || comment.trim().isEmpty()) {
                    jsonResponse.put("success", false);
                    jsonResponse.put("message", "Nội dung đánh giá không được để trống.");
                    response.getWriter().write(gson.toJson(jsonResponse));
                    return;
                }

                boolean success = reviewDAO.updateReview(reviewId, rating, comment.trim());
                jsonResponse.put("success", success);
                if (success) {
                    jsonResponse.put("message", "Cập nhật đánh giá thành công!");
                } else {
                    jsonResponse.put("message", "Không thể cập nhật đánh giá.");
                }

            } else if ("delete".equalsIgnoreCase(action)) {
                String reviewId = request.getParameter("reviewId");

                boolean success = reviewDAO.deleteReview(reviewId);
                jsonResponse.put("success", success);
                if (success) {
                    jsonResponse.put("message", "Đã xóa đánh giá thành công.");
                } else {
                    jsonResponse.put("message", "Không thể xóa đánh giá.");
                }
            } else {
                jsonResponse.put("success", false);
                jsonResponse.put("message", "Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.put("success", false);
            jsonResponse.put("message", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
        }

        response.getWriter().write(gson.toJson(jsonResponse));
    }
}
