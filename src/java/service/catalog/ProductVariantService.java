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

    public ProductVariantService() {
        this(new ProductVariantDAO(), new ProductDAO());
    }

    public ProductVariantService(ProductVariantDAO productVariantDAO, ProductDAO productDAO) {
        this.productVariantDAO = productVariantDAO;
        this.productDAO = productDAO;
    }

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

    public int countVariants(int productId, String keyword, String status) throws SQLException {
        return productVariantDAO.countByProduct(
                normalizeProductId(productId),
                normalizeKeyword(keyword),
                normalizeOptionalStatus(status)
        );
    }

    public int countVariantsByStatus(int productId, String status) throws SQLException {
        return productVariantDAO.countByProduct(normalizeProductId(productId), null, normalizeRequiredStatus(status));
    }

    public ProductVariant getVariantById(int variantId) throws SQLException {
        validateVariantId(variantId);
        return productVariantDAO.findById(variantId)
                .orElseThrow(() -> new IllegalArgumentException("Variant does not exist."));
    }

    public int createVariant(ProductVariant variant) throws SQLException {
        normalizeVariant(variant);
        validateVariant(variant);
        validateProductExists(variant.getProductId());

        if (productVariantDAO.existsBySku(variant.getSku())) {
            throw new IllegalArgumentException("SKU already exists.");
        }

        return productVariantDAO.insert(variant);
    }

    public void updateVariant(ProductVariant variant) throws SQLException {
        validateVariantId(variant.getVariantId());
        normalizeVariant(variant);
        validateVariant(variant);
        validateProductExists(variant.getProductId());

        if (productVariantDAO.existsBySkuForOtherVariant(variant.getVariantId(), variant.getSku())) {
            throw new IllegalArgumentException("SKU already exists.");
        }
        if (!productVariantDAO.update(variant)) {
            throw new IllegalArgumentException("Variant does not exist.");
        }
    }

    public void changeStatus(int variantId, boolean isActive) throws SQLException {
        validateVariantId(variantId);
        if (!productVariantDAO.updateStatus(variantId, isActive)) {
            throw new IllegalArgumentException("Variant does not exist.");
        }
    }

    public List<String> getAllowedStatuses() {
        return ALLOWED_STATUSES;
    }

    public List<String> getAllowedConnectivities() {
        return ALLOWED_CONNECTIVITIES;
    }

    public List<String> getAllowedSorts() {
        return ALLOWED_SORTS;
    }

    private void normalizeVariant(ProductVariant variant) {
        if (variant == null) {
            throw new IllegalArgumentException("Variant data is required.");
        }

        variant.setSku(normalizeRequiredSku(variant.getSku()));
        variant.setVariantLabel(trimRequired(variant.getVariantLabel()));
        variant.setColorName(normalizeOptional(variant.getColorName()));
        variant.setColorHex(normalizeOptionalUpper(variant.getColorHex()));
        variant.setConnectivity(normalizeOptionalUpper(variant.getConnectivity()));
        variant.setChipOption(normalizeOptional(variant.getChipOption()));
    }

    private void validateVariant(ProductVariant variant) {
        if (variant.getProductId() <= 0) {
            throw new IllegalArgumentException("Product is invalid.");
        }
        if (variant.getSku().length() > MAX_SKU_LENGTH) {
            throw new IllegalArgumentException("SKU must be 50 characters or less.");
        }
        if (variant.getVariantLabel().length() > MAX_LABEL_LENGTH) {
            throw new IllegalArgumentException("Variant label must be 150 characters or less.");
        }
        if (variant.getColorName() != null && variant.getColorName().length() > MAX_COLOR_NAME_LENGTH) {
            throw new IllegalArgumentException("Color name must be 50 characters or less.");
        }
        if (variant.getColorHex() != null) {
            if (variant.getColorHex().length() > MAX_COLOR_HEX_LENGTH || !COLOR_HEX_PATTERN.matcher(variant.getColorHex()).matches()) {
                throw new IllegalArgumentException("Color hex must follow format #RRGGBB.");
            }
        }
        if (variant.getStorageCapacityGb() != null && variant.getStorageCapacityGb() < 0) {
            throw new IllegalArgumentException("Storage capacity must be 0 or greater.");
        }
        if (variant.getRamGb() != null && variant.getRamGb() < 0) {
            throw new IllegalArgumentException("RAM must be 0 or greater.");
        }
        if (variant.getConnectivity() != null && !ALLOWED_CONNECTIVITIES.contains(variant.getConnectivity())) {
            throw new IllegalArgumentException("Connectivity is invalid.");
        }
        if (variant.getChipOption() != null && variant.getChipOption().length() > MAX_CHIP_OPTION_LENGTH) {
            throw new IllegalArgumentException("Chip option must be 50 characters or less.");
        }
        if (variant.getScreenSizeInch() != null && variant.getScreenSizeInch().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Screen size must be greater than 0.");
        }
        if (variant.getPrice() == null || variant.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price must be 0 or greater.");
        }
        if (variant.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Stock quantity must be 0 or greater.");
        }
        if (variant.getWeightKg() == null || variant.getWeightKg().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Weight must be greater than 0.");
        }
        if (variant.getDiscountPrice() != null) {
            if (variant.getDiscountPrice().compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("Discount price must be 0 or greater.");
            }
            if (variant.getDiscountPrice().compareTo(variant.getPrice()) > 0) {
                throw new IllegalArgumentException("Discount price must not be greater than price.");
            }
        }

        boolean hasDiscountStart = variant.getDiscountStart() != null;
        boolean hasDiscountEnd = variant.getDiscountEnd() != null;
        if (hasDiscountStart != hasDiscountEnd) {
            throw new IllegalArgumentException("Discount start and end must both be filled or both be empty.");
        }
        if (hasDiscountStart && !variant.getDiscountEnd().isAfter(variant.getDiscountStart())) {
            throw new IllegalArgumentException("Discount end must be after discount start.");
        }
    }

    private void validateProductExists(int productId) throws SQLException {
        if (productDAO.findById(productId).isEmpty()) {
            throw new IllegalArgumentException("Product does not exist.");
        }
    }

    private int normalizeProductId(int productId) {
        if (productId <= 0) {
            throw new IllegalArgumentException("Product id is invalid.");
        }
        return productId;
    }

    private void validateVariantId(int variantId) {
        if (variantId <= 0) {
            throw new IllegalArgumentException("Variant id is invalid.");
        }
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return keyword.trim();
    }

    private String normalizeOptionalStatus(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return normalizeRequiredStatus(value);
    }

    private String normalizeRequiredStatus(String value) {
        String normalized = normalizeRequiredUpper(value);
        if (!ALLOWED_STATUSES.contains(normalized)) {
            throw new IllegalArgumentException("Variant status is invalid.");
        }
        return normalized;
    }

    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "newest";
        }
        String normalized = value.trim().toLowerCase(Locale.ROOT);
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Sort option is invalid.");
        }
        return normalized;
    }

    private String normalizeRequiredSku(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String normalizeRequiredUpper(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeOptionalUpper(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim().toUpperCase(Locale.ROOT);
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
}
