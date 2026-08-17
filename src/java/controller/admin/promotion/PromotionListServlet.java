package controller.admin.promotion;

import model.entity.promtion.Promotion;
import model.entity.catalog.Category;
import model.entity.catalog.Product;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PromotionListServlet", urlPatterns = {"/admin/promotions"})
public class PromotionListServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. Đọc tham số lọc & phân trang cho danh sách (Bảng bên trái)
            String keyword = req.getParameter("keyword");
            String statusFilter = req.getParameter("status");
            String sortCol = req.getParameter("sortCol");
            String sortDir = req.getParameter("sortDir");

            int page = 1;
            int pageSize = 10;
            if (req.getParameter("page") != null) {
                try { page = Integer.parseInt(req.getParameter("page")); } catch (NumberFormatException ignored) {}
            }
            int offset = (page - 1) * pageSize;

            int totalRecords = promotionService.countAll(keyword, statusFilter);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            List<Promotion> promotions = promotionService.findAllWithPaging(keyword, statusFilter, sortCol, sortDir, offset, pageSize);

            // 2. Số liệu KPI
            int activeCount = promotionService.countAll(null, "1");
            long totalRedeemed = promotionService.getTotalRedeemedCount();
            int expiringSoon = promotionService.getExpiringSoonCount();

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

            // 3. Khởi tạo dữ liệu cho Form (Panel bên phải - Mặc định là Tạo mới)
            req.setAttribute("isEdit", false);
            req.setAttribute("promo", new Promotion());
            
            List<Category> categories = new ArrayList<>();
            List<Product> products = new ArrayList<>();
            req.setAttribute("categories", categories);
            req.setAttribute("products", products);

            // Forward thẳng về list.jsp gộp chung
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);

        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi cơ sở dữ liệu tại PromotionListServlet", sqlEx);
            req.setAttribute("errorMessage", "[BE] Lỗi truy xuất cơ sở dữ liệu: " + sqlEx.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}