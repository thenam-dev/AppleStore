package controller.admin.dashboard;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminReportServlet", urlPatterns = {"/admin/report"})
public class AdminReportServlet extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet AdminReportServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AdminReportServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        service.report.ReportService service = new service.report.ReportService();
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        
        java.util.LinkedHashMap<String, Double> revenueMap = service.getRevenueByDate(startDate, endDate);
        
        double totalRev = 0;
        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");

        for (java.util.Map.Entry<String, Double> entry : revenueMap.entrySet()) {
            totalRev += entry.getValue();
            labels.append("'").append(entry.getKey()).append("',");
            data.append(entry.getValue()).append(",");
        }

        if (labels.length() > 1) {
            labels.setLength(labels.length() - 1);
            data.setLength(data.length() - 1);
        }
        labels.append("]");
        data.append("]");

        request.setAttribute("totalRevenue", totalRev);
        request.setAttribute("chartLabels", labels.toString());
        request.setAttribute("chartData", data.toString());

        request.setAttribute("adminSidebarTitle", "Báo cáo doanh thu");
        request.setAttribute("adminSidebarDescription", "Phân tích doanh thu và biểu đồ bán hàng.");
        request.setAttribute("adminSidebarActive", "report");

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard-report/report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Admin Report Servlet";
    }

}
