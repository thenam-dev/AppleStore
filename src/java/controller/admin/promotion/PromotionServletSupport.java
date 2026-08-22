package controller.admin.promotion;

import service.catalog.CategoryService;
import service.catalog.ProductService;
import service.promotion.PromotionService;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Locale;

public abstract class PromotionServletSupport extends HttpServlet {
    protected static final String LIST_VIEW = "/WEB-INF/views/admin/promotions/list.jsp";
    protected static final String FORM_VIEW = "/WEB-INF/views/admin/promotions/form.jsp";
    protected static final String PROMO_LIST_PATH = "/admin/promotions";
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";

    protected final PromotionService promotionService = new PromotionService();
    protected final CategoryService categoryService = new CategoryService();
    protected final ProductService productService = new ProductService();

    /** Nạp các master data (Danh mục, Sản phẩm) phục vụ form chọn Scope */
    protected void setPromotionFormOptions(HttpServletRequest request) {
        try {
            request.setAttribute("categories", categoryService.getActiveCategories());
            request.setAttribute("products", productService.getProducts(null, null, "ACTIVE", "name_asc", 1, 1000));
        } catch (Exception e) {
            getServletContext().log("Lỗi load master data cho form Promotion: ", e);
        }
    }

    protected void redirectToPromotionListWithMessage(HttpServletRequest request, HttpServletResponse response,
                                                      String flashKey, String message) throws IOException {
        if (message != null && !message.isBlank()) {
            request.getSession().setAttribute(flashKey, message);
        }
        response.sendRedirect(request.getContextPath() + PROMO_LIST_PATH);
    }

    protected void moveFlashMessagesToRequest(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            moveFlash(request, session, FLASH_SUCCESS_KEY);
            moveFlash(request, session, FLASH_ERROR_KEY);
        }
    }

    private void moveFlash(HttpServletRequest request, HttpSession session, String key) {
        Object msg = session.getAttribute(key);
        if (msg instanceof String && !((String) msg).isBlank()) {
            request.setAttribute(key, msg);
        }
        session.removeAttribute(key);
    }

    protected int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) return defaultValue;
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    protected String normalizeStatusFilter(String value) {
        if (value == null || value.isBlank()) return null;
        String normalized = value.trim().toUpperCase(Locale.ROOT);
        if ("ACTIVE".equals(normalized) || "INACTIVE".equals(normalized)) return normalized;
        return null;
    }

    protected String normalizeSort(String sort) {
        if (sort == null || sort.isBlank()) return "newest";
        return sort.trim().toLowerCase(Locale.ROOT);
    }

    protected String buildListQueryString(String keyword, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String key, String value) {
        if (value == null || value.isBlank()) return;
        if (!query.isEmpty()) query.append('&');
        query.append(key).append('=').append(URLEncoder.encode(value, StandardCharsets.UTF_8));
    }

    protected List<SortOption> buildSortOptions() {
        return List.of(
            new SortOption("newest", "Mới nhất"),
            new SortOption("oldest", "Cũ nhất"),
            new SortOption("discount_desc", "Mức giảm cao nhất"),
            new SortOption("discount_asc", "Mức giảm thấp nhất")
        );
    }

    public static final class SortOption {
        private final String value;
        private final String label;

        public SortOption(String value, String label) {
            this.value = value;
            this.label = label;
        }

        public String getValue() { return value; }
        public String getLabel() { return label; }
    }
}