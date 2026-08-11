/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import model.CartItemView;
import model.User;
import service.CartService;
 
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
/**
 *
 * @author ACER
 */
@WebFilter(urlPatterns = {"/cart", "/cart/*"})
public class CustomerFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
 
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
 
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }
        if (!"CUSTOMER".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chức năng giỏ hàng chỉ dành cho khách hàng.");
            return;
        }
        chain.doFilter(req, res);
    }
}
