<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="/common/admin-header.jsp">
            <jsp:param name="title" value="CakeZone Admin - Vai trò & Quyền hạn" />
        </jsp:include>

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

            .main-panel { margin-left: 260px; min-height: 100vh; display: flex; flex-direction: column; }
            .content-container { padding: 35px; flex: 1; }
            .form-card { background-color: var(--cz-card-bg); border-radius: 12px; padding: 35px; border: 1px solid var(--cz-border-color); box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02); width: 100%; }
            .page-title { font-size: 26px; font-weight: 700; color: #111; margin-bottom: 4px; }
            .page-subtitle { font-size: 13.5px; color: var(--cz-text-muted); margin-bottom: 30px; }


            .profile-section { display: flex; align-items: center; gap: 10px; border-left: 1px solid var(--cz-border-color); padding-left: 20px; }
            .profile-img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid var(--cz-border-color); }

            .role-tabs-container { display: flex; background: #fff; border: 2px solid #222; border-radius: 6px; overflow: hidden; width: fit-content; margin-bottom: 35px; }
            .role-tab-item { padding: 14px 35px; font-weight: 700; text-transform: uppercase; text-decoration: none; color: #222; border-right: 2px solid #222; font-size: 13.5px; transition: all 0.2s; }
            .role-tab-item:last-child { border-right: none; }
            .role-tab-item.active-tab { background-color: #ced4da; color: #000; }

            .table-card { background-color: var(--cz-card-bg); border-radius: 12px; border: 1px solid var(--cz-border-color); overflow: hidden; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02); }
            .feature-matrix-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 15px; border-bottom: 1px solid var(--cz-border-color); }
            .feature-matrix-row:last-child { border-bottom: none; }
            .feature-meta-info { font-size: 16px; font-weight: 600; color: #111; display: flex; align-items: center; gap: 12px; }
            .feature-meta-info i { color: var(--cz-primary); font-size: 18px; }
            .feature-endpoint { font-size: 13px; color: #999; font-weight: 400; font-family: monospace; }

            .toggle-switch-box { display: flex; border: 2px solid #222; border-radius: 20px; overflow: hidden; background-color: #fff; }
            .toggle-btn { padding: 6px 22px; font-size: 12.5px; font-weight: 800; text-transform: uppercase; text-decoration: none; color: #aaa; transition: all 0.2s; cursor: pointer; border: none; background: none; }
            .toggle-btn.on-active { background-color: var(--cz-primary); color: #fff; }
            .toggle-btn.off-active { background-color: #222; color: #fff; }
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="roles" />
        </jsp:include>

        <div class="main-panel">
            <!-- Top Header -->
            <jsp:include page="../common/top-header.jsp">
                <jsp:param name="parentMenu" value="System" />
                <jsp:param name="activeMenu" value="Vai trò & Quyền hạn" />
            </jsp:include>

            <div class="content-container">
                <div class="form-card">
                    <h1 class="page-title">QUẢN LÝ VAI TRÒ & PHÂN QUYỀN ĐỘNG</h1>
                    <p class="page-subtitle">Bật / Tắt trạng thái để cấu hình real-time danh mục quyền hạn truy cập của các nhóm nhân sự</p>

                    <div class="role-tabs-container">
                        <c:if test="${not empty ALL_ROLES}">
                            <c:forEach items="${ALL_ROLES}" var="r">
                                <a href="${pageContext.request.contextPath}/admin/role-permissions?roleId=${r.roleId}" 
                                   class="role-tab-item ${CURRENT_ROLE_ID eq r.roleId ? 'active-tab' : ''}">
                                    ${r.roleId}
                                </a>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="table-card p-2">
                        <c:choose>
                            <c:when test="${not empty SCREEN_LIST}">
                                <c:forEach items="${SCREEN_LIST}" var="s">
                                    <div class="feature-matrix-row" id="row-${s.screenId}">
                                        <div class="feature-meta-info">
                                            <i class="fa-solid fa-folder-gear"></i>
                                            <span>${s.screenName}</span>
                                            <span class="feature-endpoint">(${s.endpointUrl})</span>
                                        </div>

                                        <div class="toggle-switch-box">
                                            <button type="button" onclick="updatePermission('${CURRENT_ROLE_ID}', '${s.screenId}', 'on')" 
                                                    class="toggle-btn btn-on ${s.activated ? 'on-active' : ''}">
                                                On
                                            </button>
                                            <button type="button" onclick="updatePermission('${CURRENT_ROLE_ID}', '${s.screenId}', 'off')" 
                                                    class="toggle-btn btn-off ${!s.activated ? 'off-active' : ''}">
                                                Off
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="p-4 text-center text-muted">Không tìm thấy dữ liệu cấu hình tính năng hợp lệ.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

        <script>
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
                            text: "Cập nhật thành công!",
                            duration: 2500,
                            close: true,
                            gravity: "top",
                            position: "right",
                            backgroundColor: "linear-gradient(to right, #3f5f36, #5a854e)"
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