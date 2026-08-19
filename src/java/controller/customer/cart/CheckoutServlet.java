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
import service.user.UserAddressService;
// ---- THÊM MỚI: Import class Promotion ----loc
import model.entity.promtion.Promotion;
import util.CheckoutSelectionUtil;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final CartService cartService = new CartService();
    private final CheckoutService checkoutService = new CheckoutService();
    private final UserAddressService addressService = new UserAddressService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Không cho trình duyệt cache lại trang này (bfcache) - nếu không, bấm
        // Back từ /payment sau khi đã đặt hàng sẽ vẫn thấy giỏ hàng cũ dù server
        // đã xoá các dòng vừa đặt (rule 5 - fix lỗi quay lại vẫn "lưu" giỏ hàng).
        preventCaching(response);

        int customerId = getCustomerId(request);

        List<CartItem> cartItems = cartService.getCartItems(customerId);
        if (cartItems.isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Giỏ hàng đang trống, không thể thanh toán");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        Set<Integer> selectedIds = resolveSelectedIds(request, cartItems);
        if (selectedIds == null) {
            request.getSession().setAttribute("errorMsg", "Vui lòng chọn ít nhất 1 sản phẩm để thanh toán");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        List<CartItem> items = cartService.filterBySelection(cartItems, selectedIds);
        if (items.isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Sản phẩm đã chọn không còn trong giỏ hàng, vui lòng chọn lại");
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
        request.setAttribute("savedAddresses", addressService.getAddressesByUserId(customerId));
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

        // Chỉ thanh toán đúng những dòng khách đã tick chọn ở cart.jsp (rule 4).
        Set<Integer> selectedIds = CheckoutSelectionUtil.load(request);
        form.selectedCartItemIds = selectedIds;

        CheckoutService.CheckoutResult result = checkoutService.checkout(form);

        if (!result.success) {
            // Lỗi validate/nghiệp vụ: forward lại (không redirect) để giữ dữ liệu đã nhập (rule 6),
            // request.getParameter vẫn còn nguyên nên checkout.jsp dùng ${param.xxx} để hiển thị lại.
            List<CartItem> allItems = cartService.getCartItems(customerId);
            List<CartItem> items = cartService.filterBySelection(allItems, selectedIds);
            if (items.isEmpty()) {
                items = allItems;
            }
            if (items.isEmpty()) {
                // Giỏ hàng đã trống hẳn (vd. vừa xoá hết ở tab khác trong lúc đang
                // điền form checkout) - forward lại trang checkout lúc này chỉ tạo
                // ra 1 trang "kẹt", bấm Đặt hàng lần nữa cũng chỉ nhận đúng lỗi này.
                // Đưa thẳng về /cart để khách chọn lại sản phẩm.
                session.setAttribute("errorMsg", result.message);
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
            BigDecimal cartTotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", cartTotal);
            request.setAttribute("errorMsg", result.message);
            request.setAttribute("fieldErrors", result.fieldErrors);
            request.setAttribute("savedAddresses", addressService.getAddressesByUserId(customerId));
            request.getRequestDispatcher("/WEB-INF/views/customer/checkout.jsp").forward(request, response);
            return;
        }
        // ---- THÊM MỚI: Dọn dẹp Session giỏ hàng sau khi đặt hàng thành công ----
        session.removeAttribute("appliedPromo");
        session.removeAttribute("discountAmount");
        CheckoutSelectionUtil.clear(request);

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

    /**
     * Xác định tập cart_item_id sẽ mang sang thanh toán:
     * - Nếu request có "fromCart" (submit từ form tick chọn ở cart.jsp): dùng đúng
     *   các cartItemId được tick, lưu lại vào session, trả null nếu khách không
     *   tick gì (để caller báo lỗi và quay lại giỏ hàng).
     * - Ngược lại (vd. quay lại /checkout từ trang voucher): dùng lại lựa chọn đã
     *   lưu trong session; nếu chưa từng chọn (vào thẳng /checkout) thì mặc định
     *   là toàn bộ giỏ hàng hiện có, để tương thích với các đường dẫn cũ.
     */
    private Set<Integer> resolveSelectedIds(HttpServletRequest request, List<CartItem> cartItems) {
        boolean fromCart = request.getParameter("fromCart") != null;
        if (fromCart) {
            Set<Integer> requestedIds = CheckoutSelectionUtil.parseFromRequest(request, "cartItemId");
            if (requestedIds == null || requestedIds.isEmpty()) {
                return null;
            }
            CheckoutSelectionUtil.store(request, requestedIds);
            return requestedIds;
        }

        Set<Integer> stored = CheckoutSelectionUtil.load(request);
        if (stored != null && !stored.isEmpty()) {
            return stored;
        }

        Set<Integer> allIds = cartItems.stream()
                .map(CartItem::getCartItemId)
                .collect(Collectors.toCollection(LinkedHashSet::new));
        CheckoutSelectionUtil.store(request, allIds);
        return allIds;
    }

    /** Chặn trình duyệt cache lại trang thanh toán (fix bug quay lại vẫn thấy giỏ hàng cũ). */
    private void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}