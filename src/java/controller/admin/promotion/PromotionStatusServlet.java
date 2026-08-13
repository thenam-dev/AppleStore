package controller.admin.promotion;

import service.promotion.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "PromotionStatusServlet", urlPatterns = {"/admin/promotions/status"})
public class PromotionStatusServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            int promoId = Integer.parseInt(req.getParameter("promoId"));
            boolean isActive = Boolean.parseBoolean(req.getParameter("isActive"));
            
            promotionService.toggleStatus(promoId, isActive);
            
            resp.sendRedirect(req.getContextPath() + "/admin/promotions");
            
        } catch (NumberFormatException numEx) {
            req.setAttribute("errorMessage", "Tham số cập nhật trạng thái không hợp lệ.");
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi DB tại PromotionStatusServlet", sqlEx);
            req.setAttribute("errorMessage", "Cập nhật trạng thái cơ sở dữ liệu thất bại: " + sqlEx.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}