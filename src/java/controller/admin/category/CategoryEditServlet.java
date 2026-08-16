package controller.admin.category;

import model.entity.catalog.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CategoryEditServlet", urlPatterns = {"/admin/categories/edit"})
public class CategoryEditServlet extends CategoryServletSupport {
    /** Mở form tạo mới hoặc form chỉnh sửa danh mục dựa trên tham số id. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String categoryId = request.getParameter("id");
            Category category = createDefaultCategory();

            if (categoryId != null && !categoryId.isBlank()) {
                category = categoryService.getCategoryById(parseInt(categoryId, "ID danh mục không hợp lệ."));
            }

            request.setAttribute("category", category);
            setCategoryFormOptions(request);
            moveFlashMessagesToRequest(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToCategoryListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
