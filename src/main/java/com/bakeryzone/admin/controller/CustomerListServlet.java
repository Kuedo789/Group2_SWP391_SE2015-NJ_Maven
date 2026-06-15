/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 *
 * @author Asus
 */
@WebServlet(name = "CustomerListServlet", urlPatterns = {"/customerList"})
public class CustomerListServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet CustomerListServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerListServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String keyword = request.getParameter("searchKeyword");
            String status = request.getParameter("filterStatus");

            String pageParam = request.getParameter("page");
            int pageIndex = 1;
            if (pageParam != null && !pageParam.trim().isEmpty()) {
                pageIndex = Integer.parseInt(pageParam);
            }
            int pageSize = 5;

            if (keyword != null && keyword.trim().isEmpty()) {
                keyword = null;
            }
            if (status != null && status.trim().isEmpty()) {
                status = null;
            }

            CustomerDAO dao = new CustomerDAO();

            int totalRecords = dao.getTotalCustomers(keyword, status);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            if (totalPages == 0) {
                totalPages = 1;
            }

            List<Customer> customerList = dao.searchAndFilterCustomers(keyword, status, pageIndex, pageSize);

            request.setAttribute("CUSTOMERS", customerList);
            request.setAttribute("currentPage", pageIndex);
            request.setAttribute("endPage", totalPages);
            request.setAttribute("activeMenu", "customers");
            request.getRequestDispatcher("/admin/customerList.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customerList");
        }

    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
