package controller.admin.product.variant;

import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;
import service.catalog.ProductService;
import service.catalog.ProductVariantService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;

public abstract class VariantServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/product-variants/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/product-variants/form.jsp";
    protected static final String VARIANT_LIST_PATH = "/admin/products/variants";
    protected static final String PRODUCT_LIST_PATH = "/admin/products";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";
    private static final DateTimeFormatter DATE_TIME_INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    protected final ProductVariantService productVariantService = new ProductVariantService();
    protected final ProductService productService = new ProductService();

    protected void setVariantReferenceData(HttpServletRequest request) {
        request.setAttribute("variantStatusOptions", productVariantService.getAllowedStatuses());
        request.setAttribute("variantConnectivityOptions", productVariantService.getAllowedConnectivities());
        request.setAttribute("sortOptions", buildSortOptions());
    }

    protected ProductVariant createDefaultVariant(int productId) {
        ProductVariant variant = new ProductVariant();
        variant.setProductId(productId);
        variant.setActive(true);
        variant.setWeightKg(new BigDecimal("0.200"));
        return variant;
    }

    protected ProductVariant buildVariantFromRequest(HttpServletRequest request) {
        ProductVariant variant = new ProductVariant();
        variant.setVariantId(parseIntOrDefault(request.getParameter("variantId"), 0));
        variant.setProductId(parseInt(request.getParameter("productId"), "ID sản phẩm không hợp lệ."));
        variant.setSku(request.getParameter("sku"));
        variant.setVariantLabel(request.getParameter("variantLabel"));
        variant.setColorName(request.getParameter("colorName"));
        variant.setColorHex(request.getParameter("colorHex"));
        variant.setStorageCapacityGb(parseNullableInteger(request.getParameter("storageCapacityGb"), "Dung lượng lưu trữ không hợp lệ."));
        variant.setRamGb(parseNullableInteger(request.getParameter("ramGb"), "RAM không hợp lệ."));
        variant.setConnectivity(request.getParameter("connectivity"));
        variant.setChipOption(request.getParameter("chipOption"));
        variant.setScreenSizeInch(parseNullableBigDecimal(request.getParameter("screenSizeInch"), "Kích thước màn hình không hợp lệ."));
        variant.setPrice(parseRequiredBigDecimal(request.getParameter("price"), "Giá không hợp lệ."));
        variant.setStockQuantity(parseInt(request.getParameter("stockQuantity"), "Số lượng tồn kho không hợp lệ."));
        variant.setWeightKg(parseRequiredBigDecimal(request.getParameter("weightKg"), "Khối lượng không hợp lệ."));
        variant.setDiscountPrice(parseNullableBigDecimal(request.getParameter("discountPrice"), "Giá giảm không hợp lệ."));
        variant.setDiscountStart(parseNullableDateTime(request.getParameter("discountStart"), "Thời gian bắt đầu giảm giá không hợp lệ."));
        variant.setDiscountEnd(parseNullableDateTime(request.getParameter("discountEnd"), "Thời gian kết thúc giảm giá không hợp lệ."));
        variant.setActive(parseRequiredVariantStatusToActive(request.getParameter("status")));
        return variant;
    }

    protected ProductVariant buildVariantFromRequestForRedisplay(HttpServletRequest request) {
        ProductVariant variant = new ProductVariant();
        variant.setVariantId(parseIntOrDefault(request.getParameter("variantId"), 0));
        variant.setProductId(parseIntOrDefault(request.getParameter("productId"), 0));
        variant.setSku(request.getParameter("sku"));
        variant.setVariantLabel(request.getParameter("variantLabel"));
        variant.setColorName(request.getParameter("colorName"));
        variant.setColorHex(request.getParameter("colorHex"));
        variant.setStorageCapacityGb(parseNullableIntegerOrNull(request.getParameter("storageCapacityGb")));
        variant.setRamGb(parseNullableIntegerOrNull(request.getParameter("ramGb")));
        variant.setConnectivity(request.getParameter("connectivity"));
        variant.setChipOption(request.getParameter("chipOption"));
        variant.setScreenSizeInch(parseNullableBigDecimalOrNull(request.getParameter("screenSizeInch")));
        variant.setPrice(parseNullableBigDecimalOrNull(request.getParameter("price")));
        variant.setStockQuantity(parseIntOrDefault(request.getParameter("stockQuantity"), 0));
        variant.setWeightKg(parseNullableBigDecimalOrNull(request.getParameter("weightKg")));
        variant.setDiscountPrice(parseNullableBigDecimalOrNull(request.getParameter("discountPrice")));
        variant.setDiscountStart(parseNullableDateTimeOrNull(request.getParameter("discountStart")));
        variant.setDiscountEnd(parseNullableDateTimeOrNull(request.getParameter("discountEnd")));
        variant.setActive(!"INACTIVE".equalsIgnoreCase(request.getParameter("status")));
        return variant;
    }

    protected Product loadManagedProduct(int productId) throws java.sql.SQLException {
        return productService.getProductById(productId);
    }

    protected void setManagedProduct(HttpServletRequest request, Product product) {
        request.setAttribute("managedProduct", product);
    }

    protected void setVariantFormDateFields(HttpServletRequest request, ProductVariant variant) {
        request.setAttribute("discountStartValue", formatDateTimeInput(variant.getDiscountStart()));
        request.setAttribute("discountEndValue", formatDateTimeInput(variant.getDiscountEnd()));
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

    protected Integer parseNullableInteger(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return parseInt(value.trim(), errorMessage);
    }

    protected BigDecimal parseRequiredBigDecimal(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(errorMessage);
        }
        return parseBigDecimal(value.trim(), errorMessage);
    }

    protected BigDecimal parseNullableBigDecimal(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return parseBigDecimal(value.trim(), errorMessage);
    }

    protected LocalDateTime parseNullableDateTime(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim(), DATE_TIME_INPUT_FORMAT);
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    protected boolean parseRequiredVariantStatusToActive(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Trạng thái biến thể không hợp lệ.");
        }
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized)) {
            return true;
        }
        if ("INACTIVE".equals(normalized)) {
            return false;
        }
        throw new IllegalArgumentException("Trạng thái biến thể không hợp lệ.");
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

    protected String normalizeVariantSort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "newest";
        }
        return sort.trim().toLowerCase(Locale.ROOT);
    }

    protected String buildVariantListQueryString(String keyword, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    protected void redirectToVariantList(HttpServletRequest request, HttpServletResponse response, int productId)
            throws IOException {
        response.sendRedirect(request.getContextPath() + VARIANT_LIST_PATH + "?productId=" + productId);
    }

    protected void redirectToVariantListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                    int productId, String flashKey, String message)
            throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToVariantList(request, response, productId);
    }

    protected void redirectToProductListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                    String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        response.sendRedirect(request.getContextPath() + PRODUCT_LIST_PATH);
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    private int parsePositiveIntOrDefault(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }

    private BigDecimal parseBigDecimal(String value, String errorMessage) {
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
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

    private String formatDateTimeInput(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return DATE_TIME_INPUT_FORMAT.format(value);
    }

    private Integer parseNullableIntegerOrNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private BigDecimal parseNullableBigDecimalOrNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return new BigDecimal(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private LocalDateTime parseNullableDateTimeOrNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return LocalDateTime.parse(value.trim(), DATE_TIME_INPUT_FORMAT);
        } catch (DateTimeParseException ex) {
            return null;
        }
    }

    private List<SortOption> buildSortOptions() {
        return List.of(
                new SortOption("newest", "Mới nhất"),
                new SortOption("oldest", "Cũ nhất"),
                new SortOption("sku_asc", "SKU A-Z"),
                new SortOption("sku_desc", "SKU Z-A"),
                new SortOption("label_asc", "Nhãn A-Z"),
                new SortOption("label_desc", "Nhãn Z-A"),
                new SortOption("price_asc", "Giá thấp đến cao"),
                new SortOption("price_desc", "Giá cao đến thấp"),
                new SortOption("stock_asc", "Tồn kho thấp đến cao"),
                new SortOption("stock_desc", "Tồn kho cao đến thấp")
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
