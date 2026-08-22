package controller.admin.promotion;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "PromotionStatusServlet", urlPatterns = {"/admin/promotions/status"})
public class PromotionStatusServlet extends PromotionServletSupport {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        try {
            int promoId = parseIntOrDefault(req.getParameter("promoId"), 0);
            String status = req.getParameter("status"); // ACTIVE hoặc INACTIVE
            boolean isActive = "ACTIVE".equalsIgnoreCase(status);
            
            promotionService.toggleStatus(promoId, isActive);
            redirectToPromotionListWithMessage(req, resp, FLASH_SUCCESS_KEY, "Cập nhật trạng thái thành công.");
            
        } catch (Exception ex) {
            getServletContext().log("Lỗi DB tại PromotionStatusServlet", ex);
            redirectToPromotionListWithMessage(req, resp, FLASH_ERROR_KEY, "Cập nhật thất bại: " + ex.getMessage());
        }
    }
}