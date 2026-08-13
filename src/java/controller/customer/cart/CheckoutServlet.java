/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer.cart;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.cart.CartItem;
import service.cart.CartService;
import service.cart.CheckoutService;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final CartService cartService = new CartService();
    private final CheckoutService checkoutService = new CheckoutService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int customerId = getCustomerId(request);

        List<CartItem> items = cartService.getCartItems(customerId);
        if (items.isEmpty()) {
            request.getSession().setAttribute("errorMsg", "Giỏ hàng đang trống, không thể thanh toán");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        BigDecimal cartTotal = items.stream()
                .map(CartItem::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        request.setAttribute("cartItems", items);
        request.setAttribute("cartTotal", cartTotal);
        request.getRequestDispatcher("/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        int customerId = getCustomerId(request);

        CheckoutService.CheckoutForm form = new CheckoutService.CheckoutForm();
        form.customerId = customerId;
        form.deliveryAddress = request.getParameter("deliveryAddress");
        form.recipientName = request.getParameter("recipientName");
        form.recipientPhone = request.getParameter("recipientPhone");
        form.deliveryTimeSlot = request.getParameter("deliveryTimeSlot");
        form.notes = request.getParameter("notes");
        form.paymentMethod = request.getParameter("paymentMethod");

        CheckoutService.CheckoutResult result = checkoutService.checkout(form);

        if (!result.success) {
            // Lỗi validate/nghiệp vụ: forward lại (không redirect) để giữ dữ liệu đã nhập (rule 6),
            // request.getParameter vẫn còn nguyên nên checkout.jsp dùng ${param.xxx} để hiển thị lại.
            List<CartItem> items = cartService.getCartItems(customerId);
            BigDecimal cartTotal = items.stream()
                    .map(CartItem::getLineTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            request.setAttribute("cartItems", items);
            request.setAttribute("cartTotal", cartTotal);
            request.setAttribute("errorMsg", result.message);
            request.setAttribute("fieldErrors", result.fieldErrors);
            request.getRequestDispatcher("/customer/checkout.jsp").forward(request, response);
            return;
        }

        // Thành công: PRG - redirect sang trang thanh toán QR (CK) hoặc trang xác nhận đơn (COD)
        HttpSession session = request.getSession();
        if (result.qrCodeUrl != null) {
            session.setAttribute("successMsg", "Đặt hàng thành công, vui lòng quét mã để thanh toán");
            response.sendRedirect(request.getContextPath() + "/payment?orderId=" + result.orderId);
        } else {
            session.setAttribute("successMsg", "Đặt hàng thành công, đơn hàng #" + result.orderId + " đã được xác nhận");
            response.sendRedirect(request.getContextPath() + "/order-success?orderId=" + result.orderId);
        }
    }

    private int getCustomerId(HttpServletRequest request) {
        Object customerId = request.getSession().getAttribute("customerId");
        if (customerId == null) {
            throw new IllegalStateException("Khách chưa đăng nhập - AuthFilter phải chặn trước khi tới servlet này");
        }
        return (Integer) customerId;
    }
}

