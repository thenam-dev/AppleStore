package controller.admin.product;

import model.entity.catalog.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductEditServlet", urlPatterns = {"/admin/products/edit"})
public class ProductEditServlet extends ProductServletSupport {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String productId = request.getParameter("id");
            Product product = createDefaultProduct();

            if (productId != null && !productId.isBlank()) {
                product = productService.getProductById(parseInt(productId, "Product id is invalid."));
            }

            request.setAttribute("product", product);
            setProductReferenceData(request);
            moveFlashMessagesToRequest(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
