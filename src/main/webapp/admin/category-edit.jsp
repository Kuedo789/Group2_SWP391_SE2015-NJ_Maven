<%-- 
    Document   : category-edit
    Created on : Jun 9, 2026, 2:29:52 AM
    Author     : thais
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>CakeZone Admin - Chỉnh Sửa Danh Mục</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/admin-global.css?v=1.1" rel="stylesheet">
        <style>
            .form-card { background-color: var(--surface-white); border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.03); border: 1px solid var(--border-soft); padding: 40px; max-width: 800px; margin: 0 auto; }
            .form-group { margin-bottom: 24px; }
            .form-label { display: block; font-weight: 600; font-size: 14px; color: var(--text-dark); margin-bottom: 8px; }
            .form-control { width: 100%; padding: 12px 16px; border: 1px solid var(--border-soft); border-radius: 8px; font-size: 14px; background-color: var(--bg-cream); outline: none; }
            .form-control[readonly], .form-control:disabled { background-color: #f1f5f9; color: #64748b; cursor: not-allowed; border-color: #e2e8f0; }
            textarea.form-control { resize: vertical; min-height: 120px; }
            .form-actions { display: flex; gap: 15px; margin-top: 30px; padding-top: 20px; border-top: 1px solid var(--border-soft); }
            .btn-secondary { background-color: white; color: var(--text-dark); border: 1px solid var(--border-soft); padding: 12px 24px; border-radius: 50px; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; }
        </style>
    </head>
    <body>
        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="categories" />
        </jsp:include>
        <main class="main-wrapper">
            <c:set var="pageTitle" value="Chỉnh Sửa Danh Mục" scope="request" />
            <jsp:include page="/common/admin-navbar.jsp" />

            <div class="content">
                <div class="page-header">
                    <div class="page-title">
                        <h2>Chỉnh sửa danh mục</h2>
                        <p>Cập nhật thông tin danh mục.</p>
                    </div>
                </div>

                <div class="form-card">
                    <form action="${pageContext.request.contextPath}/admin/categories" method="POST">
                        <input type="hidden" name="formAction" value="update">
                        
                        <div class="form-group">
                            <label class="form-label">Mã Danh Mục (Category ID)</label>
                            <input type="text" name="categoryId" class="form-control" value="${category.categoryId}" readonly>
                            <small style="color: #ef4444; font-size: 12px; margin-top: 5px; display: block;">Không thể thay đổi mã danh mục vì nó liên kết với sản phẩm.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Tên Danh Mục (Category Name) *</label>
                            <input type="text" name="categoryName" class="form-control" value="${category.categoryName}" required maxlength="100">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Phân Loại (Type)</label>
                            <select class="form-control" disabled>
                                <option value="Sản phẩm chính" ${category.categoryType == 'Sản phẩm chính' ? 'selected' : ''}>Sản phẩm chính</option>
                                <option value="Nguyên liệu" ${category.categoryType == 'Nguyên liệu' ? 'selected' : ''}>Nguyên liệu</option>
                            </select>
                            <input type="hidden" name="categoryType" value="${category.categoryType}">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mô Tả (Description)</label>
                            <textarea name="description" class="form-control" ${category.categoryType == 'Nguyên liệu' ? 'disabled' : ''} maxlength="255">${category.description}</textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Đường dẫn Icon (Icon URL)</label>
                            <input type="text" name="iconUrl" class="form-control" value="${category.iconUrl}" ${category.categoryType == 'Nguyên liệu' ? 'disabled' : ''} placeholder="Ví dụ: assets/images/categories/icons/default.png" maxlength="255">
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-primary">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu Cập Nhật
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/categories" class="btn-secondary">Hủy Bỏ</a>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </body>
</html>
