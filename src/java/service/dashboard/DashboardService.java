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
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalOrders(dashboardDAO.getCount("orders", "1=1"));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'"));
        stats.setTotalUsers(dashboardDAO.getCount("users", "1=1"));
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", "status IN ('PENDING_PAYMENT', 'APPROVED')"));
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')"));
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", "status = 'DELIVERED'"));
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')"));

        // Tái sử dụng hàm getRevenueByDate của ReportService để tính tổng doanh thu
        service.report.ReportService reportService = new service.report.ReportService();
        java.util.LinkedHashMap<String, Double> revenueMap = reportService.getRevenueByDate(null, null);
        double totalRev = 0;
        for (Double dailyRev : revenueMap.values()) {
            totalRev += dailyRev;
        }
        stats.setTotalRevenue(totalRev);

        return stats;

    }


    public java.util.List<model.entity.order.Order> getRecentOrders(int limit) {
        return dashboardDAO.getRecentOrders(limit);
    }
    
    public java.util.List<dto.BestSellingProductDTO> getBestSellingProducts(int limit) {
        return dashboardDAO.getBestSellingProducts(limit);
    }
}
