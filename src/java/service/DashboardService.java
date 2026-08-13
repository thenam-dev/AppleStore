/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.DashboardDAO;
import model.DashboardStats;
import model.entity.order.Order;

/**
 *
 * @author admin
 */
public class DashboardService {

    private DashboardDAO dashboardDAO = new DashboardDAO();

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        stats.setTotalRevenue(dashboardDAO.getTotalRevenue());
        stats.setTotalOrders(dashboardDAO.getCount("orders", "1=1"));
        stats.setActiveProducts(dashboardDAO.getCount("products", "status = 'ACTIVE'"));
        stats.setTotalCustomers(dashboardDAO.getCount("users", "role = 'CUSTOMER'"));
        stats.setPendingOrdersCount(dashboardDAO.getCount("orders", "status IN ('PENDING_PAYMENT', 'APPROVED')"));
        stats.setShippingOrdersCount(dashboardDAO.getCount("orders", "status IN ('CONFIRMED', 'PREPARING', 'DISPATCHED')"));
        stats.setDeliveredOrdersCount(dashboardDAO.getCount("orders", "status = 'DELIVERED'"));
        stats.setCancelledOrdersCount(dashboardDAO.getCount("orders", "status IN ('CANCELLED', 'PAYMENT_FAILED', 'EXPIRED')"));

        return stats;

    }

<<<<<<< Updated upstream
    public java.util.List<model.Order> getRecentOrders(int limit) {
        return dashboardDAO.getRecentOrders(limit);
=======
    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate) {
        return dashboardDAO.getRevenueByDate(startDate, endDate);
    }

    public java.util.List<Order> getRecentOrders(int limit, String startDate, String endDate) {
        return dashboardDAO.getRecentOrders(limit, startDate, endDate);
>>>>>>> Stashed changes
    }
}
