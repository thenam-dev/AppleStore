package controller.admin.category;

import model.entity.catalog.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CategoryUpdateServlet", urlPatterns = {"/admin/categories/update"})
public class CategoryUpdateServlet extends CategoryServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            Category category = buildCategoryFromRequest(request);

            if (category.getCategoryId() > 0) {
                categoryService.updateCategory(category);
                redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Category updated successfully.");
                return;
            }

            categoryService.createCategory(category);
            redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Category created successfully.");
        } catch (SQLException | IllegalArgumentException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        Category category = new Category();
        category.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        category.setName(request.getParameter("name"));
        category.setSlug(request.getParameter("slug"));
        category.setDisplayOrder(parseIntOrDefault(request.getParameter("displayOrder"), 0));
        category.setIsActive("on".equals(request.getParameter("isActive")));

        request.setAttribute("category", category);
        request.setAttribute(FLASH_ERROR_KEY, message);
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
