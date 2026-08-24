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

@WebServlet(name = "DeliveryCompleteServlet", urlPatterns = {"/delivery/complete"})
public class DeliveryCompleteServlet extends HttpServlet {

    private final StaffOrderService staffOrderService = new StaffOrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); // BẮT BUỘC (Rule 3)
        HttpSession session = req.getSession(false);
        User user = null;

        if (session != null) {
            user = (User) session.getAttribute("user");
            if (user == null) {
                user = (User) session.getAttribute(AppConfig.SESSION_USER);
            }
        }

        if (user == null || !"DELIVERY".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            // Gọi hàm hoàn tất giao hàng bám sát IDOR check của Shipper
            staffOrderService.completeDelivery(orderId, user.getUserId());
            session.setAttribute("successMsg", "Đã xác nhận giao thành công đơn hàng #" + orderId);
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Lỗi xác nhận: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/staff/tasks");
    }
}
