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

    public List<Promotion> getAllPromotions() throws SQLException {
        return promotionDAO.findAll();
    }

    public Promotion getPromotionById(int id) throws SQLException {
        return promotionDAO.findById(id);
    }

    public void createPromotion(Promotion promo, int adminId) throws SQLException {
        // Truyền false để bật check cấm ngày bắt đầu ở quá khứ
        validatePromotion(promo, false);

        // Ensure code uniqueness
        Promotion existing = promotionDAO.findByCode(promo.getCode());
        if (existing != null) {
            throw new IllegalArgumentException("Mã khuyến mãi đã tồn tại.");
        }

        promo.setCreatedBy(adminId);
        promotionDAO.insert(promo);
    }

    public void updatePromotion(Promotion promo) throws SQLException {
        // Truyền true để bỏ qua check ngày bắt đầu ở quá khứ (vì mã đang chạy thì validFrom chắc chắn ở quá khứ)
        validatePromotion(promo, true);

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

    /**
     * BỘ VALIDATE TẬP TRUNG - MỌI LỖI ĐỀU GẮN TAG [BE]
     * Tuân thủ tuyệt đối CK_promotions_scope_logic trong schema.sql
     */
    private void validatePromotion(Promotion promo, boolean isEdit) {
        if (promo.getCode() == null || promo.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Mã giảm giá không được để trống.");
        }
        promo.setCode(promo.getCode().trim().toUpperCase());
        if (promo.getCode().length() > 50) {
            throw new IllegalArgumentException("Mã giảm giá không được vượt quá 50 ký tự.");
        }

        if (promo.getDiscountValue() == null || promo.getDiscountValue().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Giá trị giảm giá phải lớn hơn 0.");
        }

        // Khớp với CHECK (discount_type IN ('PERCENT','FIXED')) và CK_promotions_discount_value
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

        // Khớp với CHECK benefit_target (chỉ cho phép MERCHANDISE và PRODUCT theo yêu cầu của bạn)
        if (!"MERCHANDISE".equals(promo.getBenefitTarget()) && !"PRODUCT".equals(promo.getBenefitTarget())) {
            throw new IllegalArgumentException("Mục tiêu được giảm chỉ hỗ trợ MERCHANDISE hoặc PRODUCT.");
        }

        // KHỚP TUYỆT ĐỐI VỚI CK_promotions_scope_logic TRONG SQL
        String scope = promo.getScope();
        if ("ORDER".equals(scope)) {
            promo.setProductId(null);
            promo.setCategoryId(null);
        } else if ("PRODUCT".equals(scope)) {
            if (promo.getProductId() == null || promo.getProductId() <= 0) {
                throw new IllegalArgumentException("Phạm vi theo sản phẩm bắt buộc phải chọn Sản phẩm áp dụng.");
            }
            promo.setCategoryId(null); // Bắt buộc null để khớp DB Check
        } else if ("CATEGORY".equals(scope)) {
            if (promo.getCategoryId() == null || promo.getCategoryId() <= 0) {
                throw new IllegalArgumentException("Phạm vi theo danh mục bắt buộc phải chọn Danh mục áp dụng.");
            }
            promo.setProductId(null); // Bắt buộc null để khớp DB Check
        } else {
            throw new IllegalArgumentException("Phạm vi áp dụng không hợp lệ.");
        }

        // Khớp với CK_promotions_valid_dates (valid_until > valid_from)
        if (promo.getValidFrom() == null || promo.getValidUntil() == null) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thời gian hiệu lực.");
        }
        if (!promo.getValidUntil().isAfter(promo.getValidFrom())) {
            throw new IllegalArgumentException("Thời gian hiệu lực không hợp lệ (Ngày kết thúc phải SAU ngày bắt đầu).");
        }

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nowBuffer = now.minusMinutes(1);

        if (promo.getValidUntil().isBefore(now)) {
            throw new IllegalArgumentException("Thời gian kết thúc không được nằm ở quá khứ.");
        }

        if (!isEdit && promo.getValidFrom().isBefore(nowBuffer)) {
            throw new IllegalArgumentException("Thời gian bắt đầu chiến dịch không được nằm ở quá khứ.");
        }
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
     * THUẬT TOÁN BÓC TÁCH GIỎ HÀNG
     * Quét giỏ hàng để tính tổng giá trị các sản phẩm thỏa mãn phạm vi (Scope) của mã.
     */
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
            } else if ("PRODUCT".equals(promo.getScope()) && promo.getProductId() != null && promo.getProductId().equals(item.getProductId())) {
                eligibleTotal = eligibleTotal.add(lineTotal);
            } else if ("CATEGORY".equals(promo.getScope()) && promo.getCategoryId() != null && promo.getCategoryId().equals(item.getCategoryId())) {
                eligibleTotal = eligibleTotal.add(lineTotal);
            }
        }
        return eligibleTotal;
    }

    /**
     * Dùng để kiểm tra voucher hợp lệ khi người dùng áp dụng mã ở giỏ hàng hoặc thanh toán
     */
    public Promotion validateCouponForCheckout(String code, BigDecimal cartSubtotal, List<CartItem> cartItems) throws SQLException {
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

        // Bóc tách giỏ hàng theo Scope của mã
        BigDecimal eligibleAmount = calculateEligibleAmount(cartItems, promo);

        // Nếu mã áp dụng theo SP hoặc Danh mục nhưng trong giỏ không có sản phẩm khớp
        if (!"ORDER".equals(promo.getScope()) && eligibleAmount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Mã giảm giá này không áp dụng cho sản phẩm hoặc danh mục trong giỏ hàng.");
        }

        // Xét giá trị đơn hàng tối thiểu
        BigDecimal amountToCompare = "ORDER".equals(promo.getScope()) ? cartSubtotal : eligibleAmount;
        if (amountToCompare.compareTo(promo.getMinOrderValue()) < 0) {
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
    public BigDecimal calculateDiscountAmount(Promotion promo, BigDecimal cartSubtotal, BigDecimal shippingFee, BigDecimal eligibleAmount) {
        if (promo == null) {
            return BigDecimal.ZERO;
        }

        BigDecimal baseAmount = BigDecimal.ZERO;

        switch (promo.getBenefitTarget()) {
            case "MERCHANDISE":
                baseAmount = "ORDER".equals(promo.getScope()) ? cartSubtotal : eligibleAmount;
                break;
            case "SHIPPING":
                baseAmount = shippingFee;
                break;
            case "PRODUCT":
                baseAmount = eligibleAmount;
                break;
            case "PAYMENT_METHOD":
                baseAmount = cartSubtotal.add(shippingFee);
                break;
            default:
                baseAmount = cartSubtotal;
        }

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
        
        // 1. Cố gắng tăng số lượt sử dụng TRƯỚC
        boolean incrementSuccess = promotionDAO.incrementUsedCount(conn, promo.getPromoId());
        
        // 2. Nếu tăng thành công (tức là còn lượt sử dụng), mới ghi nhận vào bảng order_promotions
        if (incrementSuccess) {
            promotionDAO.insertOrderPromotion(conn, orderId, promo.getPromoId(), customerId, discountApplied, promo.getCode(), promo.getBenefitTarget());
            return true;
        }
        
        // Nếu hết lượt, trả về false để CheckoutService biết đường Rollback
        return false;
    }

    public List<Promotion> getAvailableVouchersForCart() throws SQLException {
        return promotionDAO.findAvailableVouchersForCart();
    }
}