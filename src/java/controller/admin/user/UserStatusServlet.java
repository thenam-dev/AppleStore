package controller.admin.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "UserStatusServlet", urlPatterns = {"/admin/users/status"})
public class UserStatusServlet extends UserServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int userId = parseInt(request.getParameter("userId"), "User id is invalid.");
            String status = request.getParameter("status");

            userService.changeStatus(userId, status);
            redirectToUserListWithMessage(request, response, FLASH_SUCCESS_KEY, "User status updated.");
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToUserListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
