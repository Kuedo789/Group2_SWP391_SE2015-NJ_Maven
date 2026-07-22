<%-- 
    Document   : footer
    Created on : Jun 4, 2026, 1:26:42 PM
    Author     : admin
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<footer class="footer" style="background-color: var(--primary-dark, #2f4728); color: white; padding: 60px 0 30px;">
    <div class="footer-inner" style="max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 2fr 1fr 1fr 1fr; gap: 40px; padding: 0 20px;">
        <div class="footer-brand" style="display: flex; flex-direction: column; gap: 16px;">
            <h3 style="font-family: 'Playfair Display', serif; font-size: 24px; color: var(--secondary, #c8a46d); font-weight: 700; margin: 0;">
                ${not empty settings.bakeryName ? settings.bakeryName : 'Tiệm Bánh Thủ Công'}
            </h3>

            <p style="color: rgba(255, 255, 255, 0.8); line-height: 1.6; margin: 0;">
                ${not empty settings.announcement ? settings.announcement : 'Hương vị ngọt ngào từ những nguyên liệu tự nhiên nhất, mang đến niềm vui cho mọi khoảnh khắc.'}
            </p>

            <div style="display: flex; flex-direction: column; gap: 12px; margin-top: 8px;">
                <div style="display: flex; align-items: flex-start; gap: 10px; color: rgba(255, 255, 255, 0.9);">
                    <span class="material-symbols-outlined" style="font-size: 20px; color: var(--secondary, #c8a46d);">location_on</span>
                    <span style="font-size: 15px;">${not empty settings.address ? settings.address : 'Đang cập nhật'}</span>
                </div>
                <div style="display: flex; align-items: center; gap: 10px; color: rgba(255, 255, 255, 0.9);">
                    <span class="material-symbols-outlined" style="font-size: 20px; color: var(--secondary, #c8a46d);">call</span>
                    <span style="font-size: 15px; font-weight: 600;">${not empty settings.hotline ? settings.hotline : 'Đang cập nhật'}</span>
                </div>
                <div style="display: flex; align-items: center; gap: 10px; color: rgba(255, 255, 255, 0.9);">
                    <span class="material-symbols-outlined" style="font-size: 20px; color: var(--secondary, #c8a46d);">mail</span>
                    <span style="font-size: 15px;">${not empty settings.email ? settings.email : 'Đang cập nhật'}</span>
                </div>
            </div>
        </div>

        <div style="display: flex; flex-direction: column; gap: 20px;">
            <h4 style="font-size: 18px; font-weight: 600; color: white; margin: 0;">Khám phá</h4>
            <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 12px;">
                <li><a href="<%= request.getContextPath() %>/home" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Trang Chủ</a></li>
                <li><a href="<%= request.getContextPath() %>/products" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Menu bánh</a></li>
                <li><a href="<%= request.getContextPath() %>/custom-cake" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Tự thiết kế</a></li>
                <li><a href="<%= request.getContextPath() %>/blog" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Tin tức & Blog</a></li>
            </ul>
        </div>

        <div style="display: flex; flex-direction: column; gap: 20px;">
            <h4 style="font-size: 18px; font-weight: 600; color: white; margin: 0;">Chính sách</h4>
            <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 12px;">
                <li><a href="<%= request.getContextPath() %>/home" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Hướng dẫn đặt hàng</a></li>
                <li><a href="<%= request.getContextPath() %>/home" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Chính sách vận chuyển</a></li>
                <li><a href="<%= request.getContextPath() %>/home" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Chính sách bảo mật (Privacy)</a></li>
                <li><a href="<%= request.getContextPath() %>/home" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Điều khoản (Terms)</a></li>
            </ul>
        </div>

        <div style="display: flex; flex-direction: column; gap: 20px;">
            <h4 style="font-size: 18px; font-weight: 600; color: white; margin: 0;">Tài khoản</h4>
            <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 12px;">
                <li><a href="<%= request.getContextPath() %>/login" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Đăng nhập</a></li>
                <li><a href="<%= request.getContextPath() %>/register" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Đăng ký</a></li>
                <li><a href="<%= request.getContextPath() %>/profile" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Quản lý tài khoản</a></li>
                <li><a href="<%= request.getContextPath() %>/cart" style="color: rgba(255, 255, 255, 0.7); text-decoration: none; transition: color 0.2s;">Giỏ hàng</a></li>
            </ul>
        </div>
    </div>
    
    <div style="max-width: 1200px; margin: 40px auto 0; padding: 20px 20px 0; border-top: 1px solid rgba(255, 255, 255, 0.1); text-align: center; color: rgba(255, 255, 255, 0.5); font-size: 14px;">
        &copy; 2026 ${not empty settings.bakeryName ? settings.bakeryName : 'BakeryZone'}. All rights reserved.
    </div>
</footer>
<style>
    .footer-inner ul li a:hover {
        color: var(--secondary, #c8a46d) !important;
        text-decoration: underline !important;
    }
</style>