package controller.admin.product;

import config.AppConfig;
import model.entity.catalog.Product;
import service.catalog.CategoryService;
import service.catalog.ProductService;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

public abstract class ProductServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/products/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/products/form.jsp";
    protected static final String PRODUCT_LIST_PATH = "/admin/products";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";

    protected final ProductService productService = new ProductService();
    protected final CategoryService categoryService = new CategoryService();

    protected void setProductReferenceData(HttpServletRequest request) throws java.sql.SQLException {
        request.setAttribute("categories", categoryService.getActiveCategories());
        request.setAttribute("productStatusOptions", productService.getAllowedStatuses());
        request.setAttribute("productConditionOptions", productService.getAllowedConditions());
        request.setAttribute("productImportTypeOptions", productService.getAllowedImportTypes());
        request.setAttribute("sortOptions", buildSortOptions());
    }

    protected void setProductReferenceDataFallback(HttpServletRequest request) {
        request.setAttribute("categories", java.util.List.of());
        request.setAttribute("productStatusOptions", productService.getAllowedStatuses());
        request.setAttribute("productConditionOptions", productService.getAllowedConditions());
        request.setAttribute("productImportTypeOptions", productService.getAllowedImportTypes());
        request.setAttribute("sortOptions", buildSortOptions());
    }

    protected Product createDefaultProduct() {
        Product product = new Product();
        product.setBrand("Apple");
        product.setProductCondition("NEW");
        product.setImportType("VN/A");
        product.setWarrantyMonths(12);
        product.setWarrantyProvider("Apple Viet Nam");
        product.setStatus("ACTIVE");
        return product;
    }

    protected Product buildProductFromRequest(HttpServletRequest request) {
        Product product = new Product();
        product.setProductId(parseIntOrDefault(request.getParameter("productId"), 0));
        product.setCategoryId(parseInt(request.getParameter("categoryId"), "Danh mục không hợp lệ."));
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));
        product.setBrand("Apple");
        product.setModelCode(request.getParameter("modelCode"));
        product.setReleaseYear(parseNullableInt(request.getParameter("releaseYear"), "Năm phát hành không hợp lệ."));
        product.setProductCondition(request.getParameter("productCondition"));
        product.setImportType(request.getParameter("importType"));
        product.setOriginCountry(request.getParameter("originCountry"));
        product.setWarrantyMonths(parseInt(request.getParameter("warrantyMonths"), "Thời hạn bảo hành không hợp lệ."));
        product.setWarrantyProvider("Apple Viet Nam");
        product.setStatus(request.getParameter("status"));
        product.setFeatured("on".equals(request.getParameter("isFeatured")));
        return product;
    }

    protected Integer parseOptionalPositiveInt(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }

        int parsed = parseInt(value, errorMessage);
        if (parsed <= 0) {
            throw new IllegalArgumentException(errorMessage);
        }
        return parsed;
    }

    protected Integer parseNullableInt(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return parseInt(value, errorMessage);
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

    protected int parsePage(String value) {
        return parsePositiveIntOrDefault(value, 1);
    }

    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (pageSize <= 0) {
            return 1;
        }
        return Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
    }

    protected String normalizeProductSort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "newest";
        }
        return sort.trim().toLowerCase();
    }

    protected String buildProductListQueryString(String keyword, Integer categoryId, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "categoryId", categoryId == null ? null : String.valueOf(categoryId));
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    protected void redirectToProductList(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + PRODUCT_LIST_PATH);
    }

    protected void redirectToProductListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                    String flashKey, String message) throws IOException {
        setFlashMessage(request, flashKey, message);
        redirectToProductList(request, response);
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
                new SortOption("newest", "Mới nhất"),
                new SortOption("oldest", "Cũ nhất"),
                new SortOption("name_asc", "Tên A-Z"),
                new SortOption("name_desc", "Tên Z-A"),
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
