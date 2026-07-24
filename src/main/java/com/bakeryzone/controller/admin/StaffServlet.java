/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.StaffDAO;
import com.bakeryzone.model.Staff;
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
@WebServlet(name = "StaffServlet", urlPatterns = {"/admin/staff"})
public class StaffServlet extends HttpServlet {

    private static final String LIST_VIEW = "/admin/userList.jsp";
    private static final String DETAIL_VIEW = "/admin/userDetail.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
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
        } catch (Exception e) {
            e.printStackTrace();
            redirectToDefault(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
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
        } catch (Exception e) {
            e.printStackTrace();
            redirectToDefault(request, response);
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("searchKeyword");
        String roleId = request.getParameter("filterRoleId");
        String status = request.getParameter("filterStatus");

        int pageIndex = getPageIndex(request);
        int pageSize = 5;

        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        if (roleId != null && roleId.trim().isEmpty()) {
            roleId = null;
        }
        if (status != null && status.trim().isEmpty()) {
            status = null;
        }

        StaffDAO dao = new StaffDAO();
        int totalRecords = dao.getTotalStaffs(keyword, roleId, status);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages == 0) {
            totalPages = 1;
        }

        List<Staff> staffList = dao.searchAndFilterStaffs(keyword, roleId, status, pageIndex, pageSize);
 
        request.setAttribute("USERS", staffList); 
        request.setAttribute("currentPage", pageIndex);
        request.setAttribute("endPage", totalPages);

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showDetailForm(HttpServletRequest request, HttpServletResponse response, String action)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        if (action.equals("edit") && id != null) {
            StaffDAO dao = new StaffDAO();
            Staff existingStaff = dao.getStaffById(id);
            request.setAttribute("USER_DATA", existingStaff); 
        }
        request.getRequestDispatcher(DETAIL_VIEW).forward(request, response);
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Staff s = bindAndMapStaff(request, false);
        if (hasValidationError(request, response, s)) {
            return;
        }

        StaffDAO dao = new StaffDAO();
        HttpSession session = request.getSession();

        if (s.getUser().getUserId() == null || s.getUser().getUserId().trim().isEmpty()) {
            s.getUser().setUserId(com.bakeryzone.utils.IDGenerator.generateUserId(s.getUser().getRoleId()));
        }
        if (s.getStaffId() == null || s.getStaffId().trim().isEmpty()) {
            s.setStaffId(com.bakeryzone.utils.IDGenerator.generateStaffId());
        }

        if (dao.insertStaff(s)) {
            session.setAttribute("successMessage", "Thêm mới tài khoản " + s.getFullName() + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Thêm mới nhân viên thất bại!");
        }
        redirectToDefault(request, response);
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Staff s = bindAndMapStaff(request, true);
        if (hasValidationError(request, response, s)) {
            return;
        }

        StaffDAO dao = new StaffDAO();
        HttpSession session = request.getSession();

        Staff oldStaff = dao.getStaffById(s.getStaffId());
        s.setIsActiveStaff(oldStaff.isIsActiveStaff());

        String inputPassword = request.getParameter("password");
        if (inputPassword == null || inputPassword.trim().isEmpty()) {
            s.getUser().setPassword(oldStaff.getUser().getPassword());
        } else {
            s.getUser().setPassword(inputPassword);
        }

        if (dao.updateStaff(s)) {
            session.setAttribute("successMessage", "Cập nhật tài khoản của " + s.getFullName() + " thành công!");
        } else {
            session.setAttribute("errorMessage", "Cập nhật tài khoản nhân viên thất bại!");
        }
        redirectToDefault(request, response);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String deleteId = request.getParameter("id");
        StaffDAO dao = new StaffDAO();
        Staff staffToDelete = dao.getStaffById(deleteId);
        String name = (staffToDelete != null) ? staffToDelete.getFullName() : "nhân viên";

        dao.deleteStaff(deleteId);

        request.getSession().setAttribute("successMessage", "Đã xóa tài khoản của " + name + " khỏi hệ thống!");
        redirectToDefault(request, response);
    }

  
    private Staff bindAndMapStaff(HttpServletRequest request, boolean isEdit) {
        String roleId = request.getParameter("roleId");
        if (roleId != null) {
            roleId = roleId.trim();
        }

        String email = request.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        String accountStatus = request.getParameter("accountStatus");
        if (accountStatus != null) {
            accountStatus = accountStatus.trim();
        }

        String password = request.getParameter("password");
        if (password == null || password.trim().isEmpty()) {
            password = "123456"; // Mật khẩu mặc định khi không truyền từ giao diện
        }

        User u = new User();
        u.setEmail(email);
        u.setRoleId(roleId);
        u.setAccountStatus(accountStatus);
        u.setVerified(true);
        u.setPassword(password);

        String fullName = request.getParameter("fullName");
        if (fullName != null) {
            fullName = fullName.trim();
        }

        String phone = request.getParameter("phone");
        if (phone != null) {
            phone = phone.trim();
        }

        Staff s = new Staff();
        s.setFullName(fullName);
        s.setPhone(phone);
        s.setIsActiveStaff(true);
        s.setUser(u);

        String managedZone = request.getParameter("managedZone");
        if (managedZone == null || managedZone.trim().isEmpty()) {
            managedZone = "Toàn thành phố";
        }
        s.setManagedZone(managedZone.trim());

        if (isEdit) {
            s.setStaffId(request.getParameter("userId")); 
        }

        String position = "";
        if ("ADMIN".equals(roleId)) {
            position = "Quản lý";
        } else if ("SHIPPER".equals(roleId)) {
            position = "Người giao hàng";
        } else if ("STAFF".equals(roleId)) {
            position = "Nhân viên";
        }
        s.setPosition(position);

        return s;
    }

    private boolean hasValidationError(HttpServletRequest request, HttpServletResponse response, Staff s)
            throws ServletException, IOException {
        String errorMessage = null;
        boolean isEdit = s.getStaffId() != null;
        StaffDAO dao = new StaffDAO();

        if (s.getFullName() == null || s.getFullName().isEmpty()) {
            errorMessage = "Vui lòng nhập họ và tên nhân viên!";
        } else if (s.getPhone() == null || s.getPhone().isEmpty()) {
            errorMessage = "Vui lòng nhập số điện thoại liên lạc!";
        } else if (!s.getPhone().matches("^(0)[35789][0-9]{8}$")) {
            errorMessage = "Số điện thoại không hợp lệ! Phải gồm 10 chữ số (bắt đầu bằng đầu số VN: 03, 05, 07, 08, 09).";
        } else if (s.getUser().getEmail() == null || s.getUser().getEmail().isEmpty()) {
            errorMessage = "Vui lòng nhập địa chỉ Email!";
        } else if (s.getUser().getRoleId() == null || s.getUser().getRoleId().isEmpty()) {
            errorMessage = "Vui lòng chọn chức vụ hệ thống!";
        } else if (s.getUser().getAccountStatus() == null || s.getUser().getAccountStatus().isEmpty()) {
            errorMessage = "Vui lòng chọn trạng thái tài khoản!";
        } else if (dao.checkEmailExist(s.getUser().getEmail(), isEdit ? s.getStaffId() : null)) {
            errorMessage = "Địa chỉ Email này đã được đăng ký bởi một nhân viên khác!";
        }

        if (errorMessage != null) {
            request.setAttribute("ERROR_MSG", errorMessage);
            request.setAttribute("USER_DATA", s);
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
        response.sendRedirect(request.getContextPath() + "/admin/staff?action=list");
    }

}
