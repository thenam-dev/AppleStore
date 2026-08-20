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
</head>
<body>

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

          <a class="btn titan block" style="margin-top:16px" href="${ctx}/products">Tiếp tục mua sắm</a>
          <a class="btn ghost block" style="margin-top:10px" href="${ctx}/home">Về trang chủ</a>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
