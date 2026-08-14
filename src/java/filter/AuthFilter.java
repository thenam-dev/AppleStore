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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(urlPatterns = {
        "/cart",
        "/checkout",
        "/payment",
        "/order-success"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);

        if (!(sessionUser instanceof User)) {
            redirectToLogin(httpRequest, httpResponse);
            return;
        }

        User user = (User) sessionUser;
        String role = user.getRole() == null ? "" : user.getRole().trim().toUpperCase();
        if (!AppConfig.ROLE_CUSTOMER.equals(role)) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        StringBuilder redirectTarget = new StringBuilder()
                .append(request.getRequestURI().substring(request.getContextPath().length()));

        String queryString = request.getQueryString();
        if (queryString != null && !queryString.isBlank()) {
            redirectTarget.append("?").append(queryString);
        }

        response.sendRedirect(request.getContextPath()
                + "/login?redirectTo="
                + URLEncoder.encode(redirectTarget.toString(), StandardCharsets.UTF_8));
    }
}
