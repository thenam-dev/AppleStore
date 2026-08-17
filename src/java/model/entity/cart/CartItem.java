/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model.entity.cart;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 *
 * @author ACER
 */
public class CartItem {

    private int cartItemId;
    private int cartId;
    private int variantId;
    private int quantity;
    private Integer addonId; // có thể null
    private LocalDateTime addedAt;
    private int productId;
    private int categoryId;
    // Field bổ sung phục vụ hiển thị / tính tiền, lấy từ JOIN trong CartDAO
    private String productName;
    private String variantLabel;
    private BigDecimal unitPrice;
    private int stockQuantity;
    private boolean active; // product_variants.is_active
    private String addonLabel;
    private BigDecimal addonPrice;
    private String imageUrl; // ảnh chính của sản phẩm (product_images.is_primary = 1), có thể null

    public CartItem() {
    }

    public int getCartItemId() {
        return cartItemId;
    }

    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public Integer getAddonId() {
        return addonId;
    }

    public void setAddonId(Integer addonId) {
        this.addonId = addonId;
    }

    public LocalDateTime getAddedAt() {
        return addedAt;
    }

    public void setAddedAt(LocalDateTime addedAt) {
        this.addedAt = addedAt;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getAddonLabel() {
        return addonLabel;
    }

    public void setAddonLabel(String addonLabel) {
        this.addonLabel = addonLabel;
    }

    public BigDecimal getAddonPrice() {
        return addonPrice;
    }

    public void setAddonPrice(BigDecimal addonPrice) {
        this.addonPrice = addonPrice;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    /**
     * True nếu số lượng trong giỏ đã vượt tồn kho hiện tại - JSP dùng để tô đỏ
     * cảnh báo bằng EL.
     */
    public boolean isOverStock() {
        return quantity > stockQuantity;
    }

    /**
     * Thành tiền của dòng = (đơn giá + phụ kiện) * số lượng. JSP gọi trực tiếp
     * ${item.lineTotal}.
     */
    public BigDecimal getLineTotal() {
        BigDecimal addon = addonPrice == null ? BigDecimal.ZERO : addonPrice;
        BigDecimal price = unitPrice == null ? BigDecimal.ZERO : unitPrice;
        return price.add(addon).multiply(BigDecimal.valueOf(quantity));
    }
}
