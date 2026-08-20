package controller.customer.cart;

import config.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.cart.CartItem;
import model.entity.user.User;
import service.cart.CartService;
import service.cart.CheckoutService;
import model.entity.promtion.Promotion;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final CartService cartService = new CartService();
    private final CheckoutService checkoutService = new CheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = getCustomerId(request);

        List<CartItem> items = cartService.getCartItems(customerId);
        if (items.isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Giỏ hàng đang trống, không thể thanh toán");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal cartTotal = items.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        HttpSession session = request.getSession();
        service.promotion.PromotionService promoService = new service.promotion.PromotionService();
        BigDecimal shippingFee = BigDecimal.ZERO; 

        // 1. Tái kiểm tra Mã Hàng Hóa
        Promotion merchPromo = (Promotion) session.getAttribute("merchandisePromo");
        if (merchPromo != null) {
            try {
                Promotion validMerch = promoService.validateCouponForCheckout(merchPromo.getCode(), cartTotal, items);
                BigDecimal eligibleAmount = promoService.calculateEligibleAmount(items, validMerch);
                BigDecimal discountAmount = promoService.calculateDiscountAmount(validMerch, cartTotal, shippingFee, eligibleAmount);
                session.setAttribute("merchandisePromo", validMerch);
                session.setAttribute("merchandiseDiscount", discountAmount);
            } catch (Exception e) {
                session.removeAttribute("merchandisePromo");
                session.removeAttribute("merchandiseDiscount");
                request.setAttribute("errorMsg", "Mã giảm giá đã tự động gỡ bỏ: " + e.getMessage());
            }
        }

        // 2. Tái kiểm tra Mã Freeship
        Promotion shipPromo = (Promotion) session.getAttribute("shippingPromo");
        if (shipPromo != null) {
            try {
                Promotion validShip = promoService.validateCouponForCheckout(shipPromo.getCode(), cartTotal, items);
                BigDecimal eligibleAmount = promoService.calculateEligibleAmount(items, validShip);
                BigDecimal discountAmount = promoService.calculateDiscountAmount(validShip, cartTotal, shippingFee, eligibleAmount);
                session.setAttribute("shippingPromo", validShip);
                session.setAttribute("shippingDiscount", discountAmount);
            } catch (Exception e) {
                session.removeAttribute("shippingPromo");
                session.removeAttribute("shippingDiscount");
                request.setAttribute("errorMsg", "Mã vận chuyển đã tự động gỡ bỏ: " + e.getMessage());
            }
        }

        request.setAttribute("cartItems", items);
        request.setAttribute("cartTotal", cartTotal);
        request.getRequestDispatcher("/WEB-INF/views/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        Promotion merchandisePromo = (Promotion) session.getAttribute("merchandisePromo");
        BigDecimal merchandiseDiscount = (BigDecimal) session.getAttribute("merchandiseDiscount");
        
        Promotion shippingPromo = (Promotion) session.getAttribute("shippingPromo");
        BigDecimal shippingDiscount = (BigDecimal) session.getAttribute("shippingDiscount");
        
        int customerId = getCustomerId(request);

        CheckoutService.CheckoutForm form = new CheckoutService.CheckoutForm();
        form.customerId = customerId;
        form.deliveryAddress = request.getParameter("deliveryAddress");
        form.recipientName = request.getParameter("recipientName");
        form.recipientPhone = request.getParameter("recipientPhone");
        form.deliveryTimeSlot = request.getParameter("deliveryTimeSlot");
        form.notes = request.getParameter("notes");
        form.paymentMethod = request.getParameter("paymentMethod");

        // GOM TỔNG: Nếu CheckoutForm của bạn chưa hỗ trợ 2 mã, tạm thời gom tổng tiền giảm lại!
        // Lưu ý quan trọng: Nếu bạn muốn lưu cả 2 mã xuống DB (bảng order_promotions), 
        // bạn sẽ phải mở class CheckoutService.CheckoutForm ra để thêm biến chứa mã 2 vào đó nhé.
        BigDecimal totalDiscount = BigDecimal.ZERO;
        if (merchandiseDiscount != null) totalDiscount = totalDiscount.add(merchandiseDiscount);
        if (shippingDiscount != null) totalDiscount = totalDiscount.add(shippingDiscount);
        
        // Tạm gán 1 mã ưu tiên (hoặc mã hàng hóa trước) để form không bị lỗi (Tùy thuộc code CheckoutService của bạn)
        form.appliedPromo = merchandisePromo != null ? merchandisePromo : shippingPromo; 
        form.discountAmount = totalDiscount;
        
        CheckoutService.CheckoutResult result = checkoutService.checkout(form);

        if (!result.success) {
            List<CartItem> items = cartService.getCartItems(customerId);
            BigDecimal cartTotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", cartTotal);
            request.setAttribute("errorMsg", result.message);
            request.setAttribute("fieldErrors", result.fieldErrors);
            request.getRequestDispatcher("/WEB-INF/views/customer/checkout.jsp").forward(request, response);
            return;
        }

        // Dọn dẹp Session giỏ hàng sau khi đặt hàng thành công
        session.removeAttribute("merchandisePromo");
        session.removeAttribute("merchandiseDiscount");
        session.removeAttribute("shippingPromo");
        session.removeAttribute("shippingDiscount");

        if (result.qrCodeUrl != null) {
            session.setAttribute("successMsg", "Đặt hàng thành công, vui lòng quét mã để thanh toán");
            response.sendRedirect(request.getContextPath() + "/payment?orderId=" + result.orderId);
        } else {
            session.setAttribute("successMsg", "Đặt hàng thành công, đơn hàng #" + result.orderId + " đã được xác nhận");
            response.sendRedirect(request.getContextPath() + "/order-success?orderId=" + result.orderId);
        }
    }

    private int getCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);
        if (!(sessionUser instanceof User)) {
            throw new IllegalStateException("Khách chưa đăng nhập - AuthFilter phải chặn trước khi tới servlet này");
        }
        return ((User) sessionUser).getUserId();
    }
}