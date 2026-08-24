package controller.staff.order;

import model.entity.order.Order;
import model.entity.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffOrderListServlet", urlPatterns = {"/staff/orders"})
public class StaffOrderListServlet extends StaffOrderServletSupport {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            User currentUser = getSessionUser(req);
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            String statusFilter = req.getParameter("status");
            String keyword = req.getParameter("keyword");
            String staffFilterParam = req.getParameter("staffId");

            int page = 1;
            int pageSize = 10;
            if (req.getParameter("page") != null) {
                try {
                    page = Integer.parseInt(req.getParameter("page"));
                } catch (NumberFormatException ignored) {}
            }
            int offset = Math.max(0, (page - 1) * pageSize);

            List<Order> orders = staffOrderService.getFilteredOrdersByRole(
                    currentUser.getRole(), currentUser.getUserId(), staffFilterParam, statusFilter, keyword, offset, pageSize
            );

            int pendingCount = staffOrderService.getFilteredOrdersByRole(
                    currentUser.getRole(), currentUser.getUserId(), null, "CONFIRMED", null, 0, 1000
            ).size();

            if ("ADMIN".equals(currentUser.getRole())) {
                req.setAttribute("saleStaffList", staffOrderService.getActiveSaleStaffList());
            }

            req.setAttribute("orders", orders);
            req.setAttribute("pendingCount", pendingCount);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("keyword", keyword);
            req.setAttribute("staffFilter", staffFilterParam);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", 1); // Nên gắn logic tính tổng số trang vào đây

            String codeParam = req.getParameter("code");
            if (codeParam != null && !codeParam.isBlank()) {
                int orderId = Integer.parseInt(codeParam);
                Order selectedOrder = staffOrderService.getOrderById(orderId);

                boolean isAssignedToMe = selectedOrder != null
                        && selectedOrder.getAssignedSaleStaffId() != null
                        && selectedOrder.getAssignedSaleStaffId().equals(currentUser.getUserId());

                if (selectedOrder != null && ("ADMIN".equals(currentUser.getRole()) || isAssignedToMe)) {
                    req.setAttribute("selectedOrder", selectedOrder);
                    req.setAttribute("orderTimeline", selectedOrder.getStatusHistory());
                }
            }

            req.getRequestDispatcher("/WEB-INF/views/staff/orders.jsp").forward(req, resp);

        } catch (Exception e) {
            getServletContext().log("CRITICAL ERROR tại StaffOrderListServlet", e);
            req.setAttribute("errorMsg", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/staff/orders.jsp").forward(req, resp);
        }
    }
}