<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/admin-header.jsp">
        <jsp:param name="title" value="CakeZone Admin - Chi tiết bài viết" />
    </jsp:include>
    <!-- Custom styling -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/adminProductDetail.css?v=1.5">
    <style>
        .image-preview-box {
            width: 100%;
            height: 180px;
            border: 2px dashed #ccc;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            background-color: #fafafa;
            overflow: hidden;
            margin-top: 10px;
            position: relative;
        }
        .image-preview-box img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
    </style>
</head>
<body>

    <!-- Left Sidebar -->
    <jsp:include page="../common/sidebar.jsp">
        <jsp:param name="activeMenu" value="blogs" />
    </jsp:include>

    <!-- Main Content Panel -->
    <div class="main-panel">
        
        <!-- Top Header -->
        <jsp:include page="../common/top-header.jsp">
            <jsp:param name="parentMenu" value="Danh sách bài viết" />
            <jsp:param name="parentUrl" value="${pageContext.request.contextPath}/admin/blog?action=list" />
            <jsp:param name="activeMenu" value="Chi tiết bài viết" />
        </jsp:include>

        <!-- Dashboard Container -->
        <div class="content-container">
            
            <form action="${pageContext.request.contextPath}/admin/blog?action=${formAction}" method="post" enctype="multipart/form-data" id="blogForm">
                <!-- Keep track of the mode -->
                <input type="hidden" name="isEdit" value="${isEdit}">
                <input type="hidden" name="postId" value="${post.postId}">
                <input type="hidden" name="currentImageUrl" value="${post.imageUrl}">

                <!-- Page Title Area -->
                <div class="page-title-area">
                    <div>
                        <h1 class="page-title">Chi Tiết Bài Viết</h1>
                        <p class="page-subtitle">Soạn thảo, phân loại, đính kèm hình ảnh và cập nhật trạng thái hiển thị của bài viết.</p>
                    </div>
                    <div class="action-button-group">
                        <button type="submit" class="btn-cz-primary"><i class="fa-regular fa-floppy-disk me-1"></i> Lưu Lại</button>
                        <c:if test="${isEdit}">
                            <button type="button" class="btn-cz-danger" onclick="confirmDeleteBlog('${post.postId}', '${post.title}')">Xóa bài viết</button>
                        </c:if>
                    </div>
                </div>

                <c:if test="${not empty sessionScope.errorMessage or not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert" style="background-color: #fdf3f3; border-color: #fcebeb; color: #dc3545; border-radius: 8px; font-weight: 500; font-size: 14px; margin-bottom: 25px;">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i> ${not empty sessionScope.errorMessage ? sessionScope.errorMessage : error}
                        <c:remove var="errorMessage" scope="session" />
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="detail-card">
                            <h5 class="card-header-title">Thông Tin Bài Viết</h5>
                            
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label-cz">Tiêu Đề Bài Viết <span>*</span></label>
                                    <input type="text" class="form-control-cz" id="title" name="title" value="<c:out value='${post.title}' />" required placeholder="Nhập tiêu đề nổi bật cho bài viết...">
                                    <div id="error-title" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label-cz">Danh Mục Bài Viết <span>*</span></label>
                                    <select name="category" id="categorySelect" class="form-control-cz" onchange="checkCategoryOption(this)" required>
                                        <option value="" disabled ${empty post.category ? 'selected' : ''}>— Chọn danh mục —</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat}" ${post.category eq cat ? 'selected' : ''}>${cat}</option>
                                        </c:forEach>
                                        <option value="custom" style="font-weight: bold; color: var(--cz-primary);">+ Tự thêm danh mục mới...</option>
                                    </select>
                                    <div id="error-category" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                </div>

                                <div class="col-md-6" id="customCategoryGroup" style="display: none;">
                                    <label class="form-label-cz" style="color: var(--cz-primary);">Tên Danh Mục Mới <span>*</span></label>
                                    <input type="text" name="customCategory" id="customCategoryInput" class="form-control-cz" placeholder="Ví dụ: Tin Khuyến Mãi...">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label-cz">Trạng Thái Xuất Bản <span>*</span></label>
                                    <select name="status" class="form-control-cz">
                                        <option value="Active" ${post.status eq 'Active' ? 'selected' : ''}>Hiển thị (Active)</option>
                                        <option value="Hidden" ${post.status eq 'Hidden' ? 'selected' : ''}>Đang ẩn (Hidden)</option>
                                    </select>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Tóm Tắt Ngắn Gọn</label>
                                    <textarea class="form-control-cz" id="summary" name="summary" rows="3" style="height: auto; border-radius: 8px;" placeholder="Một vài dòng tóm tắt nội dung bài viết hiển thị ngoài trang chủ..."><c:out value="${post.summary}" /></textarea>
                                    <div id="error-summary" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                </div>

                                <div class="col-md-12">
                                    <label class="form-label-cz">Nội Dung Chi Tiết Bài Viết <span>*</span></label>
                                    <textarea class="form-control-cz" id="content" name="content" rows="12" style="height: auto; border-radius: 8px;" required placeholder="Nhập toàn bộ nội dung bài viết chi tiết tại đây..."><c:out value="${post.content}" /></textarea>
                                    <div id="error-content" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="detail-card">
                            <h5 class="card-header-title">Ảnh Đại Diện</h5>
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label-cz">Chọn File Ảnh</label>
                                    <input type="file" name="image" id="imageInput" class="form-control-cz" accept="image/*" onchange="previewImage(this)">
                                    <div id="error-image" class="text-danger mt-1 small" style="display: none; font-weight: 500;"></div>
                                    <div class="image-preview-box" id="previewContainer">
                                        <c:choose>
                                            <c:when test="${not empty post.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/${post.imageUrl}" alt="Current" />
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fa-regular fa-image" style="font-size: 32px; color: #ccc; margin-bottom: 8px;"></i>
                                                <span style="font-size: 12.5px; color: #aaa;">Chưa có ảnh đại diện.</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <!-- Hidden delete form -->
    <c:if test="${isEdit}">
        <form id="deleteBlogForm" action="${pageContext.request.contextPath}/admin/blog?action=delete" method="post" style="display:none;">
            <input type="hidden" name="id" value="${post.postId}">
        </form>
    </c:if>

    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function checkCategoryOption(select) {
            const customGroup = document.getElementById('customCategoryGroup');
            const customInput = document.getElementById('customCategoryInput');
            if (select.value === 'custom') {
                customGroup.style.display = 'block';
                customInput.setAttribute('required', 'required');
                customInput.focus();
            } else {
                customGroup.style.display = 'none';
                customInput.removeAttribute('required');
                customInput.value = '';
            }
        }

        function previewImage(input) {
            const previewContainer = document.getElementById('previewContainer');
            const errorImage = document.getElementById('error-image');
            errorImage.style.display = 'none';
            input.classList.remove('is-invalid');

            if (input.files && input.files[0]) {
                const file = input.files[0];
                const fileName = file.name.toLowerCase();
                const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
                const hasValidExt = validExtensions.some(ext => fileName.endsWith(ext));
                if (!hasValidExt) {
                    errorImage.textContent = 'Định dạng file không hợp lệ. Chỉ chấp nhận ảnh (JPG, JPEG, PNG, GIF, WEBP).';
                    errorImage.style.display = 'block';
                    input.classList.add('is-invalid');
                    input.value = '';
                    previewContainer.innerHTML = `
                        <i class="fa-regular fa-image" style="font-size: 32px; color: #ccc; margin-bottom: 8px;"></i>
                        <span style="font-size: 12.5px; color: #aaa;">Chưa có ảnh đại diện.</span>
                    `;
                    return;
                }

                const objectUrl = URL.createObjectURL(file);
                previewContainer.innerHTML = 
                    '<img src="' + objectUrl + '" alt="Preview" onerror="this.style.display=\'none\'; document.getElementById(\'preview-error-text\').style.display=\'block\'; document.getElementById(\'file-details\').textContent = \'Tên: \' + file.name.replace(/\'/g, \'\\\\\'\') + \' | Dung lượng: \' + (file.size / 1024).toFixed(2) + \' KB | Định dạng: \' + (file.type || \'Không xác định\');" style="max-width: 100%; max-height: 100%; object-fit: contain; display: block;" />' +
                    '<div id="preview-error-text" style="display:none; text-align: center; padding: 10px;">' +
                        '<i class="fa-solid fa-triangle-exclamation" style="font-size: 28px; color: var(--cz-danger); margin-bottom: 6px;"></i>' +
                        '<span style="font-size: 12px; color: var(--cz-danger); font-weight: 600; display: block;">Tệp tin không phải hình ảnh hợp lệ hoặc bị lỗi!</span>' +
                        '<span id="file-details" style="font-size: 11.5px; color: #888; display: block; margin-top: 6px; font-weight: 500;"></span>' +
                    '</div>';
            } else {
                previewContainer.innerHTML = `
                    <c:choose>
                        <c:when test="${not empty post.imageUrl}">
                            <img src="${pageContext.request.contextPath}/${post.imageUrl}" alt="Current" style="max-width: 100%; max-height: 100%; object-fit: contain; display: block;" />
                        </c:when>
                        <c:otherwise>
                            <i class="fa-regular fa-image" style="font-size: 32px; color: #ccc; margin-bottom: 8px;"></i>
                            <span style="font-size: 12.5px; color: #aaa;">Chưa có ảnh đại diện.</span>
                        </c:otherwise>
                    </c:choose>
                `;
            }
        }

        function confirmDeleteBlog(id, title) {
            if (confirm("Bạn có chắc chắn muốn xóa bài viết \"" + title + "\" không? Hành động này sẽ xóa vĩnh viễn hình ảnh đại diện và dữ liệu bài viết!")) {
                document.getElementById('deleteBlogForm').submit();
            }
        }

        document.getElementById('blogForm').addEventListener('submit', function(e) {
            let hasError = false;

            const errorTitle = document.getElementById('error-title');
            const errorCategory = document.getElementById('error-category');
            const errorSummary = document.getElementById('error-summary');
            const errorContent = document.getElementById('error-content');
            const errorImage = document.getElementById('error-image');

            errorTitle.style.display = 'none';
            errorCategory.style.display = 'none';
            errorSummary.style.display = 'none';
            errorContent.style.display = 'none';
            errorImage.style.display = 'none';

            const titleInput = document.getElementById('title');
            const categorySelect = document.getElementById('categorySelect');
            const customCategoryInput = document.getElementById('customCategoryInput');
            const summaryInput = document.getElementById('summary');
            const contentInput = document.getElementById('content');
            const imageInput = document.getElementById('imageInput');

            titleInput.classList.remove('is-invalid');
            categorySelect.classList.remove('is-invalid');
            customCategoryInput.classList.remove('is-invalid');
            summaryInput.classList.remove('is-invalid');
            contentInput.classList.remove('is-invalid');
            imageInput.classList.remove('is-invalid');

            // 1. Title validation
            const titleVal = titleInput.value.trim();
            if (titleVal.length === 0) {
                errorTitle.textContent = 'Tiêu đề bài viết không được để trống.';
                errorTitle.style.display = 'block';
                titleInput.classList.add('is-invalid');
                hasError = true;
            } else if (titleVal.length < 5) {
                errorTitle.textContent = 'Tiêu đề bài viết tối thiểu phải có 5 ký tự.';
                errorTitle.style.display = 'block';
                titleInput.classList.add('is-invalid');
                hasError = true;
            } else if (titleVal.length > 200) {
                errorTitle.textContent = 'Tiêu đề bài viết không được vượt quá 200 ký tự.';
                errorTitle.style.display = 'block';
                titleInput.classList.add('is-invalid');
                hasError = true;
            }

            // 2. Category validation
            const catVal = categorySelect.value;
            if (!catVal) {
                errorCategory.textContent = 'Vui lòng chọn danh mục bài viết.';
                errorCategory.style.display = 'block';
                categorySelect.classList.add('is-invalid');
                hasError = true;
            } else if (catVal === 'custom') {
                const customVal = customCategoryInput.value.trim();
                if (customVal.length === 0) {
                    errorCategory.textContent = 'Vui lòng nhập tên danh mục bài viết mới.';
                    errorCategory.style.display = 'block';
                    customCategoryInput.classList.add('is-invalid');
                    hasError = true;
                } else if (customVal.length < 2) {
                    errorCategory.textContent = 'Tên danh mục mới tối thiểu 2 ký tự.';
                    errorCategory.style.display = 'block';
                    customCategoryInput.classList.add('is-invalid');
                    hasError = true;
                } else if (customVal.length > 50) {
                    errorCategory.textContent = 'Tên danh mục mới tối đa 50 ký tự.';
                    errorCategory.style.display = 'block';
                    customCategoryInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            // 3. Summary validation
            const summaryVal = summaryInput.value.trim();
            if (summaryVal.length > 500) {
                errorSummary.textContent = 'Tóm tắt bài viết không được vượt quá 500 ký tự.';
                errorSummary.style.display = 'block';
                summaryInput.classList.add('is-invalid');
                hasError = true;
            }

            // 4. Content validation
            const contentVal = contentInput.value.trim();
            if (contentVal.length === 0) {
                errorContent.textContent = 'Nội dung chi tiết bài viết không được để trống.';
                errorContent.style.display = 'block';
                contentInput.classList.add('is-invalid');
                hasError = true;
            } else if (contentVal.length < 10) {
                errorContent.textContent = 'Nội dung bài viết quá ngắn (tối thiểu 10 ký tự).';
                errorContent.style.display = 'block';
                contentInput.classList.add('is-invalid');
                hasError = true;
            }

            // 5. Image validation if selected
            if (imageInput.files && imageInput.files[0]) {
                const file = imageInput.files[0];
                const fileName = file.name.toLowerCase();
                const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
                const hasValidExt = validExtensions.some(ext => fileName.endsWith(ext));
                if (!hasValidExt) {
                    errorImage.textContent = 'Chỉ chấp nhận file ảnh dạng JPG, JPEG, PNG, GIF hoặc WEBP.';
                    errorImage.style.display = 'block';
                    imageInput.classList.add('is-invalid');
                    hasError = true;
                }
            }

            if (hasError) {
                e.preventDefault();
                return false;
            }
        });
    </script>
</body>
</html>
