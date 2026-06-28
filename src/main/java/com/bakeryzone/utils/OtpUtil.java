package com.bakeryzone.utils;

import java.security.SecureRandom;
import java.sql.Timestamp;

public class OtpUtil {

    private static final SecureRandom random = new SecureRandom();

    public static String generateOtp() {
        return String.format("%06d", random.nextInt(1_000_000));
    }

    public static Timestamp generateExpiryTime() {
        return new Timestamp(System.currentTimeMillis() + getOtpExpireMinutes() * 60 * 1000L);
    }
    public static int getOtpExpireMinutes() {
        try {
            com.bakeryzone.dao.SettingDAO settingDAO = new com.bakeryzone.dao.SettingDAO();
            java.util.Map<String, Object> settings = settingDAO.getSettings();
            if (settings != null && settings.containsKey("otpExpiry")) {
                return Integer.parseInt((String) settings.get("otpExpiry"));
            }
        } catch (Exception e) {
            // Fallback to default
        }
        return 3;
    }
    public static String getOtpExpireText() {
        return getOtpExpireMinutes() + " phút";
    }
}