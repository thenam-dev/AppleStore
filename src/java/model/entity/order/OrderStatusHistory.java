package model.entity.order;

import java.io.Serializable;
import java.time.LocalDateTime;

public class OrderStatusHistory implements Serializable {
    private static final long serialVersionUID = 1L;

    private int historyId;
    private int orderId;
    private String status;
    private Integer changedBy; 
    private String note;
    private LocalDateTime changedAt;
    
    private String changedByName;

    public int getHistoryId() {
        return historyId;
    }

    public void setHistoryId(int historyId) {
        this.historyId = historyId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Integer changedBy) {
        this.changedBy = changedBy;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }

    public String getChangedByName() {
        return changedByName;
    }

    public void setChangedByName(String changedByName) {
        this.changedByName = changedByName;
    }
    
    public String getFormattedChangedAt() {
        if (this.changedAt == null) {
            return "Chưa cập nhật";
        }
        return this.changedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}