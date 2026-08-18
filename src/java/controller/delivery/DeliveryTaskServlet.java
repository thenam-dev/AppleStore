package controller.delivery;

import config.AppConfig;
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
import java.util.Map;

@WebServlet(name = "DeliveryTaskServlet", urlPatterns = {"/staff/tasks", "/staff/complete"})
public class DeliveryTaskServlet extends HttpServlet {

    private final StaffOrderService staffOrderService = new StaffOrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null || !"DELIVERY".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Map<String, Object>> tasks = staffOrderService.getShipperTasks(user.getUserId());
            req.setAttribute("tasks", tasks);
            req.getRequestDispatcher("/WEB-INF/views/staff/tasks.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null || !"DELIVERY".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            
            // Truyền orderId và userId của shipper để lưu vết changed_by và thời gian changed_at
            staffOrderService.completeDelivery(orderId, user.getUserId());

            req.getSession().setAttribute("successMsg", "Đã xác nhận giao thành công đơn hàng #" + orderId);
            resp.sendRedirect(req.getContextPath() + "/staff/tasks");

        } catch (Exception e) {
            req.getSession().setAttribute("errorMsg", "Lỗi xác nhận: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/tasks");
        }
    }
}