package controller.admin.promotion;

import model.Promotion;
import service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "PromotionEditServlet", urlPatterns = {"/admin/promotions/edit"})
public class PromotionEditServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String editId = req.getParameter("id");
        try {
            if (editId != null && !editId.trim().isEmpty()) {
                Promotion p = promotionService.getPromotionById(Integer.parseInt(editId));
                req.setAttribute("promo", p);
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi tải dữ liệu: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        }
    }
}