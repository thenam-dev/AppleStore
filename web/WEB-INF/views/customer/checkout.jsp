<%--
  checkout.jsp — thanh toán.
  Servlet (CheckoutServlet) set khi GET: cartItems, cartTotal.
  Khi POST lỗi (forward, không redirect): cartItems, cartTotal, errorMsg, fieldErrors — request.getParameter
  vẫn còn nguyên nên trang này dùng ${param.xxx} để đổ lại dữ liệu đã nhập.
  Form field bắt buộc đúng tên: recipientName, recipientPhone, deliveryAddress,
  deliveryTimeSlot, notes, paymentMethod (CK | COD).
  Mã giảm giá: sessionScope.appliedPromo (Promotion), sessionScope.discountAmount (BigDecimal),
  set bởi ApplyVoucherServlet (/apply-voucher) và xoá bởi RemoveVoucherServlet (/remove-voucher).
  Bấm "+ Nhập địa chỉ khác" thì xoá trắng 3 ô Người nhận hàng (không giữ lại dữ liệu địa chỉ
  mặc định đã điền sẵn trước đó) rồi validate không cho rỗng/toàn khoảng trắng ngay trên trình
  duyệt trước khi submit (form có novalidate, JS tự vẽ khung .err-msg đỏ) - server
  (CheckoutService) vẫn validate lại độc lập, JS chỉ để phản hồi nhanh hơn.
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

                    <%-- Chỉ hiện option địa chỉ MẶC ĐỊNH (không liệt kê hết sổ địa chỉ) + option
                         "Nhập địa chỉ khác". Đổi địa chỉ mặc định thì vào "Quản lý sổ địa chỉ". --%>
                    <c:set var="defaultAddress" value=""/>
                    <c:forEach var="addr" items="${savedAddresses}">
                        <c:if test="${addr.isDefault == 1}"><c:set var="defaultAddress" value="${addr}"/></c:if>
                    </c:forEach>
                    <%-- otherSelected: quyết định radio nào đang được chọn. showRecipientForm:
                         quyết định panel "Người nhận hàng" có hiện hay không - vẫn phải ép hiện
                         khi submit lỗi ngay trên các trường này (vd. địa chỉ mặc định có SĐT sai
                         định dạng) để khách còn thấy đường sửa, dù đang chọn địa chỉ mặc định. --%>
                    <c:set var="otherSelected" value="${param.addressChoice eq 'other' or (empty param.addressChoice and empty defaultAddress)}"/>
                    <c:set var="showRecipientForm" value="${otherSelected or not empty fieldErrors.recipientName or not empty fieldErrors.recipientPhone or not empty fieldErrors.deliveryAddress}"/>

                    <%-- novalidate: nhường toàn bộ việc báo lỗi rỗng cho JS validate ở cuối
                         trang (khung .err-msg đỏ đồng bộ với lỗi server trả về), tránh vừa
                         hiện bubble validate mặc định của trình duyệt vừa hiện khung lỗi tự
                         viết cho 2 kiểu rỗng khác nhau (rỗng hẳn vs. chỉ toàn khoảng trắng). --%>
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

                            </div>
                            <div class="panel" id="recipientFormPanel" style="margin-top:18px${showRecipientForm ? '' : ';display:none'}">
                                <div class="panel-head"><h3>Người nhận hàng</h3></div><div class="panel-pad">
                                    <div class="grid-2">
                                        <div class="field ${not empty fieldErrors.recipientName ? 'err' : ''}">
                                            <label>Tên người nhận <span class="req">*</span></label>
                                            <input class="input" type="text" name="recipientName" id="recipientNameInput" maxlength="100" required value="<c:out value='${param.recipientName}'/>">
                                            <c:if test="${not empty fieldErrors.recipientName}">
                                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientName}"/></div>
                                                </c:if>
                                        </div>
                                        <div class="field ${not empty fieldErrors.recipientPhone ? 'err' : ''}">
                                            <label>Số điện thoại <span class="req">*</span></label>
                                            <input class="input" type="tel" name="recipientPhone" id="recipientPhoneInput" maxlength="15" required value="<c:out value='${param.recipientPhone}'/>">
                                            <c:if test="${not empty fieldErrors.recipientPhone}">
                                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.recipientPhone}"/></div>
                                                </c:if>
                                        </div>
                                    </div>
                                    <div class="field ${not empty fieldErrors.deliveryAddress ? 'err' : ''}" style="margin-bottom:0">
                                        <label>Địa chỉ giao hàng <span class="req">*</span></label>
                                        <textarea class="textarea" name="deliveryAddress" id="deliveryAddressInput" maxlength="500" required><c:out value="${param.deliveryAddress}"/></textarea>
                                        <c:choose>
                                            <c:when test="${not empty fieldErrors.deliveryAddress}">
                                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${fieldErrors.deliveryAddress}"/></div>
                                                </c:when>
                                                <c:otherwise><div class="help">Ghi rõ số nhà, đường, phường/quận để shipper tìm đúng</div></c:otherwise>
                                        </c:choose>
                                    </div>
                                    </label>
                                </div></div></div>


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
                                <label class="pm-option">
                                    <input type="radio" name="paymentMethod" value="CK" class="sr-only" ${paymentMethod eq 'CK' ? 'checked' : ''}>
                                    <span class="pm-dot"></span>
                                    <span style="flex:1"><b style="font-size:13.5px">Chuyển khoản qua SePay</b><br><span style="font-size:12.5px;color:var(--ash)">Quét mã QR ở bước tiếp theo</span></span>
                                </label>
                                <label class="pm-option">
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

                        <form action="${ctx}/apply-voucher" method="post" style="display:flex;gap:8px;margin:14px 0 6px">
                            <input class="input" type="text" name="voucherCode"
                                   value="${not empty sessionScope.appliedPromo ? sessionScope.appliedPromo.code : ''}"
                                   placeholder="Nhập mã khuyến mãi…" style="height:38px">
                            <button class="btn quiet sm" type="submit">Áp dụng</button>
                        </form>
                        <div style="display:flex;justify-content:space-between;font-size:12px;margin-bottom:10px">
                            <a href="${ctx}/vouchers" style="color:var(--graphite);border-bottom:1px solid var(--line)">Chọn mã có sẵn</a>
                            <c:if test="${not empty sessionScope.appliedPromo}">
                                <a href="${ctx}/remove-voucher" style="color:var(--danger)">Gỡ bỏ mã</a>
                            </c:if>
                        </div>

                        <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
                        <c:if test="${not empty sessionScope.appliedPromo}">
                            <div class="sum-row" style="color:var(--ok)">
                                <span>Giảm giá (<c:out value="${sessionScope.appliedPromo.code}"/>)</span>
                                <span>− <fmt:formatNumber value="${sessionScope.discountAmount}" type="number" maxFractionDigits="0"/> ₫</span>
                            </div>
                        </c:if>

                        <c:set var="finalCheckoutTotal" value="${cartTotal - (not empty sessionScope.discountAmount ? sessionScope.discountAmount : 0)}"/>
                        <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${finalCheckoutTotal < 0 ? 0 : finalCheckoutTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>

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

                // LƯU Ý: không khoá readonly các ô này khi chọn địa chỉ có sẵn - chỉ điền sẵn
                // dữ liệu để tiện, khách vẫn sửa được nếu địa chỉ đã lưu trong sổ bị thiếu/sai
                // (vd. số điện thoại cũ không còn đúng định dạng khiến submit bị chặn mà
                // không có cách nào sửa nếu ô bị khoá cứng).
                //
                // toggleVisibility=false ở lần gọi đầu (load trang) để không đè lên trạng
                // thái hiện/ẩn panel mà server đã tính sẵn (JSP ép hiện panel khi submit lỗi
                // ngay trên các trường này, dù đang chọn địa chỉ mặc định) - chỉ bật/tắt panel
                // theo lựa chọn MỚI của khách từ lần bấm radio trở đi.
                function applySelection(radio, toggleVisibility) {
                    if (toggleVisibility && formPanel) {
                        formPanel.style.display = radio.value === 'other' ? '' : 'none';
                    }
                    if (radio.value === 'other') {
                        // Khách CHỦ ĐỘNG bấm "+ Nhập địa chỉ khác" ngay trong phiên này
                        // (toggleVisibility=true) - xoá trắng 3 ô, tránh còn sót dữ liệu
                        // của địa chỉ mặc định vừa điền sẵn trước đó (bug cũ: bấm "Nhập
                        // địa chỉ khác" nhưng form vẫn hiện tên/SĐT/địa chỉ mặc định).
                        // KHÔNG xoá ở lần gọi đầu khi tải trang (toggleVisibility=false)
                        // vì lúc đó có thể đang hiện lại dữ liệu khách vừa nhập bị lỗi
                        // validate (submit thất bại, forward lại kèm ${param.xxx}) - xoá
                        // đi sẽ mất luôn dữ liệu khách vừa gõ.
                        if (toggleVisibility) {
                            if (nameInput) { nameInput.value = ''; }
                            if (phoneInput) { phoneInput.value = ''; }
                            if (addressInput) { addressInput.value = ''; }
                            if (nameInput) { nameInput.focus(); }
                        }
                        return;
                    }
                    var label = radio.closest('.addr-option');
                    if (!label) {
                        return;
                    }
                    if (nameInput) {
                        nameInput.value = label.dataset.name || '';
                    }
                    if (phoneInput) {
                        phoneInput.value = label.dataset.phone || '';
                    }
                    if (addressInput) {
                        addressInput.value = label.dataset.address || '';
                    }
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
            // Validate không để trống 3 trường bắt buộc của "Người nhận hàng" ngay
            // trên trình duyệt trước khi submit. HTML required (đã thêm ở input/textarea)
            // chặn được rỗng hẳn, nhưng không chặn được chuỗi toàn khoảng trắng (server
            // .trim() rồi mới coi là rỗng, xem CheckoutService) nên vẫn cần JS ở đây.
            // Bỏ qua nếu panel đang ẩn (khách dùng địa chỉ mặc định có sẵn, dữ liệu đã
            // hợp lệ từ sổ địa chỉ - server vẫn tự validate lại dù client bỏ qua).
            // stopImmediatePropagation() khi có lỗi để script chặn-bấm-đúp bên dưới
            // (đăng ký submit trên cùng #checkout-form) không chạy - nếu không, nút
            // "Đặt hàng" sẽ bị disable vĩnh viễn dù request chưa từng được gửi đi.
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

                // Gõ lại thì gỡ lỗi ngay, không cần đợi submit lại mới biết đã sửa đúng.
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
            // Chặn bấm đúp/gửi lại nút "Đặt hàng" - server hiện chưa có cơ chế chống
            // trùng submit (idempotency key), bấm đúp nhanh có thể tạo 2 đơn giống hệt
            // nhau. Chỉ disable trong sự kiện submit (không preventDefault) nên request
            // đầu tiên vẫn đi bình thường, chỉ chặn các lần bấm/Enter tiếp theo.
            (function () {
                var form = document.getElementById('checkout-form');
                var btn = document.getElementById('placeOrderBtn');
                if (!form || !btn) {
                    return;
                }
                form.addEventListener('submit', function () {
                    btn.disabled = true;
                    btn.textContent = 'Đang xử lý…';
                });
            })();
        </script>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
    </body>
</html>
