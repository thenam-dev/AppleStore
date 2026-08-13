package controller.admin.product.variant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "VariantStatusServlet", urlPatterns = {"/admin/products/variants/status"})
public class VariantStatusServlet extends VariantServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int productId = parseIntOrDefault(request.getParameter("productId"), 0);

        try {
            int variantId = parseInt(request.getParameter("variantId"), "ID biến thể không hợp lệ.");
            productId = parseInt(request.getParameter("productId"), "ID sản phẩm không hợp lệ.");
            boolean isActive = parseRequiredVariantStatusToActive(request.getParameter("status"));
            productVariantService.changeStatus(variantId, isActive);
            redirectToVariantListWithMessage(request, response, productId, FLASH_SUCCESS_KEY, "Cập nhật trạng thái biến thể thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            if (productId > 0) {
                redirectToVariantListWithMessage(request, response, productId, FLASH_ERROR_KEY, ex.getMessage());
                return;
            }
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
