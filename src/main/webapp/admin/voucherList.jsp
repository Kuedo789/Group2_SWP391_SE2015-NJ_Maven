<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Mã Giảm Giá - CakeZone Admin</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary: #4CAF50;
            --primary-dark: #388E3C;
            --bg-color: #f4f6f8;
            --surface: #ffffff;
            --text-main: #333333;
            --text-muted: #666666;
            --border: #e0e0e0;
            --danger: #dc3545;
        }

        body {
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            display: flex;
        }

        .main-content {
            flex: 1;
            padding: 20px 40px;
            margin-left: 250px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .btn {
            padding: 8px 16px;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background-color: var(--primary);
            color: white;
        }

        .btn-danger {
            background-color: var(--danger);
            color: white;
        }

        .data-table {
            width: 100%;
            background: var(--surface);
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            border-collapse: collapse;
            overflow: hidden;
        }

        .data-table th, .data-table td {
            padding: 12px 16px;
            text-align: left;
            border-bottom: 1px solid var(--border);
        }

        .data-table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: var(--text-muted);
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-active { background: #e8f5e9; color: #2e7d32; }
        .status-inactive { background: #ffebee; color: #c62828; }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal.active { display: flex; }

        .modal-content {
            background: var(--surface);
            padding: 24px;
            border-radius: 8px;
            width: 500px;
            max-width: 90%;
        }

        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-control {
            width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: 4px; box-sizing: border-box;
        }

        .alert {
            padding: 12px; border-radius: 4px; margin-bottom: 20px;
        }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

<jsp:include page="../common/sidebar.jsp">
    <jsp:param name="activeMenu" value="vouchers"/>
</jsp:include>

<div class="main-content">
    <div class="page-header">
        <h2>Quản lý Mã Giảm Giá</h2>
        <button class="btn btn-primary" onclick="openModal('createModal')">
            <i class="fa-solid fa-plus"></i> Thêm Mã Mới
        </button>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <c:remove var="successMessage" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-error">${sessionScope.errorMessage}</div>
        <c:remove var="errorMessage" scope="session"/>
    </c:if>

    <table class="data-table">
        <thead>
            <tr>
                <th>Mã CODE</th>
                <th>Giảm giá</th>
                <th>Đơn Tối Thiểu</th>
                <th>SL Còn Lại</th>
                <th>Giới hạn / User</th>
                <th>Thời gian</th>
                <th>Trạng thái</th>
                <th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="v" items="${vouchers}">
                <tr>
                    <td><strong>${v.voucherCode}</strong></td>
                    <td><fmt:formatNumber value="${v.discountAmount}" type="number"/>đ</td>
                    <td><fmt:formatNumber value="${v.minOrderValue}" type="number"/>đ</td>
                    <td>${v.totalQuantity}</td>
                    <td>${v.usagePerUser} lần</td>
                    <td style="font-size: 13px;">
                        <fmt:formatDate value="${v.startDate}" pattern="dd/MM/yyyy"/> - 
                        <fmt:formatDate value="${v.endDate}" pattern="dd/MM/yyyy"/>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${v.active}">
                                <span class="status-badge status-active">Hoạt động</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-badge status-inactive">Khóa</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/admin/vouchers?action=toggle&code=${v.voucherCode}&status=${!v.active}" 
                           class="btn" style="background: #e0e0e0; color: #333; padding: 4px 8px; font-size: 12px;">
                           <i class="fa-solid fa-power-off"></i>
                        </a>
                        <button class="btn" style="background: #ffc107; color: #333; padding: 4px 8px; font-size: 12px;"
                            onclick="openEditModal('${v.voucherCode}', '${v.discountAmount}', '${v.minOrderValue}', '${v.totalQuantity}', '${v.usagePerUser}', '${v.requiredTierId}', '${v.startDate}', '${v.endDate}', ${v.active})">
                            <i class="fa-solid fa-pen"></i>
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/vouchers?action=delete&code=${v.voucherCode}" 
                           onclick="return confirm('Bạn có chắc chắn muốn xóa mã ${v.voucherCode}?');"
                           class="btn btn-danger" style="padding: 4px 8px; font-size: 12px;">
                           <i class="fa-solid fa-trash"></i>
                        </a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<!-- Create Modal -->
<div class="modal" id="createModal">
    <div class="modal-content">
        <h3>Thêm Mã Giảm Giá</h3>
        <form action="${pageContext.request.contextPath}/admin/vouchers" method="POST">
            <input type="hidden" name="action" value="create">
            <div class="form-group">
                <label>Mã Voucher (Code)</label>
                <input type="text" name="voucherCode" class="form-control" required style="text-transform: uppercase;">
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Tiền giảm (VNĐ)</label>
                    <input type="number" name="discountAmount" class="form-control" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Đơn Tối Thiểu (VNĐ)</label>
                    <input type="number" name="minOrderValue" class="form-control" required>
                </div>
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Tổng Số Lượng (Lượt)</label>
                    <input type="number" name="totalQuantity" class="form-control" value="100" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Giới Hạn / User</label>
                    <input type="number" name="usagePerUser" class="form-control" value="1" required>
                </div>
            </div>
            <div class="form-group">
                <label>Hạng Yêu Cầu (Tier ID: 1-MEMBER, 2-BRONZE, 3-SILVER, 4-GOLD, 5-DIAMOND)</label>
                <input type="number" name="requiredTierId" class="form-control" value="1" min="1" max="5" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Ngày Bắt Đầu</label>
                    <input type="date" name="startDate" class="form-control" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Ngày Kết Thúc</label>
                    <input type="date" name="endDate" class="form-control" required>
                </div>
            </div>
            <div class="form-group">
                <label><input type="checkbox" name="isActive" value="true" checked> Kích hoạt ngay</label>
            </div>
            <div style="text-align: right; margin-top: 20px;">
                <button type="button" class="btn" onclick="closeModal('createModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu Voucher</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal" id="editModal">
    <div class="modal-content">
        <h3>Chỉnh Sửa Mã Giảm Giá</h3>
        <form action="${pageContext.request.contextPath}/admin/vouchers" method="POST">
            <input type="hidden" name="action" value="update">
            <div class="form-group">
                <label>Mã Voucher (Không thể sửa code)</label>
                <input type="text" name="voucherCode" id="editCode" class="form-control" readonly style="background: #eee;">
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Tiền giảm (VNĐ)</label>
                    <input type="number" name="discountAmount" id="editDiscount" class="form-control" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Đơn Tối Thiểu (VNĐ)</label>
                    <input type="number" name="minOrderValue" id="editMinOrder" class="form-control" required>
                </div>
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Tổng Số Lượng (Lượt)</label>
                    <input type="number" name="totalQuantity" id="editQuantity" class="form-control" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Giới Hạn / User</label>
                    <input type="number" name="usagePerUser" id="editUsage" class="form-control" required>
                </div>
            </div>
            <div class="form-group">
                <label>Hạng Yêu Cầu (Tier ID)</label>
                <input type="number" name="requiredTierId" id="editTier" class="form-control" min="1" max="5" required>
            </div>
            <div style="display: flex; gap: 10px;">
                <div class="form-group" style="flex:1;">
                    <label>Ngày Bắt Đầu</label>
                    <input type="date" name="startDate" id="editStart" class="form-control" required>
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Ngày Kết Thúc</label>
                    <input type="date" name="endDate" id="editEnd" class="form-control" required>
                </div>
            </div>
            <div class="form-group">
                <label><input type="checkbox" name="isActive" id="editActive" value="true"> Hoạt động</label>
            </div>
            <div style="text-align: right; margin-top: 20px;">
                <button type="button" class="btn" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
function openModal(id) {
    document.getElementById(id).classList.add('active');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}
function openEditModal(code, discount, min, qty, usage, tier, start, end, active) {
    document.getElementById('editCode').value = code;
    document.getElementById('editDiscount').value = parseFloat(discount);
    document.getElementById('editMinOrder').value = parseFloat(min);
    document.getElementById('editQuantity').value = qty;
    document.getElementById('editUsage').value = usage;
    document.getElementById('editTier').value = tier;
    document.getElementById('editStart').value = start;
    document.getElementById('editEnd').value = end;
    document.getElementById('editActive').checked = active;
    openModal('editModal');
}
</script>

</body>
</html>
