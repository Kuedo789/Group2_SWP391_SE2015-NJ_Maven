<%-- 
    Document   : deliveryAddress
    Created on : Jun 12, 2026, 9:49:37 PM
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
                height: 52px;
                border: 1px solid var(--border);
                border-radius: 10px;
                padding: 0 16px;
                font-size: 16px;
                outline: none;
            }

            .address-input:focus {
                border-color: var(--primary);
            }

            .btn-search {
                height: 52px;
                padding: 0 24px;
                border: none;
                border-radius: 10px;
                background-color: var(--primary);
                color: white;
                font-weight: 700;
                cursor: pointer;
            }

            .btn-search:hover {
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

            @media (max-width: 768px) {
                .address-page {
                    padding: 32px 18px 70px;
                }

                .address-card {
                    padding: 28px 22px;
                }

                .address-form {
                    grid-template-columns: 1fr;
                }

                .btn-search {
                    width: 100%;
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

                    <input type="text"
                           id="addressInput"
                           class="address-input"
                           placeholder="Nhập địa chỉ giao hàng">

                    <input type="hidden" id="addressDetail" name="addressDetail">
                    <input type="hidden" id="latitudeInput" name="latitude">
                    <input type="hidden" id="longitudeInput" name="longitude">

                    <button type="button"
                            class="btn-search"
                            onclick="searchAddress()">
                        Tìm địa chỉ
                    </button>

                    <button type="submit"
                            class="btn-search">
                        Lưu địa chỉ
                    </button>

                </form>

                <div id="map"></div>

                <div class="address-info">
                    <div><strong>Địa chỉ:</strong> <span id="selectedAddress">Chưa chọn</span></div>
                    <div><strong>Latitude:</strong> <span id="latitude">Chưa có</span></div>
                    <div><strong>Longitude:</strong> <span id="longitude">Chưa có</span></div>
                    <div><strong>Khoảng cách:</strong> <span id="distance">Chưa tính</span></div>
                    <div><strong>Thời gian dự kiến:</strong> <span id="duration">Chưa tính</span></div>
                </div>

            </div>
        </main>

        <jsp:include page="../common/footer.jsp" />

        <!-- Leaflet JS -->
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <script>
                                // Tọa độ cửa hàng, tạm đặt ở Hà Nội
                                const shopLat = 21.0278;
                                const shopLng = 105.8342;

                                let customerMarker = null;
                                let routeLine = null;

                                // Tạo map
                                const map = L.map("map").setView([shopLat, shopLng], 13);

                                // Nền bản đồ OpenStreetMap
                                L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
                                    maxZoom: 19,
                                    attribution: "&copy; OpenStreetMap"
                                }).addTo(map);

                                // Marker cửa hàng
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

                                    const url = "https://nominatim.openstreetmap.org/search?format=json&q="
                                            + encodeURIComponent(address);

                                    const response = await fetch(url);
                                    const data = await response.json();

                                    if (data.length === 0) {
                                        alert("Không tìm thấy địa chỉ. Vui lòng nhập rõ hơn.");
                                        return;
                                    }

                                    const result = data[0];

                                    const customerLat = parseFloat(result.lat);
                                    const customerLng = parseFloat(result.lon);

                                    document.getElementById("selectedAddress").innerText = result.display_name;
                                    document.getElementById("latitude").innerText = customerLat;
                                    document.getElementById("longitude").innerText = customerLng;

                                    document.getElementById("addressDetail").value = result.display_name;
                                    document.getElementById("latitudeInput").value = customerLat;
                                    document.getElementById("longitudeInput").value = customerLng;

                                    // Xóa marker cũ nếu có
                                    if (customerMarker !== null) {
                                        map.removeLayer(customerMarker);
                                    }

                                    // Thêm marker khách hàng
                                    customerMarker = L.marker([customerLat, customerLng])
                                            .addTo(map)
                                            .bindPopup("Địa chỉ giao hàng")
                                            .openPopup();

                                    map.setView([customerLat, customerLng], 15);

                                    // Tính đường đi bằng OSRM
                                    calculateRoute(customerLat, customerLng);
                                }

                                async function calculateRoute(customerLat, customerLng) {
                                    const osrmUrl =
                                            "https://router.project-osrm.org/route/v1/driving/"
                                            + shopLng + "," + shopLat + ";"
                                            + customerLng + "," + customerLat
                                            + "?overview=full&geometries=geojson";

                                    const response = await fetch(osrmUrl);
                                    const data = await response.json();

                                    if (data.code !== "Ok") {
                                        alert("Không tính được đường đi.");
                                        return;
                                    }

                                    const route = data.routes[0];

                                    const distanceKm = route.distance / 1000;
                                    const durationMin = route.duration / 60;

                                    document.getElementById("distance").innerText =
                                            distanceKm.toFixed(2) + " km";

                                    document.getElementById("duration").innerText =
                                            Math.round(durationMin) + " phút";

                                    // Xóa đường cũ nếu có
                                    if (routeLine !== null) {
                                        map.removeLayer(routeLine);
                                    }

                                    // Vẽ đường đi mới
                                    routeLine = L.geoJSON(route.geometry).addTo(map);

                                    map.fitBounds(routeLine.getBounds());
                                }
        </script>

    </body>
</html>
