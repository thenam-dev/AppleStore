package controller.admin.category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CategoryStatusServlet", urlPatterns = {"/admin/categories/status"})
public class CategoryStatusServlet extends CategoryServletSupport {
    /** Đổi trạng thái danh mục giữa ACTIVE và INACTIVE theo form gửi từ danh sách. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int categoryId = parseInt(request.getParameter("categoryId"), "ID danh mục không hợp lệ.");
            String status = request.getParameter("status");
            categoryService.changeCategoryStatus(categoryId, status);
            redirectToCategoryListWithMessage(request, response, FLASH_SUCCESS_KEY, "Cập nhật trạng thái danh mục thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToCategoryListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
