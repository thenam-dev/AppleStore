package service.payment;

import dao.order.OrderDAO;
import dao.payment.PaymentDAO;
import model.entity.order.Order;

import java.sql.SQLException;
import java.util.Optional;

/**
 * Business rule cho trang thanh toán chuyển khoản (rule 2: Service điều phối
 * DAO, Controller chỉ xử lý request/response). Gom lại đúng những gì trước
 * đây PaymentServlet đang tự làm thẳng với DAO.
 */
public class PaymentService {

    private final OrderDAO orderDAO;
    private final PaymentDAO paymentDAO;

    public PaymentService() {
        this(new OrderDAO(), new PaymentDAO());
    }

    public PaymentService(OrderDAO orderDAO, PaymentDAO paymentDAO) {
        this.orderDAO = orderDAO;
        this.paymentDAO = paymentDAO;
    }

    public static class PaymentPageResult {
        public boolean orderFound;
        public boolean alreadyConfirmed;
        public Order order;
        public String qrCodeUrl;
    }

    /**
     * Lấy dữ liệu để render trang /payment.
     * - orderFound = false: không có đơn, hoặc đơn không thuộc về khách này (chặn IDOR).
     * - alreadyConfirmed = true: đơn đã xác nhận rồi (COD hoặc CK đã thanh toán) ->
     *   Controller nên điều hướng sang /order-success thay vì render trang QR.
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
        result.alreadyConfirmed = !"PENDING_PAYMENT".equals(result.order.getStatus());

        if (!result.alreadyConfirmed) {
            result.qrCodeUrl = paymentDAO.findLatestQrCode(orderId).orElse(null);
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
        if (!"PENDING_PAYMENT".equals(order.getStatus())) {
            // Khách bấm 2 lần / F5 lại trang -> coi như thành công, không báo lỗi
            result.success = true;
            result.message = "Đơn hàng đã được xác nhận trước đó.";
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