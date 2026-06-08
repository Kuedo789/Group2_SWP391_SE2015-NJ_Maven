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

        request.setAttribute("product", product);
        request.setAttribute("relatedProducts", relatedProducts);

        request.getRequestDispatcher("/customer/productDetail.jsp").forward(request, response);
    }
}
