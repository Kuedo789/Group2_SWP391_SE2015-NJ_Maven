/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.dao;

import com.bakeryzone.model.DeliveryAddress;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DeliveryAddressDAO {


    private void close(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<DeliveryAddress> getAddressesByUserId(String userId) {
        List<DeliveryAddress> list = new ArrayList<>();
        String sql = """
            SELECT Address_ID, User_ID, Receiver_Name, Receiver_Phone, Address_Detail, Latitude, Longitude, Is_Default
            FROM delivery_address
            WHERE User_ID = ?
            ORDER BY Is_Default DESC, Address_ID DESC
        """;
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DeliveryAddress address = new DeliveryAddress();
                    address.setAddressId(rs.getInt("Address_ID"));
                    address.setUserId(rs.getString("User_ID"));
                    address.setReceiverName(rs.getString("Receiver_Name"));
                    address.setReceiverPhone(rs.getString("Receiver_Phone"));
                    address.setAddressDetail(rs.getString("Address_Detail"));
                    address.setLatitude(rs.getDouble("Latitude"));
                    address.setLongitude(rs.getDouble("Longitude"));
                    address.setDefault(rs.getBoolean("Is_Default"));
                    list.add(address);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public DeliveryAddress getAddressById(int addressId, String userId) {
        String sql = """
            SELECT Address_ID, User_ID, Receiver_Name, Receiver_Phone, Address_Detail, Latitude, Longitude, Is_Default
            FROM delivery_address
            WHERE Address_ID = ? AND User_ID = ?
        """;
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, addressId);
            ps.setString(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DeliveryAddress address = new DeliveryAddress();
                    address.setAddressId(rs.getInt("Address_ID"));
                    address.setUserId(rs.getString("User_ID"));
                    address.setReceiverName(rs.getString("Receiver_Name"));
                    address.setReceiverPhone(rs.getString("Receiver_Phone"));
                    address.setAddressDetail(rs.getString("Address_Detail"));
                    address.setLatitude(rs.getDouble("Latitude"));
                    address.setLongitude(rs.getDouble("Longitude"));
                    address.setDefault(rs.getBoolean("Is_Default"));
                    return address;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertAddress(DeliveryAddress address) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // Check if this user has any addresses yet
            String countSql = "SELECT COUNT(*) FROM delivery_address WHERE User_ID = ?";
            int count = 0;
            try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                psCount.setString(1, address.getUserId());
                try (ResultSet rs = psCount.executeQuery()) {
                    if (rs.next()) {
                        count = rs.getInt(1);
                    }
                }
            }

            // If first address, force Is_Default to true
            if (count == 0) {
                address.setDefault(true);
            }

            if (address.isDefault()) {
                // Unset other defaults for this user
                String unsetSql = "UPDATE delivery_address SET Is_Default = 0 WHERE User_ID = ?";
                try (PreparedStatement psUnset = conn.prepareStatement(unsetSql)) {
                    psUnset.setString(1, address.getUserId());
                    psUnset.executeUpdate();
                }
                // Sync customer default address
                String syncSql = "UPDATE customer SET Default_Address = ? WHERE User_ID = ?";
                try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                    psSync.setString(1, address.getAddressDetail());
                    psSync.setString(2, address.getUserId());
                    psSync.executeUpdate();
                }
            }

            String sql = """
                INSERT INTO delivery_address
                (User_ID, Receiver_Name, Receiver_Phone, Address_Detail, Latitude, Longitude, Is_Default)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
            ps = conn.prepareStatement(sql);
            ps.setString(1, address.getUserId());
            ps.setString(2, address.getReceiverName());
            ps.setString(3, address.getReceiverPhone());
            ps.setString(4, address.getAddressDetail());
            ps.setDouble(5, address.getLatitude());
            ps.setDouble(6, address.getLongitude());
            ps.setBoolean(7, address.isDefault());

            boolean success = ps.executeUpdate() > 0;
            conn.commit();
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public boolean updateAddress(DeliveryAddress address) {
        String sql = """
            UPDATE delivery_address
            SET Receiver_Name = ?, Receiver_Phone = ?, Address_Detail = ?, Latitude = ?, Longitude = ?, Is_Default = ?
            WHERE Address_ID = ? AND User_ID = ?
        """;
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            if (address.isDefault()) {
                // Unset other defaults for this user
                String unsetSql = "UPDATE delivery_address SET Is_Default = 0 WHERE User_ID = ?";
                try (PreparedStatement psUnset = conn.prepareStatement(unsetSql)) {
                    psUnset.setString(1, address.getUserId());
                    psUnset.executeUpdate();
                }
                // Also sync customer default address
                String syncSql = "UPDATE customer SET Default_Address = ? WHERE User_ID = ?";
                try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                    psSync.setString(1, address.getAddressDetail());
                    psSync.setString(2, address.getUserId());
                    psSync.executeUpdate();
                }
            }

            ps = conn.prepareStatement(sql);
            ps.setString(1, address.getReceiverName());
            ps.setString(2, address.getReceiverPhone());
            ps.setString(3, address.getAddressDetail());
            ps.setDouble(4, address.getLatitude());
            ps.setDouble(5, address.getLongitude());
            ps.setBoolean(6, address.isDefault());
            ps.setInt(7, address.getAddressId());
            ps.setString(8, address.getUserId());

            boolean success = ps.executeUpdate() > 0;
            conn.commit();
            return success;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public boolean deleteAddress(int addressId, String userId) {
        DeliveryAddress addressToDelete = getAddressById(addressId, userId);
        if (addressToDelete == null) {
            return false;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // Delete the address
            String deleteSql = "DELETE FROM delivery_address WHERE Address_ID = ? AND User_ID = ?";
            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setInt(1, addressId);
                psDel.setString(2, userId);
                psDel.executeUpdate();
            }

            // If it was default, set another address as default
            if (addressToDelete.isDefault()) {
                // Find another address
                String findNextSql = "SELECT Address_ID, Address_Detail FROM delivery_address WHERE User_ID = ? ORDER BY Address_ID DESC LIMIT 1";
                int nextId = -1;
                String nextAddressDetail = null;
                try (PreparedStatement psFind = conn.prepareStatement(findNextSql)) {
                    psFind.setString(1, userId);
                    try (ResultSet rs = psFind.executeQuery()) {
                        if (rs.next()) {
                            nextId = rs.getInt("Address_ID");
                            nextAddressDetail = rs.getString("Address_Detail");
                        }
                    }
                }

                if (nextId != -1) {
                    // Set next as default
                    String setNextSql = "UPDATE delivery_address SET Is_Default = 1 WHERE Address_ID = ?";
                    try (PreparedStatement psSetNext = conn.prepareStatement(setNextSql)) {
                        psSetNext.setInt(1, nextId);
                        psSetNext.executeUpdate();
                    }
                    // Sync customer default address
                    String syncSql = "UPDATE customer SET Default_Address = ? WHERE User_ID = ?";
                    try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                        psSync.setString(1, nextAddressDetail);
                        psSync.setString(2, userId);
                        psSync.executeUpdate();
                    }
                } else {
                    // No other address left, clear customer default address
                    String syncSql = "UPDATE customer SET Default_Address = NULL WHERE User_ID = ?";
                    try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                        psSync.setString(1, userId);
                        psSync.executeUpdate();
                    }
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            close(conn, ps, null);
        }
        return false;
    }

    public boolean setDefaultAddress(int addressId, String userId) {
        DeliveryAddress address = getAddressById(addressId, userId);
        if (address == null) {
            return false;
        }

        Connection conn = null;
        try {
            conn = DBContext.getJDBCConnection();
            if (conn == null) return false;
            conn.setAutoCommit(false);

            // Unset other defaults for this user
            String unsetSql = "UPDATE delivery_address SET Is_Default = 0 WHERE User_ID = ?";
            try (PreparedStatement psUnset = conn.prepareStatement(unsetSql)) {
                psUnset.setString(1, userId);
                psUnset.executeUpdate();
            }

            // Set selected as default
            String setSql = "UPDATE delivery_address SET Is_Default = 1 WHERE Address_ID = ? AND User_ID = ?";
            try (PreparedStatement psSet = conn.prepareStatement(setSql)) {
                psSet.setInt(1, addressId);
                psSet.setString(2, userId);
                psSet.executeUpdate();
            }

            // Sync customer default address
            String syncSql = "UPDATE customer SET Default_Address = ? WHERE User_ID = ?";
            try (PreparedStatement psSync = conn.prepareStatement(syncSql)) {
                psSync.setString(1, address.getAddressDetail());
                psSync.setString(2, userId);
                psSync.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }
}
