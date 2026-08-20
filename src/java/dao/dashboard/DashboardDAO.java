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
import java.util.LinkedHashMap;
import java.util.List;
import model.entity.order.Order;

/**
 *
 * @author admin
 */
public class DashboardDAO {

    // 2. Đếm số lượng theo bảng
    public int getCount(String table, String condition) {
        String sql = "SELECT COUNT(*) FROM " + table;
        if (condition != null && !condition.trim().isEmpty()) {
            sql += " WHERE " + condition;
        }
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
        return getRecentOrders(limit, null, null, null, "ADMIN");
    }

    public List<Order> getRecentOrders(int limit, String startDate, String endDate, Integer staffId, String staffRole) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.order_id, o.recipient_name, o.created_at, o.final_amount, o.status FROM orders o ";
        
        if ("DELIVERY".equals(staffRole)) {
            sql += " JOIN deliveries d ON o.order_id = d.order_id ";
        }
        
        sql += " WHERE 1=1 ";
        
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        if (hasDateFilter) {
            sql += " AND o.created_at BETWEEN ? AND ? ";
        }
        
        if (staffId != null) {
            if ("DELIVERY".equals(staffRole)) {
                sql += " AND d.staff_id = ? ";
            } else if ("SALE_STAFF".equals(staffRole)) {
                sql += " AND o.assigned_sale_staff_id = ? ";
            }
        }
        sql += "ORDER BY o.created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            if (hasDateFilter) {
                ps.setString(paramIndex++, startDate + " 00:00:00");
                ps.setString(paramIndex++, endDate + " 23:59:59");
            }
            if (staffId != null) {
                ps.setInt(paramIndex++, staffId);
            }
            ps.setInt(paramIndex++, limit);
            
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

    public List<dto.BestSellingProductDTO> getBestSellingProducts(int limit, String startDate, String endDate, Integer staffId) {
        List<dto.BestSellingProductDTO> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.name, pi.file_path, " +
                     "SUM(oi.quantity) as total_sold, " +
                     "SUM(oi.subtotal) as total_revenue, " +
                     "COUNT(DISTINCT o.order_id) as order_count " +
                     "FROM order_items oi " +
                     "JOIN orders o ON oi.order_id = o.order_id " +
                     "JOIN product_variants pv ON oi.variant_id = pv.variant_id " +
                     "JOIN products p ON pv.product_id = p.product_id " +
                     "LEFT JOIN product_images pi ON p.product_id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE o.status = 'DELIVERED' ";
                     
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        if (hasDateFilter) {
            sql += " AND o.created_at BETWEEN ? AND ? ";
        }
        
        if (staffId != null) {
            sql += " AND o.assigned_sale_staff_id = ? ";
        }
        
        sql += "GROUP BY p.product_id, p.name, pi.file_path " +
               "ORDER BY total_sold DESC " +
               "LIMIT ?";
                     
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (hasDateFilter) {
                ps.setString(paramIndex++, startDate + " 00:00:00");
                ps.setString(paramIndex++, endDate + " 23:59:59");
            }
            if (staffId != null) {
                ps.setInt(paramIndex++, staffId);
            }
            ps.setInt(paramIndex++, limit);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    dto.BestSellingProductDTO dto = new dto.BestSellingProductDTO();
                    dto.setProductId(rs.getInt("product_id"));
                    dto.setName(rs.getString("name"));
                    dto.setImageUrl(rs.getString("file_path"));
                    dto.setTotalSold(rs.getInt("total_sold"));
                    dto.setTotalRevenue(rs.getDouble("total_revenue"));
                    dto.setOrderCount(rs.getInt("order_count"));
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate, Integer staffId) {
        LinkedHashMap<String, Double> map = new LinkedHashMap<>();
        
        String sql = "SELECT DATE(created_at) as order_date, SUM(final_amount) as daily_revenue " +
                     "FROM orders WHERE status = 'DELIVERED'";
                     
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        if (hasDateFilter) {
            sql += " AND created_at BETWEEN ? AND ?";
        }
        
        if (staffId != null) {
            sql += " AND assigned_sale_staff_id = ?";
        }
        
        sql += " GROUP BY DATE(created_at) ORDER BY DATE(created_at) ASC";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (hasDateFilter) {
                ps.setString(paramIndex++, startDate + " 00:00:00");
                ps.setString(paramIndex++, endDate + " 23:59:59");
            }
            if (staffId != null) {
                ps.setInt(paramIndex++, staffId);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("order_date"), rs.getDouble("daily_revenue"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public LinkedHashMap<String, Integer> getOrderStatusStats(String startDate, String endDate, Integer staffId, String staffRole) {
        LinkedHashMap<String, Integer> map = new LinkedHashMap<>();
        
        String sql = "SELECT o.status, COUNT(*) as status_count FROM orders o ";
        
        if ("DELIVERY".equals(staffRole)) {
            sql += " JOIN deliveries d ON o.order_id = d.order_id ";
        }
        
        sql += " WHERE 1=1 ";
                     
        boolean hasDateFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());
        if (hasDateFilter) {
            sql += " AND o.created_at BETWEEN ? AND ?";
        }
        
        if (staffId != null) {
            if ("DELIVERY".equals(staffRole)) {
                sql += " AND d.staff_id = ?";
            } else if ("SALE_STAFF".equals(staffRole)) {
                sql += " AND o.assigned_sale_staff_id = ?";
            }
        }
        
        sql += " GROUP BY o.status";
        
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            int paramIndex = 1;
            if (hasDateFilter) {
                ps.setString(paramIndex++, startDate + " 00:00:00");
                ps.setString(paramIndex++, endDate + " 23:59:59");
            }
            if (staffId != null) {
                ps.setInt(paramIndex++, staffId);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("status"), rs.getInt("status_count"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }
}
