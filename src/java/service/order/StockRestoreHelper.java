package service.order;

import dao.catalog.ProductVariantDAO;
import dao.order.OrderDAO;
import model.entity.order.OrderItem;

import java.sql.SQLException;
import java.util.List;

/**
 * Hoàn tồn kho cho các order_item của 1 đơn vừa bị huỷ - dùng chung bởi
 * CustomerOrderService (khách tự huỷ) và OrderExpiryService (job tự động
 * huỷ đơn CK hết hạn thanh toán), vì cả 2 trường hợp đều phải "trả lại" số
 * lượng đã trừ (giữ chỗ) lúc tạo đơn cho biến thể tương ứng.
 *
 * Gọi SAU KHI đơn đã được chuyển trạng thái thành công (atomic ở tầng DAO),
 * để không hoàn kho 2 lần nếu 2 luồng cùng cố huỷ 1 đơn.
 */
final class StockRestoreHelper {

    private final OrderDAO orderDAO;
    private final ProductVariantDAO productVariantDAO;

    StockRestoreHelper(OrderDAO orderDAO, ProductVariantDAO productVariantDAO) {
        this.orderDAO = orderDAO;
        this.productVariantDAO = productVariantDAO;
    }

    /**
     * @param actorId dùng cho inventory_logs.changed_by (NOT NULL, FK users).
     *                Khách tự huỷ thì truyền customerId của chính họ; job hệ
     *                thống tự huỷ (hết hạn) thì truyền customerId của đơn vì
     *                không có tài khoản "system" riêng trong schema hiện tại.
     */
    void restore(int orderId, int actorId) throws SQLException {
        List<OrderItem> items = orderDAO.findItemsByOrderId(orderId);
        for (OrderItem item : items) {
            if (item.getVariantId() == null) {
                continue; // biến thể đã bị xoá khỏi hệ thống, không còn gì để hoàn
            }
            try {
                productVariantDAO.increaseStock(item.getVariantId(), item.getQuantity());
                int stockAfter = productVariantDAO.findStockQuantity(item.getVariantId()).orElse(0);
                orderDAO.insertInventoryLog(item.getVariantId(), actorId, orderId, item.getOrderItemId(),
                        "ORDER_RELEASE", item.getQuantity(), stockAfter);
            } catch (SQLException e) {
                // Best-effort như compensate() của CheckoutService: đơn đã huỷ rồi, không thể
                // rollback ngược lại trạng thái CANCELLED/EXPIRED chỉ vì 1 dòng hoàn kho lỗi ->
                // log lại để admin đối soát tay thay vì chặn cả luồng huỷ đơn.
                e.printStackTrace();
            }
        }
    }
}
