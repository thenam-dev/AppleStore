package controller.admin.product.image;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.catalog.ProductImageService;

import java.io.IOException;

abstract class ProductImageServletSupport extends HttpServlet {
    protected static final String FLASH_SUCCESS_KEY = "successMsg";
    protected static final String FLASH_ERROR_KEY = "errorMsg";
    protected static final String PRODUCT_IMAGE_PATH = "/admin/products/images";

    protected final ProductImageService productImageService = new ProductImageService();

    protected int parseProductId(HttpServletRequest request) {
        return parseInt(request.getParameter("productId"), "ID sản phẩm không hợp lệ.");
    }

    protected int parseImageId(HttpServletRequest request) {
        return parseInt(request.getParameter("imageId"), "ID ảnh không hợp lệ.");
    }

    protected void redirectToImageManagement(HttpServletRequest request,
                                             HttpServletResponse response,
                                             int productId,
                                             String flashKey,
                                             String message) throws IOException {
        if (message != null && !message.isBlank()) {
            request.getSession().setAttribute(flashKey, message);
        }
        if (productId > 0) {
            response.sendRedirect(request.getContextPath() + PRODUCT_IMAGE_PATH + "?productId=" + productId);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    private int parseInt(String value, String errorMessage) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(errorMessage, ex);
        }
    }
}
