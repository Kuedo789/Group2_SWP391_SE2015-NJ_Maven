package com.bakeryzone.utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;
import jakarta.mail.internet.MimeUtility;

public class EmailUtils {

    public static boolean sendOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP xác thực BakeryZone",
                buildOtpContent(
                        "Xác thực tài khoản BakeryZone",
                        "Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong "+OtpUtil.getOtpExpireText()+"."
                )
        );
    }

    public static boolean sendRegisterOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP xác thực tài khoản BakeryZone",
                buildOtpContent(
                        "Xác thực tài khoản BakeryZone",
                        "Cảm ơn bạn đã đăng ký tài khoản tại BakeryZone. Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong "+OtpUtil.getOtpExpireText()+". Vui lòng không chia sẻ mã này cho người khác."
                )
        );
    }

    public static boolean sendForgotPasswordOtpEmail(String toEmail, String otpCode) {
        return sendEmail(
                toEmail,
                "Mã OTP đặt lại mật khẩu BakeryZone",
                buildOtpContent(
                        "Đặt lại mật khẩu BakeryZone",
                        "Bạn đã yêu cầu đặt lại mật khẩu. Mã OTP của bạn là:",
                        otpCode,
                        "Mã này có hiệu lực trong  "+OtpUtil.getOtpExpireText()+". Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này."
                )
        );
    }

    private static boolean sendEmail(String toEmail, String subject, String htmlContent) {
        String fromEmail = null;
        String appPassword = null;
        String bakeryName = "BakeryZone";
        
        try {
            com.bakeryzone.dao.SettingDAO settingDAO = new com.bakeryzone.dao.SettingDAO();
            java.util.Map<String, Object> settings = settingDAO.getSettings();
            if (settings != null && !settings.isEmpty()) {
                fromEmail = (String) settings.get("systemEmail");
                appPassword = (String) settings.get("appPassword");
                String dbName = (String) settings.get("bakeryName");
                if (dbName != null && !dbName.isEmpty()) {
                    bakeryName = dbName;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (fromEmail == null || fromEmail.isEmpty() || appPassword == null || appPassword.isEmpty()) {
            System.err.println("LỖI: Chưa có cấu hình Email hệ thống hoặc Mật khẩu ứng dụng trong Database!");
            return false;
        }

        final String finalFrom = fromEmail;
        final String finalPass = appPassword;
        final String finalName = bakeryName;

        try {
            Properties props = new Properties();

            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(finalFrom, finalPass);
                }
            });

            Message message = new MimeMessage(session);

            message.setFrom(new InternetAddress(finalFrom, finalName, "UTF-8"));

            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail, false)
            );

            // Có UTF-8 để title mail không bị lỗi dấu ? ? ?
            message.setSubject(MimeUtility.encodeText(subject, "UTF-8", "B"));

            // Có charset UTF-8 để nội dung email không lỗi tiếng Việt
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);

            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

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
