package filter;

import config.AppConfig;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import service.cart.CartService;

import java.io.IOException;

/**
 * Đổ sẵn requestScope.cartItemCount cho mọi trang khách hàng có include
 * header.jsp, không riêng gì /cart (nơi CartServlet tự set biến này). Trước
 * đây home.jsp và products-list.jsp không hiện số lượng trong giỏ vì
 * HomeServlet/ProductListServlet chưa từng set "cartItemCount" - filter này
 * chạy trước mọi servlet khách hàng nên đảm bảo header luôn có dữ liệu.
 * Servlet nào tự set lại "cartItemCount" (vd. CartServlet) thì giá trị của
 * servlet đó vẫn thắng vì set sau, không xung đột.
 */
@WebFilter(urlPatterns = {
        "/home",
        "/products",
        "/product",
        "/cart",
        "/checkout",
        "/payment",
        "/order-success",
        "/vouchers",
        "/account/orders",
        "/addresses",
        "/profile",
        "/change-password"
})
public class CartBadgeFilter implements Filter {

    private final CartService cartService = new CartService();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);

        if (sessionUser instanceof User) {
            int customerId = ((User) sessionUser).getUserId();
            httpRequest.setAttribute("cartItemCount", cartService.getCartItemCount(customerId));
        }

        chain.doFilter(request, response);
    }
}
