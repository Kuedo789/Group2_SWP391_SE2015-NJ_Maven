package com.bakeryzone.dao;

import com.bakeryzone.model.UnitMeasure;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UnitMeasureDAO {
    private static final Logger LOGGER = Logger.getLogger(UnitMeasureDAO.class.getName());

    public List<UnitMeasure> getAllUnitMeasures() {
        List<UnitMeasure> list = new ArrayList<>();
        String sql = "SELECT Unit_ID, Unit_Name, Description, enable FROM unit_measure WHERE enable = 1 ORDER BY Unit_ID ASC";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                UnitMeasure u = new UnitMeasure(
                    rs.getString("Unit_ID"),
                    rs.getString("Unit_Name"),
                    rs.getString("Description"),
                    rs.getBoolean("enable")
                );
                list.add(u);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all unit measures", e);
        }
        return list;
    }

    public UnitMeasure getUnitMeasureById(String id) {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = "SELECT Unit_ID, Unit_Name, Description, enable FROM unit_measure WHERE Unit_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new UnitMeasure(
                        rs.getString("Unit_ID"),
                        rs.getString("Unit_Name"),
                        rs.getString("Description"),
                        rs.getBoolean("enable")
                    );
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get unit measure by ID: " + id, e);
        }
        return null;
    }

    public boolean saveUnitMeasure(UnitMeasure unit) {
        try (Connection conn = DBContext.getJDBCConnection()) {
            boolean exists = false;
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM unit_measure WHERE Unit_ID = ?")) {
                ps.setString(1, unit.getUnitId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            }

            if (exists) {
                String sql = "UPDATE unit_measure SET Unit_Name = ?, Description = ?, enable = ? WHERE Unit_ID = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, unit.getUnitName());
                    ps.setString(2, unit.getDescription());
                    ps.setBoolean(3, unit.isEnable());
                    ps.setString(4, unit.getUnitId());
                    return ps.executeUpdate() > 0;
                }
            } else {
                String sql = "INSERT INTO unit_measure (Unit_ID, Unit_Name, Description, enable) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, unit.getUnitId());
                    ps.setString(2, unit.getUnitName());
                    ps.setString(3, unit.getDescription());
                    ps.setBoolean(4, unit.isEnable());
                    return ps.executeUpdate() > 0;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to save unit measure: " + unit.getUnitId(), e);
        }
        return false;
    }

    public boolean deleteUnitMeasure(String id) {
        if (id == null || id.trim().isEmpty()) return false;
        String sql = "UPDATE unit_measure SET enable = 0 WHERE Unit_ID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to soft delete unit measure: " + id, e);
        }
        return false;
    }
}
