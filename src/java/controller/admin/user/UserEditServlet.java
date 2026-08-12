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
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = parseInt(request.getParameter("id"), "User id is invalid.");
            User user = userService.getUserById(userId);

            request.setAttribute("user", user);
            moveFlashMessagesToRequest(request);
            setUserReferenceData(request);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            redirectToUserListWithMessage(request, response, FLASH_ERROR_KEY, ex.getMessage());
        }
    }
}
