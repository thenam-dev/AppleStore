<%--
  checkout.jsp — thanh toán.
  Servlet cần set:
    form          : dữ liệu người dùng đã nhập, đổ lại khi có lỗi
                    {fullName,phone,email,provinceId,districtId,wardId,address,
                     deliveryMethod,paymentMethod,note}
    provinces, districts, wards : List cho 3 select địa chỉ (đổi bằng JS gọi API riêng nếu cần)
    errors        : Map<String,String> lỗi từng ô
    cartItems, subtotal, discount, total : giống trang giỏ hàng
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Thanh toán · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<header class="sf-top">
  <nav class="sf-nav">
    <a class="sf-logo" href="${ctx}/home">
      <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-halo"/></svg>
      <span class="wm">HALO</span>
    </a>
    <div class="tools">
      <span class="mono" style="font-size:10px;letter-spacing:.16em;color:var(--titan);display:flex;align-items:center;gap:7px">
        <svg width="13" height="13"><use href="#i-lock"/></svg>THANH TOÁN AN TOÀN
      </span>
    </div>
  </nav>
</header>

<c:set var="activeStep" value="2"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:22px 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  <form method="post" action="${ctx}/checkout">
    <div class="split">
      <div style="display:flex;flex-direction:column;gap:18px">

        <div class="panel"><div class="panel-head"><h3>Người nhận hàng</h3></div><div class="panel-pad">
          <div class="grid-2">
            <div class="field ${not empty errors.fullName ? 'err' : ''}">
              <label>Họ và tên <span class="req">*</span></label>
              <input class="input" type="text" name="fullName" maxlength="100" value="<c:out value='${form.fullName}'/>">
              <c:if test="${not empty errors.fullName}">
                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.fullName}"/></div>
              </c:if>
            </div>
            <div class="field ${not empty errors.phone ? 'err' : ''}">
              <label>Số điện thoại <span class="req">*</span></label>
              <input class="input" type="tel" name="phone" maxlength="10" value="<c:out value='${form.phone}'/>">
              <c:if test="${not empty errors.phone}">
                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.phone}"/></div>
              </c:if>
            </div>
          </div>
          <div class="field ${not empty errors.email ? 'err' : ''}">
            <label>Email <span class="req">*</span></label>
            <input class="input" type="email" name="email" maxlength="100" value="<c:out value='${form.email}'/>">
            <c:if test="${not empty errors.email}">
              <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.email}"/></div>
            </c:if>
          </div>
          <div class="grid-3">
            <div class="field"><label>Tỉnh / Thành phố <span class="req">*</span></label>
              <select class="select" name="provinceId">
                <c:forEach var="p" items="${provinces}">
                  <option value="${p.id}" ${p.id == form.provinceId ? 'selected' : ''}><c:out value="${p.name}"/></option>
                </c:forEach>
              </select></div>
            <div class="field"><label>Quận / Huyện <span class="req">*</span></label>
              <select class="select" name="districtId">
                <c:forEach var="d" items="${districts}">
                  <option value="${d.id}" ${d.id == form.districtId ? 'selected' : ''}><c:out value="${d.name}"/></option>
                </c:forEach>
              </select></div>
            <div class="field"><label>Phường / Xã <span class="req">*</span></label>
              <select class="select" name="wardId">
                <c:forEach var="w" items="${wards}">
                  <option value="${w.id}" ${w.id == form.wardId ? 'selected' : ''}><c:out value="${w.name}"/></option>
                </c:forEach>
              </select></div>
          </div>
          <div class="field ${not empty errors.address ? 'err' : ''}" style="margin-bottom:0">
            <label>Địa chỉ cụ thể <span class="req">*</span></label>
            <input class="input" type="text" name="address" maxlength="200" value="<c:out value='${form.address}'/>">
            <c:choose>
              <c:when test="${not empty errors.address}">
                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.address}"/></div>
              </c:when>
              <c:otherwise><div class="help">Ghi rõ số nhà và tên đường để shipper tìm đúng</div></c:otherwise>
            </c:choose>
          </div>
        </div></div>

        <div class="panel"><div class="panel-head"><h3>Cách nhận hàng</h3></div><div class="panel-pad" style="display:flex;flex-direction:column;gap:10px">
          <label style="display:flex;gap:12px;align-items:center;border:1px solid ${form.deliveryMethod eq 'EXPRESS' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
            <input type="radio" name="deliveryMethod" value="EXPRESS" class="sr-only" ${form.deliveryMethod eq 'EXPRESS' ? 'checked' : ''}>
            <span style="width:16px;height:16px;border-radius:50%;border:${form.deliveryMethod eq 'EXPRESS' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
            <span style="flex:1"><b style="font-size:13.5px">Giao tận nơi trong 2 giờ</b><br><span style="font-size:12.5px;color:var(--ash)">Nội thành Hà Nội, nhận từ 8:30 đến 21:30</span></span>
            <b style="font-size:13.5px">Miễn phí</b>
          </label>
          <label style="display:flex;gap:12px;align-items:center;border:1px solid ${form.deliveryMethod eq 'PICKUP' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
            <input type="radio" name="deliveryMethod" value="PICKUP" class="sr-only" ${form.deliveryMethod eq 'PICKUP' ? 'checked' : ''}>
            <span style="width:16px;height:16px;border-radius:50%;border:${form.deliveryMethod eq 'PICKUP' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
            <span style="flex:1"><b style="font-size:13.5px">Nhận tại cửa hàng</b><br><span style="font-size:12.5px;color:var(--ash)">128 Cầu Giấy, Hà Nội · sẵn hàng sau 30 phút</span></span>
            <b style="font-size:13.5px">Miễn phí</b>
          </label>
        </div></div>

        <div class="panel"><div class="panel-head"><h3>Cách thanh toán</h3></div><div class="panel-pad" style="display:flex;flex-direction:column;gap:10px">
          <label style="display:flex;gap:12px;align-items:center;border:1px solid ${form.paymentMethod eq 'COD' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
            <input type="radio" name="paymentMethod" value="COD" class="sr-only" ${form.paymentMethod eq 'COD' ? 'checked' : ''}>
            <span style="width:16px;height:16px;border-radius:50%;border:${form.paymentMethod eq 'COD' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
            <b style="font-size:13.5px">Trả tiền khi nhận hàng</b>
          </label>
          <label style="display:flex;gap:12px;align-items:center;border:1px solid ${form.paymentMethod eq 'BANK' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
            <input type="radio" name="paymentMethod" value="BANK" class="sr-only" ${form.paymentMethod eq 'BANK' ? 'checked' : ''}>
            <span style="width:16px;height:16px;border-radius:50%;border:${form.paymentMethod eq 'BANK' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
            <b style="font-size:13.5px">Chuyển khoản ngân hàng</b>
          </label>
          <label style="display:flex;gap:12px;align-items:center;border:1px solid ${form.paymentMethod eq 'INSTALLMENT' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
            <input type="radio" name="paymentMethod" value="INSTALLMENT" class="sr-only" ${form.paymentMethod eq 'INSTALLMENT' ? 'checked' : ''}>
            <span style="width:16px;height:16px;border-radius:50%;border:${form.paymentMethod eq 'INSTALLMENT' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
            <b style="font-size:13.5px">Trả góp 0% qua thẻ tín dụng</b>
          </label>
          <div class="field" style="margin:6px 0 0">
            <label>Ghi chú cho cửa hàng</label>
            <textarea class="textarea" name="note" maxlength="300" placeholder="Ví dụ: gọi trước 15 phút khi giao"><c:out value="${form.note}"/></textarea>
          </div>
        </div></div>
      </div>

      <div class="panel" style="position:sticky;top:16px">
        <div class="panel-head"><h3>Đơn của bạn</h3><span class="r mono" style="font-size:11px;color:var(--ash)">${fn:length(cartItems)} món</span></div>
        <div class="panel-pad">
          <c:forEach var="item" items="${cartItems}">
            <div style="display:flex;gap:10px;align-items:center;margin-bottom:10px">
              <div class="shot" style="width:44px;height:44px;aspect-ratio:auto;border-radius:var(--r-sm)">
                <c:choose>
                  <c:when test="${not empty item.imageUrl}"><img src="${ctx}/uploads/${item.imageUrl}" alt=""></c:when>
                  <c:otherwise><svg style="color:#5B6472"><use href="#${empty item.iconKey ? 'd-acc' : item.iconKey}"/></svg></c:otherwise>
                </c:choose>
              </div>
              <div style="flex:1;font-size:12.5px"><b><c:out value="${item.name}"/></b><br><span style="color:var(--ash)">× ${item.quantity}</span></div>
              <span style="font-size:12.5px"><fmt:formatNumber value="${item.lineTotal}" type="number" maxFractionDigits="0"/> ₫</span>
            </div>
          </c:forEach>
          <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${subtotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
          <c:if test="${discount > 0}">
            <div class="sum-row"><span>Giảm giá</span><span style="color:var(--ok)">− <fmt:formatNumber value="${discount}" type="number" maxFractionDigits="0"/> ₫</span></div>
          </c:if>
          <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${total}" type="number" maxFractionDigits="0"/> ₫</span></div>
          <button type="submit" class="btn titan block" style="margin-top:16px">Đặt hàng</button>
        </div>
      </div>
    </div>
  </form>
</div>
</body>
</html>
