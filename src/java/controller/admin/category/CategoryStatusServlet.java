package controller.admin.category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CategoryStatusServlet", urlPatterns = {"/admin/categories/status"})
public class CategoryStatusServlet extends CategoryServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int categoryId = parseInt(request.getParameter("categoryId"), "Category id is invalid.");
            categoryService.toggleCategoryStatus(categoryId);
            redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Category status updated.");
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToCategoryListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
