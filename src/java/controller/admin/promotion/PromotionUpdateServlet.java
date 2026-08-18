package controller.admin.promotion;

import model.entity.promtion.Promotion;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import model.entity.user.User;

@WebServlet(name = "PromotionUpdateServlet", urlPatterns = {"/admin/promotions/update"})
public class PromotionUpdateServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Promotion p = new Promotion();
        try {
            String promoIdStr = req.getParameter("promoId");
            if (promoIdStr != null && !promoIdStr.isBlank()) {
                p.setPromoId(Integer.parseInt(promoIdStr));
            }

            p.setCode(req.getParameter("code"));
            p.setDiscountType(req.getParameter("discountType"));
            p.setBenefitTarget(req.getParameter("benefitTarget"));
            p.setScope(req.getParameter("scope"));

            p.setDiscountValue(parseBigDecimal(req.getParameter("discountValue")));
            p.setDiscountMax(parseBigDecimal(req.getParameter("discountMax")));
            p.setMinOrderValue(parseBigDecimal(req.getParameter("minOrderValue")));
            p.setMaxUses(parseIntegerNullable(req.getParameter("maxUses")));

            String scope = p.getScope();
            String categoryIdStr = req.getParameter("categoryId");
            String productIdStr = req.getParameter("productId");

            if ("CATEGORY".equals(scope)) {
                p.setCategoryId(parseIntegerNullable(categoryIdStr));
                p.setProductId(null);
            } else if ("PRODUCT".equals(scope)) {
                p.setProductId(parseIntegerNullable(productIdStr));
                p.setCategoryId(null);
            } else {
                p.setCategoryId(null);
                p.setProductId(null);
            }

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            String validFromStr = req.getParameter("validFrom");
            String validUntilStr = req.getParameter("validUntil");

            p.setValidFrom(validFromStr != null && !validFromStr.isBlank() ? LocalDateTime.parse(validFromStr, formatter) : null);
            p.setValidUntil(validUntilStr != null && !validUntilStr.isBlank() ? LocalDateTime.parse(validUntilStr, formatter) : null);

            // Xóa canStack theo yêu cầu
            p.setCanStack(false);
            p.setIsActive(req.getParameter("isActive") != null);

            if (p.getPromoId() > 0) {
                promotionService.updatePromotion(p);
            } else {
                User loggedInAdmin = (User) req.getSession().getAttribute("loggedInUser");
                int adminId = (loggedInAdmin != null) ? loggedInAdmin.getUserId() : 1;
                promotionService.createPromotion(p, adminId);
            }

            resp.sendRedirect(req.getContextPath() + "/admin/promotions");

        } catch (IllegalArgumentException illEx) {
            forwardErrorToForm(req, resp, p, illEx.getMessage());
        } catch (DateTimeParseException dateEx) {
            forwardErrorToForm(req, resp, p, "[BE] Định dạng ngày tháng không hợp lệ.");
        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi DB tại PromotionUpdateServlet", sqlEx);
            forwardErrorToForm(req, resp, p, "[BE] Lỗi DB: " + sqlEx.getMessage());
        } catch (Exception ex) {
            forwardErrorToForm(req, resp, p, "[BE] Lỗi hệ thống: " + ex.getMessage());
        }
    }

    private void forwardErrorToForm(HttpServletRequest req, HttpServletResponse resp, Promotion p, String errorMessage) throws ServletException, IOException {
        req.setAttribute("errorMessage", errorMessage);
        req.setAttribute("promo", p);
        req.setAttribute("isEdit", p.getPromoId() > 0);

        if (p.getValidFrom() != null) {
            req.setAttribute("validFromStr", p.getValidFrom().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        }
        if (p.getValidUntil() != null) {
            req.setAttribute("validUntilStr", p.getValidUntil().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        }

        req.setAttribute("categories", new java.util.ArrayList<>()); // Thay bằng load thật nếu cần
        req.setAttribute("products", new java.util.ArrayList<>());

        // Trả về trang FORM riêng
        req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
    }

    private BigDecimal parseBigDecimal(String value) {
        if (value == null || value.trim().isEmpty()) return BigDecimal.ZERO;
        try { return new BigDecimal(value.trim()); } 
        catch (NumberFormatException e) { return BigDecimal.ZERO; }
    }

    private Integer parseIntegerNullable(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try { return Integer.parseInt(value.trim()); } 
        catch (NumberFormatException e) { return null; }
    }
}