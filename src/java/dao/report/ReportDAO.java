package dao.report;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;

public class ReportDAO {

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
}
