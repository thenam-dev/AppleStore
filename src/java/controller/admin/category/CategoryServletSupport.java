package controller.admin.category;

import config.AppConfig;
import model.entity.catalog.Category;
import service.catalog.CategoryService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;

public abstract class CategoryServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/categories/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/categories/form.jsp";
    protected static final String CATEGORY_LIST_PATH = "/admin/categories";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";

    protected final CategoryService categoryService = new CategoryService();

    /** Gom tham số request thành entity Category dùng cho thao tác tạo mới hoặc cập nhật. */
    protected Category buildCategoryFromRequest(HttpServletRequest request) {
        Category category = new Category();
        category.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        category.setName(request.getParameter("name"));
        category.setSlug(request.getParameter("slug"));
        category.setDisplayOrder(parseInt(request.getParameter("displayOrder"), "Thứ tự hiển thị không hợp lệ."));
        category.setIsActive(parseRequiredCategoryStatusToActive(request.getParameter("status")));
        return category;
    }

    /** Đưa danh sách trạng thái hợp lệ lên request để JSP render select option. */
    protected void setCategoryFormOptions(HttpServletRequest request) {
        request.setAttribute("categoryStatusOptions", categoryService.getAllowedStatuses());
    }

    /** Parse số nguyên bắt buộc và ném lỗi nghiệp vụ với thông báo thân thiện nếu sai định dạng. */
    protected int parseInt(String value, String errorMessage) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    /** Parse số nguyên tùy chọn, trả về giá trị mặc định nếu dữ liệu rỗng hoặc sai định dạng. */
    protected int parseIntOrDefault(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    /** Tính số liệu tổng quan của danh mục để hiển thị các thẻ thống kê trên màn list. */
    protected void setCategoryMetrics(HttpServletRequest request, List<Category> allCategories, int filteredCount) {
        long activeCount = allCategories.stream().filter(Category::getIsActive).count();

        request.setAttribute("totalCategories", allCategories.size());
        request.setAttribute("activeCategories", activeCount);
        request.setAttribute("inactiveCategories", allCategories.size() - activeCount);
        request.setAttribute("filteredCategories", filteredCount);
        request.setAttribute("pageSizeAdmin", AppConfig.PAGE_SIZE_ADMIN);
        request.setAttribute("sortOptions", buildSortOptions());
    }

    /** Tạo category mặc định cho form thêm mới. */
    protected Category createDefaultCategory() {
        Category category = new Category();
        category.setDisplayOrder(0);
        category.setIsActive(true);
        return category;
    }

    /** Điều hướng người dùng về trang danh sách danh mục. */
    protected void redirectToCategoryList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + CATEGORY_LIST_PATH);
    }

    /** Lưu flash message vào session rồi redirect về danh sách danh mục theo pattern PRG. */
    protected void redirectToCategoryListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                     String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToCategoryList(request, response);
    }

    /** Chuyển thông báo tạm trong session sang request để JSP hiển thị một lần. */
    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    /** Chuẩn hóa tham số page, mặc định về trang 1 nếu thiếu hoặc không hợp lệ. */
    protected int parsePage(String value) {
        return parsePositiveIntOrDefault(value, 1);
    }

    /** Tính tổng số trang dựa trên tổng bản ghi và kích thước trang. */
    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (pageSize <= 0) {
            return 1;
        }
        return Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
    }

    /** Chuẩn hóa bộ lọc trạng thái danh mục từ request. */
    protected String normalizeStatusFilter(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized) || "INACTIVE".equals(normalized)) {
            return normalized;
        }
        throw new IllegalArgumentException("Bộ lọc trạng thái danh mục không hợp lệ.");
    }

    /** Chuyển trạng thái bắt buộc ACTIVE/INACTIVE thành cờ isActive cho entity Category. */
    protected boolean parseRequiredCategoryStatusToActive(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Trạng thái danh mục không hợp lệ.");
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized)) {
            return true;
        }
        if ("INACTIVE".equals(normalized)) {
            return false;
        }
        throw new IllegalArgumentException("Trạng thái danh mục không hợp lệ.");
    }

    /** Chuyển trạng thái tùy chọn thành cờ isActive, dùng default khi dữ liệu không hợp lệ. */
    protected boolean parseCategoryStatusToActiveOrDefault(String value, boolean defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized)) {
            return true;
        }
        if ("INACTIVE".equals(normalized)) {
            return false;
        }
        return defaultValue;
    }

    /** Chuẩn hóa tùy chọn sắp xếp danh mục, mặc định theo thứ tự hiển thị tăng dần. */
    protected String normalizeCategorySort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "display_asc";
        }
        return sort.trim().toLowerCase(Locale.ROOT);
    }

    /** Tạo query string giữ lại bộ lọc/sắp xếp khi người dùng chuyển trang. */
    protected String buildCategoryListQueryString(String keyword, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    /** Parse số nguyên dương, trả về mặc định nếu giá trị thiếu, âm hoặc sai định dạng. */
    private int parsePositiveIntOrDefault(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    /** Lưu flash message vào session nếu nội dung thông báo không rỗng. */
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

    /** Nối một tham số vào query string và encode giá trị để an toàn khi redirect/phân trang. */
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

    /** Tạo danh sách lựa chọn sắp xếp cho màn danh sách danh mục. */
    private List<SortOption> buildSortOptions() {
        return List.of(
                new SortOption("display_asc", "Thứ tự hiển thị tăng dần"),
                new SortOption("display_desc", "Thứ tự hiển thị giảm dần"),
                new SortOption("name_asc", "Tên A-Z"),
                new SortOption("name_desc", "Tên Z-A"),
                new SortOption("newest", "Mới nhất"),
                new SortOption("oldest", "Cũ nhất")
        );
    }

    public static final class SortOption {
        private final String value;
        private final String label;

        /** Tạo một lựa chọn sắp xếp gồm giá trị gửi lên server và nhãn hiển thị. */
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
