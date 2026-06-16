package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.StaffDAO;
import com.bakeryzone.model.Staff;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

public class UserDetailServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String action = request.getParameter("action");

            String id = request.getParameter("id");

            StaffDAO dao = new StaffDAO();

            if (action != null && action.equals("delete")) {
                Staff staffToDelete = dao.getStaffById(id);
                String name = (staffToDelete != null) ? staffToDelete.getFullName() : "nhân viên";

                dao.deleteStaff(id);

                request.getSession().setAttribute(
                        "successMessage",
                        "Đã xóa tài khoản của " + name + " khỏi hệ thống!"
                );

                response.sendRedirect("userList");
                return;
            }

            if (action != null && action.equals("edit")) {
                Staff existingStaff = dao.getStaffById(id);
                request.setAttribute("USER_DATA", existingStaff);
            }

            request.getRequestDispatcher("admin/userDetail.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("userList");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            request.setCharacterEncoding("UTF-8");

            String action = request.getParameter("action");
            String userId = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String roleId = request.getParameter("roleId");
            String accountStatus = request.getParameter("accountStatus");

            StaffDAO dao = new StaffDAO();

            Staff s = new Staff();

            s.setFullName(fullName);
            s.setEmail(email);
            s.setPhone(phone);
            s.setRoleId(roleId);
            s.setAccountStatus(accountStatus);
            s.setIsActiveStaff(true);

            String errorMessage = null;

            boolean isEdit = action != null && action.equals("edit");

            if (fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || roleId == null || roleId.trim().isEmpty()
                    || accountStatus == null || accountStatus.trim().isEmpty()
                    || (!isEdit && (password == null || password.trim().isEmpty()))) {

                errorMessage = "Vui lòng điền đầy đủ các trường thông tin";

            } else if (!phone.matches("^(0)[3579][0-9]{8}$")) {

                errorMessage = "Số điện thoại phải là 10 chữ số";

            } else if (!isEdit && password.length() < 6) {

                errorMessage = "Mật khẩu phải từ 6 kí tự trở lên";

            } else if (dao.checkEmailExist(email, isEdit ? userId : null)) {

                errorMessage = "Địa chỉ Email này đã được đăng kí bởi một nhân viên khác";
            }

            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("USER_DATA", s);
                request.getRequestDispatcher("admin/userDetail.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();

            if (isEdit) {
                s.setStaffId(userId);

                Staff oldStaff = dao.getStaffById(userId);
                s.setIsActiveStaff(oldStaff.isIsActiveStaff());
                if (password == null || password.trim().isEmpty()) {
                    s.setPassword(oldStaff.getPassword());
                } else {
                    s.setPassword(password);
                }

                dao.updateStaff(s);

                session.setAttribute(
                        "successMessage",
                        "Cập nhật tài khoản của " + fullName + " thành công!"
                );

            } else {
                s.setPassword(password);

                dao.insertStaff(s);

                session.setAttribute(
                        "successMessage",
                        "Thêm mới tài khoản " + fullName + " thành công!"
                );
            }

            response.sendRedirect("userList");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("userList");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}