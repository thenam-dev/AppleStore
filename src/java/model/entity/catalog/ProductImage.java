package model.entity.catalog;

import java.io.Serializable;
import java.time.LocalDateTime;

public class ProductImage implements Serializable {
    private static final long serialVersionUID = 1L;

    private int imageId;
    private int productId;
    private String filePath;
    private int displayOrder;
    private boolean primary;
    private LocalDateTime uploadedAt;

    public int getImageId() { return imageId; }
    public void setImageId(int imageId) { this.imageId = imageId; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }
    public boolean isPrimary() { return primary; }
    public void setPrimary(boolean primary) { this.primary = primary; }
    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }
}
