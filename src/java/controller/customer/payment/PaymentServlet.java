package controller.customer.payment;

import config.AppConfig;
import dao.order.OrderDAO;
import dao.payment.PaymentDAO;
import model.entity.order.Order;
import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Optional;

/**
 * Trang thanh toán chuyển khoản (CK): hiển thị QR tĩnh của SePay do
 * CheckoutService sinh sẵn khi tạo đơn (PaymentDAO.insertPending). Không có
 * webhook SePay thật xác thực giao dịch (đã thống nhất phạm vi đồ án), nên
 * có thêm doPost() cho khách tự bấm "Tôi đã chuyển khoản" để demo hết luồng -
 * ghi rõ đây KHÔNG phải cách xác thực thanh toán an toàn cho hệ thống thật.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment"})
public class PaymentServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        try {
            Optional<Order> orderOpt = orderDAO.findById(orderId);
            if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
                request.getSession().setAttribute("errorMsg", "Không tìm thấy đơn hàng.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
            Order order = orderOpt.get();

            // Đơn đã được xác nhận (thanh toán xong / COD) -> không cần ở lại trang QR nữa.
            // order.status chính là nguồn sự thật cho việc điều hướng, không cần đọc
            // status của payment_transactions riêng.
            if (!"PENDING_PAYMENT".equals(order.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/order-success?orderId=" + orderId);
                return;
            }

            Optional<String> qrCode = paymentDAO.findLatestQrCode(orderId);

            request.setAttribute("order", order);
            request.setAttribute("qrCodeUrl", qrCode.orElse(null));
            request.getRequestDispatcher("/WEB-INF/views/customer/payment.jsp").forward(request, response);
        } catch (SQLException e) {
            request.getSession().setAttribute("errorMsg", "Lỗi khi tải thông tin thanh toán.");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    /** DEMO-ONLY: xem ghi chú ở đầu class. Cần PaymentDAO.markLatestCompleted() (đã gửi kèm để thêm vào). */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        try {
            Optional<Order> orderOpt = orderDAO.findById(orderId);
            if (orderOpt.isEmpty() || orderOpt.get().getCustomerId() != customerId) {
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }

            paymentDAO.markLatestCompleted(orderId);
            orderDAO.updateStatus(orderId, "CONFIRMED");
            orderDAO.insertStatusHistory(orderId, "CONFIRMED", customerId,
                    "Khách tự xác nhận đã chuyển khoản (demo, chưa có webhook SePay thật)");

            request.getSession().setAttribute("successMsg", "Xác nhận thanh toán thành công!");
        } catch (SQLException e) {
            request.getSession().setAttribute("errorMsg", "Lỗi khi xác nhận thanh toán.");
        }

        response.sendRedirect(request.getContextPath() + "/order-success?orderId=" + orderId);
    }

    private Integer parseOrderId(HttpServletRequest request) {
        String raw = request.getParameter("orderId");
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Integer getCustomerId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object sessionUser = session == null ? null : session.getAttribute(AppConfig.SESSION_USER);
        if (!(sessionUser instanceof User)) {
            return null;
        }
        return ((User) sessionUser).getUserId();
    }
}