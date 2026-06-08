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
import java.util.List;
import java.util.Map;

@WebServlet(name = "CustomerProductListController", urlPatterns = {"/products"})
public class CustomerProductListController extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
}