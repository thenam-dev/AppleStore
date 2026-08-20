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
        request.setAttribute("savedAddresses", addressService.getAddressesByUserId(customerId));
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

        BigDecimal totalDiscount = BigDecimal.ZERO;
        if (merchandiseDiscount != null) totalDiscount = totalDiscount.add(merchandiseDiscount);
        if (shippingDiscount != null) totalDiscount = totalDiscount.add(shippingDiscount);
        
        form.appliedPromo = merchandisePromo != null ? merchandisePromo : shippingPromo; 
        form.discountAmount = totalDiscount;

        Set<Integer> selectedIds = CheckoutSelectionUtil.load(request);
        form.selectedCartItemIds = selectedIds;
        
        CheckoutService.CheckoutResult result = checkoutService.checkout(form);

        if (!result.success) {
            List<CartItem> allItems = cartService.getCartItems(customerId);
            List<CartItem> items = cartService.filterBySelection(allItems, selectedIds);
            if (items.isEmpty()) {
                items = allItems;
            }
            if (items.isEmpty()) {
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

        // Dọn dẹp Session giỏ hàng và mã giảm giá sau khi đặt hàng thành công
        session.removeAttribute("merchandisePromo");
        session.removeAttribute("merchandiseDiscount");
        session.removeAttribute("shippingPromo");
        session.removeAttribute("shippingDiscount");
        CheckoutSelectionUtil.clear(request);

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

    private void preventCaching(HttpServletResponse response) {
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
    }
}