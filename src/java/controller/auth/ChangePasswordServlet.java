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

@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/auth/change-password.jsp";

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login?redirectTo="
                    + URLEncoder.encode("/change-password", StandardCharsets.UTF_8));
            return;
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(AppConfig.SESSION_USER) instanceof User;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        Object sessionUser = (session != null) ? session.getAttribute(AppConfig.SESSION_USER) : null;

        if (!(sessionUser instanceof User user)) {
            // Session expired between page load and submit — send back to login.
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        try {
            authService.changePassword(user.getUserId(), currentPassword, newPassword, confirmNewPassword);
            response.sendRedirect(request.getContextPath() + "/change-password?changed=1");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            redirectWithError(request, response, ex.getMessage());
        } catch (SQLException ex) {
            redirectWithError(request, response, "Hiện chưa thể đổi mật khẩu. Vui lòng thử lại sau.");
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws IOException {
        String url = request.getContextPath() + "/change-password?error="
                + URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(url);
    }
}