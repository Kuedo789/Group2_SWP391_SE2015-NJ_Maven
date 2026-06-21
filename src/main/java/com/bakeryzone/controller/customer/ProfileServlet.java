package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.utils.PasswordUtils;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
public class ProfileServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String fullName = trim(request.getParameter("fullName"));
        String phone = trim(request.getParameter("phone"));
        String address = request.getParameter("address");

        String currentPassword = trim(request.getParameter("currentPassword"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        setInputAttributes(request, fullName, phone, currentPassword, newPassword, confirmPassword);

        // 1. Validate họ tên
        if (isEmpty(fullName)) {
            forwardError(request, response, "Vui lòng nhập họ và tên.");
            return;
        }

        if (fullName.length() > 30) {
            forwardError(request, response, "Họ và tên không được quá 30 ký tự.");
            return;
        }

        if (fullName.contains("  ")) {
            forwardError(request, response, "Họ và tên không được có quá 1 khoảng trắng liên tiếp.");
            return;
        }

        if (!fullName.matches("[\\p{L}]+( [\\p{L}]+)*")) {
            forwardError(request, response, "Họ và tên không được chứa số hoặc ký tự đặc biệt.");
            return;
        }

        // 2. Validate số điện thoại Việt Nam
        if (isEmpty(phone)) {
            forwardError(request, response, "Vui lòng nhập số điện thoại.");
            return;
        }

        if (!phone.matches("0(3|5|7|8|9)\\d{8}")) {
            forwardError(request, response,
                    "Số điện thoại không hợp lệ. Số điện thoại Việt Nam phải bắt đầu bằng 03, 05, 07, 08 hoặc 09 và có đúng 10 chữ số.");
            return;
        }

        // 3. Kiểm tra có muốn đổi mật khẩu không
        boolean wantChangePassword =
                !isEmpty(currentPassword)
                || !isEmpty(newPassword)
                || !isEmpty(confirmPassword);

        if (wantChangePassword) {
            request.setAttribute("showPasswordBox", true);

            if (isEmpty(currentPassword)) {
                forwardError(request, response, "Vui lòng nhập mật khẩu hiện tại.");
                return;
            }

            User dbUser = userDAO.getUserById(user.getUserId());

            if (dbUser == null || dbUser.getPassword() == null) {
                forwardError(request, response, "Không tìm thấy thông tin tài khoản.");
                return;
            }

            if (!PasswordUtils.checkPassword(currentPassword, dbUser.getPassword())) {
                forwardError(request, response, "Mật khẩu hiện tại không đúng.");
                return;
            }

            if (isEmpty(newPassword)) {
                forwardError(request, response, "Vui lòng nhập mật khẩu mới.");
                return;
            }

            if (newPassword.length() > 20) {
                forwardError(request, response, "Mật khẩu mới không được quá 20 ký tự.");
                return;
            }

            if (isEmpty(confirmPassword)) {
                forwardError(request, response, "Vui lòng xác nhận mật khẩu mới.");
                return;
            }

            if (confirmPassword.length() > 20) {
                forwardError(request, response, "Xác nhận mật khẩu mới không được quá 20 ký tự.");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                forwardError(request, response, "Xác nhận mật khẩu mới không khớp.");
                return;
            }
        }

        // 4. Sau khi validate OK mới update
        boolean updated = userDAO.updateProfile(
                user.getUserId(),
                fullName,
                phone,
                address
        );

        if (updated) {
            user.setFullName(fullName);
            user.setPhone(phone);
            session.setAttribute("user", user);
        }

        if (wantChangePassword) {
            String hashedNewPassword = PasswordUtils.hashPassword(newPassword);

            if (hashedNewPassword == null) {
                request.setAttribute("showPasswordBox", true);
                forwardError(request, response, "Mật khẩu mới không hợp lệ.");
                return;
            }

            userDAO.updatePasswordByEmail(user.getEmail(), hashedNewPassword);

            user.setPassword(hashedNewPassword);
            session.setAttribute("user", user);
        }

        if (updated || wantChangePassword) {
            request.setAttribute("successMessage", "Cập nhật thông tin thành công.");

            // Sau khi cập nhật thành công thì không giữ lại mật khẩu trên form
            request.removeAttribute("inputCurrentPassword");
            request.removeAttribute("inputNewPassword");
            request.removeAttribute("inputConfirmPassword");
            request.removeAttribute("showPasswordBox");
        } else {
            request.setAttribute("errorMessage", "Cập nhật thất bại. Vui lòng thử lại.");
        }

        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isEmpty(String value) {
        return value == null || value.isEmpty();
    }

    private void setInputAttributes(HttpServletRequest request,
                                    String fullName,
                                    String phone,
                                    String currentPassword,
                                    String newPassword,
                                    String confirmPassword) {

        request.setAttribute("inputFullName", fullName);
        request.setAttribute("inputPhone", phone);
        request.setAttribute("inputCurrentPassword", currentPassword);
        request.setAttribute("inputNewPassword", newPassword);
        request.setAttribute("inputConfirmPassword", confirmPassword);
    }

    private void forwardError(HttpServletRequest request,
                              HttpServletResponse response,
                              String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }
}