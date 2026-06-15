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
import java.util.ArrayList;
import java.util.List;
import java.sql.ResultSet;

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

    public List<DeliveryAddress> getAddressesByUserId(String userId) {

        List<DeliveryAddress> list = new ArrayList<>();

        String sql = """
        SELECT *
        FROM delivery_address
        WHERE User_ID = ?
        ORDER BY Address_ID DESC
    """;

        try (
                Connection conn = DBContext.getJDBCConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                DeliveryAddress a = new DeliveryAddress();

                a.setAddressId(rs.getInt("Address_ID"));
                a.setUserId(rs.getString("User_ID"));
                a.setReceiverName(rs.getString("Receiver_Name"));
                a.setReceiverPhone(rs.getString("Receiver_Phone"));
                a.setAddressDetail(rs.getString("Address_Detail"));
                a.setLatitude(rs.getDouble("Latitude"));
                a.setLongitude(rs.getDouble("Longitude"));
                a.setDefault(rs.getBoolean("Is_Default"));

                list.add(a);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
