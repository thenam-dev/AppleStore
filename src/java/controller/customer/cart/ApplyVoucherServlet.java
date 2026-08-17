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

@WebServlet(name = "ApplyVoucherServlet", urlPatterns = {"/apply-voucher"})
public class ApplyVoucherServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();
    private final CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        String voucherCode = req.getParameter("voucherCode");

        Integer customerId = getCustomerId(req);
        if (customerId == null) {
            redirectToLogin(req, resp);
            return;
        }

        try {
            List<CartItem> items = cartService.getCartItems(customerId);
            if (items.isEmpty()) {
                session.setAttribute("errorMsg", "Giỏ hàng của bạn đang trống.");
                resp.sendRedirect(req.getContextPath() + "/checkout");
                return;
            }

            BigDecimal cartSubtotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal shippingFee = BigDecimal.ZERO;

            // ---- CẬP NHẬT: Truyền thêm List<CartItem> để bóc tách và validate chính xác ----
            Promotion validPromo = promotionService.validateCouponForCheckout(voucherCode, cartSubtotal, items);
            
            // Tính tiền giảm dựa trên diện tích sản phẩm hợp lệ (eligibleAmount)
            BigDecimal eligibleAmount = promotionService.calculateEligibleAmount(items, validPromo);
            BigDecimal discountAmount = promotionService.calculateDiscountAmount(validPromo, cartSubtotal, shippingFee, eligibleAmount);

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

        resp.sendRedirect(req.getContextPath() + "/checkout");
    }

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