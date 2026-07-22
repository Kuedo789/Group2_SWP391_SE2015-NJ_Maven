/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.controller.admin;

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
@WebServlet(name = "CustomerServlet", urlPatterns = {"/admin/customer"})
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
        /*
        List<Customer> filteredList = new java.util.ArrayList<>();
        for (int i = 0; i < customerList.size(); i++) {
            int stt = (pageIndex - 1) * pageSize + (i + 1);
            if (stt % 2 != 0) { 
                filteredList.add(customerList.get(i));
            }
        }
        customerList = filteredList;
*/
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

        String email = request.getParameter("email");
        u.setEmail(email != null ? email.trim() : "");

        String accountStatus = request.getParameter("accountStatus");
        u.setAccountStatus(accountStatus != null ? accountStatus.trim() : "");

        u.setVerified(true);

        String password = request.getParameter("password");
        if (password == null || password.trim().isEmpty()) {
            password = "123456"; // Mật khẩu mặc định khi tạo mới
        }
        u.setPassword(password);

        String fullName = request.getParameter("fullName");
        c.setFullName(fullName != null ? fullName.trim() : "");

        String phone = request.getParameter("phone");
        c.setPhone(phone != null ? phone.trim() : "");

        String defaultAddress = request.getParameter("defaultAddress");
        c.setDefaultAddress(defaultAddress != null ? defaultAddress.trim() : "");

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

        if (c.getFullName() == null || c.getFullName().isEmpty()) {
            errorMessage = "Vui lòng nhập họ và tên khách hàng!";
        } else if (c.getPhone() == null || c.getPhone().isEmpty()) {
            errorMessage = "Vui lòng nhập số điện thoại liên lạc!";
        } else if (!c.getPhone().matches("^(0)[35789][0-9]{8}$")) {
            errorMessage = "Số điện thoại không hợp lệ! Phải gồm 10 chữ số (bắt đầu bằng đầu số VN: 03, 05, 07, 08, 09).";
        } else if (c.getUser().getEmail() == null || c.getUser().getEmail().isEmpty()) {
            errorMessage = "Vui lòng nhập địa chỉ Email!";
        } else if (c.getUser().getAccountStatus() == null || c.getUser().getAccountStatus().isEmpty()) {
            errorMessage = "Vui lòng chọn trạng thái tài khoản!";
        } else if (dao.checkEmailExist(c.getUser().getEmail(), isEdit ? c.getCustomerId() : null)) {
            errorMessage = "Địa chỉ Email này đã được đăng ký bởi một khách hàng khác!";
        } else if (c.getDefaultAddress() != null && c.getDefaultAddress().length() > 100) {
            errorMessage = "Địa chỉ không được vượt quá 100 ký tự. Vui lòng rút gọn!";
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
        response.sendRedirect(request.getContextPath() + "/admin/customer?action=list");
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
