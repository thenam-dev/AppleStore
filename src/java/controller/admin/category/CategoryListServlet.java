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

        List<Category> allCategories = categoryService.getAllCategories();
        List<Category> filteredCategories = filterCategories(allCategories, keyword, status);

        request.setAttribute("categories", filteredCategories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", firstNonBlank(
                (String) request.getAttribute("errorMessage"),
                request.getParameter("error")));
        setCategoryMetrics(request, allCategories, filteredCategories);

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showCategoryListFallback(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("categories", Collections.emptyList());
        request.setAttribute("errorMessage", message);
        request.setAttribute("totalCategories", 0);
        request.setAttribute("activeCategories", 0L);
        request.setAttribute("inactiveCategories", 0L);
        request.setAttribute("filteredCategories", 0);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
