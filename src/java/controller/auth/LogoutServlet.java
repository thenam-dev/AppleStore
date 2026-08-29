package controller.auth;

import config.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;

import java.io.IOException;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        boolean isCustomer = true;
        if (session != null) {
            Object sessionUser = session.getAttribute(AppConfig.SESSION_USER);
            if (sessionUser instanceof User) {
                String role = ((User) sessionUser).getRole();
                isCustomer = role != null && AppConfig.ROLE_CUSTOMER.equalsIgnoreCase(role.trim());
            }
            session.invalidate();
        }

        String redirectPath = isCustomer ? "/home" : "/login";
        response.sendRedirect(request.getContextPath() + redirectPath);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
