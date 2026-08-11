package controller.admin.user;

import model.User;
import service.UserService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public abstract class UserServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/users/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/users/form.jsp";
    protected static final String USER_LIST_PATH = "/admin/users";

    protected final UserService userService = new UserService();

    protected void setUserReferenceData(HttpServletRequest request) {
        request.setAttribute("roles", userService.getAllowedRoles());
        request.setAttribute("statuses", userService.getAllowedStatuses());
    }

    protected User buildUserFromRequest(HttpServletRequest request) {
        User user = new User();
        user.setUserId(parseInt(request.getParameter("userId"), "User id is invalid."));
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setRole(request.getParameter("role"));
        user.setStatus(request.getParameter("status"));
        user.setEmailVerified("on".equals(request.getParameter("emailVerified")));
        return user;
    }

    protected int parseInt(String value, String errorMessage) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    protected int parseIntOrDefault(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    protected void redirectToUserList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + USER_LIST_PATH);
    }

    protected void redirectToUserListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                 String paramName, String message) throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + USER_LIST_PATH + "?" + paramName + "=" + encodedMessage);
    }

    protected String firstNonBlank(String first, String second) {
        if (first != null && !first.isBlank()) {
            return first;
        }
        if (second != null && !second.isBlank()) {
            return second;
        }
        return null;
    }
}
