package service.staff.order;

import dao.staff.order.StaffOrderDAO;
import model.entity.order.Order;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.entity.order.OrderStatusHistory;

public class StaffOrderService {

    private final StaffOrderDAO staffOrderDAO = new StaffOrderDAO();

    public List<Order> getFilteredOrders(String status, String keyword, int offset, int limit) throws SQLException {
        return staffOrderDAO.findFilteredOrders(status, keyword, offset, limit);
    }

    /**
     * Xử lý cập nhật trạng thái đơn hàng và tự động phân công Shipper ít task nhất khi sang DISPATCHED.
     */
    public void updateOrderStatus(int orderId, String newStatus, Integer staffId, String note) throws SQLException {
        // 1. Cập nhật trạng thái bảng orders
        staffOrderDAO.updateStatus(orderId, newStatus);
        
        // 2. Ghi nhận lịch sử dòng thời gian (order_status_history)
        String logNote = (note != null && !note.isBlank()) ? note : "Nhân viên cập nhật trạng thái";
        staffOrderDAO.insertStatusHistory(orderId, newStatus, staffId, logNote);

        // 3. TỰ ĐỘNG GÁN SHIPPER (Load Balancing) KHI ĐƠN CHUYỂN SANG DISPATCHED
        if ("DISPATCHED".equals(newStatus) || "SHIPPING".equals(newStatus)) {
            Integer bestShipperId = staffOrderDAO.findBestShipperId();
            if (bestShipperId != null) {
                staffOrderDAO.assignDelivery(orderId, bestShipperId);
            }
        }
    }

    public List<Map<String, Object>> getShipperTasks(int shipperId) throws SQLException {
        return staffOrderDAO.findTasksByShipper(shipperId);
    }

    public void completeDelivery(int orderId) throws SQLException {
        staffOrderDAO.updateStatus(orderId, "DELIVERED");
        staffOrderDAO.insertStatusHistory(orderId, "DELIVERED", null, "Shipper xác nhận giao hàng thành công");
        staffOrderDAO.updateDeliveryCompleted(orderId);
    }
    
    public Order getOrderById(int orderId) throws SQLException {
        Order order = staffOrderDAO.findById(orderId).orElse(null);
        if (order != null) {
            // Lấy danh sách sản phẩm trong đơn
            order.setItems(staffOrderDAO.findOrderItemsByOrderId(orderId));
            
            // Lấy lịch sử trạng thái chuẩn từ bảng order_status_history
            List<OrderStatusHistory> historyList = staffOrderDAO.findStatusHistoryByOrderId(orderId);
            order.setStatusHistory(historyList);
        }
        return order;
    }

    // Cập nhật hàm completeDelivery của Shipper để ghi nhận chính xác người thực hiện (changed_by)
    public void completeDelivery(int orderId, int shipperId) throws SQLException {
        staffOrderDAO.updateStatus(orderId, "DELIVERED");
        staffOrderDAO.insertStatusHistory(orderId, "DELIVERED", shipperId, "Shipper xác nhận giao hàng thành công");
        staffOrderDAO.updateDeliveryCompleted(orderId);
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