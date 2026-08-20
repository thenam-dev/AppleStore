package controller.admin.customer;

import service.user.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "CustomerStatusServlet", urlPatterns = {"/admin/customers/status"})
public class CustomerStatusServlet extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String redirectTo = sanitizeRedirect(request.getParameter("redirectTo"));

        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            userService.changeCustomerStatus(userId, request.getParameter("status"));
            request.getSession().setAttribute("successMsg", "Cập nhật trạng thái khách hàng thành công.");
        } catch (SQLException | IllegalArgumentException ex) {
            request.getSession().setAttribute("errorMsg", ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + redirectTo);
    }

    private String sanitizeRedirect(String redirectTo) {
        if (redirectTo == null || redirectTo.isBlank() || redirectTo.startsWith("//")) {
            return "/admin/customers";
        }
        if (!redirectTo.startsWith("/admin/customers")) {
            return "/admin/customers";
        }
        return redirectTo;
    }
}
