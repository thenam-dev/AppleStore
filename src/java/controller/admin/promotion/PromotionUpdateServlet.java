package controller.admin.promotion;

import model.entity.promtion.Promotion;
import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PromotionUpdateServlet", urlPatterns = {"/admin/promotions/update"})
public class PromotionUpdateServlet extends PromotionServletSupport {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); // BẮT BUỘC: AppleStore Rule 3
        Promotion p = new Promotion();

        try {
            p.setPromoId(parseIntOrDefault(req.getParameter("promoId"), 0));
            p.setCode(req.getParameter("code"));
            p.setDiscountType(req.getParameter("discountType"));
            p.setBenefitTarget(req.getParameter("benefitTarget"));
            p.setScope(req.getParameter("scope"));
            p.setDiscountValue(parseBigDecimal(req.getParameter("discountValue")));
            p.setDiscountMax(parseBigDecimal(req.getParameter("discountMax")));
            p.setMinOrderValue(parseBigDecimal(req.getParameter("minOrderValue")));
            
            String maxUses = req.getParameter("maxUses");
            p.setMaxUses(maxUses != null && !maxUses.isBlank() ? parseIntOrDefault(maxUses, 0) : null);

            // Mảng Options
            p.setCategoryIds(parseIdList(req.getParameterValues("categoryIds")));
            p.setProductIds(parseIdList(req.getParameterValues("productIds")));

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            String validFromStr = req.getParameter("validFrom");
            String validUntilStr = req.getParameter("validUntil");
            p.setValidFrom(validFromStr != null && !validFromStr.isBlank() ? LocalDateTime.parse(validFromStr, formatter) : null);
            p.setValidUntil(validUntilStr != null && !validUntilStr.isBlank() ? LocalDateTime.parse(validUntilStr, formatter) : null);

            p.setIsActive("ACTIVE".equalsIgnoreCase(req.getParameter("status")));

            if (p.getPromoId() > 0) {
                promotionService.updatePromotion(p);
                redirectToPromotionListWithMessage(req, resp, FLASH_SUCCESS_KEY, "Cập nhật mã khuyến mãi thành công.");
            } else {
                User loggedInAdmin = (User) req.getSession().getAttribute("loggedInUser");
                int adminId = (loggedInAdmin != null) ? loggedInAdmin.getUserId() : 1;
                promotionService.createPromotion(p, adminId);
                redirectToPromotionListWithMessage(req, resp, FLASH_SUCCESS_KEY, "Tạo mã khuyến mãi thành công.");
            }

        } catch (IllegalArgumentException | DateTimeParseException ex) {
            forwardErrorToForm(req, resp, p, ex instanceof DateTimeParseException ? "Định dạng ngày tháng không hợp lệ." : ex.getMessage());
        } catch (Exception ex) {
            getServletContext().log("Lỗi tại PromotionUpdateServlet", ex);
            forwardErrorToForm(req, resp, p, "Lỗi hệ thống: " + ex.getMessage());
        }
    }

    private void forwardErrorToForm(HttpServletRequest req, HttpServletResponse resp, Promotion p, String errorMessage) throws ServletException, IOException {
        req.setAttribute(FLASH_ERROR_KEY, errorMessage);
        req.setAttribute("promo", p);
        
        if (p.getValidFrom() != null) req.setAttribute("validFromStr", p.getValidFrom().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        if (p.getValidUntil() != null) req.setAttribute("validUntilStr", p.getValidUntil().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));

        setPromotionFormOptions(req);
        req.getRequestDispatcher(FORM_VIEW).forward(req, resp);
    }

    private BigDecimal parseBigDecimal(String value) {
        if (value == null || value.isBlank()) return BigDecimal.ZERO;
        try { return new BigDecimal(value.trim()); } catch (NumberFormatException e) { return BigDecimal.ZERO; }
    }

    private List<Integer> parseIdList(String[] values) {
        List<Integer> ids = new ArrayList<>();
        if (values != null) {
            for (String s : values) {
                int id = parseIntOrDefault(s, 0);
                if (id > 0) ids.add(id);
            }
        }
        return ids;
    }
}