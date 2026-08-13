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
        
        // Lấy dữ liệu tổng quan
        dto.DashboardStatsDTO stats = service.getDashboardStats();

        // Bắn sang JSP
        request.setAttribute("stats", stats);
        request.setAttribute("recentOrders", service.getRecentOrders(4));
        request.setAttribute("bestSellingProducts", service.getBestSellingProducts(3));

        // Set các biến Sidebar
        request.setAttribute("adminSidebarActive", "dashboard");

        // Forward sang file JSP
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-report/dashboard.jsp").forward(request, response);
    }

}
