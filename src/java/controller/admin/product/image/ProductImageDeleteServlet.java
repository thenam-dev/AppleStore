package controller.admin.product.image;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductImageDeleteServlet", urlPatterns = "/admin/products/images/delete")
public class ProductImageDeleteServlet extends ProductImageServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        int productId;
        try {
            productId = parseProductId(request);
            int imageId = parseImageId(request);
            productImageService.deleteImage(productId, imageId);
            redirectToImageManagement(request, response, productId, FLASH_SUCCESS_KEY, "Đã xóa ảnh sản phẩm.");
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
