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
        
        // Handle PRG pattern success message
        String successMessage = (String) session.getAttribute("successMessage");
        if (successMessage != null) {
            request.setAttribute("successMessage", successMessage);
            session.removeAttribute("successMessage");
        }

        User user = (User) session.getAttribute("user");
        if (user != null && "CUSTOMER".equalsIgnoreCase(user.getRoleId())) {
            com.bakeryzone.dao.DeliveryAddressDAO addressDAO = new com.bakeryzone.dao.DeliveryAddressDAO();
            addressDAO.getAddressesByUserId(user.getUserId()).stream()
                    .filter(com.bakeryzone.model.DeliveryAddress::isDefault)
                    .findFirst()
                    .ifPresent(addr -> request.setAttribute("defaultDeliveryAddress", addr));
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

        String currentPassword = trim(request.getParameter("currentPassword"));
        String newPassword = trim(request.getParameter("newPassword"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        // 1. Validate họ tên và số điện thoại
        String profileError = validateProfile(fullName, phone);
        if (profileError != null) {
            forwardError(request, response, profileError);
            return;
        }

        // 2. Kiểm tra có muốn đổi mật khẩu không
        boolean wantChangePassword =
                !isEmpty(currentPassword)
                || !isEmpty(newPassword)
                || !isEmpty(confirmPassword);

        if (wantChangePassword) {
            request.setAttribute("showPasswordBox", true);

            User dbUser = userDAO.getUserById(user.getUserId());
            if (dbUser == null || dbUser.getPassword() == null) {
                forwardError(request, response, "Không tìm thấy thông tin tài khoản.");
                return;
            }

            String passwordError = validatePasswordChange(currentPassword, newPassword, confirmPassword, dbUser.getPassword());
            if (passwordError != null) {
                forwardError(request, response, passwordError);
                return;
            }
        }

        // 3. Sau khi validate OK mới update profile
        boolean updated = userDAO.updateProfile(user.getUserId(), fullName, phone);
        if (updated) {
            user.setFullName(fullName);
            user.setPhone(phone);
            session.setAttribute("user", user);
        }

        // 4. Update mật khẩu nếu cần
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
            // Apply PRG Pattern to avoid double form submission on refresh
            session.setAttribute("successMessage", "Cập nhật thông tin thành công.");
            response.sendRedirect(request.getContextPath() + "/profile");
        } else {
            forwardError(request, response, "Cập nhật thất bại. Vui lòng thử lại.");
        }
    }

    private String validateProfile(String fullName, String phone) {
        if (isEmpty(fullName)) return "Vui lòng nhập họ và tên.";
        if (fullName.length() > 30) return "Họ và tên không được quá 30 ký tự.";
        if (fullName.contains("  ")) return "Họ và tên không được có quá 1 khoảng trắng liên tiếp.";
        if (!fullName.matches("[\\p{L}]+( [\\p{L}]+)*")) return "Họ và tên không được chứa số hoặc ký tự đặc biệt.";

        if (isEmpty(phone)) return "Vui lòng nhập số điện thoại.";
        if (!phone.matches("0(3|5|7|8|9)\\d{8}")) {
            return "Số điện thoại không hợp lệ. Số điện thoại Việt Nam phải bắt đầu bằng 03, 05, 07, 08 hoặc 09 và có đúng 10 chữ số.";
        }
        return null;
    }

    private String validatePasswordChange(String currentPassword, String newPassword, String confirmPassword, String dbPassword) {
        if (isEmpty(currentPassword)) return "Vui lòng nhập mật khẩu hiện tại.";
        if (!PasswordUtils.checkPassword(currentPassword, dbPassword)) return "Mật khẩu hiện tại không đúng.";

        if (isEmpty(newPassword)) return "Vui lòng nhập mật khẩu mới.";
        if (newPassword.length() < 6 || newPassword.length() > 20) return "Mật khẩu mới phải từ 6 đến 20 ký tự.";
        if (newPassword.equals(currentPassword)) return "Mật khẩu mới không được trùng với mật khẩu hiện tại.";

        if (isEmpty(confirmPassword)) return "Vui lòng xác nhận mật khẩu mới.";
        if (confirmPassword.length() > 20) return "Xác nhận mật khẩu mới không được quá 20 ký tự.";
        if (!newPassword.equals(confirmPassword)) return "Xác nhận mật khẩu mới không khớp.";

        return null;
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isEmpty(String value) {
        return value == null || value.isEmpty();
    }

    private void forwardError(HttpServletRequest request,
                              HttpServletResponse response,
                              String message)
            throws ServletException, IOException {

        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/customer/profile.jsp").forward(request, response);
    }
}