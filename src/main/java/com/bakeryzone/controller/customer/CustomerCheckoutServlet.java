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

        // Fetch selected cart items from DB
        com.bakeryzone.dao.CartDAO cartDAO = new com.bakeryzone.dao.CartDAO();
        List<com.bakeryzone.model.CartItemDTO> allCartItems = cartDAO.getCartItemsForUser(currentUser.getUserId());
        List<com.bakeryzone.model.CartItemDTO> checkoutCartItems = new java.util.ArrayList<>();
        BigDecimal productTotalSum = BigDecimal.ZERO;

        @SuppressWarnings("unchecked")
        List<String> checkoutSelectedItems = (List<String>) session.getAttribute("checkoutSelectedItems");
        
        if (checkoutSelectedItems != null && allCartItems != null) {
            for (com.bakeryzone.model.CartItemDTO item : allCartItems) {
                if (item.isActive() && checkoutSelectedItems.contains(item.getCartItemId())) {
                    checkoutCartItems.add(item);
                    if (item.getUnitPrice() != null) {
                        productTotalSum = productTotalSum.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
                    }
                }
            }
        }
        request.setAttribute("checkoutCartItems", checkoutCartItems);
        request.setAttribute("productTotalSum", productTotalSum);

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
        String appliedOrderVoucherCode = (String) session.getAttribute("appliedOrderVoucherCode");
        BigDecimal calculatedOrderDiscount = BigDecimal.ZERO;
        
        if (appliedOrderVoucherCode != null) {
            com.bakeryzone.model.Voucher orderVoucher = voucherDAO.getVoucherByCodeAndUser(appliedOrderVoucherCode, currentUser.getUserId());
            if (orderVoucher != null) {
                // Ensure order meets minimum
                BigDecimal minOrder = orderVoucher.getMinOrderValue() != null ? orderVoucher.getMinOrderValue() : BigDecimal.ZERO;
                if (productTotalSum.compareTo(minOrder) >= 0) {
                    boolean isPercentage = "PERCENT".equalsIgnoreCase(orderVoucher.getDiscountType()) || "PERCENTAGE".equalsIgnoreCase(orderVoucher.getDiscountType());
                    if (isPercentage) {
                        calculatedOrderDiscount = productTotalSum.multiply(orderVoucher.getDiscountValue()).divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                        if (orderVoucher.getMaxDiscountAmount() != null && orderVoucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                            calculatedOrderDiscount = calculatedOrderDiscount.min(orderVoucher.getMaxDiscountAmount());
                        }
                    } else {
                        calculatedOrderDiscount = orderVoucher.getDiscountValue();
                    }
                    calculatedOrderDiscount = calculatedOrderDiscount.min(productTotalSum);
                } else {
                    // Invalidated by deselecting items
                    appliedOrderVoucherCode = null;
                }
            }
        }
        
        request.setAttribute("checkoutOrderDiscount", calculatedOrderDiscount);
        request.setAttribute("checkoutOrderVoucherCode", appliedOrderVoucherCode);

        String appliedShippingVoucherCode = (String) session.getAttribute("appliedShippingVoucherCode");
        request.setAttribute("checkoutShippingVoucherCode", appliedShippingVoucherCode);
        
        if (appliedShippingVoucherCode != null) {
            com.bakeryzone.model.Voucher shippingVoucher = voucherDAO.getVoucherByCodeAndUser(appliedShippingVoucherCode, currentUser.getUserId());
            if (shippingVoucher != null) {
                request.setAttribute("shippingVoucherType", shippingVoucher.getDiscountType());
                request.setAttribute("shippingVoucherValue", shippingVoucher.getDiscountValue());
                request.setAttribute("shippingVoucherMax", shippingVoucher.getMaxDiscountAmount() != null ? shippingVoucher.getMaxDiscountAmount() : BigDecimal.ZERO);
            }
        }

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

        if (!"CUSTOMER".equalsIgnoreCase(currentUser.getRoleId())) {
            response.sendRedirect(request.getContextPath() + "/checkout?error=admin_cannot_order");
            return;
        }

        String action = request.getParameter("action");
        if ("applyVoucherAjax".equals(action)) {
            handleApplyVoucherAjax(request, response, currentUser.getUserId());
            return;
        }

        try {
            // ── 1. Fetch parameters ────────────────────────────────────────────────
            String addressIdRaw  = request.getParameter("addressId");
            String timeSlot      = request.getParameter("timeSlot");   // e.g. "08:00 - 09:00"
            String deliveryDate  = request.getParameter("deliveryDate"); // e.g. "2026-06-19"
            String note          = request.getParameter("note");
            String cartDataJson  = request.getParameter("cartData");    // JSON array from localStorage
            String paymentMethod = request.getParameter("paymentMethod"); // e.g. "BANK_TRANSFER_FULL" or "DIRECT_DEPOSIT_20"
            String appliedOrderVoucherCode = request.getParameter("appliedOrderVoucherCode");
            String appliedShippingVoucherCode = request.getParameter("appliedShippingVoucherCode");
            
            if (note != null) {
                note = note.trim();
                if (note.length() > 100) {
                    response.sendRedirect(request.getContextPath() + "/checkout?error=note_too_long");
                    return;
                }
            }
            // ── 2. Resolve delivery address string ─────────────────────────────────
            String deliveryAddressStr = null;
            if (addressIdRaw != null && !addressIdRaw.trim().isEmpty()) {
                try {
                    int addressId = Integer.parseInt(addressIdRaw.trim());
                    DeliveryAddress addr = addressDAO.getAddressById(addressId, currentUser.getUserId());
                    if (addr != null) {
                        deliveryAddressStr = addr.getReceiverName()
                                + " | " + addr.getReceiverPhone()
                                + " | " + addr.getAddressDetail();
                    }
                } catch (NumberFormatException ignored) {}
            }

            if (deliveryAddressStr == null) {
                response.sendRedirect(request.getContextPath() + "/checkout?error=empty_address");
                return;
            }

            // ── 3. Build Delivery Window timestamps ────────────────────────────────
            // timeSlot format: "HH:mm - HH:mm"
            Timestamp deliveryWindowStart = null;
            Timestamp deliveryWindowEnd   = null;
            Timestamp orderTime           = new Timestamp(System.currentTimeMillis());

            if (deliveryDate != null && !deliveryDate.trim().isEmpty()
                    && timeSlot != null && !timeSlot.trim().isEmpty()) {
                try {
                    String[] parts = timeSlot.split("-");
                    String startTime = parts[0].trim(); // e.g. "08:00"
                    String endTime   = parts[1].trim(); // e.g. "09:00"

                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                    Date startDate = sdf.parse(deliveryDate + " " + startTime);
                    Date endDate   = sdf.parse(deliveryDate + " " + endTime);
                    deliveryWindowStart = new Timestamp(startDate.getTime());
                    deliveryWindowEnd   = new Timestamp(endDate.getTime());
                } catch (Exception e) {
                    System.err.println("[WARN] Failed to parse delivery date/time: " + e.getMessage());
                }
            }
            
            // Fallback for missing delivery date/time to avoid DB NOT NULL constraint error
            if (deliveryWindowStart == null || deliveryWindowEnd == null) {
                long tomorrow = System.currentTimeMillis() + 24L * 3600 * 1000;
                deliveryWindowStart = new Timestamp(tomorrow);
                deliveryWindowEnd = new Timestamp(tomorrow + 2L * 3600 * 1000);
            }

            // ── 4. Parse cart JSON to OrderItem list ───────────────────────────────
            // Cart item shape (from localStorage): { id, name, price, qty, image, desc, templateId? }
            Order order = new Order();
            String orderNo = "ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            order.setOrderNo(orderNo);
            String customerId = orderDAO.getCustomerIdByUserId(currentUser.getUserId());
            order.setCustomerId(customerId);
            order.setOrderTime(orderTime);
            order.setDeliveryWindowStart(deliveryWindowStart);
            order.setDeliveryWindowEnd(deliveryWindowEnd);
            order.setDeliveryAddress(deliveryAddressStr);
            order.setOrderStatus("Pending");

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
                        // It's a cake template → create custom_cake entry
                        String cakeId = "CAKE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
                        oi.setCustomCakeId(cakeId);
                        oi.setAccessoryId(null);
                    } else if (itemId != null && itemId.startsWith("ACC-")) {
                        // It's an accessory
                        oi.setAccessoryId(itemId);
                        oi.setCustomCakeId(null);
                    } else {
                        // Generic product → treat as accessory link (safe default)
                        oi.setAccessoryId(null);
                        oi.setCustomCakeId(null);
                        if (templateId == null || templateId.isEmpty()) {
                            // Create custom_cake with item id as template ref
                            String cakeId = "CAKE-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
                            oi.setCustomCakeId(cakeId);
                            oi.setTemplateId(itemId); // Use product id as template ref
                        }
                    }

                    order.getItems().add(oi);
                }
            }

if (order.getItems().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/checkout?error=empty_cart");
                return;
            }

            // 1. Resolve Shipping Fee (Parse from request, fallback to 25k default if missing)
            String shippingFeeStr = request.getParameter("shippingFee");
            BigDecimal shippingFee = BigDecimal.valueOf(25000); // Default fallback
            if (shippingFeeStr != null && !shippingFeeStr.trim().isEmpty()) {
                try {
                    shippingFee = new BigDecimal(shippingFeeStr.trim());
                } catch (NumberFormatException e) {
                    // Keep default 25000 if parsing fails
                }
            }

            // 2. Extract and Apply Voucher Discount securely on the server
            BigDecimal appliedOrderDiscount = BigDecimal.ZERO;
            com.bakeryzone.model.Voucher orderVoucher = null;
            if (appliedOrderVoucherCode != null && !appliedOrderVoucherCode.trim().isEmpty()) {
                orderVoucher = voucherDAO.getVoucherByCodeAndUser(appliedOrderVoucherCode, currentUser.getUserId());
                if (orderVoucher != null && "ORDER".equalsIgnoreCase(orderVoucher.getVoucherScope())) {
                    BigDecimal minOrder = orderVoucher.getMinOrderValue() != null ? orderVoucher.getMinOrderValue() : BigDecimal.ZERO;
                    if (productTotal.compareTo(minOrder) >= 0) {
                        boolean isPercentage = "PERCENT".equalsIgnoreCase(orderVoucher.getDiscountType()) 
                                            || "PERCENTAGE".equalsIgnoreCase(orderVoucher.getDiscountType());
                        if (isPercentage) {
                            appliedOrderDiscount = productTotal.multiply(orderVoucher.getDiscountValue())
                                                    .divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                            if (orderVoucher.getMaxDiscountAmount() != null && orderVoucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                                appliedOrderDiscount = appliedOrderDiscount.min(orderVoucher.getMaxDiscountAmount());
                            }
                        } else {
                            appliedOrderDiscount = orderVoucher.getDiscountValue();
                        }
                        appliedOrderDiscount = appliedOrderDiscount.min(productTotal);
                    }
                }
            }

            BigDecimal appliedShippingDiscount = BigDecimal.ZERO;
            com.bakeryzone.model.Voucher shippingVoucher = null;
            if (appliedShippingVoucherCode != null && !appliedShippingVoucherCode.trim().isEmpty()) {
                shippingVoucher = voucherDAO.getVoucherByCodeAndUser(appliedShippingVoucherCode, currentUser.getUserId());
                if (shippingVoucher != null && "SHIPPING".equalsIgnoreCase(shippingVoucher.getVoucherScope())) {
                    BigDecimal minOrder = shippingVoucher.getMinOrderValue() != null ? shippingVoucher.getMinOrderValue() : BigDecimal.ZERO;
                    if (productTotal.compareTo(minOrder) >= 0) {
                        boolean isPercentage = "PERCENT".equalsIgnoreCase(shippingVoucher.getDiscountType()) 
                                            || "PERCENTAGE".equalsIgnoreCase(shippingVoucher.getDiscountType());
                        if (isPercentage) {
                            appliedShippingDiscount = shippingFee.multiply(shippingVoucher.getDiscountValue())
                                                    .divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                            if (shippingVoucher.getMaxDiscountAmount() != null && shippingVoucher.getMaxDiscountAmount().compareTo(BigDecimal.ZERO) > 0) {
                                appliedShippingDiscount = appliedShippingDiscount.min(shippingVoucher.getMaxDiscountAmount());
                            }
                        } else {
                            appliedShippingDiscount = shippingVoucher.getDiscountValue();
                        }
                        appliedShippingDiscount = appliedShippingDiscount.min(shippingFee);
                    }
                }
            }
            
            // 3. Compute Final Total Cost
            BigDecimal finalShippingFee = shippingFee.subtract(appliedShippingDiscount);
            BigDecimal totalCost = productTotal.add(finalShippingFee).subtract(appliedOrderDiscount);
            if (totalCost.compareTo(BigDecimal.ZERO) < 0) {
                totalCost = BigDecimal.ZERO;
            }
            
            // 4. Determine Deposit and COD Splits based on Payment Method
            BigDecimal deposit = BigDecimal.ZERO;
            BigDecimal remainingCod = totalCost;

            if ("BANK_TRANSFER_FULL".equals(paymentMethod)) {
                deposit = totalCost; // Full upfront bank transfer
                remainingCod = BigDecimal.ZERO;
            } else {
                // Default COD: Calculate a standard 30% upfront commitment deposit
                deposit = totalCost.multiply(BigDecimal.valueOf(0.3)).setScale(0, java.math.RoundingMode.HALF_UP);
                remainingCod = totalCost.subtract(deposit);
            }

            order.setTotalCost(totalCost);
            order.setDepositAmount(deposit);
            order.setRemainingCodBalance(remainingCod);
            order.setShippingFee(shippingFee);
            order.setPaymentMethod(paymentMethod);
            order.setCustomerNote(note);

            // ── 5. Persist order ───────────────────────────────────────────────────
            System.out.println("[INFO] Attempting to place order: " + orderNo 
                    + " for customerId: " + order.getCustomerId() 
                    + " | deliveryWindow: " + order.getDeliveryWindowStart()
                    + " | cart items size: " + order.getItems().size());
            
            boolean success = orderDAO.insertOrder(order);

            System.out.println("[INFO] Order placed: " + orderNo + " by user " + currentUser.getUserId()
                    + " | success=" + success + " | total=" + totalCost);

            if (success) {
                // Mark voucher as used if applicable and clear session attributes
                if (orderVoucher != null) {
                    voucherDAO.markVoucherUsed(orderVoucher.getVoucherId(), currentUser.getUserId());
                }
                if (shippingVoucher != null) {
                    voucherDAO.markVoucherUsed(shippingVoucher.getVoucherId(), currentUser.getUserId());
                }

                session.removeAttribute("appliedOrderVoucherId");
                session.removeAttribute("appliedOrderVoucherCode");
                session.removeAttribute("appliedOrderDiscount");
                session.removeAttribute("appliedShippingVoucherId");
                session.removeAttribute("appliedShippingVoucherCode");

                // Redirect to bank transfer if there is any deposit required (Full transfer or 30% COD deposit)
                if (deposit.compareTo(BigDecimal.ZERO) > 0) {
                    String depositEncoded = java.net.URLEncoder.encode(deposit.toPlainString(), "UTF-8");
                    response.sendRedirect(request.getContextPath() + "/bank-transfer?orderNo=" + orderNo + "&total=" + depositEncoded);
                } else {
                    response.sendRedirect(request.getContextPath() + "/order-success?orderNo=" + orderNo);
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/checkout?error=save_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/checkout?error=server_error");
        }
    }

    private void handleApplyVoucherAjax(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {
        String voucherCode = request.getParameter("voucherCode");
        String subtotalStr = request.getParameter("subtotal");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            response.getWriter().write("{\"success\": false, \"error\": \"Vui lòng nhập mã voucher.\"}");
            return;
        }
        
        BigDecimal subtotal = BigDecimal.ZERO;
        if (subtotalStr != null && !subtotalStr.trim().isEmpty()) {
            try {
                subtotal = new BigDecimal(subtotalStr.trim());
            } catch (Exception e) {}
        }
        
        com.bakeryzone.model.Voucher v = voucherDAO.getVoucherByCodeAndUser(voucherCode.trim(), userId);
        if (v == null) {
            response.getWriter().write("{\"success\": false, \"error\": \"Mã giảm giá không hợp lệ hoặc đã hết hạn.\"}");
            return;
        }
        
        BigDecimal minOrder = v.getMinOrderValue() != null ? v.getMinOrderValue() : BigDecimal.ZERO;
        if (subtotal.compareTo(minOrder) < 0) {
            response.getWriter().write("{\"success\": false, \"error\": \"Chưa đạt giá trị đơn tối thiểu: " + minOrder.longValue() + "đ\"}");
            return;
        }
        
        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("code", v.getVoucherCode());
        json.addProperty("scope", v.getVoucherScope());
        json.addProperty("discountType", v.getDiscountType());
        json.addProperty("discountValue", v.getDiscountValue().doubleValue());
        json.addProperty("maxDiscount", v.getMaxDiscountAmount() != null ? v.getMaxDiscountAmount().doubleValue() : 0);
        
        response.getWriter().write(json.toString());
    }

    /** Safely get a String field from a JsonObject, returns null if missing/null */
    private String getStr(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }
}
