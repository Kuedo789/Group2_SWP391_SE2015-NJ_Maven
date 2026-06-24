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
        <link href="${pageContext.request.contextPath}/assets/css/admin-global.css?v=1.1" rel="stylesheet">
        <style>
            /* Specific styles for the form card to keep the global CSS clean */
            .form-card {
                background-color: var(--surface-white);
                border-radius: 16px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.03);
                border: 1px solid var(--border-soft);
                padding: 40px;
                max-width: 800px;
                margin: 0 auto; 
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

        <jsp:include page="/common/sidebar.jsp">
            <jsp:param name="activeMenu" value="categories" />
        </jsp:include>

        <main class="main-wrapper">

            <c:set var="pageTitle" value="Thêm Danh Mục" scope="request" />
            <jsp:include page="/common/admin-navbar.jsp" />

            <div class="content">
                <div class="page-header">
                    <div class="page-title">
                        <h2>Thêm danh mục mới</h2>
                        <p>Create a new category for products, ingredients, or accessories.</p>
                    </div>
                </div>

                <div class="form-card">
                    <form action="${pageContext.request.contextPath}/admin/categories" method="POST">
                        
                        <input type="hidden" name="formAction" value="add">

                        <div class="form-group">
                            <label class="form-label" for="categoryType">Phân Loại (Type) <span style="color: #ef4444;">*</span></label>
                            <select id="categoryType" name="categoryType" class="form-control" required>
                                <option value="" disabled selected>-- Chọn phân loại --</option>
                                <option value="Sản phẩm chính">Sản phẩm chính (Bánh kem, Sweetbox...)</option>
                                <option value="Nguyên liệu">Nguyên liệu (Cốt bánh, Kem phủ...)</option>
                                <option value="Phụ kiện">Phụ kiện & Bao bì (Nến, Hộp, Pháo bông...)</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="categoryId">Mã Danh Mục (Category ID) <span style="color: #ef4444;">*</span></label>
                            <input 
                                type="text" 
                                id="categoryId" 
                                name="categoryId" 
                                class="form-control" 
                                placeholder="Chọn phân loại trước..." 
                                required 
                                maxlength="50"
                                pattern="^CAT[\-_][A-Z0-9\-_]+$"
                                title="Mã danh mục phải bắt đầu bằng 'CAT-' hoặc 'CAT_' và chỉ chứa chữ in hoa, số, dấu gạch ngang hoặc dấu gạch dưới."
                                style="text-transform: uppercase;"
                            >
                            <small style="color: var(--text-muted); font-size: 12px; margin-top: 5px; display: block;">Mã sẽ tự động tạo tiền tố dựa trên Phân loại. Chỉ chứa chữ in hoa, số, gạch ngang và gạch dưới.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="categoryName">Tên Danh Mục (Category Name) <span style="color: #ef4444;">*</span></label>
                            <input type="text" id="categoryName" name="categoryName" class="form-control" placeholder="Nhập tên danh mục..." required maxlength="100">
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="description">Mô Tả (Description)</label>
                            <textarea id="description" name="description" class="form-control" placeholder="Mô tả ngắn gọn về danh mục này..." maxlength="255"></textarea>
                            <small style="color: var(--text-muted); font-size: 12px; margin-top: 5px; display: block;">Lưu ý: Nhóm Nguyên liệu không hiển thị mô tả.</small>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="iconUrl">Đường dẫn Icon (Icon URL)</label>
                            <input type="text" id="iconUrl" name="iconUrl" class="form-control" placeholder="Ví dụ: assets/images/categories/icons/default.png" maxlength="255">
                            <small style="color: var(--text-muted); font-size: 12px; margin-top: 5px; display: block;">Lưu ý: Nhóm Nguyên liệu không hiển thị icon.</small>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn-primary">
                                <i class="fa-solid fa-floppy-disk"></i> Lưu Danh Mục
                            </button>
                            <a href="${pageContext.request.contextPath}/admin/categories" class="btn-secondary">
                                Hủy Bỏ
                            </a>
                        </div>

                        <script>
                            document.getElementById('categoryType').addEventListener('change', function() {
                                const type = this.value;
                                const idInput = document.getElementById('categoryId');
                                const descInput = document.getElementById('description');
                                const iconInput = document.getElementById('iconUrl');
                                
                                if (type === 'Sản phẩm chính') {
                                    idInput.value = 'CAT-PROD-';
                                    descInput.disabled = false;
                                    iconInput.disabled = false;
                                } else if (type === 'Nguyên liệu') {
                                    idInput.value = 'CAT-ING-';
                                    descInput.disabled = true;
                                    descInput.value = '';
                                    iconInput.disabled = true;
                                    iconInput.value = '';
                                } else if (type === 'Phụ kiện') {
                                    idInput.value = 'CAT-ACC-';
                                    descInput.disabled = false;
                                    iconInput.disabled = false;
                                }
                                
                                idInput.focus(); // Snap the cursor to the input box so they can finish typing
                            });
                        </script>

                    </form>
                </div>
            </div>
        </main>

    </body>
</html>