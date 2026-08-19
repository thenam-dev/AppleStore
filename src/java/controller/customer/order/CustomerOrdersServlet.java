package controller.customer.order;

import config.AppConfig;
import model.entity.user.User;
import service.order.CustomerOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CustomerOrdersServlet", urlPatterns = {"/account/orders", "/order/cancel"})
public class CustomerOrdersServlet extends HttpServlet {

    private final CustomerOrderService customerOrderService = new CustomerOrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;
        
        if (user == null && session != null) {
            user = (User) session.getAttribute("user");
        }

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int customerId = user.getUserId();
            String tab = req.getParameter("tab");
            if (tab == null || tab.isBlank()) {
                tab = "all"; // Mặc định hiển thị tất cả đơn hàng
            }
            
            String codeParam = req.getParameter("code");

            List<Map<String, Object>> orders = customerOrderService.getCustomerOrders(customerId, tab);
            
            int allCount = customerOrderService.getAllCount(customerId);
            int activeCount = customerOrderService.getActiveCount(customerId);
            int completedCount = customerOrderService.getCompletedCount(customerId);

            Map<String, Object> selectedOrder = null;
            if (!orders.isEmpty()) {
                int targetOrderId = -1;
                if (codeParam != null && codeParam.startsWith("DH")) {
                    try {
                        targetOrderId = Integer.parseInt(codeParam.substring(2));
                    } catch (Exception ignored) {}
                }

                if (targetOrderId > 0) {
                    selectedOrder = customerOrderService.getSelectedOrderDetail(targetOrderId, customerId);
                }
                
                if (selectedOrder == null) {
                    Map<String, Object> firstOrder = orders.get(0);
                    selectedOrder = customerOrderService.getSelectedOrderDetail((int) firstOrder.get("rawId"), customerId);
                }
            }

            req.setAttribute("orders", orders);
            req.setAttribute("tab", tab);
            req.setAttribute("allCount", allCount);
            req.setAttribute("activeCount", activeCount);
            req.setAttribute("completedCount", completedCount);
            req.setAttribute("selectedOrder", selectedOrder);

            req.getRequestDispatcher("/WEB-INF/views/customer/orders.jsp").forward(req, resp);

        } catch (Exception e) {
            getServletContext().log("Lỗi CustomerOrdersServlet GET", e);
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            String codeParam = req.getParameter("code");
            if (codeParam != null && codeParam.startsWith("DH")) {
                int orderId = Integer.parseInt(codeParam.substring(2));
                boolean cancelled = customerOrderService.cancelOrder(orderId, user.getUserId());
                if (cancelled) {
                    session.setAttribute("successMsg", "Đã huỷ thành công đơn hàng #" + orderId);
                } else {
                    session.setAttribute("errorMsg", "Không thể huỷ đơn hàng này.");
                }
            }
            // Quay lại đúng tab mà khách hàng vừa gửi request (hoặc "all" nếu không có)
            String tabRedirect = req.getParameter("tab") != null ? req.getParameter("tab") : "all";
            resp.sendRedirect(req.getContextPath() + "/account/orders?tab=" + tabRedirect);
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Lỗi xử lý huỷ đơn: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/account/orders?tab=all");
        }
    }
}