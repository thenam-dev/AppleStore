/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model.entity.order;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 *
 * @author namnthe180997
 */
public class OrderItem implements Serializable {

    private static final long serialVersionUID = 1L;

    private int orderItemId;
    private int orderId;
    private Integer variantId; // nullable vì FK ON DELETE SET NULL
    private Integer serialId;
    private String productNameSnapshot;
    private String variantLabelSnapshot;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal subtotal;
    private String addonLabelSnapshot;
    private BigDecimal addonPriceSnapshot;

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public Integer getVariantId() {
        return variantId;
    }

    public void setVariantId(Integer variantId) {
        this.variantId = variantId;
    }

    public Integer getSerialId() {
        return serialId;
    }

    public void setSerialId(Integer serialId) {
        this.serialId = serialId;
    }

    public String getProductNameSnapshot() {
        return productNameSnapshot;
    }

    public void setProductNameSnapshot(String productNameSnapshot) {
        this.productNameSnapshot = productNameSnapshot;
    }

    public String getVariantLabelSnapshot() {
        return variantLabelSnapshot;
    }

    public void setVariantLabelSnapshot(String variantLabelSnapshot) {
        this.variantLabelSnapshot = variantLabelSnapshot;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public String getAddonLabelSnapshot() {
        return addonLabelSnapshot;
    }

    public void setAddonLabelSnapshot(String addonLabelSnapshot) {
        this.addonLabelSnapshot = addonLabelSnapshot;
    }

    public BigDecimal getAddonPriceSnapshot() {
        return addonPriceSnapshot;
    }

    public void setAddonPriceSnapshot(BigDecimal addonPriceSnapshot) {
        this.addonPriceSnapshot = addonPriceSnapshot;
    }
}
