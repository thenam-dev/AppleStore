/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

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
    private Integer addonId;
    private LocalDateTime addedAt;
 
    public CartItem() {
    }
 
    public CartItem(int cartItemId, int cartId, int variantId, int quantity,
                     Integer addonId, LocalDateTime addedAt) {
        this.cartItemId = cartItemId;
        this.cartId = cartId;
        this.variantId = variantId;
        this.quantity = quantity;
        this.addonId = addonId;
        this.addedAt = addedAt;
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
}
