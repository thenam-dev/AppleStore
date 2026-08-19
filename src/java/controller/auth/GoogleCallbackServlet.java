/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller.auth;
import config.AppConfig;
import service.AuthService;
import util.JsonUtil;
import util.ServletUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Map;
/**
 *
 * @author admin
 */
@WebServlet(name="GoogleCallbackServlet", urlPatterns={"/googleCallback"})
public class GoogleCallbackServlet extends HttpServlet {

        private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException {
                String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            request.setAttribute("errorMsg", "Đăng nhập Google bị hủy.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }
        try {
            // 1. Lấy Access Token
            Map<String, Object> tokenMap = exchangeCodeForToken(request, code);
            String accessToken = (String) tokenMap.get("access_token");
            // 2. Lấy User Info
            Map<String, Object> profileMap = fetchGoogleUserProfile(accessToken);
            String email = (String) profileMap.get("email");
            String fullName = (String) profileMap.get("name");
            String pictureUrl = (String) profileMap.get("picture");
            String googleId = (String) profileMap.get("id");
            // 3. Login hoặc Register
            AuthService.LoginResult result = authService.processGoogleLogin(email, fullName, pictureUrl, googleId);
            if (result.success) {
                HttpSession session = request.getSession(true);
                session.setAttribute(AppConfig.SESSION_USER, result.user);
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            } else {
                request.setAttribute("errorMsg", result.message);
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Lỗi tích hợp Google. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    } 

    private Map<String, Object> exchangeCodeForToken(HttpServletRequest req, String code) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        String formBody = "code=" + URLEncoder.encode(code, StandardCharsets.UTF_8)
                + "&client_id=" + URLEncoder.encode(AppConfig.GOOGLE_CLIENT_ID, StandardCharsets.UTF_8)
                + "&client_secret=" + URLEncoder.encode(AppConfig.GOOGLE_CLIENT_SECRET, StandardCharsets.UTF_8)
                + "&redirect_uri=" + URLEncoder.encode(ServletUtil.getGoogleRedirectUri(req), StandardCharsets.UTF_8)
                + "&grant_type=" + URLEncoder.encode(AppConfig.GOOGLE_GRANT_TYPE, StandardCharsets.UTF_8);
        HttpRequest request = HttpRequest.newBuilder()
                .uri(java.net.URI.create(AppConfig.GOOGLE_LINK_GET_TOKEN))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return JsonUtil.fromJson(response.body(), Map.class);
    }
    private Map<String, Object> fetchGoogleUserProfile(String accessToken) throws Exception {
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(java.net.URI.create(AppConfig.GOOGLE_LINK_GET_USER_INFO + accessToken))
                .header("Accept", "application/json")
                .GET()
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return JsonUtil.fromJson(response.body(), Map.class);
    }

}
