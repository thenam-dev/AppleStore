package controller.auth;

import config.AppConfig;
import model.entity.user.User;
import service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final String LOGIN_VIEW = "/WEB-INF/views/auth/login.jsp";
    private static final int REMEMBER_ME_MAX_AGE_SECONDS = 60 * 60 * 24 * 14; // 14 days
    private static final int DEFAULT_MAX_AGE_SECONDS = 60 * 30; // 30 minutes

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(LOGIN_VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        boolean rememberMe = "1".equals(request.getParameter("rememberMe"));
        String redirectTo = request.getParameter("redirectTo");

        try {
            User user = authService.login(email, password);

            HttpSession session = request.getSession(true);
            session.setAttribute(AppConfig.SESSION_USER, user);
            // Temporary bridge while a few older admin screens still read the legacy key.
            session.setAttribute("loggedInUser", user);
            session.setMaxInactiveInterval(rememberMe ? REMEMBER_ME_MAX_AGE_SECONDS : DEFAULT_MAX_AGE_SECONDS);

            String redirectUrl = resolveRedirectUrl(user, redirectTo, request);
            response.sendRedirect(redirectUrl);
        } catch (IllegalArgumentException | IllegalStateException ex) {
            redirectWithError(request, response, ex.getMessage(), email, redirectTo);
        } catch (SQLException ex) {
            redirectWithError(request, response,
                    "Hiện chưa thể đăng nhập. Vui lòng thử lại sau.", email, redirectTo);
        }
    }

    private String resolveRedirectUrl(User user, String redirectTo, HttpServletRequest request) {
        String role = user.getRole() == null ? "" : user.getRole().trim().toUpperCase();

        if (AppConfig.ROLE_ADMIN.equals(role) || AppConfig.ROLE_SALE_STAFF.equals(role)) {
            return request.getContextPath() + "/admin/dashboard";
        }

        if (AppConfig.ROLE_CUSTOMER.equals(role)) {
            if (isSafeRedirect(redirectTo)) {
                return toAppRedirectUrl(redirectTo, request);
            }
            return request.getContextPath() + "/index.jsp";
        }

        if (AppConfig.ROLE_DELIVERY.equals(role)) {
            return request.getContextPath() + "/index.jsp";
        }

        return request.getContextPath() + "/index.jsp";
    }

    private boolean isSafeRedirect(String redirectTo) {
        // Only allow relative, in-app paths to avoid open-redirect vulnerabilities.
        return redirectTo != null && redirectTo.startsWith("/") && !redirectTo.startsWith("//");
    }

    private String toAppRedirectUrl(String redirectTo, HttpServletRequest request) {
        if (redirectTo == null || redirectTo.isBlank()) {
            return request.getContextPath() + "/index.jsp";
        }

        if (redirectTo.startsWith(request.getContextPath() + "/")) {
            return redirectTo;
        }

        return request.getContextPath() + redirectTo;
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message,
            String email, String redirectTo) throws IOException {
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath())
                .append("/login?error=").append(encode(message));

        if (email != null) {
            redirectUrl.append("&email=").append(encode(email));
        }
        if (isSafeRedirect(redirectTo)) {
            redirectUrl.append("&redirectTo=").append(encode(redirectTo));
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
