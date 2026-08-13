package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

@WebFilter(urlPatterns = {
        "/admin/products",
        "/admin/products/*",
        "/admin/users",
        "/admin/users/*",
        "/admin/categories",
        "/admin/categories/*"
})
public class AdminFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;

        // Temporarily pass through while the login/session flow is not finished.
        httpRequest.setAttribute("adminFilterStatus", "pass-through");
        chain.doFilter(request, response);
    }
}
