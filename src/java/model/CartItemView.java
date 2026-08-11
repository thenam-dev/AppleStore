/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;
/**
 *
 * @author ACER
 */
public class CartItemView {
    private int cartItemId;
    private int variantId;
    private String productName;
    private String variantLabel;
    private String imageUrl;
    private BigDecimal unitPrice;
    private BigDecimal discountPrice; // có thể null
    private int quantity;
    private int stockQuantity;
    private Integer addonId;
    private String addonName;
    private BigDecimal addonPrice;
 
    public BigDecimal getEffectiveUnitPrice() {
        BigDecimal base = (discountPrice != null) ? discountPrice : unitPrice;
        if (addonPrice != null) {
            base = base.add(addonPrice);
        }
        return base;
    }
 
    public BigDecimal getSubtotal() {
        return getEffectiveUnitPrice().multiply(BigDecimal.valueOf(quantity));
    }
 
    public int getCartItemId() {
        return cartItemId;
    }
 
    public void setCartItemId(int cartItemId) {
        this.cartItemId = cartItemId;
    }
 
    public int getVariantId() {
        return variantId;
    }
 
    public void setVariantId(int variantId) {
        this.variantId = variantId;
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
 
    public String getImageUrl() {
        return imageUrl;
    }
 
    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
 
    public BigDecimal getUnitPrice() {
        return unitPrice;
    }
 
    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }
 
    public BigDecimal getDiscountPrice() {
        return discountPrice;
    }
 
    public void setDiscountPrice(BigDecimal discountPrice) {
        this.discountPrice = discountPrice;
    }
 
    public int getQuantity() {
        return quantity;
    }
 
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
 
    public int getStockQuantity() {
        return stockQuantity;
    }
 
    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }
 
    public Integer getAddonId() {
        return addonId;
    }
 
    public void setAddonId(Integer addonId) {
        this.addonId = addonId;
    }
 
    public String getAddonName() {
        return addonName;
    }
 
    public void setAddonName(String addonName) {
        this.addonName = addonName;
    }
 
    public BigDecimal getAddonPrice() {
        return addonPrice;
    }
 
    public void setAddonPrice(BigDecimal addonPrice) {
        this.addonPrice = addonPrice;
    }
}
