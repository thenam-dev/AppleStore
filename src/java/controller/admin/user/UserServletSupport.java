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

    /** Đưa danh sách role nội bộ, status và sort option lên request cho JSP user. */
    protected void setUserReferenceData(HttpServletRequest request) {
        request.setAttribute("roles", userService.getAllowedInternalRoles());
        request.setAttribute("statuses", userService.getAllowedStatuses());
        request.setAttribute("sortOptions", buildSortOptions());
    }

    /** Gom dữ liệu request thành entity User dùng cho cập nhật thông tin tài khoản. */
    protected User buildUserFromRequest(HttpServletRequest request) {
        User user = new User();
        user.setUserId(parseInt(request.getParameter("userId"), "ID người dùng không hợp lệ."));
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setRole(request.getParameter("role"));
        user.setStatus(request.getParameter("status"));
        user.setEmailVerified("on".equals(request.getParameter("emailVerified")));
        return user;
    }

    /** Lấy admin hiện tại để chặn tự khóa/tự hạ quyền ở service. */
    protected int getCurrentAdminId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(config.AppConfig.SESSION_USER);
        if (sessionUser instanceof User) {
            return ((User) sessionUser).getUserId();
        }
        throw new IllegalArgumentException("Phiên đăng nhập không hợp lệ.");
    }

    /** Parse số nguyên bắt buộc và ném lỗi nghiệp vụ nếu dữ liệu không hợp lệ. */
    protected int parseInt(String value, String errorMessage) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    /** Parse số nguyên tùy chọn, trả về mặc định nếu thiếu hoặc sai định dạng. */
    protected int parseIntOrDefault(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    /** Điều hướng về trang danh sách người dùng. */
    protected void redirectToUserList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + USER_LIST_PATH);
    }

    /** Lưu flash message rồi redirect về danh sách người dùng theo pattern PRG. */
    protected void redirectToUserListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                 String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToUserList(request, response);
    }

    /** Chuyển flash message từ session sang request để JSP hiển thị một lần. */
    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    /** Chuẩn bị dữ liệu phụ trợ cho list user như chữ viết tắt avatar và ngày tạo đã format. */
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

    /** Chuẩn hóa tham số page, mặc định về trang 1. */
    protected int parsePage(String value) {
        return parsePositiveIntOrDefault(value, 1);
    }

    /** Parse số nguyên dương, trả về mặc định nếu thiếu hoặc không hợp lệ. */
    protected int parsePositiveIntOrDefault(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    /** Tính tổng số trang cho màn danh sách người dùng. */
    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (pageSize <= 0) {
            return 1;
        }
        return Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
    }

    /** Chuẩn hóa lựa chọn sắp xếp user, mặc định theo ngày tạo mới nhất. */
    protected String normalizeUserSort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "created_desc";
        }
        return sort.trim().toLowerCase();
    }

    /** Tạo query string giữ lại keyword, role, status và sort khi phân trang user. */
    protected String buildUserListQueryString(String keyword, String role, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "role", role);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    /** Lưu thông báo tạm vào session nếu message có nội dung. */
    private void setFlashMessage(HttpServletRequest request, String flashKey, String message) {
        if (message == null || message.isBlank()) {
            return;
        }
        request.getSession().setAttribute(flashKey, message);
    }

    /** Lấy một flash message từ session sang request rồi xóa khỏi session. */
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

    /** Nối tham số vào query string và encode giá trị để dùng cho phân trang. */
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

    /** Format ngày giờ tạo user để hiển thị trên bảng danh sách. */
    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return USER_CREATED_AT_FORMATTER.format(value);
    }

    /** Tạo chữ viết tắt từ họ tên để hiển thị avatar dạng text. */
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

    /** Tạo danh sách lựa chọn sắp xếp cho màn người dùng. */
    private List<SortOption> buildSortOptions() {
        return List.of(
                new SortOption("created_desc", "Mới nhất"),
                new SortOption("created_asc", "Cũ nhất"),
                new SortOption("name_asc", "Tên A-Z"),
                new SortOption("email_asc", "Email A-Z"),
                new SortOption("role_asc", "Vai trò A-Z"),
                new SortOption("status_asc", "Trạng thái A-Z")
        );
    }

    public static final class SortOption {
        private final String value;
        private final String label;

        /** Tạo một lựa chọn sort gồm value gửi lên server và label hiển thị. */
        public SortOption(String value, String label) {
            this.value = value;
            this.label = label;
        }

        /** Trả về giá trị sort dùng trong query parameter. */
        public String getValue() {
            return value;
        }

        /** Trả về nhãn sort hiển thị trên giao diện. */
        public String getLabel() {
            return label;
        }
    }
}
