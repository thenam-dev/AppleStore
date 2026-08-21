package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

@WebFilter(urlPatterns = {"/update-profile"})
public class ProfileValidationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        
        request.setCharacterEncoding("UTF-8");

        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String avatarUrl = request.getParameter("avatarUrl");

            if (fullName == null || fullName.trim().isEmpty() || fullName.length() > 100 ||
                phone == null || phone.trim().isEmpty() || !phone.matches("^[0-9]{9,15}$")) {
                req.setAttribute("errorMsg", "Họ tên và số điện thoại không hợp lệ (từ 9-15 chữ số).");
                req.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
                return;
            }
            if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
                String urlLower = avatarUrl.toLowerCase();
                if (!urlLower.endsWith(".jpg") && !urlLower.endsWith(".jpeg") && !urlLower.endsWith(".png") && !urlLower.endsWith(".gif") && !urlLower.startsWith("http")) {
                    req.setAttribute("errorMsg", "Định dạng ảnh không hợp lệ (chỉ hỗ trợ URL jpg, jpeg, png, gif).");
                    req.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }
}
