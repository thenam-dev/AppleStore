package dao.order;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class CustomerOrderDAO {

    // Lấy danh sách đơn hàng của riêng khách hàng đó (có lọc theo trạng thái UI)
    public List<Map<String, Object>> findOrdersByCustomer(int customerId, String uiStatus) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id, o.status, o.created_at, o.final_amount, o.payment_method,
                   o.recipient_name, o.recipient_phone, o.delivery_address, o.total_amount, o.discount_amount,
                   (SELECT product_name_snapshot FROM order_items oi WHERE oi.order_id = o.order_id LIMIT 1) as first_item,
                   (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
            FROM orders o
            WHERE o.customer_id = ?
        """);

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (uiStatus != null && !uiStatus.isBlank()) {
            if ("PENDING".equals(uiStatus)) {
                sql.append(" AND o.status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING')");
            } else if ("SHIPPING".equals(uiStatus)) {
                sql.append(" AND o.status IN ('DISPATCHED', 'SHIPPING')");
            } else if ("DELIVERED".equals(uiStatus)) {
                sql.append(" AND o.status = 'DELIVERED'");
            } else if ("CANCELLED".equals(uiStatus)) {
                sql.append(" AND o.status = 'CANCELLED'");
            }
        }

        sql.append(" ORDER BY o.created_at DESC");

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
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

    // Đếm số lượng đơn hàng theo từng nhóm trạng thái để hiển thị badge trên nút lọc
    public Map<String, Integer> countOrdersByStatus(int customerId) throws SQLException {
        String sql = """
            SELECT 
                SUM(1) as total_all,
                SUM(CASE WHEN status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING') THEN 1 ELSE 0 END) as count_pending,
                SUM(CASE WHEN status IN ('DISPATCHED', 'SHIPPING') THEN 1 ELSE 0 END) as count_shipping,
                SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) as count_delivered,
                SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as count_cancelled
            FROM orders WHERE customer_id = ?
        """;
        Map<String, Integer> counts = new HashMap<>();
        counts.put("ALL", 0);
        counts.put("PENDING", 0);
        counts.put("SHIPPING", 0);
        counts.put("DELIVERED", 0);
        counts.put("CANCELLED", 0);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    counts.put("ALL", rs.getInt("total_all"));
                    counts.put("PENDING", rs.getInt("count_pending"));
                    counts.put("SHIPPING", rs.getInt("count_shipping"));
                    counts.put("DELIVERED", rs.getInt("count_delivered"));
                    counts.put("CANCELLED", rs.getInt("count_cancelled"));
                }
            }
        }
        return counts;
    }

    // Lấy chi tiết một đơn hàng (chỉ trả về nếu đúng customer_id sở hữu)
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

    // Lấy lịch sử trạng thái (Timeline) TUYỆT ĐỐI KHÔNG JOIN BẢNG USERS (Không lộ changed_by)
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

    // Khách hàng hủy đơn (chỉ khi đơn đang ở trạng thái PENDING_PAYMENT hoặc CONFIRMED)
    public boolean cancelOrderByCustomer(int orderId, int customerId) throws SQLException {
        String sql = "UPDATE orders SET status = 'CANCELLED', cancelled_at = NOW() WHERE order_id = ? AND customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }
}