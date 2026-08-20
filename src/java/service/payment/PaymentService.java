package service.payment;

import dao.order.OrderDAO;
import dao.payment.PaymentDAO;
import model.entity.order.Order;
import service.order.OrderExpiryService;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.Set;

/**
 * Business rule cho trang thanh toán chuyển khoản (rule 2: Service điều phối
 * DAO, Controller chỉ xử lý request/response). Gom lại đúng những gì trước
 * đây PaymentServlet đang tự làm thẳng với DAO.
 */
public class PaymentService {

    private final OrderDAO orderDAO;
    private final PaymentDAO paymentDAO;
    private final OrderExpiryService orderExpiryService;

    public PaymentService() {
        this(new OrderDAO(), new PaymentDAO());
    }

    public PaymentService(OrderDAO orderDAO, PaymentDAO paymentDAO) {
        this.orderDAO = orderDAO;
        this.paymentDAO = paymentDAO;
        this.orderExpiryService = new OrderExpiryService();
    }

    /** Các trạng thái coi như "đơn đã bị huỷ vì không thanh toán kịp" (xem OrderExpiryService). */
    private static final Set<String> CANCELLED_STATUSES = Set.of("EXPIRED", "CANCELLED");

    public static class PaymentPageResult {
        public boolean orderFound;
        public boolean alreadyConfirmed;
        public boolean expired;
        public Order order;
        public String qrCodeUrl;
        public LocalDateTime expiresAt;
    }

    /**
     * Lấy dữ liệu để render trang /payment.
     * - orderFound = false: không có đơn, hoặc đơn không thuộc về khách này (chặn IDOR).
     * - alreadyConfirmed = true: đơn đã xác nhận rồi (COD hoặc CK đã thanh toán) ->
     *   Controller nên điều hướng sang /order-success thay vì render trang QR.
     * - expired = true: đơn đã tự huỷ vì hết hạn giữ chỗ (OrderExpiryService) hoặc
     *   khách tự huỷ - render NGAY trên /payment (không redirect sang order-success,
     *   vì trang đó chỉ dành cho đơn thành công, hiện thông báo huỷ ở đó là sai).
     */
    public PaymentPageResult getPaymentPageData(int orderId, int customerId) throws SQLException {
        PaymentPageResult result = new PaymentPageResult();

        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
            result.orderFound = false;
            return result;
        }

        result.orderFound = true;
        result.order = orderOpt.get();
        String status = result.order.getStatus();

        // Tự huỷ ngay tại đây nếu đã quá giờ nhưng job quét định kỳ (5 phút/lần)
        // chưa kịp xử lý - để mỗi lần tải/tải lại trang /payment đều phản ánh đúng
        // trạng thái ngay lập tức, tránh vòng lặp "đếm ngược hết giờ -> tải lại ->
        // vẫn thấy PENDING_PAYMENT -> đếm ngược lại từ số âm" lặp tới khi job chạy.
        if ("PENDING_PAYMENT".equals(status) && orderExpiryService.expireIfExpiredNow(orderId)) {
            status = "EXPIRED";
            result.order.setStatus(status);
        }

        if ("PENDING_PAYMENT".equals(status)) {
            result.qrCodeUrl = paymentDAO.findLatestQrCode(orderId).orElse(null);
            result.expiresAt = paymentDAO.findLatestExpiresAt(orderId).orElse(null);
        } else if (CANCELLED_STATUSES.contains(status)) {
            result.expired = true;
        } else {
            result.alreadyConfirmed = true;
        }
        return result;
    }

    public static class ConfirmResult {
        public boolean success;
        public String message;
    }

    /**
     * DEMO-ONLY: khách tự xác nhận đã chuyển khoản, vì đồ án dùng QR tĩnh,
     * không có webhook SePay thật xác thực giao dịch. Gom 3 bước DAO
     * (đánh dấu giao dịch COMPLETED, chuyển trạng thái đơn, ghi lịch sử)
     * thành 1 business operation duy nhất thay vì rải trong Controller.
     * Hệ thống thật KHÔNG được xác nhận thanh toán theo cách này.
     */
    public ConfirmResult confirmManualPayment(int orderId, int customerId) throws SQLException {
        ConfirmResult result = new ConfirmResult();

        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
            result.success = false;
            result.message = "Không tìm thấy đơn hàng.";
            return result;
        }

        Order order = orderOpt.get();
        String status = order.getStatus();

        if (CANCELLED_STATUSES.contains(status)) {
            // Đơn đã tự huỷ vì hết hạn giữ chỗ (hoặc khách tự huỷ) đúng lúc khách
            // bấm xác nhận - KHÔNG được coi là thành công, vì kho đã được hoàn lại rồi.
            result.success = false;
            result.message = "Đơn hàng đã hết hạn thanh toán và được huỷ tự động. Vui lòng đặt lại đơn khác.";
            return result;
        }

        if (!"PENDING_PAYMENT".equals(status)) {
            // Khách bấm 2 lần / F5 lại trang -> coi như thành công, không báo lỗi
            result.success = true;
            result.message = "Đơn hàng đã được xác nhận trước đó.";
            return result;
        }

        // Đơn vẫn còn PENDING_PAYMENT trong DB nhưng có thể đã QUÁ giờ hết hạn mà
        // job quét định kỳ (5 phút/lần) chưa kịp xử lý - huỷ ngay tại đây thay vì
        // để khách "xác nhận" được 1 đơn lẽ ra đã hết hạn.
        if (orderExpiryService.expireIfExpiredNow(orderId)) {
            result.success = false;
            result.message = "Đơn hàng đã hết hạn thanh toán và được huỷ tự động. Vui lòng đặt lại đơn khác.";
            return result;
        }

        paymentDAO.markLatestCompleted(orderId);
        orderDAO.updateStatus(orderId, "CONFIRMED");
        orderDAO.insertStatusHistory(orderId, "CONFIRMED", customerId,
                "Khách tự xác nhận đã chuyển khoản (demo, chưa có webhook SePay thật)");

        result.success = true;
        result.message = "Xác nhận thanh toán thành công!";
        return result;
    }
}