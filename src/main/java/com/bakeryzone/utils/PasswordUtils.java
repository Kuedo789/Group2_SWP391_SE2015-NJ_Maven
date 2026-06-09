/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bakeryzone.utils;

import java.security.MessageDigest;

/**
 *
 * @author Asus
 */
public class PasswordUtils {

    // Ham bam mat khau sang chuoi SHA-256 khong the giai ma nguoc
    public static String hashPassword(String password) {
        if (password == null || password.trim().isEmpty()) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();

            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString(); // Tra ve chuoi dai 64 ky tu o dang Hex
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        }
    }
     //check xem mat khau dang nhap co giong voi mat khau da ma hoa khong

    public static boolean checkPassword(String rawPassword, String hashedPassword) {
        if (rawPassword == null || rawPassword.trim().isEmpty()
                || hashedPassword == null || hashedPassword.trim().isEmpty()) {
            return false;
        }

        String rawHash = hashPassword(rawPassword);

        if (rawHash == null) {
            return false;
        }

        return rawHash.equals(hashedPassword);
    }
}
