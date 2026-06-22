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

        com.google.gson.Gson gson = new com.google.gson.Gson();
        String contextPath = request.getContextPath();

        List<Map<String, Object>> productDtoList = new ArrayList<>();
        for (Product p : productList) {
            productDtoList.add(mapProductToDto(p, contextPath));
        }

        List<String> categoriesJsonList = new ArrayList<>();
        for (Map<String, String> c : categoryList) {
            categoriesJsonList.add(c.get("name"));
        }

        request.setAttribute("productsJson", gson.toJson(productDtoList));
        request.setAttribute("categoriesJson", gson.toJson(categoriesJsonList));

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

        String contextPath = request.getContextPath();
        com.google.gson.Gson gson = new com.google.gson.Gson();

        List<Map<String, Object>> relatedProductsDto = new ArrayList<>();

        for (Product p : result.list()) {
            if (!p.getId().equals(product.getId())) {
                relatedProductsDto.add(mapProductToDto(p, contextPath));
            }
        }

        // Check purchase and review status
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        boolean hasBought = false;
        boolean hasReviewed = false;
        String currentUserId = "";
        
        if (currentUser != null) {
            currentUserId = currentUser.getUserId();
            hasBought = reviewDAO.hasBoughtProduct(currentUser.getUserId(), product.getId());
            hasReviewed = reviewDAO.hasReviewed(currentUser.getUserId(), product.getId());
        }

        // Load reviews
        List<Review> reviewsList = reviewDAO.getReviewsByProductId(product.getId());
        List<Map<String, Object>> reviewsDtoList = new ArrayList<>();
        for (Review r : reviewsList) {
            Map<String, Object> rDto = new java.util.HashMap<>();
            rDto.put("reviewId", r.getReviewId());
            rDto.put("customCakeId", r.getCustomCakeId());
            rDto.put("customerId", r.getCustomerId());
            rDto.put("customerName", r.getCustomerName());
            rDto.put("ratingStars", r.getRatingStars());
            rDto.put("comment", r.getComment() != null ? r.getComment() : "");
            rDto.put("variationName", r.getVariationName() != null ? r.getVariationName() : "");
            rDto.put("greetingText", r.getGreetingText() != null ? r.getGreetingText() : "");
            reviewsDtoList.add(rDto);
        }

        // Images logic
        List<String> imageList = new ArrayList<>();
        if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty()) {
            imageList.add(product.getImageUrl());
        }
        if (product.getAdditionalImages() != null) {
            for (String img : product.getAdditionalImages()) {
                if (img != null && !img.trim().isEmpty() && !imageList.contains(img)) {
                    imageList.add(img);
                }
            }
        }
        if (imageList.isEmpty()) {
            imageList.add("assets/images/products/basic.png");
        }
        
        List<String> resolvedImages = new ArrayList<>();
        for (String img : imageList) {
            resolvedImages.add(resolveImageUrl(img, contextPath));
        }

        Map<String, Object> productDto = mapProductToDto(product, contextPath);
        productDto.put("image", resolvedImages.get(0)); // override image with first resolved image

        request.setAttribute("productJson", gson.toJson(productDto));
        request.setAttribute("imagesJson", gson.toJson(resolvedImages));
        request.setAttribute("relatedProductsJson", gson.toJson(relatedProductsDto));
        request.setAttribute("reviewsJson", gson.toJson(reviewsDtoList));
        
        request.setAttribute("hasBought", hasBought);
        request.setAttribute("hasReviewed", hasReviewed);
        request.setAttribute("currentUserId", currentUserId);

        request.getRequestDispatcher("/customer/productDetail.jsp").forward(request, response);
    }
    
    private Map<String, Object> mapProductToDto(Product p, String contextPath) {
        Map<String, Object> dto = new java.util.HashMap<>();
        dto.put("id", p.getId());
        dto.put("name", p.getName());
        dto.put("category", p.getCategoryName());
        dto.put("price", p.getBasePrice());
        dto.put("desc", p.getFullDescription() != null ? p.getFullDescription() : "");
        dto.put("image", resolveImageUrl(p.getImageUrl(), contextPath));
        dto.put("featured", p.isFeatured());
        return dto;
    }
    
    private String resolveImageUrl(String url, String contextPath) {
        if (url == null || url.trim().isEmpty()) {
            return contextPath + "/assets/images/products/basic.png";
        }
        if (url.startsWith("http")) {
            return url;
        }
        return contextPath + "/" + url;
    }
}
