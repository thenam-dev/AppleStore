package controller.admin.user;

import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "UserListServlet", urlPatterns = {"/admin/users"})
public class UserListServlet extends UserServletSupport {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showUserList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showUserListFallback(request, response, ex.getMessage());
        }
    }

    private void showUserList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        List<User> users = userService.getUsers(keyword, role, status);

        request.setAttribute("users", users);
        setUserReferenceData(request);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRole", role);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("successMessage", request.getParameter("success"));
        request.setAttribute("errorMessage", firstNonBlank(
                (String) request.getAttribute("errorMessage"),
                request.getParameter("error")));

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    private void showUserListFallback(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("users", Collections.emptyList());
        request.setAttribute("errorMessage", message);
        setUserReferenceData(request);
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
