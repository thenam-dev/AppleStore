package service.order;

import dao.review.ReviewDAO;
import dao.order.OrderDAO;
import java.sql.SQLException;
import java.util.*;
import model.entity.review.Review;

public class OrderService {

    private final OrderDAO orderDAO = new OrderDAO();

    public List<Map<String, Object>> getCustomerOrders(int customerId, String tab) throws SQLException {
        List<Map<String, Object>> rawOrders = orderDAO.findOrdersByCustomer(customerId, tab);
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
            o.put("firstItemIconKey", "d-acc"); 
            
            result.add(o);
        }
        return result;
    }

    public int getAllCount(int customerId) throws SQLException {
        return orderDAO.countTabOrders(customerId, "all");
    }

    public int getActiveCount(int customerId) throws SQLException {
        return orderDAO.countTabOrders(customerId, "active");
    }

    public int getCompletedCount(int customerId) throws SQLException {
        return orderDAO.countTabOrders(customerId, "completed");
    }

    public Map<String, Object> getSelectedOrderDetail(int orderId, int customerId) throws SQLException {
        Map<String, Object> raw = orderDAO.findOrderDetail(orderId, customerId);
        if (raw == null) return null;

        Map<String, Object> detail = new HashMap<>();
        detail.put("code", "DH" + raw.get("orderId"));
        detail.put("rawId", raw.get("orderId"));
        
        String dbStatus = (String) raw.get("status");
        detail.put("status", mapUiStatus(dbStatus));
        detail.put("statusLabel", mapStatusLabel(dbStatus));
        detail.put("rawStatus", dbStatus);
        
        detail.put("receiverName", raw.get("recipientName"));
        detail.put("phone", raw.get("recipientPhone"));
        detail.put("fullAddress", raw.get("deliveryAddress"));
        
        String payMethod = (String) raw.get("paymentMethod");
        detail.put("paymentMethod", payMethod);
        detail.put("paymentMethodLabel", "CK".equals(payMethod) ? "Chuyển khoản QR" : "Thanh toán khi nhận hàng (COD)");
        
        detail.put("subtotal", raw.get("totalAmount") != null ? raw.get("totalAmount") : 0);
        detail.put("discount", raw.get("discountAmount") != null ? raw.get("discountAmount") : 0);
        detail.put("total", raw.get("finalAmount") != null ? raw.get("finalAmount") : 0);

        Map<String, Integer> statusRank = Map.of(
            "PENDING_PAYMENT", 0,
            "CONFIRMED", 1,
            "PREPARING", 2,
            "DISPATCHED", 3,
            "SHIPPING", 3,
            "DELIVERED", 4,
            "CANCELLED", -1,
            "EXPIRED", -1,
            "PAYMENT_FAILED", -1
        );

        int currentRank = statusRank.getOrDefault(dbStatus, 0);

        List<Map<String, Object>> history = orderDAO.findTimelineByOrderId(orderId);
        List<Map<String, Object>> timeline = new ArrayList<>();
        
        String[] steps = {"CONFIRMED", "PREPARING", "DISPATCHED", "DELIVERED"};
        String[] labels = {"Đã xác nhận đơn", "Đang chuẩn bị hàng", "Đang giao vận chuyển", "Đã giao thành công"};
        int[] ranks = {1, 2, 3, 4};

        for (int i = 0; i < steps.length; i++) {
            Map<String, Object> step = new HashMap<>();
            step.put("label", labels[i]);
            
            boolean isDone = (currentRank >= ranks[i]);
            step.put("done", isDone);
            
            Object stepTime = null;
            for (Map<String, Object> h : history) {
                String hStatus = (String) h.get("status");
                if (steps[i].equals(hStatus)) {
                    stepTime = h.get("changedAt");
                    break;
                }
            }
            step.put("time", stepTime);
            timeline.add(step);
        }
        detail.put("timeline", timeline);
        return detail;
    }
 
    private String mapStatusLabel(String dbStatus) {
        switch (dbStatus) {
            case "PENDING_PAYMENT": return "Chờ thanh toán";
            case "CONFIRMED": return "Đã xác nhận";
            case "PREPARING": return "Đang chuẩn bị";
            case "DISPATCHED": case "SHIPPING": return "Đang giao";
            case "DELIVERED": return "Đã giao";
            case "CANCELLED": return "Đã huỷ";
            case "EXPIRED": return "Đã huỷ (hết hạn thanh toán)";
            case "PAYMENT_FAILED": return "Thanh toán thất bại";
            default: return dbStatus;
        }
    }

    public boolean cancelOrder(int orderId, int customerId) throws SQLException {
        return orderDAO.cancelOrderByCustomer(orderId, customerId);
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
    
    public Map<String, Object> getOrderDetailWithItems(int orderId, int customerId) throws SQLException {
        Map<String, Object> detail = getSelectedOrderDetail(orderId, customerId);
        if (detail == null) return null;

        List<Map<String, Object>> items = orderDAO.findOrderItems(orderId);
        ReviewDAO reviewDAO = new ReviewDAO();
        
        for (Map<String, Object> item : items) {
            int orderItemId = (int) item.get("orderItemId");
            Review review = reviewDAO.getReviewByItemAndCustomer(orderItemId, customerId);
            item.put("review", review);
        }
        detail.put("items", items);
        
        return detail;
    }
}