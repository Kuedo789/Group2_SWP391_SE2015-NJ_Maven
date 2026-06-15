/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.bakeryzone.customer.controller;

import com.bakeryzone.dao.DeliveryAddressDAO;
import com.bakeryzone.model.DeliveryAddress;
import com.bakeryzone.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "DeliveryAddressServlet", urlPatterns = {"/delivery-address"})
public class DeliveryAddressServlet extends HttpServlet {

    private final DeliveryAddressDAO addressDAO = new DeliveryAddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        List<DeliveryAddress> addresses
                = addressDAO.getAddressesByUserId(user.getUserId());

        request.setAttribute("addresses", addresses);

        request.getRequestDispatcher("/customer/deliveryAddress.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        String receiverName = trim(request.getParameter("receiverName"));
        String receiverPhone = trim(request.getParameter("receiverPhone"));
        String addressDetail = trim(request.getParameter("addressDetail"));
        String latitudeRaw = trim(request.getParameter("latitude"));
        String longitudeRaw = trim(request.getParameter("longitude"));

        if (isEmpty(receiverName)) {
            request.setAttribute("errorMessage", "Vui lòng nhập tên người nhận.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (receiverName.length() > 30 || !receiverName.matches("[\\p{L}]+( [\\p{L}]+)*")) {
            request.setAttribute("errorMessage", "Tên người nhận không hợp lệ.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(receiverPhone) || !receiverPhone.matches("0(3|5|7|8|9)\\d{8}")) {
            request.setAttribute("errorMessage", "Số điện thoại người nhận không hợp lệ.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(addressDetail)) {
            request.setAttribute("errorMessage", "Vui lòng tìm và chọn địa chỉ giao hàng.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(latitudeRaw) || isEmpty(longitudeRaw)) {
            request.setAttribute("errorMessage", "Vui lòng tìm địa chỉ trên bản đồ trước khi lưu.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        double latitude;
        double longitude;

        try {
            latitude = Double.parseDouble(latitudeRaw);
            longitude = Double.parseDouble(longitudeRaw);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Tọa độ địa chỉ không hợp lệ.");
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        DeliveryAddress address = new DeliveryAddress(
                user.getUserId(),
                receiverName,
                receiverPhone,
                addressDetail,
                latitude,
                longitude,
                false
        );

        boolean inserted = addressDAO.insertAddress(address);

        if (inserted) {
            request.setAttribute("successMessage", "Lưu địa chỉ giao hàng thành công.");
        } else {
            request.setAttribute("errorMessage", "Lưu địa chỉ thất bại. Vui lòng thử lại.");
        }

        request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isEmpty(String value) {
        return value == null || value.isEmpty();
    }
}
