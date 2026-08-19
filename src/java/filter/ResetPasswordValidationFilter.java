package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

@WebFilter(urlPatterns = {"/forgot-password"})
public class ResetPasswordValidationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        
        request.setCharacterEncoding("UTF-8");

        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String action = request.getParameter("action");
            if ("resetPassword".equals(action)) {
                String newPass = request.getParameter("newPassword");
                
                if (newPass == null || newPass.trim().isEmpty() || newPass.length() < 8 || !newPass.matches(".*[A-Za-z].*") || !newPass.matches(".*\\d.*")) {
                    req.setAttribute("errorMsg", "Mật khẩu phải có ít nhất 8 ký tự, bao gồm cả chữ và số.");
                    req.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }
}
