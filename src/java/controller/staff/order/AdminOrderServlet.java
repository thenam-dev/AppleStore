package controller.staff.order;

import config.AppConfig;
import model.entity.order.Order;
import model.entity.user.User;
import service.staff.order.StaffOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/staff/orders", "/staff/orders/status"})
public class AdminOrderServlet extends HttpServlet {

    private final StaffOrderService staffOrderService = new StaffOrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            if ("/staff/orders".equals(path)) {
                String statusFilter = req.getParameter("status");
                String keyword = req.getParameter("keyword");
                
                int page = 1;
                int pageSize = 10;
                if (req.getParameter("page") != null) {
                    try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
                }
                int offset = (page - 1) * pageSize;

                List<Order> orders = staffOrderService.getFilteredOrders(statusFilter, keyword, offset, pageSize);
                int pendingCount = staffOrderService.getFilteredOrders("CONFIRMED", null, 0, 1000).size();

                req.setAttribute("orders", orders);
                req.setAttribute("pendingCount", pendingCount);
                req.setAttribute("statusFilter", statusFilter);
                req.setAttribute("keyword", keyword);
                req.setAttribute("totalPages", 1);

                String codeParam = req.getParameter("code");
                if (codeParam != null && !codeParam.isBlank()) {
                    int orderId = Integer.parseInt(codeParam);
                    Order selectedOrder = staffOrderService.getOrderById(orderId);
                    req.setAttribute("selectedOrder", selectedOrder);
                }

                req.getRequestDispatcher("/WEB-INF/views/staff/orders.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            getServletContext().log("Lỗi tại AdminOrderServlet doGet", e);
            req.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/staff/orders.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            currentUser = (User) session.getAttribute(AppConfig.SESSION_USER);
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("code"));
            String newStatus = req.getParameter("status");
            String note = req.getParameter("note");
            String returnUrl = req.getParameter("returnUrl");

            Integer staffId = (currentUser != null) ? currentUser.getUserId() : null;
            
            staffOrderService.updateOrderStatus(orderId, newStatus, staffId, note);

            session.setAttribute("successMsg", "Đã cập nhật trạng thái đơn hàng thành công.");
            if (returnUrl != null && !returnUrl.isBlank()) {
                resp.sendRedirect(returnUrl);
            } else {
                resp.sendRedirect(req.getContextPath() + "/staff/orders");
            }

        } catch (Exception e) {
            getServletContext().log("Lỗi tại AdminOrderServlet doPost", e);
            session.setAttribute("errorMsg", "Lỗi khi cập nhật trạng thái: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/orders");
        }
    }
}