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

    public DashboardStatsDTO getDashboardStats(String startDate, String endDate) {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setTotalOrders(dashboardDAO.getCount("orders", "1=1", startDate, endDate));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'", startDate, endDate));
        stats.setTotalUsers(dashboardDAO.getCount("users", "1=1", startDate, endDate));
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", "status IN ('PENDING_PAYMENT', 'APPROVED')", startDate, endDate));
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')", startDate, endDate));
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", "status = 'DELIVERED'", startDate, endDate));
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')", startDate, endDate));

        // Tái sử dụng hàm getRevenueByDate của ReportService để tính tổng doanh thu
        service.report.ReportService reportService = new service.report.ReportService();
        java.util.LinkedHashMap<String, Double> revenueMap = reportService.getRevenueByDate(startDate, endDate);
        double totalRev = 0;
        for (Double dailyRev : revenueMap.values()) {
            totalRev += dailyRev;
        }
        stats.setTotalRevenue(totalRev);

        return stats;

    }


    public java.util.List<model.entity.order.Order> getRecentOrders(int limit, String startDate, String endDate) {
        return dashboardDAO.getRecentOrders(limit, startDate, endDate);
    }
    
    public java.util.List<dto.BestSellingProductDTO> getBestSellingProducts(int limit) {
        return dashboardDAO.getBestSellingProducts(limit);
    }
}
