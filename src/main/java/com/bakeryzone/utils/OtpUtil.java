package com.bakeryzone.utils;

import java.security.SecureRandom;
import java.sql.Timestamp;

public class OtpUtil {

    private static final SecureRandom random = new SecureRandom();
    private static final int OTP_EXPIRE_MINUTES = 1;

    public static String generateOtp() {
        return String.format("%06d", random.nextInt(1_000_000));
    }

    public static Timestamp generateExpiryTime() {
        return new Timestamp(System.currentTimeMillis() + OTP_EXPIRE_MINUTES * 60 * 1000L);
    }
    public static int getOtpExpireMinutes() {
        return OTP_EXPIRE_MINUTES;
    }
    public static String getOtpExpireText() {
        return OTP_EXPIRE_MINUTES + " phút";
    }
}