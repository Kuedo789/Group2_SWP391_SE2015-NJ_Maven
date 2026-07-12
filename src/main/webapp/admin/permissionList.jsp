<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CakeZone Admin - Vai trò & Quyền hạn</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

        <style>
            :root {
                --cz-primary: #3f5f36;
                --cz-primary-hover: #2f4728;
                --cz-dark-bg: #111010;
                --cz-sidebar-active: #232222;
                --cz-text-muted: #888888;
                --cz-border-color: #f1ede8;
                --cz-light-bg: #f8f6f4;
                --cz-card-bg: #ffffff;
            }

            body {
                font-family: 'Outfit', sans-serif;
                background-color: var(--cz-light-bg);
                color: #333;
                overflow-x: hidden;
                margin: 0;
            }

            .main-panel {
                margin-left: 260px;
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            .content-container {
                padding: 35px;
                flex: 1;
            }
            .form-card {
                background-color: var(--cz-card-bg);
                border-radius: 12px;
                padding: 35px;
                border: 1px solid var(--cz-border-color);
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
                width: 100%;
            }
            .page-title {
                font-size: 26px;
                font-weight: 700;
                color: #111;
                margin-bottom: 4px;
            }
            .page-subtitle {
                font-size: 13.5px;
                color: var(--cz-text-muted);
                margin-bottom: 30px;
            }

            .top-header {
                height: 70px;
                background-color: #fff;
                border-bottom: 1px solid var(--cz-border-color);
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 0 35px;
                position: sticky;
                top: 0;
                z-index: 90;
            }
            .breadcrumbs {
                font-size: 13px;
                color: var(--cz-text-muted);
                margin-bottom: 0;
            }
            .breadcrumbs a {
                color: var(--cz-text-muted);
                text-decoration: none;
            }
            .breadcrumbs span {
                margin: 0 6px;
            }
            .profile-section {
                display: flex;
                align-items: center;
                gap: 10px;
                border-left: 1px solid var(--cz-border-color);
                padding-left: 20px;
            }
            .profile-img {
                width: 36px;
                height: 36px;
                border-radius: 50%;
                object-fit: cover;
                border: 2px solid var(--cz-border-color);
            }

            .role-tabs-container {
                display: flex;
                background: #fff;
                border: 2px solid #222;
                border-radius: 6px;
                overflow: hidden;
                width: fit-content;
                margin-bottom: 35px;
            }
            .role-tab-item {
                padding: 14px 35px;
                font-weight: 700;
                text-transform: uppercase;
                text-decoration: none;
                color: #222;
                border-right: 2px solid #222;
                font-size: 13.5px;
                transition: all 0.2s;
            }
            .role-tab-item:last-child {
                border-right: none;
            }
            .role-tab-item.active-tab {
                background-color: #ced4da;
                color: #000;
            }

            .table-card {
                background-color: var(--cz-card-bg);
                border-radius: 12px;
                border: 1px solid var(--cz-border-color);
                overflow: hidden;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
            }

            .toggle-switch-box {
                display: flex;
                border: 2px solid #222;
                border-radius: 20px;
                overflow: hidden;
                background-color: #fff;
            }
            .toggle-btn {
                padding: 6px 22px;
                font-size: 12.5px;
                font-weight: 800;
                text-transform: uppercase;
                text-decoration: none;
                color: #aaa;
                transition: all 0.2s;
                cursor: pointer;
                border: none;
                background: none;
            }
            .toggle-btn.on-active {
                background-color: var(--cz-primary);
                color: #fff;
            }
            .toggle-btn.off-active {
                background-color: #222;
                color: #fff;
            }

            .feature-group-header {
                background-color: #f1ede8;
                padding: 12px 20px;
                font-weight: 800;
                font-size: 13px;
                text-transform: uppercase;
                color: var(--cz-primary);
                margin: 30px 0 15px 0;
                border-radius: 6px;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .feature-matrix-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 18px 25px;
                background: #fff;
                margin-bottom: 8px;
                border-radius: 8px;
                border: 1px solid var(--cz-border-color);
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .feature-matrix-row:hover {
                box-shadow: 0 4px 10px rgba(0,0,0,0.05);
                border-color: #e0dcd7;
            }

            .feature-meta-info {
                font-size: 16px;
                font-weight: 600;
                color: #111;
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .feature-meta-info i {
                color: var(--cz-primary);
                font-size: 18px;
            }
            .feature-endpoint {
                font-size: 13px;
                color: #999;
                font-weight: 400;
                font-family: monospace;
            }

            .feature-main {
                font-weight: 800 !important;
                color: #111 !important;
                font-size: 15px;
            }

            .feature-sub {
                font-weight: 400;
                color: #666;
                padding-left: 20px;
            }

            .btn-cz-primary {
                background-color: var(--cz-primary);
                color: #fff;
                font-weight: 600;
                font-size: 14.5px;
                padding: 10px 20px;
                border-radius: 8px;
                border: none;
                transition: all 0.2s;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                text-decoration: none;
            }
            .btn-cz-primary:hover {
                background-color: var(--cz-primary-hover);
                color: #fff;
            }
            .btn-action-delete {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid var(--cz-border-color);
                background-color: #fff;
                color: #dc3545;
                cursor: pointer;
                transition: all 0.2s;
                text-decoration: none;
            }
            .btn-action-delete:hover {
                background-color: #fdf3f4;
                border-color: #dc3545;
            }
            .btn-action-edit {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                border: 1px solid var(--cz-border-color);
                background-color: #fff;
                color: var(--cz-primary);
                cursor: pointer;
                transition: all 0.2s;
                text-decoration: none;
            }
            .btn-action-edit:hover {
                background-color: #f6faf5;
                border-color: var(--cz-primary);
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="roles" />
        </jsp:include>

        <div class="main-panel">
            <div class="top-header">
                <div class="header-left d-flex align-items-center gap-3">
                    <button class="sidebar-toggle btn p-0 border-0 fs-5 text-secondary"><i class="fa-solid fa-bars"></i></button>
                    <div class="breadcrumbs m-0">
                        <a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
                        <span>&gt;</span>
                        <a href="#">System</a>
                        <span>&gt;</span>
                        <a href="#" class="active text-dark fw-bold">Vai trò & Quyền hạn</a>
                    </div>
                </div>
                <div class="header-right">
                    <div class="profile-section">
                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="profile-img">
                        <div class="profile-info" style="line-height: 1.2;">
                            <div class="profile-name" style="font-size: 13.5px; font-weight: 600; color: #333;">
                                <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Hoàng Anh'}" />
                            </div>
                            <div class="profile-role" style="font-size: 10.5px; color: var(--cz-text-muted); font-weight: 500;">Quản trị viên</div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="content-container">
                <div class="form-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h1 class="page-title m-0">QUẢN LÝ VAI TRÒ & PHÂN QUYỀN ĐỘNG</h1>
                        <button type="button" class="btn btn-cz-primary" data-bs-toggle="modal" data-bs-target="#addFeatureModal">
                            <i class="fa-solid fa-circle-plus"></i> Khai báo tính năng mới
                        </button>
                    </div>
                    <p class="page-subtitle">Bật / Tắt trạng thái để cấu hình real-time danh mục quyền hạn truy cập của các nhóm nhân sự</p>

                    <div class="role-tabs-container">
                        <c:if test="${not empty ALL_ROLES}">
                            <c:forEach items="${ALL_ROLES}" var="r">
                                <c:if test="${r.roleId ne 'CUSTOMER'}">
                                    <a href="${pageContext.request.contextPath}/admin/role-permissions?roleId=${r.roleId}" 
                                       class="role-tab-item ${CURRENT_ROLE_ID eq r.roleId ? 'active-tab' : ''}">
                                        ${r.roleId}
                                    </a>
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="table-card p-4" style="background: transparent; box-shadow: none; border: none;">
                        <c:choose>
                            <c:when test="${not empty SCREEN_LIST}">
                                <c:set var="currentGroup" value="" />
                                <c:forEach items="${SCREEN_LIST}" var="s">
                                    <c:set var="groupName" value="${s.screenName.contains(':') ? s.screenName.split(':')[0] : 'Tính năng khác'}" />
                                    <c:set var="isMainFeature" value="${!s.screenName.contains(':')}" />

                                    <c:if test="${groupName != currentGroup}">
                                        <div class="feature-group-header">
                                            <i class="fa-solid fa-folder"></i> ${groupName}
                                        </div>
                                        <c:set var="currentGroup" value="${groupName}" />
                                    </c:if>

                                    <div class="feature-matrix-row" id="row-${s.screenId}">
                                        <div class="feature-meta-info ${isMainFeature ? 'feature-main' : 'feature-sub'}">
                                            <i class="fa-solid ${isMainFeature ? 'fa-star' : 'fa-caret-right'}"></i> 
                                            <span>${s.screenName.contains(':') ? s.screenName.split(':')[1] : s.screenName}</span>
                                        </div>

                                        <div class="d-flex align-items-center gap-2">
                                            <div class="toggle-switch-box">
                                                <button type="button" onclick="updatePermission('${CURRENT_ROLE_ID}', '${s.screenId}', 'on')" 
                                                        class="toggle-btn btn-on ${s.activated ? 'on-active' : ''}">On</button>
                                                <button type="button" onclick="updatePermission('${CURRENT_ROLE_ID}', '${s.screenId}', 'off')" 
                                                        class="toggle-btn btn-off ${!s.activated ? 'off-active' : ''}">Off</button>
                                            </div>

                                            <button type="button" class="btn-action-edit" 
                                                    onclick="openEditModal('${s.screenId}', '${s.screenName}', '${s.endpointUrl}')" title="Chỉnh sửa tính năng">
                                                <i class="fa-regular fa-pen-to-square" style="font-size: 13px;"></i>
                                            </button>

                                            <a href="${pageContext.request.contextPath}/admin/role-permissions?action=delete-feature&id=${s.screenId}&roleId=${CURRENT_ROLE_ID}" 
                                               class="btn-action-delete"
                                               onclick="return confirm('Bạn có chắc chắn muốn ẩn vĩnh viễn tính năng này khỏi danh mục quản trị không?')" title="Xóa mềm tính năng">
                                                <i class="fa-regular fa-trash-can" style="font-size: 13px;"></i>
                                            </a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                        </c:choose>
                    </div>

                    <c:if test="${not empty HIDDEN_SCREEN_LIST}">
                        <div class="mt-5 border-top pt-4">
                            <h5 class="fw-bold text-danger text-uppercase" style="font-size: 14px; letter-spacing: 0.5px;">
                                <i class="fa-solid fa-eye-slash me-2"></i> Kho lưu trữ tính năng đã ẩn (Xóa mềm)
                            </h5>
                            <div class="table-card p-3 mt-3 bg-light border">
                                <c:forEach items="${HIDDEN_SCREEN_LIST}" var="hs">
                                    <div class="d-flex justify-content-between align-items-center p-2 border-bottom last-border-0">
                                        <div style="font-size: 14px;">
                                            <i class="fa-solid fa-ghost text-muted me-2"></i>
                                            <span class="fw-bold text-secondary">${hs.screenName}</span> 
                                        </div>
                                        <a href="${pageContext.request.contextPath}/admin/role-permissions?action=restore-feature&id=${hs.screenId}&roleId=${CURRENT_ROLE_ID}" 
                                           class="btn btn-sm btn-outline-success px-3" style="font-size: 12px; font-weight: 600; border-radius: 6px;">
                                            <i class="fa-solid fa-trash-arrow-up me-1"></i> Khôi phục hiển thị
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                </div>
            </div>
        </div>

        <div class="modal fade" id="addFeatureModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                    <form action="${pageContext.request.contextPath}/admin/role-permissions" method="POST">
                        <input type="hidden" name="action" value="add-feature">
                        <input type="hidden" name="roleId" value="${CURRENT_ROLE_ID}">
                        
                        <div class="modal-header" style="background-color: #f1ede8; border-top-left-radius: 12px; border-top-right-radius: 12px;">
                            <h5 class="modal-title fw-bold" style="color: var(--cz-primary); font-size: 16px;"><i class="fa-solid fa-folder-plus me-2"></i>Khai báo tính năng hệ thống mới</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-4" style="font-size: 14px;">
                            <div class="mb-3">
                                <label class="form-label fw-bold mb-1">Mã tính năng (Screen ID) <span class="text-danger">*</span></label>
                                <input type="text" name="screenId" class="form-control" placeholder="Ví dụ: FEAT_VOUCHER_VIEW" style="text-transform: uppercase; height: 44px;" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold mb-1">Tên hiển thị phân nhóm <span class="text-danger">*</span></label>
                                <input type="text" name="screenName" class="form-control" placeholder="Ví dụ: Khuyến mãi:Xem danh sách" style="height: 44px;" required>
                                <div class="text-muted mt-1" style="font-size: 12px;">Cú pháp bắt buộc: <b class="text-dark">Tên Nhóm:Tên Chức Năng</b></div>
                            </div>
                            <div class="mb-2">
                                <label class="form-label fw-bold mb-1">Đường dẫn bảo mật (Endpoint URL) <span class="text-danger">*</span></label>
                                <input type="text" name="endpointUrl" class="form-control" placeholder="Ví dụ: /admin/voucher?action=list" style="height: 44px;" required>
                            </div>
                        </div>
                        <div class="modal-footer" style="background-color: #faf9f7;">
                            <button type="button" class="btn btn-sm btn-secondary px-3" style="height: 36px;" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-sm btn-cz-primary px-3" style="height: 36px;"><i class="fa-solid fa-floppy-disk me-1"></i>Khai báo</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="modal fade" id="editFeatureModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content" style="border-radius: 12px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                    <form action="${pageContext.request.contextPath}/admin/role-permissions" method="POST">
                        <input type="hidden" name="action" value="edit-feature">
                        <input type="hidden" name="roleId" value="${CURRENT_ROLE_ID}">
                        
                        <div class="modal-header" style="background-color: #f1ede8; border-top-left-radius: 12px; border-top-right-radius: 12px;">
                            <h5 class="modal-title fw-bold" style="color: var(--cz-primary); font-size: 16px;"><i class="fa-regular fa-pen-to-square me-2"></i>Chỉnh sửa cấu hình tính năng</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body p-4" style="font-size: 14px;">
                            <div class="mb-3">
                                <label class="form-label fw-bold mb-1">Mã tính năng (Screen ID)</label>
                                <input type="text" id="editScreenId" name="screenId" class="form-control bg-light" style="height: 44px; font-weight: 600;" readonly>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold mb-1">Tên hiển thị phân nhóm <span class="text-danger">*</span></label>
                                <input type="text" id="editScreenName" name="screenName" class="form-control" style="height: 44px;" required>
                                <div class="text-muted mt-1" style="font-size: 12px;">Cú pháp bắt buộc: <b class="text-dark">Tên Nhóm:Tên Chức Năng</b></div>
                            </div>
                            <div class="mb-2">
                                <label class="form-label fw-bold mb-1">Đường dẫn bảo mật (Endpoint URL) <span class="text-danger">*</span></label>
                                <input type="text" id="editEndpointUrl" name="endpointUrl" class="form-control" style="height: 44px;" required>
                            </div>
                        </div>
                        <div class="modal-footer" style="background-color: #faf9f7;">
                            <button type="button" class="btn btn-sm btn-secondary px-3" style="height: 36px;" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-sm btn-cz-primary px-3" style="height: 36px;"><i class="fa-solid fa-floppy-disk me-1"></i>Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

        <script>
            // POP-UP ĐÓN NHẬN CHUỖI SUCCESS/ERROR SESSION ĐƯỢC REDIRECT TỪ SERVLET VỀ
            <c:if test="${not empty sessionScope.successMessage}">
                Toastify({
                    text: "${sessionScope.successMessage}",
                    duration: 3500,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: {
                        background: "linear-gradient(to right, #3f5f36, #5a854e)"
                    }
                }).showToast();
                <c:remove var="successMessage" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.errorMessage}">
                Toastify({
                    text: "${sessionScope.errorMessage}",
                    duration: 3500,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: {
                        background: "linear-gradient(to right, #ff5f6d, #ffc371)"
                    }
                }).showToast();
                <c:remove var="errorMessage" scope="session" />
            </c:if>

            // HÀM JS ĐỔ DỮ LIỆU CŨ VÀO FORM MODAL SỬA
            function openEditModal(id, name, url) {
                document.getElementById('editScreenId').value = id;
                document.getElementById('editScreenName').value = name;
                document.getElementById('editEndpointUrl').value = url;
                
                var myModal = new bootstrap.Modal(document.getElementById('editFeatureModal'));
                myModal.show();
            }

            function updatePermission(roleId, screenId, action) {
                const url = "${pageContext.request.contextPath}/admin/role-permissions?action=" + action + "&roleId=" + roleId + "&screenId=" + screenId;

                fetch(url, {
                    method: 'GET',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                })
                .then(response => response.text())
                .then(data => {
                    if (data.trim() === "SUCCESS") {
                        const row = document.getElementById("row-" + screenId);
                        const btnOn = row.querySelector('.btn-on');
                        const btnOff = row.querySelector('.btn-off');

                        if (action === 'on') {
                            btnOn.classList.add('on-active');
                            btnOff.classList.remove('off-active');
                        } else {
                            btnOn.classList.remove('on-active');
                            btnOff.classList.add('off-active');
                        }

                        Toastify({
                            text: "Cập nhật quyền thành công!",
                            duration: 2500,
                            close: true,
                            gravity: "top",
                            position: "right",
                            style: {
                                background: "linear-gradient(to right, #3f5f36, #5a854e)"
                            }
                        }).showToast();
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
            }
        </script>
    </body>
</html>