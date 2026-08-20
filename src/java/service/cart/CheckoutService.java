/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service.cart;

import dao.cart.CartDAO;
import dao.catalog.ProductVariantDAO;
import dao.order.OrderDAO;
import dao.payment.PaymentDAO;

import model.entity.promtion.Promotion;
import service.promotion.PromotionService;
import util.DBConnection;
import java.sql.Connection;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import model.entity.cart.CartItem;
import model.entity.order.Order;

/**
 * Business rule cho luồng đặt hàng. Service chỉ gọi DAO tuần tự, KHÔNG còn
 * mở/quản lý Connection hay transaction (mỗi hàm DAO tự commit riêng theo
 * form CategoryDAO).
 *
 * Vì mất tính atomic xuyên suốt, checkout() tự làm "rollback nghiệp vụ"
 * bằng cách gọi các hàm bù trừ (increaseStock, deleteOrderItem,
 * deleteOrder...) khi một bước ở giữa thất bại, thay vì trông chờ
 * conn.rollback(). Đây là đánh đổi đã được team chốt để đồng nhất pattern
 * DAO toàn hệ thống; vẫn còn rủi ro race condition ở mức thấp giữa các
 * request chạy song song vì không có SELECT ... FOR UPDATE giữ khoá xuyên
 * suốt nhiều câu lệnh.
 * 
 * @author namnthe180997
 */
public class CheckoutService {

    private static final String SEPAY_ACCOUNT_NUMBER = "9999928012004"; // TODO: đọc từ config chung thay vì hard-code
    private static final String SEPAY_BANK_CODE = "MBBank";
    private static final String ORDER_PREFIX = "DH";

    private final CartDAO cartDAO;
    private final OrderDAO orderDAO;
    private final PaymentDAO paymentDAO;
    private final ProductVariantDAO productVariantDAO;

    public CheckoutService() {
        this(new CartDAO(), new OrderDAO(), new PaymentDAO(), new ProductVariantDAO());
    }

    public CheckoutService(CartDAO cartDAO, OrderDAO orderDAO, PaymentDAO paymentDAO, ProductVariantDAO productVariantDAO) {
        this.cartDAO = cartDAO;
        this.orderDAO = orderDAO;
        this.paymentDAO = paymentDAO;
        this.productVariantDAO = productVariantDAO;
    }

    public static class CheckoutForm {
        public int customerId;

        public String deliveryAddress;
        public String recipientName;
        public String recipientPhone;
        public String deliveryTimeSlot;
        public String notes;
        public String paymentMethod; // "CK" hoặc "COD"

        // Voucher đã áp dụng ở giỏ hàng (nếu có), truyền từ CheckoutServlet.
        public Promotion appliedPromo;
        public BigDecimal discountAmount;

        // Tập cart_item_id khách đã tick chọn ở cart.jsp để thanh toán - null/rỗng
        // nghĩa là thanh toán toàn bộ giỏ hàng (tương thích ngược).
        public Set<Integer> selectedCartItemIds;
    }

    public static class CheckoutResult {
        public boolean success;
        public String message;
        public Map<String, String> fieldErrors = new HashMap<>();
        public Integer orderId;
        public String qrCodeUrl;
    }

    /** Validate tối thiểu theo rule 6: required, length, format. */
    public Map<String, String> validate(CheckoutForm form) {
        Map<String, String> errors = new HashMap<>();

        if (isBlank(form.recipientName)) {
            errors.put("recipientName", "Vui lòng nhập tên người nhận");
        } else if (form.recipientName.trim().length() > 100) {
            errors.put("recipientName", "Tên người nhận tối đa 100 ký tự");
        }

        if (isBlank(form.recipientPhone)) {
            errors.put("recipientPhone", "Vui lòng nhập số điện thoại");
        } else if (!form.recipientPhone.trim().matches("^0\\d{9}$")) {
            errors.put("recipientPhone", "Số điện thoại không đúng định dạng (10 số, bắt đầu bằng 0)");
        }

        // SỬA: bản trước bị thiếu nhánh else-if kiểm tra độ dài, và message
        // "Địa chỉ tối đa 500 ký tự" bị gán nhầm cho trường hợp rỗng.
        if (isBlank(form.deliveryAddress)) {
            errors.put("deliveryAddress", "Vui lòng nhập địa chỉ giao hàng");
        } else if (form.deliveryAddress.trim().length() > 500) {
            errors.put("deliveryAddress", "Địa chỉ tối đa 500 ký tự");
        }

        // SỬA: bản trước dòng này chạy VÔ ĐIỀU KIỆN (không nằm trong if nào),
        // nên luôn báo lỗi "Vui lòng chọn phương thức" dù đã chọn CK/COD hợp lệ.
        // Đây chính là nguyên nhân toàn bộ luồng checkout bị chặn.
        if (isBlank(form.paymentMethod) || !(form.paymentMethod.equals("CK") || form.paymentMethod.equals("COD"))) {
            errors.put("paymentMethod", "Vui lòng chọn phương thức thanh toán");
        }

        return errors;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Tạo đơn hàng từ giỏ hàng hiện tại của khách. Các bước gọi DAO tuần tự:
     * kiểm tra tồn kho -> insert orders -> insert order_items + trừ kho (atomic
     * từng dòng nhờ decreaseStockIfAvailable) -> ghi log -> tạo payment (nếu CK)
     * -> xoá giỏ hàng. Nếu 1 bước ở giữa thất bại, gọi các hàm bù trừ để hoàn
     * lại các bước đã làm trước đó thay vì transaction rollback.
     */
    public CheckoutResult checkout(CheckoutForm form) {
        CheckoutResult result = new CheckoutResult();
        result.fieldErrors = validate(form);
        if (!result.fieldErrors.isEmpty()) {
            result.success = false;
            result.message = "Vui lòng kiểm tra lại thông tin";
            return result;
        }

        try {
            List<CartItem> allItems = cartDAO.findByCustomerId(form.customerId);
            List<CartItem> items = (form.selectedCartItemIds == null || form.selectedCartItemIds.isEmpty())
                    ? allItems
                    : allItems.stream()
                            .filter(cartItem -> form.selectedCartItemIds.contains(cartItem.getCartItemId()))
                            .collect(Collectors.toList());
            if (items.isEmpty()) {
                result.success = false;
                result.message = "Giỏ hàng đang trống";
                return result;
            }

            // Kiểm tra sơ bộ tồn kho trước (best-effort, không khoá được xuyên suốt
            // nhiều câu lệnh vì không còn transaction) để trả lỗi sớm cho khách.
            BigDecimal totalAmount = BigDecimal.ZERO;
            for (CartItem cartItem : items) {
                var stock = productVariantDAO.findStockQuantity(cartItem.getVariantId());
                if (stock.isEmpty()) {
                    result.success = false;
                    result.message = "Sản phẩm \"" + cartItem.getProductName() + "\" không còn kinh doanh";
                    return result;
                }
                if (stock.get() < cartItem.getQuantity()) {
                    result.success = false;
                    result.message = "Sản phẩm \"" + cartItem.getProductName() + "\" chỉ còn " + stock.get() + " trong kho";
                    return result;
                }
                totalAmount = totalAmount.add(cartItem.getLineTotal());
            }

            BigDecimal deliveryFee = BigDecimal.ZERO;
            BigDecimal discountAmount = (form.discountAmount != null) ? form.discountAmount : BigDecimal.ZERO;
            BigDecimal finalAmount = totalAmount.add(deliveryFee).subtract(discountAmount);

            Order order = new Order();
            order.setCustomerId(form.customerId);
            order.setDeliveryAddress(form.deliveryAddress.trim());
            order.setRecipientName(form.recipientName.trim());
            order.setRecipientPhone(form.recipientPhone.trim());
            order.setDeliveryTimeSlot(form.deliveryTimeSlot);
            order.setNotes(form.notes);
            order.setStatus("PENDING_PAYMENT");
            order.setTotalAmount(totalAmount);
            order.setDeliveryFee(deliveryFee);
            order.setDiscountAmount(discountAmount);
            order.setFinalAmount(finalAmount);
            order.setPaymentMethod(form.paymentMethod);
            
            try {
                int bestSaleId = orderDAO.findBestAvailableSaleStaffId();
                if (bestSaleId > 0) {
                    order.setAssignedSaleStaffId(bestSaleId);
                }
            } catch (SQLException ignored) {
                // Best-effort: Nếu lỗi tìm kiếm, để trống cho Admin phân công sau
            }
            
            int orderId = orderDAO.insert(order);

            // Theo dõi các dòng đã trừ kho thành công để hoàn lại (compensate) nếu 1 dòng sau bị lỗi
            List<int[]> decreasedStock = new ArrayList<>(); // {variantId, quantity}

            for (CartItem cartItem : items) {
                boolean decreased = productVariantDAO.decreaseStockIfAvailable(cartItem.getVariantId(), cartItem.getQuantity());
                if (!decreased) {
                    // Hết hàng đúng lúc đang checkout (race condition) -> hoàn lại toàn bộ các bước đã làm
                    compensate(orderId, decreasedStock);
                    result.success = false;
                    result.message = "Sản phẩm \"" + cartItem.getProductName() + "\" vừa hết hàng, vui lòng thử lại";
                    return result;
                }
                decreasedStock.add(new int[]{cartItem.getVariantId(), cartItem.getQuantity()});

                int orderItemId = orderDAO.insertOrderItem(orderId, cartItem);
                int stockAfter = productVariantDAO.findStockQuantity(cartItem.getVariantId()).orElse(0);
                orderDAO.insertInventoryLog(cartItem.getVariantId(), form.customerId, orderId, orderItemId,
                        "ORDER_RESERVE", -cartItem.getQuantity(), stockAfter);
            }

            // Ghi nhận việc dùng voucher (order_promotions + tăng used_count). Tự mở
            // Connection riêng vì kiến trúc hiện tại không dùng Global Transaction.
            // Ghi nhận việc dùng voucher (order_promotions + tăng used_count). Tự mở
            // Connection riêng vì kiến trúc hiện tại không dùng Global Transaction.
            if (form.appliedPromo != null && form.discountAmount != null) {
                PromotionService promotionService = new PromotionService();
                try (Connection conn = DBConnection.getConnection()) {
                    // Bắt kết quả trả về từ hàm recordPromotionUsage
                    boolean isPromoApplied = promotionService.recordPromotionUsage(conn, orderId, form.customerId, form.appliedPromo, form.discountAmount);
                    
                    // Nếu false tức là DB từ chối tăng used_count vì đã chạm ngưỡng max_uses
                    if (!isPromoApplied) {
                        // Rollback nghiệp vụ: Hoàn lại tồn kho đã trừ và xóa đơn hàng
                        compensate(orderId, decreasedStock);
                        result.success = false;
                        result.message = "Rất tiếc, mã khuyến mãi '" + form.appliedPromo.getCode() + "' vừa hết lượt sử dụng trong lúc bạn đang thanh toán. Vui lòng bỏ mã hoặc chọn mã khác.";
                        return result;
                    }
                } catch (SQLException e) {
                    // Best-effort lưu voucher, nếu lỗi SQL thông thường thì log lại
                    e.printStackTrace();
                }
            }

            orderDAO.insertStatusHistory(orderId, "PENDING_PAYMENT", form.customerId, "Khách tạo đơn hàng");

            String qrUrl = null;
            if ("CK".equals(form.paymentMethod)) {
                String content = ORDER_PREFIX + orderId;
                qrUrl = buildQrUrl(finalAmount, content);
                paymentDAO.insertPending(orderId, finalAmount, qrUrl);
            } else {
                orderDAO.updateStatus(orderId, "CONFIRMED");
                orderDAO.insertStatusHistory(orderId, "CONFIRMED", null, "Đơn COD tự động xác nhận");
            }

            // Chỉ xoá đúng những dòng đã đặt (khách có thể chỉ tick chọn 1 phần giỏ
            // hàng) - KHÔNG xoá cả giỏ như trước, để các dòng chưa chọn vẫn còn lại.
            int cartId = items.get(0).getCartId();
            for (CartItem cartItem : items) {
                cartDAO.deleteCartItem(cartItem.getCartItemId(), cartId);
            }

            result.success = true;
            result.message = "Đặt hàng thành công";
            result.orderId = orderId;
            result.qrCodeUrl = qrUrl;
            return result;
        } catch (SQLException e) {
            result.success = false;
            result.message = "Lỗi hệ thống khi tạo đơn: " + e.getMessage();
            return result;
        }
    }

    /** Hoàn lại tồn kho đã trừ và xoá đơn hàng vừa tạo khi 1 bước giữa chừng thất bại. */
    private void compensate(int orderId, List<int[]> decreasedStock) {
        for (int[] entry : decreasedStock) {
            try {
                productVariantDAO.increaseStock(entry[0], entry[1]);
            } catch (SQLException ignored) {
                // Best-effort: log lại để admin đối soát tay nếu hoàn kho thất bại
            }
        }
        try {
            orderDAO.deleteOrder(orderId);
        } catch (SQLException ignored) {
            // Best-effort tương tự - đơn sẽ còn ở trạng thái PENDING_PAYMENT không có order_items,
            // cần job dọn dẹp định kỳ xử lý các đơn "mồ côi" này nếu deleteOrder cũng lỗi.
        }
    }

    /** Sinh URL ảnh QR VietQR động của SePay. */
    private String buildQrUrl(BigDecimal amount, String content) {
        String encodedContent = URLEncoder.encode(content, StandardCharsets.UTF_8);
        return String.format("https://qr.sepay.vn/img?acc=%s&bank=%s&amount=%s&des=%s",
                SEPAY_ACCOUNT_NUMBER, SEPAY_BANK_CODE,
                amount.setScale(0, java.math.RoundingMode.HALF_UP).toPlainString(), encodedContent);
    }
}