package listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import service.order.OrderExpiryService;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

/**
 * Khởi động 1 job nền quét định kỳ các đơn CK (chuyển khoản QR) đã hết hạn
 * thanh toán (payment_transactions.expires_at) mà khách chưa chuyển khoản,
 * để tự huỷ đơn (status = EXPIRED) và hoàn tồn kho đã trừ lúc đặt hàng - xem
 * OrderExpiryService.
 *
 * Đây là scheduler nội bộ (ScheduledExecutorService), chỉ chạy khi ứng dụng
 * đang sống trong 1 Tomcat instance - đủ dùng cho quy mô đồ án hiện tại.
 * Nếu sau này scale nhiều instance thì cần chuyển sang 1 job có khoá phân
 * tán (VD: quét bằng cron ngoài + DB lock) để tránh nhiều instance cùng quét
 * trùng nhau; hiện tại việc trùng nhau vẫn AN TOÀN vì
 * OrderDAO.expireIfStillPending() đã atomic (WHERE status = 'PENDING_PAYMENT'),
 * chỉ 1 instance thắng, các instance còn lại tự bỏ qua.
 */
@WebListener
public class OrderExpirySchedulerListener implements ServletContextListener {

    /** Chu kỳ quét. Tối thiểu nên nhỏ hơn thời gian giữ chỗ (15 phút, xem PaymentDAO.insertPending). */
    private static final long SCAN_INTERVAL_MINUTES = 5;

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ThreadFactory daemonThreadFactory = runnable -> {
            Thread thread = new Thread(runnable, "order-expiry-scheduler");
            thread.setDaemon(true);
            return thread;
        };
        scheduler = Executors.newSingleThreadScheduledExecutor(daemonThreadFactory);

        OrderExpiryService orderExpiryService = new OrderExpiryService();
        scheduler.scheduleWithFixedDelay(() -> {
            try {
                int expired = orderExpiryService.expireStalePendingOrders();
                if (expired > 0) {
                    sce.getServletContext().log("OrderExpirySchedulerListener: đã tự huỷ + hoàn kho " + expired + " đơn hết hạn thanh toán.");
                }
            } catch (RuntimeException e) {
                // Không để 1 lượt quét lỗi làm chết hẳn scheduler (scheduleWithFixedDelay sẽ
                // dừng nếu task ném exception ra ngoài).
                sce.getServletContext().log("OrderExpirySchedulerListener: lỗi khi quét đơn hết hạn", e);
            }
        }, 1, SCAN_INTERVAL_MINUTES, TimeUnit.MINUTES);

        sce.getServletContext().log("OrderExpirySchedulerListener: đã khởi động, quét mỗi " + SCAN_INTERVAL_MINUTES + " phút.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }
}
