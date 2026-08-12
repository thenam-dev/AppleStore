package controller.admin.category;

import model.entity.catalog.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "CategoryListServlet", urlPatterns = {"/admin/categories"})
public class CategoryListServlet extends CategoryServletSupport {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showCategoryList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showCategoryListFallback(request, response, ex.getMessage());
        }
    }

    private void showCategoryList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String status = normalizeStatusFilter(request.getParameter("status"));
        String sort = normalizeCategorySort(request.getParameter("sort"));
        int currentPage = parsePage(request.getParameter("page"));
        int pageSize = config.AppConfig.PAGE_SIZE_ADMIN;
        List<Category> allCategories = categoryService.getAllCategories();
        int filteredCount = categoryService.countCategories(keyword, status);
        int totalPages = calculateTotalPages(filteredCount, pageSize);
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }
        List<Category> categories = categoryService.getCategories(keyword, status, sort, currentPage, pageSize);

        request.setAttribute("categories", categories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("listQuery", buildCategoryListQueryString(keyword, status, sort));
        moveFlashMessagesToRequest(request);
        setCategoryMetrics(request, allCategories, filteredCount);

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showCategoryListFallback(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("categories", Collections.emptyList());
        request.setAttribute(FLASH_ERROR_KEY, message);
        request.setAttribute("totalCategories", 0);
        request.setAttribute("activeCategories", 0L);
        request.setAttribute("inactiveCategories", 0L);
        request.setAttribute("filteredCategories", 0);
        request.setAttribute("selectedSort", "display_asc");
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 1);
        request.setAttribute("listQuery", "");
        request.setAttribute("sortOptions", java.util.List.of());
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
