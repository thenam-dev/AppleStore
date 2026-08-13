package controller.customer.cart;

import config.AppConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.cart.CartItem;
import model.entity.user.User;
import service.cart.CartService;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * Controller giỏ hàng: GET hiển thị trang cart.jsp, POST xử lý add/update/remove
 * rồi redirect lại chính trang giỏ hàng theo PRG (rule 10).
 * customerId được suy ra từ User trong session, không tin request param.
 */
@WebServlet("/cart")
public class CartServlet extends HttpServlet {

    private final CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            redirectToLogin(request, response);
            return;
        }

        List<CartItem> items = cartService.getCartItems(customerId);
        BigDecimal cartTotal = items.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        boolean hasOverStockItem = items.stream().anyMatch(CartItem::isOverStock);
        int cartItemCount = items.stream().mapToInt(CartItem::getQuantity).sum();

        request.setAttribute("cartItems", items);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("hasOverStockItem", hasOverStockItem);
        request.setAttribute("cartItemCount", cartItemCount);

        // Đọc flash message từ session (đã set ở doPost sau khi redirect) rồi xoá đi
        readFlashMessage(request);

        request.getRequestDispatcher("/WEB-INF/views/customer/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            redirectToLogin(request, response);
            return;
        }
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        CartService.Result result;
        switch (action == null ? "" : action) {
            case "add":
                result = handleAdd(request, customerId);
                break;
            case "update":
                result = handleUpdate(request, customerId);
                break;
            case "remove":
                result = handleRemove(request, customerId);
                break;
            default:
                result = new CartService.Result(false, "Hành động không hợp lệ");
        }

        if (result.isSuccess()) {
            session.setAttribute("successMsg", result.getMessage());
        } else {
            session.setAttribute("errorMsg", result.getMessage());
        }

        // PRG: luôn redirect về GET /cart sau khi xử lý xong POST
        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private CartService.Result handleAdd(HttpServletRequest request, int customerId) {
        try {
            int variantId = Integer.parseInt(request.getParameter("variantId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String addonParam = request.getParameter("addonId");
            Integer addonId = (addonParam == null || addonParam.isBlank()) ? null : Integer.parseInt(addonParam);
            return cartService.addToCart(customerId, variantId, quantity, addonId);
        } catch (NumberFormatException e) {
            return new CartService.Result(false, "Dữ liệu gửi lên không hợp lệ");
        }
    }

    private CartService.Result handleUpdate(HttpServletRequest request, int customerId) {
        try {
            int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            return cartService.updateQuantity(customerId, cartItemId, quantity);
        } catch (NumberFormatException e) {
            return new CartService.Result(false, "Dữ liệu gửi lên không hợp lệ");
        }
    }

    private CartService.Result handleRemove(HttpServletRequest request, int customerId) {
        try {
            int cartItemId = Integer.parseInt(request.getParameter("cartItemId"));
            return cartService.removeItem(customerId, cartItemId);
        } catch (NumberFormatException e) {
            return new CartService.Result(false, "Dữ liệu gửi lên không hợp lệ");
        }
    }

    private void readFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession();
        Object successMsg = session.getAttribute("successMsg");
        Object errorMsg = session.getAttribute("errorMsg");
        if (successMsg != null) {
            request.setAttribute("successMsg", successMsg);
            session.removeAttribute("successMsg");
        }
        if (errorMsg != null) {
            request.setAttribute("errorMsg", errorMsg);
            session.removeAttribute("errorMsg");
        }
    }

    /** Trả về customerId từ User trong session - AuthFilter là lớp chặn chính, đây là lớp phòng thủ thêm. */
    private Integer getCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);
        if (!(sessionUser instanceof User)) {
            return null;
        }

        return ((User) sessionUser).getUserId();
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String redirectTarget = request.getRequestURI().substring(request.getContextPath().length());
        String queryString = request.getQueryString();
        if (queryString != null && !queryString.isBlank()) {
            redirectTarget += "?" + queryString;
        }

        response.sendRedirect(request.getContextPath()
                + "/login?redirectTo="
                + URLEncoder.encode(redirectTarget, StandardCharsets.UTF_8));
    }
}
