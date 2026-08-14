package controller.customer.cart;

import config.AppConfig;
import model.entity.promtion.Promotion;
import model.entity.cart.CartItem;
import model.entity.user.User;
import service.promotion.PromotionService;
import service.cart.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;

/**
 * Xử lý áp mã khuyến mãi. Luôn PRG: xử lý xong (thành công hay lỗi) đều
 * redirect về /checkout để khách thấy ngay giá đã cập nhật trên chính
 * màn thanh toán, thay vì quay lại /cart (đúng luồng: chọn mã ở
 * /vouchers -> áp dụng -> quay lại /checkout để xem lại tổng tiền).
 */
@WebServlet(name = "ApplyVoucherServlet", urlPatterns = {"/apply-voucher"})
public class ApplyVoucherServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();
    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        String voucherCode = req.getParameter("voucherCode");

        // SỬA: lấy customerId đúng theo pattern CartServlet/CheckoutServlet đang dùng
        // trong toàn dự án - session lưu object User dưới key AppConfig.SESSION_USER,
        // không phải Integer thô dưới key "user". Ép kiểu (Integer) trên object User
        // sẽ ném ClassCastException, không được các catch bên dưới bắt.
        Integer customerId = getCustomerId(req);
        if (customerId == null) {
            redirectToLogin(req, resp);
            return;
        }

        try {
            // Lấy giỏ hàng thật và tính tổng tiền
            List<CartItem> items = cartService.getCartItems(customerId);
            if (items.isEmpty()) {
                session.setAttribute("errorMsg", "Giỏ hàng của bạn đang trống.");
                resp.sendRedirect(req.getContextPath() + "/checkout");
                return;
            }

            BigDecimal cartSubtotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Ghi chú: CheckoutService hiện đang fix phí ship = 0, dùng chung giá trị này.
            BigDecimal shippingFee = BigDecimal.ZERO;

            // Kiểm tra mã và tính tiền giảm thật
            Promotion validPromo = promotionService.validateCouponForCheckout(voucherCode, cartSubtotal);
            BigDecimal discountAmount = promotionService.calculateDiscountAmount(validPromo, cartSubtotal, shippingFee, null);

            session.setAttribute("appliedPromo", validPromo);
            session.setAttribute("discountAmount", discountAmount);
            session.setAttribute("successMsg", "Áp dụng mã giảm giá thành công!");

        } catch (IllegalArgumentException e) {
            session.removeAttribute("appliedPromo");
            session.removeAttribute("discountAmount");
            session.setAttribute("errorMsg", e.getMessage());
        } catch (SQLException e) {
            session.setAttribute("errorMsg", "Lỗi hệ thống khi xử lý mã giảm giá.");
        }

        // PRG: luôn quay về /checkout để thấy tổng tiền vừa cập nhật
        resp.sendRedirect(req.getContextPath() + "/checkout");
    }

    /** Giống hệt cách CartServlet lấy customerId - dùng chung 1 chuẩn cho toàn hệ thống. */
    private Integer getCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);
        if (!(sessionUser instanceof User)) {
            return null;
        }
        return ((User) sessionUser).getUserId();
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String redirectTarget = request.getRequestURI().substring(request.getContextPath().length());
        String queryString = request.getQueryString();
        if (queryString != null && !queryString.isBlank()) {
            redirectTarget += "?" + queryString;
        }
        response.sendRedirect(request.getContextPath()
                + "/login?redirectTo="
                + URLEncoder.encode(redirectTarget, StandardCharsets.UTF_8));
    }
}