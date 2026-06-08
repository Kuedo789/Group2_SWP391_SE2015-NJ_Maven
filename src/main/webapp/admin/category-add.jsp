<%-- 
    Document   : category-add
    Created on : Jun 8, 2026, 9:16:29 PM
    Author     : thais
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>CakeZone Admin - Thêm Danh Mục</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/admin-global.css" rel="stylesheet">
        <style>
            /* Specific styles for the form card to keep the global CSS clean */
            .form-card {
                background-color: var(--surface-white);
                border-radius: 16px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.03);
                border: 1px solid var(--border-soft);
                padding: 40px;
                max-width: 800px;
                margin: 0 auto; /* <--- ADD THIS LINE */
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-label {
                display: block;
                font-weight: 600;
                font-size: 14px;
                color: var(--text-dark);
                margin-bottom: 8px;
            }

            .form-control {
                width: 100%;
                padding: 12px 16px;
                border: 1px solid var(--border-soft);
                border-radius: 8px;
                font-size: 14px;
                font-family: 'Inter', sans-serif;
                background-color: var(--bg-cream);
                color: var(--text-dark);
                transition: border-color 0.3s;
                outline: none;
            }

            .form-control:focus {
                border-color: var(--primary-green);
                background-color: white;
            }

            textarea.form-control {
                resize: vertical;
                min-height: 120px;
            }

            .form-actions {
                display: flex;
                gap: 15px;
                margin-top: 30px;
                padding-top: 20px;
                border-top: 1px solid var(--border-soft);
            }

            .btn-secondary {
                background-color: white;
                color: var(--text-dark);
                border: 1px solid var(--border-soft);
                padding: 12px 24px;
                border-radius: 50px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                transition: all 0.2s;
            }

            .btn-secondary:hover {
                background-color: #f1f5f9;
                border-color: #cbd5e1;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/common/admin-sidebar.jsp" />

        <main class="main-wrapper">

            <c:set var="pageTitle" value="Thêm Danh Mục" scope="request" />
            <jsp:include page="/common/admin-navbar.jsp" />

            <div class="content">
                <div class="page-header">
                    <div class="page-title">
                        <h2>Thêm danh mục mới</h2>
                        <p>Create a new category for products or ingredients.</p>
                    </div>
                </div>

                <div class="form-card">
                    <form action="${pageContext.request.contextPath}/admin/categories" method="POST">

                        <div class="form-group">
                            <label class="form-label" for="categoryId">Mã Danh Mục (Category ID) <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="categoryId" name="categoryId" class="form-control" placeholder="VD: CAT-PROD-NEW" required maxlength="50">
                            <small style="color: var(--text-muted); font-size: 12px; margin-top: 5px; display: block;">Mã danh mục viết hoa, không dấu, không khoảng trắng.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="categoryName">Tên Danh Mục (Category Name) <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="categoryName" name="categoryName" class="form-control" placeholder="Nhập tên danh mục..." required maxlength="100">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="categoryType">Phân Loại (Type) <span style="color: #ef4444;">*</span></label>
                            <select id="categoryType" name="categoryType" class="form-control" required>
                                <option value="" disabled selected>-- Chọn phân loại --</option>
                                <option value="Sản phẩm chính">Sản phẩm chính (Dành cho Bánh, Nước...)</option>
                                <option value="Nguyên liệu">Nguyên liệu (Dành cho Kem phủ, Cốt bánh...)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="description">Mô Tả (Description)</label>
                            <textarea id="description" name="description" class="form-control" placeholder="Mô tả ngắn gọn về danh mục này..."></textarea>
                            <small style="color: var(--text-muted); font-size: 12px; margin-top: 5px; display: block;">Lưu ý: Nhóm Nguyên liệu không hiển thị mô tả.</small>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-primary">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu Danh Mục
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/categories" class="btn-secondary">
                                Hủy Bỏ
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </main>

    </body>
</html>