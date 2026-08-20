/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao.payment;

import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
/**
 *
 * @author namnthe180997
 */
public class PaymentDAO {
    /** Tạo 1 phiên thanh toán mới, attempt_no tự tăng theo order (phòng khi khách thử lại). */
    public int insertPending(int orderId, BigDecimal amount, String qrCodeUrl) throws SQLException {
        int nextAttempt = findNextAttemptNo(orderId);
        String sql = """
                INSERT INTO payment_transactions (order_id, attempt_no, payment_method, amount, status,
                    sepay_qr_code, expires_at)
                VALUES (?, ?, 'SEPAY', ?, 'PENDING', ?, DATE_ADD(NOW(), INTERVAL 15 MINUTE))
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, orderId);
            statement.setInt(2, nextAttempt);
            statement.setBigDecimal(3, amount);
            statement.setString(4, qrCodeUrl);
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated payment transaction id.");
            }
        }
    }

    public int findNextAttemptNo(int orderId) throws SQLException {
        String sql = "SELECT COALESCE(MAX(attempt_no), 0) + 1 AS next_attempt FROM payment_transactions WHERE order_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt("next_attempt");
            }
        }
    }

    public Optional<String> findLatestQrCode(int orderId) throws SQLException {
        String sql = """
                SELECT sepay_qr_code FROM payment_transactions
                WHERE order_id = ? AND status = 'PENDING'
                ORDER BY attempt_no DESC LIMIT 1
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.ofNullable(resultSet.getString("sepay_qr_code"));
                }
                return Optional.empty();
            }
        }
    }

    /**
     * Thời điểm hết hạn của phiên thanh toán PENDING mới nhất - dùng để hiển
     * thị đồng hồ đếm ngược ở payment.jsp (xem PaymentService.getPaymentPageData).
     * Cùng mốc thời gian mà OrderExpiryService dùng để tự huỷ đơn, nên đồng hồ
     * trên UI và job huỷ ở server luôn khớp nhau.
     */
    public Optional<java.time.LocalDateTime> findLatestExpiresAt(int orderId) throws SQLException {
        String sql = """
                SELECT expires_at FROM payment_transactions
                WHERE order_id = ? AND status = 'PENDING'
                ORDER BY attempt_no DESC LIMIT 1
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    Timestamp expiresAt = resultSet.getTimestamp("expires_at");
                    return expiresAt == null ? Optional.empty() : Optional.of(expiresAt.toLocalDateTime());
                }
                return Optional.empty();
            }
        }
    }

    /** Xoá phiên thanh toán khi cần rollback thủ công (checkout lỗi giữa chừng, không còn transaction tự động). */
    public void deleteById(int transactionId) throws SQLException {
        String sql = "DELETE FROM payment_transactions WHERE transaction_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.executeUpdate();
        }
    }
    
     /**
     * DEMO-ONLY: đánh dấu phiên PENDING mới nhất của 1 đơn thành COMPLETED khi
     * khách tự bấm "Tôi đã chuyển khoản" ở payment.jsp. KHÔNG thay thế webhook
     * xác thực thật từ SePay - chỉ dùng để demo trọn luồng cho đồ án.
     */
    public boolean markLatestCompleted(int orderId) throws SQLException {
        String sql = """
                UPDATE payment_transactions
                SET status = 'COMPLETED', completed_at = NOW()
                WHERE order_id = ? AND status = 'PENDING'
                ORDER BY attempt_no DESC
                LIMIT 1
                """;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    /**
     * Tìm các đơn CK còn PENDING_PAYMENT mà phiên thanh toán (attempt) mới
     * nhất đã hết hạn (expires_at < NOW()) và chưa được xác nhận - dùng cho
     * job tự động huỷ + hoàn kho (OrderExpiryService). Chỉ xét attempt mới
     * nhất của mỗi đơn vì khách có thể tạo lại QR (attempt mới) sau khi
     * attempt cũ hết hạn.
     */
    public List<Integer> findExpiredPendingOrderIds() throws SQLException {
        String sql = """
                SELECT o.order_id
                FROM orders o
                JOIN payment_transactions pt ON pt.order_id = o.order_id
                WHERE o.status = 'PENDING_PAYMENT'
                  AND o.payment_method = 'CK'
                  AND pt.status = 'PENDING'
                  AND pt.expires_at IS NOT NULL
                  AND pt.expires_at < NOW()
                  AND pt.attempt_no = (
                      SELECT MAX(pt2.attempt_no) FROM payment_transactions pt2 WHERE pt2.order_id = o.order_id
                  )
                """;

        List<Integer> orderIds = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                orderIds.add(resultSet.getInt("order_id"));
            }
        }
        return orderIds;
    }

    /** Đánh dấu phiên thanh toán PENDING mới nhất của 1 đơn thành EXPIRED (không còn hiệu lực để quét lại). */
    public boolean expireLatestPending(int orderId) throws SQLException {
        String sql = """
                UPDATE payment_transactions
                SET status = 'EXPIRED'
                WHERE order_id = ? AND status = 'PENDING'
                ORDER BY attempt_no DESC
                LIMIT 1
                """;
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            return statement.executeUpdate() > 0;
        }
    }
}
