<%--
  order-success.jsp — đặt hàng thành công.
  Servlet (OrderSuccessServlet) set:
    order      : Order{orderId,recipientName,recipientPhone,deliveryAddress,deliveryTimeSlot,
                        notes,status,totalAmount,deliveryFee,discountAmount,finalAmount,paymentMethod}
    orderItems : List<OrderItem>{productNameSnapshot,variantLabelSnapshot,addonLabelSnapshot,
                                  quantity,unitPrice,subtotal}
    successMsg : flash message (CheckoutServlet/PaymentServlet set trước khi redirect)
  Chỉ tới trang này bằng GET /order-success?orderId=... (PRG) - tải lại trang không tạo thêm đơn.
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
  <title>Đặt hàng thành công · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
  <style>
    /* Xuất hóa đơn: khối invoice-print chỉ hiện khi in (Ctrl+P / Save as PDF),
       ẩn trên màn hình bình thường. Khi in thì ẩn hẳn (display:none - không
       chiếm chỗ trong luồng trang, tránh sinh trang trắng thừa) toàn bộ phần
       còn lại của trang (bọc trong .screen-only), chỉ còn nội dung hóa đơn. */
    .invoice-print { display:none; }
    @media print {
      .screen-only { display:none !important; }
      .invoice-print { display:block; }
    }
  </style>
</head>
<body>
<div class="screen-only">

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<c:set var="activeStep" value="4" scope="request"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:44px 26px;text-align:center">
  <div style="width:76px;height:76px;border-radius:50%;background:var(--ok-bg);color:var(--ok);
       display:flex;align-items:center;justify-content:center;margin:0 auto 20px">
    <svg width="34" height="34"><use href="#i-check"/></svg>
  </div>
  <h2 style="font-size:28px;text-transform:uppercase">Đã nhận đơn của bạn</h2>
  <p style="color:var(--graphite);max-width:460px;margin:12px auto 4px;font-size:14px">
    Cửa hàng sẽ liên hệ xác nhận và giao hàng trong thời gian sớm nhất.
  </p>
  <div class="etch" style="display:inline-flex;border-radius:var(--r-pill);margin:18px 0 4px">
    <span>Mã đơn</span><i class="dot"></i><span style="opacity:1;font-weight:700">#${order.orderId}</span>
  </div>

  <%-- Không hiện lại successMsg ở đây nữa: tiến độ đã thể hiện qua thanh checkout-steps.jsp
       phía trên (bước 4 tô đậm, các bước trước tô xanh), banner "thành công" là thừa. --%>
  <div style="max-width:960px;margin:26px auto 0;text-align:left">
    <div class="split">
      <div style="display:flex;flex-direction:column;gap:18px">
        <div class="panel">
          <div class="panel-head"><h3>Sản phẩm đã đặt</h3></div>
          <div class="panel-pad">
            <c:forEach var="item" items="${orderItems}">
              <div class="line-item">
                <div style="flex:1;min-width:0">
                  <b style="font-size:13.5px"><c:out value="${item.productNameSnapshot}"/></b><br>
                  <span style="font-size:12px;color:var(--ash)">
                    <c:out value="${item.variantLabelSnapshot}"/>
                    <c:if test="${not empty item.addonLabelSnapshot}"> &middot; Dịch vụ thêm: <c:out value="${item.addonLabelSnapshot}"/></c:if>
                  </span>
                </div>
                <span class="mono" style="font-size:12.5px;color:var(--ash)">
                  <fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/> ₫ × ${item.quantity}
                </span>
                <div style="width:110px;text-align:right;font-family:var(--display);font-stretch:112%;font-weight:700;font-size:14.5px">
                  <fmt:formatNumber value="${item.subtotal}" type="number" maxFractionDigits="0"/> ₫
                </div>
              </div>
            </c:forEach>
          </div>
        </div>

        <div class="panel">
          <div class="panel-head"><h3>Thông tin giao hàng</h3></div>
          <div class="panel-pad">
            <dl class="kv">
              <dt>Người nhận</dt><dd><c:out value="${order.recipientName}"/> · <c:out value="${order.recipientPhone}"/></dd>
              <dt>Địa chỉ</dt><dd><c:out value="${order.deliveryAddress}"/></dd>
              <c:if test="${not empty order.deliveryTimeSlot}">
                <dt>Khung giờ nhận</dt><dd><c:out value="${order.deliveryTimeSlot}"/></dd>
              </c:if>
              <c:if test="${not empty order.notes}">
                <dt>Ghi chú</dt><dd><c:out value="${order.notes}"/></dd>
              </c:if>
            </dl>
          </div>
        </div>
      </div>

      <div class="panel" style="position:sticky;top:calc(var(--sf-header-h) + 16px)">
        <div class="panel-head"><h3>Tóm tắt đơn hàng</h3></div>
        <div class="panel-pad">
          <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/> ₫</span></div>
          <c:if test="${order.discountAmount > 0}">
            <div class="sum-row" style="color:var(--ok)"><span>Giảm giá</span><span>− <fmt:formatNumber value="${order.discountAmount}" type="number" maxFractionDigits="0"/> ₫</span></div>
          </c:if>
          <div class="sum-row"><span>Phí vận chuyển</span><span><fmt:formatNumber value="${order.deliveryFee}" type="number" maxFractionDigits="0"/> ₫</span></div>
          <div class="sum-row"><span>Thanh toán</span><span>${order.paymentMethod == 'COD' ? 'Khi nhận hàng' : 'Chuyển khoản (SePay)'}</span></div>
          <div class="sum-row"><span>Trạng thái</span><span class="badge ${order.status == 'CONFIRMED' ? 'ok' : 'warn'}"><c:out value="${order.status}"/></span></div>
          <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0"/> ₫</span></div>

          <button type="button" class="btn ghost block" style="margin-top:16px" onclick="window.print()">Xuất hóa đơn</button>
          <a class="btn titan block" style="margin-top:10px" href="${ctx}/products">Tiếp tục mua sắm</a>
          <a class="btn ghost block" style="margin-top:10px" href="${ctx}/account/orders">Xem lịch sử mua hàng</a>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</div><%-- /.screen-only --%>

<%-- Nội dung hóa đơn dùng riêng cho khi in / xuất PDF (nút "Xuất hóa đơn" ở trên
     gọi window.print(); trong hộp thoại in, chọn "Save as PDF" để xuất file).
     Khối này ẩn trên màn hình bình thường, chỉ hiện khi in - xem CSS @media print. --%>
<div class="invoice-print" id="invoicePrint">
  <div style="text-align:center;margin-bottom:18px">
    <h2 style="margin:0;font-family:var(--display)">AOS · APPLESTORE</h2>
    <p style="margin:4px 0 0;font-size:12px">Công ty Cổ phần Thương mại và Dịch vụ APPLESTORE Việt Nam</p>
    <p style="margin:0;font-size:12px">Hotline: 1800 8888</p>
  </div>
  <h3 style="text-align:center;text-transform:uppercase;letter-spacing:1px;margin:18px 0;border-top:1px solid #000;border-bottom:1px solid #000;padding:8px 0">
    Hóa đơn bán hàng
  </h3>

  <table style="width:100%;font-size:13px;margin-bottom:14px">
    <tr>
      <td>Mã đơn hàng: <b>#${order.orderId}</b></td>
      <td style="text-align:right">Ngày đặt: <b><c:out value="${order.formattedCreatedAtFull}"/></b></td>
    </tr>
  </table>

  <table style="width:100%;font-size:13px;margin-bottom:16px">
    <tr><td style="width:140px;color:#555">Khách hàng</td><td><b><c:out value="${order.recipientName}"/></b></td></tr>
    <tr><td style="color:#555">Điện thoại</td><td><c:out value="${order.recipientPhone}"/></td></tr>
    <tr><td style="color:#555">Địa chỉ giao hàng</td><td><c:out value="${order.deliveryAddress}"/></td></tr>
  </table>

  <table style="width:100%;border-collapse:collapse;font-size:12.5px">
    <thead>
      <tr style="border-bottom:2px solid #000">
        <th style="text-align:left;padding:6px 4px">#</th>
        <th style="text-align:left;padding:6px 4px">Sản phẩm</th>
        <th style="text-align:center;padding:6px 4px">SL</th>
        <th style="text-align:right;padding:6px 4px">Đơn giá</th>
        <th style="text-align:right;padding:6px 4px">Thành tiền</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="item" items="${orderItems}" varStatus="st">
        <tr style="border-bottom:1px solid #ddd">
          <td style="padding:6px 4px;vertical-align:top">${st.index + 1}</td>
          <td style="padding:6px 4px;vertical-align:top">
            <c:out value="${item.productNameSnapshot}"/><br>
            <span style="font-size:11px;color:#666">
              <c:out value="${item.variantLabelSnapshot}"/>
              <c:if test="${not empty item.addonLabelSnapshot}"> &middot; Dịch vụ thêm: <c:out value="${item.addonLabelSnapshot}"/></c:if>
            </span>
          </td>
          <td style="text-align:center;padding:6px 4px;vertical-align:top">${item.quantity}</td>
          <td style="text-align:right;padding:6px 4px;vertical-align:top;white-space:nowrap"><fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/> ₫</td>
          <td style="text-align:right;padding:6px 4px;vertical-align:top;white-space:nowrap"><fmt:formatNumber value="${item.subtotal}" type="number" maxFractionDigits="0"/> ₫</td>
        </tr>
      </c:forEach>
    </tbody>
  </table>

  <table style="width:100%;max-width:320px;margin:16px 0 0 auto;font-size:13px">
    <tr><td>Tạm tính</td><td style="text-align:right"><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/> ₫</td></tr>
    <c:if test="${order.discountAmount > 0}">
      <tr><td>Giảm giá</td><td style="text-align:right">− <fmt:formatNumber value="${order.discountAmount}" type="number" maxFractionDigits="0"/> ₫</td></tr>
    </c:if>
    <tr><td>Phí vận chuyển</td><td style="text-align:right"><fmt:formatNumber value="${order.deliveryFee}" type="number" maxFractionDigits="0"/> ₫</td></tr>
    <tr style="font-weight:700;font-size:15px">
      <td style="padding-top:8px;border-top:2px solid #000">Tổng cộng</td>
      <td style="text-align:right;padding-top:8px;border-top:2px solid #000"><fmt:formatNumber value="${order.finalAmount}" type="number" maxFractionDigits="0"/> ₫</td>
    </tr>
  </table>

  <p style="font-size:12.5px;margin-top:10px">
    Phương thức thanh toán: <b>${order.paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản (SePay)'}</b><br>
    Trạng thái đơn hàng: <b><c:out value="${order.status}"/></b>
  </p>

  <table style="width:100%;margin-top:56px;font-size:13px;text-align:center">
    <tr>
      <td style="width:50%">
        <b>Khách hàng</b><br><span style="font-size:11px;color:#666">(Ký, ghi rõ họ tên)</span>
      </td>
      <td style="width:50%">
        <b>Người bán</b><br><span style="font-size:11px;color:#666">(Ký, ghi rõ họ tên)</span>
      </td>
    </tr>
  </table>

  <p style="text-align:center;margin-top:44px;font-size:12px;color:#666">Cảm ơn quý khách đã mua hàng tại AppleStore!</p>
</div>

</body>
</html>
