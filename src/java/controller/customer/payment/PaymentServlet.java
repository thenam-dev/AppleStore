package controller.customer.payment;

import config.AppConfig;
import model.entity.order.Order;
import model.entity.user.User;
import service.payment.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Controller mỏng: chỉ đọc request/response và điều phối PaymentService,
 * không tự gọi DAO hay chứa business rule (rule 2).
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment"})
public class PaymentServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

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
            PaymentService.PaymentPageResult pageResult = paymentService.getPaymentPageData(orderId, customerId);

            if (!pageResult.orderFound) {
                request.getSession().setAttribute("errorMsg", "Không tìm thấy đơn hàng.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }

            if (pageResult.alreadyConfirmed) {
                response.sendRedirect(request.getContextPath() + "/order-success?orderId=" + orderId);
                return;
            }

            request.setAttribute("order", pageResult.order);
            request.setAttribute("qrCodeUrl", pageResult.qrCodeUrl);
            request.getRequestDispatcher("/WEB-INF/views/customer/payment.jsp").forward(request, response);
        } catch (SQLException e) {
            request.getSession().setAttribute("errorMsg", "Lỗi khi tải thông tin thanh toán.");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    /** DEMO-ONLY: xem ghi chú trong PaymentService.confirmManualPayment(). */
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
            PaymentService.ConfirmResult result = paymentService.confirmManualPayment(orderId, customerId);
            HttpSession session = request.getSession();
            if (result.success) {
                session.setAttribute("successMsg", result.message);
            } else {
                session.setAttribute("errorMsg", result.message);
            }
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