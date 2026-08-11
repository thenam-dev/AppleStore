package controller.admin.promotion;

import service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "PromotionStatusServlet", urlPatterns = {"/admin/promotions/status"})
public class PromotionStatusServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int promoId = Integer.parseInt(req.getParameter("promoId"));
            boolean isActive = Boolean.parseBoolean(req.getParameter("isActive")); // Truyền lên true/false
            
            promotionService.toggleStatus(promoId, isActive);
            
            resp.sendRedirect(req.getContextPath() + "/admin/promotions");
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Cập nhật trạng thái thất bại: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}