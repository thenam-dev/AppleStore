<%--
  checkout.jsp — thanh toán.
  Servlet (CheckoutServlet) set khi GET: cartItems, cartTotal.
  Khi POST lỗi (forward, không redirect): cartItems, cartTotal, errorMsg, fieldErrors — request.getParameter
  vẫn còn nguyên nên trang này dùng ${param.xxx} để đổ lại dữ liệu đã nhập.
  Form field bắt buộc đúng tên: recipientName, recipientPhone, deliveryAddress,
  deliveryTimeSlot, notes, paymentMethod (CK | COD).
  Mã giảm giá quản lý qua session.
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

                    <c:set var="defaultAddress" value=""/>
                    <c:forEach var="addr" items="${savedAddresses}">
                        <c:if test="${addr.isDefault == 1}"><c:set var="defaultAddress" value="${addr}"/></c:if>
                    </c:forEach>

                    <c:set var="otherSelected" value="${param.addressChoice eq 'other' or (empty param.addressChoice and empty defaultAddress)}"/>
                    <c:set var="showRecipientForm" value="${otherSelected or not empty fieldErrors.recipientName or not empty fieldErrors.recipientPhone or not empty fieldErrors.deliveryAddress}"/>

                    <form id="checkout-form" method="post" action="${ctx}/checkout" novalidate>
                        <div class="panel"><div class="panel-head">
                                <h3>Địa chỉ giao hàng</h3>
                                <a class="r" style="font-size:12px;color:var(--graphite);border-bottom:1px solid var(--line)"
                                   href="${ctx}/addresses" target="_blank" rel="noopener">Quản lý sổ địa chỉ</a>
                            </div><div class="panel-pad" style="display:flex;flex-direction:column;gap:10px">
                                <c:if test="${not empty defaultAddress}">
                                    <label class="pm-option addr-option"
                                           data-name="<c:out value='${defaultAddress.recipientName}'/>"
                                           data-phone="<c:out value='${defaultAddress.recipientPhone}'/>"
                                           data-address="<c:out value='${defaultAddress.addressDetail}, ${defaultAddress.ward}, ${defaultAddress.district}, ${defaultAddress.province}'/>">
                                        <input type="radio" name="addressChoice" class="sr-only addr-radio" value="${defaultAddress.addressId}"
                                               ${otherSelected ? '' : 'checked'}>
                                        <span class="pm-dot"></span>
                                        <span style="flex:1">
                                            <b style="font-size:13.5px"><c:out value="${defaultAddress.recipientName}"/></b>
                                            &middot; <span class="mono" style="font-size:12px"><c:out value="${defaultAddress.recipientPhone}"/></span>
                                            <span class="tag" style="margin-left:6px; outline-color: red">Mặc định</span>
                                            <br><span style="font-size:12.5px;color:var(--ash)">
                                                <c:out value="${defaultAddress.addressDetail}"/>, <c:out value="${defaultAddress.ward}"/>, <c:out value="${defaultAddress.district}"/>, <c:out value="${defaultAddress.province}"/>
                                            </span>
                                        </span>
                                    </label>
                                </c:if>
                                <label class="pm-option addr-option">
                                    <input type="radio" name="addressChoice" class="sr-only addr-radio" value="other" id="addrOther"
                                           ${otherSelected ? 'checked' : ''}>
                                    <span class="pm-dot"></span>
                                    <b style="font-size:13.5px">+ Nhập địa chỉ khác</b>
                                </label>
                            </div>
                        </div>

                        <div class="panel" id="recipientFormPanel" style="margin-top:18px${showRecipientForm ? '' : ';display:none'}">
                            <div class="panel-head"><h3>Người nhận hàng</h3></div><div class="panel-pad">
                                <div class="grid-2">
                                    <div class="field ${not empty fieldErrors.recipientName ? 'err' : ''}">
                                        <label>Tên người nhận <span class="req">*</span></label>
                                        <input class="input" type="text" name="recipientName" id="recipientNameInput" maxlength="100" value="<c:out value='${param.recipientName}'/>">
                                        <c:if test="${not empty fieldErrors.recipientName}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientName}"/></div>
                                        </c:if>
                                    </div>
                                    <div class="field ${not empty fieldErrors.recipientPhone ? 'err' : ''}">
                                        <label>Số điện thoại <span class="req">*</span></label>
                                        <input class="input" type="tel" name="recipientPhone" id="recipientPhoneInput" maxlength="15" value="<c:out value='${param.recipientPhone}'/>">
                                        <c:if test="${not empty fieldErrors.recipientPhone}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientPhone}"/></div>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="field ${not empty fieldErrors.deliveryAddress ? 'err' : ''}" style="margin-bottom:0">
                                    <label>Địa chỉ giao hàng <span class="req">*</span></label>
                                    <textarea class="textarea" name="deliveryAddress" id="deliveryAddressInput" maxlength="500"><c:out value="${param.deliveryAddress}"/></textarea>
                                    <c:choose>
                                        <c:when test="${not empty fieldErrors.deliveryAddress}">
                                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.deliveryAddress}"/></div>
                                        </c:when>
                                        <c:otherwise><div class="help">Ghi rõ số nhà, đường, phường/quận để shipper tìm đúng</div></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <div class="panel" style="margin-top:18px"><div class="panel-head"><h3>Giao hàng</h3></div><div class="panel-pad">
                                <div class="grid-2">
                                    <div class="field">
                                        <label>Khung giờ nhận hàng (Optional)</label>
                                        <input class="input" type="text" name="deliveryTimeSlot" value="<c:out value='${param.deliveryTimeSlot}'/>" placeholder="Ví dụ: 8h - 12h">
                                    </div>
                                    <div class="field" style="margin-bottom:0">
                                        <label>Ghi chú cho cửa hàng (Optional)</label>
                                        <input class="input" type="text" name="notes" maxlength="300" value="<c:out value='${param.notes}'/>" placeholder="Ví dụ: gọi trước khi giao">
                                    </div>
                                </div>
                            </div></div>

                        <div class="panel" style="margin-top:18px"><div class="panel-head"><h3>Phương thức thanh toán</h3></div>
                            <div class="panel-pad" style="display:flex;flex-direction:column;gap:10px">
                                <label class="pm-option" style="display:flex;gap:12px;align-items:center;border:1px solid ${paymentMethod eq 'CK' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
                                    <input type="radio" name="paymentMethod" value="CK" class="sr-only" ${paymentMethod eq 'CK' ? 'checked' : ''}>
                                    <span class="pm-dot"></span>
                                    <span style="flex:1"><b style="font-size:13.5px">Chuyển khoản qua SePay</b><br><span style="font-size:12.5px;color:var(--ash)">Quét mã QR ở bước tiếp theo</span></span>
                                </label>
                                <label class="pm-option" style="display:flex;gap:12px;align-items:center;border:1px solid ${paymentMethod eq 'COD' ? 'var(--ink)' : 'var(--line)'};border-radius:var(--r-sm);padding:13px 15px">
                                    <input type="radio" name="paymentMethod" value="COD" class="sr-only" ${paymentMethod eq 'COD' ? 'checked' : ''}>
                                    <span class="pm-dot"></span>
                                    <b style="font-size:13.5px">Thanh toán khi nhận hàng (COD)</b>
                                </label>
                                <c:if test="${not empty fieldErrors.paymentMethod}">
                                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.paymentMethod}"/></div>
                                </c:if>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="panel" style="position:sticky;top:calc(var(--sf-header-h) + 16px)">
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
                                   value="${not empty sessionScope.merchandisePromo ? sessionScope.merchandisePromo.code : (not empty sessionScope.shippingPromo ? sessionScope.shippingPromo.code : '')}"
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

                        <button type="submit" form="checkout-form" id="placeOrderBtn" class="btn titan block" style="margin-top:16px">Đặt hàng</button>
                        <a class="btn ghost block" style="margin-top:10px" href="${ctx}/cart">Quay lại giỏ hàng</a>
                    </div>
                </div>
            </div>
        </div>

        <script>
            (function () {
                var radios = document.querySelectorAll('.addr-radio');
                var nameInput = document.getElementById('recipientNameInput');
                var phoneInput = document.getElementById('recipientPhoneInput');
                var addressInput = document.getElementById('deliveryAddressInput');
                var formPanel = document.getElementById('recipientFormPanel');

                function applySelection(radio, toggleVisibility) {
                    if (toggleVisibility && formPanel) {
                        formPanel.style.display = radio.value === 'other' ? '' : 'none';
                    }
                    if (radio.value === 'other') {
                        if (toggleVisibility) {
                            if (nameInput) { nameInput.value = ''; }
                            if (phoneInput) { phoneInput.value = ''; }
                            if (addressInput) { addressInput.value = ''; }
                            if (nameInput) { nameInput.focus(); }
                        }
                        return;
                    }
                    var label = radio.closest('.addr-option');
                    if (!label) { return; }
                    if (nameInput) { nameInput.value = label.dataset.name || ''; }
                    if (phoneInput) { phoneInput.value = label.dataset.phone || ''; }
                    if (addressInput) { addressInput.value = label.dataset.address || ''; }
                }

                radios.forEach(function (radio) {
                    radio.addEventListener('change', function () {
                        applySelection(radio, true);
                    });
                });

                var checkedRadio = document.querySelector('.addr-radio:checked');
                if (checkedRadio) {
                    applySelection(checkedRadio, false);
                }
            })();
        </script>

        <script>
            (function () {
                var form = document.getElementById('checkout-form');
                var formPanel = document.getElementById('recipientFormPanel');
                if (!form) { return; }

                var REQUIRED_FIELDS = [
                    { id: 'recipientNameInput', message: 'Vui lòng nhập tên người nhận' },
                    { id: 'recipientPhoneInput', message: 'Vui lòng nhập số điện thoại' },
                    { id: 'deliveryAddressInput', message: 'Vui lòng nhập địa chỉ giao hàng' }
                ];

                function isBlank(value) {
                    return !value || value.trim() === '';
                }

                function setFieldError(input, message) {
                    var fieldEl = input.closest('.field');
                    if (!fieldEl) { return; }
                    fieldEl.classList.add('err');
                    var help = fieldEl.querySelector('.help');
                    if (help) { help.style.display = 'none'; }
                    var msgEl = fieldEl.querySelector('.err-msg');
                    if (!msgEl) {
                        msgEl = document.createElement('div');
                        msgEl.className = 'err-msg';
                        msgEl.innerHTML = '<svg width="14" height="14"><use href="#i-alert"/></svg>';
                        fieldEl.appendChild(msgEl);
                    }
                    while (msgEl.lastChild && msgEl.lastChild.nodeType === 3) {
                        msgEl.removeChild(msgEl.lastChild);
                    }
                    msgEl.appendChild(document.createTextNode(message));
                }

                function clearFieldError(input) {
                    var fieldEl = input.closest('.field');
                    if (!fieldEl) { return; }
                    fieldEl.classList.remove('err');
                    var msgEl = fieldEl.querySelector('.err-msg');
                    if (msgEl) { msgEl.remove(); }
                    var help = fieldEl.querySelector('.help');
                    if (help) { help.style.display = ''; }
                }

                REQUIRED_FIELDS.forEach(function (f) {
                    var input = document.getElementById(f.id);
                    if (!input) { return; }
                    input.addEventListener('input', function () {
                        if (!isBlank(input.value)) { clearFieldError(input); }
                    });
                });

                form.addEventListener('submit', function (e) {
                    if (formPanel && formPanel.style.display === 'none') { return; }

                    var firstInvalid = null;
                    REQUIRED_FIELDS.forEach(function (f) {
                        var input = document.getElementById(f.id);
                        if (!input) { return; }
                        if (isBlank(input.value)) {
                            setFieldError(input, f.message);
                            if (!firstInvalid) { firstInvalid = input; }
                        } else {
                            clearFieldError(input);
                        }
                    });

                    if (firstInvalid) {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        firstInvalid.focus();
                    }
                });
            })();
        </script>

        <script>
            (function () {
                var form = document.getElementById('checkout-form');
                var btn = document.getElementById('placeOrderBtn');
                if (!form || !btn) { return; }
                form.addEventListener('submit', function () {
                    btn.disabled = true;
                    btn.textContent = 'Đang xử lý…';
                });
            })();
        </script>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
    </body>
</html>