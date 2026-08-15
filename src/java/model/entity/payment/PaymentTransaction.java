/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package model.entity.payment;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
/**
 *
 * @author namnthe180997
 */
public class PaymentTransaction implements Serializable{
private static final long serialVersionUID = 1L;
 
    private int transactionId;
    private int orderId;
    private int attemptNo;
    private String paymentMethod;
    private String sepayTransactionId;
    private String sepayReference;
    private String sepayQrCode;
    private BigDecimal amount;
    private String currency;
    private String status;
    private LocalDateTime initiatedAt;
    private LocalDateTime completedAt;
    private LocalDateTime expiresAt;
    private String errorMessage;
 
    public int getTransactionId() {
        return transactionId;
    }
 
    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }
 
    public int getOrderId() {
        return orderId;
    }
 
    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }
 
    public int getAttemptNo() {
        return attemptNo;
    }
 
    public void setAttemptNo(int attemptNo) {
        this.attemptNo = attemptNo;
    }
 
    public String getPaymentMethod() {
        return paymentMethod;
    }
 
    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }
 
    public String getSepayTransactionId() {
        return sepayTransactionId;
    }
 
    public void setSepayTransactionId(String sepayTransactionId) {
        this.sepayTransactionId = sepayTransactionId;
    }
 
    public String getSepayReference() {
        return sepayReference;
    }
 
    public void setSepayReference(String sepayReference) {
        this.sepayReference = sepayReference;
    }
 
    public String getSepayQrCode() {
        return sepayQrCode;
    }
 
    public void setSepayQrCode(String sepayQrCode) {
        this.sepayQrCode = sepayQrCode;
    }
 
    public BigDecimal getAmount() {
        return amount;
    }
 
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
 
    public String getCurrency() {
        return currency;
    }
 
    public void setCurrency(String currency) {
        this.currency = currency;
    }
 
    public String getStatus() {
        return status;
    }
 
    public void setStatus(String status) {
        this.status = status;
    }
 
    public LocalDateTime getInitiatedAt() {
        return initiatedAt;
    }
 
    public void setInitiatedAt(LocalDateTime initiatedAt) {
        this.initiatedAt = initiatedAt;
    }
 
    public LocalDateTime getCompletedAt() {
        return completedAt;
    }
 
    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }
 
    public LocalDateTime getExpiresAt() {
        return expiresAt;
    }
 
    public void setExpiresAt(LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }
 
    public String getErrorMessage() {
        return errorMessage;
    }
 
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
}
