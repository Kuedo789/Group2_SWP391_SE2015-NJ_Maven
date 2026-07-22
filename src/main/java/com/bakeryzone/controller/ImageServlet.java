package com.bakeryzone.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

@WebServlet("/uploads/*")
public class ImageServlet extends HttpServlet {

    // Thư mục cố định ngoài workspace dự án để không bao giờ bị xóa khi Clean & Build
    public static final String EXTERNAL_UPLOAD_DIR = System.getProperty("os.name").toLowerCase().contains("win") 
            ? "C:/uploads" 
            : System.getProperty("user.home") + "/uploads";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Lấy đường dẫn tương đối từ request URL (Ví dụ: /blog/blog_1720000000.jpg)
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Tạo file trỏ tới vị trí lưu trữ cố định trên đĩa cứng
        File file = new File(EXTERNAL_UPLOAD_DIR, pathInfo);

        // Kiểm tra file có tồn tại không
        if (!file.exists() || file.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Xác định định dạng MIME (image/jpeg, image/png, image/webp, v.v.)
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            try {
                contentType = Files.probeContentType(file.toPath());
            } catch (Exception ignored) {
            }
        }
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());
        response.setHeader("Cache-Control", "public, max-age=86400"); // Cache 24 giờ cho mượt mà

        // Stream byte dữ liệu file từ đĩa cứng ra response truyền về trình duyệt
        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
