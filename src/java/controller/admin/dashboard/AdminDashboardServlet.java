/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.admin.dashboard;

import java.io.IOException;
import java.io.PrintWriter;
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

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminDashboardServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminDashboardServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        service.DashboardService service = new service.DashboardService();
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        // 1. Lấy dữ liệu
        java.util.LinkedHashMap<String, Double> revenueMap = service.getRevenueByDate(startDate, endDate);
        model.DashboardStats stats = service.getDashboardStats(startDate, endDate);

        // TỰ CỘNG DỒN doanh thu lấy từ Biểu đồ để ra Tổng (Đỡ tốn 1 lần chọc DB)
        double totalRev = 0;
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");

        for (java.util.Map.Entry<String, Double> entry : revenueMap.entrySet()) {
            totalRev += entry.getValue(); // Cộng dồn tiền
            labels.append("'").append(entry.getKey()).append("',");
            data.append(entry.getValue()).append(",");
        }

        // Gán Tổng tiền vào stats
        stats.setTotalRevenue(totalRev);

        // Xóa dấu phẩy thừa ở cuối chuỗi JSON
        if (labels.length() > 1) {
            labels.setLength(labels.length() - 1);
            data.setLength(data.length() - 1);
        }
        labels.append("]");
        data.append("]");

        // Bắn hết sang JSP
        request.setAttribute("stats", stats);
        request.setAttribute("recentOrders", service.getRecentOrders(4, startDate, endDate));
        request.setAttribute("chartLabels", labels.toString());
        request.setAttribute("chartData", data.toString());

        // 2. Set các biến Sidebar (giống file UserListServlet) để hiển thị menu bên trái
        request.setAttribute("adminSidebarTitle", "Dashboard");
        request.setAttribute("adminSidebarDescription", "A clean snapshot of shop performance.");

        // 3. Forward sang file JSP
        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-report/dashboard.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
