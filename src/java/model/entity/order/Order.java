package model.entity.order;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class Order {

    private int orderId;
    private int customerId;
    private String deliveryAddress;
    private String recipientName;
    private String recipientPhone;
    private String deliveryTimeSlot;
    private String notes;
    private String status;
    private BigDecimal totalAmount;
    private BigDecimal deliveryFee;
    private BigDecimal discountAmount;
    private BigDecimal finalAmount;
    private String paymentMethod;
    private LocalDateTime createdAt;
    private List<OrderItem> items;
    private List<OrderStatusHistory> statusHistory;

    // Bổ sung thêm thông tin Shipper phụ trách đơn hàng
    private String shipperName;
    private Integer shipperId;

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getRecipientPhone() {
        return recipientPhone;
    }

    public void setRecipientPhone(String recipientPhone) {
        this.recipientPhone = recipientPhone;
    }

    public String getDeliveryTimeSlot() {
        return deliveryTimeSlot;
    }

    public void setDeliveryTimeSlot(String deliveryTimeSlot) {
        this.deliveryTimeSlot = deliveryTimeSlot;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public BigDecimal getDeliveryFee() {
        return deliveryFee;
    }

    public void setDeliveryFee(BigDecimal deliveryFee) {
        this.deliveryFee = deliveryFee;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(BigDecimal finalAmount) {
        this.finalAmount = finalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<OrderItem> getItems() {
        return items;
    }

    public void setItems(List<OrderItem> items) {
        this.items = items;
    }

    public List<OrderStatusHistory> getStatusHistory() {
        return statusHistory;
    }

    public void setStatusHistory(List<OrderStatusHistory> statusHistory) {
        this.statusHistory = statusHistory;
    }

    public String getShipperName() {
        return shipperName;
    }

    public void setShipperName(String shipperName) {
        this.shipperName = shipperName;
    }

    public Integer getShipperId() {
        return shipperId;
    }

    public void setShipperId(Integer shipperId) {
        this.shipperId = shipperId;
    }

    public String getFormattedCreatedAt() {
        if (this.createdAt == null) {
            return "";
        }
        return this.createdAt.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy", new java.util.Locale("vi", "VN")));
    }

    // Dùng cho hóa đơn xuất ở order-success.jsp - cần cả ngày và giờ, format dd/MM/yyyy HH:mm.
    public String getFormattedCreatedAtFull() {
        if (this.createdAt == null) {
            return "";
        }
        return this.createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
