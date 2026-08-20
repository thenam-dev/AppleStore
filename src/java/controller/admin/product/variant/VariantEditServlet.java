package controller.admin.product.variant;

import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "VariantEditServlet", urlPatterns = {"/admin/products/variants/edit"})
public class VariantEditServlet extends VariantServletSupport {
    /** Mở form thêm mới hoặc chỉnh sửa biến thể, luôn gắn với một sản phẩm cha. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            ProductVariant variant;
            Product managedProduct;
            String variantId = request.getParameter("id");

            if (variantId != null && !variantId.isBlank()) {
                variant = productVariantService.getVariantById(parseInt(variantId, "ID biến thể không hợp lệ."));
                managedProduct = loadManagedProduct(variant.getProductId());
            } else {
                int productId = parseInt(request.getParameter("productId"), "ID sản phẩm không hợp lệ.");
                managedProduct = loadManagedProduct(productId);
                variant = createDefaultVariant(productId);
            }

            setManagedProduct(request, managedProduct);
            request.setAttribute("variant", variant);
            setVariantReferenceData(request, managedProduct);
            setVariantFormDateFields(request, variant);
            moveFlashMessagesToRequest(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
