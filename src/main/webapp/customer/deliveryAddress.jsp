<%-- 
    Document   : deliveryAddress
    Created on : Jun 12, 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.bakeryzone.model.DeliveryAddress"%>

<%
    String view = (String) request.getAttribute("view");
    if (view == null) {
        view = "list";
    }
    DeliveryAddress addressToEdit = (DeliveryAddress) request.getAttribute("addressToEdit");
    boolean isEditMode = addressToEdit != null;
    List<DeliveryAddress> addressList = (List<DeliveryAddress>) request.getAttribute("addressList");
%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <!-- Leaflet CSS -->
        <link rel="stylesheet"
              href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

        <style>
            .address-page {
                max-width: 1200px;
                margin: 0 auto;
                padding: 110px 24px 90px;
            }

            /* Common Card Design */
            .address-card {
                background-color: var(--white);
                border-radius: 22px;
                padding: 35px;
                box-shadow: var(--shadow);
            }

            /* Header Section */
            .address-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 24px;
                border-bottom: 1px solid #f0edf8;
                padding-bottom: 16px;
            }

            .address-header h2 {
                margin: 0;
                font-size: 26px;
                font-weight: 800;
                color: var(--text);
            }

            /* Buttons */
            .btn-add-new {
                background-color: var(--primary);
                color: white;
                text-decoration: none;
                padding: 10px 20px;
                border-radius: 10px;
                font-weight: 700;
                font-size: 14px;
                transition: all 0.2s;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }

            .btn-add-new:hover {
                opacity: 0.9;
                color: white;
            }

            .btn-back {
                display: flex;
                align-items: center;
                justify-content: center;
                text-decoration: none;
                border: 1px solid #ccc;
                border-radius: 10px;
                color: var(--text);
                font-weight: 700;
                padding: 0 20px;
                height: 52px;
                background-color: white;
                transition: all 0.2s;
            }

            .btn-back:hover {
                background-color: #f5f5f5;
                color: var(--text);
            }

            /* View 1: Address List Layout */
            .address-list-container {
                max-width: 850px;
                margin: 0 auto;
            }

            .address-items-container {
                display: flex;
                flex-direction: column;
                gap: 16px;
            }

            .address-item {
                border: 1px solid var(--border);
                border-radius: 12px;
                padding: 24px;
                background-color: #faf9f6;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                transition: all 0.2s;
            }

            .address-item:hover {
                border-color: var(--primary);
                box-shadow: 0 4px 12px rgba(21, 92, 46, 0.05);
            }

            .address-item.default-item {
                border-left: 4px solid var(--primary);
                background-color: #fffdf5;
            }

            .address-item-left {
                flex: 1;
                padding-right: 16px;
            }

            .address-item-header {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 8px;
            }

            .receiver-name {
                font-weight: 700;
                font-size: 17px;
                color: var(--text);
            }

            .divider-pipe {
                color: #ccc;
            }

            .receiver-phone {
                color: var(--text-muted);
                font-size: 15px;
            }

            .address-item-detail {
                font-size: 15px;
                color: var(--text);
                line-height: 1.5;
                margin-bottom: 12px;
            }

            .badge-default {
                background-color: #eefaf1;
                color: var(--primary);
                border: 1px solid #b8e6c4;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 700;
                display: inline-block;
            }

            .address-item-right {
                display: flex;
                flex-direction: column;
                align-items: flex-end;
                gap: 18px;
            }

            .address-actions {
                display: flex;
                gap: 12px;
            }

            .action-link {
                text-decoration: none;
                font-size: 14px;
                font-weight: 700;
                color: #0d6efd;
            }

            .action-link:hover {
                text-decoration: underline;
            }

            .action-link.delete-link {
                color: #dc3545;
            }

            .btn-set-default {
                background-color: white;
                border: 1px solid #ccc;
                color: var(--text);
                padding: 6px 14px;
                border-radius: 6px;
                font-size: 13px;
                font-weight: 700;
                cursor: pointer;
                text-decoration: none;
                transition: all 0.2s;
            }

            .btn-set-default:hover {
                background-color: #f5f5f5;
                border-color: #999;
                color: var(--text);
            }

            .no-address-state {
                text-align: center;
                padding: 60px 20px;
                color: var(--text-muted);
            }

            .no-address-state i {
                font-size: 56px;
                margin-bottom: 16px;
                color: #ddd;
            }

            .no-address-state p {
                margin: 0;
                font-size: 17px;
                font-weight: 600;
            }

            /* View 2: Form & Map Layout */
            .address-form-container {
                display: grid;
                grid-template-columns: 1.2fr 1fr;
                gap: 32px;
            }

            .address-form {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }

            .form-field-group {
                margin-bottom: 8px;
                display: flex;
                flex-direction: column;
                gap: 6px;
            }

            .form-field-label {
                font-size: 14px;
                font-weight: 700;
                color: var(--text);
            }

            .required {
                color: #d62828;
            }

            .address-input {
                width: 100%;
                height: 52px;
                border: 1px solid var(--border);
                border-radius: 10px;
                padding: 0 16px;
                font-size: 16px;
                outline: none;
                box-sizing: border-box;
            }

            .address-input:focus {
                border-color: var(--primary);
            }

            .address-suggest-box {
                position: relative;
                width: 100%;
            }

            .suggestion-list {
                position: absolute;
                top: 58px;
                left: 0;
                right: 0;
                z-index: 999;
                display: none;
                max-height: 240px;
                overflow-y: auto;
                background-color: white;
                border: 1px solid var(--border);
                border-radius: 10px;
                box-shadow: var(--shadow);
            }

            .suggestion-item {
                padding: 12px 14px;
                font-size: 14px;
                cursor: pointer;
                border-bottom: 1px solid #eee;
            }

            .suggestion-item:hover {
                background-color: #fff4e8;
            }

            .suggestion-item:last-child {
                border-bottom: none;
            }

            .button-row {
                display: flex;
                gap: 12px;
            }

            .btn-search,
            .btn-save {
                height: 52px;
                padding: 0 24px;
                border: none;
                border-radius: 10px;
                color: white;
                font-weight: 700;
                cursor: pointer;
                transition: all 0.2s;
            }

            .btn-search {
                background-color: #6c757d;
                min-width: 110px;
            }

            .btn-save {
                background-color: var(--primary);
                flex: 1;
            }

            .btn-search:hover,
            .btn-save:hover {
                opacity: 0.9;
            }

            #map {
                width: 100%;
                height: 420px;
                border-radius: 16px;
                overflow: hidden;
                margin-top: 20px;
            }

            .address-info {
                margin-top: 20px;
                padding: 16px;
                background-color: #fffaf5;
                border: 1px solid #ead8c7;
                border-radius: 12px;
                line-height: 1.8;
            }

            .address-info strong {
                color: var(--primary);
            }

            .alert {
                margin-bottom: 20px;
                padding: 12px 16px;
                border-radius: 10px;
                font-weight: 600;
            }

            .alert-success {
                color: #155c2e;
                background-color: #eefaf1;
                border: 1px solid #b8e6c4;
            }

            .alert-danger {
                color: #d62828;
                background-color: #fff0f0;
                border: 1px solid #f5b5b5;
            }

            .checkbox-row {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 14px;
                font-weight: 700;
                color: var(--text);
                cursor: pointer;
                margin: 8px 0 16px;
            }

            .checkbox-row input {
                width: 18px;
                height: 18px;
                cursor: pointer;
            }

            @media (max-width: 992px) {
                .address-form-container {
                    grid-template-columns: 1fr;
                }
                .address-page {
                    padding: 32px 18px 70px;
                }
            }
        </style>
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="address-page">

            <% 
                // view is already declared at the top of the file

                String source = request.getParameter("source");
                String sourceParam = (source != null && !source.isEmpty()) ? "&source=" + source : "";
                String sourceQuery = (source != null && !source.isEmpty()) ? "?source=" + source : "";
            %>
            <% if (view.equals("list")) { %>
                <!-- View 1: Address List Screen -->
                <div class="address-list-container">
                    <div class="address-card">
                        <div class="address-header">
                            <div style="display:flex;align-items:center;gap:12px;">
                                <% if ("checkout".equals(source)) { %>
                                <a href="${pageContext.request.contextPath}/checkout" class="btn-back" title="Quay lại thanh toán">
                                    <i class="fa fa-arrow-left" style="margin-right:6px;"></i> Quay lại
                                </a>
                                <% } else { %>
                                <a href="${pageContext.request.contextPath}/profile" class="btn-back" title="Quay lại trang cá nhân">
                                    <i class="fa fa-arrow-left" style="margin-right:6px;"></i> Quay lại
                                </a>
                                <% } %>
                                <h2 style="margin:0;">Địa chỉ của tôi</h2>
                            </div>
                            <a href="${pageContext.request.contextPath}/delivery-address?action=add<%= sourceParam %>" class="btn-add-new">
                                <i class="fa fa-plus"></i> Thêm địa chỉ mới
                            </a>
                        </div>

                        <% if (request.getAttribute("successMessage") != null) { %>
                        <div class="alert alert-success">
                            ✓ <%= request.getAttribute("successMessage") %>
                        </div>
                        <% } %>

                        <% if (request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger">
                            <%= request.getAttribute("errorMessage") %>
                        </div>
                        <% } %>

                        <div class="address-items-container">
                            <% 
                                if (addressList == null || addressList.isEmpty()) {
                            %>
                                <div class="no-address-state">
                                    <i class="fa fa-map-marker-alt"></i>
                                    <p>Bạn chưa lưu địa chỉ giao hàng nào.</p>
                                </div>
                            <% 
                                } else {
                                    for (DeliveryAddress addr : addressList) {
                            %>
                                <div class="address-item <%= addr.isDefault() ? "default-item" : "" %>"
                                     <% if ("checkout".equals(source)) { %>
                                     style="cursor: pointer;"
                                     onclick="if(event.target.tagName !== 'A') window.location.href='${pageContext.request.contextPath}/checkout?selectedAddressId=<%= addr.getAddressId() %>'"
                                     <% } %>>
                                    <div class="address-item-left">
                                        <div class="address-item-header">
                                            <span class="receiver-name"><%= addr.getReceiverName() %></span>
                                            <span class="divider-pipe">|</span>
                                            <span class="receiver-phone"><%= addr.getReceiverPhone() %></span>
                                        </div>
                                        <div class="address-item-detail">
                                            <%= addr.getAddressDetail() %>
                                        </div>
                                        <% if (addr.isDefault()) { %>
                                            <span class="badge-default">Mặc định</span>
                                        <% } %>
                                        <% if ("checkout".equals(source)) { %>
                                            <div style="margin-top: 8px; font-size: 13px; color: var(--primary-dark); font-weight: 600;">
                                                <i class="fa fa-check-circle"></i> Nhấp để chọn địa chỉ này
                                            </div>
                                        <% } %>
                                    </div>
                                    <div class="address-item-right">
                                        <div class="address-actions">
                                            <a href="${pageContext.request.contextPath}/delivery-address?action=edit&id=<%= addr.getAddressId() %><%= sourceParam %>" class="action-link">Cập nhật</a>
                                            <a href="${pageContext.request.contextPath}/delivery-address?action=delete&id=<%= addr.getAddressId() %><%= sourceParam %>" class="action-link delete-link" onclick="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?')">Xóa</a>
                                        </div>
                                        <% if (!addr.isDefault()) { %>
                                            <a href="${pageContext.request.contextPath}/delivery-address?action=set-default&id=<%= addr.getAddressId() %><%= sourceParam %>" class="btn-set-default">Thiết lập mặc định</a>
                                        <% } %>
                                    </div>
                                </div>
                            <% 
                                    }
                                }
                            %>
                        </div>
                    </div>
                </div>

            <% } else if (view.equals("form")) { %>
                <!-- View 2: Add/Edit Address Form & Map Screen -->
                <div class="address-form-container">
                    <div class="address-card">
                        <div class="address-header">
                            <h2><%= isEditMode ? "Cập nhật địa chỉ" : "Địa chỉ mới" %></h2>
                        </div>

                        <% if (request.getAttribute("errorMessage") != null) { %>
                        <div class="alert alert-danger">
                            <%= request.getAttribute("errorMessage") %>
                        </div>
                        <% } %>

                        <form id="addressForm" class="address-form"
                              action="${pageContext.request.contextPath}/delivery-address"
                              method="post">

                            <input type="hidden" name="addressId" value="<%= isEditMode ? addressToEdit.getAddressId() : "" %>">
                            <input type="hidden" name="source" value="<%= source != null ? source : "" %>">

                            <div class="form-field-group">
                                <label class="form-field-label">Tên người nhận <span class="required">*</span></label>
                                <input type="text"
                                       name="receiverName"
                                       class="address-input"
                                       maxlength="30"
                                       placeholder="Tên người nhận"
                                       value="<%= isEditMode ? addressToEdit.getReceiverName() : "" %>">
                            </div>

                            <div class="form-field-group">
                                <label class="form-field-label">Số điện thoại <span class="required">*</span></label>
                                <input type="text"
                                       name="receiverPhone"
                                       class="address-input"
                                       maxlength="10"
                                       placeholder="Số điện thoại người nhận"
                                       value="<%= isEditMode ? addressToEdit.getReceiverPhone() : "" %>">
                            </div>

                            <div class="form-field-group">
                                <label class="form-field-label">Địa chỉ <span class="required">*</span></label>
                                <div class="address-suggest-box">
                                    <input type="text"
                                           id="addressInput"
                                           class="address-input"
                                           placeholder="Nhập và tìm địa chỉ giao hàng"
                                           oninput="suggestAddress()"
                                           autocomplete="off"
                                           value="<%= isEditMode ? addressToEdit.getAddressDetail() : "" %>">

                                    <div id="suggestionList" class="suggestion-list"></div>
                                </div>
                            </div>

                            <div class="form-field-group">
                                <label class="form-field-label">Ghi chú địa chỉ (Tùy chọn)</label>
                                <input type="text"
                                       id="addressNote"
                                       class="address-input"
                                       maxlength="255"
                                       placeholder="Ghi chú địa chỉ: số nhà, ngõ, tầng...">
                            </div>

                            <input type="hidden" id="addressDetail" name="addressDetail" value="<%= isEditMode ? addressToEdit.getAddressDetail() : "" %>">
                            <input type="hidden" id="latitudeInput" name="latitude" value="<%= isEditMode ? addressToEdit.getLatitude() : "" %>">
                            <input type="hidden" id="longitudeInput" name="longitude" value="<%= isEditMode ? addressToEdit.getLongitude() : "" %>">

                            <label class="checkbox-row">
                                <input type="checkbox" name="isDefault" <%= (isEditMode && addressToEdit.isDefault()) ? "checked disabled" : "" %> <%= (!isEditMode && (addressList == null || addressList.isEmpty())) ? "checked disabled" : "" %>>
                                Đặt làm địa chỉ mặc định
                            </label>
                            <% if (isEditMode && addressToEdit.isDefault()) { %>
                                <input type="hidden" name="isDefault" value="on">
                            <% } %>
                            <% if (!isEditMode && (addressList == null || addressList.isEmpty())) { %>
                                <input type="hidden" name="isDefault" value="on">
                            <% } %>

                            <div class="button-row">
                                <button type="button"
                                        class="btn-search"
                                        onclick="searchAddress()">
                                    Tìm kiếm
                                </button>

                                <button type="submit"
                                        class="btn-save">
                                    Lưu địa chỉ
                                </button>

                                <a href="${pageContext.request.contextPath}/delivery-address<%= sourceQuery %>" class="btn-back">
                                    Trở lại
                                </a>
                            </div>

                        </form>
                    </div>

                    <div class="address-card">
                        <div class="address-header">
                            <h2>Bản đồ & Tuyến đường</h2>
                        </div>

                        <div style="margin-bottom:10px;padding:8px 12px;background:#fff8e1;border:1px solid #ffe082;border-radius:8px;font-size:13px;color:#7b5800;">
                            <i class="fa fa-hand-pointer"></i> <strong>Mẹo:</strong> Nhấp vào bản đồ để ghim vị trí giao hàng bằng tay.
                        </div>

                        <div id="map"></div>

                        <div class="address-info">
                            <div><strong>Địa chỉ:</strong> <span id="selectedAddress"><%= isEditMode ? addressToEdit.getAddressDetail() : "Chưa chọn" %></span></div>
                            <div><strong>Khoảng cách:</strong> <span id="distance">Chưa tính</span></div>
                            <div><strong>Thời gian dự kiến:</strong> <span id="duration">Chưa tính</span></div>
                        </div>
                    </div>
                </div>
            <% } %>

        </main>

        <jsp:include page="../common/footer.jsp" />

        <!-- Leaflet JS -->
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <script>
            const isEditMode = <%= isEditMode %>;
            const editLat = <%= isEditMode ? addressToEdit.getLatitude() : "null" %>;
            const editLng = <%= isEditMode ? addressToEdit.getLongitude() : "null" %>;
            const editAddress = `<%= isEditMode ? addressToEdit.getAddressDetail().replace("`", "\\`").replace("$", "\\$") : "" %>`;

            const shopLat = 21.0278;
            const shopLng = 105.8342;

            let customerMarker = null;
            let routeLine = null;
            let suggestTimer = null;

            // Only initialize map if form view is active
            const mapContainer = document.getElementById("map");
            let map = null;

            if (mapContainer) {
                map = L.map("map").setView([shopLat, shopLng], 13);

                L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                    maxZoom: 19,
                    attribution: "&copy; OpenStreetMap"
                }).addTo(map);

                L.marker([shopLat, shopLng])
                        .addTo(map)
                        .bindPopup("Cửa hàng bánh")
                        .openPopup();
            }

            window.addEventListener("load", function () {
                if (isEditMode && editLat && editLng && map) {
                    updateMarker(editLat, editLng);
                    calculateRoute(editLat, editLng);
                    document.getElementById("selectedAddress").innerText = editAddress;
                }
            });

            async function searchAddress() {
                const address = document.getElementById("addressInput").value.trim();

                if (address === "") {
                    alert("Vui lòng nhập địa chỉ giao hàng.");
                    return;
                }

                const url = "https://nominatim.openstreetmap.org/search"
                        + "?format=json"
                        + "&addressdetails=1"
                        + "&limit=1"
                        + "&countrycodes=vn"
                        + "&q=" + encodeURIComponent(address);

                try {
                    const response = await fetch(url);
                    const data = await response.json();

                    if (data.length === 0) {
                        alert("Không tìm thấy địa chỉ. Vui lòng nhập rõ hơn.");
                        return;
                    }

                    selectAddress(data[0]);

                } catch (error) {
                    alert("Không thể tìm địa chỉ. Vui lòng thử lại.");
                }
            }

            function suggestAddress() {
                clearTimeout(suggestTimer);

                suggestTimer = setTimeout(async function () {
                    const keyword = document.getElementById("addressInput").value.trim();
                    const suggestionList = document.getElementById("suggestionList");

                    if (keyword.length < 3) {
                        hideSuggestions();
                        return;
                    }

                    const url = "https://nominatim.openstreetmap.org/search"
                            + "?format=json"
                            + "&addressdetails=1"
                            + "&limit=5"
                            + "&countrycodes=vn"
                            + "&q=" + encodeURIComponent(keyword);

                    try {
                        const response = await fetch(url);
                        const data = await response.json();

                        suggestionList.innerHTML = "";

                        if (data.length === 0) {
                            hideSuggestions();
                            return;
                        }

                        data.forEach(function (item) {
                            const div = document.createElement("div");
                            div.className = "suggestion-item";
                            div.innerText = item.display_name;

                            div.onclick = function () {
                                selectAddress(item);
                            };

                            suggestionList.appendChild(div);
                        });

                        suggestionList.style.display = "block";

                    } catch (error) {
                        hideSuggestions();
                    }

                }, 500);
            }

            function selectAddress(item) {
                const customerLat = parseFloat(item.lat);
                const customerLng = parseFloat(item.lon);
                const address = item.display_name;

                document.getElementById("addressInput").value = address;
                const note = document.getElementById("addressNote").value.trim();

                document.getElementById("selectedAddress").innerText =
                        note === "" ? address : note + ", " + address;
                document.getElementById("addressDetail").value =
                        note === "" ? address : note + ", " + address;
                document.getElementById("latitudeInput").value = customerLat;
                document.getElementById("longitudeInput").value = customerLng;

                hideSuggestions();
                updateMarker(customerLat, customerLng);
                calculateRoute(customerLat, customerLng);
            }

            function updateMarker(customerLat, customerLng) {
                if (!map) return;

                if (customerMarker !== null) {
                    map.removeLayer(customerMarker);
                }

                customerMarker = L.marker([customerLat, customerLng])
                        .addTo(map)
                        .bindPopup("Địa chỉ giao hàng")
                        .openPopup();

                map.setView([customerLat, customerLng], 15);
            }

            async function calculateRoute(customerLat, customerLng) {
                if (!map) return;

                const osrmUrl = "https://router.project-osrm.org/route/v1/driving/"
                        + shopLng + "," + shopLat + ";"
                        + customerLng + "," + customerLat
                        + "?overview=full&geometries=geojson";

                try {
                    const response = await fetch(osrmUrl);
                    const data = await response.json();

                    if (data.code !== "Ok") {
                        alert("Không tính được đường đi.");
                        return;
                    }

                    const route = data.routes[0];
                    const distanceKm = route.distance / 1000;

                    document.getElementById("distance").innerText =
                            distanceKm.toFixed(2) + " km";

                    // Tính thời gian theo xe máy (~30 km/h trong đô thị)
                    const motoSpeedKmh = 30;
                    const motoSeconds = (distanceKm / motoSpeedKmh) * 3600;
                    document.getElementById("duration").innerText =
                            formatDuration(motoSeconds);

                    if (routeLine !== null) {
                        map.removeLayer(routeLine);
                    }

                    routeLine = L.geoJSON(route.geometry).addTo(map);
                    map.fitBounds(routeLine.getBounds());

                } catch (error) {
                    alert("Không thể tính đường đi.");
                }
            }

            // Ghim vị trí bằng tay khi click lên bản đồ
            if (map) {
                map.on("click", async function (e) {
                    const lat = e.latlng.lat;
                    const lng = e.latlng.lng;

                    // Reverse geocode để lấy tên địa chỉ
                    let addressName = "Vị trí đã ghim (" + lat.toFixed(5) + ", " + lng.toFixed(5) + ")";
                    try {
                        const revUrl = "https://nominatim.openstreetmap.org/reverse?format=json&lat=" + lat + "&lon=" + lng + "&addressdetails=1";
                        const revRes = await fetch(revUrl);
                        const revData = await revRes.json();
                        if (revData && revData.display_name) {
                            addressName = revData.display_name;
                        }
                    } catch (err) {}

                    // Cập nhật input và marker
                    document.getElementById("addressInput").value = addressName;
                    document.getElementById("addressDetail").value = addressName;
                    document.getElementById("latitudeInput").value = lat;
                    document.getElementById("longitudeInput").value = lng;
                    document.getElementById("selectedAddress").innerText = addressName;

                    hideSuggestions();
                    updateMarker(lat, lng);
                    calculateRoute(lat, lng);
                });
            }

            function formatDuration(seconds) {
                const totalMinutes = Math.round(seconds / 60);

                if (totalMinutes < 60) {
                    return totalMinutes + " phút";
                }

                const hours = Math.floor(totalMinutes / 60);
                const minutes = totalMinutes % 60;

                if (minutes === 0) {
                    return hours + " giờ";
                }

                return hours + " giờ " + minutes + " phút";
            }

            function hideSuggestions() {
                const suggestionList = document.getElementById("suggestionList");
                if (suggestionList) {
                    suggestionList.style.display = "none";
                    suggestionList.innerHTML = "";
                }
            }

            document.addEventListener("click", function (event) {
                const box = document.querySelector(".address-suggest-box");

                if (box && !box.contains(event.target)) {
                    hideSuggestions();
                }
            });

            // Form Validation on Submit
            const addressForm = document.getElementById("addressForm");
            if (addressForm) {
                addressForm.addEventListener("submit", function (e) {
                    const nameInput = document.querySelector('input[name="receiverName"]');
                    const phoneInput = document.querySelector('input[name="receiverPhone"]');
                    const addressInput = document.getElementById("addressInput");
                    const latInput = document.getElementById("latitudeInput");
                    const lngInput = document.getElementById("longitudeInput");

                    const nameVal = nameInput ? nameInput.value.trim() : "";
                    if (nameVal === "") {
                        alert("Vui lòng nhập tên người nhận.");
                        if (nameInput) nameInput.focus();
                        e.preventDefault();
                        return;
                    }
                    if (nameVal.length > 30) {
                        alert("Tên người nhận không được dài quá 30 ký tự.");
                        if (nameInput) nameInput.focus();
                        e.preventDefault();
                        return;
                    }
                    // Validate name format: no numbers or special characters (except spaces)
                    const specialCharOrNum = /[0-9!@#$%^&*(),.?":{}|<>_\[\]\\\/+=~`-]/;
                    if (specialCharOrNum.test(nameVal)) {
                        alert("Tên người nhận không hợp lệ (chỉ chứa chữ cái và khoảng trắng, không chứa số hay ký tự đặc biệt).");
                        if (nameInput) nameInput.focus();
                        e.preventDefault();
                        return;
                    }

                    const phoneVal = phoneInput ? phoneInput.value.trim() : "";
                    if (phoneVal === "") {
                        alert("Vui lòng nhập số điện thoại người nhận.");
                        if (phoneInput) phoneInput.focus();
                        e.preventDefault();
                        return;
                    }
                    // Vietnamese phone regex: starts with 03, 05, 07, 08, 09, exactly 10 digits
                    const phoneRegex = /^0(3|5|7|8|9)\d{8}$/;
                    if (!phoneRegex.test(phoneVal)) {
                        alert("Số điện thoại không hợp lệ (phải đủ 10 chữ số và bắt đầu bằng 03, 05, 07, 08 hoặc 09).");
                        if (phoneInput) phoneInput.focus();
                        e.preventDefault();
                        return;
                    }

                    const addrVal = addressInput ? addressInput.value.trim() : "";
                    if (addrVal === "") {
                        alert("Vui lòng nhập và tìm kiếm địa chỉ trên bản đồ.");
                        if (addressInput) addressInput.focus();
                        e.preventDefault();
                        return;
                    }

                    const latVal = latInput ? latInput.value.trim() : "";
                    const lngVal = lngInput ? lngInput.value.trim() : "";
                    if (latVal === "" || lngVal === "") {
                        alert("Vui lòng tìm địa chỉ hoặc ghim vị trí trên bản đồ để xác định tọa độ giao hàng.");
                        if (addressInput) addressInput.focus();
                        e.preventDefault();
                        return;
                    }
                });
            }
        </script>

    </body>
</html>