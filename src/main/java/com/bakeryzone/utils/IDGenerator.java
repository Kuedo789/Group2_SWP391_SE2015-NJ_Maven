package com.bakeryzone.utils;

import java.util.UUID;

public class IDGenerator {

    public static String generateUserId(String roleId) {
        String prefix = "U";
        if (roleId != null) {
            if ("CUSTOMER".equalsIgnoreCase(roleId)) {
                prefix = "CUS";
            } else if ("STAFF".equalsIgnoreCase(roleId)) {
                prefix = "STAFF";
            } else if ("ADMIN".equalsIgnoreCase(roleId)) {
                prefix = "ADMIN";
            } else if ("SHIPPER".equalsIgnoreCase(roleId)) {
                prefix = "SHIP";
            }
        }
        return prefix + "_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    public static String generateStaffId() {
        return "STF_" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
}
