package com.bakeryzone.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/blog")
public class BlogController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "detail":
                request.getRequestDispatcher("/customer/blogDetail.jsp").forward(request, response);
                break;
            case "list":
            default:
                request.getRequestDispatcher("/customer/blogList.jsp").forward(request, response);
                break;
        }
    }
}
