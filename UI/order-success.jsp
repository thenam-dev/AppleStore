<%--
  order-success.jsp — đặt hàng thành công.
  Servlet cần set: order : Order{code,receiverName,phone,fullAddress,deliveryMethodLabel,
                                  paymentMethodLabel,total,customerEmail}
  Chỉ forward tới trang này ngay sau khi tạo đơn (PRG); tải lại trang không tạo thêm đơn
  vì servlet /checkout xử lý xong sẽ redirect sang /order/success?code=... (GET, không tạo mới).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Đặt hàng thành công · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<header class="sf-top"><nav class="sf-nav">
  <a class="sf-logo" href="${ctx}/home">
    <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-halo"/></svg>
    <span class="wm">HALO</span>
  </a>
</nav></header>

<c:set var="activeStep" value="4"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:44px 26px;text-align:center">
  <div style="width:76px;height:76px;border-radius:50%;background:var(--ok-bg);color:var(--ok);
       display:flex;align-items:center;justify-content:center;margin:0 auto 20px">
    <svg width="34" height="34"><use href="#i-check"/></svg>
  </div>
  <h2 style="font-size:30px;text-transform:uppercase">Đã nhận đơn của bạn</h2>
  <p style="color:var(--graphite);max-width:460px;margin:12px auto 4px;font-size:14px">
    Cửa hàng sẽ gọi xác nhận trong 15 phút. Chi tiết đơn cũng vừa gửi tới <c:out value="${order.customerEmail}"/>.
  </p>
  <div class="etch" style="display:inline-flex;border-radius:var(--r-pill);margin:18px 0 26px">
    <span>Mã đơn</span><i class="dot"></i><span style="opacity:1;font-weight:700"><c:out value="${order.code}"/></span>
  </div>
  <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap">
    <a class="btn" href="${ctx}/account/orders?code=${order.code}">Theo dõi đơn hàng</a>
    <a class="btn ghost" href="${ctx}/products">Tiếp tục mua sắm</a>
  </div>

  <div class="panel" style="max-width:620px;margin:34px auto 0;text-align:left">
    <div class="panel-head"><h3>Thông tin giao hàng</h3><span class="r badge warn">Chờ xác nhận</span></div>
    <div class="panel-pad">
      <dl class="kv">
        <dt>Người nhận</dt><dd><c:out value="${order.receiverName}"/> · <c:out value="${order.phone}"/></dd>
        <dt>Địa chỉ</dt><dd><c:out value="${order.fullAddress}"/></dd>
        <dt>Cách nhận</dt><dd><c:out value="${order.deliveryMethodLabel}"/></dd>
        <dt>Thanh toán</dt><dd><c:out value="${order.paymentMethodLabel}"/></dd>
        <dt>Tổng tiền</dt><dd style="font-family:var(--display);font-stretch:112%;font-size:17px">
          <fmt:formatNumber value="${order.total}" type="number" maxFractionDigits="0"/> ₫</dd>
      </dl>
    </div>
  </div>
</div>
</body>
</html>
