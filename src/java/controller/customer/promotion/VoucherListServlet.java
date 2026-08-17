package controller.customer.promotion;

import model.entity.promtion.Promotion;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.time.format.DateTimeFormatter; // <-- THÊM THƯ VIỆN NÀY

@WebServlet(name = "VoucherListServlet", urlPatterns = {"/vouchers"})
public class VoucherListServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // Lấy danh sách mã khả dụng
            List<Promotion> vouchers = promotionService.getAvailableVouchersForCart();
            req.setAttribute("vouchers", vouchers);
            
            // --- THÊM DÒNG NÀY: Khởi tạo Formatter và đẩy sang JSP ---
            req.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
            
            // Chuyển hướng sang giao diện chọn mã
            req.getRequestDispatcher("/WEB-INF/views/customer/voucher-list.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "Chi tiết lỗi: " + e.toString());
            resp.sendRedirect(req.getContextPath() + "/checkout");
        }
    }
}