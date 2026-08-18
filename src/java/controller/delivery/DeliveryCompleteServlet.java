package controller.delivery;

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
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        
        // Lấy thông tin Shipper đang đăng nhập
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            currentUser = (User) session.getAttribute("currentUser");
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            
            if (currentUser != null) {
                // Gọi service hoàn tất giao hàng kèm theo ID của shipper
                staffOrderService.completeDelivery(orderId, currentUser.getUserId());
            } else {
                staffOrderService.completeDelivery(orderId);
            }

            session.setAttribute("successMsg", "Đã xác nhận giao thành công đơn hàng #" + orderId);
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Lỗi xác nhận: " + e.getMessage());
        }
        
        // Điều hướng về lại trang danh sách nhiệm vụ của shipper (Sửa lại URL nếu trang tasks của bạn dùng đường dẫn khác như /staff/tasks)
        resp.sendRedirect(req.getContextPath() + "/staff/tasks");
    }
}