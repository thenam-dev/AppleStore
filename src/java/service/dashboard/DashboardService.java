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

    public DashboardStatsDTO getDashboardStats() {
        return getDashboardStats(null);
    }

    public DashboardStatsDTO getDashboardStats(Integer staffId) {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        String orderCondition = null;
        if (staffId != null) {
            orderCondition = "assigned_sale_staff_id = " + staffId;
        }

        stats.setTotalOrders(dashboardDAO.getCount("orders", orderCondition));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'"));
        stats.setTotalUsers(dashboardDAO.getCount("users", ""));
        
        String pendingStatus = "status IN ('PENDING_PAYMENT', 'APPROVED')";
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", staffId == null ? pendingStatus : pendingStatus + " AND " + orderCondition));
        
        String shippingStatus = "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')";
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", staffId == null ? shippingStatus : shippingStatus + " AND " + orderCondition));
        
        String deliveredStatus = "status = 'DELIVERED'";
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", staffId == null ? deliveredStatus : deliveredStatus + " AND " + orderCondition));
        
        String cancelledStatus = "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')";
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", staffId == null ? cancelledStatus : cancelledStatus + " AND " + orderCondition));

        // Tính tổng doanh thu
        java.util.LinkedHashMap<String, Double> revenueMap = dashboardDAO.getRevenueByDate(null, null, staffId);
        double totalRev = 0;
        for (Double dailyRev : revenueMap.values()) {
            totalRev += dailyRev;
        }
        stats.setTotalRevenue(totalRev);

        return stats;

    }


    public java.util.List<model.entity.order.Order> getRecentOrders(int limit) {
        return getRecentOrders(limit, null);
    }

    public java.util.List<model.entity.order.Order> getRecentOrders(int limit, Integer staffId) {
        return dashboardDAO.getRecentOrders(limit, staffId);
    }
    
    public java.util.List<dto.BestSellingProductDTO> getBestSellingProducts(int limit) {
        return getBestSellingProducts(limit, null);
    }

    public java.util.List<dto.BestSellingProductDTO> getBestSellingProducts(int limit, Integer staffId) {
        return dashboardDAO.getBestSellingProducts(limit, staffId);
    }

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate) {
        return dashboardDAO.getRevenueByDate(startDate, endDate, null);
    }

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate, Integer staffId) {
        return dashboardDAO.getRevenueByDate(startDate, endDate, staffId);
    }
}
