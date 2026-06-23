<%-- 
    Document   : deliveryAddress
    Created on : Jun 12, 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <!-- Leaflet CSS -->
        <link rel="stylesheet"
              href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/customer/deliveryAddress.css">
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="address-page">

            <c:set var="sourceParam" value="${not empty param.source ? '&source=' += param.source : ''}" />
            <c:set var="sourceQuery" value="${not empty param.source ? '?source=' += param.source : ''}" />
            <c:set var="isEditMode" value="${not empty requestScope.addressToEdit}" />
            <c:set var="addressToEdit" value="${requestScope.addressToEdit}" />
            <c:set var="addressList" value="${requestScope.addressList}" />
            <c:set var="isProfileMode" value="${empty param.source}" />

            <c:choose>
            <c:when test="${empty requestScope.view or requestScope.view == 'list'}">
                <!-- View 1: Address List Screen -->
                <div class="address-list-container">
                    <div class="address-card">
                        <div class="address-header">
                            <div style="display:flex;align-items:center;gap:12px;">
                                <c:choose>
                                <c:when test="${param.source == 'checkout'}">
                                <a href="${pageContext.request.contextPath}/checkout" class="btn-back" title="Quay lại thanh toán">
                                    <i class="fa fa-arrow-left" style="margin-right:6px;"></i> Quay lại
                                </a>
                                </c:when>
                                <c:otherwise>
                                <a href="${pageContext.request.contextPath}/profile" class="btn-back" title="Quay lại trang cá nhân">
                                    <i class="fa fa-arrow-left" style="margin-right:6px;"></i> Quay lại
                                </a>
                                </c:otherwise>
                                </c:choose>
                                <h2 style="margin:0;">Địa chỉ của tôi</h2>
                            </div>
                            <a href="${pageContext.request.contextPath}/delivery-address?action=add${sourceParam}" class="btn-add-new">
                                <i class="fa fa-plus"></i> Thêm địa chỉ mới
                            </a>
                        </div>

                        <c:if test="${not empty requestScope.successMessage}">
                        <div class="alert alert-success">
                            ✓ ${requestScope.successMessage}
                        </div>
                        </c:if>

                        <c:if test="${not empty requestScope.errorMessage}">
                        <div class="alert alert-danger">
                            ${requestScope.errorMessage}
                        </div>
                        </c:if>

                        <div class="address-items-container">
                            <c:choose>
                                <c:when test="${empty addressList}">
                                    <div class="no-address-state">
                                        <i class="fa fa-map-marker-alt"></i>
                                        <p>Bạn chưa lưu địa chỉ giao hàng nào.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="addr" items="${addressList}">
                                        <div class="address-item ${addr.isDefault() ? 'default-item' : ''}"
                                             <c:if test="${param.source == 'checkout'}">
                                             style="cursor: pointer;"
                                             onclick="if(event.target.tagName !== 'A') window.location.href='${pageContext.request.contextPath}/checkout?selectedAddressId=${addr.addressId}'"
                                             </c:if>>
                                            <div class="address-item-left">
                                                <div class="address-item-header">
                                                    <span class="receiver-name">${addr.receiverName}</span>
                                                    <span class="divider-pipe">|</span>
                                                    <span class="receiver-phone">${addr.receiverPhone}</span>
                                                </div>
                                                <div class="address-item-detail">
                                                    ${addr.addressDetail}
                                                </div>
                                                <c:if test="${addr.isDefault()}">
                                                    <span class="badge-default">Mặc định</span>
                                                </c:if>
                                                <c:if test="${param.source == 'checkout'}">
                                                    <div style="margin-top: 8px; font-size: 13px; color: var(--primary-dark); font-weight: 600;">
                                                        <i class="fa fa-check-circle"></i> Nhấp để chọn địa chỉ này
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="address-item-right">
                                                <div class="address-actions">
                                                    <a href="${pageContext.request.contextPath}/delivery-address?action=edit&id=${addr.addressId}${sourceParam}" class="action-link">Cập nhật</a>
                                                    <a href="${pageContext.request.contextPath}/delivery-address?action=delete&id=${addr.addressId}${sourceParam}" class="action-link delete-link" onclick="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?')">Xóa</a>
                                                </div>
                                                <c:if test="${not addr.isDefault() and param.source != 'checkout'}">
                                                    <a href="${pageContext.request.contextPath}/delivery-address?action=set-default&id=${addr.addressId}${sourceParam}" class="btn-set-default">Thiết lập mặc định</a>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:when>
            <c:when test="${requestScope.view == 'form'}">
                <!-- View 2: Add/Edit Address Form & Map Screen -->
                <div class="address-form-container">
                    <div class="address-card">
                        <div class="address-header">
                            <h2>${isEditMode ? 'Cập nhật địa chỉ' : 'Địa chỉ mới'}</h2>
                        </div>

                        <c:if test="${not empty requestScope.errorMessage}">
                        <div class="alert alert-danger">
                            ${requestScope.errorMessage}
                        </div>
                        </c:if>

                        <form id="addressForm" class="address-form"
                              action="${pageContext.request.contextPath}/delivery-address"
                              method="post">

                            <input type="hidden" name="addressId" value="${isEditMode ? addressToEdit.addressId : ''}">
                            <input type="hidden" name="source" value="${not empty param.source ? param.source : ''}">

                            <c:choose>
                            <c:when test="${isProfileMode}">
                                <input type="hidden" name="receiverName" value="${sessionScope.user.fullName}">
                                <input type="hidden" name="receiverPhone" value="${sessionScope.user.phone}">
                            </c:when>
                            <c:otherwise>
                            <div class="form-field-group">
                                <label class="form-field-label">Tên người nhận <span class="required">*</span></label>
                                <input type="text"
                                       name="receiverName"
                                       class="address-input"
                                       maxlength="30"
                                       placeholder="Tên người nhận"
                                       value="${isEditMode ? addressToEdit.receiverName : ''}">
                            </div>

                            <div class="form-field-group">
                                <label class="form-field-label">Số điện thoại <span class="required">*</span></label>
                                <input type="text"
                                       name="receiverPhone"
                                       class="address-input"
                                       maxlength="10"
                                       placeholder="Số điện thoại người nhận"
                                       value="${isEditMode ? addressToEdit.receiverPhone : ''}">
                            </div>
                            </c:otherwise>
                            </c:choose>

                            <div class="form-field-group">
                                <label class="form-field-label">Địa chỉ <span class="required">*</span></label>
                                <div class="address-suggest-box">
                                    <input type="text"
                                           id="addressInput"
                                           class="address-input"
                                           placeholder="Nhập và tìm địa chỉ giao hàng"
                                           oninput="suggestAddress()"
                                           autocomplete="off"
                                           value="${isEditMode ? addressToEdit.addressDetail : ''}">

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

                            <input type="hidden" id="addressDetail" name="addressDetail" value="${isEditMode ? addressToEdit.addressDetail : ''}">
                            <input type="hidden" id="latitudeInput" name="latitude" value="${isEditMode ? addressToEdit.latitude : ''}">
                            <input type="hidden" id="longitudeInput" name="longitude" value="${isEditMode ? addressToEdit.longitude : ''}">

                            <c:choose>
                            <c:when test="${isProfileMode}">
                                <input type="hidden" name="isDefault" value="on">
                            </c:when>
                            <c:otherwise>
                            <label class="checkbox-row">
                                <input type="checkbox" name="isDefault" ${(isEditMode and addressToEdit.isDefault()) ? 'checked disabled' : ''} ${(!isEditMode and empty addressList) ? 'checked disabled' : ''}>
                                Đặt làm địa chỉ mặc định
                            </label>
                            <c:if test="${isEditMode and addressToEdit.isDefault()}">
                                <input type="hidden" name="isDefault" value="on">
                            </c:if>
                            <c:if test="${!isEditMode and empty addressList}">
                                <input type="hidden" name="isDefault" value="on">
                            </c:if>
                            </c:otherwise>
                            </c:choose>

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

                                <c:choose>
                                <c:when test="${isProfileMode}">
                                    <a href="${pageContext.request.contextPath}/profile" class="btn-back">
                                        Trở lại
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/delivery-address${sourceQuery}" class="btn-back">
                                        Trở lại
                                    </a>
                                </c:otherwise>
                                </c:choose>
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
                            <div><strong>Địa chỉ:</strong> <span id="selectedAddress">${isEditMode ? addressToEdit.addressDetail : 'Chưa chọn'}</span></div>
                            <div><strong>Khoảng cách:</strong> <span id="distance">Chưa tính</span></div>
                            <div><strong>Thời gian dự kiến:</strong> <span id="duration">Chưa tính</span></div>
                        </div>
                    </div>
                </div>
            </c:when>
            </c:choose>

        </main>

        <jsp:include page="../common/footer.jsp" />

        <!-- Leaflet JS -->
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

        <script>
            <c:set var="escapedAddress" value="${isEditMode ? addressToEdit.addressDetail : ''}" />
            const isEditMode = ${isEditMode};
            const isProfileModeJs = ${isProfileMode};
            const editLat = ${isEditMode ? addressToEdit.latitude : 'null'};
            const editLng = ${isEditMode ? addressToEdit.longitude : 'null'};
            const editAddress = "${escapedAddress}";
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

                    if (!isProfileModeJs) {
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