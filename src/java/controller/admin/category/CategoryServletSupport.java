package controller.admin.category;

import config.AppConfig;
import model.entity.catalog.Category;
import service.catalog.CategoryService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public abstract class CategoryServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/categories/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/categories/form.jsp";
    protected static final String CATEGORY_LIST_PATH = "/admin/categories";

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

    protected List<Category> filterCategories(List<Category> categories, String keyword, String status) {
        return categories.stream()
                .filter(category -> matchesKeyword(category, keyword))
                .filter(category -> matchesStatus(category, status))
                .collect(Collectors.toList());
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

    protected void setCategoryMetrics(HttpServletRequest request, List<Category> allCategories, List<Category> filteredCategories) {
        long activeCount = allCategories.stream().filter(Category::getIsActive).count();

        request.setAttribute("totalCategories", allCategories.size());
        request.setAttribute("activeCategories", activeCount);
        request.setAttribute("inactiveCategories", allCategories.size() - activeCount);
        request.setAttribute("filteredCategories", filteredCategories.size());
        request.setAttribute("pageSizeAdmin", AppConfig.PAGE_SIZE_ADMIN);
    }

    protected void redirectToCategoryList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + CATEGORY_LIST_PATH);
    }

    protected void redirectToCategoryListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                     String paramName, String message) throws IOException {
        String encodedMessage = URLEncoder.encode(message, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + CATEGORY_LIST_PATH + "?" + paramName + "=" + encodedMessage);
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

    private boolean matchesKeyword(Category category, String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return true;
        }

        String normalizedKeyword = keyword.trim().toLowerCase(Locale.ROOT);
        return category.getName().toLowerCase(Locale.ROOT).contains(normalizedKeyword)
                || category.getSlug().toLowerCase(Locale.ROOT).contains(normalizedKeyword);
    }

    private boolean matchesStatus(Category category, String status) {
        if (status == null || status.isBlank()) {
            return true;
        }
        if ("ACTIVE".equals(status)) {
            return category.getIsActive();
        }
        if ("INACTIVE".equals(status)) {
            return !category.getIsActive();
        }
        return true;
    }
}
