package controller.admin.product.image;

import model.entity.catalog.Product;
import service.catalog.ProductService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductImageManagementViewServlet", urlPatterns = "/admin/products/images")
public class ProductImageManagementViewServlet extends ProductImageServletSupport {
    private static final String VIEW = "/WEB-INF/views/admin/product-images/form.jsp";
    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int productId = parseProductId(request);
            Product product = productService.getProductById(productId);

            request.setAttribute("product", product);
            request.setAttribute("productImages", productImageService.getImagesByProductId(productId));
            moveFlashMessagesToRequest(request);
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            setFlashMessage(request, FLASH_ERROR_KEY, ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    private void moveFlashMessagesToRequest(HttpServletRequest request) {
        moveFlashMessageToRequest(request, FLASH_SUCCESS_KEY);
        moveFlashMessageToRequest(request, FLASH_ERROR_KEY);
    }

    private void moveFlashMessageToRequest(HttpServletRequest request, String key) {
        HttpSession session = request.getSession(false);
        if (session == null) return;
        Object message = session.getAttribute(key);
        if (message instanceof String && !((String) message).isBlank()) {
            request.setAttribute(key, message);
        }
        session.removeAttribute(key);
    }

    private void setFlashMessage(HttpServletRequest request, String key, String message) {
        if (message != null && !message.isBlank()) {
            request.getSession().setAttribute(key, message);
        }
    }
}
