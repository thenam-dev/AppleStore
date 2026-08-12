package model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Promotion {

    private int promoId;
    private String code;
    private String discountType; // PERCENT, FIXED
    private BigDecimal discountMax;
    private BigDecimal discountValue;
    private BigDecimal minOrderValue;
    private String scope; // ORDER, PRODUCT
    private String benefitTarget; // MERCHANDISE, SHIPPING, PRODUCT, PAYMENT_METHOD
    private Integer productId;
    private Integer categoryId;
    private Integer maxUses;
    private int usedCount;
    private boolean canStack;
    private LocalDateTime validFrom;
    private LocalDateTime validUntil;
    private int createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean isDeleted;
    private boolean isActive;

    public Promotion() {
    }

    public Promotion(int promoId, String code, String discountType, BigDecimal discountMax, BigDecimal discountValue, BigDecimal minOrderValue, String scope, String benefitTarget, Integer productId, Integer categoryId, Integer maxUses, int usedCount, boolean canStack, LocalDateTime validFrom, LocalDateTime validUntil, int createdBy, LocalDateTime createdAt, LocalDateTime updatedAt, boolean isDeleted, boolean isActive) {
        this.promoId = promoId;
        this.code = code;
        this.discountType = discountType;
        this.discountMax = discountMax;
        this.discountValue = discountValue;
        this.minOrderValue = minOrderValue;
        this.scope = scope;
        this.benefitTarget = benefitTarget;
        this.productId = productId;
        this.categoryId = categoryId;
        this.maxUses = maxUses;
        this.usedCount = usedCount;
        this.canStack = canStack;
        this.validFrom = validFrom;
        this.validUntil = validUntil;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.isDeleted = isDeleted;
        this.isActive = isActive;
    }

    public int getPromoId() {
        return promoId;
    }

    public void setPromoId(int promoId) {
        this.promoId = promoId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDiscountType() {
        return discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public BigDecimal getDiscountMax() {
        return discountMax;
    }

    public void setDiscountMax(BigDecimal discountMax) {
        this.discountMax = discountMax;
    }

    public BigDecimal getDiscountValue() {
        return discountValue;
    }

    public void setDiscountValue(BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public BigDecimal getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(BigDecimal minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public String getScope() {
        return scope;
    }

    public void setScope(String scope) {
        this.scope = scope;
    }

    public String getBenefitTarget() {
        return benefitTarget;
    }

    public void setBenefitTarget(String benefitTarget) {
        this.benefitTarget = benefitTarget;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public Integer getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Integer categoryId) {
        this.categoryId = categoryId;
    }

    public Integer getMaxUses() {
        return maxUses;
    }

    public void setMaxUses(Integer maxUses) {
        this.maxUses = maxUses;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isCanStack() {
        return canStack;
    }

    public void setCanStack(boolean canStack) {
        this.canStack = canStack;
    }

    public LocalDateTime getValidFrom() {
        return validFrom;
    }

    public void setValidFrom(LocalDateTime validFrom) {
        this.validFrom = validFrom;
    }

    public LocalDateTime getValidUntil() {
        return validUntil;
    }

    public void setValidUntil(LocalDateTime validUntil) {
        this.validUntil = validUntil;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public boolean IsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(boolean isDeleted) {
        this.isDeleted = isDeleted;
    }

    public boolean IsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }
}
