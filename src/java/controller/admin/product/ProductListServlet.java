package controller.admin.product;

import config.AppConfig;
import model.entity.catalog.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "ProductListServlet", urlPatterns = {"/admin/products"})
public class ProductListServlet extends ProductServletSupport {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showProductList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showProductListFallback(request, response, ex.getMessage());
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = request.getParameter("keyword");
        Integer categoryId = parseOptionalPositiveInt(request.getParameter("categoryId"), "Category filter is invalid.");
        String status = request.getParameter("status");
        String sort = normalizeProductSort(request.getParameter("sort"));
        int currentPage = parsePage(request.getParameter("page"));
        int pageSize = AppConfig.PAGE_SIZE_ADMIN;
        int filteredProducts = productService.countProducts(keyword, categoryId, status);
        int totalPages = calculateTotalPages(filteredProducts, pageSize);
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        List<Product> products = productService.getProducts(keyword, categoryId, status, sort, currentPage, pageSize);
        String listQuery = buildProductListQueryString(keyword, categoryId, status, sort);

        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedCategoryId", categoryId);
        request.setAttribute("selectedStatus", status == null ? null : status.trim().toUpperCase());
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("filteredProducts", filteredProducts);
        request.setAttribute("totalProducts", productService.countProducts(null, null, null));
        request.setAttribute("activeProducts", productService.countProductsByStatus("ACTIVE"));
        request.setAttribute("inactiveProducts", productService.countProductsByStatus("INACTIVE"));
        request.setAttribute("discontinuedProducts", productService.countProductsByStatus("DISCONTINUED"));
        request.setAttribute("listQuery", listQuery);
        request.setAttribute("listQuerySuffix", listQuery.isBlank() ? "" : "&" + listQuery);
        setProductReferenceData(request);
        moveFlashMessagesToRequest(request);

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showProductListFallback(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("products", Collections.emptyList());
        request.setAttribute(FLASH_ERROR_KEY, message);
        request.setAttribute("selectedSort", "newest");
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 1);
        request.setAttribute("filteredProducts", 0);
        request.setAttribute("totalProducts", 0);
        request.setAttribute("activeProducts", 0);
        request.setAttribute("inactiveProducts", 0);
        request.setAttribute("discontinuedProducts", 0);
        request.setAttribute("listQuery", "");
        request.setAttribute("listQuerySuffix", "");
        setProductReferenceDataFallback(request);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
