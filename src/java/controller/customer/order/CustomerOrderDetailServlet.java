package controller.customer.order;

import config.AppConfig;
import model.entity.user.User;
import service.order.OrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "CustomerOrderDetailServlet", urlPatterns = {"/account/order-detail"})
public class CustomerOrderDetailServlet extends HttpServlet {

    private final OrderService customerOrderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("id"));
            Map<String, Object> orderDetail = customerOrderService.getOrderDetailWithItems(orderId, user.getUserId());

            if (orderDetail == null) {
                session.setAttribute("errorMsg", "Không tìm thấy đơn hàng.");
                resp.sendRedirect(req.getContextPath() + "/account/orders");
                return;
            }

            req.setAttribute("order", orderDetail);
            req.getRequestDispatcher("/WEB-INF/views/customer/order-detail.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account/orders");
        }
    }
}