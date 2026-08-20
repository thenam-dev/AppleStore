package service.payment;

import dao.order.OrderDAO;
import dao.payment.PaymentDAO;
import model.entity.order.Order;
import service.order.OrderExpiryService;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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

    /**
     * Chỉ lấy trạng thái hiện tại của đơn (có tự huỷ nếu vừa hết hạn) - dùng
     * cho PaymentStatusServlet poll ngầm bằng JSON ở payment.jsp, KHÔNG kèm
     * QR/expiresAt như getPaymentPageData() vì client đã có sẵn những thứ đó,
     * chỉ cần biết đơn đã CONFIRMED/EXPIRED hay chưa để quyết định có
     * điều hướng sang order-success hay không.
     * @return null nếu không tìm thấy đơn hoặc đơn không thuộc về customerId này (chặn IDOR).
     */
    public String getOrderStatusForCustomer(int orderId, int customerId) throws SQLException {
        Optional<Order> orderOpt = orderDAO.findById(orderId);
        if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
            return null;
        }
        Order order = orderOpt.get();
        String status = order.getStatus();
        if ("PENDING_PAYMENT".equals(status) && orderExpiryService.expireIfExpiredNow(orderId)) {
            status = "EXPIRED";
        }
        return status;
    }

    public static class ConfirmResult {
        public boolean success;
        public String message;
    }

    /**
     * Khách tự xác nhận đã chuyển khoản - phương án XÁC NHẬN DỰ PHÒNG, không
     * đối chiếu được với giao dịch ngân hàng thật (khác với
     * processSepayWebhook(), có bằng chứng giao dịch từ SePay). Vẫn được GIỮ
     * LẠI song song với webhook thật theo yêu cầu, dùng khi webhook chưa cấu
     * hình/bị trễ - nhưng vì không xác thực được gì cả, LƯU Ý: ai biết
     * orderId của người khác (vd. đoán số) cũng bấm xác nhận được đơn đó mà
     * không cần thực sự chuyển tiền - đây là rủi ro chấp nhận được cho đồ án,
     * hệ thống thật nên tắt endpoint này khi đã có webhook hoạt động ổn định,
     * hoặc chỉ hiện nút này sau khi đã chờ webhook một khoảng thời gian.
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
        markOrderConfirmed(orderId, customerId, "Khách tự xác nhận đã chuyển khoản");

        result.success = true;
        result.message = "Xác nhận thanh toán thành công!";
        return result;
    }

    /** orderId -> "DH" + orderId (ORDER_PREFIX ở CheckoutService), tìm trong nội dung chuyển khoản của webhook. */
    private static final Pattern ORDER_CODE_PATTERN = Pattern.compile("(?i)DH0*([0-9]+)");

    public static class WebhookResult {
        public boolean confirmed;
        /** Lý do bỏ qua/không xác nhận - dùng để log + ghi vào sepay_webhook_dedup.process_result. */
        public String reason;
    }

    /**
     * Xử lý 1 webhook SePay báo "có giao dịch chuyển khoản vào tài khoản" -
     * đối chiếu nội dung chuyển khoản với mã đơn, đối chiếu số tiền, rồi tự
     * động xác nhận đơn giống hệt luồng khách tự bấm "Tôi đã chuyển khoản"
     * (confirmManualPayment) nhưng có bằng chứng giao dịch thật kèm theo.
     *
     * LUÔN trả về WebhookResult (không throw trừ lỗi hạ tầng SQL thật) để
     * Servlet luôn ack HTTP 200 cho SePay - kể cả khi giao dịch không khớp
     * đơn nào (vd. ai đó chuyển nhầm nội dung) thì cũng không phải lỗi của
     * SePay, không cần SePay gửi lại webhook đó.
     *
     * @param payload JSON webhook đã parse thành Map (xem SepayWebhookServlet)
     * @param rawBody JSON gốc dạng chuỗi, lưu lại để đối soát sau này
     */
    public WebhookResult processSepayWebhook(Map<String, Object> payload, String rawBody) throws SQLException {
        WebhookResult result = new WebhookResult();

        String transferType = asString(payload.get("transferType"));
        if (!"in".equalsIgnoreCase(transferType)) {
            // Giao dịch "out" (tiền ra khỏi tài khoản) không liên quan gì tới việc khách trả tiền đơn hàng.
            result.confirmed = false;
            result.reason = "ignored_not_incoming";
            return result;
        }

        String sepayTransactionId = asString(payload.get("id"));
        if (sepayTransactionId == null || sepayTransactionId.isBlank()) {
            result.confirmed = false;
            result.reason = "missing_transaction_id";
            return result;
        }

        String content = asString(payload.get("content"));
        Integer orderId = extractOrderId(content);
        String orderCode = orderId == null ? null : "DH" + orderId;

        // Khoá giao dịch này lại trước khi làm gì khác - nếu SePay gửi trùng
        // webhook (retry) thì lần sau insertWebhook trả về false, dừng ngay,
        // không xác nhận đơn 2 lần / cộng dồn.
        if (!paymentDAO.tryClaimWebhookTransaction(sepayTransactionId, orderCode == null ? "" : orderCode)) {
            result.confirmed = false;
            result.reason = "duplicate_webhook";
            return result;
        }

        // Từ đây luôn ghi lại result.reason trước mỗi return, rồi finally cập
        // nhật sepay_webhook_dedup.process_result bằng đúng giá trị đó - dù
        // nhánh nào return hay có SQLException giữa chừng cũng không bỏ sót
        // (dedup row đã insert ở tryClaimWebhookTransaction() phía trên, nếu
        // không update lại thì mãi mãi kẹt ở "processing").
        try {
            if (orderId == null) {
                result.confirmed = false;
                result.reason = "order_code_not_found_in_content";
                return result;
            }

            Optional<Order> orderOpt = orderDAO.findById(orderId);
            if (orderOpt.isEmpty()) {
                result.confirmed = false;
                result.reason = "order_not_found:" + orderId;
                return result;
            }

            Order order = orderOpt.get();
            if (!"CK".equals(order.getPaymentMethod())) {
                result.confirmed = false;
                result.reason = "order_not_bank_transfer:" + orderId;
                return result;
            }

            String status = order.getStatus();
            if ("PENDING_PAYMENT".equals(status) && orderExpiryService.expireIfExpiredNow(orderId)) {
                status = "EXPIRED";
            }

            if (!"PENDING_PAYMENT".equals(status)) {
                // Đơn đã CONFIRMED từ trước (vd. khách tự bấm xác nhận trước khi
                // webhook tới) -> coi là thành công, không phải lỗi. Đơn đã bị
                // huỷ/hết hạn nhưng tiền vẫn về -> KHÔNG tự xác nhận (kho đã hoàn
                // lại rồi), cần admin đối soát thủ công và liên hệ khách.
                result.confirmed = "CONFIRMED".equals(status);
                result.reason = "already_" + status + ":" + orderId;
                return result;
            }

            BigDecimal transferAmount = asBigDecimal(payload.get("transferAmount"));
            BigDecimal expectedAmount = paymentDAO.findLatestPendingAmount(orderId).orElse(null);
            if (transferAmount == null || expectedAmount == null
                    || transferAmount.compareTo(expectedAmount) != 0) {
                // Sai số tiền (chuyển thiếu/thừa) - KHÔNG tự xác nhận để tránh xác
                // nhận nhầm; khách/CSKH xử lý thủ công (khách vẫn bấm "Tôi đã
                // chuyển khoản" được nếu chắc chắn đã chuyển đúng - xem rule giữ
                // luôn xác nhận thủ công ở đầu file).
                result.confirmed = false;
                result.reason = "amount_mismatch:" + orderId + " expected=" + expectedAmount + " got=" + transferAmount;
                return result;
            }

            String referenceCode = asString(payload.get("referenceCode"));
            paymentDAO.markLatestCompletedFromWebhook(orderId, sepayTransactionId, referenceCode, rawBody);
            markOrderConfirmed(orderId, null, "Xác nhận thanh toán tự động qua SePay webhook (mã GD: "
                    + sepayTransactionId + (referenceCode == null ? "" : ", ref: " + referenceCode) + ")");

            result.confirmed = true;
            result.reason = "confirmed:" + orderId;
            return result;
        } finally {
            paymentDAO.updateWebhookDedupResult(sepayTransactionId, result.reason);
        }
    }

    private void markOrderConfirmed(int orderId, Integer actorUserId, String note) throws SQLException {
        orderDAO.updateStatus(orderId, "CONFIRMED");
        orderDAO.insertStatusHistory(orderId, "CONFIRMED", actorUserId, note);
    }

    private Integer extractOrderId(String content) {
        if (content == null) {
            return null;
        }
        Matcher matcher = ORDER_CODE_PATTERN.matcher(content);
        if (!matcher.find()) {
            return null;
        }
        try {
            return Integer.parseInt(matcher.group(1));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String asString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    private BigDecimal asBigDecimal(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}