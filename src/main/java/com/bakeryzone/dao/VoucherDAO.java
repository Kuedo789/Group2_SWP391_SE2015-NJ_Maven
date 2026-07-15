package com.bakeryzone.dao;

import com.bakeryzone.model.Voucher;
import com.bakeryzone.utils.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class VoucherDAO {

    /**
     * Validates a voucher for a specific user and cart subtotal.
     * This is the single source of truth for all voucher validation rules.
     *
     * @param code         Voucher code (case-insensitive, will be uppercased)
     * @param userId       The User_ID of the customer applying the voucher
     * @param cartSubtotal The total value of the cart (before discount & shipping)
     * @return null if the voucher is valid; a Vietnamese error message String if invalid
     */
    public String validateVoucher(String code, String userId, BigDecimal cartSubtotal) {
        if (code == null || code.trim().isEmpty()) {
            return "Vui lòng nhập mã voucher!";
        }

        Voucher v = getVoucherByCode(code.trim().toUpperCase());

        // 1. Voucher existence & active status
        if (v == null || !v.isActive()) {
            return "Mã voucher không tồn tại hoặc đã bị khóa!";
        }

        // 2. Date validity check
        long now = System.currentTimeMillis();
        if (v.getStartDate() == null || v.getEndDate() == null
                || v.getStartDate().getTime() > now || v.getEndDate().getTime() < now) {
            return "Mã voucher chưa bắt đầu hoặc đã hết hạn!";
        }

        // 3. Global quantity check
        if (v.getTotalQuantity() <= 0) {
            return "Mã voucher này đã hết số lượng!";
        }

        // 4. Per-user usage limit check
        int userUsage = getUserUsageCount(userId, v.getVoucherCode());
        if (userUsage >= v.getUsagePerUser()) {
            return "Bạn đã sử dụng hết lượt cho mã này!";
        }

        // 5. Required membership tier check
        if (v.getRequiredTierId() > 0) {
            int userTierId = getUserCurrentTierId(userId);
            if (userTierId < v.getRequiredTierId()) {
                String requiredTierName = getTierNameById(v.getRequiredTierId());
                return "Bạn cần đạt hạng " + requiredTierName + " để sử dụng mã này!";
            }
        }

        // 6. Minimum order value check (only when a subtotal is provided)
        if (cartSubtotal != null && v.getMinOrderValue() != null
                && cartSubtotal.compareTo(v.getMinOrderValue()) < 0) {
            String minFormatted = String.format("%,.0f", v.getMinOrderValue()) + "₫";
            return "Đơn hàng tối thiểu " + minFormatted + " mới được áp dụng mã này!";
        }

        return null; // All checks passed — voucher is valid
    }

    /**
     * Returns the current membership TierID for the given user.
     * Returns 0 if the user has no membership record (treated as lowest tier).
     */
    private int getUserCurrentTierId(String userId) {
        String sql = "SELECT CurrentTierID FROM UserMembership WHERE UserID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("CurrentTierID");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Returns the TierName for a given TierID. Falls back to "yêu cầu" if not found.
     */
    private String getTierNameById(int tierId) {
        String sql = "SELECT TierName FROM MembershipTier WHERE TierID = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tierId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("TierName");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "yêu cầu";
    }



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
