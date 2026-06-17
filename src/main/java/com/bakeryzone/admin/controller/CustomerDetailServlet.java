/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

/**
 *
 * @author Asus
 */
@WebServlet(name = "CustomerDetailServlet", urlPatterns = {"/customerDetail"})
public class CustomerDetailServlet extends HttpServlet {

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
            out.println("<title>Servlet CustomerDetailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet CustomerDetailServlet at " + request.getContextPath() + "</h1>");
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
            String action = request.getParameter("action");
            String id = request.getParameter("id");

            CustomerDAO dao = new CustomerDAO();

            if (action != null && action.equals("delete")) {
                Customer cus = dao.getCustomerById(id);
                String name = (cus != null) ? cus.getFullName() : "khách hàng";

                dao.deleteCustomer(id);

                request.getSession().setAttribute("successMessage", "xóa tài khoản " + name + " thành công!");
                response.sendRedirect("customerList");
                return;
            }

            if (action != null && action.equals("edit")) {
                Customer existingCustomer = dao.getCustomerById(id);
                request.setAttribute("CUSTOMER_DATA", existingCustomer);
            }

            request.getRequestDispatcher("/admin/customerDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customerList");
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
        try {
            request.setCharacterEncoding("UTF-8");

            String action = request.getParameter("action");
            String customerId = request.getParameter("customerId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            if (email != null) {
                email = email.trim();
            }
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String defaultAddress = request.getParameter("defaultAddress");
            String accountStatus = request.getParameter("accountStatus");

            CustomerDAO dao = new CustomerDAO();

            User u = new User();
            u.setEmail(email);
            u.setAccountStatus(accountStatus);
            u.setVerified(true);

            Customer c = new Customer();
            c.setFullName(fullName);
            c.setPhone(phone);
            c.setDefaultAddress(defaultAddress);
            c.setUser(u);

            boolean isEdit = action != null && action.equals("edit");
            if (isEdit) {
                c.setCustomerId(customerId);
            }

            String errorMessage = null;

            if (fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || accountStatus == null || accountStatus.trim().isEmpty()
                    || (!isEdit && (password == null || password.trim().isEmpty()))) {
                errorMessage = "Vui lòng điền đầy đủ các trường thông tin";
            } else if (!phone.matches("^(0)[35789][0-9]{8}$")) {
                errorMessage = "Số điện thoại phải là 10 chữ số đầu Việt Nam.";
            } else if (!isEdit && password.length() < 6) {
                errorMessage = "Mật khẩu thêm mới phải từ 6 ký tự trở lên";
            } else if (dao.checkEmailExist(email, isEdit ? customerId : null)) {
                errorMessage = "Địa chỉ Email này đã được đăng ký bởi một khách hàng khác";
            } else if (defaultAddress != null) {
                String trimmedAddr = defaultAddress.trim();
                if (trimmedAddr.isEmpty()) {
                    errorMessage = "Vui lòng nhập địa chỉ mặc định cho khách hàng!";
                } else if (trimmedAddr.length() > 100) {
                    errorMessage = "Địa chỉ không được vượt quá 100 ký tự. Vui lòng rút gọn!";
                }
            }

            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("CUSTOMER_DATA", c);
                request.getRequestDispatcher("/admin/customerDetail.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();

            if (isEdit) {
                Customer oldCus = dao.getCustomerById(customerId);

                if (password == null || password.trim().isEmpty()) {
                    c.getUser().setPassword(oldCus.getUser().getPassword());
                } else {
                    c.getUser().setPassword(password);
                }

                boolean isUpdated = dao.updateCustomer(c);
                if (isUpdated) {
                    session.setAttribute("successMessage", "Cập nhật tài khoản khách hàng thành công!");
                } else {
                    session.setAttribute("errorMessage", "Cập nhật thất bại do lỗi hệ thống database!");
                }
            } else {
                c.getUser().setPassword(password);

                boolean isInserted = dao.insertCustomer(c);
                if (isInserted) {
                    session.setAttribute("successMessage", "Thêm mới khách hàng thành công!");
                } else {
                    session.setAttribute("errorMessage", "Thêm mới thất bại! Email hoặc dữ liệu không hợp lệ.");
                }
            }
            response.sendRedirect("customerList");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customerList");

        }
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
