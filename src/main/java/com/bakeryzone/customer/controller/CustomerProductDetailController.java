/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package com.bakeryzone.customer.controller;

/**
 *
 * @author Nguyễn Hùng
 */
import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "CustomerProductDetailController", urlPatterns = {"/product-detail"})
public class CustomerProductDetailController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");

        if (id == null || id.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        Product product = productDAO.getProductById(id);

        if (product == null) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        ProductSearchResult result = productDAO.getAllProductsAdmin(
                product.getCategoryName(),
                "Active",
                "",
                "newest",
                1,
                4
        );

        List<Product> relatedProducts = new ArrayList<>();

        for (Product p : result.list()) {
            if (!p.getId().equals(product.getId())) {
                relatedProducts.add(p);
            }
        }

        // Check purchase and review status
        jakarta.servlet.http.HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        boolean hasBought = false;
        boolean hasReviewed = false;
        com.bakeryzone.dao.ReviewDAO reviewDAO = new com.bakeryzone.dao.ReviewDAO();
        if (currentUser != null) {
            hasBought = reviewDAO.hasBoughtProduct(currentUser.getUserId(), product.getId());
            hasReviewed = reviewDAO.hasReviewed(currentUser.getUserId(), product.getId());
        }

        // Load reviews
        List<com.bakeryzone.model.Review> reviewsList = reviewDAO.getReviewsByProductId(product.getId());

        request.setAttribute("product", product);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("hasBought", hasBought);
        request.setAttribute("hasReviewed", hasReviewed);
        request.setAttribute("reviewsList", reviewsList);

        request.getRequestDispatcher("/customer/productDetail.jsp").forward(request, response);
    }
}
