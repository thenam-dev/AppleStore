package dao.order;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class CustomerOrderDAO {

    public List<Map<String, Object>> findOrdersByCustomer(int customerId, String tab) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id, o.status, o.created_at, o.final_amount, o.payment_method,
                   o.recipient_name, o.recipient_phone, o.delivery_address, o.total_amount, o.discount_amount,
                   (SELECT product_name_snapshot FROM order_items oi WHERE oi.order_id = o.order_id LIMIT 1) as first_item,
                   (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
            FROM orders o
            WHERE o.customer_id = ?
        """);

        if ("completed".equals(tab)) {
            sql.append(" AND o.status IN ('DELIVERED', 'CANCELLED')");
        } else {
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
        String sql = "";
        if ("completed".equals(tab)) {
            sql = "SELECT COUNT(*) FROM orders WHERE customer_id = ? AND status IN ('DELIVERED', 'CANCELLED')";
        } else {
            sql = "SELECT COUNT(*) FROM orders WHERE customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING', 'DISPATCHED', 'SHIPPING')";
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
        String sql = "SELECT status, changed_at FROM order_status_history WHERE order_id = ? ORDER BY changed_at ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("status", rs.getString("status"));
                    map.put("changedAt", rs.getTimestamp("changed_at"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    /**
     * Đổi trạng thái đơn sang CANCELLED, chỉ thành công nếu đơn còn đang
     * PENDING_PAYMENT/CONFIRMED và đúng chủ đơn - điều kiện nằm trong WHERE
     * nên atomic ở mức 1 câu lệnh SQL (tránh huỷ trùng khi khách bấm 2 lần).
     * Việc hoàn tồn kho được xử lý riêng ở tầng Service SAU KHI bước này trả
     * về true, vì đây chỉ là 1 hàm DAO đơn lẻ, không nên gánh luôn nghiệp vụ
     * trừ/hoàn kho.
     */
    public boolean cancelOrderByCustomer(int orderId, int customerId) throws SQLException {
        String sql = "UPDATE orders SET status = 'CANCELLED', cancelled_at = NOW(), cancelled_by = ? "
                + "WHERE order_id = ? AND customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, orderId);
            ps.setInt(3, customerId);
            return ps.executeUpdate() > 0;
        }
    }
}