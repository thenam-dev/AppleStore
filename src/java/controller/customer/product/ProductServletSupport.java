package controller.customer.product;

import jakarta.servlet.http.HttpServlet;

import java.util.Arrays;
import java.util.List;

/**
 * Helper dùng chung cho các servlet sản phẩm phía khách hàng (guest).
 * Mirror lại đúng phong cách của controller.admin.product.ProductServletSupport
 * nhưng KHÔNG có filter theo status ACTIVE/INACTIVE (khách chỉ được thấy
 * sản phẩm ACTIVE, việc lọc ACTIVE phải làm ở tầng DAO/Service, không hỏi
 * status từ request như trang admin).
 */
public abstract class ProductServletSupport extends HttpServlet {

    protected static final int DEFAULT_PAGE_SIZE = 8;
    protected static final int LOW_STOCK_THRESHOLD = 5;

    private static final List<String> ALLOWED_SORTS =
            Arrays.asList("featured", "newest", "best-selling", "price-asc", "price-desc");

    /** Parse 1 tham số Integer dương tuỳ chọn (categoryId, id...). null/rỗng -> null. */
    protected Integer parseOptionalPositiveInt(String raw, String errorMessage) {
        if (raw == null || raw.trim().isEmpty()) {
            return null;
        }
        try {
            int value = Integer.parseInt(raw.trim());
            if (value <= 0) {
                throw new IllegalArgumentException(errorMessage);
            }
            return value;
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage);
        }
    }

    /** Chuẩn hoá tham số sort, mặc định "featured" nếu không hợp lệ. */
    protected String normalizeProductSort(String raw) {
        if (raw == null || !ALLOWED_SORTS.contains(raw.trim())) {
            return "featured";
        }
        return raw.trim();
    }

    /** Parse số trang, mặc định 1, không cho < 1. */
    protected int parsePage(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return 1;
        }
        try {
            int page = Integer.parseInt(raw.trim());
            return Math.max(page, 1);
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    /** Tính tổng số trang, tối thiểu 1 trang dù danh sách rỗng. */
    protected int calculateTotalPages(int totalItems, int pageSize) {
        if (totalItems <= 0 || pageSize <= 0) {
            return 1;
        }
        return (int) Math.ceil((double) totalItems / pageSize);
    }

    /** Chuỗi rỗng/toàn dấu cách -> null, còn lại trim(). */
    protected String trimToNull(String raw) {
        if (raw == null) {
            return null;
        }
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}