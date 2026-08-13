package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Set;

/**
 * Chặn truy cập /admin/* nếu chưa đăng nhập hoặc không có quyền phù hợp.
 * Session attribute mong đợi: "user" (model.User) - khớp với
 * filter.CustomerFilter.
 */
@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    private static final Set<String> ALLOWED_ROLES = Set.of("ADMIN", "SALE_STAFF");

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        Object attribute = (session != null) ? session.getAttribute("user") : null;

        if (!(attribute instanceof User authenticatedUser)) {
            String target = httpRequest.getContextPath() + httpRequest.getServletPath();
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.html"
                    + "?error=" + URLEncoder.encode("Please log in to continue.", StandardCharsets.UTF_8)
                    + "&redirectTo=" + URLEncoder.encode(target, StandardCharsets.UTF_8));
            return;
        }

        if (!ALLOWED_ROLES.contains(authenticatedUser.getRole())) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.html"
                    + "?error=" + URLEncoder.encode("You do not have permission to access this page.", StandardCharsets.UTF_8));
            return;
        }

        chain.doFilter(request, response);
    }
}
