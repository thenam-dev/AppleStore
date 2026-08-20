package service.order;

import dao.catalog.ProductVariantDAO;
import dao.order.OrderDAO;
import dao.payment.PaymentDAO;
import model.entity.order.Order;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Tự động huỷ các đơn CK (chuyển khoản QR) chưa thanh toán khi hết hạn giữ
 * chỗ (payment_transactions.expires_at, mặc định 15 phút - xem
 * PaymentDAO.insertPending) và hoàn lại tồn kho đã trừ lúc tạo đơn.
 *
 * Không xử lý đơn COD vì COD được auto-CONFIRMED ngay lúc tạo (xem
 * CheckoutService.checkout), không có khái niệm "chờ thanh toán hết hạn".
 *
 * Được gọi định kỳ bởi OrderExpirySchedulerListener (ScheduledExecutorService),
 * KHÔNG phải job DB/cron ngoài, nên chỉ chạy khi ứng dụng đang sống.
 */
public class OrderExpiryService {

    private final PaymentDAO paymentDAO;
    private final OrderDAO orderDAO;
    private final StockRestoreHelper stockRestoreHelper;

    public OrderExpiryService() {
        this(new PaymentDAO(), new OrderDAO(), new ProductVariantDAO());
    }

    public OrderExpiryService(PaymentDAO paymentDAO, OrderDAO orderDAO, ProductVariantDAO productVariantDAO) {
        this.paymentDAO = paymentDAO;
        this.orderDAO = orderDAO;
        this.stockRestoreHelper = new StockRestoreHelper(orderDAO, productVariantDAO);
    }

    /**
     * Kiểm tra và huỷ NGAY 1 đơn cụ thể nếu đã hết hạn giữ chỗ, dùng khi khách
     * bấm "Tôi đã chuyển khoản" đúng lúc job quét định kỳ (5 phút/lần, xem
     * OrderExpirySchedulerListener) chưa kịp xử lý - tránh khách vẫn xác nhận
     * được 1 đơn lẽ ra phải bị huỷ chỉ vì job chưa chạy tới.
     * @return true nếu đơn VỪA bị huỷ ở lần gọi này.
     */
    public boolean expireIfExpiredNow(int orderId) {
        Optional<LocalDateTime> expiresAt;
        try {
            expiresAt = paymentDAO.findLatestExpiresAt(orderId);
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
        if (expiresAt.isEmpty() || expiresAt.get().isAfter(LocalDateTime.now())) {
            return false;
        }
        return expireOne(orderId);
    }

    /** @return số đơn đã huỷ + hoàn kho trong lượt quét này. */
    public int expireStalePendingOrders() {
        List<Integer> orderIds;
        try {
            orderIds = paymentDAO.findExpiredPendingOrderIds();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }

        int count = 0;
        for (int orderId : orderIds) {
            if (expireOne(orderId)) {
                count++;
            }
        }
        return count;
    }

    /**
     * Xử lý 1 đơn: khoá trạng thái trước (atomic, chỉ thành công nếu đơn còn
     * PENDING_PAYMENT) để 2 lượt quét chồng nhau hoặc khách vừa thanh toán
     * xong đúng lúc job chạy không bị xử lý trùng, rồi mới hoàn kho.
     */
    private boolean expireOne(int orderId) {
        try {
            if (!orderDAO.expireIfStillPending(orderId)) {
                return false; // đã được xử lý bởi lượt quét khác hoặc khách vừa thanh toán xong
            }

            paymentDAO.expireLatestPending(orderId);

            Optional<Order> order = orderDAO.findById(orderId);
            int actorId = order.map(Order::getCustomerId).orElse(0);
            if (actorId > 0) {
                stockRestoreHelper.restore(orderId, actorId);
            } else {
                // Không nên xảy ra (order vừa update status ở trên chắc chắn tồn tại),
                // nhưng phòng hờ để không insert inventory_logs với changed_by không hợp lệ.
                System.err.println("OrderExpiryService: không tìm thấy customerId cho order_id=" + orderId
                        + ", bỏ qua bước hoàn kho - cần đối soát tay.");
            }

            orderDAO.insertStatusHistory(orderId, "EXPIRED", null, "Hết hạn thanh toán, tự động huỷ và hoàn kho");
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
