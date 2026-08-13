package controller.auth;

import model.entity.user.User;
import service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.html");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        try {
            User createdUser = authService.register(fullName, email, phone, password, confirmPassword);
            String redirectUrl = request.getContextPath() + "/login.html"
                    + "?registered=1&email=" + encode(createdUser.getEmail());
            response.sendRedirect(redirectUrl);
        } catch (IllegalArgumentException ex) {
            redirectWithError(request, response, ex.getMessage(), fullName, email, phone);
        } catch (SQLException ex) {
            redirectWithError(request, response,
                    "Unable to create the account right now. Please try again later.", fullName, email, phone);
        }
    }

    private void redirectWithError(HttpServletRequest request, HttpServletResponse response, String message,
            String fullName, String email, String phone) throws IOException {
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath())
                .append("/register.html?error=").append(encode(message));

        if (fullName != null) {
            redirectUrl.append("&fullName=").append(encode(fullName));
        }
        if (email != null) {
            redirectUrl.append("&email=").append(encode(email));
        }
        if (phone != null) {
            redirectUrl.append("&phone=").append(encode(phone));
        }

        response.sendRedirect(redirectUrl.toString());
    }

    private String encode(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
}
