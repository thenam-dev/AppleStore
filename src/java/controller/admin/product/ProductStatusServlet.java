package controller.admin.product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductStatusServlet", urlPatterns = {"/admin/products/status"})
public class ProductStatusServlet extends ProductServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int productId = parseInt(request.getParameter("productId"), "Product id is invalid.");
            String status = request.getParameter("status");
            productService.changeStatus(productId, status);
            redirectToProductListWithMessage(request, response, FLASH_SUCCESS_KEY, "Product status updated.");
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
