/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin.dashboard;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author admin
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        service.dashboard.DashboardService service = new service.dashboard.DashboardService();
        
        model.entity.user.User user = (model.entity.user.User) request.getSession().getAttribute(config.AppConfig.SESSION_USER);
        
        // Mặc định staffId = null. Khi truyền null xuống DAO, hệ thống sẽ lấy TẤT CẢ dữ liệu (Dành cho ADMIN)
        Integer staffId = null;
        
        if (user != null && config.AppConfig.ROLE_SALE_STAFF.equals(user.getRole())) {
            staffId = user.getUserId();
        }

        // Lấy dữ liệu tổng quan
        dto.DashboardStatsDTO stats = service.getDashboardStats(staffId);

        // Lấy dữ liệu báo cáo (Revenue Chart)
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        java.util.LinkedHashMap<String, Double> revenueMap = service.getRevenueByDate(startDate, endDate, staffId);
        
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");

        for (java.util.Map.Entry<String, Double> entry : revenueMap.entrySet()) {
            labels.append("'").append(entry.getKey()).append("',");
            data.append(entry.getValue()).append(",");
        }

        if (labels.length() > 1) {
            labels.setLength(labels.length() - 1);
            data.setLength(data.length() - 1);
        }
        labels.append("]");
        data.append("]");

        // Lấy dữ liệu thống kê trạng thái đơn hàng (Doughnut Chart)
        java.util.LinkedHashMap<String, Integer> statusStats = service.getOrderStatusStats(startDate, endDate, staffId);
        StringBuilder statusJson = new StringBuilder("[");
        for (java.util.Map.Entry<String, Integer> entry : statusStats.entrySet()) {
            statusJson.append("{\"status\":\"").append(entry.getKey()).append("\", \"count\":").append(entry.getValue()).append("},");
        }
        if (statusJson.length() > 1) {
            statusJson.setLength(statusJson.length() - 1);
        }
        statusJson.append("]");

        // Bắn sang JSP
        request.setAttribute("stats", stats);
        request.setAttribute("recentOrders", service.getRecentOrders(4, staffId));
        request.setAttribute("bestSellingProducts", service.getBestSellingProducts(10, staffId)); // Tăng lên 10 để xuất báo cáo
        request.setAttribute("chartLabels", labels.toString());
        request.setAttribute("chartData", data.toString());
        request.setAttribute("orderStatusStatsJson", statusJson.toString());

        // Set các biến Sidebar
        request.setAttribute("adminSidebarActive", "dashboard");

        // Forward sang file JSP
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-report/dashboard.jsp").forward(request, response);
    }

}
