package controller.auth;

import service.AuthService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/auth/register.jsp";

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        Map<String, String> formValues = new HashMap<>();
        formValues.put("fullName", fullName == null ? "" : fullName);
        formValues.put("phone", phone == null ? "" : phone);
        formValues.put("email", email == null ? "" : email);

        try {
            AuthService.RegisterResult result = authService.register(fullName, email, phone, password, confirmPassword);

            if (!result.success) {
                request.setAttribute("form", formValues);
                request.setAttribute("errors", result.fieldErrors);
                request.getRequestDispatcher(VIEW).forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("successMsg", "Tạo tài khoản thành công, vui lòng đăng nhập.");
            response.sendRedirect(request.getContextPath() + "/login");
        } catch (SQLException ex) {
            request.setAttribute("form", formValues);
            request.setAttribute("errorMsg", "Hiện chưa thể tạo tài khoản. Vui lòng thử lại sau.");
            request.getRequestDispatcher(VIEW).forward(request, response);
        }
    }
}
