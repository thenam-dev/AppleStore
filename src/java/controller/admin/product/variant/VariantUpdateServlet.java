package controller.admin.product.variant;

import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "VariantUpdateServlet", urlPatterns = {"/admin/products/variants/update"})
public class VariantUpdateServlet extends VariantServletSupport {
    /** Nhận dữ liệu form biến thể, phân nhánh tạo mới hoặc cập nhật rồi quay lại danh sách biến thể. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            ProductVariant variant = buildVariantFromRequest(request);

            if (variant.getVariantId() > 0) {
                productVariantService.updateVariant(variant);
                redirectToVariantListWithMessage(
                        request,
                        response,
                        variant.getProductId(),
                        FLASH_SUCCESS_KEY,
                        "Cập nhật biến thể thành công."
                );
                return;
            }

            productVariantService.createVariant(variant);
            redirectToVariantListWithMessage(
                    request,
                    response,
                    variant.getProductId(),
                    FLASH_SUCCESS_KEY,
                    "Tạo biến thể thành công."
            );
        } catch (SQLException | IllegalArgumentException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    /** Giữ lại dữ liệu đã nhập và quay lại form khi validate hoặc lưu biến thể thất bại. */
    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        ProductVariant variant = buildVariantFromRequestForRedisplay(request);
        Product managedProduct;

        try {
            managedProduct = loadManagedProduct(variant.getProductId());
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
            return;
        }

        setManagedProduct(request, managedProduct);
        request.setAttribute("variant", variant);
        request.setAttribute(FLASH_ERROR_KEY, message);
        setVariantReferenceData(request);
        request.setAttribute("discountStartValue", request.getParameter("discountStart"));
        request.setAttribute("discountEndValue", request.getParameter("discountEnd"));
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
