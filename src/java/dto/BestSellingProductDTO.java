package dto;

public class BestSellingProductDTO {
    private int productId;
    private String name;
    private String imageUrl;
    private int totalSold;

    public BestSellingProductDTO() {
    }

    public BestSellingProductDTO(int productId, String name, String imageUrl, int totalSold) {
        this.productId = productId;
        this.name = name;
        this.imageUrl = imageUrl;
        this.totalSold = totalSold;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getTotalSold() {
        return totalSold;
    }

    public void setTotalSold(int totalSold) {
        this.totalSold = totalSold;
    }
}
