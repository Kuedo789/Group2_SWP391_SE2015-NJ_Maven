<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Cake Ingredient BOM" />
    </jsp:include>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Be Vietnam Pro', sans-serif;
            background-color: #f8fafc;
            color: #1e293b;
        }
        .main-panel {
            background-color: #f8fafc;
            min-height: 100vh;
        }
        .content-container {
            padding: 30px;
        }
        .page-title-area {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 20px;
        }
        .page-title {
            font-size: 24px;
            font-weight: 800;
            color: #0f2d1e;
            margin: 0 0 6px 0;
            letter-spacing: -0.5px;
        }
        .page-subtitle {
            font-size: 14px;
            color: #64748b;
            margin: 0;
        }
        .btn-cz-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            color: #475569;
            font-weight: 600;
            font-size: 13.5px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        .btn-cz-back:hover {
            background-color: #f1f5f9;
            color: #0f2d1e;
            border-color: #cbd5e1;
        }
        
        .bom-layout {
            display: grid;
            grid-template-columns: 1fr 2.5fr;
            gap: 28px;
        }
        
        /* Product Info Card */
        .product-preview-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            overflow: hidden;
            height: fit-content;
        }
        .product-img-wrapper {
            position: relative;
            width: 100%;
            aspect-ratio: 16/10;
            background: #f1f5f9;
            overflow: hidden;
            border-bottom: 1px solid #e2e8f0;
        }
        .product-img-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .product-badge-sku {
            position: absolute;
            top: 14px;
            left: 14px;
            background: rgba(15, 45, 30, 0.85);
            backdrop-filter: blur(4px);
            color: #ffffff;
            font-size: 11px;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
            letter-spacing: 0.5px;
        }
        .product-info-body {
            padding: 24px;
        }
        .product-cat {
            font-size: 11px;
            font-weight: 700;
            color: #10b981;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }
        .product-title {
            font-size: 20px;
            font-weight: 800;
            color: #0f2d1e;
            margin: 0 0 16px 0;
            line-height: 1.3;
        }
        .product-detail-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px dashed #f1f5f9;
            font-size: 13.5px;
        }
        .product-detail-item:last-child {
            border-bottom: none;
        }
        .detail-label {
            color: #64748b;
            font-weight: 500;
        }
        .detail-value {
            font-weight: 700;
            color: #1e293b;
        }
        
        /* Ingredients BOM Card */
        .bom-table-card {
            background: #ffffff;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            padding: 28px;
        }
        .bom-header {
            margin-bottom: 20px;
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .bom-header-title {
            font-size: 16px;
            font-weight: 700;
            color: #0f2d1e;
            margin: 0;
        }
        .bom-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 24px;
        }
        .bom-table th {
            text-align: left;
            font-size: 12.5px;
            font-weight: 700;
            color: #475569;
            background-color: #f8fafc;
            padding: 12px 16px;
            border-bottom: 1px solid #e2e8f0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .bom-table td {
            padding: 16px;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
            color: #334155;
        }
        .bom-table tr:hover td {
            background-color: #fcfdfe;
        }
        .ing-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .ing-img {
            width: 38px;
            height: 38px;
            border-radius: 8px;
            object-fit: cover;
            border: 1px solid #e2e8f0;
        }
        .ing-name {
            font-weight: 600;
            color: #1e293b;
        }
        .ing-sku {
            display: block;
            font-size: 11px;
            color: #64748b;
            margin-top: 2px;
        }
        .qty-val {
            font-weight: 700;
            color: #0f2d1e;
        }
        .unit-label {
            font-size: 12px;
            color: #64748b;
            margin-left: 4px;
            font-weight: 500;
        }
        
        /* Summary Card */
        .summary-box {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 12px;
            padding: 16px 24px;
            margin-top: 10px;
        }
        .summary-label {
            font-size: 14px;
            color: #166534;
            font-weight: 600;
            margin-right: 16px;
        }
        .summary-value {
            font-size: 22px;
            font-weight: 800;
            color: #15803d;
        }
        
        .empty-bom {
            text-align: center;
            padding: 60px 20px;
            color: #64748b;
        }
        .empty-icon {
            font-size: 40px;
            color: #cbd5e1;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="products" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Sản phẩm" />
            <jsp:param name="parentUrl" value="#" />
            <jsp:param name="parentMenu2" value="Danh sách bánh kem" />
            <jsp:param name="parentUrl2" value="${pageContext.request.contextPath}/admin/product?action=list" />
            <jsp:param name="activeMenu" value="Cấu tạo nguyên liệu" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <!-- Page Title Area -->
            <div class="page-title-area">
                <div>
                    <h1 class="page-title">Cấu tạo nguyên liệu bánh</h1>
                    <p class="page-subtitle">Xem thông tin định lượng các nguyên liệu cấu tạo chi tiết của mẫu bánh kem.</p>
                </div>
                <div class="d-flex gap-2">
                    <c:if test="${sessionScope.user.roleId eq 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/admin/product?action=edit&id=${product.id}" class="btn btn-cz-primary" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; font-weight: 600; font-size: 13.5px; border-radius: 8px; text-decoration: none; color: white; background-color: #0f2d1e; border: 1px solid #0f2d1e;">
                            <i class="fa-solid fa-pen-to-square"></i> Chỉnh sửa định lượng
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/admin/product?action=list" class="btn-cz-back">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <div class="bom-layout">
                <!-- Left: Product Preview -->
                <div class="product-preview-card">
                    <div class="product-img-wrapper">
                        <c:set var="resolvedImageUrl" value="https://images.unsplash.com/photo-1578985545062-69928b1d9587" />
                        <c:if test="${not empty product.imageUrl}">
                            <c:choose>
                                <c:when test="${product.imageUrl.startsWith('http://') or product.imageUrl.startsWith('https://')}">
                                    <c:set var="resolvedImageUrl" value="${product.imageUrl}" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="resolvedImageUrl" value="${pageContext.request.contextPath}/${product.imageUrl}" />
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                        <img src="${resolvedImageUrl}" alt="${product.name}" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587';">
                        <span class="product-badge-sku">ID: ${product.id}</span>
                    </div>
                    <div class="product-info-body">
                        <div class="product-cat">${product.categoryName}</div>
                        <h2 class="product-title">${product.name}</h2>
                        
                        <div class="product-detail-item">
                            <span class="detail-label">Giá bán:</span>
                            <span class="detail-value text-success" style="font-size: 15px;">
                                <fmt:formatNumber value="${product.basePrice}" type="number" pattern="#,##0"/> đ
                            </span>
                        </div>
                        <div class="product-detail-item">
                            <span class="detail-label">Giờ công ước tính:</span>
                            <span class="detail-value">${product.estimatedLaborHours} giờ</span>
                        </div>
                        <div class="product-detail-item">
                            <span class="detail-label">Trạng thái:</span>
                            <span class="detail-value">
                                <c:choose>
                                    <c:when test="${product.status eq 'Active'}">
                                        <span class="badge bg-success bg-opacity-10 text-success px-2 py-1" style="font-size: 11px; border-radius: 4px;">Hoạt động</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary bg-opacity-10 text-secondary px-2 py-1" style="font-size: 11px; border-radius: 4px;">Ngưng bán</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Right: Ingredient BOM List -->
                <div class="bom-table-card">
                    <div class="bom-header">
                        <h5 class="bom-header-title"><i class="fa-solid fa-kitchen-set me-2"></i>Chi Tiết Định Lượng Nguyên Liệu (BOM)</h5>
                    </div>
                    
                    <c:choose>
                        <c:when test="${not empty productIngredients}">
                            <div class="table-responsive">
                                <table class="bom-table">
                                    <thead>
                                        <tr>
                                            <th>STT</th>
                                            <th style="width: 45%;">Nguyên liệu</th>
                                            <th>Định lượng sử dụng</th>
                                            <c:if test="${sessionScope.user.roleId eq 'ADMIN'}">
                                                <th>Đơn giá</th>
                                                <th>Thành tiền</th>
                                            </c:if>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${productIngredients}" varStatus="status">
                                            <tr>
                                                <td>${status.index + 1}</td>
                                                <td>
                                                    <div class="ing-cell">
                                                        <c:choose>
                                                            <c:when test="${not empty item.imageUrl}">
                                                                <c:set var="resolvedIngImg" value="${item.imageUrl}" />
                                                                <c:if test="${not (item.imageUrl.startsWith('http://') or item.imageUrl.startsWith('https://'))}">
                                                                    <c:set var="resolvedIngImg" value="${pageContext.request.contextPath}/${item.imageUrl}" />
                                                                </c:if>
                                                                <img src="${resolvedIngImg}" alt="${item.ingredientName}" class="ing-img" onerror="this.src='https://images.unsplash.com/photo-1578985545062-69928b1d9587';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div class="ing-img d-flex align-items-center justify-content-center" style="background: #e2e8f0; font-size: 11px; font-weight: bold; color: #64748b;">ING</div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <div>
                                                            <span class="ing-name">${fn:escapeXml(item.ingredientName)}</span>
                                                            <span class="ing-sku">Mã: ${item.ingredientId}</span>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="qty-val">
                                                        <fmt:formatNumber value="${item.standardGram}" type="number" pattern="#,##0.##"/>
                                                    </span>
                                                    <span class="unit-label">${item.unitMeasure}</span>
                                                </td>
                                                <c:if test="${sessionScope.user.roleId eq 'ADMIN'}">
                                                    <td>
                                                        <fmt:formatNumber value="${item.pricePerUnit}" type="number" pattern="#,##0"/> đ/${item.unitMeasure}
                                                    </td>
                                                    <td style="font-weight: 600; color: #1e293b;">
                                                        <fmt:formatNumber value="${item.standardGram * item.pricePerUnit}" type="number" pattern="#,##0"/> đ
                                                    </td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <c:if test="${sessionScope.user.roleId eq 'ADMIN'}">
                                <div class="summary-box">
                                    <span class="summary-label">Tổng chi phí nguyên liệu dự toán (BOM Cost):</span>
                                    <span class="summary-value">
                                        <fmt:formatNumber value="${bomCostTotal}" type="number" pattern="#,##0"/> đ
                                    </span>
                                </div>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-bom">
                                <i class="fa-solid fa-box-open empty-icon"></i>
                                <p style="font-weight: 500; font-size: 15px; margin: 0;">Sản phẩm chưa được thiết lập định lượng nguyên liệu.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
