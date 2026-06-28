package com.bakeryzone.dao;

import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class SettingDAO {

    public Map<String, Object> getSettings() {
        Map<String, Object> settings = new HashMap<>();
        String sql = "SELECT * FROM `settings`";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String key = rs.getString("setting_key");
                String value = rs.getString("setting_value");
                
                if ("darkMode".equals(key)) {
                    settings.put(key, Boolean.parseBoolean(value));
                } else {
                    settings.put(key, value);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return settings;
    }

    public boolean updateSettings(Map<String, Object> settings) {
        String sql = "INSERT INTO `settings` (`setting_key`, `setting_value`) VALUES (?, ?) "
                + "ON DUPLICATE KEY UPDATE `setting_value` = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            for (Map.Entry<String, Object> entry : settings.entrySet()) {
                String key = entry.getKey();
                String value = String.valueOf(entry.getValue());
                
                ps.setString(1, key);
                ps.setString(2, value);
                ps.setString(3, value);
                ps.addBatch();
            }
            ps.executeBatch();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
