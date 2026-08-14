package service.report;

import dao.report.ReportDAO;

public class ReportService {

    private ReportDAO reportDAO = new ReportDAO();

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate) {
        return reportDAO.getRevenueByDate(startDate, endDate, null);
    }

    public java.util.LinkedHashMap<String, Double> getRevenueByDate(String startDate, String endDate, Integer staffId) {
        return reportDAO.getRevenueByDate(startDate, endDate, staffId);
    }
}
