package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.BlogPostDAO;
import com.bakeryzone.model.BlogPost;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/blog")
public class BlogController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final BlogPostDAO blogPostDAO = new BlogPostDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "detail":
                String id = request.getParameter("id");
                BlogPost blog = blogPostDAO.getBlogPostById(id);
                request.setAttribute("blog", blog);
                request.getRequestDispatcher("/customer/blogDetail.jsp").forward(request, response);
                break;
            case "list":
            default:
                String category = request.getParameter("category");
                List<BlogPost> blogList = blogPostDAO.getAllActiveBlogPosts(category);
                request.setAttribute("blogList", blogList);
                request.getRequestDispatcher("/customer/blogList.jsp").forward(request, response);
                break;
        }
    }
}
