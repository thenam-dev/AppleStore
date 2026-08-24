package service.promotion;

import dao.promtion.PromotionDAO;
import model.entity.promtion.Promotion;
import model.entity.cart.CartItem;

import java.sql.Connection;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

public class PromotionService {

    private final PromotionDAO promotionDAO = new PromotionDAO();

    /** =======================================================================
     *  PHẦN 1: CÁC HÀM XỬ LÝ NGHIỆP VỤ CHO ADMIN QUẢN TRỊ MÃ KHUYẾN MÃI
     *  ======================================================================= */

    public List<Promotion> getAllPromotions() throws SQLException {
        return promotionDAO.findAll();
    }

    public Promotion getPromotionById(int id) throws SQLException {
        Promotion promo = promotionDAO.findById(id);
        if (promo == null) {
            throw new IllegalArgumentException("Mã khuyến mãi không tồn tại.");
        }
        return promo;
    }

    public void createPromotion(Promotion promo, int adminId) throws SQLException {
        validatePromotion(promo, false);
        Promotion existing = promotionDAO.findByCode(promo.getCode());
        if (existing != null) {
            throw new IllegalArgumentException("Mã khuyến mãi đã tồn tại.");
        }
        promo.setCreatedBy(adminId);
        promotionDAO.insert(promo);
    }

    public void updatePromotion(Promotion promo) throws SQLException {
        if (promo == null || promo.getPromoId() <= 0) {
            throw new IllegalArgumentException("ID khuyến mãi không hợp lệ.");
        }
        validatePromotion(promo, true);
        Promotion existing = promotionDAO.findByCode(promo.getCode());
        if (existing != null && existing.getPromoId() != promo.getPromoId()) {
            throw new IllegalArgumentException("Mã khuyến mãi này đã được sử dụng cho một chương trình khác.");
        }
        promotionDAO.update(promo);
    }

    public void toggleStatus(int id, boolean isActive) throws SQLException {
        if (id <= 0) {
            throw new IllegalArgumentException("ID mã giảm giá không hợp lệ.");
        }
        promotionDAO.toggleStatus(id, isActive);
    }

    private void validatePromotion(Promotion promo, boolean isEdit) {
        if (promo.getCode() == null || promo.getCode().isBlank()) {
            throw new IllegalArgumentException("Mã giảm giá không được để trống.");
        }
        promo.setCode(promo.getCode().trim().toUpperCase());
        if (promo.getCode().length() > 50) {
            throw new IllegalArgumentException("Mã giảm giá không được vượt quá 50 ký tự.");
        }

        if (promo.getDiscountValue() == null || promo.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá trị giảm giá phải lớn hơn 0.");
        }

        if ("PERCENT".equals(promo.getDiscountType())) {
            if (promo.getDiscountValue().compareTo(new BigDecimal("100")) > 0) {
                throw new IllegalArgumentException("Mức giảm phần trăm (%) tối đa là 100.");
            }
            if (promo.getDiscountMax() != null && promo.getDiscountMax().compareTo(BigDecimal.ZERO) < 0) {
                throw new IllegalArgumentException("Mức giảm tối đa không được là số âm.");
            }
        } else if ("FIXED".equals(promo.getDiscountType())) {
            if (promo.getDiscountValue().compareTo(new BigDecimal("99999999.99")) > 0) {
                throw new IllegalArgumentException("Giá trị giảm giá quá lớn, vượt mức cho phép.");
            }
            promo.setDiscountMax(BigDecimal.ZERO);
        } else {
            throw new IllegalArgumentException("Loại giảm giá không hợp lệ.");
        }

        if (promo.getMinOrderValue() != null && promo.getMinOrderValue().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Giá trị đơn hàng tối thiểu không được là số âm.");
        }
        
        if (promo.getMaxUses() != null && promo.getMaxUses() < 0) {
            throw new IllegalArgumentException("Giới hạn số lượt dùng không được là số âm.");
        }

        if (!"MERCHANDISE".equals(promo.getBenefitTarget())) {
            throw new IllegalArgumentException("Mục tiêu được giảm mặc định phải là Tiền hàng (MERCHANDISE).");
        }

        String scope = promo.getScope();
        if ("ORDER".equals(scope)) {
            promo.getProductIds().clear();
            promo.getCategoryIds().clear();
        } else if ("PRODUCT".equals(scope)) {
            if (promo.getProductIds() == null || promo.getProductIds().isEmpty()) {
                throw new IllegalArgumentException("Phạm vi theo sản phẩm bắt buộc phải chọn ít nhất 1 Sản phẩm áp dụng.");
            }
            promo.getCategoryIds().clear();
        } else if ("CATEGORY".equals(scope)) {
            if (promo.getCategoryIds() == null || promo.getCategoryIds().isEmpty()) {
                throw new IllegalArgumentException("Phạm vi theo danh mục bắt buộc phải chọn ít nhất 1 Danh mục áp dụng.");
            }
            promo.getProductIds().clear();
        } else {
            throw new IllegalArgumentException("Phạm vi áp dụng không hợp lệ.");
        }

        if (promo.getValidFrom() == null || promo.getValidUntil() == null) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thời gian hiệu lực.");
        }
        if (!promo.getValidUntil().isAfter(promo.getValidFrom())) {
            throw new IllegalArgumentException("Thời gian hiệu lực không hợp lệ (Ngày kết thúc phải SAU ngày bắt đầu).");
        }

//        LocalDateTime now = LocalDateTime.now();
//        if (promo.getValidUntil().isBefore(now)) {
//            throw new IllegalArgumentException("Thời gian kết thúc không được nằm ở quá khứ.");
//        }
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

    public List<Promotion> findAllWithPaging(String keyword, String statusFilter, String sort, int offset, int limit) throws SQLException {
        return promotionDAO.findAllWithPaging(keyword, statusFilter, sort, offset, limit);
    }


    /** =======================================================================
     *  PHẦN 2: CÁC HÀM XỬ LÝ NGHIỆP VỤ CHO CUSTOMER / GIỎ HÀNG / CHECKOUT
     *  ======================================================================= */

    public BigDecimal calculateEligibleAmount(List<CartItem> cartItems, Promotion promo) {
        if (cartItems == null || promo == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal eligibleTotal = BigDecimal.ZERO;
        for (CartItem item : cartItems) {
            BigDecimal unitPrice = item.getUnitPrice() != null ? item.getUnitPrice() : BigDecimal.ZERO;
            BigDecimal addonPrice = item.getAddonPrice() != null ? item.getAddonPrice() : BigDecimal.ZERO;
            BigDecimal lineTotal = unitPrice.add(addonPrice).multiply(new BigDecimal(item.getQuantity()));

            if ("ORDER".equals(promo.getScope())) {
                eligibleTotal = eligibleTotal.add(lineTotal);
            } else if ("PRODUCT".equals(promo.getScope()) && promo.getProductIds() != null && promo.getProductIds().contains(item.getProductId())) {
                eligibleTotal = eligibleTotal.add(lineTotal);
            } else if ("CATEGORY".equals(promo.getScope()) && promo.getCategoryIds() != null && promo.getCategoryIds().contains(item.getCategoryId())) {
                eligibleTotal = eligibleTotal.add(lineTotal);
            }
        }
        return eligibleTotal;
    }

    public Promotion validateCouponForCheckout(String code, BigDecimal cartSubtotal, List<CartItem> cartItems) throws SQLException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mã khuyến mãi.");
        }
        Promotion promo = promotionDAO.findByCode(code.trim().toUpperCase());
        if (promo == null) {
            throw new IllegalArgumentException("Mã khuyến mãi không tồn tại.");
        }
        
        // Sử dụng chuẩn hàm Getter/Setter đúng chuẩn (viết thường chữ i)
        if (!promo.isActive() || promo.isDeleted()) {
            throw new IllegalArgumentException("Mã khuyến mãi đã hết hạn hoặc bị vô hiệu hóa.");
        }
        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(promo.getValidFrom())) {
            throw new IllegalArgumentException("Mã khuyến mãi này chưa đến thời gian sử dụng.");
        }
        if (now.isAfter(promo.getValidUntil())) {
            throw new IllegalArgumentException("Mã khuyến mãi này đã hết hạn.");
        }

        BigDecimal eligibleAmount = calculateEligibleAmount(cartItems, promo);
        if (!"ORDER".equals(promo.getScope()) && eligibleAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Mã giảm giá này không áp dụng cho sản phẩm hoặc danh mục trong giỏ hàng.");
        }
        
        BigDecimal amountToCompare = "ORDER".equals(promo.getScope()) ? cartSubtotal : eligibleAmount;
        if (amountToCompare.compareTo(promo.getMinOrderValue()) < 0) {
            throw new IllegalArgumentException("Đơn hàng chưa đạt giá trị tối thiểu " + promo.getMinOrderValue() + " để áp dụng.");
        }
        if (promo.getMaxUses() != null && promo.getUsedCount() >= promo.getMaxUses()) {
            throw new IllegalArgumentException("Mã khuyến mãi đã hết lượt sử dụng.");
        }
        return promo;
    }

    public BigDecimal calculateDiscountAmount(Promotion promo, BigDecimal cartSubtotal, BigDecimal shippingFee, BigDecimal eligibleAmount) {
        if (promo == null) {
            return BigDecimal.ZERO;
        }
        BigDecimal baseAmount = "ORDER".equals(promo.getScope()) ? cartSubtotal : eligibleAmount;
        if (baseAmount.compareTo(BigDecimal.ZERO) <= 0) {
            return BigDecimal.ZERO;
        }

        BigDecimal discountAmount = BigDecimal.ZERO;
        if ("FIXED".equals(promo.getDiscountType())) {
            discountAmount = promo.getDiscountValue();
        } else if ("PERCENT".equals(promo.getDiscountType())) {
            discountAmount = baseAmount.multiply(promo.getDiscountValue()).divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
            if (promo.getDiscountMax() != null && promo.getDiscountMax().compareTo(BigDecimal.ZERO) > 0) {
                if (discountAmount.compareTo(promo.getDiscountMax()) > 0) {
                    discountAmount = promo.getDiscountMax();
                }
            }
        }
        return discountAmount.compareTo(baseAmount) > 0 ? baseAmount : discountAmount;
    }

    public boolean recordPromotionUsage(Connection conn, int orderId, int customerId, Promotion promo, BigDecimal discountApplied) throws SQLException {
        if (promo == null) {
            return false;
        }
        boolean incrementSuccess = promotionDAO.incrementUsedCount(conn, promo.getPromoId());
        if (incrementSuccess) {
            promotionDAO.insertOrderPromotion(conn, orderId, promo.getPromoId(), customerId, discountApplied, promo.getCode(), promo.getBenefitTarget());
            return true;
        }
        return false;
    }

    public void voidPromotionUsage(Connection conn, int promoId) throws SQLException {
        promotionDAO.decrementUsedCount(conn, promoId);
    }

    public List<Promotion> getAvailableVouchersForCart() throws SQLException {
        return promotionDAO.findAvailableVouchersForCart();
    }
}