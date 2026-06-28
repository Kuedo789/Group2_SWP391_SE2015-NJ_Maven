package com.bakeryzone.controller.customer;

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

        // Flash message handling from session redirect
        String sessionSuccess = (String) session.getAttribute("successMessage");
        if (sessionSuccess != null) {
            request.setAttribute("successMessage", sessionSuccess);
            session.removeAttribute("successMessage");
        }
        String sessionError = (String) session.getAttribute("errorMessage");
        if (sessionError != null) {
            request.setAttribute("errorMessage", sessionError);
            session.removeAttribute("errorMessage");
        }

        String action = request.getParameter("action");
        String source = request.getParameter("source");
        String redirectUrl = request.getContextPath() + "/delivery-address" + (source != null && !source.isEmpty() ? "?source=" + source : "");
        String view = "list"; // default view is the list of addresses

        if (action != null) {
            if (action.equalsIgnoreCase("delete")) {
                String idStr = request.getParameter("id");
                try {
                    int id = Integer.parseInt(idStr);
                    boolean deleted = addressDAO.deleteAddress(id, user.getUserId());
                    if (deleted) {
                        User freshUser = new com.bakeryzone.dao.UserDAO().getUserById(user.getUserId());
                        session.setAttribute("user", freshUser);
                        session.setAttribute("successMessage", "Xóa địa chỉ thành công.");
                    } else {
                        session.setAttribute("errorMessage", "Xóa địa chỉ thất bại.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã địa chỉ không hợp lệ.");
                }
                response.sendRedirect(redirectUrl);
                return;
            } else if (action.equalsIgnoreCase("set-default")) {
                String idStr = request.getParameter("id");
                try {
                    int id = Integer.parseInt(idStr);
                    boolean set = addressDAO.setDefaultAddress(id, user.getUserId());
                    if (set) {
                        User freshUser = new com.bakeryzone.dao.UserDAO().getUserById(user.getUserId());
                        session.setAttribute("user", freshUser);
                        session.setAttribute("successMessage", "Thiết lập địa chỉ mặc định thành công.");
                    } else {
                        session.setAttribute("errorMessage", "Thiết lập địa chỉ mặc định thất bại.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã địa chỉ không hợp lệ.");
                }
                response.sendRedirect(redirectUrl);
                return;
            } else if (action.equalsIgnoreCase("add")) {
                view = "form";
            } else if (action.equalsIgnoreCase("profile")) {
                addressDAO.getAddressesByUserId(user.getUserId()).stream()
                        .filter(DeliveryAddress::isDefault)
                        .findFirst()
                        .ifPresent(addr -> request.setAttribute("addressToEdit", addr));
                view = "form";
            } else if (action.equalsIgnoreCase("edit")) {
                String idStr = request.getParameter("id");
                try {
                    int id = Integer.parseInt(idStr);
                    DeliveryAddress addressToEdit = addressDAO.getAddressById(id, user.getUserId());
                    if (addressToEdit != null) {
                        request.setAttribute("addressToEdit", addressToEdit);
                        view = "form";
                    } else {
                        session.setAttribute("errorMessage", "Không tìm thấy địa chỉ cần chỉnh sửa.");
                        response.sendRedirect(redirectUrl);
                        return;
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Mã địa chỉ không hợp lệ.");
                    response.sendRedirect(redirectUrl);
                    return;
                }
            }
        }

        request.setAttribute("view", view);
        refetchAddresses(request, user);
        request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
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

        String addressIdRaw = trim(request.getParameter("addressId"));
        String source = request.getParameter("source");
        boolean isProfileMode = source == null || source.trim().isEmpty();
        String redirectUrl = isProfileMode ? request.getContextPath() + "/profile" : request.getContextPath() + "/delivery-address?source=" + source;
        String receiverNameRaw = trim(request.getParameter("receiverName"));
        String receiverPhoneRaw = trim(request.getParameter("receiverPhone"));
        
        final String receiverName = isProfileMode ? user.getFullName() : receiverNameRaw;
        final String receiverPhone = isProfileMode ? user.getPhone() : receiverPhoneRaw;

        String addressDetail = trim(request.getParameter("addressDetail"));
        String latitudeRaw = trim(request.getParameter("latitude"));
        String longitudeRaw = trim(request.getParameter("longitude"));
        String isDefaultRaw = request.getParameter("isDefault");
        boolean isDefaultParam = isDefaultRaw != null && (isDefaultRaw.equals("true") || isDefaultRaw.equals("on"));

        final boolean isDefault = isProfileMode ? true : isDefaultParam;

        // Helper to preserve edit state on validation failure
        Runnable preserveState = () -> {
            request.setAttribute("view", "form");
            refetchAddresses(request, user);
            try {
                int addressId = isEmpty(addressIdRaw) ? 0 : Integer.parseInt(addressIdRaw);
                DeliveryAddress addressToEdit = new DeliveryAddress(
                        user.getUserId(), receiverName, receiverPhone, addressDetail,
                        isEmpty(latitudeRaw) ? 0 : Double.parseDouble(latitudeRaw),
                        isEmpty(longitudeRaw) ? 0 : Double.parseDouble(longitudeRaw),
                        isDefault
                );
                addressToEdit.setAddressId(addressId);
                request.setAttribute("addressToEdit", addressToEdit);
            } catch (Exception e) {}
        };

        boolean isLockedName = receiverName.equals(user.getFullName());
        boolean isLockedPhone = receiverPhone.equals(user.getPhone());

        if (isEmpty(receiverName)) {
            request.setAttribute("errorMessage", "Vui lòng nhập tên người nhận.");
            preserveState.run();
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (!isLockedName && (receiverName.length() > 30 || !receiverName.matches("[\\p{L}]+( [\\p{L}]+)*"))) {
            request.setAttribute("errorMessage", "Tên người nhận không hợp lệ.");
            preserveState.run();
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(receiverPhone) || (!isLockedPhone && !receiverPhone.matches("0(3|5|7|8|9)\\d{8}"))) {
            request.setAttribute("errorMessage", "Số điện thoại người nhận không hợp lệ.");
            preserveState.run();
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(addressDetail)) {
            request.setAttribute("errorMessage", "Vui lòng tìm và chọn địa chỉ giao hàng.");
            preserveState.run();
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        if (isEmpty(latitudeRaw) || isEmpty(longitudeRaw)) {
            request.setAttribute("errorMessage", "Vui lòng tìm địa chỉ trên bản đồ trước khi lưu.");
            preserveState.run();
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
            preserveState.run();
            request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
            return;
        }

        boolean success;
        if (!isEmpty(addressIdRaw)) {
            // Edit mode
            try {
                int addressId = Integer.parseInt(addressIdRaw);
                DeliveryAddress address = new DeliveryAddress(
                        user.getUserId(),
                        receiverName,
                        receiverPhone,
                        addressDetail,
                        latitude,
                        longitude,
                        isDefault
                );
                address.setAddressId(addressId);
                success = addressDAO.updateAddress(address);
                if (success) {
                    session.setAttribute("successMessage", "Cập nhật địa chỉ thành công.");
                } else {
                    request.setAttribute("errorMessage", "Cập nhật địa chỉ thất bại. Vui lòng thử lại.");
                    preserveState.run();
                    request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Mã địa chỉ không hợp lệ.");
                preserveState.run();
                request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
                return;
            }
        } else {
            // Insert/Add mode
            DeliveryAddress address = new DeliveryAddress(
                    user.getUserId(),
                    receiverName,
                    receiverPhone,
                    addressDetail,
                    latitude,
                    longitude,
                    isDefault
            );
            success = addressDAO.insertAddress(address);
            if (success) {
                session.setAttribute("successMessage", "Thêm địa chỉ giao hàng thành công.");
            } else {
                request.setAttribute("errorMessage", "Thêm địa chỉ thất bại. Vui lòng thử lại.");
                preserveState.run();
                request.getRequestDispatcher("/customer/deliveryAddress.jsp").forward(request, response);
                return;
            }
        }

        if (success) {
            User freshUser = new com.bakeryzone.dao.UserDAO().getUserById(user.getUserId());
            session.setAttribute("user", freshUser);
        }

        // Post-Redirect-Get: Redirect back to the address list view
        response.sendRedirect(redirectUrl);
    }

    private void refetchAddresses(HttpServletRequest request, User user) {
        List<DeliveryAddress> addressList = addressDAO.getAddressesByUserId(user.getUserId());
        request.setAttribute("addressList", addressList);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isEmpty(String value) {
        return value == null || value.isEmpty();
    }
}
