package com.bakeryzone.utils;

public class ValidationUtils {
    public static final int NAME_MAX_LENGTH = 30;
    public static final int EMAIL_MAX_LENGTH = 100;
    public static final int PASSWORD_MIN_LENGTH = 6;
    public static final int PASSWORD_MAX_LENGTH = 20;

    public static String validateRegisterInput(String fullName, String email, String phone, String password, String confirmPassword) {
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
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return "Email không đúng định dạng.";
        }
        if (!phone.matches("^0\\d{9}$")) {
            return "Số điện thoại phải bắt đầu bằng 0 và có đúng 10 chữ số.";
        }
        if (phone.matches("^(\\d)\\1{9}$")) {
            return "Số điện thoại không hợp lệ.";
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
        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            return "Email không đúng định dạng.";
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
        if (startDateStr == null || startDateStr.trim().isEmpty() || endDateStr == null || endDateStr.trim().isEmpty()) {
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
}
