<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CakeZone Admin - Vai trò & Quyền hạn</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

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

            /* Hàng nút bấm chọn Vai trò nằm ngang chuẩn Mockup bản vẽ của bạn */
            .role-tabs-container { display: flex; background: #fff; border: 2px solid #222; border-radius: 6px; overflow: hidden; width: fit-content; margin-bottom: 35px; }
            .role-tab-item { padding: 14px 35px; font-weight: 700; text-transform: uppercase; text-decoration: none; color: #222; border-right: 2px solid #222; font-size: 13.5px; transition: all 0.2s; }
            .role-tab-item:last-child { border-right: none; }
            .role-tab-item.active-tab { background-color: #ced4da; color: #000; } /* Sáng xám active */

            /* Cột Tính năng xếp dọc */
            .table-card { background-color: var(--cz-card-bg); border-radius: 12px; border: 1px solid var(--cz-border-color); overflow: hidden; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02); }
            .feature-matrix-row { display: flex; justify-content: space-between; align-items: center; padding: 20px 15px; border-bottom: 1px solid var(--cz-border-color); }
            .feature-matrix-row:last-child { border-bottom: none; }
            .feature-meta-info { font-size: 16px; font-weight: 600; color: #111; display: flex; align-items: center; gap: 12px; }
            .feature-meta-info i { color: var(--cz-primary); font-size: 18px; }
            .feature-endpoint { font-size: 13px; color: #999; font-weight: 400; font-family: monospace; }

            /* Nút công tắc đôi trượt đôi On | Off của bạn */
            .toggle-switch-box { display: flex; border: 2px solid #222; border-radius: 20px; overflow: hidden; background-color: #fff; }
            .toggle-btn { padding: 6px 22px; font-size: 12.5px; font-weight: 800; text-transform: uppercase; text-decoration: none; color: #aaa; transition: all 0.2s; }
            .toggle-btn.on-active { background-color: #ced4da; color: #111; } /* On màu xám */
            .toggle-btn.off-active { background-color: #222; color: #fff; }  /* Off màu đen */
        </style>
    </head>
    <body>

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="roles" />
        </jsp:include>

        <div class="main-panel">
            <div class="top-header">
                <div class="header-left">
                    <div class="breadcrumbs">
                        <a href="#">Dashboard</a>
                        <span>&gt;</span>
                        <a href="#">System</a>
                        <span>&gt;</span>
                        <a href="#" class="active text-dark font-weight-bold">Vai trò & Quyền hạn</a>
                    </div>
                </div>
                <div class="header-right">
                    <div class="profile-section d-flex align-items-center gap-3">
                        <span class="fw-bold" style="font-size: 14px;"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Chưa đăng nhập'}" /></span>
                        <img src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde" alt="Avatar" class="rounded-circle" width="35" height="35">
                    </div>
                </div>
            </div>

            <div class="content-container">
                <div class="form-card">
                    <h1 class="page-title">QUẢN LÝ VAI TRÒ & PHÂN QUYỀN ĐỘNG</h1>
                    <p class="page-subtitle">Bật / Tắt trạng thái để kiểm soát việc Ẩn hoặc Hiện trực tiếp các danh mục tính năng trên Sidebar nội bộ</p>

          <div class="role-tabs-container">
                        <%-- 🟢 THÊM KIỂM TRA AN TOÀN: Chỉ lặp khi danh sách không trống --%>
                        <c:if test="${not empty ALL_ROLES}">
                            <c:forEach items="${ALL_ROLES}" var="r">
                                <a href="${pageContext.request.contextPath}/admin/role-permissions?action=list&roleId=${r.roleId}" 
                                   class="role-tab-item ${CURRENT_ROLE_ID eq r.roleId ? 'active-tab' : ''}">
                                    ${r.roleId}
                                </a>
                            </c:forEach>
                        </c:if>
                    </div>

                    <div class="table-card p-2">
                        <%-- 🟢 THÊM KIỂM TRA AN TOÀN: Tránh việc list rỗng gây trắng trang --%>
                        <c:choose>
                            <c:when test="${not empty SCREEN_LIST}">
                                <c:forEach items="${SCREEN_LIST}" var="s">
                                    <div class="feature-matrix-row">
                                        <div class="feature-meta-info">
                                            <i class="fa-solid fa-folder-gear"></i>
                                            <span>${s.screenName}</span>
                                            <span class="feature-endpoint">(${s.endpointUrl})</span>
                                        </div>
                                        
                                        <div class="toggle-switch-box">
                                            <a href="${pageContext.request.contextPath}/admin/role-permissions?action=toggle&roleId=${CURRENT_ROLE_ID}&screenId=${s.screenId}&status=on" 
                                               class="toggle-btn ${s.activated ? 'on-active' : ''}">
                                                On
                                            </a>
                                            <a href="${pageContext.request.contextPath}/admin/role-permissions?action=toggle&roleId=${CURRENT_ROLE_ID}&screenId=${s.screenId}&status=off" 
                                               class="toggle-btn ${!s.activated ? 'off-active' : ''}">
                                                Off
                                            </a>
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

    </body>
</html>