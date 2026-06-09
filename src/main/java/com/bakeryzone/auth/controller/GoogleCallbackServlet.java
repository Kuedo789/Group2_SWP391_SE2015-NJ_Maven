package com.bakeryzone.auth.controller;

import com.bakeryzone.dao.UserDAO;
import com.bakeryzone.model.User;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mysql.cj.xdevapi.JsonParser;
import jakarta.json.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;

public class GoogleCallbackServlet extends HttpServlet {

    private static final String CLIENT_ID = "DÁN_CLIENT_ID_CỦA_BẠN_VÀO_ĐÂY";
    private static final String CLIENT_SECRET = "DÁN_CLIENT_SECRET_CỦA_BẠN_VÀO_ĐÂY";

    private static final String REDIRECT_URI =
            "http://localhost:8081/bakery/google-callback";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String code = request.getParameter("code");

        if (code == null || code.trim().isEmpty()) {
            request.setAttribute("error", "Không thể đăng nhập Google. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }

        try {
            String tokenJson = getToken(code);
            JsonObject tokenObj = JsonParser.parseString(tokenJson).getAsJsonObject();

            if (!tokenObj.has("access_token")) {
                request.setAttribute("error", "Không lấy được token từ Google.");
                request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                return;
            }

            String accessToken = tokenObj.get("access_token").getAsString();

            String userInfoJson = getUserInfo(accessToken);
            JsonObject userObj = JsonParser.parseString(userInfoJson).getAsJsonObject();

            String googleId = userObj.get("id").getAsString();
            String email = userObj.get("email").getAsString().trim().toLowerCase();
            String fullName = userObj.has("name")
                    ? userObj.get("name").getAsString()
                    : email;

            UserDAO dao = new UserDAO();
            User existingUser = dao.findByEmail(email);

            if (existingUser != null) {

                if (!"GOOGLE".equalsIgnoreCase(existingUser.getProvider())) {
                    request.setAttribute("error", "Email này đã đăng ký bằng mật khẩu. Vui lòng đăng nhập bằng email và mật khẩu.");
                    request.setAttribute("accountInput", email);
                    request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                    return;
                }

                if (!"Active".equalsIgnoreCase(existingUser.getAccountStatus())) {
                    request.setAttribute("error", "Tài khoản của bạn đang bị khóa hoặc không hoạt động.");
                    request.setAttribute("accountInput", email);
                    request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                    return;
                }

                request.getSession().setAttribute("user", existingUser);
                redirectAfterLogin(existingUser, request, response);
                return;
            }

            User newUser = new User();
            newUser.setFullName(fullName);
            newUser.setEmail(email);
            newUser.setPassword(null);
            newUser.setPhone(null);
            newUser.setRoleId("CUS");
            newUser.setVerified(true);
            newUser.setOtpCode(null);
            newUser.setOtpExpiry(null);
            newUser.setProvider("GOOGLE");
            newUser.setProviderId(googleId);
            newUser.setAccountStatus("Active");
            newUser.setActiveStaff(false);

            boolean created = dao.createGoogleUser(newUser);

            if (!created) {
                request.setAttribute("error", "Không thể tạo tài khoản Google. Vui lòng thử lại.");
                request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                return;
            }

            User createdUser = dao.findByEmail(email);

            request.getSession().setAttribute("user", createdUser);
            redirectAfterLogin(createdUser, request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đăng nhập Google thất bại. Vui lòng thử lại.");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
        }
    }

    private String getToken(String code) throws IOException {
        URL url = new URL("https://oauth2.googleapis.com/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        String data = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(CLIENT_ID, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(CLIENT_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(REDIRECT_URI, StandardCharsets.UTF_8)
                + "&grant_type=authorization_code";

        try (OutputStream os = conn.getOutputStream()) {
            os.write(data.getBytes(StandardCharsets.UTF_8));
        }

        return readResponse(conn);
    }

    private String getUserInfo(String accessToken) throws IOException {
        URL url = new URL("https://www.googleapis.com/oauth2/v1/userinfo");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();

        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        return readResponse(conn);
    }

    private String readResponse(HttpURLConnection conn) throws IOException {
        Scanner scanner;

        if (conn.getResponseCode() >= 200 && conn.getResponseCode() < 300) {
            scanner = new Scanner(conn.getInputStream(), StandardCharsets.UTF_8);
        } else {
            scanner = new Scanner(conn.getErrorStream(), StandardCharsets.UTF_8);
        }

        StringBuilder sb = new StringBuilder();

        while (scanner.hasNextLine()) {
            sb.append(scanner.nextLine());
        }

        scanner.close();
        return sb.toString();
    }

    private void redirectAfterLogin(User user, HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if ("ADMIN".equalsIgnoreCase(user.getRoleId()) || user.isActiveStaff()) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        } else {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}