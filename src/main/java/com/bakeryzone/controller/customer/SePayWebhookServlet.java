package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.model.Order;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/sepay-webhook")
public class SePayWebhookServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Read JSON payload from request body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        
        String jsonStr = sb.toString();
        if (jsonStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Empty request body");
            return;
        }

        try {
            // 2. Parse JSON
            JsonObject payload = JsonParser.parseString(jsonStr).getAsJsonObject();
            
            String transferType = payload.has("transferType") && !payload.get("transferType").isJsonNull() 
                                  ? payload.get("transferType").getAsString() : "";
            
            // Only process incoming transfers
            if (!"in".equalsIgnoreCase(transferType)) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Not an incoming transfer. Ignored.");
                return;
            }

            long transferAmount = payload.has("transferAmount") && !payload.get("transferAmount").isJsonNull() 
                                  ? payload.get("transferAmount").getAsLong() : 0;
            
            String content = payload.has("content") && !payload.get("content").isJsonNull() 
                             ? payload.get("content").getAsString() : "";
            
            // 3. Extract Order No from transfer content
            // Assuming order number format is ORD- followed by alphanumeric characters
            String orderNo = extractOrderNo(content);
            
            if (orderNo == null || orderNo.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("No order number found in content.");
                return;
            }
            
            // 4. Verify order and update status
            Order order = orderDAO.getOrderByNo(orderNo);
            if (order != null) {
                // Determine expected amount (Total or Deposit)
                BigDecimal expectedAmount = order.getTotalCost();
                if (!"BANK_TRANSFER_FULL".equals(order.getPaymentMethod()) && order.getDepositAmount() != null) {
                    expectedAmount = order.getDepositAmount();
                }
                
                // If transfer amount matches or exceeds expected amount
                if (BigDecimal.valueOf(transferAmount).compareTo(expectedAmount) >= 0) {
                    boolean success = orderDAO.updateOrderStatus(orderNo, "PAID");
                    if (success) {
                        System.out.println("[SePay] Order " + orderNo + " successfully marked as PAID via webhook.");
                        
                        // Tự động phân công shipper và gom chuyến
                        try {
                            orderDAO.autoAssignShipperAndTrip(orderNo);
                        } catch (Exception e) {
                            System.err.println("[SePay] Lỗi tự động gán shipper: " + e.getMessage());
                        }
                        
                        response.setContentType("application/json");
                        response.setStatus(HttpServletResponse.SC_OK);
                        response.getWriter().write("{\"success\":true,\"message\":\"Order status updated\"}");
                        return;
                    }
                } else {
                    System.out.println("[SePay] Order " + orderNo + " received insufficient amount: " + transferAmount + " < " + expectedAmount);
                }
            } else {
                System.out.println("[SePay] Order " + orderNo + " not found.");
            }
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("Processed.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Internal server error: " + e.getMessage());
        }
    }
    
    private String extractOrderNo(String content) {
        if (content == null || content.isEmpty()) return null;
        // Hỗ trợ cả trường hợp có hoặc không có dấu gạch ngang (ví dụ: ORD-BA82EE91 hoặc ORDBA82EE91)
        Pattern pattern = Pattern.compile("(ORD-?[A-Z0-9]+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            String rawOrderNo = matcher.group(1).toUpperCase();
            // Nếu không có dấu gạch ngang, tự động thêm dấu gạch ngang sau 'ORD'
            if (rawOrderNo.startsWith("ORD") && !rawOrderNo.startsWith("ORD-") && rawOrderNo.length() > 3) {
                return "ORD-" + rawOrderNo.substring(3);
            }
            return rawOrderNo;
        }
        return null;
    }
}
