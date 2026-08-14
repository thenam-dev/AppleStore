package controller.customer.cart;

import model.entity.promtion.Promotion;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "VoucherListServlet", urlPatterns = {"/vouchers"})
public class VoucherListServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Lấy danh sách mã khả dụng
            List<Promotion> vouchers = promotionService.getAvailableVouchersForCart();
            req.setAttribute("vouchers", vouchers);
            
            // Chuyển hướng sang giao diện chọn mã
            req.getRequestDispatcher("/WEB-INF/views/customer/voucher-list.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.getSession().setAttribute("errorMsg", "Lỗi khi tải danh sách mã giảm giá.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
        }
    }
}