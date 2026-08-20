package controller.customer.payment;

import config.AppConfig;
import model.entity.user.User;
import service.payment.PaymentService;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/**
 * GET /payment/status?orderId=... - trả về đúng trạng thái đơn dạng JSON,
 * KHÔNG render HTML. Dùng cho script poll ngầm ở payment.jsp: trước đây
 * payment.jsp poll bằng cách window.location.reload() mỗi 5s, làm cả trang
 * (QR, đồng hồ đếm ngược) nháy/tải lại liên tục dù đơn chưa có gì thay đổi -
 * endpoint này cho phép JS chỉ hỏi đúng 1 giá trị trạng thái, chỉ điều hướng
 * (window.location) khi trạng thái THỰC SỰ đổi (CONFIRMED/EXPIRED/CANCELLED).
 */
@WebServlet(name = "PaymentStatusServlet", urlPatterns = {"/payment/status"})
public class PaymentStatusServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

        Integer customerId = getCustomerId(request);
        if (customerId == null) {
            writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "UNAUTHORIZED");
            return;
        }

        Integer orderId = parseOrderId(request);
        if (orderId == null) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "INVALID");
            return;
        }

        try {
            String status = paymentService.getOrderStatusForCustomer(orderId, customerId);
            if (status == null) {
                writeJson(response, HttpServletResponse.SC_NOT_FOUND, "NOT_FOUND");
                return;
            }
            writeJson(response, HttpServletResponse.SC_OK, status);
        } catch (SQLException e) {
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "ERROR");
        }
    }

    private void writeJson(HttpServletResponse response, int statusCode, String status) throws IOException {
        response.setStatus(statusCode);
        response.getWriter().write("{\"status\":\"" + status + "\"}");
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
