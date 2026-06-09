package com.bakeryzone.auth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public class GoogleLoginServlet extends HttpServlet {

    private static final String CLIENT_ID = "DÁN_CLIENT_ID_CỦA_BẠN_VÀO_ĐÂY";

    private static final String REDIRECT_URI =
            "http://localhost:8081/bakery/google-callback";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scope = "openid email profile";

        String googleAuthUrl = "https://accounts.google.com/o/oauth2/v2/auth"
                + "?client_id=" + URLEncoder.encode(CLIENT_ID, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(REDIRECT_URI, StandardCharsets.UTF_8)
                + "&response_type=code"
                + "&scope=" + URLEncoder.encode(scope, StandardCharsets.UTF_8)
                + "&prompt=select_account";

        response.sendRedirect(googleAuthUrl);
    }
}