package controller.staff.order;

import model.entity.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "StaffOrderReassignServlet", urlPatterns = {"/staff/orders/reassign"})
public class StaffOrderReassignServlet extends StaffOrderServletSupport {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8"); // BẮT BUỘC (Rule 3)
        User currentUser = getSessionUser(req);

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!"ADMIN".equals(currentUser.getRole())) {
            redirectWithFlash(req, resp, "/staff/orders", "errorMsg", "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        try {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            int newStaffId = Integer.parseInt(req.getParameter("newStaffId"));

            boolean success = staffOrderService.reassignOrder(orderId, newStaffId);
            if (success) {
                redirectWithFlash(req, resp, "/staff/orders?code=" + orderId, "successMsg", "Đã chuyển giao đơn hàng #" + orderId + " thành công.");
            } else {
                redirectWithFlash(req, resp, "/staff/orders?code=" + orderId, "errorMsg", "Chuyển giao thất bại. Đơn hàng phải đang ở trạng thái Chờ đóng gói (CONFIRMED).");
            }

        } catch (Exception e) {
            getServletContext().log("Lỗi tại StaffOrderReassignServlet", e);
            redirectWithFlash(req, resp, "/staff/orders", "errorMsg", "Lỗi hệ thống: " + e.getMessage());
        }
    }
}