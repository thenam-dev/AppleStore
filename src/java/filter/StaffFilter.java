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

@WebFilter(urlPatterns = {"/staff/*"})
public class StaffFilter implements Filter {
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
        
        // Admin, Sale Staff, Delivery can access /staff/*
        if (AppConfig.ROLE_ADMIN.equals(role) || AppConfig.ROLE_SALE_STAFF.equals(role) || "DELIVERY".equals(role)) {
            chain.doFilter(request, response);
            return;
        }

        // If normal customer or unknown role tries to access, block them
        httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
    }
}
