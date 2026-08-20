package model.entity.catalog;

public class ProductSpecification {
    private int specId;
    private int productId;
    private String specGroup;
    private String specName;
    private String specValue;
    private Integer displayOrder;

    public ProductSpecification() {
    }

    public ProductSpecification(int specId, int productId, String specGroup, String specName,
                                String specValue, Integer displayOrder) {
        this.specId = specId;
        this.productId = productId;
        this.specGroup = specGroup;
        this.specName = specName;
        this.specValue = specValue;
        this.displayOrder = displayOrder;
    }

    public int getSpecId() {
        return specId;
    }

    public void setSpecId(int specId) {
        this.specId = specId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSpecGroup() {
        return specGroup;
    }

    public void setSpecGroup(String specGroup) {
        this.specGroup = specGroup;
    }

    public String getSpecName() {
        return specName;
    }

    public void setSpecName(String specName) {
        this.specName = specName;
    }

    public String getSpecValue() {
        return specValue;
    }

    public void setSpecValue(String specValue) {
        this.specValue = specValue;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }
}
