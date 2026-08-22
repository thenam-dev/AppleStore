package controller.staff.order;

import model.entity.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "StaffOrderStatusServlet", urlPatterns = {"/staff/orders/status"})
public class StaffOrderStatusServlet extends StaffOrderServletSupport {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); // BẮT BUỘC (Rule 3)
        User currentUser = getSessionUser(req);

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("code"));
            String newStatus = req.getParameter("status");
            String note = req.getParameter("note");
            String returnUrl = req.getParameter("returnUrl");

            // Gọi service có truyền kèm role của user đang đăng nhập để phân quyền
            boolean isAdmin = "ADMIN".equals(currentUser.getRole());
            staffOrderService.updateOrderStatus(orderId, newStatus, currentUser.getUserId(), currentUser.getRole(), note);
//            staffOrderService.updateOrderStatus(orderId, newStatus, currentUser.getUserId(), note);

            String actionMsg = "Đã cập nhật đơn hàng #" + orderId + " thành công.";
            if ("PREPARING".equals(newStatus)) {
                actionMsg = "Đã xác nhận đóng gói đơn hàng #" + orderId + " (Chuyển sang Đang chuẩn bị).";
            } else if ("DISPATCHED".equals(newStatus)) {
                actionMsg = "Đã giao vận chuyển đơn hàng #" + orderId + " (Tự động gán Shipper).";
            } else if ("CANCELLED".equals(newStatus)) {
                actionMsg = "Đã huỷ đơn hàng #" + orderId + " thành công.";
            }

            if (returnUrl != null && !returnUrl.isBlank()) {
                redirectWithFlash(req, resp, returnUrl.replace(req.getContextPath(), ""), "successMsg", actionMsg);
            } else {
                redirectWithFlash(req, resp, "/staff/orders", "successMsg", actionMsg);
            }

        } catch (Exception e) {
            getServletContext().log("Lỗi tại StaffOrderStatusServlet", e);
            redirectWithFlash(req, resp, "/staff/orders", "errorMsg", "Lỗi: " + e.getMessage());
        }
    }
}
