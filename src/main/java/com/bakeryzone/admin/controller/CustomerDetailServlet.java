/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.CustomerDAO;
import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.Customer;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.PasswordUtils;
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
            String id = request.getParameter("id"); // Customer_ID dạng String

            CustomerDAO dao = new CustomerDAO();
            UserDAO userDAO = new UserDAO();

            // LOGIC XỬ LÝ XÓA MỀM KHÁCH HÀNG
            if (action != null && action.equals("delete")) {
                Customer cus = dao.getCustomerById(id);
                String name = (cus != null) ? cus.getFullName() : "khách hàng";

                dao.deleteCustomer(id); // Gọi hàm xóa mềm tài khoản khách hàng

                request.getSession().setAttribute("successMessage", "Đã xóa tài khoản của " + name + " thành công!");
                response.sendRedirect("customerList");
                return;
            }

            // LOGIC BỐC DỮ LIỆU CŨ ĐỂ ĐỔ LÊN FORM SỬA
            if (action != null && action.equals("edit")) {
                Customer existingCustomer = dao.getCustomerById(id);

                if (existingCustomer != null) {
                    User existingUser = userDAO.getUserById(existingCustomer.getUserId());

                    if (existingUser != null) {
                        request.setAttribute("FORM_EMAIL", existingUser.getEmail());
                        request.setAttribute("FORM_STATUS", existingUser.getAccountStatus());
                    }
                }

                request.setAttribute("CUSTOMER_DATA", existingCustomer);
            }

            request.getRequestDispatcher("admin/customerDetail.jsp").forward(request, response);

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
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String accountStatus = request.getParameter("accountStatus");
            String defaultAddress = request.getParameter("defaultAddress");

            CustomerDAO dao = new CustomerDAO();
            UserDAO userDAO = new UserDAO();

            Customer c = new Customer();
            c.setCustomerId(customerId);
            c.setFullName(fullName);
            c.setPhone(phone);
            c.setDefaultAddress(defaultAddress);

            String errorMessage = null;
            boolean isEdit = action != null && action.equals("edit");

            // VALIDATE ĐẦU VÀO BACKEND
            if (fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || accountStatus == null || accountStatus.trim().isEmpty()
                    || (!isEdit && (password == null || password.trim().isEmpty()))) {
                errorMessage = "Vui lòng điền đầy đủ các trường thông tin";
            } else if (!phone.matches("^(0)[35789][0-9]{8}$")) {
                errorMessage = "Số điện thoại phải là 10 chữ số đầu VN";
            } else if (!isEdit && password.length() < 6) {
                errorMessage = "Mật khẩu thêm mới phải từ 6 kí tự trở lên";
            } else if (dao.checkEmailExist(email, isEdit ? customerId : null)) {
                errorMessage = "Địa chỉ Email này đã được đăng kí bởi một khách hàng khác";
            }

            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("CUSTOMER_DATA", c);
                request.setAttribute("FORM_EMAIL", email);
                request.setAttribute("FORM_STATUS", accountStatus);
                request.getRequestDispatcher("admin/customerDetail.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();

            if (isEdit) {
                Customer oldCus = dao.getCustomerById(customerId);

                if (oldCus == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy khách hàng cần cập nhật!");
                    response.sendRedirect("customerList");
                    return;
                }

                User oldUser = userDAO.getUserById(oldCus.getUserId());

                if (oldUser == null) {
                    session.setAttribute("errorMessage", "Không tìm thấy tài khoản của khách hàng!");
                    response.sendRedirect("customerList");
                    return;
                }

                String finalPassword;

                if (password == null || password.trim().isEmpty()) {
                    finalPassword = oldUser.getPassword();
                } else {
                    finalPassword = PasswordUtils.hashPassword(password);

                    if (finalPassword == null) {
                        request.setAttribute("ERROR_MSG", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
                        request.setAttribute("CUSTOMER_DATA", c);
                        request.setAttribute("FORM_EMAIL", email);
                        request.setAttribute("FORM_STATUS", accountStatus);
                        request.getRequestDispatcher("admin/customerDetail.jsp").forward(request, response);
                        return;
                    }
                }

                User u = new User();
                u.setUserId(oldCus.getUserId());
                u.setEmail(email.trim().toLowerCase());
                u.setPassword(finalPassword);
                u.setRoleId("CUS");
                u.setVerified(true);
                u.setAccountStatus(accountStatus);
                u.setFullName(fullName);
                u.setPhone(phone);
                u.setDefaultAddress(defaultAddress);

                userDAO.updateUser(u);

                session.setAttribute("successMessage", "Cập nhật tài khoản khách hàng thành công!");
            } else {
                String hashedPassword = PasswordUtils.hashPassword(password);

                if (hashedPassword == null) {
                    request.setAttribute("ERROR_MSG", "Không thể xử lý mật khẩu. Vui lòng thử lại.");
                    request.setAttribute("CUSTOMER_DATA", c);
                    request.setAttribute("FORM_EMAIL", email);
                    request.setAttribute("FORM_STATUS", accountStatus);
                    request.getRequestDispatcher("admin/customerDetail.jsp").forward(request, response);
                    return;
                }

                User u = new User();
                u.setFullName(fullName);
                u.setEmail(email.trim().toLowerCase());
                u.setPassword(hashedPassword);
                u.setPhone(phone);
                u.setDefaultAddress(defaultAddress);
                u.setRoleId("CUS");
                u.setVerified(true);
                u.setAccountStatus(accountStatus);

                userDAO.insertUser(u);
                System.out.println("Đã insert thành công vào Database!");

                session.setAttribute("successMessage", "Thêm mới khách hàng thành công!");
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
