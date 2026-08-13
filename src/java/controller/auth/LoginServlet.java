package controller.auth;

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

    // Same session attribute key already relied on by filter.CustomerFilter and the
    // customer.cart servlets ((User) session.getAttribute("user")). Keep this in sync
    // with those classes if it ever changes.
    public static final String SESSION_USER = "user";

    private static final int REMEMBER_ME_MAX_AGE_SECONDS = 60 * 60 * 24 * 14; // 14 days
    private static final int DEFAULT_MAX_AGE_SECONDS = 60 * 30; // 30 minutes

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.html");
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
            session.setAttribute(SESSION_USER, user);
            session.setMaxInactiveInterval(rememberMe ? REMEMBER_ME_MAX_AGE_SECONDS : DEFAULT_MAX_AGE_SECONDS);

            String redirectUrl = isSafeRedirect(redirectTo)
                    ? redirectTo
                    : request.getContextPath() + "/index.html";
            response.sendRedirect(redirectUrl);
        } catch (IllegalArgumentException | IllegalStateException ex) {
            redirectWithError(request, response, ex.getMessage(), email, redirectTo);
        } catch (SQLException ex) {
            redirectWithError(request, response,
                    "Unable to sign in right now. Please try again later.", email, redirectTo);
        }
    }

    private boolean isSafeRedirect(String redirectTo) {
        // Only allow relative, in-app paths to avoid open-redirect vulnerabilities.
        return redirectTo != null && redirectTo.startsWith("/") && !redirectTo.startsWith("//");
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message,
            String email, String redirectTo) throws IOException {
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath())
                .append("/login.html?error=").append(encode(message));

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
