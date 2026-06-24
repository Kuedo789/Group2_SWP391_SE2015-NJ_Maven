package com.bakeryzone.controller.auth;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.dao.ReviewDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.Review;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class HomeServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Map<String, String>> homepageCategories = productDAO.getAllProductCategories();
        List<Product> bestSellerProducts = productDAO.getHomepageBestSellerProducts(4);
        List<Review> featuredReviews = reviewDAO.getFeaturedReviewsForHomePage();

        request.setAttribute("homepageCategories", homepageCategories);
        request.setAttribute("bestSellerProducts", bestSellerProducts);
        request.setAttribute("FEATURED_REVIEWS", featuredReviews);

        request.getRequestDispatcher("/common/home.jsp").forward(request, response);
    }
}
