package controller.admin.product;

import model.entity.catalog.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "ProductUpdateServlet", urlPatterns = {"/admin/products/update"})
public class ProductUpdateServlet extends ProductServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            Product product = buildProductFromRequest(request);

            if (product.getProductId() > 0) {
                productService.updateProduct(product);
                redirectToProductListWithMessage(request, response, FLASH_SUCCESS_KEY, "Product updated successfully.");
                return;
            }

            productService.createProduct(product);
            redirectToProductListWithMessage(request, response, FLASH_SUCCESS_KEY, "Product created successfully.");
        } catch (SQLException | IllegalArgumentException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        Product product = createDefaultProduct();
        product.setProductId(parseIntOrDefault(request.getParameter("productId"), 0));
        product.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));
        product.setModelCode(request.getParameter("modelCode"));
        product.setReleaseYear(parseNullableInt(request.getParameter("releaseYear"), "Release year is invalid."));
        product.setProductCondition(request.getParameter("productCondition"));
        product.setImportType(request.getParameter("importType"));
        product.setOriginCountry(request.getParameter("originCountry"));
        product.setWarrantyMonths(parseIntOrDefault(request.getParameter("warrantyMonths"), 12));
        product.setStatus(request.getParameter("status"));
        product.setFeatured("on".equals(request.getParameter("isFeatured")));

        request.setAttribute("product", product);
        request.setAttribute(FLASH_ERROR_KEY, message);
        try {
            setProductReferenceData(request);
        } catch (SQLException ex) {
            setProductReferenceDataFallback(request);
        }
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
