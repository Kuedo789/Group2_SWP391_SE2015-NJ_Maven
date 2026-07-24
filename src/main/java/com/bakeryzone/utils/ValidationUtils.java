package com.bakeryzone.utils;

public class ValidationUtils {
    public static final int NAME_MAX_LENGTH = 30;
    public static final int EMAIL_MAX_LENGTH = 100;
    public static final int PASSWORD_MIN_LENGTH = 6;
    public static final int PASSWORD_MAX_LENGTH = 20;

    public static String validateRegisterInput(String fullName, String email, String phone, String password,
            String confirmPassword) {
        if (fullName == null || fullName.isEmpty() ||
                email == null || email.isEmpty() ||
                phone == null || phone.isEmpty() ||
                password == null || password.isEmpty() ||
                confirmPassword == null || confirmPassword.isEmpty()) {
            return "Vui lòng nhập đầy đủ thông tin đăng ký.";
        }
        if (fullName.length() > NAME_MAX_LENGTH) {
            return "Họ tên không được vượt quá " + NAME_MAX_LENGTH + " ký tự.";
        }
        if (!fullName.matches("^[\\p{L}]+(?: [\\p{L}]+)*$")) {
            return "Họ tên chỉ được chứa chữ cái và không được có nhiều hơn 1 khoảng trắng liên tiếp.";
        }
        if (email.length() > EMAIL_MAX_LENGTH) {
            return "Email không được vượt quá " + EMAIL_MAX_LENGTH + " ký tự.";
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z]+\\.[A-Za-z.]+$")) {
            return "Email không đúng định dạng (tên miền sau dấu @ chỉ chứa chữ cái).";
        }
        if (!phone.matches("^0\\d{9}$")) {
            return "Số điện thoại phải bắt đầu bằng 0 và có đúng 10 chữ số.";
        }
        if (phone.substring(1).matches("^(\\d)\\1{8}$")) {
            return "Số điện thoại không hợp lệ (không được trùng lặp liên tiếp các chữ số).";
        }
        if (password.matches(".*\\s.*") || confirmPassword.matches(".*\\s.*")) {
            return "Mật khẩu không được chứa khoảng trắng.";
        }
        if (password.length() < PASSWORD_MIN_LENGTH) {
            return "Mật khẩu phải có ít nhất " + PASSWORD_MIN_LENGTH + " ký tự.";
        }
        if (password.length() > PASSWORD_MAX_LENGTH) {
            return "Mật khẩu không được vượt quá " + PASSWORD_MAX_LENGTH + " ký tự.";
        }
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }
        return null;
    }

    public static String validateEmailInput(String email) {
        if (email == null || email.isEmpty()) {
            return "Vui lòng nhập email.";
        }
        if (email.length() > EMAIL_MAX_LENGTH) {
            return "Email không được vượt quá " + EMAIL_MAX_LENGTH + " ký tự.";
        }
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z]+\\.[A-Za-z.]+$")) {
            return "Email không đúng định dạng (tên miền sau dấu @ chỉ chứa chữ cái).";
        }
        return null;
    }

    public static String validateForgotPasswordInput(String email) {
        return validateEmailInput(email);
    }

    public static String validateResetPasswordInput(String newPassword, String confirmPassword) {
        if (newPassword == null || newPassword.isEmpty() || confirmPassword == null || confirmPassword.isEmpty()) {
            return "Vui lòng nhập đầy đủ mật khẩu.";
        }
        if (newPassword.matches(".*\\s.*") || confirmPassword.matches(".*\\s.*")) {
            return "Mật khẩu không được chứa khoảng trắng.";
        }
        if (newPassword.length() < PASSWORD_MIN_LENGTH) {
            return "Mật khẩu phải có ít nhất " + PASSWORD_MIN_LENGTH + " ký tự.";
        }
        if (newPassword.length() > PASSWORD_MAX_LENGTH) {
            return "Mật khẩu không được vượt quá " + PASSWORD_MAX_LENGTH + " ký tự.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp.";
        }
        return null;
    }

    public static String validateOtpInput(String otp) {
        if (otp == null || otp.trim().isEmpty()) {
            return "Vui lòng nhập mã OTP.";
        }
        if (!otp.trim().matches("\\d{6}")) {
            return "Mã OTP phải gồm đúng 6 chữ số.";
        }
        return null;
    }

    public static boolean isValidDateFormat(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return true;
        }
        try {
            java.time.LocalDate.parse(dateStr);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean isValidDateRange(String startDateStr, String endDateStr) {
        if (startDateStr == null || startDateStr.trim().isEmpty() || endDateStr == null
                || endDateStr.trim().isEmpty()) {
            return true;
        }
        try {
            java.time.LocalDate start = java.time.LocalDate.parse(startDateStr.trim());
            java.time.LocalDate end = java.time.LocalDate.parse(endDateStr.trim());
            return !start.isAfter(end);
        } catch (Exception e) {
            return false;
        }
    }

    public static String validateSystemSettings(
            String bakeryName, String hotline, String email, String address,
            String depositPercent, String shippingRate,
            String systemEmail, String appPassword, String otpExpiry) {

        if (bakeryName == null || bakeryName.trim().isEmpty() ||
                hotline == null || hotline.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                depositPercent == null || depositPercent.trim().isEmpty() ||
                shippingRate == null || shippingRate.trim().isEmpty() ||
                systemEmail == null || systemEmail.trim().isEmpty() ||
                appPassword == null || appPassword.trim().isEmpty() ||
                otpExpiry == null || otpExpiry.trim().isEmpty()) {
            return "Vui lòng nhập đầy đủ các trường thông tin bắt buộc.";
        }

        if (bakeryName.trim().length() > 10) {
            return "Tên tiệm bánh không được vượt quá 10 ký tự.";
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z]+\\.[A-Za-z.]+$") ||
                !systemEmail.matches("^[A-Za-z0-9+_.-]+@[A-Za-z]+\\.[A-Za-z.]+$")) {
            return "Email không đúng định dạng (tên miền sau dấu @ chỉ chứa chữ cái).";
        }

        if (!hotline.matches("^0\\d{9}$")) {
            return "Số điện thoại Hotline phải bắt đầu bằng số 0 và có đúng 10 chữ số.";
        }
        if (hotline.substring(1).matches("^(\\d)\\1{8}$")) {
            return "Số điện thoại Hotline không hợp lệ (không được trùng lặp liên tiếp các chữ số).";
        }

        try {
            int deposit = Integer.parseInt(depositPercent);
            if (deposit < 0 || deposit > 100) {
                return "Phần trăm đặt cọc phải từ 0% đến 100%.";
            }
        } catch (NumberFormatException e) {
            return "Phần trăm đặt cọc phải là một số nguyên.";
        }

        try {
            double rate = Double.parseDouble(shippingRate);
            if (rate < 0) {
                return "Đơn giá ship/km không được âm.";
            }
        } catch (NumberFormatException e) {
            return "Đơn giá ship phải là một số hợp lệ.";
        }

        try {
            int otp = Integer.parseInt(otpExpiry);
            if (otp <= 0) {
                return "Thời gian hiệu lực OTP phải lớn hơn 0.";
            }
        } catch (NumberFormatException e) {
            return "Thời gian hiệu lực OTP phải là một số nguyên.";
        }

        return null;
    }

    public static String validateDateFilter(String startDate, String endDate) {
        if (!isValidDateFormat(startDate) || !isValidDateFormat(endDate)) {
            return "Định dạng ngày không hợp lệ.";
        }
        if (!isValidDateRange(startDate, endDate)) {
            return "Ngày bắt đầu không được lớn hơn Ngày kết thúc.";
        }
        return null;
    }

    public static String validateImageUpload(jakarta.servlet.http.Part part) {
        if (part == null || part.getSize() <= 0) {
            return null; // Không bắt buộc upload
        }
        
        String contentType = part.getContentType();
        if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/jpg"))) {
            return "File tải lên không đúng định dạng ảnh (chỉ cho phép JPG, JPEG, PNG).";
        }
        
        try {
            java.awt.image.BufferedImage image = javax.imageio.ImageIO.read(part.getInputStream());
            if (image == null) {
                return "File không phải là một bức ảnh hợp lệ.";
            }
            // Có thể thêm code kiểm tra kích thước cụ thể ở đây nếu cần, ví dụ:
            // if (image.getWidth() < 800 || image.getHeight() < 400) return "Ảnh banner phải lớn hơn 800x400.";
        } catch (java.io.IOException e) {
            return "Lỗi khi đọc file ảnh.";
        }
        
        return null;
    }
}
