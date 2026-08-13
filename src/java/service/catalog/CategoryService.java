package service.catalog;

import dao.catalog.CategoryDAO;
import model.entity.catalog.Category;

import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

public class CategoryService {
    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = config.AppConfig.PAGE_SIZE_ADMIN;
    private static final int MAX_PAGE_SIZE = 100;
    private static final Pattern SLUG_PATTERN = Pattern.compile("^[a-z0-9]+(?:-[a-z0-9]+)*$");
    private static final List<String> ALLOWED_SORTS = List.of(
            "display_asc",
            "display_desc",
            "name_asc",
            "name_desc",
            "newest",
            "oldest"
    );

    private final CategoryDAO categoryDAO;

    public CategoryService() {
        this(new CategoryDAO());
    }

    public CategoryService(CategoryDAO categoryDAO) {
        this.categoryDAO = categoryDAO;
    }

    public List<Category> getAllCategories() throws SQLException {
        return categoryDAO.findAll();
    }

    public List<Category> getCategories(String keyword, String status, String sort, int page, int pageSize)
            throws SQLException {
        return categoryDAO.findAll(
                keyword,
                normalizeStatus(status),
                normalizeSort(sort),
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    public int countCategories(String keyword, String status) throws SQLException {
        return categoryDAO.countAll(keyword, normalizeStatus(status));
    }

    public List<Category> getActiveCategories() throws SQLException {
        return categoryDAO.findAllActive();
    }

    public List<String> getAllowedStatuses() {
        return List.of("ACTIVE", "INACTIVE");
    }

    public Category getCategoryById(int categoryId) throws SQLException {
        validateCategoryId(categoryId);
        return categoryDAO.findById(categoryId)
                .orElseThrow(() -> new IllegalArgumentException("Category does not exist."));
    }

    public int createCategory(Category category) throws SQLException {
        normalizeCategory(category);
        validateCategory(category);

        if (categoryDAO.existsByName(category.getName())) {
            throw new IllegalArgumentException("Category name already exists.");
        }
        if (categoryDAO.existsBySlug(category.getSlug())) {
            throw new IllegalArgumentException("Category slug already exists.");
        }

        return categoryDAO.insert(category);
    }

    public void updateCategory(Category category) throws SQLException {
        if (category == null || category.getCategoryId() <= 0) {
            throw new IllegalArgumentException("Category id is invalid.");
        }

        normalizeCategory(category);
        validateCategory(category);

        if (categoryDAO.existsByNameForOtherCategory(category.getName(), category.getCategoryId())) {
            throw new IllegalArgumentException("Category name already exists.");
        }
        if (categoryDAO.existsBySlugForOtherCategory(category.getSlug(), category.getCategoryId())) {
            throw new IllegalArgumentException("Category slug already exists.");
        }
        if (!categoryDAO.update(category)) {
            throw new IllegalArgumentException("Category does not exist.");
        }
    }

    public void changeCategoryStatus(int categoryId, String status) throws SQLException {
        Category category = getCategoryById(categoryId);
        category.setIsActive("ACTIVE".equals(normalizeStatus(status)));

        if (!categoryDAO.update(category)) {
            throw new IllegalArgumentException("Category does not exist.");
        }
    }

    private void normalizeCategory(Category category) {
        if (category == null) {
            throw new IllegalArgumentException("Category data is required.");
        }

        category.setName(trimRequired(category.getName()));
        category.setSlug(normalizeSlug(category.getSlug()));
    }

    private void validateCategory(Category category) {
        if (category.getName().length() > 100) {
            throw new IllegalArgumentException("Category name must be 100 characters or less.");
        }
        if (category.getSlug().length() > 100) {
            throw new IllegalArgumentException("Category slug must be 100 characters or less.");
        }
        if (!SLUG_PATTERN.matcher(category.getSlug()).matches()) {
            throw new IllegalArgumentException("Category slug may contain only lowercase letters, numbers, and hyphens.");
        }
        if (category.getDisplayOrder() < 0) {
            throw new IllegalArgumentException("Display order must be 0 or greater.");
        }
    }

    private void validateCategoryId(int categoryId) {
        if (categoryId <= 0) {
            throw new IllegalArgumentException("Category id is invalid.");
        }
    }

    private int normalizePage(int page) {
        return page <= 0 ? DEFAULT_PAGE : page;
    }

    private int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    private String normalizeStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String normalized = value.trim().toUpperCase();
        if (!"ACTIVE".equals(normalized) && !"INACTIVE".equals(normalized)) {
            throw new IllegalArgumentException("Category status filter is invalid.");
        }
        return normalized;
    }

    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "display_asc";
        }
        String normalized = value.trim().toLowerCase();
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Category sort option is invalid.");
        }
        return normalized;
    }

    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim();
    }

    private String normalizeSlug(String value) {
        return trimRequired(value).toLowerCase();
    }
}
