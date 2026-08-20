package dao.staff.order;

import model.entity.order.Order;
import model.entity.order.OrderItem;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import model.entity.order.OrderStatusHistory;

public class StaffOrderDAO {

    public List<Order> findFilteredOrders(String status, String keyword, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id, o.recipient_name, o.recipient_phone, o.total_amount, 
                   o.discount_amount, o.final_amount, o.payment_method, o.status, o.created_at,
                   (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
            FROM orders o
            WHERE 1=1
        """);
        
        List<Object> params = new ArrayList<>();
        if (status != null && !status.isBlank()) {
            sql.append(" AND o.status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (o.order_id LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?)");
            String likeKey = "%" + keyword.trim() + "%";
            params.add(likeKey);
            params.add(likeKey);
            params.add(likeKey);
        }
        
        sql.append(" ORDER BY o.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setRecipientName(rs.getString("recipient_name"));
                    o.setRecipientPhone(rs.getString("recipient_phone"));
                    o.setTotalAmount(rs.getBigDecimal("total_amount"));
                    o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    o.setFinalAmount(rs.getBigDecimal("final_amount"));
                    o.setPaymentMethod(rs.getString("payment_method"));
                    o.setStatus(rs.getString("status"));
                    if (rs.getTimestamp("created_at") != null) {
                        o.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    }
                    o.setNotes(String.valueOf(rs.getInt("item_count"))); 
                    orders.add(o);
                }
            }
        }
        return orders;
    }

    public Optional<Order> findById(int orderId) throws SQLException {
        // JOIN thêm bảng users lần nữa (với alias us) để lấy tên nhân viên Sale dựa trên assigned_sale_staff_id
        String sql = """
            SELECT o.*, 
                   u.full_name AS shipper_name, 
                   d.staff_id AS shipper_id,
                   us.full_name AS sale_staff_name
            FROM orders o 
            LEFT JOIN deliveries d ON o.order_id = d.order_id 
            LEFT JOIN users u ON d.staff_id = u.user_id 
            LEFT JOIN users us ON o.assigned_sale_staff_id = us.user_id
            WHERE o.order_id = ?
        """;
        Order order = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order = new Order();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setRecipientName(rs.getString("recipient_name"));
                    order.setRecipientPhone(rs.getString("recipient_phone"));
                    order.setDeliveryAddress(rs.getString("delivery_address"));
                    order.setTotalAmount(rs.getBigDecimal("total_amount"));
                    order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    order.setFinalAmount(rs.getBigDecimal("final_amount"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setStatus(rs.getString("status"));
                    
                    int assignedStaffId = rs.getInt("assigned_sale_staff_id");
                    if (!rs.wasNull()) {
                        order.setAssignedSaleStaffId(assignedStaffId);
                    }

                    if (rs.getTimestamp("created_at") != null) {
                        order.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    }
                    
                    order.setShipperName(rs.getString("shipper_name"));
                    // Lấy tên nhân viên Sale phụ trách
                    order.setAssignedSaleStaffName(rs.getString("sale_staff_name")); 

                    int shipperId = rs.getInt("shipper_id");
                    if (!rs.wasNull()) {
                        order.setShipperId(shipperId);
                    }
                }
            }
        }
        if (order != null) {
            order.setItems(findOrderItemsByOrderId(orderId));
            order.setStatusHistory(findStatusHistoryByOrderId(orderId));
        }
        return Optional.ofNullable(order);
    }

    public List<OrderItem> findOrderItemsByOrderId(int orderId) throws SQLException {
        String sql = "SELECT * FROM order_items WHERE order_id = ?";
        List<OrderItem> items = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemId(rs.getInt("order_item_id"));
                    item.setOrderId(rs.getInt("order_id"));
                    item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
                    item.setVariantLabelSnapshot(rs.getString("variant_label_snapshot"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setUnitPrice(rs.getBigDecimal("unit_price"));
                    item.setSubtotal(rs.getBigDecimal("subtotal"));
                    item.setAddonLabelSnapshot(rs.getString("addon_label_snapshot"));
                    item.setAddonPriceSnapshot(rs.getBigDecimal("addon_price_snapshot"));
                    items.add(item);
                }
            }
        }
        return items;
    }

    public void updateStatus(int orderId, String status) throws SQLException {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    public void insertStatusHistory(int orderId, String status, Integer changedBy, String note) throws SQLException {
        String sql = "INSERT INTO order_status_history (order_id, status, changed_by, note) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, status);
            if (changedBy == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, changedBy);
            ps.setString(4, note);
            ps.executeUpdate();
        }
    }

    public Integer findBestShipperId() throws SQLException {
        String sql = """
            SELECT u.user_id, COUNT(d.delivery_id) AS active_tasks
            FROM users u
            LEFT JOIN deliveries d ON u.user_id = d.staff_id 
                AND d.status IN ('ASSIGNED', 'PICKED_UP', 'IN_TRANSIT')
            WHERE u.role = 'DELIVERY' AND u.status = 'ACTIVE'
            GROUP BY u.user_id
            ORDER BY active_tasks ASC, RAND()
            LIMIT 1
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("user_id");
            }
        }
        return null;
    }

    public void assignDelivery(int orderId, int shipperId) throws SQLException {
        String sql = "INSERT INTO deliveries (order_id, staff_id, status) VALUES (?, ?, 'ASSIGNED') " +
                     "ON DUPLICATE KEY UPDATE staff_id = ?, status = 'ASSIGNED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, shipperId);
            ps.setInt(3, shipperId);
            ps.executeUpdate();
        }
    }

    public List<Map<String, Object>> findTasksByShipper(int shipperId) throws SQLException {
        String sql = """
            SELECT d.delivery_id, d.order_id, d.status AS delivery_status, 
                   o.recipient_name, o.recipient_phone, o.delivery_address, o.final_amount
            FROM deliveries d
            JOIN orders o ON d.order_id = o.order_id
            WHERE d.staff_id = ? AND d.status IN ('ASSIGNED', 'PICKED_UP', 'IN_TRANSIT')
        """;
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("deliveryId", rs.getInt("delivery_id"));
                    map.put("orderId", rs.getInt("order_id"));
                    map.put("recipientName", rs.getString("recipient_name"));
                    map.put("recipientPhone", rs.getString("recipient_phone"));
                    map.put("deliveryAddress", rs.getString("delivery_address"));
                    map.put("finalAmount", rs.getBigDecimal("final_amount"));
                    list.add(map);
                }
            }
        }
        return list;
    }
    
    public List<OrderStatusHistory> findStatusHistoryByOrderId(int orderId) throws SQLException {
        String sql = """
            SELECT h.history_id, h.order_id, h.status, h.changed_by, h.note, h.changed_at, u.full_name 
            FROM order_status_history h 
            LEFT JOIN users u ON h.changed_by = u.user_id 
            WHERE h.order_id = ? 
            ORDER BY h.changed_at ASC
        """;
        List<OrderStatusHistory> history = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderStatusHistory h = new OrderStatusHistory();
                    h.setHistoryId(rs.getInt("history_id"));
                    h.setOrderId(rs.getInt("order_id"));
                    h.setStatus(rs.getString("status"));
                    
                    int changedBy = rs.getInt("changed_by");
                    if (!rs.wasNull()) {
                        h.setChangedBy(changedBy);
                    }
                    
                    h.setNote(rs.getString("note"));
                    if (rs.getTimestamp("changed_at") != null) {
                        h.setChangedAt(rs.getTimestamp("changed_at").toLocalDateTime());
                    }
                    h.setChangedByName(rs.getString("full_name"));
                    history.add(h);
                }
            }
        }
        return history;
    }

    public void updateDeliveryCompleted(int orderId) throws SQLException {
        String sql = "UPDATE deliveries SET status = 'DELIVERED', delivered_at = NOW() WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }
    
    // Lọc đơn hàng dành riêng cho Staff hoặc Admin (có hỗ trợ filter theo staffId nếu admin chọn)
    public List<Order> findFilteredOrdersByRole(String role, int userId, String staffFilter, String status, String keyword, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT o.order_id, o.recipient_name, o.recipient_phone, o.total_amount, 
                   o.discount_amount, o.final_amount, o.payment_method, o.status, o.created_at,
                   o.assigned_sale_staff_id,
                   (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.order_id) as item_count
            FROM orders o
            WHERE 1=1
        """);
        
        List<Object> params = new ArrayList<>();

        // Nếu không phải ADMIN (tức là SALE_STAFF), bắt buộc chỉ xem đơn của chính mình
        if (!"ADMIN".equals(role)) {
            sql.append(" AND o.assigned_sale_staff_id = ?");
            params.add(userId);
        } else {
            // Nếu là ADMIN, có thể lọc theo một nhân viên Sale cụ thể nếu được chọn trên giao diện
            if (staffFilter != null && !staffFilter.isBlank()) {
                sql.append(" AND o.assigned_sale_staff_id = ?");
                params.add(Integer.parseInt(staffFilter));
            }
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND o.status = ?");
            params.add(status);
        }
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (o.order_id LIKE ? OR o.recipient_name LIKE ? OR o.recipient_phone LIKE ?)");
            String likeKey = "%" + keyword.trim() + "%";
            params.add(likeKey);
            params.add(likeKey);
            params.add(likeKey);
        }
        
        sql.append(" ORDER BY o.created_at DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setRecipientName(rs.getString("recipient_name"));
                    o.setRecipientPhone(rs.getString("recipient_phone"));
                    o.setTotalAmount(rs.getBigDecimal("total_amount"));
                    o.setDiscountAmount(rs.getBigDecimal("discount_amount"));
                    o.setFinalAmount(rs.getBigDecimal("final_amount"));
                    o.setPaymentMethod(rs.getString("payment_method"));
                    o.setStatus(rs.getString("status"));
                    o.setAssignedSaleStaffId(rs.getInt("assigned_sale_staff_id"));
                    if (rs.getTimestamp("created_at") != null) {
                        o.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    }
                    o.setNotes(String.valueOf(rs.getInt("item_count"))); 
                    orders.add(o);
                }
            }
        }
        return orders;
    }

    // Admin chuyển giao việc khi đơn đang ở trạng thái CONFIRMED
    public boolean updateAssignedSaleStaff(int orderId, int newStaffId) throws SQLException {
        String sql = "UPDATE orders SET assigned_sale_staff_id = ? WHERE order_id = ? AND status = 'CONFIRMED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newStaffId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    // Lấy danh sách nhân viên Sale đang active để đổ vào thẻ <select> cho Admin
    public List<Map<String, Object>> getActiveSaleStaffList() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT user_id, full_name FROM users WHERE role = 'SALE_STAFF' AND status = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> staff = new HashMap<>();
                staff.put("userId", rs.getInt("user_id"));
                staff.put("fullName", rs.getString("full_name"));
                list.add(staff);
            }
        }
        return list;
    }
}