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
import java.util.List;

/**
 *
 * @author Asus
 */
@WebServlet(name = "CustomerServlet", urlPatterns = {"/customer"})
public class CustomerServlet extends HttpServlet {

    private static final String LIST_VIEW = "/admin/customerList.jsp";
    private static final String DETAIL_VIEW = "/admin/customerDetail.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                showList(request, response);
                break;
            case "delete":
                handleDelete(request, response);
                break;
            case "add":
            case "edit":
                showDetailForm(request, response, action);
                break;
            default:
                redirectToDefault(request, response);
                break;
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        switch (action) {
            case "add":
                handleCreate(request, response);
                break;
            case "edit":
                handleUpdate(request, response);
                break;
            default:
                redirectToDefault(request, response);
                break;
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("searchKeyword");
        String status = request.getParameter("filterStatus");
        int pageIndex = getPageIndex(request);
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

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showDetailForm(HttpServletRequest request, HttpServletResponse response, String action)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (action.equals("edit") && id != null) {
            CustomerDAO dao = new CustomerDAO();
            Customer existingCustomer = dao.getCustomerById(id);
            request.setAttribute("CUSTOMER_DATA", existingCustomer);
        }
        request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Customer c = bindAndValidateCustomer(request, false);
        if (hasValidationError(request, response, c)) {
            return;
        }

        CustomerDAO dao = new CustomerDAO();
        HttpSession session = request.getSession();

        if (dao.insertCustomer(c)) {
            session.setAttribute("successMessage", "Thêm mới khách hàng thành công!");
        } else {
            session.setAttribute("errorMessage", "Thêm mới thất bại! Email hoặc dữ liệu không hợp lệ.");
        }
        redirectToDefault(request, response);
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Customer c = bindAndValidateCustomer(request, true);
        if (hasValidationError(request, response, c)) {
            return;
        }

        CustomerDAO dao = new CustomerDAO();
        HttpSession session = request.getSession();

        Customer oldCus = dao.getCustomerById(c.getCustomerId());
        String inputPassword = request.getParameter("password");
        if (inputPassword == null || inputPassword.trim().isEmpty()) {
            c.getUser().setPassword(oldCus.getUser().getPassword());
        } else {
            c.getUser().setPassword(inputPassword);
        }

        if (dao.updateCustomer(c)) {
            session.setAttribute("successMessage", "Cập nhật tài khoản khách hàng thành công!");
        } else {
            session.setAttribute("errorMessage", "Cập nhật thất bại do lỗi hệ thống database!");
        }
        redirectToDefault(request, response);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String deleteId = request.getParameter("id");
        CustomerDAO dao = new CustomerDAO();
        Customer cusToDelete = dao.getCustomerById(deleteId);
        String name = (cusToDelete != null) ? cusToDelete.getFullName() : "khách hàng";

        dao.deleteCustomer(deleteId);

        request.getSession().setAttribute("successMessage", "Xóa tài khoản " + name + " thành công!");
        redirectToDefault(request, response);
    }

    private Customer bindAndValidateCustomer(HttpServletRequest request, boolean isEdit) {
        Customer c = new Customer();
        User u = new User();

        u.setEmail(request.getParameter("email") != null ? request.getParameter("email").trim() : "");
        u.setAccountStatus(request.getParameter("accountStatus"));
        u.setVerified(true);
        u.setPassword(request.getParameter("password"));

        c.setFullName(request.getParameter("fullName"));
        c.setPhone(request.getParameter("phone"));
        c.setDefaultAddress(request.getParameter("defaultAddress"));
        c.setUser(u);

        if (isEdit) {
            c.setCustomerId(request.getParameter("customerId"));
        }
        return c;
    }

    private boolean hasValidationError(HttpServletRequest request, HttpServletResponse response, Customer c)
            throws ServletException, IOException {
        String errorMessage = null;
        boolean isEdit = c.getCustomerId() != null;
        CustomerDAO dao = new CustomerDAO();

        if (c.getFullName() == null || c.getFullName().trim().isEmpty()
                || c.getUser().getEmail() == null || c.getUser().getEmail().trim().isEmpty()
                || c.getPhone() == null || c.getPhone().trim().isEmpty()
                || c.getUser().getAccountStatus() == null || c.getUser().getAccountStatus().trim().isEmpty()
                || (!isEdit && (c.getUser().getPassword() == null || c.getUser().getPassword().trim().isEmpty()))) {
            errorMessage = "Vui lòng điền đầy đủ các trường thông tin";
        } else if (!c.getPhone().matches("^(0)[35789][0-9]{8}$")) {
            errorMessage = "Số điện thoại phải là 10 chữ số đầu Việt Nam.";
        } else if (!isEdit && c.getUser().getPassword().length() < 6) {
            errorMessage = "Mật khẩu thêm mới phải từ 6 ký tự trở lên";
        } else if (dao.checkEmailExist(c.getUser().getEmail(), isEdit ? c.getCustomerId() : null)) {
            errorMessage = "Địa chỉ Email này đã được đăng ký bởi một khách hàng khác";
        } else if (c.getDefaultAddress() != null) {
            String trimmedAddr = c.getDefaultAddress().trim();
            if (trimmedAddr.isEmpty()) {
                errorMessage = "Vui lòng nhập địa chỉ mặc định cho khách hàng!";
            } else if (trimmedAddr.length() > 100) {
                errorMessage = "Địa chỉ không được vượt quá 100 ký tự. Vui lòng rút gọn!";
            }
        }

        if (errorMessage != null) {
            request.setAttribute("ERROR_MSG", errorMessage);
            request.setAttribute("CUSTOMER_DATA", c);
            request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
            return true;
        }
        return false;
    }

    private int getPageIndex(HttpServletRequest request) {
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                return Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                return 1;
            }
        }
        return 1;
    }

    private void redirectToDefault(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect("customer?action=list");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
