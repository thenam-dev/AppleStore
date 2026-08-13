package controller.admin.promotion;

import service.promotion.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "PromotionListServlet", urlPatterns = {"/admin/promotions"})
public class PromotionListServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("promotions", promotionService.getAllPromotions());
            // Thêm 2 dòng này:
            req.setAttribute("totalRedeemed", promotionService.getTotalRedeemedCount());
            req.setAttribute("expiringSoon", promotionService.getExpiringSoonCount());
            
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        } catch (ServletException | IOException | SQLException e) {
            req.setAttribute("errorMessage", "Lỗi tải dữ liệu: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}