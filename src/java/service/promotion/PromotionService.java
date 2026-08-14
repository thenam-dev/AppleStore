package service.promotion;

import dao.promtion.PromotionDAO;
import model.entity.promtion.Promotion;
import java.sql.Connection;
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
            throw new IllegalArgumentException("Mã giảm giá không được để trống hoặc chỉ chứa khoảng trắng.");
        }
        // VALIDATE LENGTH ĐỂ TRÁNH LỖI DB
        if (promo.getCode().trim().length() > 50) {
            throw new IllegalArgumentException("Mã giảm giá không được vượt quá 50 ký tự.");
        }

        if (promo.getDiscountValue() == null || promo.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá trị giảm giá phải lớn hơn 0.");
        }
        // MAX LIMIT CHO DECIMAL(10,2)
        if (promo.getDiscountValue().compareTo(new BigDecimal("99999999.99")) > 0) {
            throw new IllegalArgumentException("Giá trị giảm giá quá lớn, vượt mức cho phép.");
        }

        if (promo.getValidFrom() == null || promo.getValidUntil() == null || promo.getValidFrom().isAfter(promo.getValidUntil())) {
            throw new IllegalArgumentException("Thời gian hiệu lực không hợp lệ (Ngày kết thúc phải sau ngày bắt đầu).");
        }
        if ("PRODUCT".equalsIgnoreCase(promo.getScope()) && promo.getProductId() == null) {
            throw new IllegalArgumentException("Phạm vi theo sản phẩm bắt buộc phải chọn Sản phẩm áp dụng.");
        }
        promo.setCode(promo.getCode().trim().toUpperCase());
    }

    public long getTotalRedeemedCount() throws SQLException {
        return promotionDAO.sumTotalRedeemed();
    }

    public int getExpiringSoonCount() throws SQLException {
        return promotionDAO.countExpiringSoon();
    }
    
    public int countAll(String keyword, String statusFilter) throws SQLException {
        return promotionDAO.countAll(keyword, statusFilter);
    }

    public List<Promotion> findAllWithPaging(String keyword, String statusFilter, String sortCol, String sortDir, int offset, int limit) throws SQLException {
        return promotionDAO.findAllWithPaging(keyword, statusFilter, sortCol, sortDir, offset, limit);
    }

    /**
     * Dùng để kiểm tra voucher hợp lệ khi người dùng nhập mã ở giỏ hàng hoặc thanh toán
     */
    public Promotion validateCouponForCheckout(String code, BigDecimal cartSubtotal) throws SQLException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mã khuyến mãi.");
        }

        Promotion promo = promotionDAO.findByCode(code.trim().toUpperCase());
        if (promo == null) {
            throw new IllegalArgumentException("Mã khuyến mãi không tồn tại.");
        }

        if (!promo.IsActive() || promo.IsDeleted()) {
            throw new IllegalArgumentException("Mã khuyến mãi đã hết hạn hoặc bị vô hiệu hóa.");
        }

        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(promo.getValidFrom())) {
            throw new IllegalArgumentException("Mã khuyến mãi này chưa đến thời gian sử dụng.");
        }
        if (now.isAfter(promo.getValidUntil())) {
            throw new IllegalArgumentException("Mã khuyến mãi này đã hết hạn.");
        }

        if (cartSubtotal.compareTo(promo.getMinOrderValue()) < 0) {
            throw new IllegalArgumentException("Đơn hàng chưa đạt giá trị tối thiểu " + promo.getMinOrderValue() + " để áp dụng.");
        }

        if (promo.getMaxUses() != null && promo.getUsedCount() >= promo.getMaxUses()) {
            throw new IllegalArgumentException("Mã khuyến mãi đã hết lượt sử dụng.");
        }

        return promo;
    }

    /**
     * Tính toán số tiền thực tế được giảm
     */
    public BigDecimal calculateDiscountAmount(Promotion promo, BigDecimal cartSubtotal, BigDecimal shippingFee, BigDecimal specificProductTotal) {
        if (promo == null) return BigDecimal.ZERO;

        BigDecimal baseAmount = BigDecimal.ZERO;

        // Xác định số tiền gốc mang đi giảm giá
        switch (promo.getBenefitTarget()) {
            case "MERCHANDISE": baseAmount = cartSubtotal; break;
            case "SHIPPING": baseAmount = shippingFee; break;
            case "PRODUCT": baseAmount = (specificProductTotal != null) ? specificProductTotal : BigDecimal.ZERO; break;
            case "PAYMENT_METHOD": baseAmount = cartSubtotal.add(shippingFee); break;
            default: baseAmount = cartSubtotal;
        }

        if (baseAmount.compareTo(BigDecimal.ZERO) <= 0) return BigDecimal.ZERO;

        BigDecimal discountAmount = BigDecimal.ZERO;

        if ("FIXED".equals(promo.getDiscountType())) {
            discountAmount = promo.getDiscountValue();
        } else if ("PERCENT".equals(promo.getDiscountType())) {
            discountAmount = baseAmount.multiply(promo.getDiscountValue()).divide(new BigDecimal("100"));
            if (promo.getDiscountMax() != null && promo.getDiscountMax().compareTo(BigDecimal.ZERO) > 0) {
                if (discountAmount.compareTo(promo.getDiscountMax()) > 0) {
                    discountAmount = promo.getDiscountMax();
                }
            }
        }

        // Không cho phép giảm âm tiền
        return discountAmount.compareTo(baseAmount) > 0 ? baseAmount : discountAmount;
    }
    
    public void recordPromotionUsage(Connection conn, int orderId, int customerId, Promotion promo, BigDecimal discountApplied) throws SQLException {
        if (promo == null) return;
        promotionDAO.insertOrderPromotion(conn, orderId, promo.getPromoId(), customerId, discountApplied, promo.getCode(), promo.getBenefitTarget());
        promotionDAO.incrementUsedCount(conn, promo.getPromoId());
    }
    
    public List<Promotion> getAvailableVouchersForCart() throws SQLException {
        return promotionDAO.findAvailableVouchersForCart();
    }
}
