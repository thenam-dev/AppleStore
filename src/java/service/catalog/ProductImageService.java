package service.catalog;

import dao.catalog.ProductImageDAO;
import jakarta.servlet.http.Part;
import model.entity.catalog.Product;
import model.entity.catalog.ProductImage;
import util.FileUploadUtil;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class ProductImageService {
    private final ProductImageDAO productImageDAO;
    private final ProductService productService;

    public ProductImageService() {
        this(new ProductImageDAO(), new ProductService());
    }

    public ProductImageService(ProductImageDAO productImageDAO, ProductService productService) {
        this.productImageDAO = productImageDAO;
        this.productService = productService;
    }

    public List<ProductImage> getImagesByProductId(int productId) throws SQLException {
        validateProductExists(productId);
        return productImageDAO.findByProductId(productId);
    }

    public int uploadImages(int productId, Collection<Part> parts) throws SQLException, IOException {
        Product product = validateProductExists(productId);
        if ("DELETED".equalsIgnoreCase(product.getStatus())) {
            throw new IllegalArgumentException("Không thể thêm ảnh cho sản phẩm đã xóa.");
        }
        if (parts == null || parts.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một ảnh.");
        }
        // Validate every part before saving the first file to avoid partial uploads.
        validateImageParts(parts);

        int existingCount = productImageDAO.countByProductId(productId);
        List<ProductImage> pendingImages = new ArrayList<>();
        List<String> savedPaths = new ArrayList<>();
        try {
            for (Part part : parts) {
                if (part == null || part.getSize() == 0) continue;
                String filePath = FileUploadUtil.saveProductImage(part);
                if (filePath == null) continue;
                savedPaths.add(filePath);

                ProductImage image = new ProductImage();
                image.setProductId(productId);
                image.setFilePath(filePath);
                image.setDisplayOrder(existingCount + pendingImages.size() + 1);
                image.setPrimary(existingCount == 0 && pendingImages.isEmpty());
                pendingImages.add(image);
            }

            productImageDAO.insertBatch(pendingImages);
        } catch (SQLException | IOException | RuntimeException ex) {
            for (String savedPath : savedPaths) {
                FileUploadUtil.deleteUploadedFile(savedPath);
            }
            throw ex;
        }
        if (pendingImages.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất một ảnh.");
        }
        return pendingImages.size();
    }

    public void validateImageParts(Collection<Part> parts) throws IOException {
        if (parts != null) {
            for (Part part : parts) FileUploadUtil.validateProductImage(part);
        }
    }

    public boolean hasUploadableImagePart(Collection<Part> parts) {
        if (parts == null) return false;
        for (Part part : parts) {
            if (part != null && part.getSize() > 0) return true;
        }
        return false;
    }

    public void setPrimary(int productId, int imageId) throws SQLException {
        validateProductExists(productId);
        ProductImage image = getOwnedImage(productId, imageId);
        if (!productImageDAO.setPrimary(productId, image.getImageId())) {
            throw new IllegalArgumentException("Không thể đặt ảnh chính.");
        }
    }

    public void deleteImage(int productId, int imageId) throws SQLException {
        validateProductExists(productId);
        ProductImage image = getOwnedImage(productId, imageId);
        if (!productImageDAO.delete(imageId)) {
            throw new IllegalArgumentException("Ảnh sản phẩm không tồn tại.");
        }
        if (productImageDAO.countByFilePath(image.getFilePath()) == 0) {
            FileUploadUtil.deleteUploadedFile(image.getFilePath());
        }
        if (image.isPrimary()) {
            productImageDAO.findFirstByProductId(productId)
                    .ifPresent(next -> setPrimaryAfterDelete(productId, next.getImageId()));
        }
    }

    private void setPrimaryAfterDelete(int productId, int imageId) {
        try {
            productImageDAO.setPrimary(productId, imageId);
        } catch (SQLException ex) {
            throw new IllegalStateException("Không thể chọn ảnh chính thay thế.", ex);
        }
    }

    private ProductImage getOwnedImage(int productId, int imageId) throws SQLException {
        if (imageId <= 0) throw new IllegalArgumentException("ID ảnh không hợp lệ.");
        ProductImage image = productImageDAO.findById(imageId)
                .orElseThrow(() -> new IllegalArgumentException("Ảnh sản phẩm không tồn tại."));
        if (image.getProductId() != productId) {
            throw new IllegalArgumentException("Ảnh không thuộc sản phẩm này.");
        }
        return image;
    }

    private Product validateProductExists(int productId) throws SQLException {
        if (productId <= 0) throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        return productService.getProductById(productId);
    }
}
