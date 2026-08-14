package controller.customer.product;

import dao.catalog.ProductDAO;
import dao.catalog.ProductVariantDAO;
import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;

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
import java.util.Optional;
import java.util.Set;

/**
 * Trang chi tiết sản phẩm cho khách hàng (guest).
 * URL: /product?id={productId}
 *
 * Dùng lại nguyên các hàm đã có trong DAO, KHÔNG thêm hàm mới:
 *   - ProductDAO.findById(productId) -> Optional<Product>
 *       (hàm này KHÔNG lọc status, nên servlet tự kiểm tra status = ACTIVE
 *        sau khi lấy về, coi như không tìm thấy nếu sản phẩm đã INACTIVE)
 *   - ProductVariantDAO.countByProduct(productId, null, "ACTIVE")
 *     + ProductVariantDAO.findByProduct(productId, null, "ACTIVE", "price_asc", 1, total)
 *       (không có hàm "lấy tất cả variant active" riêng, nên đếm trước rồi
 *        lấy đúng 1 trang bằng đúng tổng số đó)
 *   - ProductDAO.findAll(null, categoryId, "ACTIVE", "newest", 1, limit+1)
 *       dùng để gợi ý sản phẩm liên quan (không có hàm loại trừ id hiện tại
 *       sẵn trong DAO, nên servlet tự lọc bỏ sản phẩm đang xem khỏi kết quả)
 */
@WebServlet(name = "GuestProductDetailServlet", urlPatterns = {"/product"})
public class ProductDetailServlet extends ProductServletSupport {

    private static final String ACTIVE_STATUS = "ACTIVE";
    private static final int RELATED_LIMIT = 4;

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductVariantDAO productVariantDAO = new ProductVariantDAO();

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

        Optional<Product> productOpt = productDAO.findById(productId);
        if (productOpt.isEmpty() || !ACTIVE_STATUS.equalsIgnoreCase(productOpt.get().getStatus())) {
            showProductDetailFallback(request, response,
                    "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh");
            return;
        }
        Product product = productOpt.get();

        List<ProductVariant> variants = loadActiveVariants(productId);
        List<String> variantColors = distinctColors(variants);
        List<Integer> variantStorages = distinctStorages(variants);
        ProductVariant defaultVariant = pickDefaultVariant(variants);
        List<Product> relatedProducts = findRelatedProducts(product);

        request.setAttribute("product", product);
        request.setAttribute("variants", variants);
        request.setAttribute("variantColors", variantColors);
        request.setAttribute("variantStorages", variantStorages);
        request.setAttribute("defaultVariant", defaultVariant);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("lowStockThreshold", LOW_STOCK_THRESHOLD);

        request.getRequestDispatcher("/WEB-INF/views/guest/product-detail.jsp").forward(request, response);
    }

    private void showProductDetailFallback(HttpServletRequest request, HttpServletResponse response,
                                            String message) throws ServletException, IOException {
        request.setAttribute("errorMsg", message);
        request.setAttribute("product", null);
        request.getRequestDispatcher("/WEB-INF/views/guest/product-detail.jsp").forward(request, response);
    }

    /** Lấy toàn bộ variant active của sản phẩm: đếm trước rồi lấy đúng 1 trang bằng tổng đó. */
    private List<ProductVariant> loadActiveVariants(int productId) throws SQLException {
        int total = productVariantDAO.countByProduct(productId, null, ACTIVE_STATUS);
        if (total <= 0) {
            return Collections.emptyList();
        }
        return productVariantDAO.findByProduct(productId, null, ACTIVE_STATUS, "price_asc", 1, total);
    }

    /** Vài sản phẩm ACTIVE cùng danh mục, tự loại bỏ sản phẩm đang xem vì DAO chưa có tham số loại trừ id. */
    private List<Product> findRelatedProducts(Product product) throws SQLException {
        List<Product> candidates = productDAO.findAll(
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