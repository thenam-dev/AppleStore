/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dto;

/**
 *
 * @author admin
 */
public class DashboardStatsDTO {

    private double totalRevenue;
    private int totalOrders;
    private int activeProducts;
    private int totalUsers;
    private int pendingOrdersCount;
    private int shippingOrdersCount;
    private int deliveredOrdersCount;
    private int cancelledOrdersCount;

    public DashboardStatsDTO() {
    }

    public DashboardStatsDTO(double totalRevenue, int totalOrders, int activeProducts, int totalUsers, int pendingOrdersCount, int shippingOrdersCount, int deliveredOrdersCount, int cancelledOrdersCount) {
        this.totalRevenue = totalRevenue;
        this.totalOrders = totalOrders;
        this.activeProducts = activeProducts;
        this.totalUsers = totalUsers;
        this.pendingOrdersCount = pendingOrdersCount;
        this.shippingOrdersCount = shippingOrdersCount;
        this.deliveredOrdersCount = deliveredOrdersCount;
        this.cancelledOrdersCount = cancelledOrdersCount;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public int getActiveProducts() {
        return activeProducts;
    }

    public void setActiveProducts(int activeProducts) {
        this.activeProducts = activeProducts;
    }

    public int getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(int totalUsers) {
        this.totalUsers = totalUsers;
    }

    public int getPendingOrdersCount() {
        return pendingOrdersCount;
    }

    public void setPendingOrdersCount(int pendingOrdersCount) {
        this.pendingOrdersCount = pendingOrdersCount;
    }

    public int getShippingOrdersCount() {
        return shippingOrdersCount;
    }

    public void setShippingOrdersCount(int shippingOrdersCount) {
        this.shippingOrdersCount = shippingOrdersCount;
    }

    public int getDeliveredOrdersCount() {
        return deliveredOrdersCount;
    }

    public void setDeliveredOrdersCount(int deliveredOrdersCount) {
        this.deliveredOrdersCount = deliveredOrdersCount;
    }

    public int getCancelledOrdersCount() {
        return cancelledOrdersCount;
    }

    public void setCancelledOrdersCount(int cancelledOrdersCount) {
        this.cancelledOrdersCount = cancelledOrdersCount;
    }

}
