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

public class DeliveryAddressDAO {

    public boolean insertAddress(DeliveryAddress address) {
        String sql = """
            INSERT INTO delivery_address
            (User_ID, Receiver_Name, Receiver_Phone, Address_Detail, Latitude, Longitude, Is_Default)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """;

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, address.getUserId());
            ps.setString(2, address.getReceiverName());
            ps.setString(3, address.getReceiverPhone());
            ps.setString(4, address.getAddressDetail());
            ps.setDouble(5, address.getLatitude());
            ps.setDouble(6, address.getLongitude());
            ps.setBoolean(7, address.isDefault());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
}
