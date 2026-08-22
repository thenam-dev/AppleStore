package controller.staff.order;

import config.AppConfig;
import model.entity.user.User;
import service.staff.order.StaffOrderService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public abstract class StaffOrderServletSupport extends HttpServlet {
    protected final StaffOrderService staffOrderService = new StaffOrderService();

    protected User getSessionUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        User user = (User) session.getAttribute("user");
        if (user == null) {
            user = (User) session.getAttribute(AppConfig.SESSION_USER);
        }
        return user;
    }

    protected void redirectWithFlash(HttpServletRequest request, HttpServletResponse response, String url, String flashKey, String message) throws IOException {
        if (message != null && !message.isBlank()) {
            request.getSession().setAttribute(flashKey, message);
        }
        response.sendRedirect(request.getContextPath() + url);
    }
}