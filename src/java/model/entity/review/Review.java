package model.entity.review;

import java.util.Date;

public class Review {

    private int reviewId;
    private int orderItemId;
    private int orderId;
    private int customerId;
    private int rating;
    private String reviewText;
    private String reviewImageUrl;
    private boolean isHidden;
    private Date createdAt; // Đổi sang java.util.Date để JSTL fmt:formatDate đọc được

    // Các trường phục vụ hiển thị lên UI
    private String customerName;
    private String variantLabel;

    public Review() {
    }

    public Review(int orderItemId, int orderId, int customerId, int rating, String reviewText) {
        this.orderItemId = orderItemId;
        this.orderId = orderId;
        this.customerId = customerId;
        this.rating = rating;
        this.reviewText = reviewText;
    }

    // Getters & Setters
    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

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

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getReviewText() {
        return reviewText;
    }

    public void setReviewText(String reviewText) {
        this.reviewText = reviewText;
    }

    public String getReviewImageUrl() {
        return reviewImageUrl;
    }

    public void setReviewImageUrl(String reviewImageUrl) {
        this.reviewImageUrl = reviewImageUrl;
    }

    public boolean isHidden() {
        return isHidden;
    }

    public void setHidden(boolean hidden) {
        isHidden = hidden;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getVariantLabel() {
        return variantLabel;
    }

    public void setVariantLabel(String variantLabel) {
        this.variantLabel = variantLabel;
    }
}
