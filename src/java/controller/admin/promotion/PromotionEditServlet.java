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
//    private final ProductService productService = new ProductService();
//    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Truyền danh sách sản phẩm sang JSP để làm dropdown
//            req.setAttribute("products", productService.getAllProducts());
//            req.setAttribute("categories", categoryDAO.getAllCategories());

            String editId = req.getParameter("id");
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
