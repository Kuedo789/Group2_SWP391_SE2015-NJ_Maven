package com.bakeryzone.service;

import com.bakeryzone.dao.MembershipDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.dao.ShipperTripDAO;
import com.bakeryzone.model.MembershipTier;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.model.UserMembership;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class OrderService {

    private final OrderDAO orderDAO;
    private final MembershipDAO membershipDAO;
    private final ShipperTripDAO shipperTripDAO;

    public OrderService() {
        this.orderDAO = new OrderDAO();
        this.membershipDAO = new MembershipDAO();
        this.shipperTripDAO = new ShipperTripDAO();
    }

    /**
     * Cập nhật trạng thái đơn hàng, tự động gán shipper và xử lý cộng/trừ điểm tích lũy
     *
     * @param orderNo     Mã đơn hàng
     * @param newStatus   Trạng thái mới cần chuyển sang
     * @param shipperNote Ghi chú của shipper (có thể null nếu không phải shipper)
     * @return boolean true nếu cập nhật thành công
     */
    public boolean updateOrderStatus(String orderNo, String newStatus, String shipperNote) {
        Order currentOrder = orderDAO.getOrderByNo(orderNo);
        if (currentOrder == null) {
            return false;
        }

        String currentStatus = currentOrder.getOrderStatus();
        boolean success;

        // Cập nhật Database
        if (shipperNote != null && !shipperNote.trim().isEmpty()) {
            success = orderDAO.updateOrderStatusWithNote(orderNo, newStatus, shipperNote.trim());
        } else {
            success = orderDAO.updateOrderStatus(orderNo, newStatus);
        }

        if (success) {
            // Logic 1: Auto Assign Shipper nếu chuyển sang WAITING_DELIVERY
            if (Order.STATUS_WAITING_DELIVERY.equals(newStatus)) {
                shipperTripDAO.autoAssignShipperAndTrip(orderNo);
            }

            // Logic 2: Xử lý cộng / trừ điểm cho khách hàng
            handlePointAccumulation(currentOrder, currentStatus, newStatus);
        }

        return success;
    }

    private void handlePointAccumulation(Order order, String currentStatus, String newStatus) {
        // Chỉ xử lý nếu trạng thái có liên quan đến COMPLETED
        boolean wasCompleted = Order.STATUS_COMPLETED.equalsIgnoreCase(currentStatus);
        boolean isNowCompleted = Order.STATUS_COMPLETED.equalsIgnoreCase(newStatus);
        boolean isNowCancelled = Order.STATUS_CANCELLED.equalsIgnoreCase(newStatus) || "Canceled".equalsIgnoreCase(newStatus);

        if ((!wasCompleted && isNowCompleted) || (wasCompleted && isNowCancelled)) {
            // Tính tổng tiền sản phẩm thực tế
            BigDecimal productTotal = BigDecimal.ZERO;
            if (order.getItems() != null) {
                for (OrderItem item : order.getItems()) {
                    BigDecimal price = item.getPriceAtPurchase() != null ? item.getPriceAtPurchase() : BigDecimal.ZERO;
                    BigDecimal quantity = new BigDecimal(item.getQuantity());
                    productTotal = productTotal.add(price.multiply(quantity));
                }
            }

            // Trừ đi voucher đơn hàng (nếu có)
            BigDecimal orderDiscount = order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO;
            BigDecimal eligibleAmount = productTotal.subtract(orderDiscount);

            if (eligibleAmount.compareTo(BigDecimal.ZERO) < 0) {
                eligibleAmount = BigDecimal.ZERO;
            }

            // Lấy hệ số điểm từ tier hiện tại của người dùng
            double pointMultiplier = 1.0;
            UserMembership um = membershipDAO.getMembershipByUserId(order.getCustomerId());
            if (um != null && um.getCurrentTier() != null) {
                pointMultiplier = um.getCurrentTier().getPointMultiplier();
            }

            // Tính số điểm: Cứ 1000đ = 1 điểm (làm tròn xuống)
            int basePoints = eligibleAmount.divide(new BigDecimal(1000), 0, RoundingMode.DOWN).intValue();
            int points = (int) Math.floor(basePoints * pointMultiplier);

            if (points > 0 || eligibleAmount.compareTo(BigDecimal.ZERO) > 0) {
                if (!wasCompleted && isNowCompleted) {
                    // Cộng điểm & chi tiêu
                    if (points > 0) membershipDAO.adjustPoints(order.getCustomerId(), points, "Tích điểm từ đơn hàng #" + order.getOrderNo());
                    if (eligibleAmount.compareTo(BigDecimal.ZERO) > 0) membershipDAO.adjustTotalSpending(order.getCustomerId(), eligibleAmount);
                } else if (wasCompleted && isNowCancelled) {
                    // Trừ điểm & chi tiêu
                    if (points > 0) membershipDAO.adjustPoints(order.getCustomerId(), -points, "Hoàn điểm do đơn hàng #" + order.getOrderNo() + " bị hủy sau khi đã hoàn thành");
                    if (eligibleAmount.compareTo(BigDecimal.ZERO) > 0) membershipDAO.adjustTotalSpending(order.getCustomerId(), eligibleAmount.negate());
                }
            }
        }
    }
}
