package service.catalog;

import config.AppConfig;
import dao.catalog.ProductDAO;
import dao.catalog.ProductVariantDAO;
import model.entity.catalog.ProductVariant;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

public class ProductVariantService {
    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = AppConfig.PAGE_SIZE_ADMIN;
    private static final int MAX_PAGE_SIZE = 100;
    private static final int MAX_SKU_LENGTH = 50;
    private static final int MAX_LABEL_LENGTH = 150;
    private static final int MAX_COLOR_NAME_LENGTH = 50;
    private static final int MAX_COLOR_HEX_LENGTH = 7;
    private static final int MAX_CHIP_OPTION_LENGTH = 50;
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
    private static final Pattern COLOR_HEX_PATTERN = Pattern.compile("^#[0-9A-F]{6}$");

    private final ProductVariantDAO productVariantDAO;
    private final ProductDAO productDAO;

    /** Khởi tạo service biến thể với DAO mặc định. */
    public ProductVariantService() {
        this(new ProductVariantDAO(), new ProductDAO());
    }

    /** Cho phép inject DAO để dễ kiểm thử hoặc thay thế nguồn dữ liệu. */
    public ProductVariantService(ProductVariantDAO productVariantDAO, ProductDAO productDAO) {
        this.productVariantDAO = productVariantDAO;
        this.productDAO = productDAO;
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

    /** Đổi trạng thái active/inactive của một biến thể. */
    public void changeStatus(int variantId, boolean isActive) throws SQLException {
        validateVariantId(variantId);
        if (!productVariantDAO.updateStatus(variantId, isActive)) {
            throw new IllegalArgumentException("Biến thể không tồn tại.");
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
        variant.setColorHex(normalizeOptionalUpper(variant.getColorHex()));
        variant.setConnectivity(normalizeOptionalUpper(variant.getConnectivity()));
        variant.setChipOption(normalizeOptional(variant.getChipOption()));
    }

    /** Kiểm tra toàn bộ ràng buộc nghiệp vụ của biến thể sản phẩm. */
    private void validateVariant(ProductVariant variant) {
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
        if (variant.getColorHex() != null) {
            if (variant.getColorHex().length() > MAX_COLOR_HEX_LENGTH || !COLOR_HEX_PATTERN.matcher(variant.getColorHex()).matches()) {
                throw new IllegalArgumentException("Mã màu phải theo định dạng #RRGGBB.");
            }
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
        if (variant.getChipOption() != null && variant.getChipOption().length() > MAX_CHIP_OPTION_LENGTH) {
            throw new IllegalArgumentException("Tùy chọn chip không được vượt quá 50 ký tự.");
        }
        if (variant.getScreenSizeInch() != null && variant.getScreenSizeInch().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Kích thước màn hình phải lớn hơn 0.");
        }
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

    /** Đảm bảo product cha tồn tại trước khi tạo hoặc cập nhật biến thể. */
    private void validateProductExists(int productId) throws SQLException {
        if (productDAO.findById(productId).isEmpty()) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại.");
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
