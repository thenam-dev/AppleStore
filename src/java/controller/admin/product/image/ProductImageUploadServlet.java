package controller.admin.product.image;

import config.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProductImageUploadServlet", urlPatterns = "/admin/products/images/upload")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = AppConfig.MAX_UPLOAD_SIZE_BYTES,
        maxRequestSize = AppConfig.MAX_UPLOAD_SIZE_BYTES * 6L
)
public class ProductImageUploadServlet extends ProductImageServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        int productId;
        try {
            productId = parseProductId(request);
            List<Part> imageParts = new ArrayList<>();
            for (Part part : request.getParts()) {
                if ("images".equals(part.getName()) && part.getSize() > 0) {
                    imageParts.add(part);
                }
            }

            int uploaded = productImageService.uploadImages(productId, imageParts);
            redirectToImageManagement(request, response, productId, FLASH_SUCCESS_KEY,
                    "Đã thêm " + uploaded + " ảnh sản phẩm.");
        } catch (SQLException | IllegalArgumentException | IllegalStateException | IOException | ServletException ex) {
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
