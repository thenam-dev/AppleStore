/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Order;

/**
 *
 * @author admin
 */
public class DashboardDAO {

    // 1. Tính tổng doanh thu (sửa thành cột final_amount thay vì total_amount)
    public double getTotalRevenue() {
        String sql = "SELECT SUM(final_amount) FROM orders WHERE status = 'DELIVERED'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 2. Đếm số lượng theo bảng
    public int getCount(String table, String condition) {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE " + condition;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // 3. Lấy đơn hàng mới nhất (Đổi TOP thành LIMIT)
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT order_id, recipient_name, created_at, final_amount, status FROM orders ORDER BY created_at DESC LIMIT ?";
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
                    o.setFinalAmount(rs.getDouble("final_amount"));
                    o.setStatus(rs.getString("status"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
