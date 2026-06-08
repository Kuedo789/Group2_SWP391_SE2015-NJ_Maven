package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.UserDAO;
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
            // Lấy action: delete, edit hoặc null
            String action = request.getParameter("action");

            // User_ID là String nên không parseInt
            String id = request.getParameter("id");

            UserDAO dao = new UserDAO();

            // Nếu action là delete thì xóa theo userId dạng String
            if (action != null && action.equals("delete")) {
                User userToDelete = dao.getUserById(id);
                String name = (userToDelete != null) ? userToDelete.getFullName() : "người dùng";

                dao.deleteUser(id);

                request.getSession().setAttribute(
                        "successMessage",
                        "Đã xóa tài khoản của " + name + " khỏi hệ thống!"
                );

                response.sendRedirect("userList");
                return;
            }

            // Nếu action là edit thì tìm user theo userId dạng String
            if (action != null && action.equals("edit")) {
                User existingUser = dao.getUserById(id);
                request.setAttribute("USER_DATA", existingUser);
            }

            // Chuyển sang trang userDetail.jsp
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
            // Đảm bảo đọc tiếng Việt đúng
            request.setCharacterEncoding("UTF-8");

            // Lấy dữ liệu từ form
            String action = request.getParameter("action");
            String userId = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String roleId = request.getParameter("roleId");
            String accountStatus = request.getParameter("accountStatus");

            UserDAO dao = new UserDAO();

            // Tạo object User để truyền xuống DAO
            User u = new User();

            u.setFullName(fullName);
            u.setEmail(email);
            u.setPhone(phone);
            u.setRoleId(roleId);
            u.setAccountStatus(accountStatus);

            // Set mặc định cho các cột mới trong database
            u.setProvider("LOCAL");
            u.setProviderId(null);

            // User tạo từ admin nên cho verified luôn
            u.setVerified(true);

            // Nếu là admin/staff/shipper thì activeStaff = true
            boolean activeStaff = "ADMIN".equalsIgnoreCase(roleId)
                    || "STAFF".equalsIgnoreCase(roleId)
                    || "SHIPPER".equalsIgnoreCase(roleId);

            u.setActiveStaff(activeStaff);

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

                errorMessage = "Địa chỉ Email này đã được đăng kí bởi một tài khoản khác";
            }

            if (errorMessage != null) {
                request.setAttribute("ERROR_MSG", errorMessage);
                request.setAttribute("USER_DATA", u);
                request.getRequestDispatcher("admin/userDetail.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession();

            // Nếu đang sửa user thì set userId dạng String rồi update
            if (isEdit) {
                u.setUserId(userId);

                // Nếu sửa user mà không nhập password mới thì giữ password cũ
                User oldUser = dao.getUserById(userId);

                if (password == null || password.trim().isEmpty()) {
                    u.setPassword(oldUser.getPassword());
                } else {
                    u.setPassword(password);
                }

                dao.updateUser(u);

                session.setAttribute(
                        "successMessage",
                        "Cập nhật tài khoản của " + fullName + " thành công!"
                );

            } else {
                // Nếu thêm mới thì insertUser sẽ tự generate userId nếu userId null
                u.setPassword(password);

                dao.insertUser(u);

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