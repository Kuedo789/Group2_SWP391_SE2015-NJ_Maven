package com.bakeryzone.service;

import com.bakeryzone.dao.OrderDAO;
import com.bakeryzone.dao.ShipperTripDAO;
import com.bakeryzone.model.Order;
import com.bakeryzone.utils.DBContext;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AutoAssignService {

    private static final OrderDAO orderDAO = new OrderDAO();
    private static final ShipperTripDAO shipperTripDAO = new ShipperTripDAO();
    private static final double[] SHOP_COORDS = new double[]{10.7769, 106.7009}; // Shop Coordinates
    private static final int MAX_BATCH_LIMIT = 3;
    private static final double MAX_ROUTE_DIVERSION_KM = 3.0;

    /**
     * Smart Auto-Assignment Algorithm with Fallbacks & Routing Batching
     */
    public static boolean assignShipperToOrder(Order order) {
        if (order == null) {
            return false;
        }

        String orderNo = order.getOrderNo();
        System.out.println("[AutoAssignService] Triggered assignment for Order: " + orderNo);

        // Fetch coordinates for the order delivery address
        double[] orderCoords = shipperTripDAO.getOrderCoordinates(orderNo);
        if (orderCoords == null) {
            System.out.println("[AutoAssignService] WARNING: Coordinates not found for Order " + orderNo + ". Using shop default coordinates.");
            orderCoords = SHOP_COORDS;
        }

        // 1. Fetch all online/active shippers
        List<Map<String, String>> activeShippers = getActiveShippers();
        if (activeShippers.isEmpty()) {
            System.err.println("[ALERT] No active shippers online! Order " + orderNo + " remains in Waiting_Delivery for manual assignment.");
            return false;
        }

        // 2. Detect the order's delivery zone
        String orderZone = getZoneFromAddress(order.getDeliveryAddress());
        System.out.println("[AutoAssignService] Order zone detected: " + (orderZone != null ? orderZone : "Unassigned/Out-of-zone"));

        // 3. Exact Zone Matching
        List<Map<String, String>> exactMatchShippers = new ArrayList<>();
        if (orderZone != null) {
            for (Map<String, String> sh : activeShippers) {
                String managedZone = sh.get("zone");
                if (managedZone != null && managedZone.toLowerCase().contains(orderZone.toLowerCase())) {
                    exactMatchShippers.add(sh);
                }
            }
        }

        // STEP 1 & 2: Exact Zone Match and check for batching or load balancing
        if (!exactMatchShippers.isEmpty()) {
            System.out.println("[AutoAssignService] Found " + exactMatchShippers.size() + " exact zone shippers.");
            
            // Try to batch into an active trip first
            String bestTripId = findBestBatchTrip(exactMatchShippers, orderCoords);
            if (bestTripId != null) {
                System.out.println("[AutoAssignService] Batching order " + orderNo + " to active Trip: " + bestTripId);
                return shipperTripDAO.updateOrderTrip(orderNo, bestTripId);
            }

            // Fallback to load balancing: Pick shipper with fewest active orders
            String bestShipperId = pickLowestWorkloadShipper(exactMatchShippers);
            if (bestShipperId != null) {
                String newTripId = shipperTripDAO.createNewDeliveryTrip(bestShipperId);
                if (newTripId != null) {
                    System.out.println("[AutoAssignService] Created new Trip " + newTripId + " for exact shipper: " + bestShipperId);
                    return shipperTripDAO.updateOrderTrip(orderNo, newTripId);
                }
            }
        }

        // STEP 3: Fallback for Out-of-Zone / Unassigned or when no exact matching shipper is online
        System.out.println("[AutoAssignService] No exact match shipper trip assigned. Running fallback strategy.");

        // Fallback Step 3a: Try to batch/pool with ANY active shipper's trip system-wide (Adjacent Zone Batching)
        String fallbackTripId = findBestBatchTrip(activeShippers, orderCoords);
        if (fallbackTripId != null) {
            System.out.println("[AutoAssignService] Batching order " + orderNo + " to fallback active Trip: " + fallbackTripId);
            return shipperTripDAO.updateOrderTrip(orderNo, fallbackTripId);
        }

        // Fallback Step 3b: Pick Central/Main Store Shippers (zone contains "Central", "Main Store", or "Toàn thành phố")
        List<Map<String, String>> centralShippers = new ArrayList<>();
        for (Map<String, String> sh : activeShippers) {
            String managedZone = sh.get("zone");
            if (managedZone != null && (
                    managedZone.toLowerCase().contains("central") ||
                    managedZone.toLowerCase().contains("main store") ||
                    managedZone.toLowerCase().contains("toàn thành phố")
            )) {
                centralShippers.add(sh);
            }
        }

        if (!centralShippers.isEmpty()) {
            String bestCentralShipperId = pickLowestWorkloadShipper(centralShippers);
            if (bestCentralShipperId != null) {
                String newTripId = shipperTripDAO.createNewDeliveryTrip(bestCentralShipperId);
                if (newTripId != null) {
                    System.out.println("[AutoAssignService] Assigned to Central/Main Store Shipper: " + bestCentralShipperId);
                    return shipperTripDAO.updateOrderTrip(orderNo, newTripId);
                }
            }
        }

        // Fallback Step 3c: Pick active shipper with the minimum total active workload system-wide
        String absoluteBestShipperId = pickLowestWorkloadShipper(activeShippers);
        if (absoluteBestShipperId != null) {
            String newTripId = shipperTripDAO.createNewDeliveryTrip(absoluteBestShipperId);
            if (newTripId != null) {
                System.out.println("[AutoAssignService] Absolute fallback assignment to Shipper: " + absoluteBestShipperId);
                return shipperTripDAO.updateOrderTrip(orderNo, newTripId);
            }
        }

        // No shipper online at all or database error
        System.err.println("[ALERT] Workload fallback failed. Order " + orderNo + " remains in Waiting_Delivery for manual assignment.");
        return false;
    }

    /**
     * Retrieve active online shippers
     */
    private static List<Map<String, String>> getActiveShippers() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT s.Staff_ID, s.Full_Name, s.Managed_Zone FROM `staff` s " +
                     "JOIN `user` u ON s.User_ID = u.User_ID " +
                     "WHERE u.Role_ID = 'SHIPPER' AND s.Is_Active_Staff = 1";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("id", rs.getString("Staff_ID"));
                map.put("name", rs.getString("Full_Name"));
                map.put("zone", rs.getString("Managed_Zone"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Pick best active trip for multi-order batching
     */
    private static String findBestBatchTrip(List<Map<String, String>> shippers, double[] newOrderCoords) {
        String bestTripId = null;
        double minDiversion = Double.MAX_VALUE;

        for (Map<String, String> sh : shippers) {
            String shipperId = sh.get("id");
            String tripId = shipperTripDAO.getActiveTripIdByShipper(shipperId);
            if (tripId == null) {
                continue;
            }

            List<Order> existingOrders = shipperTripDAO.getOrdersByTripId(tripId);
            // Check max batch limit
            if (existingOrders.size() >= MAX_BATCH_LIMIT) {
                continue;
            }

            // Calculate original route distance
            List<double[]> originalCoords = new ArrayList<>();
            originalCoords.add(SHOP_COORDS);
            for (Order o : existingOrders) {
                double[] pt = shipperTripDAO.getOrderCoordinates(o.getOrderNo());
                originalCoords.add(pt != null ? pt : SHOP_COORDS);
            }
            double originalDist = getRouteDistance(originalCoords);

            // Calculate proposed route distance (appending the new order at the end)
            List<double[]> proposedCoords = new ArrayList<>(originalCoords);
            proposedCoords.add(newOrderCoords);
            double proposedDist = getRouteDistance(proposedCoords);

            double diversion = proposedDist - originalDist;
            System.out.println("[AutoAssignService] Check Trip " + tripId + " | Current Orders: " + existingOrders.size() + " | Route diversion: " + diversion + " km");

            if (diversion < MAX_ROUTE_DIVERSION_KM && diversion < minDiversion) {
                minDiversion = diversion;
                bestTripId = tripId;
            }
        }

        return bestTripId;
    }

    /**
     * Pick shipper with the lowest active workload
     */
    private static String pickLowestWorkloadShipper(List<Map<String, String>> shippers) {
        String bestShipperId = null;
        int minWorkload = Integer.MAX_VALUE;

        String sql = "SELECT COUNT(o.Order_No) AS active_orders FROM `orders` o " +
                     "JOIN `delivery_trip` dt ON o.Trip_ID = dt.Trip_ID " +
                     "WHERE dt.Shipper_ID = ? AND o.OrderStatus IN ('Processing', 'Delivering')";

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (Map<String, String> sh : shippers) {
                String shipperId = sh.get("id");
                ps.setString(1, shipperId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int workload = rs.getInt("active_orders");
                        if (workload < minWorkload) {
                            minWorkload = workload;
                            bestShipperId = shipperId;
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bestShipperId;
    }

    /**
     * Extract dynamic Zone Name from delivery address details
     */
    public static String getZoneFromAddress(String deliveryAddress) {
        if (deliveryAddress == null) {
            return null;
        }
        String addr = deliveryAddress.toLowerCase();
        
        // Exact match with Zone 1 - Zone 6 or Quận 1 - Quận 6
        for (int i = 1; i <= 6; i++) {
            if (addr.contains("zone " + i) || addr.contains("zone" + i)) {
                return "Zone " + i;
            }
            if (addr.contains("quận " + i) || addr.contains("q" + i)) {
                return "Zone " + i;
            }
        }
        
        // Regex fallback
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("zone\\s*(\\d+)", java.util.regex.Pattern.CASE_INSENSITIVE);
        java.util.regex.Matcher matcher = pattern.matcher(deliveryAddress);
        if (matcher.find()) {
            return "Zone " + matcher.group(1);
        }
        
        java.util.regex.Pattern patternQuan = java.util.regex.Pattern.compile("quận\\s*(\\d+)", java.util.regex.Pattern.CASE_INSENSITIVE);
        java.util.regex.Matcher matcherQuan = patternQuan.matcher(deliveryAddress);
        if (matcherQuan.find()) {
            return "Zone " + matcherQuan.group(1);
        }

        return null;
    }

    /**
     * Compute total routing distance of coordinates list using OSRM, falls back to Haversine
     */
    public static double getRouteDistance(List<double[]> coords) {
        if (coords == null || coords.size() < 2) {
            return 0.0;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < coords.size(); i++) {
            double[] pt = coords.get(i);
            if (i > 0) sb.append(";");
            sb.append(String.format("%f,%f", pt[1], pt[0])); // OSRM takes: lng,lat
        }

        try {
            String urlString = "https://router.project-osrm.org/route/v1/driving/" + sb.toString() + "?overview=false";
            URL url = new URL(urlString);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(3000);
            conn.setReadTimeout(3000);

            if (conn.getResponseCode() == 200) {
                try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = in.readLine()) != null) {
                        response.append(line);
                    }
                    JsonObject json = JsonParser.parseString(response.toString()).getAsJsonObject();
                    if ("Ok".equalsIgnoreCase(json.get("code").getAsString())) {
                        return json.getAsJsonArray("routes").get(0).getAsJsonObject().get("distance").getAsDouble() / 1000.0;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[AutoAssignService] OSRM route fetch failed: " + e.getMessage() + ". Using Haversine fallback.");
        }

        // Fallback: Haversine distance sum * 1.25
        double dist = 0.0;
        for (int i = 0; i < coords.size() - 1; i++) {
            double[] pt1 = coords.get(i);
            double[] pt2 = coords.get(i + 1);
            dist += getHaversineDistance(pt1[0], pt1[1], pt2[0], pt2[1]);
        }
        return dist * 1.25;
    }

    /**
     * Haversine formula calculation
     */
    public static double getHaversineDistance(double lat1, double lng1, double lat2, double lng2) {
        double R = 6371; // Earth radius in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}
