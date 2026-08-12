package controller.admin.user;

import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "UserUpdateServlet", urlPatterns = {"/admin/users/update"})
public class UserUpdateServlet extends UserServletSupport {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            User user = buildUserFromRequest(request);
            userService.updateUser(user);
            redirectToUserListWithMessage(request, response, "success", "User updated successfully.");
        } catch (SQLException | IllegalArgumentException ex) {
            forwardBackToForm(request, response, ex.getMessage());
        }
    }

    private void forwardBackToForm(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        User user = new User();
        user.setUserId(parseIntOrDefault(request.getParameter("userId"), 0));
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setRole(request.getParameter("role"));
        user.setStatus(request.getParameter("status"));
        user.setEmailVerified("on".equals(request.getParameter("emailVerified")));

        request.setAttribute("user", user);
        request.setAttribute("errorMessage", message);
        setUserReferenceData(request);
        request.getRequestDispatcher(FORM_VIEW).forward(request, response);
    }
}
