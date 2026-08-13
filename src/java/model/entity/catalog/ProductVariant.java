package model.entity.catalog;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ProductVariant implements Serializable {
    private static final long serialVersionUID = 1L;

    private int variantId;
    private int productId;
    private String productName;
    private String productStatus;
    private String sku;
    private String variantLabel;
    private String colorName;
    private String colorHex;
    private Integer storageCapacityGb;
    private Integer ramGb;
    private String connectivity;
    private String chipOption;
    private BigDecimal screenSizeInch;
    private BigDecimal price;
    private int stockQuantity;
    private BigDecimal weightKg;
    private BigDecimal discountPrice;
    private LocalDateTime discountStart;
    private LocalDateTime discountEnd;
    private boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel;
    }

    public String getColorName() {
        return colorName;
    }

    public void setColorName(String colorName) {
        this.colorName = colorName;
    }

    public String getColorHex() {
        return colorHex;
    }

    public void setColorHex(String colorHex) {
        this.colorHex = colorHex;
    }

    public Integer getStorageCapacityGb() {
        return storageCapacityGb;
    }

    public void setStorageCapacityGb(Integer storageCapacityGb) {
        this.storageCapacityGb = storageCapacityGb;
    }

    public Integer getRamGb() {
        return ramGb;
    }

    public void setRamGb(Integer ramGb) {
        this.ramGb = ramGb;
    }

    public String getConnectivity() {
        return connectivity;
    }

    public void setConnectivity(String connectivity) {
        this.connectivity = connectivity;
    }

    public String getChipOption() {
        return chipOption;
    }

    public void setChipOption(String chipOption) {
        this.chipOption = chipOption;
    }

    public BigDecimal getScreenSizeInch() {
        return screenSizeInch;
    }

    public void setScreenSizeInch(BigDecimal screenSizeInch) {
        this.screenSizeInch = screenSizeInch;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public BigDecimal getWeightKg() {
        return weightKg;
    }

    public void setWeightKg(BigDecimal weightKg) {
        this.weightKg = weightKg;
    }

    public BigDecimal getDiscountPrice() {
        return discountPrice;
    }

    public void setDiscountPrice(BigDecimal discountPrice) {
        this.discountPrice = discountPrice;
    }

    public LocalDateTime getDiscountStart() {
        return discountStart;
    }

    public void setDiscountStart(LocalDateTime discountStart) {
        this.discountStart = discountStart;
    }

    public LocalDateTime getDiscountEnd() {
        return discountEnd;
    }

    public void setDiscountEnd(LocalDateTime discountEnd) {
        this.discountEnd = discountEnd;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
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
}
