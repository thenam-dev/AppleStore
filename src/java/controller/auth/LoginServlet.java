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
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute(AppConfig.SESSION_USER) instanceof User) {
            User user = (User) session.getAttribute(AppConfig.SESSION_USER);
            String role = user.getRole();
            if (AppConfig.ROLE_ADMIN.equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else if (AppConfig.ROLE_SALE_STAFF.equals(role)) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            } else if ("DELIVERY".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/staff/tasks");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
            return;
        }
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

            if (redirectTo != null) {
                response.sendRedirect(request.getContextPath() + redirectTo);
                return;
            }

            // Redirect dựa theo Role
            String role = result.user.getRole();
            if (AppConfig.ROLE_ADMIN.equals(role)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else if (AppConfig.ROLE_SALE_STAFF.equals(role)) {
                response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            } else if ("DELIVERY".equals(role)) {
                response.sendRedirect(request.getContextPath() + "/staff/tasks");
            } else {
                // Mặc định là CUSTOMER
                response.sendRedirect(request.getContextPath() + "/home");
            }
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
