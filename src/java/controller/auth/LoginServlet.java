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
import java.sql.SQLException;
import java.util.Map;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/auth/login.jsp";
    private static final int REMEMBER_ME_MAX_AGE_SECONDS = 60 * 60 * 24 * 14; // 14 ngày
    private static final int DEFAULT_MAX_AGE_SECONDS = 60 * 30; // 30 phút

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        boolean rememberMe = "1".equals(request.getParameter("remember"));
        String redirectTo = sanitizeRedirect(request.getParameter("redirectTo"));

        try {
            AuthService.LoginResult result = authService.login(email, password);

            if (!result.success) {
                request.setAttribute("errorMsg", result.message);
                request.setAttribute("attemptsLeft", result.attemptsLeft);
                request.setAttribute("form", Map.of("email", email == null ? "" : email));
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute(AppConfig.SESSION_USER, result.user);
            session.setMaxInactiveInterval(rememberMe ? REMEMBER_ME_MAX_AGE_SECONDS : DEFAULT_MAX_AGE_SECONDS);

            String target = (redirectTo != null) ? request.getContextPath() + redirectTo
                    : request.getContextPath() + "/home";
            response.sendRedirect(target);
        } catch (SQLException ex) {
            request.setAttribute("errorMsg", "Hiện chưa thể đăng nhập. Vui lòng thử lại sau.");
            request.setAttribute("form", Map.of("email", email == null ? "" : email));
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }

    private String sanitizeRedirect(String redirectTo) {
        if (redirectTo == null || redirectTo.isBlank() || !redirectTo.startsWith("/") || redirectTo.startsWith("//")) {
            return null;
        }
        return redirectTo;
    }
}
