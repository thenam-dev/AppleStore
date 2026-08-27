package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * Tiện ích dùng chung để nhớ tập cart_item_id mà khách đã tick chọn ở giỏ
 * hàng để mang sang thanh toán (chỉ thanh toán 1 phần giỏ hàng thay vì toàn
 * bộ). Lưu trong session vì luồng thanh toán đi qua nhiều servlet khác nhau
 * (CheckoutServlet, ApplyVoucherServlet, RemoveVoucherServlet) và người dùng
 * có thể rời trang (xem voucher...) rồi quay lại /checkout mà không kèm lại
 * tham số đã chọn.
 */
public final class CheckoutSelectionUtil {

    private static final String SESSION_KEY = "checkoutItemIds";

    /**
     * Số lượng "ghi đè" cho nút "Mua ngay" - map cartItemId -> số lượng thực
     * sự muốn đặt ở lần thanh toán này, tách biệt với số lượng đang tồn trong
     * dòng cart_items (dòng đó có thể đã bị cộng dồn thêm số lượng cũ có sẵn
     * trong giỏ trước khi bấm "Mua ngay" - xem CartService.addToCart()). Chỉ
     * áp dụng khi khách bấm "Mua ngay" (đúng 1 cartItemId kèm buyNowQty), lưu
     * session cùng vòng đời với SESSION_KEY ở trên vì cùng lý do (đi qua nhiều
     * servlet, có thể rời trang rồi quay lại).
     */
    private static final String SESSION_KEY_QTY_OVERRIDE = "checkoutQtyOverride";

    private CheckoutSelectionUtil() {
    }

    /** Đọc các giá trị cartItemId được tick (nhiều input cùng tên paramName) từ request. */
    public static Set<Integer> parseFromRequest(HttpServletRequest request, String paramName) {
        String[] raw = request.getParameterValues(paramName);
        if (raw == null) {
            return null;
        }
        return Arrays.stream(raw)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .map(CheckoutSelectionUtil::parseIntOrNull)
                .filter(Objects::nonNull)
                .collect(Collectors.toCollection(LinkedHashSet::new));
    }

    private static Integer parseIntOrNull(String value) {
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static void store(HttpServletRequest request, Set<Integer> ids) {
        request.getSession().setAttribute(SESSION_KEY, ids);
    }

    @SuppressWarnings("unchecked")
    public static Set<Integer> load(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(SESSION_KEY);
        return value instanceof Set ? (Set<Integer>) value : null;
    }

    public static void clear(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(SESSION_KEY);
            session.removeAttribute(SESSION_KEY_QTY_OVERRIDE);
        }
    }

    public static void storeQuantityOverride(HttpServletRequest request, Map<Integer, Integer> overrides) {
        request.getSession().setAttribute(SESSION_KEY_QTY_OVERRIDE, overrides);
    }

    @SuppressWarnings("unchecked")
    public static Map<Integer, Integer> loadQuantityOverride(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(SESSION_KEY_QTY_OVERRIDE);
        return value instanceof Map ? (Map<Integer, Integer>) value : null;
    }

    public static void clearQuantityOverride(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute(SESSION_KEY_QTY_OVERRIDE);
        }
    }
}
