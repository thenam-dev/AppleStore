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

/**
 * Filter này đảm bảo:
 * - Khi chưa đăng nhập (Guest): Ai cũng có thể vào các trang public (Home, Login, Shop...).
 * - Khi đăng nhập là CUSTOMER: Xem bình thường.
 * - Khi đăng nhập bằng Role khác (ADMIN, SALE_STAFF, DELIVERY): Không được vào Home, Cart, Profile...
 *   Nếu cố tình vào sẽ bị đá về Dashboard tương ứng của role đó.
 */
@WebFilter(urlPatterns = {"/*"})
public class RoleRedirectFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        HttpSession session = httpRequest.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);

        if (sessionUser instanceof User) {
            User user = (User) sessionUser;
            String role = user.getRole() == null ? "" : user.getRole().trim().toUpperCase();
            
            if (!AppConfig.ROLE_CUSTOMER.equals(role)) {
                String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
                
                // Những đường dẫn không bị chặn
                boolean isAllowedPath = path.startsWith("/admin") 
                                     || path.startsWith("/staff") 
                                     || path.startsWith("/logout") 
                                     || path.startsWith("/assets") 
                                     || path.startsWith("/change-password");
                                     
                if (!isAllowedPath) {
                    // Nếu là Admin/Sale cố tình vào trang Customer, đá về Dashboard
                    if (AppConfig.ROLE_ADMIN.equals(role) || AppConfig.ROLE_SALE_STAFF.equals(role)) {
                        httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/dashboard");
                        return;
                    } 
                    // Nếu là Shipper, đá về trang Tasks
                    else if ("DELIVERY".equals(role)) {
                        httpResponse.sendRedirect(httpRequest.getContextPath() + "/staff/tasks");
                        return;
                    }
                }
            }
        }
        
        chain.doFilter(request, response);
    }
}
