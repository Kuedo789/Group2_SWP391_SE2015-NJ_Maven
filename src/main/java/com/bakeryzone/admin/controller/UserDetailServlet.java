package com.bakeryzone.admin.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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
            String userId = request.getParameter("id");

            UserDAO dao = new UserDAO();

            // Nếu action là delete thì xóa theo userId dạng String
            if ("delete".equals(action)) {
                dao.deleteUser(userId);
                response.sendRedirect("userList");
                return;
            }

            // Nếu action là edit thì tìm user theo userId dạng String
            if ("edit".equals(action)) {
                User existingUser = dao.getUserById(userId);
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

            UserDAO dao = new UserDAO();

            // Tạo object User để truyền xuống DAO
            User u = new User();
            u.setFullName(fullName);
            u.setEmail(email);
            u.setPassword(password);
            u.setPhone(phone);
            u.setRoleId(roleId);

            // Set mặc định cho các cột mới trong database
            u.setProvider("LOCAL");
            u.setProviderId(null);
            u.setAccountStatus("Active");

            // Nếu là admin/staff/shipper thì activeStaff = true
            boolean activeStaff = "ADMIN".equalsIgnoreCase(roleId)
                    || "STAFF".equalsIgnoreCase(roleId)
                    || "SHIPPER".equalsIgnoreCase(roleId);

            u.setActiveStaff(activeStaff);

            // User tạo từ admin nên cho verified luôn
            u.setVerified(true);

            // Nếu đang sửa user thì set userId dạng String rồi update
            if ("edit".equals(action)) {
                u.setUserId(userId);
                dao.updateUser(u);
            } else {
                // Nếu thêm mới thì insertUser sẽ tự generate userId nếu userId null
                dao.insertUser(u);
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