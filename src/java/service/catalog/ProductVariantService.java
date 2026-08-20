package service.catalog;

import config.AppConfig;
import dao.catalog.CategoryDAO;
import dao.catalog.ProductDAO;
import dao.catalog.ProductVariantDAO;
import model.entity.catalog.Category;
import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

public class ProductVariantService {
    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = AppConfig.PAGE_SIZE_ADMIN;
    private static final int MAX_PAGE_SIZE = 100;
    private static final int MAX_SKU_LENGTH = 50;
    private static final int MAX_LABEL_LENGTH = 150;
    private static final int MAX_COLOR_NAME_LENGTH = 50;
    private static final List<String> ALLOWED_STATUSES = List.of("ACTIVE", "INACTIVE");
    private static final List<String> ALLOWED_CONNECTIVITIES = List.of("WIFI", "WIFI_CELLULAR");
    private static final List<String> ALLOWED_SORTS = List.of(
            "newest",
            "oldest",
            "sku_asc",
            "sku_desc",
            "label_asc",
            "label_desc",
            "price_asc",
            "price_desc",
            "stock_asc",
            "stock_desc"
    );

    private final ProductVariantDAO productVariantDAO;
    private final ProductDAO productDAO;
    private final CategoryDAO categoryDAO;
    private final ProductVariantAttributeService attributeService = new ProductVariantAttributeService();

    /** Khởi tạo service biến thể với DAO mặc định. */
    public ProductVariantService() {
        this(new ProductVariantDAO(), new ProductDAO(), new CategoryDAO());
    }

    /** Cho phép inject DAO để dễ kiểm thử hoặc thay thế nguồn dữ liệu. */
    public ProductVariantService(ProductVariantDAO productVariantDAO, ProductDAO productDAO) {
        this(productVariantDAO, productDAO, new CategoryDAO());
    }

    /** Cho phép inject DAO để dễ kiểm thử hoặc thay thế nguồn dữ liệu. */
    public ProductVariantService(ProductVariantDAO productVariantDAO, ProductDAO productDAO, CategoryDAO categoryDAO) {
        this.productVariantDAO = productVariantDAO;
        this.productDAO = productDAO;
        this.categoryDAO = categoryDAO;
    }

    /** Lấy danh sách biến thể của một sản phẩm theo filter, sort và phân trang. */
    public List<ProductVariant> getVariants(int productId, String keyword, String status, String sort, int page, int pageSize)
            throws SQLException {
        return productVariantDAO.findByProduct(
                normalizeProductId(productId),
                normalizeKeyword(keyword),
                normalizeOptionalStatus(status),
                normalizeSort(sort),
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    /** Đếm biến thể của một sản phẩm sau khi áp dụng keyword và trạng thái. */
    public int countVariants(int productId, String keyword, String status) throws SQLException {
        return productVariantDAO.countByProduct(
                normalizeProductId(productId),
                normalizeKeyword(keyword),
                normalizeOptionalStatus(status)
        );
    }

    /** Đếm biến thể theo trạng thái để hiển thị KPI trên màn variant. */
    public int countVariantsByStatus(int productId, String status) throws SQLException {
        return productVariantDAO.countByProduct(normalizeProductId(productId), null, normalizeRequiredStatus(status));
    }

    /** Lấy biến thể theo ID và báo lỗi nghiệp vụ nếu không tồn tại. */
    public ProductVariant getVariantById(int variantId) throws SQLException {
        validateVariantId(variantId);
        return productVariantDAO.findById(variantId)
                .orElseThrow(() -> new IllegalArgumentException("Biến thể không tồn tại."));
    }

    /** Tạo biến thể mới sau khi chuẩn hóa, validate, kiểm tra product cha và chống trùng SKU. */
    public int createVariant(ProductVariant variant) throws SQLException {
        normalizeVariant(variant);
        validateVariant(variant);
        validateProductExists(variant.getProductId());

        if (productVariantDAO.existsBySku(variant.getSku())) {
            throw new IllegalArgumentException("SKU đã tồn tại.");
        }

        return productVariantDAO.insert(variant);
    }

    /** Cập nhật biến thể sau khi validate ID, product cha và chống trùng SKU với biến thể khác. */
    public void updateVariant(ProductVariant variant) throws SQLException {
        validateVariantId(variant.getVariantId());
        normalizeProductId(variant.getProductId());

        ProductVariant existingVariant = getVariantById(variant.getVariantId());
        if (existingVariant.getProductId() != variant.getProductId()) {
            throw new IllegalArgumentException("Không thể chuyển biến thể sang sản phẩm khác.");
        }

        normalizeVariant(variant);
        validateVariant(variant);
        validateProductExists(variant.getProductId());

        if (productVariantDAO.existsBySkuForOtherVariant(variant.getVariantId(), variant.getSku())) {
            throw new IllegalArgumentException("SKU đã tồn tại.");
        }
        if (!productVariantDAO.update(variant)) {
            throw new IllegalArgumentException("Biến thể không tồn tại.");
        }
    }

    /**
     * Đổi trạng thái active/inactive của một biến thể thuộc đúng product cha.
     * Khi bật variant, product cha cũng phải đang ACTIVE.
     */
    public void changeStatus(int productId, int variantId, boolean isActive) throws SQLException {
        normalizeProductId(productId);
        validateVariantId(variantId);

        ProductVariant variant = productVariantDAO.findById(variantId)
                .orElseThrow(() -> new IllegalArgumentException("Biến thể không tồn tại."));
        if (variant.getProductId() != productId) {
            throw new IllegalArgumentException("Biến thể không thuộc sản phẩm này.");
        }

        if (isActive) {
            Product product = productDAO.findById(productId)
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
            validateProductAndCategoryCanSellVariant(product);
        }

        if (!productVariantDAO.updateStatus(productId, variantId, isActive)) {
            throw new IllegalArgumentException("Biến thể không thuộc sản phẩm này hoặc không tồn tại.");
        }
    }

    /** Trả về trạng thái biến thể hợp lệ cho UI và validate. */
    public List<String> getAllowedStatuses() {
        return ALLOWED_STATUSES;
    }

    /** Trả về các tùy chọn kết nối hợp lệ như WIFI hoặc WIFI_CELLULAR. */
    public List<String> getAllowedConnectivities() {
        return ALLOWED_CONNECTIVITIES;
    }

    /** Trả về danh sách sort hợp lệ cho màn biến thể. */
    public List<String> getAllowedSorts() {
        return ALLOWED_SORTS;
    }

    /** Chuẩn hóa chuỗi và trạng thái của biến thể trước khi validate. */
    private void normalizeVariant(ProductVariant variant) {
        if (variant == null) {
            throw new IllegalArgumentException("Dữ liệu biến thể là bắt buộc.");
        }

        variant.setSku(normalizeRequiredSku(variant.getSku()));
        variant.setVariantLabel(trimRequired(variant.getVariantLabel()));
        variant.setColorName(normalizeOptional(variant.getColorName()));
        variant.setCaseSizeMm(variant.getCaseSizeMm());
        variant.setConnectivity(normalizeOptionalUpper(variant.getConnectivity()));
    }

    /** Kiểm tra toàn bộ ràng buộc nghiệp vụ của biến thể sản phẩm. */
    private void validateVariant(ProductVariant variant) throws SQLException {
        if (variant.getProductId() <= 0) {
            throw new IllegalArgumentException("Sản phẩm không hợp lệ.");
        }
        if (variant.getSku().length() > MAX_SKU_LENGTH) {
            throw new IllegalArgumentException("SKU không được vượt quá 50 ký tự.");
        }
        if (variant.getVariantLabel().length() > MAX_LABEL_LENGTH) {
            throw new IllegalArgumentException("Nhãn biến thể không được vượt quá 150 ký tự.");
        }
        if (variant.getColorName() != null && variant.getColorName().length() > MAX_COLOR_NAME_LENGTH) {
            throw new IllegalArgumentException("Tên màu không được vượt quá 50 ký tự.");
        }
        if (variant.getCaseSizeMm() != null && variant.getCaseSizeMm() <= 0) {
            throw new IllegalArgumentException("Kích thước vỏ phải lớn hơn 0.");
        }
        if (variant.getStorageCapacityGb() != null && variant.getStorageCapacityGb() < 0) {
            throw new IllegalArgumentException("Dung lượng lưu trữ phải lớn hơn hoặc bằng 0.");
        }
        if (variant.getRamGb() != null && variant.getRamGb() < 0) {
            throw new IllegalArgumentException("RAM phải lớn hơn hoặc bằng 0.");
        }
        if (variant.getConnectivity() != null && !ALLOWED_CONNECTIVITIES.contains(variant.getConnectivity())) {
            throw new IllegalArgumentException("Kết nối không hợp lệ.");
        }
        Product product = productDAO.findById(variant.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
        if (variant.isActive()) {
            validateProductAndCategoryCanSellVariant(product);
        }
        validateConfiguredAttributes(variant, product);
        validateUniqueCombination(variant, product);
        if (variant.getPrice() == null || variant.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá phải lớn hơn hoặc bằng 0.");
        }
        if (variant.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Số lượng tồn kho phải lớn hơn hoặc bằng 0.");
        }
        if (variant.getWeightKg() == null || variant.getWeightKg().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Khối lượng phải lớn hơn 0.");
        }
        if (variant.getDiscountPrice() != null) {
            if (variant.getDiscountPrice().compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("Giá giảm phải lớn hơn hoặc bằng 0.");
            }
            if (variant.getDiscountPrice().compareTo(variant.getPrice()) > 0) {
                throw new IllegalArgumentException("Giá giảm không được lớn hơn giá bán.");
            }
        }

        boolean hasDiscountStart = variant.getDiscountStart() != null;
        boolean hasDiscountEnd = variant.getDiscountEnd() != null;
        if (hasDiscountStart != hasDiscountEnd) {
            throw new IllegalArgumentException("Thời gian bắt đầu và kết thúc giảm giá phải cùng được nhập hoặc cùng để trống.");
        }
        if (hasDiscountStart && !variant.getDiscountEnd().isAfter(variant.getDiscountStart())) {
            throw new IllegalArgumentException("Thời gian kết thúc giảm giá phải sau thời gian bắt đầu.");
        }
    }

    /** Bắt buộc các dimension đã cấu hình cho nhóm sản phẩm phải được nhập đầy đủ. */
    private void validateConfiguredAttributes(ProductVariant variant, Product product) {
        for (ProductVariantAttributeService.Definition definition : attributeService.getDefinitions(product)) {
            switch (definition.getKey()) {
                case "color" -> requireText(variant.getColorName(), "Màu sắc là bắt buộc.");
                case "storage" -> requireInteger(variant.getStorageCapacityGb(), "Dung lượng là bắt buộc.");
                case "ram" -> requireInteger(variant.getRamGb(), "RAM là bắt buộc.");
                case "connectivity" -> requireText(variant.getConnectivity(), "Kết nối là bắt buộc.");
                case "caseSize" -> requireInteger(variant.getCaseSizeMm(), "Kích thước vỏ là bắt buộc.");
                default -> { }
            }
        }
    }

    /** Không cho phép hai SKU khác nhau đại diện cho cùng một tổ hợp selector. */
    private void validateUniqueCombination(ProductVariant candidate, Product product) throws SQLException {
        int total = productVariantDAO.countByProduct(candidate.getProductId(), null, null);
        if (total <= 0) {
            return;
        }
        List<ProductVariant> existingVariants = productVariantDAO.findByProduct(
                candidate.getProductId(), null, null, "newest", 1, total);
        List<ProductVariantAttributeService.Definition> definitions = attributeService.getDefinitions(product);
        for (ProductVariant existing : existingVariants) {
            if (existing.getVariantId() == candidate.getVariantId()) {
                continue;
            }
            boolean same = definitions.stream().allMatch(definition ->
                    Objects.equals(attributeValue(existing, definition.getKey()),
                            attributeValue(candidate, definition.getKey())));
            if (same) {
                throw new IllegalArgumentException("Tổ hợp thuộc tính này đã có variant khác.");
            }
        }
    }

    private Object attributeValue(ProductVariant variant, String key) {
        return switch (key) {
            case "color" -> normalizeOptional(variant.getColorName());
            case "storage" -> variant.getStorageCapacityGb();
            case "ram" -> variant.getRamGb();
            case "connectivity" -> normalizeOptionalUpper(variant.getConnectivity());
            case "caseSize" -> variant.getCaseSizeMm();
            default -> null;
        };
    }

    private void requireText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
    }

    private void requireInteger(Integer value, String message) {
        if (value == null) {
            throw new IllegalArgumentException(message);
        }
    }

    /** Đảm bảo product cha tồn tại trước khi tạo hoặc cập nhật biến thể. */
    private void validateProductExists(int productId) throws SQLException {
        if (productDAO.findById(productId).isEmpty()) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
        }
    }

    private void validateProductAndCategoryCanSellVariant(Product product) throws SQLException {
        if (!"ACTIVE".equalsIgnoreCase(product.getStatus())) {
            throw new IllegalArgumentException("Không thể bật biến thể khi sản phẩm chưa ở trạng thái đang bán.");
        }
        Category category = categoryDAO.findById(product.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Danh mục không tồn tại."));
        if (!category.getIsActive()) {
            throw new IllegalArgumentException("Không thể bật biến thể khi danh mục đang tạm ẩn.");
        }
    }

    /** Chuẩn hóa và validate productId dùng trong các truy vấn variant. */
    private int normalizeProductId(int productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        }
        return productId;
    }

    /** Đảm bảo variantId là số dương trước khi cập nhật hoặc đổi trạng thái. */
    private void validateVariantId(int variantId) {
        if (variantId <= 0) {
            throw new IllegalArgumentException("ID biến thể không hợp lệ.");
        }
    }

    /** Chuẩn hóa keyword tìm kiếm variant, cho phép null khi không tìm kiếm. */
    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return keyword.trim();
    }

    /** Chuẩn hóa trạng thái tùy chọn, trả về null nếu không lọc trạng thái. */
    private String normalizeOptionalStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return normalizeRequiredStatus(value);
    }

    /** Chuẩn hóa trạng thái bắt buộc và kiểm tra thuộc danh sách hợp lệ. */
    private String normalizeRequiredStatus(String value) {
        String normalized = normalizeRequiredUpper(value);
        if (!ALLOWED_STATUSES.contains(normalized)) {
            throw new IllegalArgumentException("Trạng thái biến thể không hợp lệ.");
        }
        return normalized;
    }

    /** Chuẩn hóa sort và chặn sort key không được hỗ trợ. */
    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "newest";
        }
        String normalized = value.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Tùy chọn sắp xếp không hợp lệ.");
        }
        return normalized;
    }

    /** Chuẩn hóa SKU bắt buộc theo dạng viết hoa. */
    private String normalizeRequiredSku(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    /** Chuẩn hóa chuỗi bắt buộc thành chữ hoa, dùng cho connectivity. */
    private String normalizeRequiredUpper(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim().toUpperCase(Locale.ROOT);
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

    /** Chuẩn hóa chuỗi tùy chọn thành chữ hoa nếu có dữ liệu. */
    private String normalizeOptionalUpper(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    /** Chuẩn hóa số trang, mặc định về trang đầu nếu không hợp lệ. */
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
}
