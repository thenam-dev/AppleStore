package dao.order;

import model.entity.cart.CartItem;
import model.entity.order.OrderItem;
import model.entity.order.Order;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class OrderDAO {
    
    //Thêm một đơn hàng mới vào bảng orders và trả về order_id vừa được database tạo.
    public int insert(Order order) throws SQLException {
        String sql = """
                INSERT INTO orders (customer_id, assigned_sale_staff_id, delivery_address, recipient_name, recipient_phone,
                    delivery_time_slot, notes, status, total_amount, delivery_fee, discount_amount,
                    final_amount, payment_method)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, order.getCustomerId());
            if (order.getAssignedSaleStaffId() != null && order.getAssignedSaleStaffId() > 0) {
                ps.setInt(2, order.getAssignedSaleStaffId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, order.getDeliveryAddress());
            ps.setString(4, order.getRecipientName());
            ps.setString(5, order.getRecipientPhone());
            ps.setString(6, order.getDeliveryTimeSlot());
            ps.setString(7, order.getNotes());
            ps.setString(8, order.getStatus());
            ps.setBigDecimal(9, order.getTotalAmount());
            ps.setBigDecimal(10, order.getDeliveryFee());
            ps.setBigDecimal(11, order.getDiscountAmount());
            ps.setBigDecimal(12, order.getFinalAmount());
            ps.setString(13, order.getPaymentMethod());
            
            ps.executeUpdate();

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated order id.");
            }
        }
    }

    //Thêm một sản phẩm từ giỏ hàng vào bảng
    public int insertOrderItem(int orderId, CartItem cartItem) throws SQLException {
        String sql = """
                INSERT INTO order_items (order_id, variant_id, product_name_snapshot, variant_label_snapshot,
                    quantity, unit_price, subtotal, addon_label_snapshot, addon_price_snapshot)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        BigDecimal addonPrice = cartItem.getAddonPrice() == null ? BigDecimal.ZERO : cartItem.getAddonPrice();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, orderId);
            ps.setInt(2, cartItem.getVariantId());
            ps.setString(3, cartItem.getProductName());
            ps.setString(4, cartItem.getVariantLabel());
            ps.setInt(5, cartItem.getQuantity());
            ps.setBigDecimal(6, cartItem.getUnitPrice());
            ps.setBigDecimal(7, cartItem.getLineTotal());
            ps.setString(8, cartItem.getAddonLabel());
            ps.setBigDecimal(9, addonPrice);
            
            ps.executeUpdate();

            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated order item id.");
            }
        }
    }

    //Lấy tất cả sản phẩm thuộc một đơn hàng.
    public List<OrderItem> findItemsByOrderId(int orderId) throws SQLException {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT * FROM order_items WHERE order_id = ? ORDER BY order_item_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(mapOrderItem(rs));
                }
            }
        }
        return items;
    }

    //Xóa một sản phẩm trong đơn_không sử dụng
    public void deleteOrderItem(int orderItemId) throws SQLException {
        String sql = "DELETE FROM order_items WHERE order_item_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderItemId);
            ps.executeUpdate();
        }
    }

    //Xóa đơn hàng_
    public void deleteOrder(int orderId) throws SQLException {
        String sql = "DELETE FROM orders WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.executeUpdate();
        }
    }

    public void insertInventoryLog(int variantId, int changedBy, Integer orderId, Integer orderItemId,
                                   String changeType, int quantityDelta, int quantityAfter) throws SQLException {
        String sql = """
                INSERT INTO inventory_logs (variant_id, changed_by, order_id, order_item_id, change_type,
                    quantity_delta, quantity_after, note)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.setInt(2, changedBy);
            if (orderId == null) ps.setNull(3, Types.INTEGER); else ps.setInt(3, orderId);
            if (orderItemId == null) ps.setNull(4, Types.INTEGER); else ps.setInt(4, orderItemId);
            ps.setString(5, changeType);
            ps.setInt(6, quantityDelta);
            ps.setInt(7, quantityAfter);
            ps.setString(8, "Auto log từ luồng checkout");
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

    //tìm nhân viên sale phù hợp nhất_đếm số đơn đang xử lý của từng nhân viên_tìm ít việc nhất_ngẫu nhiên nếu cùng khối lượng
    public Integer findBestSaleStaffId() throws SQLException {
        String sql = """
            SELECT u.user_id, COUNT(o.order_id) AS active_tasks
            FROM users u
            LEFT JOIN orders o ON u.user_id = o.assigned_sale_staff_id 
                AND o.status IN ('PENDING_PAYMENT', 'CONFIRMED', 'PREPARING', 'DISPATCHED')
            WHERE u.role = 'SALE_STAFF' AND u.status = 'ACTIVE'
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

    //Gán nhân viên bán hàng vào đơn hàng.
    public void assignSaleStaff(int orderId, int staffId) throws SQLException {
        String sql = "UPDATE orders SET assigned_sale_staff_id = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    //Cập nhật trạng thái mới cho đơn hàng.
    public boolean updateStatus(int orderId, String newStatus) throws SQLException {
        String sql = "UPDATE orders SET status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    //Chuyển trạng thái đơn sang EXPIRED nếu đơn vẫn đang ở trạng thái chờ thanh toán PENDING_PAYMENT
    public boolean expireIfStillPending(int orderId) throws SQLException {
        String sql = "UPDATE orders SET status = 'EXPIRED' WHERE order_id = ? AND status = 'PENDING_PAYMENT'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        }
    }

    public Optional<Order> findById(int orderId) throws SQLException {
        String sql = "SELECT * FROM orders WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapOrder(rs));
                }
                return Optional.empty();
            }
        }
    }

    public boolean updateAssignedSaleStaff(int orderId, int newStaffId) throws SQLException {
        String sql = "UPDATE orders SET assigned_sale_staff_id = ? WHERE order_id = ? AND status = 'CONFIRMED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newStaffId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        }
    }

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
                    map.put("note", rs.getString("note"));
                    list.add(map);
                }
            }
        }
        return list;
    }

    public List<Map<String, Object>> findOrderItems(int orderId) throws SQLException {
        List<Map<String, Object>> items = new ArrayList<>();
        String sql = "SELECT order_item_id, product_name_snapshot, variant_label_snapshot, quantity, subtotal " +
                     "FROM order_items WHERE order_id = ?";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
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

    public boolean cancelOrderByCustomer(int orderId, int customerId) throws SQLException {
        String updateOrderSql = "UPDATE orders SET status = 'CANCELLED', cancelled_at = NOW(), cancelled_by = ? WHERE order_id = ? AND customer_id = ? AND status IN ('PENDING_PAYMENT', 'CONFIRMED')";
        String selectItemsSql = "SELECT order_item_id, variant_id, quantity FROM order_items WHERE order_id = ?";
        String updateStockSql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";
        String getStockSql = "SELECT stock_quantity FROM product_variants WHERE variant_id = ?";
        String insertLogSql = "INSERT INTO inventory_logs (variant_id, changed_by, order_id, order_item_id, change_type, quantity_delta, quantity_after, note) VALUES (?, ?, ?, ?, 'ORDER_RELEASE', ?, ?, 'Hoàn lại tồn kho do khách hàng huỷ đơn')";
        String insertHistorySql = "INSERT INTO order_status_history (order_id, status, changed_by, note) VALUES (?, 'CANCELLED', ?, 'Khách hàng tự huỷ đơn')";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); 
            try {
                // 1. Khóa và cập nhật trạng thái đơn hàng (chỉ cho phép hủy khi ở PENDING_PAYMENT hoặc CONFIRMED)
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

                // 2. Lấy danh sách sản phẩm trong đơn để hoàn kho
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
                         PreparedStatement psGetStock = conn.prepareStatement(getStockSql);
                         PreparedStatement psInsertLog = conn.prepareStatement(insertLogSql)) {
                         
                        for (Map<String, Integer> item : items) {
                            int vId = item.get("variantId");
                            int qty = item.get("quantity");
                            int itemId = item.get("orderItemId");

                            // Cộng lại kho
                            psUpdateStock.setInt(1, qty);
                            psUpdateStock.setInt(2, vId);
                            psUpdateStock.executeUpdate();

                            // Đọc lại stock ngay trong cùng transaction an toàn
                            int currentStock = 0;
                            psGetStock.setInt(1, vId);
                            try (ResultSet rsStock = psGetStock.executeQuery()) {
                                if (rsStock.next()) {
                                    currentStock = rsStock.getInt(1);
                                }
                            }

                            // Ghi log kho an toàn
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

                // 3. Ghi lịch sử trạng thái đơn hàng
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

    private Order mapOrder(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setDeliveryAddress(rs.getString("delivery_address"));
        order.setRecipientName(rs.getString("recipient_name"));
        order.setRecipientPhone(rs.getString("recipient_phone"));
        order.setDeliveryTimeSlot(rs.getString("delivery_time_slot"));
        order.setNotes(rs.getString("notes"));
        order.setStatus(rs.getString("status"));
        order.setTotalAmount(rs.getBigDecimal("total_amount"));
        order.setDeliveryFee(rs.getBigDecimal("delivery_fee"));
        order.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        order.setFinalAmount(rs.getBigDecimal("final_amount"));
        order.setPaymentMethod(rs.getString("payment_method"));
        
        int assignedStaffId = rs.getInt("assigned_sale_staff_id");
        if (!rs.wasNull()) {
            order.setAssignedSaleStaffId(assignedStaffId);
        }

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            order.setCreatedAt(createdAt.toLocalDateTime());
        }
        return order;
    }

    private OrderItem mapOrderItem(ResultSet rs) throws SQLException {
        OrderItem item = new OrderItem();
        item.setOrderItemId(rs.getInt("order_item_id"));
        item.setOrderId(rs.getInt("order_id"));

        int variantId = rs.getInt("variant_id");
        item.setVariantId(rs.wasNull() ? null : variantId);

        int serialId = rs.getInt("serial_id");
        item.setSerialId(rs.wasNull() ? null : serialId);

        item.setProductNameSnapshot(rs.getString("product_name_snapshot"));
        item.setVariantLabelSnapshot(rs.getString("variant_label_snapshot"));
        item.setQuantity(rs.getInt("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setSubtotal(rs.getBigDecimal("subtotal"));
        item.setAddonLabelSnapshot(rs.getString("addon_label_snapshot"));
        item.setAddonPriceSnapshot(rs.getBigDecimal("addon_price_snapshot"));
        return item;
    }
}