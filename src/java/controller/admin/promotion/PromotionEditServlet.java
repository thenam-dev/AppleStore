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

@WebServlet(name = "PromotionEditServlet", urlPatterns = {"/admin/promotions/edit"})
public class PromotionEditServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Category> categories = new ArrayList<>(); 
            List<Product> products = new ArrayList<>();    
            req.setAttribute("categories", categories);
            req.setAttribute("products", products);

            String editId = req.getParameter("id");
            boolean isEdit = false;
            Promotion p = new Promotion();

            if (editId != null && !editId.trim().isEmpty()) {
                Promotion existingPromo = promotionService.getPromotionById(Integer.parseInt(editId));
                if (existingPromo != null) {
                    p = existingPromo;
                    isEdit = true;
                    
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                    if (p.getValidFrom() != null) {
                        req.setAttribute("validFromStr", p.getValidFrom().format(formatter));
                    }
                    if (p.getValidUntil() != null) {
                        req.setAttribute("validUntilStr", p.getValidUntil().format(formatter));
                    }
                } else {
                    req.setAttribute("errorMessage", "[BE] Không tìm thấy mã khuyến mãi yêu cầu.");
                }
            }
            
            req.setAttribute("promo", p);
            req.setAttribute("isEdit", isEdit);
            
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);

        } catch (NumberFormatException numEx) {
            req.setAttribute("errorMessage", "[BE] Định dạng ID không hợp lệ.");
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi DB tại PromotionEditServlet", sqlEx);
            req.setAttribute("errorMessage", "[BE] Lỗi kết nối DB: " + sqlEx.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        }
    }
}