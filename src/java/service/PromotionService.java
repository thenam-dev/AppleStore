package service;

import dao.PromotionDAO;
import model.Promotion;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

public class PromotionService {
    
    private final PromotionDAO promotionDAO = new PromotionDAO();

    public List<Promotion> getAllPromotions() throws SQLException {
        return promotionDAO.findAll();
    }

    public Promotion getPromotionById(int id) throws SQLException {
        return promotionDAO.findById(id);
    }

    public void createPromotion(Promotion promo, int adminId) throws SQLException {
        validatePromotion(promo);
        
        // Ensure code uniqueness
        Promotion existing = promotionDAO.findByCode(promo.getCode());
        if (existing != null) {
            throw new IllegalArgumentException("Mã khuyến mãi đã tồn tại.");
        }
        
        promo.setCreatedBy(adminId);
        promotionDAO.insert(promo);
    }

    public void updatePromotion(Promotion promo) throws SQLException {
        validatePromotion(promo);
        
        Promotion existing = promotionDAO.findByCode(promo.getCode());
        if (existing != null && existing.getPromoId() != promo.getPromoId()) {
            throw new IllegalArgumentException("Mã khuyến mãi này đang được sử dụng cho một chương trình khác.");
        }
        
        promotionDAO.update(promo);
    }

    public void deletePromotion(int id) throws SQLException {
        promotionDAO.softDelete(id);
    }

    public void toggleStatus(int id, boolean isActive) throws SQLException {
        promotionDAO.toggleStatus(id, isActive);
    }

    private void validatePromotion(Promotion promo) {
        if (promo.getCode() == null || promo.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Mã giảm giá không được để trống.");
        }
        if (promo.getDiscountValue() == null || promo.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá trị giảm giá phải lớn hơn 0.");
        }
        if (promo.getValidFrom() == null || promo.getValidUntil() == null || promo.getValidFrom().isAfter(promo.getValidUntil())) {
            throw new IllegalArgumentException("Thời gian hiệu lực không hợp lệ.");
        }
        if ("PRODUCT".equalsIgnoreCase(promo.getScope()) && promo.getProductId() == null) {
            throw new IllegalArgumentException("Phạm vi theo sản phẩm phải chọn Sản phẩm áp dụng.");
        }
        promo.setCode(promo.getCode().trim().toUpperCase());
    }
    
    public long getTotalRedeemedCount() throws SQLException {
        return promotionDAO.sumTotalRedeemed();
    }

    public int getExpiringSoonCount() throws SQLException {
        return promotionDAO.countExpiringSoon();
    }

    // =========================================================================
    // TODO: PHẦN DÀNH CHO CHECKOUT/CART SẼ CODE SAU
    // =========================================================================
    
    /**
     * Dùng để kiểm tra voucher hợp lệ khi người dùng nhập mã ở giỏ hàng
     */
    public Promotion validateCouponForCheckout(String code, BigDecimal cartSubtotal) throws SQLException {
        // Code implementation for later:
        // 1. Find by code
        // 2. Check ValidFrom, ValidUntil
        // 3. Check min_order_value <= cartSubtotal
        // 4. Check used_count < max_uses
        return null;
    }
    
    /**
     * Tính toán số tiền thực tế được giảm dựa trên loại % hay Giá tiền cố định
     */
    public BigDecimal calculateDiscountAmount(Promotion promo, BigDecimal baseAmount) {
        // Code implementation for later...
        return BigDecimal.ZERO;
    }
}