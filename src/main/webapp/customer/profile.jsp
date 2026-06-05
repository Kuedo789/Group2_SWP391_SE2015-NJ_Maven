<%-- 
    Document   : profile
    Created on : Jun 2026
    Author     : Nguyễn Hùng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <jsp:include page="../common/header.jsp" />

        <style>
            /* ===== PROFILE PAGE ===== */

            .profile-page {
                max-width: 1180px;
                margin: 0 auto;
                padding: 110px 32px 90px;
            }

            .profile-card {
                background-color: var(--white);
                border-radius: 22px;
                padding: 48px 54px;
                box-shadow: var(--shadow);
            }

            .profile-title {
                display: flex;
                align-items: center;
                gap: 18px;
                margin-bottom: 34px;
                color: var(--text);
            }

            .profile-title i {
                font-size: 34px;
                color: var(--primary);
            }

            .profile-title h1 {
                margin: 0;
                font-size: 34px;
                font-weight: 800;
            }

            .profile-form {
                width: 100%;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 30px;
            }

            .form-group {
                margin-bottom: 24px;
            }

            .form-group label {
                display: block;
                margin-bottom: 10px;
                color: var(--text);
                font-size: 16px;
                font-weight: 700;
            }

            .required {
                color: #d62828;
            }

            .form-control {
                width: 100%;
                height: 56px;
                border: 1px solid var(--border);
                border-radius: 10px;
                background-color: var(--white);
                color: var(--text);
                font-size: 16px;
                padding: 0 16px;
                outline: none;
                box-sizing: border-box;
            }

            .form-control:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(21, 92, 46, 0.1);
            }

            .form-control[readonly] {
                background-color: #f7f5ef;
                color: var(--text-muted);
                cursor: not-allowed;
            }

            .form-note {
                margin-top: 8px;
                color: var(--text-muted);
                font-size: 14px;
            }

            .address-area {
                min-height: 145px;
                padding-top: 14px;
                resize: vertical;
                font-family: inherit;
            }

            .profile-actions {
                display: flex;
                justify-content: flex-end;
                gap: 14px;
                margin-top: 18px;
            }

            .btn-cancel,
            .btn-update {
                min-width: 140px;
                height: 52px;
                border: none;
                border-radius: 9px;
                color: white;
                font-size: 16px;
                font-weight: 700;
                cursor: pointer;
            }

            .btn-cancel {
                background-color: #6c757d;
            }

            .btn-update {
                background-color: var(--primary);
            }

            .btn-cancel:hover {
                background-color: #5c636a;
            }

            .btn-update:hover {
                background-color: #104823;
            }

            .btn-update i {
                margin-right: 8px;
            }

            @media (max-width: 768px) {
                .profile-page {
                    padding: 32px 18px 70px;
                }

                .profile-card {
                    padding: 32px 24px;
                }

                .profile-title h1 {
                    font-size: 28px;
                }

                .form-row {
                    grid-template-columns: 1fr;
                    gap: 0;
                }

                .profile-actions {
                    flex-direction: column;
                }

                .btn-cancel,
                .btn-update {
                    width: 100%;
                }
            }
        </style>
    </head>

    <body>

        <jsp:include page="../common/navbar.jsp" />

        <main class="profile-page">
            <div class="profile-card">

                <div class="profile-title">
                    <i class="fa fa-user-edit"></i>
                    <h1>Thông tin cá nhân</h1>
                </div>

                <form class="profile-form" action="#" method="post">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Họ và tên <span class="required">*</span></label>
                            <input type="text" name="fullName" class="form-control" placeholder="Nhập họ và tên của bạn">
                        </div>

                        <div class="form-group">
                            <label>Số điện thoại <span class="required">*</span></label>
                            <input type="text" name="phone" class="form-control" placeholder="Nhập số điện thoại">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="email" class="form-control" value="" readonly>
                        <div class="form-note">Email dùng để đăng nhập và không thể thay đổi tại đây.</div>
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ giao hàng <span class="required">*</span></label>
                        <textarea name="address" class="form-control address-area" placeholder="Nhập địa chỉ giao hàng"></textarea>
                    </div>

                    <div class="profile-actions">
                        <button type="button" class="btn-cancel" onclick="history.back()">Hủy</button>

                        <button type="submit" class="btn-update">
                            <i class="fa fa-save"></i>
                            Cập nhật
                        </button>
                    </div>

                </form>

            </div>
        </main>

        <jsp:include page="../common/footer.jsp" />
        <jsp:include page="../common/scripts.jsp" />

    </body>
</html>