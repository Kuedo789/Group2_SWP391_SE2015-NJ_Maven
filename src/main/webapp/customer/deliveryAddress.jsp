<%-- 
    Document   : deliveryAddress
    Created on : Jun 12, 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <!-- Leaflet CSS -->
        <link rel="stylesheet"
              href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

        <style>
            .address-page {
                max-width: 1180px;
                margin: 0 auto;
                padding: 110px 32px 90px;
            }

            .address-card {
                background-color: var(--white);
                border-radius: 22px;
                padding: 40px;
                box-shadow: var(--shadow);
            }

            .address-title {
                margin-bottom: 24px;
            }

            .address-title h1 {
                margin: 0;
                font-size: 32px;
                font-weight: 800;
                color: var(--text);
            }

            .address-form {
                display: grid;
                grid-template-columns: 1fr;
                gap: 12px;
                margin-bottom: 20px;
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
                display: grid;
                grid-template-columns: 1fr 1fr;
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
            }

            .btn-search {
                background-color: #6c757d;
            }

            .btn-save {
                background-color: var(--primary);
            }

            .btn-search:hover,
            .btn-save:hover {
                opacity: 0.9;
            }

            #map {
                width: 100%;
                height: 480px;
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

            @media (max-width: 768px) {
                .address-page {
                    padding: 32px 18px 70px;
                }

                .address-card {
                    padding: 28px 22px;
                }

                .button-row {
                    grid-template-columns: 1fr;
                }

                #map {
                    height: 380px;
                }
            }
        </style>
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="address-page">
            <div class="address-card">

                <div class="address-title">
                    <h1>Địa chỉ giao hàng</h1>
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

                <form class="address-form"
                      action="${pageContext.request.contextPath}/delivery-address"
                      method="post">

                    <input type="text"
                           name="receiverName"
                           class="address-input"
                           maxlength="30"
                           placeholder="Tên người nhận">

                    <input type="text"
                           name="receiverPhone"
                           class="address-input"
                           maxlength="10"
                           placeholder="Số điện thoại người nhận">

                    <div class="address-suggest-box">
                        <input type="text"
                               id="addressInput"
                               class="address-input"
                               placeholder="Nhập địa chỉ giao hàng"
                               oninput="suggestAddress()"
                               autocomplete="off">

                        <div id="suggestionList" class="suggestion-list"></div>
                    </div>

                    <input type="text"
                           id="addressNote"
                           class="address-input"
                           maxlength="255"
                           placeholder="Ghi chú địa chỉ: số nhà, ngõ, tầng, ghi chú giao hàng">

                    <input type="hidden" id="addressDetail" name="addressDetail">
                    <input type="hidden" id="latitudeInput" name="latitude">
                    <input type="hidden" id="longitudeInput" name="longitude">

                    <div class="button-row">
                        <button type="button"
                                class="btn-search"
                                onclick="searchAddress()">
                            Tìm địa chỉ
                        </button>

                        <button type="submit"
                                class="btn-save">
                            Lưu địa chỉ
                        </button>
                    </div>

                </form>

                <div id="map"></div>

                <div class="address-info">
                    <div><strong>Địa chỉ:</strong> <span id="selectedAddress">Chưa chọn</span></div>
                    <div><strong>Khoảng cách:</strong> <span id="distance">Chưa tính</span></div>
                    <div><strong>Thời gian dự kiến:</strong> <span id="duration">Chưa tính</span></div>
                </div>

            </div>
        </main>

        <jsp:include page="../common/footer.jsp" />

        <!-- Leaflet JS -->
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <script>
                                    const shopLat = 21.0278;
                                    const shopLng = 105.8342;

                                    let customerMarker = null;
                                    let routeLine = null;
                                    let suggestTimer = null;

                                    const map = L.map("map").setView([shopLat, shopLng], 13);

                                    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                                        maxZoom: 19,
                                        attribution: "&copy; OpenStreetMap"
                                    }).addTo(map);

                                    L.marker([shopLat, shopLng])
                                            .addTo(map)
                                            .bindPopup("Cửa hàng bánh")
                                            .openPopup();

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

                                            document.getElementById("distance").innerText =
                                                    (route.distance / 1000).toFixed(2) + " km";

                                            document.getElementById("duration").innerText =
                                                    formatDuration(route.duration);

                                            if (routeLine !== null) {
                                                map.removeLayer(routeLine);
                                            }

                                            routeLine = L.geoJSON(route.geometry).addTo(map);
                                            map.fitBounds(routeLine.getBounds());

                                        } catch (error) {
                                            alert("Không thể tính đường đi.");
                                        }
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
                                        suggestionList.style.display = "none";
                                        suggestionList.innerHTML = "";
                                    }

                                    document.addEventListener("click", function (event) {
                                        const box = document.querySelector(".address-suggest-box");

                                        if (box && !box.contains(event.target)) {
                                            hideSuggestions();
                                        }
                                    });
        </script>

    </body>
</html>