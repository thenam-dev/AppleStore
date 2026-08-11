package controller.admin.promotion;

import model.Promotion;
import service.PromotionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet(name = "PromotionUpdateServlet", urlPatterns = {"/admin/promotions/update"})
public class PromotionUpdateServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Promotion p = new Promotion();
            String idStr = req.getParameter("promoId");
            if (idStr != null && !idStr.trim().isEmpty()) {
                p.setPromoId(Integer.parseInt(idStr));
            }
            
            p.setCode(req.getParameter("code"));
            p.setDiscountType(req.getParameter("discountType"));
            p.setDiscountValue(new BigDecimal(req.getParameter("discountValue")));
            
            String maxDiscount = req.getParameter("discountMax");
            if (maxDiscount != null && !maxDiscount.trim().isEmpty()) {
                p.setDiscountMax(new BigDecimal(maxDiscount));
            }
            
            String minOrder = req.getParameter("minOrderValue");
            if (minOrder != null && !minOrder.trim().isEmpty()) {
                p.setMinOrderValue(new BigDecimal(minOrder));
            }
            
            p.setScope(req.getParameter("scope"));
            p.setBenefitTarget(req.getParameter("benefitTarget"));
            
            String maxUses = req.getParameter("maxUses");
            if (maxUses != null && !maxUses.trim().isEmpty()) {
                p.setMaxUses(Integer.parseInt(maxUses));
            }
            
            p.setCanStack(req.getParameter("canStack") != null);
            p.setActive(req.getParameter("isActive") != null);
            
            p.setValidFrom(LocalDateTime.parse(req.getParameter("validFrom"), FORMATTER));
            p.setValidUntil(LocalDateTime.parse(req.getParameter("validUntil"), FORMATTER));

            // TODO: Lấy ID của Admin từ User Session (Tạm fix cứng ID = 1)
            int adminId = 1; 

            if (p.getPromoId() > 0) {
                promotionService.updatePromotion(p);
            } else {
                promotionService.createPromotion(p, adminId);
            }
            
            resp.sendRedirect(req.getContextPath() + "/admin/promotions");
        } catch (Exception e) {
            // Khi có lỗi validation hoặc DB, set thuộc tính và forward lại form
            req.setAttribute("errorMessage", "Thao tác thất bại: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        }
    }
}