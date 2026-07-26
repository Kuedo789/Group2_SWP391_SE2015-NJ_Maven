<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    .category-icon-picker {
        padding: 18px;
        border: 1px solid var(--border-soft);
        border-radius: 12px;
        background: #f8fafc;
    }
    .icon-source-actions {
        display: flex;
        gap: 10px;
        margin-bottom: 14px;
    }
    .icon-source-button,
    .icon-file-button {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 9px 16px;
        border: 1px solid #cbd5e1;
        border-radius: 8px;
        background: #fff;
        color: #334155;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        transition: all .18s ease;
    }
    .icon-source-button.active {
        border-color: var(--primary-green);
        background: var(--primary-green);
        color: #fff;
    }
    .icon-file-row {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-wrap: wrap;
    }
    .icon-file-name {
        color: #64748b;
        font-size: 13px;
    }
    .icon-preview-wrap {
        display: none;
        align-items: center;
        gap: 14px;
        margin-top: 14px;
        padding: 12px;
        border: 1px dashed #cbd5e1;
        border-radius: 10px;
        background: #fff;
    }
    .icon-preview-wrap.visible {
        display: flex;
    }
    .icon-preview {
        width: 72px;
        height: 72px;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        background: #fff;
        object-fit: contain;
    }
    .icon-picker-error {
        display: none;
        margin-top: 9px;
        color: #dc2626;
        font-size: 12px;
        font-weight: 500;
    }
    .icon-picker-error.visible {
        display: block;
    }
    .category-icon-picker.disabled {
        opacity: .55;
        pointer-events: none;
    }
</style>

<div class="form-group" id="categoryIconGroup">
    <label class="form-label">Icon danh mục</label>

    <c:if test="${param.error == 'icon_too_large'
                  || param.error == 'icon_dimensions_too_large'
                  || param.error == 'invalid_icon_type'
                  || param.error == 'invalid_icon_url'}">
        <div class="icon-picker-error visible" role="alert">
            <c:choose>
                <c:when test="${param.error == 'icon_too_large'}">Ảnh vượt quá dung lượng tối đa 2 MB.</c:when>
                <c:when test="${param.error == 'icon_dimensions_too_large'}">Kích thước ảnh không được vượt quá 2048 × 2048 px.</c:when>
                <c:when test="${param.error == 'invalid_icon_type'}">File không phải ảnh PNG, JPG, JPEG hoặc GIF hợp lệ.</c:when>
                <c:when test="${param.error == 'invalid_icon_url'}">URL ảnh không hợp lệ. Chỉ dùng HTTP(S), assets/images/... hoặc uploads/....</c:when>
            </c:choose>
        </div>
    </c:if>

    <div class="category-icon-picker" id="categoryIconPicker"
         data-initial-url="<c:out value="${category.iconUrl}" />">
        <input type="hidden" name="iconMode" id="iconMode" value="url">

        <div class="icon-source-actions">
            <button type="button" class="icon-source-button active" id="useIconUrlButton">
                <i class="fa-solid fa-link"></i> Dùng URL
            </button>
            <button type="button" class="icon-source-button" id="uploadIconButton">
                <i class="fa-solid fa-upload"></i> Tải ảnh từ máy
            </button>
        </div>

        <div id="iconUrlPanel">
            <input type="text" id="iconUrl" name="iconUrl" class="form-control"
                   value="<c:out value="${category.iconUrl}" />"
                   placeholder="https://example.com/icon.png hoặc assets/images/categories/icon.png"
                   maxlength="255" autocomplete="off">
        </div>

        <div id="iconUploadPanel" style="display:none;">
            <div class="icon-file-row">
                <input type="file" id="iconFile" name="iconFile"
                       accept=".png,.jpg,.jpeg,.gif,image/png,image/jpeg,image/gif"
                       style="display:none;">
                <label for="iconFile" class="icon-file-button">
                    <i class="fa-regular fa-image"></i> Chọn ảnh
                </label>
                <span class="icon-file-name" id="iconFileName">Chưa chọn file</span>
            </div>
            <small style="display:block;margin-top:8px;color:#64748b;font-size:12px;">
                PNG, JPG, JPEG hoặc GIF · tối đa 2 MB · tối đa 2048 × 2048 px.
            </small>
        </div>

        <div class="icon-picker-error" id="iconPickerError" role="alert"></div>

        <div class="icon-preview-wrap" id="iconPreviewWrap">
            <img class="icon-preview" id="iconPreview" alt="Xem trước icon">
            <div>
                <strong style="display:block;font-size:13px;color:#334155;">Xem trước</strong>
                <small style="color:#64748b;font-size:12px;">Ảnh sẽ được thu gọn theo khu vực hiển thị.</small>
            </div>
        </div>
    </div>

    <small style="color:var(--text-muted);font-size:12px;margin-top:7px;display:block;">
        Với ảnh trên máy tính, hãy dùng nút “Tải ảnh từ máy”; không nhập đường dẫn C:\ hoặc file://.
        Nhóm Nguyên liệu không hiển thị icon.
    </small>
</div>

<script>
    (function () {
        const MAX_FILE_SIZE = 2 * 1024 * 1024;
        const MAX_DIMENSION = 2048;
        const ALLOWED_TYPES = ['image/png', 'image/jpeg', 'image/gif'];
        const contextPath = '${pageContext.request.contextPath}';

        const picker = document.getElementById('categoryIconPicker');
        const modeInput = document.getElementById('iconMode');
        const urlButton = document.getElementById('useIconUrlButton');
        const uploadButton = document.getElementById('uploadIconButton');
        const urlPanel = document.getElementById('iconUrlPanel');
        const uploadPanel = document.getElementById('iconUploadPanel');
        const urlInput = document.getElementById('iconUrl');
        const fileInput = document.getElementById('iconFile');
        const fileName = document.getElementById('iconFileName');
        const errorBox = document.getElementById('iconPickerError');
        const previewWrap = document.getElementById('iconPreviewWrap');
        const preview = document.getElementById('iconPreview');
        let fileIsValid = true;
        let previewObjectUrl = null;

        function showError(message) {
            errorBox.textContent = message || '';
            errorBox.classList.toggle('visible', Boolean(message));
        }

        function resolvePreviewUrl(value) {
            if (/^https?:\/\//i.test(value)) return value;
            return contextPath + '/' + value.replace(/^\/+/, '');
        }

        function showPreview(source) {
            if (!source) {
                preview.removeAttribute('src');
                previewWrap.classList.remove('visible');
                return;
            }
            preview.onload = function () {
                previewWrap.classList.add('visible');
                showError('');
            };
            preview.onerror = function () {
                previewWrap.classList.remove('visible');
                if (modeInput.value === 'url') {
                    showError('Không thể tải ảnh từ URL này.');
                }
            };
            preview.src = source;
        }

        function setMode(mode) {
            modeInput.value = mode;
            const useUpload = mode === 'upload';
            urlButton.classList.toggle('active', !useUpload);
            uploadButton.classList.toggle('active', useUpload);
            urlPanel.style.display = useUpload ? 'none' : 'block';
            uploadPanel.style.display = useUpload ? 'block' : 'none';
            showError('');

            if (!useUpload) {
                fileInput.value = '';
                fileName.textContent = 'Chưa chọn file';
                fileIsValid = true;
                showPreview(urlInput.value.trim()
                        ? resolvePreviewUrl(urlInput.value.trim()) : '');
            } else if (!fileInput.files.length) {
                showPreview('');
            }
        }

        function isValidIconUrl(value) {
            if (!value) return true;
            if (value.length > 255 || value.includes('..')) return false;

            if (/^https?:\/\//i.test(value)) {
                try {
                    new URL(value);
                    return true;
                } catch (e) {
                    return false;
                }
            }
            return /^\/?(assets\/images|uploads)\/[A-Za-z0-9._/-]+\.(png|jpe?g|gif|webp)$/i.test(value);
        }

        urlButton.addEventListener('click', function () { setMode('url'); });
        uploadButton.addEventListener('click', function () { setMode('upload'); });

        urlInput.addEventListener('change', function () {
            const value = this.value.trim();
            if (!isValidIconUrl(value)) {
                showError('URL phải là HTTP(S) hoặc đường dẫn assets/images/... hay uploads/... của một file ảnh.');
                showPreview('');
                return;
            }
            showError('');
            showPreview(value ? resolvePreviewUrl(value) : '');
        });

        fileInput.addEventListener('change', function () {
            const file = this.files && this.files[0];
            fileIsValid = false;
            showError('');
            showPreview('');

            if (!file) {
                fileName.textContent = 'Chưa chọn file';
                fileIsValid = true;
                return;
            }
            fileName.textContent = file.name;
            if (!ALLOWED_TYPES.includes(file.type)) {
                showError('Chỉ chấp nhận ảnh PNG, JPG, JPEG hoặc GIF.');
                this.value = '';
                return;
            }
            if (file.size > MAX_FILE_SIZE) {
                showError('Ảnh vượt quá dung lượng tối đa 2 MB.');
                this.value = '';
                return;
            }

            if (previewObjectUrl) URL.revokeObjectURL(previewObjectUrl);
            previewObjectUrl = URL.createObjectURL(file);
            const probe = new Image();
            probe.onload = function () {
                if (probe.naturalWidth > MAX_DIMENSION || probe.naturalHeight > MAX_DIMENSION) {
                    showError('Kích thước ảnh không được vượt quá 2048 × 2048 px.');
                    fileInput.value = '';
                    URL.revokeObjectURL(previewObjectUrl);
                    previewObjectUrl = null;
                    return;
                }
                fileIsValid = true;
                showPreview(previewObjectUrl);
            };
            probe.onerror = function () {
                showError('File đã chọn không phải ảnh hợp lệ.');
                fileInput.value = '';
                URL.revokeObjectURL(previewObjectUrl);
                previewObjectUrl = null;
            };
            probe.src = previewObjectUrl;
        });

        window.setCategoryIconEnabled = function (enabled) {
            picker.classList.toggle('disabled', !enabled);
            urlInput.disabled = !enabled;
            fileInput.disabled = !enabled;
            urlButton.disabled = !enabled;
            uploadButton.disabled = !enabled;
            if (!enabled) {
                urlInput.value = '';
                fileInput.value = '';
                showPreview('');
                showError('');
            }
        };

        const form = picker.closest('form');
        form.addEventListener('submit', function (event) {
            if (picker.classList.contains('disabled')) return;
            if (modeInput.value === 'upload') {
                if (!fileIsValid) {
                    event.preventDefault();
                    showError('Vui lòng chờ kiểm tra ảnh hoặc chọn một ảnh hợp lệ.');
                }
                return;
            }

            const value = urlInput.value.trim();
            if (!isValidIconUrl(value)) {
                event.preventDefault();
                showError('URL ảnh không hợp lệ.');
                urlInput.focus();
            }
        });

        const initialUrl = picker.dataset.initialUrl || '';
        if (initialUrl) showPreview(resolvePreviewUrl(initialUrl));
    })();
</script>
