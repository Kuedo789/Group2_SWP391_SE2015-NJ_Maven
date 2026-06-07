package com.bakeryzone.utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtils {

    // Email Gmail dùng để gửi OTP
    private static final String FROM_EMAIL = "YOUR_GMAIL@gmail.com";

    // App Password của Gmail, không phải mật khẩu đăng nhập Gmail thường
    private static final String APP_PASSWORD = "YOUR_APP_PASSWORD";

    // Hàm gửi OTP
    public static boolean sendOtpEmail(String toEmail, String otpCode) {

        try {
            // Cấu hình SMTP của Gmail
            Properties props = new Properties();

            // Máy chủ SMTP Gmail
            props.put("mail.smtp.host", "smtp.gmail.com");

            // Cổng TLS của Gmail
            props.put("mail.smtp.port", "587");

            // Bật xác thực tài khoản
            props.put("mail.smtp.auth", "true");

            // Bật STARTTLS để gửi mail an toàn
            props.put("mail.smtp.starttls.enable", "true");

            // Tạo session đăng nhập SMTP
            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {

                    // Đăng nhập bằng Gmail + App Password
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            // Tạo nội dung email
            Message message = new MimeMessage(session);

            // Email người gửi
            message.setFrom(new InternetAddress(FROM_EMAIL, "BakeryZone"));

            // Email người nhận
            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );

            // Tiêu đề email
            message.setSubject("Mã OTP xác thực BakeryZone");

            // Nội dung email dạng HTML
            String htmlContent = ""
                    + "<div style='font-family: Arial, sans-serif; padding: 20px;'>"
                    + "<h2 style='color: #8B4513;'>BakeryZone</h2>"
                    + "<p>Xin chào,</p>"
                    + "<p>Mã OTP của bạn là:</p>"
                    + "<div style='font-size: 28px; font-weight: bold; letter-spacing: 4px; "
                    + "background: #f5e6d3; padding: 12px 18px; display: inline-block; "
                    + "border-radius: 8px; color: #5a2d0c;'>"
                    + otpCode
                    + "</div>"
                    + "<p>Mã này có hiệu lực trong <strong>5 phút</strong>.</p>"
                    + "<p>Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email.</p>"
                    + "</div>";

            // Set nội dung email là HTML, UTF-8 để không lỗi tiếng Việt
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            // Gửi email
            Transport.send(message);

            // Gửi thành công
            return true;

        } catch (Exception e) {
            // In lỗi ra console để debug
            e.printStackTrace();

            // Gửi thất bại
            return false;
        }
    }
}