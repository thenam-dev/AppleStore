/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer.cart;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.CartItemView;
import model.entity.user.User;
import service.CartService;

/**
 *
 * @author ACER
 */
@WebServlet(name = "ViewCartServlet", urlPatterns = {"/cart"})
public class ViewCartServlet extends HttpServlet {
 
    private final CartService cartService = new CartService();
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
 
        if (currentUser == null || !"CUSTOMER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }
 
        try {
            List<CartItemView> cartItems = cartService.getCartItems(currentUser.getUserId());
            BigDecimal subtotal = cartService.getCartSubtotal(cartItems);
            int itemCount = cartService.countItemsInCart(cartItems);
 
            session.setAttribute("cartItemCount", itemCount);
            request.setAttribute("cartItems", cartItems);
            request.setAttribute("cartSubtotal", subtotal);
            request.setAttribute("cartItemCount", itemCount);
 
            request.getRequestDispatcher("/cart.jsp").forward(request, response);
 
        } catch (SQLException ex) {
            getServletContext().log("ViewCartServlet - database error", ex);
            request.setAttribute("flashError", "Unable to load your cart, please try again later.");
            request.setAttribute("cartItems", List.of());
            request.setAttribute("cartSubtotal", BigDecimal.ZERO);
            request.setAttribute("cartItemCount", 0);
            request.getRequestDispatcher("/cart.jsp").forward(request, response);
        }
    }
}
