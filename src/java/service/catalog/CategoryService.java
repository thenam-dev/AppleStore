package service.catalog;

import dao.catalog.CategoryDAO;
import model.entity.catalog.Category;

import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

public class CategoryService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;
    private static final Pattern SLUG_PATTERN = Pattern.compile("^[a-z0-9]+(?:-[a-z0-9]+)*$");

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

    public List<Category> getCategories(int page, int pageSize) throws SQLException {
        return categoryDAO.findAll(normalizePage(page), normalizePageSize(pageSize));
    }

    public int countCategories() throws SQLException {
        return categoryDAO.countAll();
    }

    public List<Category> getActiveCategories() throws SQLException {
        return categoryDAO.findAllActive();
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

    public void toggleCategoryStatus(int categoryId) throws SQLException {
        Category category = getCategoryById(categoryId);
        category.setIsActive(!category.getIsActive());

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
