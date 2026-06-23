package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.ProductDAO;
import com.bakeryzone.dao.ReviewDAO;
import com.bakeryzone.model.Product;
import com.bakeryzone.model.ProductSearchResult;
import com.bakeryzone.model.Review;
import com.bakeryzone.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CustomerProductController", urlPatterns = {"/products", "/product-detail"})
public class CustomerProductController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        String action = request.getParameter("action");

        if ("/product-detail".equals(path) || "detail".equals(action)) {
            handleDetail(request, response);
        } else {
            handleList(request, response);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        ProductSearchResult result = productDAO.getAllProductsAdmin(
                "",
                "Active",
                "",
                "newest",
                1,
                100
        );

        List<Product> productList = result.list();
        List<Map<String, String>> categoryList = productDAO.getAllProductCategories();

        request.setAttribute("productList", productList);
        request.setAttribute("categoryList", categoryList);

        request.getRequestDispatcher("/customer/productList.jsp").forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
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
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        boolean hasBought = false;
        boolean hasReviewed = false;
        
        if (currentUser != null) {
            String customerId = new com.bakeryzone.dao.OrderDAO().getCustomerIdByUserId(currentUser.getUserId());
            hasBought = reviewDAO.hasBoughtProduct(customerId, product.getId());
            hasReviewed = reviewDAO.hasReviewed(customerId, product.getId());
        }

        // Load reviews
        List<Review> reviewsList = reviewDAO.getReviewsByProductId(product.getId());

        request.setAttribute("product", product);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("hasBought", hasBought);
        request.setAttribute("hasReviewed", hasReviewed);
        request.setAttribute("reviewsList", reviewsList);

        request.getRequestDispatcher("/customer/productDetail.jsp").forward(request, response);
    }
}
