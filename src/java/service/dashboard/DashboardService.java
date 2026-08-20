/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service.dashboard;

import dao.dashboard.DashboardDAO;
import dto.DashboardStatsDTO;

/**
 *
 * @author admin
 */
public class DashboardService {

    private DashboardDAO dashboardDAO = new DashboardDAO();


    public Integer extractStaffId(model.entity.user.User user) {
        if (user != null && 
           (config.AppConfig.ROLE_SALE_STAFF.equals(user.getRole()) || "DELIVERY".equals(user.getRole()))) {
            return user.getUserId();
        }
        return null;
    }

    public DashboardStatsDTO getDashboardStats(String startDate, String endDate, model.entity.user.User user) {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        
        String staffRole = (user != null && user.getRole() != null) ? user.getRole() : "ADMIN";
        Integer staffId = extractStaffId(user);
        
        // --- XỬ LÝ RIÊNG CHO SHIPPER (Dùng bảng deliveries) ---
        if ("DELIVERY".equals(staffRole)) {
            java.util.List<String> deliveryConditionsList = new java.util.ArrayList<>();
            deliveryConditionsList.add("staff_id = " + staffId);
            
            if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
                String dateFilter = "order_id IN (SELECT order_id FROM orders WHERE created_at BETWEEN '" + startDate + " 00:00:00' AND '" + endDate + " 23:59:59')";
                deliveryConditionsList.add(dateFilter);
            }
            String baseCond = String.join(" AND ", deliveryConditionsList);
            
            stats.setTotalOrders(dashboardDAO.getCount("deliveries", baseCond));
            stats.setPendingOrdersCount(dashboardDAO.getCount("deliveries", "status IN ('ASSIGNED', 'PICKED_UP', 'IN_TRANSIT') AND " + baseCond));
            stats.setDeliveredOrdersCount(dashboardDAO.getCount("deliveries", "status = 'DELIVERED' AND " + baseCond));
            stats.setCancelledOrdersCount(dashboardDAO.getCount("deliveries", "status IN ('FAILED', 'CANCELLED') AND " + baseCond));
            
            stats.setShippingOrdersCount(0);
            stats.setActiveProducts(0);
            stats.setTotalUsers(0);
            stats.setTotalRevenue(0);
            return stats;
        }

        // --- XỬ LÝ CHO ADMIN VÀ SALE_STAFF (Dùng bảng orders) ---
        java.util.List<String> orderConditionsList = new java.util.ArrayList<>();
        java.util.List<String> userConditionsList = new java.util.ArrayList<>();
        
        if (staffId != null) {
            orderConditionsList.add("assigned_sale_staff_id = " + staffId);
        }
        
        if (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty()) {
            String dateFilter = "created_at BETWEEN '" + startDate + " 00:00:00' AND '" + endDate + " 23:59:59'";
            orderConditionsList.add(dateFilter);
            userConditionsList.add(dateFilter); // Đếm user đăng ký trong khoảng thời gian này
        }
        
        String baseOrderCond = orderConditionsList.isEmpty() ? "" : String.join(" AND ", orderConditionsList);
        String baseUserCond = userConditionsList.isEmpty() ? "" : String.join(" AND ", userConditionsList);

        stats.setTotalOrders(dashboardDAO.getCount("orders", baseOrderCond));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'"));
        stats.setTotalUsers(dashboardDAO.getCount("users", baseUserCond));
        
        String pendingStatus = "status IN ('PENDING_PAYMENT', 'APPROVED')";
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", baseOrderCond.isEmpty() ? pendingStatus : pendingStatus + " AND " + baseOrderCond));
        
        String shippingStatus = "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')";
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", baseOrderCond.isEmpty() ? shippingStatus : shippingStatus + " AND " + baseOrderCond));
        
        String deliveredStatus = "status = 'DELIVERED'";
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", baseOrderCond.isEmpty() ? deliveredStatus : deliveredStatus + " AND " + baseOrderCond));
        
        String cancelledStatus = "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')";
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", baseOrderCond.isEmpty() ? cancelledStatus : cancelledStatus + " AND " + baseOrderCond));

        // Tính tổng doanh thu theo filter
        java.util.LinkedHashMap<String, Double> revenueMap = dashboardDAO.getRevenueByDate(startDate, endDate, staffId);
        double totalRev = 0;
        for (Double dailyRev : revenueMap.values()) {
            totalRev += dailyRev;
        }
        stats.setTotalRevenue(totalRev);

        return stats;

    }


    public java.util.List<model.entity.order.Order> getRecentOrders(int limit, String startDate, String endDate, model.entity.user.User user) {
        String staffRole = (user != null && user.getRole() != null) ? user.getRole() : "ADMIN";
        Integer staffId = extractStaffId(user);
        return dashboardDAO.getRecentOrders(limit, startDate, endDate, staffId, staffRole);
    }
    
    public java.util.List<dto.BestSellingProductDTO> getBestSellingProducts(int limit, String startDate, String endDate, model.entity.user.User user) {
        String staffRole = (user != null && user.getRole() != null) ? user.getRole() : "ADMIN";
        Integer staffId = extractStaffId(user);
        // Shipper không cần xem sản phẩm bán chạy
        if ("DELIVERY".equals(staffRole)) return new java.util.ArrayList<>();
        return dashboardDAO.getBestSellingProducts(limit, startDate, endDate, staffId);
    }

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate, model.entity.user.User user) {
        String staffRole = (user != null && user.getRole() != null) ? user.getRole() : "ADMIN";
        Integer staffId = extractStaffId(user);
        if ("DELIVERY".equals(staffRole)) return new java.util.LinkedHashMap<>();
        return dashboardDAO.getRevenueByDate(startDate, endDate, staffId);
    }

    public java.util.LinkedHashMap<String, Integer> getOrderStatusStats(String startDate, String endDate, model.entity.user.User user) {
        String staffRole = (user != null && user.getRole() != null) ? user.getRole() : "ADMIN";
        Integer staffId = extractStaffId(user);
        return dashboardDAO.getOrderStatusStats(startDate, endDate, staffId, staffRole);
    }
}
