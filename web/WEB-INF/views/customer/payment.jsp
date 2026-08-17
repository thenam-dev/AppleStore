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
      <span class="r badge warn">Đang chờ thanh toán</span>
    </div>
    <div class="panel-pad" style="text-align:center">
      <c:choose>
        <c:when test="${not empty qrCodeUrl}">
          <span class="t-eyebrow" style="display:block;margin-bottom:6px">Quét mã để chuyển khoản</span>
          <h2 style="font-size:19px;text-transform:none;margin-bottom:14px">Mở app ngân hàng và quét mã QR bên dưới</h2>
          <img src="${qrCodeUrl}" alt="Mã QR thanh toán" style="max-width:280px;width:100%;border:1px solid var(--line);border-radius:var(--r-md);padding:12px;margin:0 auto 20px">

          <div style="text-align:left">
            <div class="sum-row"><span>Số tiền cần chuyển</span><span><b><fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0"/> ₫</b></span></div>
            <div class="sum-row"><span>Nội dung chuyển khoản</span><span class="mono">DH${order.orderId}</span></div>
            <div class="sum-row"><span>Trạng thái</span><span>Đang chờ thanh toán</span></div>
          </div>

          <div class="note-box" style="text-align:left;margin-top:14px">
            <b>Lưu ý:</b> nhập đúng nội dung chuyển khoản ở trên để cửa hàng đối soát đơn hàng chính xác.
            Mã QR có hiệu lực trong 15 phút kể từ lúc tạo đơn.
          </div>

          <%--
            DEMO-ONLY: đồ án dùng QR tĩnh, không có webhook SePay thật để tự động xác nhận
            giao dịch. Nút dưới đây cho khách TỰ xác nhận đã chuyển khoản để demo trọn luồng -
            hệ thống thật KHÔNG được xác nhận thanh toán theo cách này.
          --%>
          <form action="${ctx}/payment" method="post" style="margin-top:18px">
            <input type="hidden" name="orderId" value="${order.orderId}">
            <button type="submit" class="btn titan block">Tôi đã chuyển khoản, xác nhận</button>
          </form>
          <a class="btn ghost block" style="margin-top:10px" href="${ctx}/products">Tiếp tục mua sắm</a>
        </c:when>
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
