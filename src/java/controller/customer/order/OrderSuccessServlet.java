package controller.customer.order;

import config.AppConfig;
import dao.order.OrderDAO;
import model.entity.order.Order;
import model.entity.order.OrderItem;
import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "OrderSuccessServlet", urlPatterns = {"/order-success"})
public class OrderSuccessServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        try {
            Optional<Order> orderOpt = orderDAO.findById(orderId);
            if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
                request.getSession().setAttribute("errorMsg", "Không tìm thấy đơn hàng.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
            Order order = orderOpt.get();
            List<OrderItem> items = orderDAO.findItemsByOrderId(orderId);

            request.setAttribute("order", order);
            request.setAttribute("orderItems", items);

            // Đọc flash message (successMsg do CheckoutServlet/PaymentServlet set) rồi xoá đi
            HttpSession session = request.getSession();
            Object successMsg = session.getAttribute("successMsg");
            if (successMsg != null) {
                request.setAttribute("successMsg", successMsg);
                session.removeAttribute("successMsg");
            }

            request.getRequestDispatcher("/WEB-INF/views/customer/order-success.jsp").forward(request, response);
        } catch (SQLException e) {
            request.getSession().setAttribute("errorMsg", "Lỗi khi tải thông tin đơn hàng.");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private Integer parseOrderId(HttpServletRequest request) {
        String raw = request.getParameter("orderId");
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer getCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);
        if (!(sessionUser instanceof User)) {
            return null;
        }
        return ((User) sessionUser).getUserId();
    }
}