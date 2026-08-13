package controller.admin.promotion;

import model.entity.promtion.Promotion;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "PromotionListServlet", urlPatterns = {"/admin/promotions"})
public class PromotionListServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. ĐỌC CÁC THAM SỐ TỪ URL (Làm đầu tiên)
            String keyword = req.getParameter("keyword");
            String statusFilter = req.getParameter("status"); // "1" (Active), "0" (Inactive)
            String sortCol = req.getParameter("sortCol");
            String sortDir = req.getParameter("sortDir");

            // 2. CẤU HÌNH PHÂN TRANG (PAGING)
            int page = 1;
            int pageSize = 10; // Số bản ghi trên 1 trang
            if (req.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(req.getParameter("page"));
                } catch (NumberFormatException ignored) {}
            }
            int offset = (page - 1) * pageSize;

            // 3. GỌI SERVICE ĐỂ LẤY DỮ LIỆU ĐÃ PHÂN TRANG & TÍNH TOÁN
            int totalRecords = promotionService.countAll(keyword, statusFilter);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            List<Promotion> promotions = promotionService.findAllWithPaging(keyword, statusFilter, sortCol, sortDir, offset, pageSize);

            // 4. LẤY SỐ LIỆU CHO KPI GRID
            // Tận dụng hàm countAll để đếm số lượng mã Active (Truyền keyword=null, status="1")
            int activeCount = promotionService.countAll(null, "1");
            long totalRedeemed = promotionService.getTotalRedeemedCount();
            int expiringSoon = promotionService.getExpiringSoonCount();

            // 5. ĐẨY DỮ LIỆU SANG JSP
            DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            req.setAttribute("dateFormatter", dateFormatter);

            req.setAttribute("promotions", promotions);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("sortCol", sortCol);
            req.setAttribute("sortDir", sortDir);

            req.setAttribute("activeCount", activeCount);
            req.setAttribute("totalRedeemed", totalRedeemed);
            req.setAttribute("expiringSoon", expiringSoon);

            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);

        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi cơ sở dữ liệu tại PromotionListServlet", sqlEx);
            req.setAttribute("errorMessage", "Lỗi truy xuất hệ thống cơ sở dữ liệu: " + sqlEx.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}