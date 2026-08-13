/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao.dashboard;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.entity.order.Order;

/**
 *
 * @author admin
 */
public class DashboardDAO {

    // 2. Đếm số lượng theo bảng
    public int getCount(String table, String condition) {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE " + condition;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            // 3. Try con để chạy lệnh
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
    // 3. Lấy đơn hàng mới nhất (Đổi TOP thành LIMIT)

    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT order_id, recipient_name, created_at, final_amount, status FROM orders " +
                     "ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderId(rs.getInt("order_id"));
                    o.setRecipientName(rs.getString("recipient_name"));
                    java.sql.Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        o.setCreatedAt(ts.toLocalDateTime());
                    }
                    o.setFinalAmount(rs.getBigDecimal("final_amount"));
                    o.setStatus(rs.getString("status"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. Lấy danh sách sản phẩm bán chạy nhất
    public List<dto.BestSellingProductDTO> getBestSellingProducts(int limit) {
        List<dto.BestSellingProductDTO> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, pi.file_path, SUM(oi.quantity) as total_sold " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.order_id " +
                     "JOIN product_variants pv ON oi.variant_id = pv.variant_id " +
                     "JOIN products p ON pv.product_id = p.product_id " +
                     "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE o.status = 'DELIVERED' " +
                     "GROUP BY p.product_id, p.name, pi.file_path " +
                     "ORDER BY total_sold DESC " +
                     "LIMIT ?";
                     
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dto.BestSellingProductDTO dto = new dto.BestSellingProductDTO();
                    dto.setProductId(rs.getInt("product_id"));
                    dto.setName(rs.getString("name"));
                    dto.setImageUrl(rs.getString("file_path"));
                    dto.setTotalSold(rs.getInt("total_sold"));
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
