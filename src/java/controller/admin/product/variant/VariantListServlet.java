package controller.admin.product.variant;

import config.AppConfig;
import model.entity.catalog.Product;
import model.entity.catalog.ProductVariant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "VariantListServlet", urlPatterns = {"/admin/products/variants"})
public class VariantListServlet extends VariantServletSupport {
    /** Mở danh sách biến thể của một sản phẩm cụ thể. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showVariantList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToProductListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }

    /** Lấy filter, phân trang, thống kê biến thể rồi forward sang list.jsp của variant. */
    private void showVariantList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int productId = parseInt(request.getParameter("productId"), "ID sản phẩm không hợp lệ.");
        Product managedProduct = loadManagedProduct(productId);
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String sort = normalizeVariantSort(request.getParameter("sort"));
        int currentPage = parsePage(request.getParameter("page"));
        int pageSize = AppConfig.PAGE_SIZE_ADMIN;
        int filteredVariants = productVariantService.countVariants(productId, keyword, status);
        int totalPages = calculateTotalPages(filteredVariants, pageSize);
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        List<ProductVariant> variants = productVariantService.getVariants(productId, keyword, status, sort, currentPage, pageSize);
        String listQuery = buildVariantListQueryString(keyword, status, sort);

        setManagedProduct(request, managedProduct);
        request.setAttribute("variants", variants);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status == null ? null : status.trim().toUpperCase());
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("filteredVariants", filteredVariants);
        request.setAttribute("totalVariants", productVariantService.countVariants(productId, null, null));
        request.setAttribute("activeVariants", productVariantService.countVariantsByStatus(productId, "ACTIVE"));
        request.setAttribute("inactiveVariants", productVariantService.countVariantsByStatus(productId, "INACTIVE"));
        request.setAttribute("listQuery", listQuery);
        request.setAttribute("listQuerySuffix", listQuery.isBlank() ? "" : "&" + listQuery);
        setVariantReferenceData(request, managedProduct);
        moveFlashMessagesToRequest(request);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
