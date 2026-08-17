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
// ---- THÊM MỚI: Import class Promotion ----loc
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

        // =====================================================================
        // CHỐT CHẶN 2: TÁI KIỂM TRA MÃ KHI LOAD LẠI TRANG CHECKOUT
        // =====================================================================
        HttpSession session = request.getSession();
        Promotion appliedPromo = (Promotion) session.getAttribute("appliedPromo");
        if (appliedPromo != null) {
            try {
                service.promotion.PromotionService promoService = new service.promotion.PromotionService();
                // Validate lại với giỏ hàng mới nhất
                Promotion validPromo = promoService.validateCouponForCheckout(appliedPromo.getCode(), cartTotal, items);
                BigDecimal eligibleAmount = promoService.calculateEligibleAmount(items, validPromo);
                BigDecimal discountAmount = promoService.calculateDiscountAmount(validPromo, cartTotal, BigDecimal.ZERO, eligibleAmount);
                
                session.setAttribute("appliedPromo", validPromo);
                session.setAttribute("discountAmount", discountAmount);
            } catch (Exception e) {
                // Nếu giỏ hàng thay đổi khiến mã không còn hợp lệ -> Tự động thu hồi
                session.removeAttribute("appliedPromo");
                session.removeAttribute("discountAmount");
                request.setAttribute("errorMsg", "Mã giảm giá đã tự động gỡ bỏ: " + e.getMessage());
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

        // ---- THÊM MỚI: Khởi tạo session ở ngay đầu hàm để lấy Voucher ----
        // LƯU Ý XÓA: Tôi đã xóa dòng "HttpSession session = request.getSession();" ở phía dưới 
        HttpSession session = request.getSession();
        Promotion appliedPromo = (Promotion) session.getAttribute("appliedPromo");
        BigDecimal discountAmount = (BigDecimal) session.getAttribute("discountAmount");
        
        int customerId = getCustomerId(request);

        CheckoutService.CheckoutForm form = new CheckoutService.CheckoutForm();
        form.customerId = customerId;
        form.deliveryAddress = request.getParameter("deliveryAddress");
        form.recipientName = request.getParameter("recipientName");
        form.recipientPhone = request.getParameter("recipientPhone");
        form.deliveryTimeSlot = request.getParameter("deliveryTimeSlot");
        form.notes = request.getParameter("notes");
        form.paymentMethod = request.getParameter("paymentMethod");

        // ---- THÊM MỚI: Nhét mã giảm giá vào form để truyền cho Service ----
        form.appliedPromo = appliedPromo;
        form.discountAmount = discountAmount;
        
        CheckoutService.CheckoutResult result = checkoutService.checkout(form);

        if (!result.success) {
            // Lỗi validate/nghiệp vụ: forward lại (không redirect) để giữ dữ liệu đã nhập (rule 6),
            // request.getParameter vẫn còn nguyên nên checkout.jsp dùng ${param.xxx} để hiển thị lại.
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
        // ---- THÊM MỚI: Dọn dẹp Session giỏ hàng sau khi đặt hàng thành công ----
        session.removeAttribute("appliedPromo");
        session.removeAttribute("discountAmount");

        // Thành công: PRG - redirect sang trang thanh toán QR (CK) hoặc trang xác nhận đơn (COD)
        //HttpSession session = request.getSession();
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

