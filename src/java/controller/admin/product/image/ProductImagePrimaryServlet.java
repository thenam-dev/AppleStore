package controller.admin.product.image;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductImagePrimaryServlet", urlPatterns = "/admin/products/images/primary")
public class ProductImagePrimaryServlet extends ProductImageServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        int productId;
        try {
            productId = parseProductId(request);
            int imageId = parseImageId(request);
            productImageService.setPrimary(productId, imageId);
            redirectToImageManagement(request, response, productId, FLASH_SUCCESS_KEY, "Đã đặt ảnh chính.");
        } catch (SQLException | IllegalArgumentException ex) {
            productId = parseProductIdSafely(request);
            redirectToImageManagement(request, response, productId, FLASH_ERROR_KEY, ex.getMessage());
        }
    }

    private int parseProductIdSafely(HttpServletRequest request) {
        try {
            return parseProductId(request);
        } catch (IllegalArgumentException ex) {
            return 0;
        }
    }
}
