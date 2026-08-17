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

/**
 * Đổi mật khẩu cho user đã đăng nhập. Không dùng chung
 * {@link filter.AuthFilter} (filter đó còn ép role phải là CUSTOMER, sẽ chặn
 * nhầm Admin/Sale Staff) — servlet tự kiểm tra session ở cả doGet và doPost.
 */
@WebServlet(name = "ChangePasswordServlet", urlPatterns = {"/change-password"})
public class ChangePasswordServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/auth/change-password.jsp";

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request)) {
            redirectToLogin(request, response);
            return;
        }
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Object sessionUser = (session != null) ? session.getAttribute(AppConfig.SESSION_USER) : null;
        if (!(sessionUser instanceof User user)) {
            redirectToLogin(request, response);
            return;
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        try {
            AuthService.ChangePasswordResult result
                    = authService.changePassword(user.getUserId(), currentPassword, newPassword, confirmNewPassword);

            if (!result.success) {
                request.setAttribute("errors", result.fieldErrors);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            session.setAttribute("successMsg", "Đổi mật khẩu thành công.");
            response.sendRedirect(request.getContextPath() + "/change-password");
        } catch (SQLException ex) {
            request.setAttribute("errorMsg", "Hiện chưa thể đổi mật khẩu. Vui lòng thử lại sau.");
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }

    private boolean isLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(AppConfig.SESSION_USER) instanceof User;
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login?redirectTo="
                + URLEncoder.encode("/change-password", StandardCharsets.UTF_8));
    }
}
