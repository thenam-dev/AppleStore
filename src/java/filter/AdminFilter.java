package filter;

import config.AppConfig;
import dao.user.UserDAO;
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
import java.sql.SQLException;
import java.util.Optional;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {
    private final UserDAO userDAO = new UserDAO();

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

        User user = refreshSessionUser((User) sessionUser, session);
        if (user == null || !"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            session.invalidate();
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            return;
        }

        String role = user.getRole() == null ? "" : user.getRole().trim().toUpperCase();
        if (AppConfig.ROLE_ADMIN.equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
    }

    private User refreshSessionUser(User sessionUser, HttpSession session) throws ServletException {
        try {
            Optional<User> freshUser = userDAO.findById(sessionUser.getUserId());
            if (freshUser.isEmpty()) {
                return null;
            }
            session.setAttribute(AppConfig.SESSION_USER, freshUser.get());
            return freshUser.get();
        } catch (SQLException ex) {
            throw new ServletException("Không thể kiểm tra quyền truy cập hiện tại.", ex);
        }
    }
}
