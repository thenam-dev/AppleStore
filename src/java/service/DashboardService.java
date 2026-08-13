/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.DashboardDAO;
import model.DashboardStats;

/**
 *
 * @author admin
 */
public class DashboardService {

    private DashboardDAO dashboardDAO = new DashboardDAO();

    public DashboardStats getDashboardStats(String startDate, String endDate) {
        DashboardStats stats = new DashboardStats();
        stats.setTotalOrders(dashboardDAO.getCount("orders", "1=1", startDate, endDate));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'", startDate, endDate));
        stats.setTotalCustomers(dashboardDAO.getCount("users", "role = 'CUSTOMER'", startDate, endDate));
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", "status IN ('PENDING_PAYMENT', 'APPROVED')", startDate, endDate));
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')", startDate, endDate));
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", "status = 'DELIVERED'", startDate, endDate));
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')", startDate, endDate));

        return stats;

    }

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate) {
        return dashboardDAO.getRevenueByDate(startDate, endDate);
    }

    public java.util.List<model.Order> getRecentOrders(int limit, String startDate, String endDate) {
        return dashboardDAO.getRecentOrders(limit, startDate, endDate);
    }
}
