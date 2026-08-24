package service.staff.order;

import dao.staff.order.StaffOrderDAO;
import model.entity.order.Order;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import model.entity.order.OrderStatusHistory;

public class StaffOrderService {

    private final StaffOrderDAO staffOrderDAO = new StaffOrderDAO();

    public List<Order> getFilteredOrders(String status, String keyword, int offset, int limit) throws SQLException {
        return staffOrderDAO.findFilteredOrders(status, keyword, offset, limit);
    }

    /**
     * Xử lý cập nhật trạng thái đơn hàng (Có check IDOR, hoàn kho khi hủy, và chặn đơn mồ côi).
     */
    public void updateOrderStatus(int orderId, String newStatus, Integer staffId, String role, String note) throws SQLException {
        int safeStaffId = (staffId != null) ? staffId : 1;

        if ("CANCELLED".equals(newStatus)) {
            // Check bảo mật IDOR trước khi hủy đơn
            boolean isSecure = staffOrderDAO.updateStatusSecure(orderId, newStatus, safeStaffId, role);
            if (!isSecure) {
                throw new IllegalArgumentException("Thất bại: Bạn không có quyền thao tác trên đơn hàng này.");
            }
            staffOrderDAO.cancelOrderAndRestoreStock(orderId, safeStaffId, note);
            return;
        }

        // Nếu chuyển sang trạng thái Giao vận (DISPATCHED/SHIPPING), bắt buộc phải có Shipper hoạt động
        if ("DISPATCHED".equals(newStatus) || "SHIPPING".equals(newStatus)) {
            Integer bestShipperId = staffOrderDAO.findBestShipperId();
            if (bestShipperId == null || bestShipperId <= 0) {
                throw new IllegalStateException("Không thể chuyển giao vận: Hiện tại không có Shipper nào đang hoạt động trong hệ thống.");
            }
            staffOrderDAO.assignDelivery(orderId, bestShipperId);
        }

        // Cập nhật trạng thái qua hàm bảo mật chống IDOR
        boolean isSecure = staffOrderDAO.updateStatusSecure(orderId, newStatus, safeStaffId, role);
        if (!isSecure) {
            throw new IllegalArgumentException("Cập nhật trạng thái thất bại. Bạn không có quyền can thiệp vào đơn hàng này.");
        }

        if (staffId != null) {
            staffOrderDAO.assignSaleStaff(orderId, staffId);
        }

        String logNote = (note != null && !note.isBlank()) ? note : "Nhân viên cập nhật trạng thái";
        staffOrderDAO.insertStatusHistory(orderId, newStatus, safeStaffId, logNote);
    }

    public List<Map<String, Object>> getShipperTasks(int shipperId) throws SQLException {
        return staffOrderDAO.findTasksByShipper(shipperId);
    }

    public Order getOrderById(int orderId) throws SQLException {
        Order order = staffOrderDAO.findById(orderId).orElse(null);
        if (order != null) {
            order.setItems(staffOrderDAO.findOrderItemsByOrderId(orderId));
            List<OrderStatusHistory> historyList = staffOrderDAO.findStatusHistoryByOrderId(orderId);
            order.setStatusHistory(historyList);
        }
        return order;
    }

    /** 
     * Shipper xác nhận giao thành công (Đã vá lỗi chống IDOR, ép buộc đúng mã shipper_id) 
     */
    public void completeDelivery(int orderId, int shipperId) throws SQLException {
        boolean success = staffOrderDAO.updateDeliveryCompletedSecure(orderId, shipperId);
        if (!success) {
            throw new IllegalArgumentException("Xác nhận giao hàng thất bại. Đơn hàng không tồn tại hoặc không được phân công cho bạn.");
        }
    }

    public List<Order> getFilteredOrdersByRole(String role, int userId, String staffFilter, String status, String keyword, int offset, int limit) throws SQLException {
        return staffOrderDAO.findFilteredOrdersByRole(role, userId, staffFilter, status, keyword, offset, limit);
    }

    public boolean reassignOrder(int orderId, int newStaffId) throws SQLException {
        return staffOrderDAO.updateAssignedSaleStaff(orderId, newStaffId);
    }

    public List<Map<String, Object>> getActiveSaleStaffList() throws SQLException {
        return staffOrderDAO.getActiveSaleStaffList();
    }
}