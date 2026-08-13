/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao.payment;

import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
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

    /** Xoá phiên thanh toán khi cần rollback thủ công (checkout lỗi giữa chừng, không còn transaction tự động). */
    public void deleteById(int transactionId) throws SQLException {
        String sql = "DELETE FROM payment_transactions WHERE transaction_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, transactionId);
            statement.executeUpdate();
        }
    }
}
