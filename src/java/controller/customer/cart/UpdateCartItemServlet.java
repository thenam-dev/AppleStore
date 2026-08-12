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
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.entity.user.User;
import service.CartService;

/**
 *
 * @author ACER
 */
@WebServlet(name = "UpdateCartItemServlet", urlPatterns = {"/cart/update"})
public class UpdateCartItemServlet extends HttpServlet {
 
    private final CartService cartService = new CartService();
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
 
        if (currentUser == null || !"CUSTOMER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }
 
        String cartUrl = request.getContextPath() + "/cart";
 
        try {
            int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
 
            cartService.updateQuantity(currentUser.getUserId(), cartItemId, quantity);
            session.setAttribute("flashSuccess", "Quantity updated.");
 
        } catch (NumberFormatException ex) {
            session.setAttribute("flashError", "Invalid quantity.");
        } catch (IllegalArgumentException ex) {
            session.setAttribute("flashError", ex.getMessage());
        } catch (SQLException ex) {
            getServletContext().log("UpdateCartItemServlet - database error", ex);
            session.setAttribute("flashError", "A system error occurred, please try again later.");
        }
 
        response.sendRedirect(cartUrl);
    }
}
