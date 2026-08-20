package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Arrays;
import java.util.LinkedHashSet;
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
        }
    }
}
