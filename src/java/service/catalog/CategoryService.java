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

    /** Khởi tạo service với DAO mặc định dùng trong luồng CRUD danh mục. */
    public CategoryService() {
        this(new CategoryDAO());
    }

    /** Cho phép truyền DAO từ ngoài vào để dễ kiểm thử hoặc thay thế nguồn dữ liệu. */
    public CategoryService(CategoryDAO categoryDAO) {
        this.categoryDAO = categoryDAO;
    }

    /** Lấy toàn bộ danh mục, thường dùng để tính thống kê trên màn quản trị. */
    public List<Category> getAllCategories() throws SQLException {
        return categoryDAO.findAll();
    }

    /** Lấy danh sách danh mục theo bộ lọc, sắp xếp và phân trang. */
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

    /** Đếm số danh mục sau khi áp dụng bộ lọc tìm kiếm và trạng thái. */
    public int countCategories(String keyword, String status) throws SQLException {
        return categoryDAO.countAll(keyword, normalizeStatus(status));
    }

    /** Lấy danh mục đang hoạt động để dùng trong form sản phẩm hoặc filter liên quan. */
    public List<Category> getActiveCategories() throws SQLException {
        return categoryDAO.findAllActive();
    }

    /** Trả về danh sách trạng thái danh mục hợp lệ cho UI và validate. */
    public List<String> getAllowedStatuses() {
        return List.of("ACTIVE", "INACTIVE");
    }

    /** Lấy một danh mục theo ID và báo lỗi nghiệp vụ nếu không tồn tại. */
    public Category getCategoryById(int categoryId) throws SQLException {
        validateCategoryId(categoryId);
        return categoryDAO.findById(categoryId)
                .orElseThrow(() -> new IllegalArgumentException("Danh mục không tồn tại."));
    }

    /** Tạo danh mục mới sau khi chuẩn hóa, validate và kiểm tra trùng tên/slug. */
    public int createCategory(Category category) throws SQLException {
        normalizeCategory(category);
        validateCategory(category);

        if (categoryDAO.existsByName(category.getName())) {
            throw new IllegalArgumentException("Tên danh mục đã tồn tại.");
        }
        if (categoryDAO.existsBySlug(category.getSlug())) {
            throw new IllegalArgumentException("Đường dẫn danh mục đã tồn tại.");
        }

        return categoryDAO.insert(category);
    }

    /** Cập nhật danh mục sau khi kiểm tra ID, dữ liệu hợp lệ và trùng tên/slug với danh mục khác. */
    public void updateCategory(Category category) throws SQLException {
        if (category == null || category.getCategoryId() <= 0) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ.");
        }

        normalizeCategory(category);
        validateCategory(category);

        if (categoryDAO.existsByNameForOtherCategory(category.getName(), category.getCategoryId())) {
            throw new IllegalArgumentException("Tên danh mục đã tồn tại.");
        }
        if (categoryDAO.existsBySlugForOtherCategory(category.getSlug(), category.getCategoryId())) {
            throw new IllegalArgumentException("Đường dẫn danh mục đã tồn tại.");
        }
        if (!categoryDAO.update(category)) {
            throw new IllegalArgumentException("Danh mục không tồn tại.");
        }
    }

    /** Đổi trạng thái danh mục bằng cách map ACTIVE/INACTIVE sang cờ isActive. */
    public void changeCategoryStatus(int categoryId, String status) throws SQLException {
        Category category = getCategoryById(categoryId);
        category.setIsActive("ACTIVE".equals(normalizeStatus(status)));

        if (!categoryDAO.update(category)) {
            throw new IllegalArgumentException("Danh mục không tồn tại.");
        }
    }

    /** Chuẩn hóa chuỗi nhập vào của danh mục trước khi validate và lưu DB. */
    private void normalizeCategory(Category category) {
        if (category == null) {
            throw new IllegalArgumentException("Dữ liệu danh mục là bắt buộc.");
        }

        category.setName(trimRequired(category.getName()));
        category.setSlug(normalizeSlug(category.getSlug()));
    }

    /** Kiểm tra các ràng buộc nghiệp vụ cơ bản của danh mục. */
    private void validateCategory(Category category) {
        if (category.getName().length() > 100) {
            throw new IllegalArgumentException("Tên danh mục không được vượt quá 100 ký tự.");
        }
        if (category.getSlug().length() > 100) {
            throw new IllegalArgumentException("Đường dẫn danh mục không được vượt quá 100 ký tự.");
        }
        if (!SLUG_PATTERN.matcher(category.getSlug()).matches()) {
            throw new IllegalArgumentException("Đường dẫn danh mục chỉ được chứa chữ thường, số và dấu gạch nối.");
        }
        if (category.getDisplayOrder() < 0) {
            throw new IllegalArgumentException("Thứ tự hiển thị phải lớn hơn hoặc bằng 0.");
        }
    }

    /** Đảm bảo ID danh mục là số dương trước khi thao tác với DB. */
    private void validateCategoryId(int categoryId) {
        if (categoryId <= 0) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ.");
        }
    }

    /** Chuẩn hóa trang hiện tại, mặc định về trang 1 nếu giá trị không hợp lệ. */
    private int normalizePage(int page) {
        return page <= 0 ? DEFAULT_PAGE : page;
    }

    /** Chuẩn hóa kích thước trang và giới hạn tối đa để tránh truy vấn quá lớn. */
    private int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    /** Chuẩn hóa trạng thái danh mục từ request thành ACTIVE/INACTIVE hoặc null. */
    private String normalizeStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String normalized = value.trim().toUpperCase();
        if (!"ACTIVE".equals(normalized) && !"INACTIVE".equals(normalized)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái danh mục không hợp lệ.");
        }
        return normalized;
    }

    /** Chuẩn hóa lựa chọn sắp xếp và chặn giá trị sort không được hỗ trợ. */
    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "display_asc";
        }
        String normalized = value.trim().toLowerCase();
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Tùy chọn sắp xếp danh mục không hợp lệ.");
        }
        return normalized;
    }

    /** Cắt khoảng trắng và bắt buộc trường chuỗi phải có nội dung. */
    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim();
    }

    /** Chuẩn hóa slug: cắt khoảng trắng, viết thường và cho phép null nếu người dùng bỏ trống. */
    private String normalizeSlug(String value) {
        return trimRequired(value).toLowerCase();
    }
}
