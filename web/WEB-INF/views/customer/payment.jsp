<%--
  payment.jsp — thanh toán chuyển khoản (SePay QR), chỉ dùng cho đơn paymentMethod = CK.
  Servlet (PaymentServlet) set: order : Order{orderId,finalAmount,...}, qrCodeUrl : String hoặc null.
  POST /payment (orderId ẩn) = DEMO-ONLY khách tự xác nhận đã chuyển khoản (xem PaymentService).
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Thanh toán chuyển khoản · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<c:set var="activeStep" value="3" scope="request"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:22px 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  <div class="panel" style="max-width:520px;margin:0 auto">
    <div class="panel-head">
      <h3>Đơn hàng #${order.orderId}</h3>
      <c:choose>
        <c:when test="${expired}"><span class="r badge dan">Đã huỷ</span></c:when>
        <c:otherwise><span class="r badge warn">Đang chờ thanh toán</span></c:otherwise>
      </c:choose>
    </div>
    <div class="panel-pad" style="text-align:center">
      <c:choose>
        <%-- ================= ĐƠN ĐÃ HẾT HẠN / BỊ HUỶ ================= --%>
        <c:when test="${expired}">
          <div class="empty" style="padding:24px 0">
            <div class="ring" style="color:var(--danger)"><svg width="26" height="26"><use href="#i-alert"/></svg></div>
            <h3>Đơn hàng đã bị huỷ do hết hạn thanh toán</h3>
            <p>Bạn chưa chuyển khoản trong vòng 15 phút kể từ lúc đặt hàng nên đơn #${order.orderId} đã tự động huỷ,
               sản phẩm đã được hoàn lại vào kho. Vui lòng đặt lại đơn nếu vẫn muốn mua.</p>
            <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap">
              <a class="btn titan" href="${ctx}/cart">Quay lại giỏ hàng</a>
              <a class="btn ghost" href="${ctx}/products">Tiếp tục mua sắm</a>
            </div>
          </div>
        </c:when>

        <%-- ================= CÒN HẠN - HIỆN MÃ QR ================= --%>
        <c:when test="${not empty qrCodeUrl}">
          <span class="t-eyebrow" style="display:block;margin-bottom:6px">Quét mã để chuyển khoản</span>
          <h2 style="font-size:19px;text-transform:none;margin-bottom:14px">Mở app ngân hàng và quét mã QR bên dưới</h2>
          <img src="${qrCodeUrl}" alt="Mã QR thanh toán" style="max-width:280px;width:100%;border:1px solid var(--line);border-radius:var(--r-md);padding:12px;margin:0 auto 20px">

          <%-- Đồng hồ đếm ngược tính từ payment_transactions.expires_at (server trả sẵn
               epoch millis, JS chỉ trừ với thời gian hiện tại, không tự tính hạn). --%>
          <div id="expiryCountdown" class="note-box" style="text-align:center;margin-bottom:16px">
            Mã QR còn hiệu lực trong <b class="mono" id="expiryTime">--:--</b>
          </div>

          <div style="text-align:left">
            <div class="sum-row"><span>Số tiền cần chuyển</span><span><b><fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0"/> ₫</b></span></div>
            <div class="sum-row"><span>Nội dung chuyển khoản</span><span class="mono">DH${order.orderId}</span></div>
            <div class="sum-row"><span>Trạng thái</span><span>Đang chờ thanh toán</span></div>
          </div>

          <div class="note-box" style="text-align:left;margin-top:14px">
            <b>Lưu ý:</b> nhập đúng nội dung chuyển khoản ở trên để cửa hàng đối soát đơn hàng chính xác.
            Mã QR có hiệu lực trong 15 phút kể từ lúc tạo đơn - quá thời gian này mà chưa chuyển khoản,
            đơn sẽ tự động bị huỷ và sản phẩm được hoàn lại vào kho.
          </div>

          <%--
            DEMO-ONLY: đồ án dùng QR tĩnh, không có webhook SePay thật để tự động xác nhận
            giao dịch. Nút dưới đây cho khách TỰ xác nhận đã chuyển khoản để demo trọn luồng -
            hệ thống thật KHÔNG được xác nhận thanh toán theo cách này.
          --%>
          <form id="confirmPaymentForm" action="${ctx}/payment" method="post" style="margin-top:18px">
            <input type="hidden" name="orderId" value="${order.orderId}">
            <button type="submit" id="confirmPaymentBtn" class="btn titan block">Tôi đã chuyển khoản, xác nhận</button>
          </form>
          <a class="btn ghost block" style="margin-top:10px" href="${ctx}/products">Tiếp tục mua sắm</a>

          <c:if test="${not empty expiresAtMillis}">
            <script>
              (function () {
                var expiresAt = ${expiresAtMillis};
                var timeEl = document.getElementById('expiryTime');
                var boxEl = document.getElementById('expiryCountdown');
                var form = document.getElementById('confirmPaymentForm');
                var btn = document.getElementById('confirmPaymentBtn');

                function renderExpired() {
                  if (timeEl) { timeEl.textContent = '00:00'; }
                  if (boxEl) {
                    boxEl.textContent = 'Mã QR đã hết hạn - đơn hàng đang được hệ thống tự huỷ.';
                    boxEl.style.borderColor = '#F2C9C9';
                    boxEl.style.color = 'var(--danger)';
                  }
                  if (btn) { btn.disabled = true; btn.textContent = 'Mã đã hết hạn'; }
                }

                function tick() {
                  var remainingMs = expiresAt - Date.now();
                  if (remainingMs <= 0) {
                    renderExpired();
                    clearInterval(timer);
                    // Cho job huỷ ở server 1 nhịp rồi tải lại trang để lấy đúng trạng
                    // thái cuối cùng (đơn đã EXPIRED, nút xác nhận biến mất hẳn).
                    setTimeout(function () { window.location.reload(); }, 3000);
                    return;
                  }
                  var totalSeconds = Math.floor(remainingMs / 1000);
                  var minutes = Math.floor(totalSeconds / 60);
                  var seconds = totalSeconds % 60;
                  if (timeEl) {
                    timeEl.textContent = String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
                  }
                }

                var timer = setInterval(tick, 1000);
                tick();

                // Bấm xác nhận sau khi đồng hồ đã hết hạn (vd. tab bị treo lâu) thì
                // chặn luôn ở client, không cần chờ round-trip lên server mới biết.
                if (form) {
                  form.addEventListener('submit', function (e) {
                    if (Date.now() >= expiresAt) {
                      e.preventDefault();
                      renderExpired();
                    }
                  });
                }
              })();
            </script>
          </c:if>
        </c:when>

        <%-- ================= KHÔNG TÌM THẤY THÔNG TIN THANH TOÁN ================= --%>
        <c:otherwise>
          <div class="empty" style="padding:24px 0">
            <div class="ring"><svg width="26" height="26"><use href="#i-alert"/></svg></div>
            <h3>Không tìm thấy thông tin thanh toán</h3>
            <p>Đơn hàng có thể đã được xử lý hoặc chưa tạo được mã QR. Vui lòng kiểm tra lại giỏ hàng.</p>
            <a class="btn titan" href="${ctx}/cart">Quay lại giỏ hàng</a>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
