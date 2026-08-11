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
import model.CartItem;
import model.User;
import service.CartService;

/**
 *
 * @author ACER
 */
@WebServlet(name = "AddToCartServlet", urlPatterns = {"/cart/add"})
public class AddToCartServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    private final CartService cartService = new CartService();
 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("user") : null;
 
        // CustomerFilter (hoặc AuthFilter) đã chặn trước, đây là lớp kiểm tra thứ 2 cho chắc chắn.
        if (currentUser == null || !"CUSTOMER".equals(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.html");
            return;
        }
 
        String returnUrl = resolveReturnUrl(request);
 
        try {
            int variantId = Integer.parseInt(request.getParameter("variantId"));
            int quantity = parseQuantity(request.getParameter("quantity"));
            Integer addonId = parseAddonId(request.getParameter("addonId"));
 
            CartItem item = cartService.addToCart(currentUser.getUserId(), variantId, addonId, quantity);
 
            session.setAttribute("cartItemCount", cartService.countItemsInCart(currentUser.getUserId()));
            session.setAttribute("flashSuccess", "Item added to your cart.");
            response.sendRedirect(returnUrl);
 
        } catch (NumberFormatException ex) {
            session.setAttribute("flashError", "Invalid product data.");
            response.sendRedirect(returnUrl);
        } catch (IllegalArgumentException ex) {
            session.setAttribute("flashError", ex.getMessage());
            response.sendRedirect(returnUrl);
        } catch (SQLException ex) {
            getServletContext().log("AddToCartServlet - database error", ex);
            session.setAttribute("flashError", "A system error occurred, please try again later.");
            response.sendRedirect(returnUrl);
        }
    }
 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // Không cho phép GET vào /cart/add, tránh thêm hàng qua việc F5 lại trang.
        response.sendRedirect(request.getContextPath() + "/products.html");
    }
 
    private String resolveReturnUrl(HttpServletRequest request) {
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl == null || returnUrl.isBlank()) {
            return request.getContextPath() + "/product-detail.jsp";
        }
        return returnUrl;
    }
 
    private int parseQuantity(String raw) {
        if (raw == null || raw.isBlank()) {
            return 1;
        }
        int q = Integer.parseInt(raw.trim());
        if (q < 1) {
            throw new IllegalArgumentException("Quantity must be greater than 0.");
        }
        return q;
    }
 
    private Integer parseAddonId(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        return Integer.parseInt(raw.trim());
    }

}
