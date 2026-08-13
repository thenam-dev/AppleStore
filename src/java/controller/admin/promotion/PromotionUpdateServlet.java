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
        Promotion p = new Promotion(); // Khởi tạo sẵn để nếu có lỗi thì đẩy lại dữ liệu về form

        try {
            String promoIdStr = req.getParameter("promoId");
            if (promoIdStr != null && !promoIdStr.isBlank()) {
                p.setPromoId(Integer.parseInt(promoIdStr));
            }

            p.setCode(req.getParameter("code"));
            p.setDiscountType(req.getParameter("discountType"));
            p.setDiscountValue(new BigDecimal(req.getParameter("discountValue")));

            String discountMaxStr = req.getParameter("discountMax");
            p.setDiscountMax(discountMaxStr != null && !discountMaxStr.isBlank() ? new BigDecimal(discountMaxStr) : BigDecimal.ZERO);

            String minOrderStr = req.getParameter("minOrderValue");
            p.setMinOrderValue(minOrderStr != null && !minOrderStr.isBlank() ? new BigDecimal(minOrderStr) : BigDecimal.ZERO);

            p.setBenefitTarget(req.getParameter("benefitTarget"));

            String maxUsesStr = req.getParameter("maxUses");
            p.setMaxUses(maxUsesStr != null && !maxUsesStr.isBlank() ? Integer.parseInt(maxUsesStr) : null);

            String scope = req.getParameter("scope");
            p.setScope(scope);

            String categoryIdStr = req.getParameter("categoryId");
            String productIdStr = req.getParameter("productId");

            if ("CATEGORY".equals(scope) && categoryIdStr != null && !categoryIdStr.isBlank()) {
                p.setCategoryId(Integer.parseInt(categoryIdStr));
                p.setProductId(null);
            } else if ("PRODUCT".equals(scope) && productIdStr != null && !productIdStr.isBlank()) {
                p.setProductId(Integer.parseInt(productIdStr));
                p.setCategoryId(null);
            } else {
                p.setCategoryId(null);
                p.setProductId(null);
            }

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            p.setValidFrom(LocalDateTime.parse(req.getParameter("validFrom"), formatter));
            p.setValidUntil(LocalDateTime.parse(req.getParameter("validUntil"), formatter));

            p.setCanStack(req.getParameter("canStack") != null);
            p.setIsActive(req.getParameter("isActive") != null);

            // Xử lý lưu Database
            if (p.getPromoId() > 0) {
                promotionService.updatePromotion(p);
            } else {
                // Thay dòng int adminId = 1; bằng:
                User loggedInAdmin = (User) req.getSession().getAttribute("loggedInUser");
                int adminId = (loggedInAdmin != null) ? loggedInAdmin.getUserId() : 1;
                promotionService.createPromotion(p, adminId);
            }

            resp.sendRedirect(req.getContextPath() + "/admin/promotions");

        } catch (NumberFormatException numEx) {
            forwardErrorToForm(req, resp, p, "Vui lòng nhập đúng định dạng số cho các trường: ID, số lượng, hoặc giá trị giảm.");
        } catch (DateTimeParseException dateEx) {
            forwardErrorToForm(req, resp, p, "Định dạng ngày tháng không hợp lệ.");
        } catch (IllegalArgumentException illEx) {
            // Đây chính là lỗi Validation (ví dụ trùng code) được ném ra từ PromotionService
            forwardErrorToForm(req, resp, p, illEx.getMessage());
        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi DB tại PromotionUpdateServlet", sqlEx);
            forwardErrorToForm(req, resp, p, "Lỗi khi lưu vào cơ sở dữ liệu: " + sqlEx.getMessage());
        }
    }

    // Hàm phụ trợ để tái cấu trúc lại Form khi có lỗi mà không làm mất dữ liệu người dùng đã gõ
    private void forwardErrorToForm(HttpServletRequest req, HttpServletResponse resp, Promotion p, String errorMessage) throws ServletException, IOException {
        req.setAttribute("errorMessage", errorMessage);
        req.setAttribute("promo", p);
        req.setAttribute("isEdit", p.getPromoId() > 0);

        // Push lại ngày giờ dạng chuỗi để input datetime-local hiển thị lại
        if (p.getValidFrom() != null) {
            req.setAttribute("validFromStr", p.getValidFrom().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        }
        if (p.getValidUntil() != null) {
            req.setAttribute("validUntilStr", p.getValidUntil().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
        }

        req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
    }
}
