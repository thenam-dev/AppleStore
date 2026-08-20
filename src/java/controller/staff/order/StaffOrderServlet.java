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

@WebServlet(name = "StaffOrderServlet", urlPatterns = {"/staff/orders", "/staff/orders/status", "/staff/orders/reassign"})
public class StaffOrderServlet extends HttpServlet {

    private final StaffOrderService staffOrderService = new StaffOrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            HttpSession session = req.getSession();
            User currentUser = (User) session.getAttribute("user");
            if (currentUser == null) {
                currentUser = (User) session.getAttribute(AppConfig.SESSION_USER);
            }
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            if ("/staff/orders".equals(path)) {
                String statusFilter = req.getParameter("status");
                String keyword = req.getParameter("keyword");
                String staffFilterParam = req.getParameter("staffId");

                int page = 1;
                int pageSize = 10;
                if (req.getParameter("page") != null) {
                    try {
                        page = Integer.parseInt(req.getParameter("page"));
                    } catch (Exception ignored) {
                    }
                }
                int offset = (page - 1) * pageSize;

                // Lấy danh sách đơn theo phân quyền Role
                List<Order> orders = staffOrderService.getFilteredOrdersByRole(
                        currentUser.getRole(), currentUser.getUserId(), staffFilterParam, statusFilter, keyword, offset, pageSize
                );

                int pendingCount = staffOrderService.getFilteredOrdersByRole(
                        currentUser.getRole(), currentUser.getUserId(), null, "CONFIRMED", null, 0, 1000
                ).size();

                // Nếu là ADMIN, cung cấp thêm danh sách Sale Staff để hiển thị ô dropdown lọc & chuyển giao
                if ("ADMIN".equals(currentUser.getRole())) {
                    req.setAttribute("saleStaffList", staffOrderService.getActiveSaleStaffList());
                }

                req.setAttribute("orders", orders);
                req.setAttribute("pendingCount", pendingCount);
                req.setAttribute("statusFilter", statusFilter);
                req.setAttribute("keyword", keyword);
                req.setAttribute("staffFilter", staffFilterParam);
                req.setAttribute("totalPages", 1);

                String codeParam = req.getParameter("code");
                if (codeParam != null && !codeParam.isBlank()) {
                    try {
                        int orderId = Integer.parseInt(codeParam);
                        Order selectedOrder = staffOrderService.getOrderById(orderId);

                        // SỬA LỖI TRẮNG MÀN HÌNH BẰNG CÁCH CHECK NULL TRƯỚC KHI SO SÁNH
                        boolean isAssignedToMe = selectedOrder != null
                                && selectedOrder.getAssignedSaleStaffId() != null
                                && selectedOrder.getAssignedSaleStaffId().equals(currentUser.getUserId());

                        if (selectedOrder != null && ("ADMIN".equals(currentUser.getRole()) || isAssignedToMe)) {
                            req.setAttribute("selectedOrder", selectedOrder);
                            req.setAttribute("orderTimeline", selectedOrder.getStatusHistory());
                        }
                    } catch (Exception ex) {
                        System.err.println("LỖI KHI TẢI CHI TIẾT ĐƠN HÀNG: " + ex.getMessage());
                        ex.printStackTrace();
                        throw ex;
                    }
                }

                req.getRequestDispatcher("/WEB-INF/views/staff/orders.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            // In toàn bộ vết lỗi (Stack Trace) ra console server
            System.err.println("CRITICAL ERROR tại StaffOrderServlet doGet: " + e.getMessage());
            e.printStackTrace();

            getServletContext().log("Lỗi tại StaffOrderServlet doGet", e);
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
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        try {
            // Chức năng REASSIGN: Chỉ ADMIN mới được phép thực hiện chuyển giao việc
            if ("/staff/orders/reassign".equals(path)) {
                if (!"ADMIN".equals(currentUser.getRole())) {
                    session.setAttribute("errorMsg", "Bạn không có quyền thực hiện thao tác này.");
                    resp.sendRedirect(req.getContextPath() + "/staff/orders");
                    return;
                }
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                int newStaffId = Integer.parseInt(req.getParameter("newStaffId"));

                boolean success = staffOrderService.reassignOrder(orderId, newStaffId);
                if (success) {
                    session.setAttribute("successMsg", "Đã chuyển giao đơn hàng #" + orderId + " thành công.");
                } else {
                    session.setAttribute("errorMsg", "Chuyển giao thất bại. Đơn hàng phải đang ở trạng thái Chờ đóng gói (CONFIRMED).");
                }
                resp.sendRedirect(req.getContextPath() + "/staff/orders?code=" + orderId);
                return;
            }

            // Luồng cập nhật trạng thái thông thường
            int orderId = Integer.parseInt(req.getParameter("code"));
            String newStatus = req.getParameter("status");
            String note = req.getParameter("note");
            String returnUrl = req.getParameter("returnUrl");

            staffOrderService.updateOrderStatus(orderId, newStatus, currentUser.getUserId(), note);

            String actionMsg = "Đã cập nhật đơn hàng #" + orderId + " thành công.";
            if ("PREPARING".equals(newStatus)) {
                actionMsg = "Đã xác nhận đóng gói đơn hàng #" + orderId + " (Chuyển sang Đang chuẩn bị).";
            } else if ("DISPATCHED".equals(newStatus)) {
                actionMsg = "Đã giao vận chuyển đơn hàng #" + orderId + " (Tự động gán Shipper).";
            } else if ("CANCELLED".equals(newStatus)) {
                actionMsg = "Đã huỷ đơn hàng #" + orderId + " thành công.";
            }

            // Đã sửa: Gán chính xác actionMsg vào session thay vì chuỗi cứng
            session.setAttribute("successMsg", actionMsg);

            if (returnUrl != null && !returnUrl.isBlank()) {
                resp.sendRedirect(returnUrl);
            } else {
                resp.sendRedirect(req.getContextPath() + "/staff/orders");
            }

        } catch (Exception e) {
            getServletContext().log("Lỗi tại StaffOrderServlet doPost", e);
            session.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/orders");
        }
    }
}
