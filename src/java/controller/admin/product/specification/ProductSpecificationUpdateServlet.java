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

@WebServlet(name = "ProductSpecificationUpdateServlet", urlPatterns = {"/admin/products/specifications/update"})
public class ProductSpecificationUpdateServlet extends ProductSpecificationServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int productId;
        try {
            productId = parseProductId(request.getParameter("productId"));
            List<ProductSpecification> specifications = buildSpecifications(request, productId);
            specificationService.replaceSpecifications(productId, specifications);
            redirectWithMessage(request, response, productId, FLASH_SUCCESS_KEY,
                    "Lưu thông số kỹ thuật thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            try {
                productId = parseProductId(request.getParameter("productId"));
                Product product = loadProduct(productId);
                request.setAttribute("product", product);
                request.setAttribute("specificationRows", buildFormRows(request));
                request.setAttribute(FLASH_ERROR_KEY, ex.getMessage());
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);
            } catch (SQLException | IllegalArgumentException fallbackEx) {
                redirectToProductListWithMessage(request, response, fallbackEx.getMessage());
            }
        }
    }
}
