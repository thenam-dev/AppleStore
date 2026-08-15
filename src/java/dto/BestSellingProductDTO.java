package dto;

public class BestSellingProductDTO {
    private int productId;
    private String name;
    private String imageUrl;
    private int totalSold;
    private double totalRevenue;
    private int orderCount;

    public BestSellingProductDTO() {
    }

    public BestSellingProductDTO(int productId, String name, String imageUrl, int totalSold, double totalRevenue, int orderCount) {
        this.productId = productId;
        this.name = name;
        this.imageUrl = imageUrl;
        this.totalSold = totalSold;
        this.totalRevenue = totalRevenue;
        this.orderCount = orderCount;
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

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) {
        this.orderCount = orderCount;
    }
}
