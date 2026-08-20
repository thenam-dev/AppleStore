package dao.order;

import model.entity.cart.CartItem;
import model.entity.order.OrderItem;
import model.entity.order.Order;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class OrderDAO {

    // =========================================================================
    // PHẦN 1: LOGIC CỦA NHÂN VIÊN / HỆ THỐNG (Từ OrderDAO cũ)
    // =========================================================================

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

    public List<OrderItem> findItemsByOrderId(int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY order_item_id ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    items.add(mapOrderItem(resultSet));
                }
            }
        }
        return items;
    }

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

    /**
     * Chuyển đơn CK sang EXPIRED khi hết hạn giữ chỗ thanh toán, chỉ thành
     * công nếu đơn còn đang PENDING_PAYMENT (điều kiện nằm trong WHERE nên
     * atomic) - tránh xử lý trùng khi job quét chạy chồng lượt, hoặc khách
     * vừa thanh toán xong đúng lúc job chạy.
     */
    public boolean expireIfStillPending(int orderId) throws SQLException {
        String sql = "UPDATE orders SET status = 'EXPIRED' WHERE order_id = ? AND status = 'PENDING_PAYMENT'";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, orderId);
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

    // =========================================================================
    // PHẦN 2: LOGIC CỦA KHÁCH HÀNG (Từ CustomerOrderDAO cũ chuyển sang)
    // =========================================================================

    public List<Map<String, Object>> findOrdersByCustomer(int customerId, String tab) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id, o.status, o.created_at, o.final_amount, o.payment_method,
                   o.recipient_name, o.recipient_phone, o.delivery_address, o.total_amount, o.discount_amount,
                   (SELECT product_name_snapshot FROM order_items oi WHERE oi.order_id = o.order_id LIMIT 1) as first_item,
                   (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
            FROM orders o
            WHERE o.customer_id = ?
        """);

        // Đã sửa: Thêm EXPIRED và PAYMENT_FAILED để đơn hủy tự động vẫn hiện ra
        if ("completed".equals(tab)) {
            sql.append(" AND o.status IN ('DELIVERED', 'CANCELLED', 'EXPIRED', 'PAYMENT_FAILED')");
        } else if ("active".equals(tab)) {
            sql.append(" AND o.status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING', 'DISPATCHED', 'SHIPPING')");
        }
        
        sql.append(" ORDER BY o.created_at DESC");

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("orderId", rs.getInt("order_id"));
                    map.put("status", rs.getString("status"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("finalAmount", rs.getBigDecimal("final_amount"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("discountAmount", rs.getBigDecimal("discount_amount"));
                    map.put("paymentMethod", rs.getString("payment_method"));
                    map.put("recipientName", rs.getString("recipient_name"));
                    map.put("recipientPhone", rs.getString("recipient_phone"));
                    map.put("deliveryAddress", rs.getString("delivery_address"));
                    map.put("firstItem", rs.getString("first_item"));
                    map.put("itemCount", rs.getInt("item_count"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public int countTabOrders(int customerId, String tab) throws SQLException {
        String sql;
        // Đã sửa: Thêm EXPIRED và PAYMENT_FAILED
        if ("completed".equals(tab)) {
            sql = "SELECT COUNT(*) FROM orders WHERE customer_id = ? AND status IN ('DELIVERED', 'CANCELLED', 'EXPIRED', 'PAYMENT_FAILED')";
        } else if ("active".equals(tab)) {
            sql = "SELECT COUNT(*) FROM orders WHERE customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING', 'DISPATCHED', 'SHIPPING')";
        } else {
            sql = "SELECT COUNT(*) FROM orders WHERE customer_id = ?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
    public Map<String, Object> findOrderDetail(int orderId, int customerId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE order_id = ? AND customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("orderId", rs.getInt("order_id"));
                    map.put("status", rs.getString("status"));
                    map.put("createdAt", rs.getTimestamp("created_at"));
                    map.put("finalAmount", rs.getBigDecimal("final_amount"));
                    map.put("totalAmount", rs.getBigDecimal("total_amount"));
                    map.put("discountAmount", rs.getBigDecimal("discount_amount"));
                    map.put("paymentMethod", rs.getString("payment_method"));
                    map.put("recipientName", rs.getString("recipient_name"));
                    map.put("recipientPhone", rs.getString("recipient_phone"));
                    map.put("deliveryAddress", rs.getString("delivery_address"));
                    return map;
                }
            }
        }
        return null;
    }

    public List<Map<String, Object>> findTimelineByOrderId(int orderId) throws SQLException {
        String sql = "SELECT status, changed_at, note FROM order_status_history WHERE order_id = ? ORDER BY changed_at ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("status", rs.getString("status"));
                    map.put("changedAt", rs.getTimestamp("changed_at"));
                    map.put("note", rs.getString("note")); // Lấy thêm ghi chú
                    list.add(map);
                }
            }
        }
        return list;
    }

    public boolean cancelOrderByCustomer(int orderId, int customerId) throws SQLException {
        String updateOrderSql = "UPDATE orders SET status = 'CANCELLED', cancelled_at = NOW(), cancelled_by = ? WHERE order_id = ? AND customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED')";
        String selectItemsSql = "SELECT order_item_id, variant_id, quantity FROM order_items WHERE order_id = ?";
        String updateStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";
        String checkStockSql = "SELECT stock_quantity FROM product_variants WHERE variant_id = ?";
        String insertLogSql = "INSERT INTO inventory_logs (variant_id, changed_by, order_id, order_item_id, change_type, quantity_delta, quantity_after, note) VALUES (?, ?, ?, ?, 'ORDER_RELEASE', ?, ?, 'Hoàn lại tồn kho do khách hàng huỷ đơn')";
        String insertHistorySql = "INSERT INTO order_status_history (order_id, status, changed_by, note) VALUES (?, 'CANCELLED', ?, 'Khách hàng tự huỷ đơn')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); 
            try {
                try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                    ps.setInt(1, customerId);
                    ps.setInt(2, orderId);
                    ps.setInt(3, customerId);
                    int rows = ps.executeUpdate();
                    if (rows == 0) {
                        conn.rollback(); 
                        return false; 
                    }
                }

                List<Map<String, Integer>> items = new ArrayList<>();
                try (PreparedStatement psItems = conn.prepareStatement(selectItemsSql)) {
                    psItems.setInt(1, orderId);
                    try (ResultSet rs = psItems.executeQuery()) {
                        while (rs.next()) {
                            int variantId = rs.getInt("variant_id");
                            if (!rs.wasNull()) {
                                Map<String, Integer> item = new HashMap<>();
                                item.put("orderItemId", rs.getInt("order_item_id"));
                                item.put("variantId", variantId);
                                item.put("quantity", rs.getInt("quantity"));
                                items.add(item);
                            }
                        }
                    }
                }

                if (!items.isEmpty()) {
                    try (PreparedStatement psUpdateStock = conn.prepareStatement(updateStockSql);
                         PreparedStatement psCheckStock = conn.prepareStatement(checkStockSql);
                         PreparedStatement psInsertLog = conn.prepareStatement(insertLogSql)) {
                         
                        for (Map<String, Integer> item : items) {
                            int vId = item.get("variantId");
                            int qty = item.get("quantity");
                            int itemId = item.get("orderItemId");

                            psUpdateStock.setInt(1, qty);
                            psUpdateStock.setInt(2, vId);
                            psUpdateStock.executeUpdate();

                            int currentStock = 0;
                            psCheckStock.setInt(1, vId);
                            try (ResultSet rs = psCheckStock.executeQuery()) {
                                if (rs.next()) {
                                    currentStock = rs.getInt(1);
                                }
                            }

                            psInsertLog.setInt(1, vId);
                            psInsertLog.setInt(2, customerId); 
                            psInsertLog.setInt(3, orderId);
                            psInsertLog.setInt(4, itemId);
                            psInsertLog.setInt(5, qty);
                            psInsertLog.setInt(6, currentStock); 
                            psInsertLog.executeUpdate();
                        }
                    }
                }

                try (PreparedStatement psHistory = conn.prepareStatement(insertHistorySql)) {
                    psHistory.setInt(1, orderId);
                    psHistory.setInt(2, customerId);
                    psHistory.executeUpdate();
                }

                conn.commit(); 
                return true;
            } catch (SQLException e) {
                conn.rollback(); 
                throw e;
            } finally {
                conn.setAutoCommit(true); 
            }
        }
    }

    // =========================================================================
    // MAPPING HELPERS
    // =========================================================================

    private Order mapOrder(ResultSet resultSet) throws SQLException {
        Order order = new Order();
        order.setOrderId(resultSet.getInt("order_id"));
        order.setCustomerId(resultSet.getInt("customer_id"));
        order.setDeliveryAddress(resultSet.getString("delivery_address"));
        order.setRecipientName(resultSet.getString("recipient_name"));
        order.setRecipientPhone(resultSet.getString("recipient_phone"));
        order.setDeliveryTimeSlot(resultSet.getString("delivery_time_slot"));
        order.setNotes(resultSet.getString("notes"));
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

    private OrderItem mapOrderItem(ResultSet resultSet) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemId(resultSet.getInt("order_item_id"));
        item.setOrderId(resultSet.getInt("order_id"));

        int variantId = resultSet.getInt("variant_id");
        item.setVariantId(resultSet.wasNull() ? null : variantId);

        int serialId = resultSet.getInt("serial_id");
        item.setSerialId(resultSet.wasNull() ? null : serialId);

        item.setProductNameSnapshot(resultSet.getString("product_name_snapshot"));
        item.setVariantLabelSnapshot(resultSet.getString("variant_label_snapshot"));
        item.setQuantity(resultSet.getInt("quantity"));
        item.setUnitPrice(resultSet.getBigDecimal("unit_price"));
        item.setSubtotal(resultSet.getBigDecimal("subtotal"));
        item.setAddonLabelSnapshot(resultSet.getString("addon_label_snapshot"));
        item.setAddonPriceSnapshot(resultSet.getBigDecimal("addon_price_snapshot"));
        return item;
    }
    
    public List<Map<String, Object>> findOrderItems(int orderId) throws SQLException {
        List<Map<String, Object>> items = new java.util.ArrayList<>();
        String sql = "SELECT order_item_id, product_name_snapshot, variant_label_snapshot, quantity, subtotal " +
                     "FROM order_items WHERE order_id = ?";
                     
        try (java.sql.Connection conn = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("orderItemId", rs.getInt("order_item_id"));
                    item.put("productNameSnapshot", rs.getString("product_name_snapshot"));
                    item.put("variantLabelSnapshot", rs.getString("variant_label_snapshot"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("subtotal", rs.getBigDecimal("subtotal"));
                    items.add(item);
                }
            }
        }
        return items;
    }
}