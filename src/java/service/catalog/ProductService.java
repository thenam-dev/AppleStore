package service.catalog;

import config.AppConfig;
import dao.catalog.CategoryDAO;
import dao.catalog.ProductDAO;
import model.entity.catalog.Product;

import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

public class ProductService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = AppConfig.PAGE_SIZE_ADMIN;
    private static final int MAX_PAGE_SIZE = 100;
    private static final String DEFAULT_BRAND = "Apple";
    private static final String DEFAULT_WARRANTY_PROVIDER = "Apple Viet Nam";
    private static final int MIN_RELEASE_YEAR = 1998;
    private static final int MAX_RELEASE_YEAR = 2100;
    private static final int MAX_NAME_LENGTH = 200;
    private static final int MAX_DESCRIPTION_LENGTH = 2000;
    private static final int MAX_BRAND_LENGTH = 50;
    private static final int MAX_MODEL_CODE_LENGTH = 50;
    private static final int MAX_ORIGIN_COUNTRY_LENGTH = 100;
    private static final int MAX_WARRANTY_PROVIDER_LENGTH = 100;
    private static final List<String> ALLOWED_STATUSES = List.of("ACTIVE", "INACTIVE", "DISCONTINUED");
    private static final List<String> ALLOWED_CONDITIONS = List.of("NEW", "LIKE_NEW", "REFURBISHED");
    private static final List<String> ALLOWED_IMPORT_TYPES = List.of("VN/A", "LL/A", "ZA/A", "ZP/A", "J/A", "KH/A");
    private static final List<String> ALLOWED_SORTS = List.of(
            "newest",
            "oldest",
            "name_asc",
            "name_desc",
            "price_asc",
            "price_desc",
            "stock_asc",
            "stock_desc"
    );

    private final ProductDAO productDAO;
    private final CategoryDAO categoryDAO;

    /** Khởi tạo service với DAO mặc định cho luồng CRUD sản phẩm. */
    public ProductService() {
        this(new ProductDAO(), new CategoryDAO());
    }

    /** Cho phép inject DAO để dễ kiểm thử hoặc thay đổi nguồn dữ liệu. */
    public ProductService(ProductDAO productDAO, CategoryDAO categoryDAO) {
        this.productDAO = productDAO;
        this.categoryDAO = categoryDAO;
    }

    /** Lấy danh sách sản phẩm theo keyword, danh mục, trạng thái, sort và phân trang. */
    public List<Product> getProducts(String keyword, Integer categoryId, String status, String sort, int page, int pageSize)
            throws SQLException {
        return productDAO.findAll(
                keyword,
                normalizeCategoryId(categoryId),
                normalizeOptionalStatus(status),
                normalizeSort(sort),
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    /** Đếm sản phẩm sau khi áp dụng bộ lọc trên màn danh sách. */
    public int countProducts(String keyword, Integer categoryId, String status) throws SQLException {
        return productDAO.countAll(keyword, normalizeCategoryId(categoryId), normalizeOptionalStatus(status));
    }

    /** Đếm sản phẩm theo một trạng thái cụ thể để hiển thị KPI. */
    public int countProductsByStatus(String status) throws SQLException {
        return productDAO.countAll(null, null, normalizeRequiredStatus(status));
    }

    /** Lấy sản phẩm theo ID và báo lỗi nghiệp vụ nếu không tồn tại. */
    public Product getProductById(int productId) throws SQLException {
        validateProductId(productId);
        return productDAO.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
    }

    /** Tạo sản phẩm mới sau khi chuẩn hóa, validate, kiểm tra danh mục và chống trùng tên/model. */
    public int createProduct(Product product) throws SQLException {
        normalizeProduct(product);
        validateProduct(product);
        validateCategoryExists(product.getCategoryId());

        if (productDAO.existsByName(product.getName())) {
            throw new IllegalArgumentException("Tên sản phẩm đã tồn tại.");
        }
        if (productDAO.existsByModelCode(product.getModelCode())) {
            throw new IllegalArgumentException("Mã model đã tồn tại.");
        }

        return productDAO.insert(product);
    }

    /** Cập nhật sản phẩm sau khi validate ID, dữ liệu, danh mục và chống trùng với sản phẩm khác. */
    public void updateProduct(Product product) throws SQLException {
        validateProductId(product.getProductId());
        normalizeProduct(product);
        validateProduct(product);
        validateCategoryExists(product.getCategoryId());

        if (productDAO.existsByNameForOtherProduct(product.getName(), product.getProductId())) {
            throw new IllegalArgumentException("Tên sản phẩm đã tồn tại.");
        }
        if (productDAO.existsByModelCodeForOtherProduct(product.getModelCode(), product.getProductId())) {
            throw new IllegalArgumentException("Mã model đã tồn tại.");
        }
        if (!productDAO.update(product)) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
        }
    }

    /** Đổi trạng thái sản phẩm sang ACTIVE, INACTIVE hoặc DISCONTINUED. */
    public void changeStatus(int productId, String status) throws SQLException {
        validateProductId(productId);
        String normalizedStatus = normalizeRequiredStatus(status);
        if (!productDAO.updateStatus(productId, normalizedStatus)) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
        }
    }

    /** Trả về các trạng thái sản phẩm hợp lệ cho UI và validate. */
    public List<String> getAllowedStatuses() {
        return ALLOWED_STATUSES;
    }

    /** Trả về các tình trạng sản phẩm hợp lệ. */
    public List<String> getAllowedConditions() {
        return ALLOWED_CONDITIONS;
    }

    /** Trả về các mã thị trường được phép chọn trong form sản phẩm. */
    public List<String> getAllowedImportTypes() {
        return ALLOWED_IMPORT_TYPES;
    }

    /** Trả về danh sách sort hợp lệ để service chặn tham số lạ. */
    public List<String> getAllowedSorts() {
        return ALLOWED_SORTS;
    }

    /** Chuẩn hóa dữ liệu sản phẩm trước khi validate và lưu DB. */
    private void normalizeProduct(Product product) {
        if (product == null) {
            throw new IllegalArgumentException("Dữ liệu sản phẩm là bắt buộc.");
        }

        product.setName(trimRequired(product.getName()));
        product.setDescription(normalizeOptional(product.getDescription()));
        product.setBrand(normalizeOptional(product.getBrand()));
        if (product.getBrand() == null) {
            product.setBrand(DEFAULT_BRAND);
        }
        product.setModelCode(normalizeOptional(product.getModelCode()));
        product.setProductCondition(normalizeRequired(product.getProductCondition()));
        product.setImportType(normalizeRequired(product.getImportType()));
        product.setOriginCountry(normalizeOptional(product.getOriginCountry()));
        product.setWarrantyProvider(normalizeOptional(product.getWarrantyProvider()));
        if (product.getWarrantyProvider() == null) {
            product.setWarrantyProvider(DEFAULT_WARRANTY_PROVIDER);
        }
        product.setStatus(normalizeRequiredStatus(product.getStatus()));
    }

    /** Kiểm tra toàn bộ ràng buộc nghiệp vụ của sản phẩm. */
    private void validateProduct(Product product) {
        if (product.getCategoryId() <= 0) {
            throw new IllegalArgumentException("Danh mục không hợp lệ.");
        }
        if (product.getName().length() > MAX_NAME_LENGTH) {
            throw new IllegalArgumentException("Tên sản phẩm không được vượt quá 200 ký tự.");
        }
        if (product.getDescription() != null && product.getDescription().length() > MAX_DESCRIPTION_LENGTH) {
            throw new IllegalArgumentException("Mô tả không được vượt quá 2000 ký tự.");
        }
        if (product.getBrand() != null && product.getBrand().length() > MAX_BRAND_LENGTH) {
            throw new IllegalArgumentException("Thương hiệu không được vượt quá 50 ký tự.");
        }
        if (product.getModelCode() != null && product.getModelCode().length() > MAX_MODEL_CODE_LENGTH) {
            throw new IllegalArgumentException("Mã model không được vượt quá 50 ký tự.");
        }
        if (product.getReleaseYear() != null
                && (product.getReleaseYear() < MIN_RELEASE_YEAR || product.getReleaseYear() > MAX_RELEASE_YEAR)) {
            throw new IllegalArgumentException("Năm phát hành không hợp lệ.");
        }
        if (!ALLOWED_CONDITIONS.contains(product.getProductCondition())) {
            throw new IllegalArgumentException("Tình trạng sản phẩm không hợp lệ.");
        }
        if (!ALLOWED_IMPORT_TYPES.contains(product.getImportType())) {
            throw new IllegalArgumentException("Mã nhập khẩu không hợp lệ.");
        }
        if (product.getOriginCountry() != null && product.getOriginCountry().length() > MAX_ORIGIN_COUNTRY_LENGTH) {
            throw new IllegalArgumentException("Quốc gia xuất xứ không được vượt quá 100 ký tự.");
        }
        if (product.getWarrantyMonths() < 0) {
            throw new IllegalArgumentException("Thời hạn bảo hành phải lớn hơn hoặc bằng 0.");
        }
        if (product.getWarrantyProvider() != null
                && product.getWarrantyProvider().length() > MAX_WARRANTY_PROVIDER_LENGTH) {
            throw new IllegalArgumentException("Đơn vị bảo hành không được vượt quá 100 ký tự.");
        }
        if (!ALLOWED_STATUSES.contains(product.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }
    }

    /** Đảm bảo danh mục gắn với sản phẩm có tồn tại trong database. */
    private void validateCategoryExists(int categoryId) throws SQLException {
        if (categoryDAO.findById(categoryId).isEmpty()) {
            throw new IllegalArgumentException("Danh mục không tồn tại.");
        }
    }

    /** Đảm bảo ID sản phẩm hợp lệ trước khi update, đổi trạng thái hoặc tìm kiếm. */
    private void validateProductId(int productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        }
    }

    /** Chuẩn hóa categoryId của bộ lọc, cho phép null khi không lọc danh mục. */
    private Integer normalizeCategoryId(Integer categoryId) {
        if (categoryId == null) {
            return null;
        }
        if (categoryId <= 0) {
            throw new IllegalArgumentException("Bộ lọc danh mục không hợp lệ.");
        }
        return categoryId;
    }

    /** Chuẩn hóa trạng thái tùy chọn, trả về null nếu người dùng không lọc trạng thái. */
    private String normalizeOptionalStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return normalizeRequiredStatus(value);
    }

    /** Chuẩn hóa trạng thái bắt buộc và kiểm tra nó thuộc danh sách được phép. */
    private String normalizeRequiredStatus(String value) {
        String normalized = normalizeRequired(value);
        if (!ALLOWED_STATUSES.contains(normalized)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }
        return normalized;
    }

    /** Chuẩn hóa sort và chặn giá trị không nằm trong danh sách hỗ trợ. */
    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "newest";
        }
        String normalized = value.trim().toLowerCase();
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Tùy chọn sắp xếp không hợp lệ.");
        }
        return normalized;
    }

    /** Chuẩn hóa chuỗi bắt buộc thành chữ hoa sau khi kiểm tra không rỗng. */
    private String normalizeRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim().toUpperCase();
    }

    /** Cắt khoảng trắng và bắt buộc chuỗi phải có nội dung. */
    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim();
    }

    /** Cắt khoảng trắng cho chuỗi tùy chọn và chuyển chuỗi rỗng thành null. */
    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    /** Chuẩn hóa số trang, mặc định về trang đầu nếu giá trị không hợp lệ. */
    private int normalizePage(int page) {
        return page <= 0 ? DEFAULT_PAGE : page;
    }

    /** Chuẩn hóa kích thước trang và giới hạn tối đa để bảo vệ truy vấn. */
    private int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    // Gọi DAO lấy sản phẩm nổi bật
    public List<Product> getFeaturedProducts(int limit) {
        try {
            return productDAO.findFeaturedProducts(limit);
        } catch (SQLException e) {
            // Log lỗi nếu cần thiết
            e.printStackTrace();
            // Trả về danh sách rỗng để trang chủ không bị sập (crash)
            return Collections.emptyList();
        }
    }

    // Gọi DAO lấy sản phẩm mới nhất
    public List<Product> getNewProducts(int limit) {
        try {
            return productDAO.findNewProducts(limit);
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    // Gọi DAO lấy sản phẩm bán chạy nhất
    public List<Product> getBestSellerProducts(int limit) {
        try {
            return productDAO.findBestSellerProducts(limit);
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}
