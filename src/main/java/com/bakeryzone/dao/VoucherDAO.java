package com.bakeryzone.dao;

import com.bakeryzone.model.Voucher;
import com.bakeryzone.utils.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO {

    public List<Voucher> getAllVouchers() {
        List<Voucher> list = new ArrayList<>();
        String sql = "SELECT * FROM `Voucher` ORDER BY Start_Date DESC";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Voucher v = new Voucher();
                v.setVoucherCode(rs.getString("Voucher_Code"));
                v.setDiscountAmount(rs.getBigDecimal("Discount_Amount"));
                v.setMinOrderValue(rs.getBigDecimal("Min_Order_Value"));
                v.setTotalQuantity(rs.getInt("Total_Quantity"));
                v.setUsagePerUser(rs.getInt("Usage_Per_User"));
                v.setRequiredTierId(rs.getInt("Required_Tier_ID"));
                v.setStartDate(rs.getDate("Start_Date"));
                v.setEndDate(rs.getDate("End_Date"));
                v.setActive(rs.getBoolean("Is_Active"));
                list.add(v);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Voucher getVoucherByCode(String code) {
        String sql = "SELECT * FROM `Voucher` WHERE Voucher_Code = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Voucher v = new Voucher();
                    v.setVoucherCode(rs.getString("Voucher_Code"));
                    v.setDiscountAmount(rs.getBigDecimal("Discount_Amount"));
                    v.setMinOrderValue(rs.getBigDecimal("Min_Order_Value"));
                    v.setTotalQuantity(rs.getInt("Total_Quantity"));
                    v.setUsagePerUser(rs.getInt("Usage_Per_User"));
                    v.setRequiredTierId(rs.getInt("Required_Tier_ID"));
                    v.setStartDate(rs.getDate("Start_Date"));
                    v.setEndDate(rs.getDate("End_Date"));
                    v.setActive(rs.getBoolean("Is_Active"));
                    return v;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertVoucher(Voucher v) {
        String sql = "INSERT INTO `Voucher` (Voucher_Code, Discount_Amount, Min_Order_Value, Total_Quantity, Usage_Per_User, Required_Tier_ID, Start_Date, End_Date, Is_Active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getVoucherCode());
            ps.setBigDecimal(2, v.getDiscountAmount());
            ps.setBigDecimal(3, v.getMinOrderValue());
            ps.setInt(4, v.getTotalQuantity());
            ps.setInt(5, v.getUsagePerUser());
            ps.setInt(6, v.getRequiredTierId());
            ps.setDate(7, v.getStartDate());
            ps.setDate(8, v.getEndDate());
            ps.setBoolean(9, v.isActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateVoucher(Voucher v) {
        String sql = "UPDATE `Voucher` SET Discount_Amount = ?, Min_Order_Value = ?, Total_Quantity = ?, Usage_Per_User = ?, Required_Tier_ID = ?, Start_Date = ?, End_Date = ?, Is_Active = ? WHERE Voucher_Code = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, v.getDiscountAmount());
            ps.setBigDecimal(2, v.getMinOrderValue());
            ps.setInt(3, v.getTotalQuantity());
            ps.setInt(4, v.getUsagePerUser());
            ps.setInt(5, v.getRequiredTierId());
            ps.setDate(6, v.getStartDate());
            ps.setDate(7, v.getEndDate());
            ps.setBoolean(8, v.isActive());
            ps.setString(9, v.getVoucherCode());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteVoucher(String code) {
        String sql = "DELETE FROM `Voucher` WHERE Voucher_Code = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleVoucherStatus(String code, boolean isActive) {
        String sql = "UPDATE `Voucher` SET Is_Active = ? WHERE Voucher_Code = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setString(2, code);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int getUserUsageCount(String userId, String voucherCode) {
        String sql = "SELECT COUNT(*) FROM `orders` WHERE Customer_ID = ? AND Applied_Voucher_Code = ? AND OrderStatus != 'CANCELLED'";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, voucherCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean decrementQuantity(String code) {
        String sql = "UPDATE `Voucher` SET Total_Quantity = Total_Quantity - 1 WHERE Voucher_Code = ? AND Total_Quantity > 0";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
