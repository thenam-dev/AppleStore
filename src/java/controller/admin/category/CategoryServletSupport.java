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

    protected Category buildCategoryFromRequest(HttpServletRequest request) {
        Category category = new Category();
        category.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        category.setName(request.getParameter("name"));
        category.setSlug(request.getParameter("slug"));
        category.setDisplayOrder(parseInt(request.getParameter("displayOrder"), "Display order is invalid."));
        category.setIsActive("on".equals(request.getParameter("isActive")));
        return category;
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

    protected void setCategoryMetrics(HttpServletRequest request, List<Category> allCategories, int filteredCount) {
        long activeCount = allCategories.stream().filter(Category::getIsActive).count();

        request.setAttribute("totalCategories", allCategories.size());
        request.setAttribute("activeCategories", activeCount);
        request.setAttribute("inactiveCategories", allCategories.size() - activeCount);
        request.setAttribute("filteredCategories", filteredCount);
        request.setAttribute("pageSizeAdmin", AppConfig.PAGE_SIZE_ADMIN);
        request.setAttribute("sortOptions", buildSortOptions());
    }

    protected Category createDefaultCategory() {
        Category category = new Category();
        category.setDisplayOrder(0);
        category.setIsActive(true);
        return category;
    }

    protected void redirectToCategoryList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + CATEGORY_LIST_PATH);
    }

    protected void redirectToCategoryListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                     String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToCategoryList(request, response);
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    protected int parsePage(String value) {
        return parsePositiveIntOrDefault(value, 1);
    }

    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (pageSize <= 0) {
            return 1;
        }
        return Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
    }

    protected String normalizeStatusFilter(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized) || "INACTIVE".equals(normalized)) {
            return normalized;
        }
        throw new IllegalArgumentException("Category status filter is invalid.");
    }

    protected String normalizeCategorySort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "display_asc";
        }
        return sort.trim().toLowerCase(Locale.ROOT);
    }

    protected String buildCategoryListQueryString(String keyword, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    private int parsePositiveIntOrDefault(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
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

    private List<SortOption> buildSortOptions() {
        return List.of(
                new SortOption("display_asc", "Display order (low-high)"),
                new SortOption("display_desc", "Display order (high-low)"),
                new SortOption("name_asc", "Name A-Z"),
                new SortOption("name_desc", "Name Z-A"),
                new SortOption("newest", "Newest"),
                new SortOption("oldest", "Oldest")
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
