package controller.admin.product.specification;

import model.entity.catalog.Product;
import model.entity.catalog.ProductSpecification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ProductSpecificationViewServlet", urlPatterns = {"/admin/products/specifications"})
public class ProductSpecificationViewServlet extends ProductSpecificationServletSupport {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int productId = parseProductId(request.getParameter("productId"));
            Product product = loadProduct(productId);
            List<ProductSpecification> specifications = specificationService.getSpecifications(productId);
            request.setAttribute("product", product);
            request.setAttribute("specificationRows", toFormRows(specifications));
            moveFlashMessagesToRequest(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, ex.getMessage());
        }
    }
}
