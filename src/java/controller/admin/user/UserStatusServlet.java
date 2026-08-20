package controller.admin.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "UserStatusServlet", urlPatterns = {"/admin/users/status"})
public class UserStatusServlet extends UserServletSupport {
    /** Đổi trạng thái tài khoản người dùng từ màn danh sách. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int userId = parseInt(request.getParameter("userId"), "ID người dùng không hợp lệ.");
            String status = request.getParameter("status");

            userService.changeStaffStatus(userId, status, getCurrentAdminId(request));
            redirectToUserListWithMessage(request, response, FLASH_SUCCESS_KEY, "Cập nhật trạng thái người dùng thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToUserListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
