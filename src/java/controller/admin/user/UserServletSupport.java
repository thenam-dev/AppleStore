package controller.admin.user;

import model.entity.user.User;
import service.user.UserService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public abstract class UserServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/users/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/users/form.jsp";
    protected static final String USER_LIST_PATH = "/admin/users";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";
    private static final DateTimeFormatter USER_CREATED_AT_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    protected final UserService userService = new UserService();

    protected void setUserReferenceData(HttpServletRequest request) {
        request.setAttribute("roles", userService.getAllowedRoles());
        request.setAttribute("statuses", userService.getAllowedStatuses());
        request.setAttribute("sortOptions", buildSortOptions());
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
                                                 String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToUserList(request, response);
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    protected void setUserListViewData(HttpServletRequest request, List<User> users) {
        Map<Integer, String> userInitialsMap = new LinkedHashMap<>();
        Map<Integer, String> userCreatedAtMap = new LinkedHashMap<>();

        for (User user : users) {
            userInitialsMap.put(user.getUserId(), buildInitials(user.getFullName()));
            userCreatedAtMap.put(user.getUserId(), formatDateTime(user.getCreatedAt()));
        }

        request.setAttribute("userInitialsMap", userInitialsMap);
        request.setAttribute("userCreatedAtMap", userCreatedAtMap);
    }

    protected int parsePage(String value) {
        return parsePositiveIntOrDefault(value, 1);
    }

    protected int parsePositiveIntOrDefault(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (pageSize <= 0) {
            return 1;
        }
        return Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
    }

    protected String normalizeUserSort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "created_desc";
        }
        return sort.trim().toLowerCase();
    }

    protected String buildUserListQueryString(String keyword, String role, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "role", role);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    private void setFlashMessage(HttpServletRequest request, String flashKey, String message) {
        if (message == null || message.isBlank()) {
            return;
        }
        request.getSession().setAttribute(flashKey, message);
    }

    private void moveFlashMessageToRequest(HttpServletRequest request, String flashKey) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object message = session.getAttribute(flashKey);
        if (message instanceof String && !((String) message).isBlank()) {
            request.setAttribute(flashKey, message);
        }
        session.removeAttribute(flashKey);
    }

    private void appendQueryParam(StringBuilder query, String key, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        if (!query.isEmpty()) {
            query.append('&');
        }
        query.append(key)
                .append('=')
                .append(URLEncoder.encode(value, StandardCharsets.UTF_8));
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return USER_CREATED_AT_FORMATTER.format(value);
    }

    private String buildInitials(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "US";
        }

        String[] parts = fullName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }

        return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
    }

    private List<SortOption> buildSortOptions() {
        return List.of(
                new SortOption("created_desc", "Newest"),
                new SortOption("created_asc", "Oldest"),
                new SortOption("name_asc", "Name A-Z"),
                new SortOption("email_asc", "Email A-Z"),
                new SortOption("role_asc", "Role A-Z"),
                new SortOption("status_asc", "Status A-Z")
        );
    }

    public static final class SortOption {
        private final String value;
        private final String label;

        public SortOption(String value, String label) {
            this.value = value;
            this.label = label;
        }

        public String getValue() {
            return value;
        }

        public String getLabel() {
            return label;
        }
    }
}
