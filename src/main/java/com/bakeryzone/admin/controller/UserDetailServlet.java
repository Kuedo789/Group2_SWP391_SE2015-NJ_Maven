package com.bakeryzone.admin.controller;

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

@WebServlet(name = "UserDetailServlet", urlPatterns = {"/userDetail"})
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

            request.getRequestDispatcher("/admin/userDetail.jsp").forward(request, response);

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

            // 1. Khởi tạo đối tượng User và nạp dữ liệu xác thực
            User u = new User();
            u.setEmail(email);
            u.setRoleId(roleId);
            u.setAccountStatus(accountStatus);
            u.setVerified(true);

            // 2. Khởi tạo đối tượng Staff và nhúng User vào
            Staff s = new Staff();
            s.setFullName(fullName);
            s.setPhone(phone);
            s.setIsActiveStaff(true);
            s.setUser(u); // Quan trọng: Bao gộp User vào Staff

            String position = "";
            if ("ADMIN".equals(roleId)) {
                position = "Quản lý";
            } else if ("SHIPPER".equals(roleId)) {
                position = "Người giao hàng";
            } else if ("STAFF".equals(roleId)) {
                position = "Nhân viên";
            }
            s.setPosition(position);

            String errorMessage = null;
            boolean isEdit = action != null && action.equals("edit");

            if (fullName == null || fullName.trim().isEmpty()
                    || email == null || email.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || roleId == null || roleId.trim().isEmpty()
                    || accountStatus == null || accountStatus.trim().isEmpty()
                    || (!isEdit && (password == null || password.trim().isEmpty()))) {

                errorMessage = "Vui lòng điền đầy đủ các trường thông tin";

            } else if (!phone.matches("^(0)[35789][0-9]{8}$")) {

                errorMessage = "Số điện thoại phải là 10 chữ số";

            } else if (!isEdit && password.length() < 6) {

                errorMessage = "Mật khẩu phải từ 6 kí tự trở lên";

            } else if (dao.checkEmailExist(email, isEdit ? userId : null)) {

                errorMessage = "Địa chỉ Email này đã được đăng kí bởi một nhân viên khác";
            }

            // Nếu có lỗi, trả lại dữ liệu về form
            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("USER_DATA", s);
                request.getRequestDispatcher("/admin/userDetail.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();

            // Xử lý Thêm mới hoặc Cập nhật
            if (isEdit) {
                s.setStaffId(userId);

                Staff oldStaff = dao.getStaffById(userId);
                s.setIsActiveStaff(oldStaff.isIsActiveStaff());

                // Xử lý password khi Edit
                if (password == null || password.trim().isEmpty()) {
                    s.getUser().setPassword(oldStaff.getUser().getPassword()); // Lấy mk cũ từ đối tượng User
                } else {
                    s.getUser().setPassword(password); // Set mk mới
                }

                dao.updateStaff(s);

                session.setAttribute(
                        "successMessage",
                        "Cập nhật tài khoản của " + fullName + " thành công!"
                );

            } else {
                s.getUser().setPassword(password);

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
