package controller.customer.cart;

import model.entity.promtion.Promotion;
import model.entity.cart.CartItem;
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
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ApplyVoucherServlet", urlPatterns = {"/apply-voucher"})
public class ApplyVoucherServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();
    private final CartService cartService = new CartService(); // Dùng service thật của đồng đội

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String voucherCode = req.getParameter("voucherCode");
        
        // 1. Lấy ID khách hàng đang đăng nhập (Giống CheckoutServlet)
        Object customerIdObj = session.getAttribute("customerId");
        if (customerIdObj == null) {
            session.setAttribute("errorMsg", "Vui lòng đăng nhập để áp dụng mã giảm giá.");
            resp.sendRedirect(req.getContextPath() + "/login.html");
            return;
        }
        int customerId = (Integer) customerIdObj;

        try {
            // 2. LẤY GIỎ HÀNG THẬT VÀ TÍNH TỔNG TIỀN
            List<CartItem> items = cartService.getCartItems(customerId);
            if (items.isEmpty()) {
                session.setAttribute("errorMsg", "Giỏ hàng của bạn đang trống.");
                resp.sendRedirect(req.getContextPath() + "/checkout");
                return;
            }

            BigDecimal cartSubtotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Ghi chú: Trong CheckoutService hiện tại đồng đội đang fix phí ship = 0, nên ở đây ta cũng dùng 0
            BigDecimal shippingFee = BigDecimal.ZERO; 

            // 3. XỬ LÝ KIỂM TRA MÃ VÀ TÍNH TIỀN GIẢM THẬT
            Promotion validPromo = promotionService.validateCouponForCheckout(voucherCode, cartSubtotal);
            BigDecimal discountAmount = promotionService.calculateDiscountAmount(validPromo, cartSubtotal, shippingFee, null);
            
            // 4. LƯU VÀO SESSION
            session.setAttribute("appliedPromo", validPromo);
            session.setAttribute("discountAmount", discountAmount);
            session.setAttribute("successMsg", "Áp dụng mã giảm giá thành công!");
            
        } catch (IllegalArgumentException e) {
            // Xóa mã nếu gặp lỗi validate
            session.removeAttribute("appliedPromo");
            session.removeAttribute("discountAmount");
            session.setAttribute("errorMsg", e.getMessage());
        } catch (SQLException e) {
            session.setAttribute("errorMsg", "Lỗi hệ thống khi xử lý mã giảm giá.");
        }

        // Chuyển hướng về lại trang giỏ hàng
        resp.sendRedirect(req.getContextPath() + "/cart");
    }
}