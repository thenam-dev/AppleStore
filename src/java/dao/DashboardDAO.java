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
import model.entity.order.Order;


/**
 *
 * @author admin
 */
public class DashboardDAO {

    // 1. Tính  doanh thu từng ngày(sửa thành cột final_amount thay vì total_amount)
     public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate) {
        java.util.LinkedHashMap<String, Double> map = new java.util.LinkedHashMap<>();
        
        String sql = "SELECT DATE(created_at) as order_date, SUM(final_amount) as daily_revenue " +
                     "FROM orders WHERE status = 'DELIVERED'";
                     
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        if (hasDateFilter) {
            sql += " AND created_at BETWEEN ? AND ?";
        }
        
        // Bắt buộc phải gom nhóm theo ngày (GROUP BY) và sắp xếp tăng dần (ORDER BY)
        sql += " GROUP BY DATE(created_at) ORDER BY DATE(created_at) ASC";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (hasDateFilter) {
                ps.setString(1, startDate + " 00:00:00");
                ps.setString(2, endDate + " 23:59:59");
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Đưa dữ liệu vào Map. Ví dụ: map.put("2026-08-12", 15000000.0)
                    map.put(rs.getString("order_date"), rs.getDouble("daily_revenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    // 2. Đếm số lượng theo bảng
    public int getCount(String table, String condition, String startDate, String endDate) {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE " + condition;
        // 1. Kiểm tra xem có lọc ngày không, VÀ bảng đang đếm có phải là bảng orders không?
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        boolean isOrderTable = table.equalsIgnoreCase("orders");
        if (hasDateFilter && isOrderTable) {
            sql += " AND created_at BETWEEN ? AND ?";
        }
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hasDateFilter && isOrderTable) {
                ps.setString(1, startDate + " 00:00:00");
                ps.setString(2, endDate + " 23:59:59");
            }

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

    public List<Order> getRecentOrders(int limit, String startDate, String endDate) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT order_id, recipient_name, created_at, final_amount, status FROM orders";
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());

        // 3. Nối thêm chữ WHERE nếu có lọc ngày
        if (hasDateFilter) {
            sql += " WHERE created_at BETWEEN ? AND ?";
        }
        sql += " ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            if (hasDateFilter) {
                ps.setString(1, startDate + " 00:00:00");
                ps.setString(2, endDate + " 23:59:59");
                ps.setInt(3, limit);
            } else {
                ps.setInt(1, limit);
            }
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
}
