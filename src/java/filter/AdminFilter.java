package filter;

import config.AppConfig;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;

import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);

        if (!(sessionUser instanceof User)) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        User user = (User) sessionUser;
        String role = user.getRole() == null ? "" : user.getRole().trim().toUpperCase();
        String adminPath = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        if (AppConfig.ROLE_ADMIN.equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        if (AppConfig.ROLE_SALE_STAFF.equals(role) && isSaleStaffAdminPath(adminPath)) {
            chain.doFilter(request, response);
            return;
        }

        httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
    }

    private boolean isSaleStaffAdminPath(String path) {
        return "/admin/dashboard".equals(path)
                || path.startsWith("/admin/orders");
    }
}
