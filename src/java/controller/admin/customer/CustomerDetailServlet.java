package controller.admin.customer;

import model.entity.user.User;
import service.user.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CustomerDetailServlet", urlPatterns = {"/admin/customers/detail"})
public class CustomerDetailServlet extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/admin/customers/detail.jsp";
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            User customer = userService.getCustomerById(customerId);
            request.setAttribute("customer", customer);
            request.setAttribute("statuses", userService.getAllowedStatuses());
            request.getRequestDispatcher(VIEW).forward(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            request.getSession().setAttribute("errorMsg", ex.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
}
