package controller.admin.user;

import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "UserEditServlet", urlPatterns = {"/admin/users/edit"})
public class UserEditServlet extends UserServletSupport {
    /** Mở form tạo mới hoặc chỉnh sửa tài khoản nội bộ dựa trên tham số id. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String userId = request.getParameter("id");
            User user = createDefaultUser();

            if (userId != null && !userId.isBlank()) {
                user = userService.getStaffUserById(parseInt(userId, "ID người dùng không hợp lệ."));
            }

            request.setAttribute("user", user);
            request.setAttribute("currentAdminId", getCurrentAdminId(request));
            moveFlashMessagesToRequest(request);
            setUserReferenceData(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToUserListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
