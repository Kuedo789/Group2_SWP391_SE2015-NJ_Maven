/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Set;

/**
 *
 * @author Asus
 */
@WebServlet(name = "UserDetailServlet", urlPatterns = {"/userDetail"})
public class UserDetailServlet extends HttpServlet {

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
            out.println("<title>Servlet UserDetailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet UserDetailServlet at " + request.getContextPath() + "</h1>");
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

            UserDAO dao = new UserDAO();

            if (action != null && action.equals("delete")) {
                User userToDelete = dao.getUserById(id);
                String name = (userToDelete != null) ? userToDelete.getFullName() : "người dùng";
                dao.deleteUser(id);
                request.getSession().setAttribute("successMessage", "Đã xóa tài khoản của " + name + " khỏi hệ thống!");
                response.sendRedirect("userList");
                return;
            }

            if (action != null && action.equals("edit")) {
                User existingUser = dao.getUserById(id);
                request.setAttribute("USER_DATA", existingUser);
            }
            request.getRequestDispatcher("admin/userDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
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

            String action = request.getParameter("action");
            String userId = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String roleId = request.getParameter("roleId");
            String accountStatus = request.getParameter("accountStatus");
            System.out.println(">>> Trạng thái nhận được từ giao diện gửi lên: " + accountStatus);
            UserDAO dao = new UserDAO();

            User u = new User();
            
            u.setFullName(fullName);
            u.setEmail(email);
            u.setPassword(password);
            u.setPhone(phone);
            u.setRoleId(roleId);
            u.setAccountStatus(accountStatus);

            String errorMessage = null;

            if (fullName.isEmpty() || email.isEmpty() || phone.isEmpty() || (action == null && password.isEmpty())) {
                errorMessage = "Vui lòng điền đầy đủ các trường thông tin";
            } else if (!phone.matches("^(0)[3|5|7|9][0-9]{8}$")) {
                errorMessage = "Số điện thoại phải là 10 chữ số";
            } else if ((action != null || !action.equals("edit")) && password.length() < 6) {
                errorMessage = "Mật khẩu phải từ 6 kí tự trở lên";
            } else if (dao.checkEmailExist(email, action != null && action.equals("edit") ? userId : null)) {
                errorMessage = "Địa chỉ Email này đã được đăng kí bởi một tài khoản khác";
            }
            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("USER_DATA", u);
                request.getRequestDispatcher("admin/userDetail.jsp").forward(request, response);
                return;
            }

            String hashedPassword = com.bakeryzone.utils.PasswordUtils.hashPassword(password);
            u.setPassword(hashedPassword);

            jakarta.servlet.http.HttpSession session = request.getSession();

            if (action != null && action.equals("edit")) {
                u.setUserId(userId);
                dao.updateUser(u);
                session.setAttribute("successMessage", "Cập nhật tài khoản của " + fullName + " thành công!");
            } else {
                String generatedId = "USR" + (System.currentTimeMillis() % 100000);
                u.setUserId(generatedId);
                dao.insertUser(u);
                session.setAttribute("successMessage", "Thêm mới tài khoản " + fullName + " thành công!");
            }
            response.sendRedirect("userList");
        } catch (Exception e) {
            e.printStackTrace();
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
