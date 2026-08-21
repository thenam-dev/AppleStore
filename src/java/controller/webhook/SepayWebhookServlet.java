package controller.webhook;

import config.AppConfig;
import service.payment.PaymentService;
import util.JsonUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Map;

/**
 * Endpoint nhận webhook thật từ SePay khi có giao dịch chuyển khoản vào tài
 * khoản ngân hàng đã đăng ký.
 *
 * === CÁCH ĐẤU NỐI VỚI SEPAY ===
 * 1. Có tài khoản SePay (sepay.vn) đã liên kết với đúng số tài khoản ngân
 *    hàng dùng để nhận tiền (AppConfig.SEPAY_ACCOUNT_NUMBER).
 * 2. App phải có URL public mà SePay gọi tới được (SePay ở ngoài Internet,
 *    KHÔNG gọi được vào localhost) - vd. domain thật khi deploy, hoặc dùng
 *    ngrok/cloudflare tunnel để test: "ngrok http 8080" rồi lấy URL dạng
 *    https://xxxx.ngrok-free.app.
 * 3. Trên dashboard SePay: Cấu hình > Webhooks > Thêm webhook:
 *      - URL: https://<domain-public-của-bạn>/AppleStore/webhook/sepay
 *      - Gõ 1 Authorization API Key bất kỳ (tự đặt), rồi dán ĐÚNG giá trị đó
 *        vào AppConfig.SEPAY_WEBHOOK_API_KEY - PHẢI khớp 100% giữa 2 nơi.
 * 4. Chọn loại thông báo: "Chỉ tiền vào" (transferType = in) là đủ.
 * Không làm đủ 4 bước trên thì webhook sẽ không bao giờ được SePay gọi tới,
 * và luồng thanh toán vẫn hoạt động bình thường qua nút xác nhận thủ công.
 */
@WebServlet(name = "SepayWebhookServlet", urlPatterns = {"/webhook/sepay"})
public class SepayWebhookServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentService();

    /** Cho phép GET trả 200 rỗng để tự kiểm tra URL có tới được server không (không xử lý gì). */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        writeJson(response, HttpServletResponse.SC_OK, true, "SePay webhook endpoint is up");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // SePay ký request bằng header Authorization: "Apikey <key>" (chuẩn của
        // SePay) - đối chiếu với key đã cấu hình trong AppConfig. Không xác
        // thực được thì từ chối luôn, không đọc/xử lý payload.
        if (!isAuthorized(request)) {
            writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Invalid API key");
            return;
        }

        String rawBody = readRawBody(request);

        Map payload;
        try {
            payload = JsonUtil.fromJson(rawBody, Map.class);
        } catch (Exception malformed) {
            // Payload không parse được thì SePay có gửi lại cũng vậy - ack 200
            // luôn để dừng retry, không phải lỗi hạ tầng cần thử lại.
            writeJson(response, HttpServletResponse.SC_OK, false, "Payload is not valid JSON, ignored");
            return;
        }

        try {
            @SuppressWarnings("unchecked")
            PaymentService.WebhookResult result = paymentService.processSepayWebhook(payload, rawBody);
            writeJson(response, HttpServletResponse.SC_OK, true, result.reason);
        } catch (SQLException dbError) {
            // Lỗi hạ tầng thật (mất kết nối DB...) - trả 5xx để SePay tự động
            // gọi lại webhook này sau (SePay có cơ chế retry khi không nhận 2xx).
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Server error, please retry");
        }
    }

    private boolean isAuthorized(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        String expected = "Apikey " + AppConfig.SEPAY_WEBHOOK_API_KEY;
        boolean ok = header != null && header.trim().equals(expected);

        // Log request bị từ chối (không log giá trị key mong đợi, tránh lộ secret
        // vào log) - giúp phát hiện có ai đó dò/gọi sai vào endpoint này.
        if (!ok) {
            System.out.println("[SepayWebhook] Từ chối request - Authorization header không khớp hoặc thiếu.");
        }
        return ok;
    }

    /** Đọc nguyên body request theo UTF-8 tường minh (không dùng request.getReader() vì
     *  charset mặc định của nó là ISO-8859-1 khi request không khai charset - có thể
     *  làm sai nội dung chuyển khoản nếu có ký tự tiếng Việt). */
    private String readRawBody(HttpServletRequest request) throws IOException {
        byte[] bytes = request.getInputStream().readAllBytes();
        return new String(bytes, StandardCharsets.UTF_8);
    }

    private void writeJson(HttpServletResponse response, int statusCode, boolean success, String message) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        String safeMessage = message == null ? "" : message.replace("\"", "'");
        response.getWriter().write("{\"success\":" + success + ",\"message\":\"" + safeMessage + "\"}");
    }
}
