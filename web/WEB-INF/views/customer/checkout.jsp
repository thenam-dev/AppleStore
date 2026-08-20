<%--
  checkout.jsp — thanh toán.
  Servlet (CheckoutServlet) set khi GET: cartItems, cartTotal.
  Khi POST lỗi (forward, không redirect): cartItems, cartTotal, errorMsg, fieldErrors — request.getParameter
  vẫn còn nguyên nên trang này dùng ${param.xxx} để đổ lại dữ liệu đã nhập.
  Form field bắt buộc đúng tên: recipientName, recipientPhone, deliveryAddress,
  deliveryTimeSlot, notes, paymentMethod (CK | COD).
  Mã giảm giá: sessionScope.appliedPromo (Promotion), sessionScope.discountAmount (BigDecimal),
  set bởi ApplyVoucherServlet (/apply-voucher) và xoá bởi RemoveVoucherServlet (/remove-voucher).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Thanh toán · AppleStore</title>
        <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
    </head>
    <body>

        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <c:set var="activeStep" value="2" scope="request"/>
        <jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

        <div style="padding:22px 26px">
            <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

            <c:set var="paymentMethod" value="${empty param.paymentMethod ? 'CK' : param.paymentMethod}"/>

            <div class="split">
                <div style="display:flex;flex-direction:column;gap:18px">

                    <form id="checkout-form" method="post" action="${ctx}/checkout">
                        <div class="panel"><div class="panel-head"><h3>Người nhận hàng</h3></div><div class="panel-pad">
                                <div class="grid-2">
                                    <div class="field ${not empty fieldErrors.recipientName ? 'err' : ''}">
                                        <label>Tên người nhận <span class="req">*</span></label>
                                        <input class="input" type="text" name="recipientName" maxlength="100" value="<c:out value='${param.recipientName}'/>">
                                        <c:if test="${not empty fieldErrors.recipientName}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientName}"/></div>
                                            </c:if>
                                    </div>
                                    <div class="field ${not empty fieldErrors.recipientPhone ? 'err' : ''}">
                                        <label>Số điện thoại <span class="req">*</span></label>
                                        <input class="input" type="tel" name="recipientPhone" maxlength="15" value="<c:out value='${param.recipientPhone}'/>">
                                        <c:if test="${not empty fieldErrors.recipientPhone}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientPhone}"/></div>
                                            </c:if>
                                    </div>
                                </div>
                                <div class="field ${not empty fieldErrors.deliveryAddress ? 'err' : ''}" style="margin-bottom:0">
                                    <label>Địa chỉ giao hàng <span class="req">*</span></label>
                                    <textarea class="textarea" name="deliveryAddress" maxlength="500"><c:out value="${param.deliveryAddress}"/></textarea>
                                    <c:choose>
                                        <c:when test="${not empty fieldErrors.deliveryAddress}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.deliveryAddress}"/></div>
                                            </c:when>
                                            <c:otherwise><div class="help">Ghi rõ số nhà, đường, phường/quận để shipper tìm đúng</div></c:otherwise>
                                    </c:choose>
                                </div>
                            </div></div>

                        <div class="panel" style="margin-top:18px"><div class="panel-head"><h3>Giao hàng</h3></div><div class="panel-pad">
                                <div class="grid-2">
                                    <div class="field">
                                        <label>Khung giờ nhận hàng</label>
                                        <input class="input" type="text" name="deliveryTimeSlot" value="<c:out value='${param.deliveryTimeSlot}'/>" placeholder="Ví dụ: 8h - 12h">
                                    </div>
                                    <div class="field" style="margin-bottom:0">
                                        <label>Ghi chú cho cửa hàng</label>
                                        <input class="input" type="text" name="notes" maxlength="300" value="<c:out value='${param.notes}'/>" placeholder="Ví dụ: gọi trước khi giao">
                                    </div>
                                </div>
                            </div></div>

                        <div class="panel" style="margin-top:18px"><div class="panel-head"><h3>Phương thức thanh toán</h3></div>
                            <div class="panel-pad" style="display:flex;flex-direction:column;gap:10px">
                                <label style="display:flex;gap:12px;align-items:center;border:1px solid ${paymentMethod eq 'CK' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
                                    <input type="radio" name="paymentMethod" value="CK" class="sr-only" ${paymentMethod eq 'CK' ? 'checked' : ''}>
                                    <span style="width:16px;height:16px;border-radius:50%;border:${paymentMethod eq 'CK' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
                                    <span style="flex:1"><b style="font-size:13.5px">Chuyển khoản qua SePay</b><br><span style="font-size:12.5px;color:var(--ash)">Quét mã QR ở bước tiếp theo</span></span>
                                </label>
                                <label style="display:flex;gap:12px;align-items:center;border:1px solid ${paymentMethod eq 'COD' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
                                    <input type="radio" name="paymentMethod" value="COD" class="sr-only" ${paymentMethod eq 'COD' ? 'checked' : ''}>
                                    <span style="width:16px;height:16px;border-radius:50%;border:${paymentMethod eq 'COD' ? '5px solid var(--ink)' : '1px solid var(--line)'}"></span>
                                    <b style="font-size:13.5px">Thanh toán khi nhận hàng (COD)</b>
                                </label>
                                <c:if test="${not empty fieldErrors.paymentMethod}">
                                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.paymentMethod}"/></div>
                                    </c:if>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="panel" style="position:sticky;top:16px">
                    <div class="panel-head"><h3>Đơn của bạn</h3><span class="r mono" style="font-size:11px;color:var(--ash)">${fn:length(cartItems)} món</span></div>
                    <div class="panel-pad">
                        <c:forEach var="item" items="${cartItems}">
                            <div class="sum-row">
                                <span><c:out value="${item.productName}"/> (<c:out value="${item.variantLabel}"/>) &times; ${item.quantity}</span>
                                <span><fmt:formatNumber value="${item.lineTotal}" type="number" maxFractionDigits="0"/> ₫</span>
                            </div>
                        </c:forEach>

                        <!-- Form nhập mã giảm giá -->
                        <form action="${ctx}/apply-voucher" method="post" style="display:flex;gap:8px;margin:14px 0 6px">
                            <input class="input" type="text" name="voucherCode"
                                   placeholder="Nhập mã khuyến mãi…" style="height:38px">
                            <button class="btn quiet sm" type="submit">Áp dụng</button>
                        </form>
                        <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:10px">
                            <a href="${ctx}/vouchers" style="color:var(--graphite);border-bottom:1px solid var(--line)">Chọn mã có sẵn</a>
                        </div>

                        <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>

                        <!-- 1. HIỂN THỊ MÃ GIẢM GIÁ HÀNG HÓA -->
                        <c:if test="${not empty sessionScope.merchandisePromo}">
                            <div class="sum-row" style="color:var(--ok)">
                                <span style="display:flex;justify-content:space-between;width:100%">
                                    <span>Giảm hàng (<c:out value="${sessionScope.merchandisePromo.code}"/>) 
                                        <a href="${ctx}/remove-voucher?type=merchandise" style="color:var(--danger);font-size:11px;margin-left:6px">[Gỡ]</a>
                                    </span>
                                    <span>− <fmt:formatNumber value="${sessionScope.merchandiseDiscount}" type="number" maxFractionDigits="0"/> ₫</span>
                                </span>
                            </div>
                        </c:if>

                        <!-- 2. HIỂN THỊ MÃ FREESHIP -->
                        <c:if test="${not empty sessionScope.shippingPromo}">
                            <div class="sum-row" style="color:var(--ok)">
                                <span style="display:flex;justify-content:space-between;width:100%">
                                    <span>Freeship (<c:out value="${sessionScope.shippingPromo.code}"/>) 
                                        <a href="${ctx}/remove-voucher?type=shipping" style="color:var(--danger);font-size:11px;margin-left:6px">[Gỡ]</a>
                                    </span>
                                    <span>− <fmt:formatNumber value="${sessionScope.shippingDiscount}" type="number" maxFractionDigits="0"/> ₫</span>
                                </span>
                            </div>
                        </c:if>

                        <!-- TÍNH TOÁN TỔNG TIỀN CUỐI CÙNG -->
                        <c:set var="totalMerchDiscount" value="${not empty sessionScope.merchandiseDiscount ? sessionScope.merchandiseDiscount : 0}"/>
                        <c:set var="totalShipDiscount" value="${not empty sessionScope.shippingDiscount ? sessionScope.shippingDiscount : 0}"/>
                        <c:set var="combinedDiscount" value="${totalMerchDiscount + totalShipDiscount}"/>

                        <c:set var="finalCheckoutTotal" value="${cartTotal - combinedDiscount}"/>

                        <div class="sum-row total">
                            <span>Tổng cộng</span>
                            <span><fmt:formatNumber value="${finalCheckoutTotal < 0 ? 0 : finalCheckoutTotal}" type="number" maxFractionDigits="0"/> ₫</span>
                        </div>

                        <button type="submit" form="checkout-form" class="btn titan block" style="margin-top:16px">Đặt hàng</button>
                        <a class="btn ghost block" style="margin-top:10px" href="${ctx}/cart">Quay lại giỏ hàng</a>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
    </body>
</html>
