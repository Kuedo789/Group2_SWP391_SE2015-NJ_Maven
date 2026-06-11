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
    private static final String FROM_EMAIL = "doduyhung0901@gmail.com";

    // App Password của Gmail, không phải mật khẩu đăng nhập Gmail thường
    private static final String APP_PASSWORD = "erqx uoeu fsdv nwlk";

    // Hàm gửi OTP mặc định, giữ lại để code cũ không bị lỗi
    public static boolean sendOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP xác thực BakeryZone",
                buildOtpContent(
                        "Xác thực tài khoản BakeryZone",
                        "Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong 5 phút."
                )
        );
    }

    // Hàm gửi OTP đăng ký tài khoản
    public static boolean sendRegisterOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP xác thực tài khoản BakeryZone",
                buildOtpContent(
                        "Xác thực tài khoản BakeryZone",
                        "Cảm ơn bạn đã đăng ký tài khoản tại BakeryZone. Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này cho người khác."
                )
        );
    }

    // Hàm gửi OTP quên mật khẩu
    public static boolean sendForgotPasswordOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP đặt lại mật khẩu BakeryZone",
                buildOtpContent(
                        "Đặt lại mật khẩu BakeryZone",
                        "Bạn đã yêu cầu đặt lại mật khẩu. Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong 5 phút. Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này."
                )
        );
    }

    // Hàm gửi email dùng chung
    private static boolean sendEmail(String toEmail, String subject, String htmlContent) {

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
            message.setSubject(subject);

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

    // Hàm tạo nội dung email OTP dạng HTML
    private static String buildOtpContent(String title, String message, String otpCode, String note) {
        return ""
                + "<div style='font-family: Arial, sans-serif; padding: 20px;'>"
                + "<h2 style='color: #8B4513;'>BakeryZone</h2>"
                + "<h3 style='color: #5a2d0c;'>" + title + "</h3>"
                + "<p>Xin chào,</p>"
                + "<p>" + message + "</p>"
                + "<div style='font-size: 28px; font-weight: bold; letter-spacing: 4px; "
                + "background: #f5e6d3; padding: 12px 18px; display: inline-block; "
                + "border-radius: 8px; color: #5a2d0c;'>"
                + otpCode
                + "</div>"
                + "<p>" + note + "</p>"
                + "<p>Trân trọng,<br>BakeryZone</p>"
                + "</div>";
    }
}