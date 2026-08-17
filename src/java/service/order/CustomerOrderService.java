package service.order;

import dao.order.CustomerOrderDAO;
import java.sql.SQLException;
import java.util.*;

public class CustomerOrderService {

    private final CustomerOrderDAO customerOrderDAO = new CustomerOrderDAO();

    public List<Map<String, Object>> getCustomerOrders(int customerId, String statusFilter) throws SQLException {
        List<Map<String, Object>> rawOrders = customerOrderDAO.findOrdersByCustomer(customerId, statusFilter);
        List<Map<String, Object>> result = new ArrayList<>();

        for (Map<String, Object> ro : rawOrders) {
            Map<String, Object> o = new HashMap<>();
            int orderId = (int) ro.get("orderId");
            o.put("code", "DH" + orderId);
            o.put("rawId", orderId);
            
            String dbStatus = (String) ro.get("status");
            o.put("status", mapUiStatus(dbStatus));
            o.put("statusLabel", mapStatusLabel(dbStatus));
            o.put("createdAt", ro.get("createdAt"));
            o.put("total", ro.get("finalAmount"));
            
            String payMethod = (String) ro.get("paymentMethod");
            o.put("paymentMethodLabel", "CK".equals(payMethod) ? "Chuyển khoản QR" : "Thanh toán khi nhận hàng (COD)");
            
            int itemCount = (int) ro.get("itemCount");
            String firstItem = (String) ro.get("firstItem");
            if (firstItem == null) firstItem = "Sản phẩm Apple";
            o.put("itemsSummary", itemCount > 1 ? firstItem + " và " + (itemCount - 1) + " sản phẩm khác" : firstItem);
            
            // Icon mặc định cho giao diện tương ứng với template
            o.put("firstItemIconKey", "d-acc"); 
            
            result.add(o);
        }
        return result;
    }

    public Map<String, Integer> getStatusCounts(int customerId) throws SQLException {
        return customerOrderDAO.countOrdersByStatus(customerId);
    }

    public Map<String, Object> getSelectedOrderDetail(int orderId, int customerId) throws SQLException {
        Map<String, Object> raw = customerOrderDAO.findOrderDetail(orderId, customerId);
        if (raw == null) return null;

        Map<String, Object> detail = new HashMap<>();
        detail.put("code", "DH" + raw.get("orderId"));
        detail.put("rawId", raw.get("orderId"));
        
        String dbStatus = (String) raw.get("status");
        detail.put("status", mapUiStatus(dbStatus));
        detail.put("statusLabel", mapStatusLabel(dbStatus));
        
        detail.put("receiverName", raw.get("recipientName"));
        detail.put("phone", raw.get("recipientPhone"));
        detail.put("fullAddress", raw.get("deliveryAddress"));
        
        String payMethod = (String) raw.get("paymentMethod");
        detail.put("paymentMethodLabel", "CK".equals(payMethod) ? "Chuyển khoản QR" : "Thanh toán khi nhận hàng (COD)");
        
        detail.put("subtotal", raw.get("totalAmount"));
        detail.put("discount", raw.get("discountAmount"));
        detail.put("total", raw.get("finalAmount"));

        // Xây dựng Timeline chuẩn (TUYỆT ĐỐI KHÔNG LỘ THÔNG TIN NHÂN VIÊN THAO TÁC / CHANGED_BY)
        List<Map<String, Object>> history = customerOrderDAO.findTimelineByOrderId(orderId);
        List<Map<String, Object>> timeline = new ArrayList<>();
        
        String[] steps = {"CONFIRMED", "PREPARING", "DISPATCHED", "DELIVERED"};
        String[] labels = {"Đã xác nhận đơn", "Đang chuẩn bị hàng", "Đang giao vận chuyển", "Đã giao thành công"};

        for (int i = 0; i < steps.length; i++) {
            Map<String, Object> step = new HashMap<>();
            step.put("label", labels[i]);
            step.put("done", false);
            step.put("time", null);

            for (Map<String, Object> h : history) {
                String hStatus = (String) h.get("status");
                if (steps[i].equals(hStatus) || ("CONFIRMED".equals(steps[i]) && "PENDING_PAYMENT".equals(hStatus))) {
                    step.put("done", true);
                    step.put("time", h.get("changedAt"));
                }
            }
            timeline.add(step);
        }
        detail.put("timeline", timeline);
        return detail;
    }

    public boolean cancelOrder(int orderId, int customerId) throws SQLException {
        return customerOrderDAO.cancelOrderByCustomer(orderId, customerId);
    }

    private String mapUiStatus(String dbStatus) {
        if ("PENDING_PAYMENT".equals(dbStatus) || "CONFIRMED".equals(dbStatus) || "PREPARING".equals(dbStatus)) {
            return "PENDING";
        }
        if ("DISPATCHED".equals(dbStatus) || "SHIPPING".equals(dbStatus)) {
            return "SHIPPING";
        }
        if ("DELIVERED".equals(dbStatus)) {
            return "DELIVERED";
        }
        return "CANCELLED";
    }

    private String mapStatusLabel(String dbStatus) {
        switch (dbStatus) {
            case "PENDING_PAYMENT": return "Chờ thanh toán";
            case "CONFIRMED": return "Đã xác nhận";
            case "PREPARING": return "Đang chuẩn bị";
            case "DISPATCHED": case "SHIPPING": return "Đang giao";
            case "DELIVERED": return "Đã giao";
            case "CANCELLED": return "Đã huỷ";
            default: return dbStatus;
        }
    }
}