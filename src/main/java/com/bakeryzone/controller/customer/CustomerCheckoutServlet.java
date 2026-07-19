package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.DeliveryAddressDAO;
import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.model.DeliveryAddress;
import com.bakeryzone.model.Order;
import com.bakeryzone.model.OrderItem;
import com.bakeryzone.model.User;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;

public class CustomerCheckoutServlet extends HttpServlet {

    private final DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Redirect to login if user is not authenticated
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Retrieve customer's saved delivery addresses
        List<DeliveryAddress> addressList = addressDAO.getAddressesByUserId(currentUser.getUserId());
        request.setAttribute("addressList", addressList);

        // Determine selected address
        DeliveryAddress selectedAddress = null;
        if (addressList != null && !addressList.isEmpty()) {
            String selectedParam = request.getParameter("selectedAddressId");
            selectedAddress = addressList.stream()
                .filter(addr -> String.valueOf(addr.getAddressId()).equals(selectedParam))
                .findFirst()
                .orElse(addressList.stream()
                    .filter(DeliveryAddress::isDefault)
                    .findFirst()
                    .orElse(addressList.get(0)));
        }
        request.setAttribute("selectedAddress", selectedAddress);

        // Fetch voucher discount from session
        BigDecimal appliedDiscount = (BigDecimal) session.getAttribute("appliedDiscount");
        String appliedVoucherCode = (String) session.getAttribute("appliedVoucherCode");
        
        request.setAttribute("checkoutDiscount", appliedDiscount != null ? appliedDiscount : BigDecimal.ZERO);
        request.setAttribute("checkoutVoucherCode", appliedVoucherCode);

        // Forward to the checkout page
        request.getRequestDispatcher("/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Đảm bảo chỉ khách hàng mới được checkout đặt hàng
        if (!"CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/checkout?error=admin_cannot_order");
            return;
        }

        try {
            // 1. Parse form parameters
            String addressIdRaw  = request.getParameter("addressId");
            String timeSlot      = request.getParameter("timeSlot");
            String deliveryDate  = request.getParameter("deliveryDate");
            String note          = request.getParameter("note");
            String cartDataJson  = request.getParameter("cartData");
            String paymentMethod = request.getParameter("paymentMethod");
            String shippingFeeStr = request.getParameter("shippingFee");

            // 2. Validate ghi chú đơn hàng (Note length check)
            if (note != null && note.length() > 500) {
                response.sendRedirect(request.getContextPath() + "/checkout?error=note_too_long");
                return;
            }

            // 3. Resolve delivery address string
            String deliveryAddressStr = resolveDeliveryAddress(addressIdRaw, currentUser.getUserId());
            if (deliveryAddressStr == null) {
                response.sendRedirect(request.getContextPath() + "/checkout?error=empty_address");
                return;
            }

            // 4. Build base order object
            Order order = new Order();
            String orderNo = "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            order.setOrderNo(orderNo);
            order.setCustomerId(orderDAO.getCustomerIdByUserId(currentUser.getUserId()));
            order.setOrderTime(new Timestamp(System.currentTimeMillis()));
            order.setDeliveryAddress(deliveryAddressStr);
            order.setOrderStatus("Pending");
            order.setCustomerNote(note);
            order.setPaymentMethod(paymentMethod);
            
            setDeliveryWindow(order, deliveryDate, timeSlot);

            // 5. Parse cart JSON to OrderItem list
            BigDecimal productTotal = parseCartItemsAndGetTotal(order, cartDataJson);
            if (order.getItems().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/checkout?error=empty_cart");
                return;
            }

            // 6. Calculate totals
            calculateAndSetTotals(order, productTotal, shippingFeeStr, paymentMethod, session);

            // 7. Persist order
            boolean success = orderDAO.insertOrder(order);
            if (success) {
                handleSuccessfulOrder(session, currentUser.getUserId(), paymentMethod, orderNo, order.getTotalCost(), response, request.getContextPath());
            } else {
                response.sendRedirect(request.getContextPath() + "/checkout?error=save_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/checkout?error=server_error");
        }
    }

    private String resolveDeliveryAddress(String addressIdRaw, String userId) {
        if (addressIdRaw != null && !addressIdRaw.trim().isEmpty()) {
            try {
                int addressId = Integer.parseInt(addressIdRaw.trim());
                DeliveryAddress addr = addressDAO.getAddressById(addressId, userId);
                if (addr != null) {
                    return addr.getReceiverName() + " | " + addr.getReceiverPhone() + " | " + addr.getAddressDetail();
                }
            } catch (NumberFormatException ignored) {}
        }
        return null;
    }

    private void setDeliveryWindow(Order order, String deliveryDate, String timeSlot) {
        Timestamp deliveryWindowStart = null;
        Timestamp deliveryWindowEnd   = null;

        if (deliveryDate != null && !deliveryDate.trim().isEmpty() && timeSlot != null && !timeSlot.trim().isEmpty()) {
            try {
                String[] parts = timeSlot.split("-");
                String startTime = parts[0].trim();
                String endTime   = parts[1].trim();

                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                deliveryWindowStart = new Timestamp(sdf.parse(deliveryDate + " " + startTime).getTime());
                deliveryWindowEnd   = new Timestamp(sdf.parse(deliveryDate + " " + endTime).getTime());
            } catch (Exception e) {
                System.err.println("[WARN] Failed to parse delivery date/time: " + e.getMessage());
            }
        }
        
        if (deliveryWindowStart == null || deliveryWindowEnd == null) {
            long tomorrow = System.currentTimeMillis() + 24L * 3600 * 1000;
            deliveryWindowStart = new Timestamp(tomorrow);
            deliveryWindowEnd = new Timestamp(tomorrow + 2L * 3600 * 1000);
        }
        
        order.setDeliveryWindowStart(deliveryWindowStart);
        order.setDeliveryWindowEnd(deliveryWindowEnd);
    }

    private BigDecimal parseCartItemsAndGetTotal(Order order, String cartDataJson) {
        BigDecimal productTotal = BigDecimal.ZERO;
        if (cartDataJson != null && !cartDataJson.trim().isEmpty() && !cartDataJson.equals("[]")) {
            JsonArray cartArray = JsonParser.parseString(cartDataJson).getAsJsonArray();
            for (JsonElement el : cartArray) {
                if (el.isJsonNull()) continue;
                JsonObject cartItem = el.getAsJsonObject();

                String itemId     = getStr(cartItem, "id");
                String itemName   = getStr(cartItem, "name");
                String itemImage  = getStr(cartItem, "image");
                String templateId = getStr(cartItem, "templateId");
                double price      = cartItem.has("price") ? cartItem.get("price").getAsDouble() : 0;
                int qty           = cartItem.has("qty")   ? cartItem.get("qty").getAsInt()   : 1;

                BigDecimal itemPrice = BigDecimal.valueOf(price);
                productTotal = productTotal.add(itemPrice.multiply(BigDecimal.valueOf(qty)));

                OrderItem oi = new OrderItem();
                oi.setQuantity(qty);
                oi.setPriceAtPurchase(itemPrice);
                oi.setItemName(itemName);
                oi.setItemImage(itemImage);
                oi.setTemplateId(templateId);

                if (templateId != null && !templateId.isEmpty()) {
                    oi.setCustomCakeId("CAKE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
                    oi.setAccessoryId(null);
                } else if (itemId != null && itemId.startsWith("ACC-")) {
                    oi.setAccessoryId(itemId);
                    oi.setCustomCakeId(null);
                } else {
                    oi.setAccessoryId(null);
                    oi.setCustomCakeId("CAKE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
                    oi.setTemplateId(itemId);
                }
                order.getItems().add(oi);
            }
        }
        return productTotal;
    }

    private void calculateAndSetTotals(Order order, BigDecimal productTotal, String shippingFeeStr, String paymentMethod, HttpSession session) {
        BigDecimal shippingFee = BigDecimal.valueOf(25000);
        if (shippingFeeStr != null && !shippingFeeStr.trim().isEmpty()) {
            try {
                shippingFee = new BigDecimal(shippingFeeStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        BigDecimal appliedDiscount = (BigDecimal) session.getAttribute("appliedDiscount");
        if (appliedDiscount == null) appliedDiscount = BigDecimal.ZERO;
        
        BigDecimal totalCost = productTotal.add(shippingFee).subtract(appliedDiscount);
        if (totalCost.compareTo(BigDecimal.ZERO) < 0) totalCost = BigDecimal.ZERO;
        
        BigDecimal deposit = BigDecimal.ZERO;
        BigDecimal remainingCod = totalCost;

        if ("BANK_TRANSFER_FULL".equals(paymentMethod)) {
            deposit = totalCost;
            remainingCod = BigDecimal.ZERO;
        } else {
            deposit = totalCost.multiply(BigDecimal.valueOf(0.3)).setScale(0, java.math.RoundingMode.HALF_UP);
            remainingCod = totalCost.subtract(deposit);
        }

        order.setTotalCost(totalCost);
        order.setDepositAmount(deposit);
        order.setRemainingCodBalance(remainingCod);
        order.setShippingFee(shippingFee);
    }

    private void handleSuccessfulOrder(HttpSession session, String userId, String paymentMethod, String orderNo, BigDecimal totalCost, HttpServletResponse response, String contextPath) throws IOException {
        Integer appliedVoucherId = (Integer) session.getAttribute("appliedVoucherId");
        if (appliedVoucherId != null) {
            voucherDAO.markVoucherUsed(appliedVoucherId, userId);
            session.removeAttribute("appliedVoucherId");
            session.removeAttribute("appliedVoucherCode");
            session.removeAttribute("appliedDiscount");
        }

        if ("BANK_TRANSFER_FULL".equals(paymentMethod)) {
            String totalEncoded = java.net.URLEncoder.encode(totalCost.toPlainString(), "UTF-8");
            response.sendRedirect(contextPath + "/bank-transfer?orderNo=" + orderNo + "&total=" + totalEncoded);
        } else {
            response.sendRedirect(contextPath + "/order-success?orderNo=" + orderNo);
        }
    }

    /** Safely get a String field from a JsonObject, returns null if missing/null */
    private String getStr(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }
}
