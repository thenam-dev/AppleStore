package controller.customer.product;

import model.entity.catalog.Product;
import model.entity.catalog.ProductImage;
import model.entity.catalog.ProductSpecification;
import model.entity.catalog.ProductVariant;
import service.catalog.ProductImageService;
import service.catalog.ProductSpecificationService;
import service.catalog.ProductVariantAttributeService;
import service.catalog.ProductVariantService;
import service.review.ReviewService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.Map;
import java.util.LinkedHashMap;
import model.entity.review.Review;
import util.JsonUtil;

/**
 * Trang chi tiết sản phẩm cho khách hàng (guest).
 * URL: /product?id={productId}
 *
 * Controller chỉ gọi qua service (KHÔNG đụng thẳng DAO), service mới xuống DAO:
 *   - ProductService.getProductById(productId)
 *       (hàm này KHÔNG lọc status, nên servlet tự kiểm tra status = ACTIVE
 *        sau khi lấy về, coi như không tìm thấy nếu sản phẩm đã INACTIVE)
 *   - ProductVariantService.countVariants(productId, null, "ACTIVE")
 *     + ProductVariantService.getVariants(productId, null, "ACTIVE", "price_asc", 1, total)
 *       (không có hàm "lấy tất cả variant active" riêng, nên đếm trước rồi
 *        lấy đúng 1 trang bằng đúng tổng số đó)
 *   - ProductService.getProducts(null, categoryId, "ACTIVE", "newest", 1, limit+1)
 *       dùng để gợi ý sản phẩm liên quan (không có hàm loại trừ id hiện tại
 *       sẵn trong service, nên servlet tự lọc bỏ sản phẩm đang xem khỏi kết quả)
 *   - ReviewService.getReviewsByProductId(productId)
 */
@WebServlet(name = "GuestProductDetailServlet", urlPatterns = {"/product"})
public class ProductDetailServlet extends ProductServletSupport {

    private static final String ACTIVE_STATUS = "ACTIVE";
    private static final int RELATED_LIMIT = 4;

    private final ProductImageService productImageService = new ProductImageService();
    private final ProductSpecificationService productSpecificationService = new ProductSpecificationService();
    private final ProductVariantService productVariantService = new ProductVariantService();
    private final ProductVariantAttributeService productVariantAttributeService = new ProductVariantAttributeService();
    private final ReviewService reviewService = new ReviewService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showProductDetail(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showProductDetailFallback(request, response, ex.getMessage());
        }
    }

    private void showProductDetail(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        Integer productId = parseOptionalPositiveInt(
                request.getParameter("id"), "Mã sản phẩm không hợp lệ");

        if (productId == null) {
            response.sendRedirect(request.getContextPath() + "/products");
            return;
        }

        Product product;
        try {
            product = productService.getProductById(productId);
        } catch (IllegalArgumentException notFound) {
            showProductDetailFallback(request, response,
                    "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh");
            return;
        }
        if (!ACTIVE_STATUS.equalsIgnoreCase(product.getStatus())) {
            showProductDetailFallback(request, response,
                    "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh");
            return;
        }

        List<ProductImage> productImages = productImageService.getImagesByProductId(productId);
        List<ProductVariant> variants = loadActiveVariants(productId);
        List<ProductSpecification> productSpecifications = productSpecificationService.getSpecifications(productId);
        List<ProductVariantAttributeService.Definition> variantAttributeDefinitions =
                productVariantAttributeService.getDefinitions(product);
        ProductVariant defaultVariant = pickDefaultVariant(variants);
        List<Product> relatedProducts = findRelatedProducts(product);

        // Lấy danh sách đánh giá của sản phẩm này
        List<Review> reviews = reviewService.getReviewsByProductId(productId);
        
        request.setAttribute("product", product);
        request.setAttribute("productImages", productImages);
        request.setAttribute("variants", variants);
        request.setAttribute("productSpecifications", productSpecifications);
        request.setAttribute("variantAttributeDefinitions", variantAttributeDefinitions);
        request.setAttribute("variantJson", buildVariantJson(variants));
        request.setAttribute("variantAttributeJson", buildAttributeJson(variantAttributeDefinitions));
        request.setAttribute("defaultVariant", defaultVariant);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("reviews", reviews); // Truyền reviews ra JSP
        request.setAttribute("lowStockThreshold", LOW_STOCK_THRESHOLD);

        request.getRequestDispatcher("/WEB-INF/views/guest/product-detail.jsp").forward(request, response);
    }

    private String buildVariantJson(List<ProductVariant> variants) throws ServletException {
        List<Map<String, Object>> values = new ArrayList<>();
        for (ProductVariant variant : variants) {
            Map<String, Object> value = new LinkedHashMap<>();
            value.put("id", variant.getVariantId());
            value.put("color", variant.getColorName());
            value.put("storage", variant.getStorageCapacityGb());
            value.put("ram", variant.getRamGb());
            value.put("connectivity", variant.getConnectivity());
            value.put("caseSize", variant.getCaseSizeMm());
            value.put("price", variant.getPrice());
            value.put("discountPrice", variant.getDiscountPrice());
            value.put("discountStart", variant.getDiscountStart() == null ? null : variant.getDiscountStart().toString());
            value.put("discountEnd", variant.getDiscountEnd() == null ? null : variant.getDiscountEnd().toString());
            value.put("stock", variant.getStockQuantity());
            value.put("active", variant.isActive());
            values.add(value);
        }
        try {
            return JsonUtil.toJson(values).replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026");
        } catch (Exception ex) {
            throw new ServletException("Không thể chuẩn bị dữ liệu phiên bản.", ex);
        }
    }

    private String buildAttributeJson(List<ProductVariantAttributeService.Definition> definitions)
            throws ServletException {
        try {
            return JsonUtil.toJson(definitions);
        } catch (Exception ex) {
            throw new ServletException("Không thể chuẩn bị cấu hình phiên bản.", ex);
        }
    }

    private void showProductDetailFallback(HttpServletRequest request, HttpServletResponse response,
                                            String message) throws ServletException, IOException {
        request.setAttribute("errorMsg", message);
        request.setAttribute("product", null);
        request.getRequestDispatcher("/WEB-INF/views/guest/product-detail.jsp").forward(request, response);
    }

    /** Lấy toàn bộ variant active của sản phẩm: đếm trước rồi lấy đúng 1 trang bằng tổng đó. */
    private List<ProductVariant> loadActiveVariants(int productId) throws SQLException {
        int total = productVariantService.countVariants(productId, null, ACTIVE_STATUS);
        if (total <= 0) {
            return Collections.emptyList();
        }
        return productVariantService.getVariants(productId, null, ACTIVE_STATUS, "price_asc", 1, total);
    }

    /** Vài sản phẩm ACTIVE cùng danh mục, tự loại bỏ sản phẩm đang xem vì service chưa có tham số loại trừ id. */
    private List<Product> findRelatedProducts(Product product) throws SQLException {
        List<Product> candidates = productService.getProducts(
                null, product.getCategoryId(), ACTIVE_STATUS, "newest", 1, RELATED_LIMIT + 1);
        List<Product> related = new ArrayList<>();
        for (Product p : candidates) {
            if (p.getProductId() != product.getProductId()) {
                related.add(p);
            }
            if (related.size() >= RELATED_LIMIT) {
                break;
            }
        }
        return related;
    }

    /** Danh sách màu duy nhất, giữ nguyên thứ tự xuất hiện đầu tiên. */
    private List<String> distinctColors(List<ProductVariant> variants) {
        Set<String> seen = new LinkedHashSet<>();
        for (ProductVariant v : variants) {
            if (v.getColorName() != null && !v.getColorName().isBlank()) {
                seen.add(v.getColorName());
            }
        }
        return new ArrayList<>(seen);
    }

    /** Danh sách dung lượng duy nhất, giữ nguyên thứ tự xuất hiện đầu tiên. */
    private List<Integer> distinctStorages(List<ProductVariant> variants) {
        Set<Integer> seen = new LinkedHashSet<>();
        for (ProductVariant v : variants) {
            if (v.getStorageCapacityGb() != null) {
                seen.add(v.getStorageCapacityGb());
            }
        }
        return new ArrayList<>(seen);
    }

    /** Variant mặc định để chọn sẵn khi vào trang: ưu tiên variant active còn hàng, nếu không thì lấy variant đầu tiên. */
    private ProductVariant pickDefaultVariant(List<ProductVariant> variants) {
        for (ProductVariant v : variants) {
            if (v.isActive() && v.getStockQuantity() > 0) {
                return v;
            }
        }
        return variants.isEmpty() ? null : variants.get(0);
    }
}
