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

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Chặn truy cập các trang khách hàng yêu cầu đăng nhập. Session attribute mong
 * đợi: "user" (model.User) - khớp với filter.CustomerFilter và các servlet
 * trong controller.customer.cart.
 */
@WebFilter(urlPatterns = {
    "/profile.html", "/checkout.html", "/order-history.html",
    "/order-detail.html", "/wishlist.html", "/addresses.html"
})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        HttpSession session = httpRequest.getSession(false);
        Object user = (session != null) ? session.getAttribute("user") : null;

        if (user == null) {
            String target = httpRequest.getContextPath() + httpRequest.getServletPath();
            String redirectUrl = httpRequest.getContextPath() + "/login.html"
                    + "?error=" + URLEncoder.encode("Please log in to continue.", StandardCharsets.UTF_8)
                    + "&redirectTo=" + URLEncoder.encode(target, StandardCharsets.UTF_8);
            httpResponse.sendRedirect(redirectUrl);
            return;
        }

        chain.doFilter(request, response);
    }
}
