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
    /** Nhận dữ liệu form danh mục, phân nhánh tạo mới hoặc cập nhật rồi redirect về danh sách. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            Category category = buildCategoryFromRequest(request);

            if (category.getCategoryId() > 0) {
                categoryService.updateCategory(category);
                redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Cập nhật danh mục thành công.");
                return;
            }

            categoryService.createCategory(category);
            redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Tạo danh mục thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    /** Giữ lại dữ liệu người dùng đã nhập và quay lại form khi validate hoặc lưu DB thất bại. */
    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        Category category = new Category();
        category.setCategoryId(parseIntOrDefault(request.getParameter("categoryId"), 0));
        category.setName(request.getParameter("name"));
        category.setSlug(request.getParameter("slug"));
        category.setDisplayOrder(parseIntOrDefault(request.getParameter("displayOrder"), 0));
        category.setIsActive(parseCategoryStatusToActiveOrDefault(request.getParameter("status"), true));

        request.setAttribute("category", category);
        request.setAttribute(FLASH_ERROR_KEY, message);
        setCategoryFormOptions(request);
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
