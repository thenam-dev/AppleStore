package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

public class AdminFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;

        // TODO: Enable role checking after the login flow is implemented.
        // Expected roles for /admin/*: ADMIN, SALE_STAFF.
        httpRequest.setAttribute("adminFilterStatus", "pass-through");
        chain.doFilter(request, response);
    }
}
