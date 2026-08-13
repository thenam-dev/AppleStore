package dao.order;

import model.entity.cart.CartItem;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.Optional;
import model.entity.order.Order;

public class OrderDAO {

    public int insert(Order order) throws SQLException {
        String sql = """
                INSERT INTO orders (customer_id, delivery_address, recipient_name, recipient_phone,
                    delivery_time_slot, notes, status, total_amount, delivery_fee, discount_amount,
                    final_amount, payment_method)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, order.getCustomerId());
            statement.setString(2, order.getDeliveryAddress());
            statement.setString(3, order.getRecipientName());
            statement.setString(4, order.getRecipientPhone());
            statement.setString(5, order.getDeliveryTimeSlot());
            statement.setString(6, order.getNotes());
            statement.setString(7, order.getStatus());
            statement.setBigDecimal(8, order.getTotalAmount());
            statement.setBigDecimal(9, order.getDeliveryFee());
            statement.setBigDecimal(10, order.getDiscountAmount());
            statement.setBigDecimal(11, order.getFinalAmount());
            statement.setString(12, order.getPaymentMethod());
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated order id.");
            }
        }
    }

    /** Ghi snapshot 1 dòng order_items từ 1 dòng giỏ hàng tại thời điểm đặt hàng. */
    public int insertOrderItem(int orderId, CartItem cartItem) throws SQLException {
        String sql = """
                INSERT INTO order_items (order_id, variant_id, product_name_snapshot, variant_label_snapshot,
                    quantity, unit_price, subtotal, addon_label_snapshot, addon_price_snapshot)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        BigDecimal addonPrice = cartItem.getAddonPrice() == null ? BigDecimal.ZERO : cartItem.getAddonPrice();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, orderId);
            statement.setInt(2, cartItem.getVariantId());
            statement.setString(3, cartItem.getProductName());
            statement.setString(4, cartItem.getVariantLabel());
            statement.setInt(5, cartItem.getQuantity());
            statement.setBigDecimal(6, cartItem.getUnitPrice());
            statement.setBigDecimal(7, cartItem.getLineTotal());
            statement.setString(8, cartItem.getAddonLabel());
            statement.setBigDecimal(9, addonPrice);
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated order item id.");
            }
        }
    }

    /** Xoá order_items khi cần rollback thủ công 1 đơn hàng vì thiếu tồn kho giữa chừng (không còn transaction tự động). */
    public void deleteOrderItem(int orderItemId) throws SQLException {
        String sql = "DELETE FROM order_items WHERE order_item_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderItemId);
            statement.executeUpdate();
        }
    }

    public void deleteOrder(int orderId) throws SQLException {
        String sql = "DELETE FROM orders WHERE order_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            statement.executeUpdate();
        }
    }

    public void insertInventoryLog(int variantId, int changedBy, Integer orderId, Integer orderItemId,
                                    String changeType, int quantityDelta, int quantityAfter) throws SQLException {
        String sql = """
                INSERT INTO inventory_logs (variant_id, changed_by, order_id, order_item_id, change_type,
                    quantity_delta, quantity_after, note)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            statement.setInt(2, changedBy);
            if (orderId == null) statement.setNull(3, Types.INTEGER); else statement.setInt(3, orderId);
            if (orderItemId == null) statement.setNull(4, Types.INTEGER); else statement.setInt(4, orderItemId);
            statement.setString(5, changeType);
            statement.setInt(6, quantityDelta);
            statement.setInt(7, quantityAfter);
            statement.setString(8, "Auto log từ luồng checkout");
            statement.executeUpdate();
        }
    }

    public void insertStatusHistory(int orderId, String status, Integer changedBy, String note) throws SQLException {
        String sql = "INSERT INTO order_status_history (order_id, status, changed_by, note) VALUES (?, ?, ?, ?)";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            statement.setString(2, status);
            if (changedBy == null) statement.setNull(3, Types.INTEGER); else statement.setInt(3, changedBy);
            statement.setString(4, note);
            statement.executeUpdate();
        }
    }

    public boolean updateStatus(int orderId, String newStatus) throws SQLException {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, newStatus);
            statement.setInt(2, orderId);
            return statement.executeUpdate() > 0;
        }
    }

    public Optional<Order> findById(int orderId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE order_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapOrder(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    private Order mapOrder(ResultSet resultSet) throws SQLException {
        Order order = new Order();
        order.setOrderId(resultSet.getInt("order_id"));
        order.setCustomerId(resultSet.getInt("customer_id"));
        order.setDeliveryAddress(resultSet.getString("delivery_address"));
        order.setRecipientName(resultSet.getString("recipient_name"));
        order.setRecipientPhone(resultSet.getString("recipient_phone"));
        order.setStatus(resultSet.getString("status"));
        order.setTotalAmount(resultSet.getBigDecimal("total_amount"));
        order.setDeliveryFee(resultSet.getBigDecimal("delivery_fee"));
        order.setDiscountAmount(resultSet.getBigDecimal("discount_amount"));
        order.setFinalAmount(resultSet.getBigDecimal("final_amount"));
        order.setPaymentMethod(resultSet.getString("payment_method"));
        Timestamp createdAt = resultSet.getTimestamp("created_at");
        if (createdAt != null) {
            order.setCreatedAt(createdAt.toLocalDateTime());
        }
        return order;
    }
}
