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
    /** Nhận dữ liệu form sản phẩm, phân nhánh tạo mới hoặc cập nhật rồi redirect về danh sách. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            Product product = buildProductFromRequest(request);

            if (product.getProductId() > 0) {
                productService.updateProduct(product);
                redirectToProductListWithMessage(request, response, FLASH_SUCCESS_KEY, "Cập nhật sản phẩm thành công.");
                return;
            }

            int productId = productService.createProduct(product);
            redirectToProductImagesWithMessage(request, response, productId, FLASH_SUCCESS_KEY,
                    "Tạo sản phẩm thành công. Bạn có thể thêm ảnh ngay bây giờ.");
        } catch (SQLException | IllegalArgumentException | IOException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    /** Giữ lại dữ liệu đã nhập và quay về form khi validate hoặc lưu sản phẩm thất bại. */
    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        Product product = createDefaultProduct();
        product.setProductId(parseIntOrDefault(request.getParameter("productId"), 0));
        product.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        product.setName(request.getParameter("name"));
        product.setDescription(request.getParameter("description"));
        product.setModelCode(request.getParameter("modelCode"));
        product.setReleaseYear(parseNullableInt(request.getParameter("releaseYear"), "Năm phát hành không hợp lệ."));
        product.setProductCondition(request.getParameter("productCondition"));
        product.setImportType(request.getParameter("importType"));
        product.setOriginCountry(request.getParameter("originCountry"));
        product.setWarrantyMonths(parseIntOrDefault(request.getParameter("warrantyMonths"), 12));
        product.setStatus(request.getParameter("status"));
        product.setFeatured("on".equals(request.getParameter("isFeatured")));

        request.setAttribute("product", product);
        request.setAttribute(FLASH_ERROR_KEY, message);
        try {
            setProductReferenceData(request, product);
        } catch (SQLException ex) {
            setProductReferenceDataFallback(request);
        }
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
